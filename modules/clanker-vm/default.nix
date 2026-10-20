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

    # true if $1 is the top of a git repo, not just a directory inside one
    is_repo() {
      top=$(git -C "$1" rev-parse --show-toplevel 2>/dev/null) &&
        [ "$top" = "$(cd "$1" && pwd -P)" ]
    }

    # push the branch `add` set up to the repo's clanker remote
    push_one() {
      spec=$(git -C "$1" config --get remote.clanker.push) || return 1
      b=''${spec#+refs/heads/}
      b=''${b%%:*}
      echo "clankerctl: pushing $(basename "$1") ($b)" >&2
      if [ -d "$1/.jj" ]; then
        jj -R "$1" git push --remote clanker --bookmark "$b"
      else
        git -C "$1" push clanker
      fi
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
        shift
        into=
        if [ "''${1:-}" = --into ]; then
          into=''${2:-}
          case "$into" in
            "" | . | .. | */*)
              echo "clankerctl: --into needs a plain directory name" >&2
              exit 2
              ;;
          esac
          shift 2
        fi
        repo=''${1:-.}
        if ! src=$(git -C "$repo" rev-parse --show-toplevel 2>/dev/null); then
          if [ -d "$repo/.jj" ]; then
            echo "clankerctl: jj repo without a .git; make it colocated first" >&2
          else
            echo "clankerctl: $repo is not a git repository" >&2
          fi
          exit 1
        fi
        case "$src" in
          "$HOME/agent" | "$HOME/agent"/*)
            echo "clankerctl: $src is already inside ~/agent" >&2
            exit 1
            ;;
        esac
        name=$(basename "$src")
        # jj keeps git's HEAD detached, so fall back to main, then master
        if [ -n "''${2:-}" ]; then
          branch=$2
        elif ! branch=$(git -C "$src" symbolic-ref --short -q HEAD); then
          branch=
          for b in main master; do
            if git -C "$src" rev-parse -q --verify "refs/heads/$b" >/dev/null; then
              branch=$b
              break
            fi
          done
          if [ -z "$branch" ]; then
            echo "clankerctl: HEAD is detached (jj repo?) and there is no main or master; name a branch/bookmark:" >&2
            echo "  clankerctl add ''${into:+--into $into }$src <branch>" >&2
            echo "available: $(git -C "$src" for-each-ref --format='%(refname:short)' refs/heads | tr '\n' ' ')" >&2
            exit 1
          fi
        fi
        if ! git -C "$src" rev-parse -q --verify "refs/heads/$branch" >/dev/null; then
          echo "clankerctl: no branch/bookmark '$branch' in $src" >&2
          exit 1
        fi
        dest="$HOME/agent/''${into:+$into/}$name"
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

        if [ -d "$src/.jj" ]; then
          # jj won't push over a remote bookmark it doesn't track
          if command -v jj >/dev/null; then
            jj -R "$src" bookmark track "$branch@clanker" >/dev/null 2>&1 \
              || echo "clankerctl: could not track $branch@clanker in jj" >&2
          else
            echo "clankerctl: jj not found; run: jj bookmark track $branch@clanker" >&2
          fi
          update="jj git push --remote clanker --bookmark $branch"
        else
          update="git push clanker"
        fi
        echo "clankerctl: $name is at $dest; update it with: $update" >&2
        ;;
      add-project)
        # `add` every repo directly under a project dir, into ~/agent/<project>/
        if ! root=$(cd "''${2:-.}" 2>/dev/null && pwd -P); then
          echo "clankerctl: ''${2:-.} is not a directory" >&2
          exit 1
        fi
        project=$(basename "$root")
        "$0" up || exit 1
        added="" skipped="" failed=""
        for c in "$root"/*/; do
          c=''${c%/}
          name=$(basename "$c")
          if ! is_repo "$c"; then
            if [ -d "$c/.jj" ]; then
              echo "clankerctl: $name: jj repo without a .git; make it colocated first" >&2
              failed="$failed $name"
            fi
            continue
          fi
          if [ "$(git -C "$c" remote get-url clanker 2>/dev/null)" = "${sshHost}:$HOME/agent/$project/$name" ]; then
            skipped="$skipped $name"
            continue
          fi
          if "$0" add --into "$project" "$c"; then
            added="$added $name"
          else
            failed="$failed $name"
          fi
        done
        echo "clankerctl: project at $HOME/agent/$project" >&2
        [ -n "$added" ] && echo "  added:$added" >&2
        [ -n "$skipped" ] && echo "  already added:$skipped" >&2
        [ -n "$failed" ] && echo "  failed:$failed" >&2
        [ -z "$failed" ]
        ;;
      push)
        # push every repo under a project dir that has a clanker remote
        root=''${2:-.}
        "$0" up || exit 1
        failed=""
        for c in "$root"/*/; do
          c=''${c%/}
          is_repo "$c" && git -C "$c" remote get-url clanker >/dev/null 2>&1 || continue
          push_one "$c" || failed="$failed $(basename "$c")"
        done
        if [ -n "$failed" ]; then
          echo "clankerctl: push failed:$failed" >&2
          exit 1
        fi
        ;;
      *)
        echo "usage: clankerctl up|down|status|logs" >&2
        echo "       clankerctl add [--into project] [repo [branch]]" >&2
        echo "       clankerctl add-project [dir] | push [dir]" >&2
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
