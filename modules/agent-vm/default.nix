{
  config,
  lib,
  pkgs,
  inputs,
  osConfig ? null,
  ...
}: let
  cfg = config.internal.clankerVm;

  sshHost = "clanker-vm"; # ssh alias; used by the scripts and the ssh block
  sshPort = 6769; # must equal host.port in guest.nix
  acpCommand = "claude-agent-acp"; # binary run inside the VM
  hostHome = config.home.homeDirectory;

  hostUid = let
    u =
      if osConfig != null
      then (osConfig.users.users.${config.home.username}.uid or null)
      else null;
  in
    if u == null
    then 1000
    else u;

  guest = inputs.nixpkgs.lib.nixosSystem {
    system = pkgs.stdenv.hostPlatform.system;
    specialArgs = {
      inherit hostHome;
      agentPubKey = cfg.publicKey;
      agentUid = hostUid;
      agentGit = cfg.git;
    };
    modules = [
      inputs.microvm.nixosModules.microvm
      ./guest.nix
    ];
  };

  # the guest's one normal user, read back from the guest config
  vmUser =
    lib.head (lib.attrNames
      (lib.filterAttrs (_: u: u.isNormalUser) guest.config.users.users));

  runner = guest.config.microvm.declaredRunner;

  # Start/stop the VM on demand, and hand repos to it. No systemd involved.
  clankerCtl = pkgs.writeShellScriptBin "clankerctl" ''
    export PATH=${lib.makeBinPath [pkgs.coreutils pkgs.openssh pkgs.util-linux pkgs.git]}:$PATH
    # directory name kept as "agent-vm" so existing disk images are reused
    state="''${XDG_STATE_HOME:-$HOME/.local/state}/agent-vm"
    mkdir -p "$state" "$HOME/agent"

    is_up() {
      ssh -n -T -o BatchMode=yes -o ConnectTimeout=2 -o LogLevel=ERROR ${sshHost} true 2>/dev/null
    }

    case "''${1:-}" in
      up)
        if is_up; then echo "clanker-vm: already running" >&2; exit 0; fi
        cd "$state"
        # `flock -n` holds this lock for as long as the VM runs. If it is held,
        # a start is already in progress, so only wait instead of starting twice.
        if flock -n "$state/run.lock" true; then
          setsid -f flock -n "$state/run.lock" ${runner}/bin/microvm-run \
            >>"$state/vm.log" 2>&1 </dev/null
          echo "clanker-vm: starting (log: $state/vm.log)" >&2
        else
          echo "clanker-vm: start already in progress, waiting" >&2
        fi
        for _ in $(seq 1 90); do
          if is_up; then echo "clanker-vm: ready" >&2; exit 0; fi
          sleep 1
        done
        echo "clanker-vm: not reachable after 90s, see $state/vm.log" >&2
        exit 1
        ;;
      down)
        cd "$state" && exec ${runner}/bin/microvm-shutdown
        ;;
      status)
        if is_up; then echo up; else echo down; exit 1; fi
        ;;
      logs)
        exec tail -f "$state/vm.log"
        ;;
      add)
        # Copy a host repo into ~/agent by pushing it. The repo is created inside
        # the VM over ssh, so nothing on the host writes into ~/agent, and git on
        # the host only ever runs in the (trusted) source repo.
        src=$(git -C "''${2:-.}" rev-parse --show-toplevel) || exit 1
        case "$src" in
          "$HOME/agent" | "$HOME/agent"/*)
            echo "clankerctl: $src is already inside ~/agent" >&2
            exit 1
            ;;
        esac
        name=$(basename "$src")
        branch=$(git -C "$src" symbolic-ref --short HEAD) || exit 1
        dest="$HOME/agent/$name"
        q=$(printf '%q' "$dest")

        "$0" up || exit 1
        if ssh -n -T ${sshHost} "test -e $q"; then
          echo "clankerctl: $dest already exists" >&2
          exit 1
        fi
        # updateInstead: a push to the checked-out branch also updates the files,
        # and is refused if the agent has uncommitted changes there.
        ssh -n -T ${sshHost} "git init -q -b $(printf '%q' "$branch") $q &&
          git -C $q config receive.denyCurrentBranch updateInstead" || exit 1

        if git -C "$src" remote get-url clanker >/dev/null 2>&1; then
          echo "clankerctl: repointing existing remote 'clanker' to $dest" >&2
          git -C "$src" remote set-url clanker "${sshHost}:$dest"
        else
          git -C "$src" remote add clanker "${sshHost}:$dest"
        fi
        # plain `git push clanker` then pushes this branch (forced, like a sync)
        git -C "$src" config remote.clanker.push "+refs/heads/$branch:refs/heads/$branch"
        git -C "$src" push clanker || exit 1
        echo "clankerctl: $name is at $dest; update it with: git push clanker" >&2
        ;;
      *)
        echo "usage: clankerctl up|down|status|logs|add [repo]" >&2
        exit 2
        ;;
    esac
  '';

  # What agent-shell launches. ACP runs over stdout, so everything the
  # start-up step prints goes to stderr.
  agentVmAcp = pkgs.writeShellScriptBin "agent-vm-acp" ''
    case "$PWD" in
      "$HOME/agent"/*) ;;
      *)
        echo "agent-vm-acp: refusing to run outside ~/agent (cwd: $PWD)" >&2
        exit 1
        ;;
    esac
    ${clankerCtl}/bin/clankerctl up >&2 </dev/null || exit 1
    dir=$(printf '%q' "$PWD")
    exec ${pkgs.openssh}/bin/ssh -T -o BatchMode=yes -o LogLevel=ERROR \
      ${sshHost} "cd $dir && exec ${acpCommand}"
  '';
in {
  options.internal.clankerVm = {
    enable = lib.mkEnableOption "sandboxed agent microVM (start with `clankerctl up`)";

    publicKey = lib.mkOption {
      type = lib.types.str;
      example = "ssh-ed25519 AAAA... clanker";
      description = "Public key authorised for the VM user. Its private half is ~/.ssh/clanker.";
    };

    git = {
      userName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "clanker";
        description = "user.name for commits made inside the VM.";
      };

      userEmail = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "clanker@example.com";
        description = "user.email for commits made inside the VM.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [clankerCtl agentVmAcp];

    programs.ssh = {
      enable = true;
      # entryBefore: ssh uses the first value it finds, so this block must come
      # before your "*" block (which sets controlMaster = "no").
      matchBlocks.${sshHost} = lib.hm.dag.entryBefore ["*"] {
        hostname = "127.0.0.1";
        port = sshPort;
        user = vmUser;
        identityFile = "${hostHome}/.ssh/clanker";
        identitiesOnly = true;
        extraOptions = {
          StrictHostKeyChecking = "accept-new";
          UserKnownHostsFile = "${hostHome}/.ssh/known_hosts_${sshHost}";
          ServerAliveInterval = "30";
          ControlMaster = "auto";
          ControlPath = "${hostHome}/.ssh/cm-%C";
          ControlPersist = "10m";
        };
      };
    };
  };
}
