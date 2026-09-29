# kuhl-shell

A matching set of bash upgrades built around one look: box-drawing frames (`╭─ │ ╰─`), rules that stretch to the terminal edge, and the **atlas** palette.

- **Prompt:** a two-line [starship](https://starship.rs) prompt with a compact version for narrow terminals.
- **`dir`:** a folder listing in the same frame.
- **`update`:** a full apt update with a live spinner for each step.
- **Welcome screen:** shown when you log in.

```
╭─(good morning, sam)─( workstation)──────────────────────( Tue Sep 29 · 10:13)
│  os     Ubuntu 26.04.1 LTS · kernel 7.0.0-34-generic · up 22h 26m
│  cpu    Intel i5-2500K · 4 cores · load 0.18 0.37 0.38
│  mem    ━━━━━━━───────────────────────   26%  4.1G / 15.1G
│  disk   ━━━━━━━━━━━━━━━━━━━━━─────────   71%  167.1G / 232.7G
│  net    eth0 192.168.1.20 · ssh from 192.168.1.5
│  apt    13 updates ready · run update
╰─(dir · dir -h · update · dt)─────────────────────────────────────────────────
```

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/g-kuhl/kuhl-shell/main/install.sh | bash
```

Or from a clone:

```bash
git clone https://github.com/g-kuhl/kuhl-shell && cd kuhl-shell && ./install.sh
```

The installer does five things:

- It copies everything to `~/.local/share/kuhl-shell`.
- It adds one marked block to the end of `~/.bashrc`, after saving a backup of the file.
- It offers to install missing packages: `gawk` and `jq` through apt, and `starship` into `~/.local/bin`. Pass `--yes` to accept all of them without being asked.
- It creates `~/.hushlogin`, so the welcome screen replaces Ubuntu's login banner.
- It leaves your own `~/.config/starship.toml` alone, because kuhl-shell points `STARSHIP_CONFIG` at its own copy.

**To update:** run the installer again.

**To remove:** run `~/.local/share/kuhl-shell/uninstall.sh`.

**Requirements:**
- bash 4.4 or newer and GNU coreutils
- a terminal font from [Nerd Fonts](https://www.nerdfonts.com), for the icons
- `update` works only on Debian and Ubuntu. Everything else works on any Linux system.

## What you get

### Prompt
- **Top line:** the path with its middle collapsed (`~/projects/…/app/src`), then the git branch and status, the project version, and on the far right the exit status, command duration and time.
- **Task line:** in a project with a `deno.json`, a numbered line of its tasks appears under the header. Run one with `dt 2`, or by name with `dt build`.
- **Narrow terminals:** below 72 columns, the prompt switches to a compact layout.

### `dir [-h] [path]`
- Clears the screen and lists the folder with directories first.
- Colors files and adds icons by type.
- Shows permissions (`r`, `w` and `x` each in their own color), sizes and dates.
- The header shows the path and git branch. The footer shows totals.
- At 130 columns or wider, folders and files sit side by side in two panes.
- `-h` (or `-a`) includes hidden files.

### `update`
- Runs `apt update`, `upgrade`, `autoremove --purge`, `autoclean` and `snap refresh`. You enter your `sudo` password once at the start.
- Shows what will be upgraded (`old → new`) and a short summary after each step.
- Ends by saying whether a reboot is needed.
- Answers apt's questions automatically and keeps your current config files, so it never hangs on a hidden question.
- Saves the full output to `~/.local/state/sys-update/last.log`.

### Welcome screen
- Shows the OS, kernel and uptime, CPU and load, memory and disk meters, network addresses and SSH source, pending updates and whether a reboot is needed.
- Appears on login shells, such as SSH or a console. Run `welcome` to see it again.
- To turn it off, put `export KUHL_NO_WELCOME=1` in `~/.bashrc` above the kuhl-shell block.

## Customizing

- **Colors:** the palette is set in `lib/palette.sh` and in the `[palettes.atlas]` tables in `prompt/*.toml`. Change them together.
- **Local edits:** edits under `~/.local/share/kuhl-shell` are replaced when you reinstall. For lasting changes, edit a clone and run `./install.sh` from it.

## Layout

```
init.sh          sourced from ~/.bashrc: prompt setup, dir, dt, update, welcome
bin/welcome      login screen
bin/sys-update   the update screen
lib/palette.sh   atlas colors
lib/ui.sh        frame helpers (top/row/bottom, meters) for the bin/ scripts
lib/dir.sh       the dir function
prompt/          starship configs and the helper scripts they call
```
