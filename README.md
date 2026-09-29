# kuhl-shell

A matching set of bash upgrades built around one look: box-drawing frames (`╭─ │ ╰─`), rules that stretch to the terminal edge, and the **atlas** palette.

- **Prompt:** a two-line [starship](https://starship.rs) prompt.
- **Everyday commands:** framed versions of `dir`, `tree`, `df`, `du`, `ip`, `free` and `ports`.
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
╰─(dir · tree · df · du · ip · free · ports · update)───────────────────────────
```

## Prerequisites

| Requirement | Why | Get it |
|---|---|---|
| **bash 4.4+** on Linux | everything | already on any current distro |
| **[Starship](https://starship.rs)** | the prompt | [install guide](https://starship.rs/guide/#%F0%9F%9A%80-installation), or let `install.sh` install it to `~/.local/bin` |
| **A [Nerd Font](https://www.nerdfonts.com)**, set as your terminal font | every icon | [download](https://www.nerdfonts.com/font-downloads). JetBrainsMono, FiraCode and Hack are good picks. Without one, icons show as boxes. |
| **[GNU awk](https://www.gnu.org/software/gawk/)** (`gawk`) | `dir`, `tree` | `sudo apt install gawk`. Debian's default `awk` is mawk, which can't do it. |
| **[jq](https://jqlang.org)** | `ip`, deno task line | `sudo apt install jq` |
| **iproute2**, coreutils, findutils | `ip`, `ports`, `df`, `du` | preinstalled on Debian and Ubuntu |
| **apt** (Debian or Ubuntu) | `update` only | everything else works on any Linux system |

The installer checks for these. On apt systems it offers to install `gawk` and `jq` for you, and it can install starship too. It can't pick a terminal font for you, so set that yourself.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/g-kuhl/kuhl-shell/main/install.sh | bash
```

Or from a clone:

```bash
git clone https://github.com/g-kuhl/kuhl-shell && cd kuhl-shell && ./install.sh
```

The installer does four things:

- It copies everything to `~/.local/share/kuhl-shell`.
- It adds one marked block to the end of `~/.bashrc`, after saving a backup of the file.
- It creates `~/.hushlogin`, so the welcome screen replaces Ubuntu's login banner.
- It leaves your own `~/.config/starship.toml` alone, because kuhl-shell points `STARSHIP_CONFIG` at its own copy.

Pass `--yes` to accept every question without being asked.

**To update:** run the installer again.

**To remove:** run `~/.local/share/kuhl-shell/uninstall.sh`.

## Commands

The framed versions only apply to the forms you type by hand, and only when the output goes to your terminal. Any other flags, pipes (`df -h | grep sda`) and redirects get the real command, so scripts keep working. To skip the framing, run `command df -h` or `\df -h`.

| You type | You get |
|---|---|
| `dir [-h] [path]` | A listing with folders first and file-type icons and colors. It shows permissions (`r`, `w` and `x` each in their own color), sizes, dates, the git branch and totals. At 130 columns or wider it uses two panes. `-h` includes hidden files. |
| `tree [-L n] [-a] [-d] [path]` | A tree with folders first and the same icons, 3 levels deep by default. Heavy folders such as `.git`, `node_modules` and caches are shown but not opened. |
| `df` / `df -h` | A usage meter for each real disk, fullest first. tmpfs, snap loop devices and overlay mounts are left out. |
| `du` / `du -sh [path]` | What's using space in a folder, biggest first, with bars. Totals are in the footer. |
| `ip` / `ip a` | Each interface with its state, addresses and MAC, then the default gateway and DNS servers. |
| `free` / `free -h` | RAM and swap meters, what's available versus cached, and the top memory users, with each program's processes counted together. |
| `ports [-u] [-s]` | What's listening, by port. It shows the program behind each port and whether the port is open to the network or to this machine only. `-u` adds UDP, and `-s` uses sudo so it can name every program. |
| `update` | Runs `apt update`, `upgrade`, `autoremove --purge`, `autoclean` and `snap refresh`, with a spinner for each step. See below. |
| `welcome` | The login screen again. |
| `dt [n\|name]` | Runs a deno task by its number in the prompt's task line. |

### `update`
- You enter your `sudo` password once at the start.
- It shows what will be upgraded (`old → new`) and a short summary after each step.
- It ends by saying whether a reboot is needed.
- It answers apt's questions automatically and keeps your current config files, so it never hangs on a hidden question.
- It saves the full output to `~/.local/state/sys-update/last.log`.

### Prompt
- **Top line:** the path with its middle collapsed (`~/projects/…/app/src`), then the git branch and status, the project version, and on the far right the exit status, command duration and time.
- **Task line:** in a project with a `deno.json`, a numbered line of its tasks appears under the header.
- **Narrow terminals:** below 72 columns, the prompt switches to a compact layout.

### Welcome screen
- Appears on login shells, such as SSH or a console.
- To turn it off, put `export KUHL_NO_WELCOME=1` in `~/.bashrc` above the kuhl-shell block.

## Customizing

- **Colors:** the palette is set in `lib/palette.sh` and in the `[palettes.atlas]` tables in `prompt/*.toml`. Change them together.
- **Tree size:** `tree` stops after 400 entries. Set `KUHL_TREE_LIMIT` to change that.
- **Local edits:** edits under `~/.local/share/kuhl-shell` are replaced when you reinstall. For lasting changes, edit a clone and run `./install.sh` from it.

## Layout

```
init.sh          sourced from ~/.bashrc: prompt setup and the command wrappers
bin/             kdf, kdu, kip, kfree, kports, ktree, sys-update, welcome
lib/palette.sh   atlas colors
lib/ui.sh        frame helpers (top/row/bottom, meters) for the bin/ scripts
lib/style.awk    icons, colors and permission styling shared by dir and tree
lib/dir.sh       the dir function
prompt/          starship configs and the helper scripts they call
```

## Credits

kuhl-shell is a thin layer over other people's excellent work:

- **[Starship](https://starship.rs)** ([github.com/starship/starship](https://github.com/starship/starship), ISC license) draws the whole prompt. kuhl-shell only provides the config and a few helper scripts.
- **[Nerd Fonts](https://www.nerdfonts.com)** by Ryan L McIntyre and contributors ([github.com/ryanoasis/nerd-fonts](https://github.com/ryanoasis/nerd-fonts), MIT and SIL OFL) provides every icon. The icons themselves come from the projects Nerd Fonts bundles, including [Font Awesome](https://fontawesome.com), [GitHub Octicons](https://github.com/primer/octicons), [Seti UI](https://github.com/jesseweed/seti-ui), [Devicons](https://vorillaz.github.io/devicons/) and [Font Logos](https://github.com/lukas-w/font-logos).
- **Palette:** the atlas palette builds on starship's [Tokyo Night preset](https://starship.rs/presets/tokyo-night) and folke's [Tokyo Night](https://github.com/folke/tokyonight.nvim) color scheme.
- **Tools:** [GNU awk](https://www.gnu.org/software/gawk/), [jq](https://jqlang.org), and [iproute2](https://wiki.linuxfoundation.org/networking/iproute2) (`ip`, `ss`) do the heavy lifting behind `dir`, `tree`, `ip` and `ports`.

## License

[MIT](LICENSE). The third-party projects above keep their own licenses. kuhl-shell doesn't bundle any of their code or fonts.
