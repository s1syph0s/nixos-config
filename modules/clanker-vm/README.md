# agent-vm

A Home Manager module that runs a coding agent (Claude Code, via ACP) inside a
microVM, so it can work on code without access to the rest of the host.

- `default.nix` — the Home Manager side: options, the `clankerctl` and
  `agent-vm-acp` scripts, and the `clanker-vm` ssh alias.
- `guest.nix` — the NixOS config of the VM itself.

## How it fits together

- The VM runs under QEMU as your user (no root, no daemon, no systemd unit),
  with user-mode networking.
- The only host directory it can see is `~/agent`, shared over 9p at the same
  absolute path on both sides.
- You reach it with `ssh clanker-vm` (host `127.0.0.1:6769` → guest `:22`).
  Inside, the user is `clanker`: same uid as you, no sudo.
- The VM's home, its writable Nix store and its sshd host key live on disk
  images in `~/.local/state/agent-vm`, so they survive restarts.
- `agent-vm-acp` is what agent-shell (Emacs) launches: it starts the VM if
  needed and runs `claude-agent-acp` in it over ssh. It refuses to run outside
  `~/agent`.

## Setup

1. Make a key for the VM:

   ```sh
   ssh-keygen -t ed25519 -f ~/.ssh/clanker -C clanker
   ```

2. Enable the module and pass in the public key:

   ```nix
   imports = [ ../../modules/agent-vm ];

   internal.clankerVm = {
     enable = true;
     publicKey = "ssh-ed25519 AAAA... clanker";
     # optional: written to /etc/gitconfig in the VM
     git = {
       userName = "Your Name";
       userEmail = "you@example.com";
     };
   };
   ```

   The flake needs a `microvm` input (`github:microvm-nix/microvm.nix`).

3. Rebuild, start the VM and log Claude in once:

   ```sh
   clankerctl up
   ssh clanker-vm
   claude          # log in, then exit
   ```

4. Point agent-shell at `agent-vm-acp` as the agent command.

## clankerctl

| Command | What it does |
|---|---|
| `clankerctl up` | start the VM and wait until ssh answers (no-op if running) |
| `clankerctl down` | shut it down |
| `clankerctl status` | print `up` / `down` |
| `clankerctl logs` | follow the VM's console log |
| `clankerctl add [repo [branch]]` | copy a host repo into `~/agent` (see below) |

## Moving code in and out

The VM cannot reach your host repos, and the agent can write anything under
`~/agent`. So code only moves in two ways, and git on the host never runs
inside `~/agent`.

**Host → VM.** In the repo on the host (default: the current directory):

```sh
clankerctl add            # once per repo
git push clanker          # every time after that
```

`add` creates `~/agent/<name>` inside the VM over ssh, sets
`receive.denyCurrentBranch=updateInstead` there, adds a `clanker` remote
(`clanker-vm:/home/<you>/agent/<name>`; it must be absolute, since a relative
path would resolve against the VM user's home) to the host repo with a push refspec for the
current branch, and pushes it. Each later `git push clanker` force-updates that
branch and its files in the VM. If the agent has uncommitted changes there, the
push is refused and nothing changes.

For a (colocated) jj repo, name the bookmark, since jj keeps git's `HEAD`
detached:

```sh
clankerctl add ~/.doom.d main
jj git push --remote clanker --bookmark main   # every time after that
```

`add` also runs `jj bookmark track main@clanker`, without which jj refuses to
push to the bookmark it didn't create. jj ignores the git push refspec, hence
the explicit `--bookmark`.

**VM → host.** Let the agent commit to its own branch, then on the host:

```sh
jj git fetch --remote clanker          # or: git fetch clanker
jj log -r 'master..<branch>@clanker'   # review before merging
```

The fetch runs `git upload-pack` inside the VM, so anything the agent put in
that repo's `.git` (hooks, config) only runs there.

## Security notes

- **Don't run git (or Magit, Majutsu, vc-mode, diff-hl) on the host inside
  `~/agent`.** The agent controls `.git/hooks` and `.git/config`; for example,
  `core.fsmonitor` runs a command on a plain `git status`. In Emacs:

  ```elisp
  (setq vc-ignore-dir-regexp
        (format "%s\\|%s" vc-ignore-dir-regexp "\\`/home/<you>/agent/"))
  ```

- **Review before you build.** A merged `flake.nix`, `.envrc`, `justfile` or
  `Makefile` runs with your rights on the host, and a NixOS config as root.
- **Don't `git clone` a host repo straight into `~/agent`.** A local clone
  hard-links `.git/objects`, so the agent could change files of the source
  repo. Use `clankerctl add`, or `git clone --no-hardlinks`.
- **Outbound network is open**, so anything in `~/agent` and the Claude login in
  the VM can leave the machine. Keep secrets out of `~/agent`.
- **The VM can reach the host's localhost** at `10.0.2.2`, which QEMU user
  networking maps to host `127.0.0.1`. Services that listen only on localhost
  are therefore reachable from the VM.
