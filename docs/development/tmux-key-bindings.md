# tmux Keybindings Reference

This document lists the current tmux keybindings configured for this environment.

**Prefix key:** `Ctrl+a` (custom, changed from default `Ctrl+b`)

## Session Management

| Key | Action                     |
| --- | -------------------------- |
| `d` | Detach from session        |
| `s` | Choose session tree        |
| `$` | Rename session             |
| `(` | Switch to previous session |
| `)` | Switch to next session     |
| `L` | Switch to last session     |
| `D` | Choose client              |

## Window Management

| Key         | Action                     |
| ----------- | -------------------------- |
| `c`         | Create new window          |
| `,`         | Rename window              |
| `&`         | Kill window (with confirm) |
| `n` / `C-n` | Next window                |
| `p` / `C-p` | Previous window            |
| `0-9`       | Select window by number    |
| `a`         | Last window                |
| `w`         | Choose window tree         |
| `f`         | Find window                |
| `'`         | Select window by index     |
| `.`         | Move window to target      |

## Pane Management

| Key  | Action                   |
| ---- | ------------------------ |
| `\|` |                          |
| `-`  | Split vertically         |
| `x`  | Kill pane (with confirm) |
| `o`  | Select next pane         |
| `;`  | Last pane                |
| `{`  | Swap pane up             |
| `}`  | Swap pane down           |
| `z`  | Toggle pane zoom         |
| `!`  | Break pane to window     |
| `q`  | Display pane numbers     |
| `M`  | Mark pane                |

## Pane Navigation (vim-style)

| Key          | Action                   |
| ------------ | ------------------------ |
| `h`          | Select pane left         |
| `j`          | Select pane down         |
| `k`          | Select pane up           |
| `l`          | Select pane right        |
| `Arrow keys` | Select pane (repeatable) |

## Pane Resizing

| Key       | Action           |
| --------- | ---------------- |
| `C-Arrow` | Resize pane by 1 |
| `M-Arrow` | Resize pane by 5 |

## Layouts

| Key     | Action              |
| ------- | ------------------- |
| `Space` | Next layout         |
| `E`     | Spread panes evenly |
| `M-1`   | Even horizontal     |
| `M-2`   | Even vertical       |
| `M-3`   | Main horizontal     |
| `M-4`   | Main vertical       |
| `M-5`   | Tiled               |

## Copy Mode

| Key    | Action              |
| ------ | ------------------- |
| `[`    | Enter copy mode     |
| `]`    | Paste buffer        |
| `#`    | List buffers        |
| `=`    | Choose buffer       |
| `PgUp` | Copy mode + page up |

### Copy Mode Vi Keys

| Key           | Action                |
| ------------- | --------------------- |
| `v`           | Begin selection       |
| `y` / `Enter` | Copy selection        |
| `Escape`      | Clear selection       |
| `q`           | Cancel copy mode      |
| `/`           | Search forward        |
| `?`           | Search backward       |
| `n`           | Next search match     |
| `N`           | Previous search match |
| `h/j/k/l`     | Cursor movement       |
| `w/b/e`       | Word movement         |
| `0/$`         | Start/end of line     |
| `g/G`         | Top/bottom of history |
| `C-u/C-d`     | Half page up/down     |
| `C-b/C-f`     | Full page up/down     |

## Plugin Bindings (TPM, Resurrect)

| Key   | Action                       |
| ----- | ---------------------------- |
| `r`   | Reload tmux.conf             |
| `R`   | Reload tmux.conf (alternate) |
| `m`   | Toggle mouse on/off          |
| `I`   | Install plugins (TPM)        |
| `U`   | Update plugins (TPM)         |
| `M-u` | Clean plugins (TPM)          |
| `C-s` | Save session (Resurrect)     |
| `C-r` | Restore session (Resurrect)  |

## Miscellaneous

| Key   | Action                     |
| ----- | -------------------------- |
| `:`   | Command prompt             |
| `?`   | List keys                  |
| `t`   | Show clock                 |
| `i`   | Display message            |
| `~`   | Show messages              |
| `C`   | Customize mode             |
| `C-o` | Rotate window              |
| `C-z` | Suspend client             |
| `C-a` | Send prefix to nested tmux |

## Mouse Bindings

| Action       | Behavior                 |
| ------------ | ------------------------ |
| Click pane   | Select pane              |
| Click status | Switch window            |
| Drag pane    | Enter copy mode + select |
| Drag border  | Resize pane              |
| Scroll wheel | Scroll / copy mode       |
| Double-click | Select word              |
| Triple-click | Select line              |
| Right-click  | Context menu             |

## Key Notation

- `C-` = Ctrl
- `M-` = Alt/Meta
- `S-` = Shift
