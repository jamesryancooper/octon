# Terminal Development Environment Guide

A comprehensive guide to the Harmony-themed terminal development environment built on Ghostty, Zsh, Tmux, and AstroNvim.

---

## Table of Contents

1. [Philosophy & Architecture](#philosophy--architecture)
2. [Ghostty Terminal](#ghostty-terminal)
3. [Zsh Shell](#zsh-shell)
4. [Tmux](#tmux)
5. [AstroNvim](#astronvim)
6. [AI Integration](#ai-integration)
7. [Common Workflows](#common-workflows)
8. [Quick Reference](#quick-reference)
9. [Troubleshooting](#troubleshooting)

---

## Philosophy & Architecture

### Responsibility Split

Each layer owns specific responsibilities with no overlap:

| Layer | Owns | Does NOT Own |
|-------|------|--------------|
| **Ghostty** | Terminal tabs, clipboard, scrollback, OS integration | Panes, splits |
| **Tmux** | Panes, splits, sessions, windows, persistence | Editor windows |
| **Neovim** | Buffers, editor splits, code editing, LSP | Terminal sessions |
| **Zsh** | Shell commands, aliases, completions, prompt | GUI elements |

### Design Principles

- **Harmony Dark theme** across all layers for visual consistency
- **Vim-style navigation** everywhere (`hjkl`)
- **Muscle memory friendly** — similar actions use similar keys
- **Non-conflicting keybindings** — each layer's keys pass through cleanly

---

## Ghostty Terminal

### Configuration

**Config location:** `~/.config/ghostty/config` or `~/Library/Application Support/com.mitchellh.ghostty/config`

**Theme location:** `~/.config/ghostty/themes/Harmony Dark`

### Features

- Harmony Dark color scheme
- Monospace Neon font at 18pt
- Transparent titlebar (macOS native)
- Shell integration with Zsh
- No terminal splits (tmux handles this)

### Keybindings

#### Tabs

| Key | Action |
|-----|--------|
| `Cmd+T` | New tab |
| `Cmd+W` | Close tab |
| `Cmd+Shift+]` | Next tab |
| `Cmd+Shift+[` | Previous tab |
| `Cmd+1-8` | Go to tab 1-8 |
| `Cmd+9` | Last tab |

#### Clipboard

| Key | Action |
|-----|--------|
| `Cmd+C` | Copy (only when text selected) |
| `Cmd+V` | Paste |

#### Scrollback & Navigation

| Key | Action |
|-----|--------|
| `Cmd+Shift+Up` | Scroll page up |
| `Cmd+Shift+Down` | Scroll page down |
| `Cmd+Up` | Jump to previous prompt |
| `Cmd+Down` | Jump to next prompt |
| `Cmd+K` | Clear screen |

#### Text Navigation (Shell)

| Key | Action |
|-----|--------|
| `Cmd+Left` | Beginning of line |
| `Cmd+Right` | End of line |
| `Alt+Left` | Back one word |
| `Alt+Right` | Forward one word |
| `Cmd+Backspace` | Delete to beginning |

#### Utilities

| Key | Action |
|-----|--------|
| `Cmd+,` | Open config |
| `Cmd+Shift+,` | Reload config |
| `Cmd+Alt+I` | Toggle inspector |
| `Cmd+Shift+P` | Command palette |

---

## Zsh Shell

### Configuration

**Config location:** `~/.zshrc`

**Prompt config:** `~/.zsh/prompt.zsh`

**Plugin manager:** Zinit

### Plugins Installed

#### Core Plugins

| Plugin | Description |
|--------|-------------|
| `zsh-autosuggestions` | Ghost text suggestions from history |
| `zsh-syntax-highlighting` | Real-time command coloring |
| `zsh-completions` | Additional completion definitions |
| `zsh-history-substring-search` | Search history with arrow keys |
| `fzf-tab` | Fuzzy completion menu |
| `forgit` | Interactive git with fzf |

#### Oh My Zsh Snippets (via Zinit)

| Plugin | Description |
|--------|-------------|
| `git` | Git aliases (`gst`, `gco`, `gp`, etc.) |
| `sudo` | Press `Esc` twice to prepend sudo |
| `extract` | Extract any archive with `extract` |
| `copypath` | Copy current path to clipboard |
| `copyfile` | Copy file contents to clipboard |
| `colored-man-pages` | Colorized man pages |
| `command-not-found` | Suggests packages for missing commands |
| `docker` | Docker completions |
| `brew` | Homebrew completions |
| `npm` | npm completions |

### CLI Tools

| Tool | Replaces | Usage |
|------|----------|-------|
| `eza` | `ls` | `ls`, `ll`, `la`, `lt` |
| `bat` | `cat` | `cat file` (aliased) |
| `fd` | `find` | `fd pattern` |
| `rg` (ripgrep) | `grep` | `rg pattern` |
| `zoxide` | `cd` | `z directory` |
| `fzf` | — | Fuzzy finder, `Ctrl+R` for history |
| `atuin` | — | Searchable shell history |
| `delta` | `diff` | Better git diffs |
| `tldr` | `man` | `tldr command` |
| `jq` | — | JSON processor |
| `yq` | — | YAML processor |

### Aliases

#### Navigation

| Alias | Command |
|-------|---------|
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `....` | `cd ../../..` |

#### Files

| Alias | Command |
|-------|---------|
| `ls` | `eza --icons` |
| `ll` | `eza -la --icons --git` |
| `la` | `eza -a --icons` |
| `lt` | `eza -la --icons --git --tree --level=2` |
| `cat` | `bat --paging=never` |

#### Git

| Alias | Command |
|-------|---------|
| `g` | `git` |
| `lg` | `lazygit` |
| `rgv` | `rg --vimgrep` |

#### Tmux

| Alias | Command |
|-------|---------|
| `tdev` | `tmux new -As dev` |
| `tclaude` | `tmux new -As claude` |
| `ta <name>` | `tmux attach -t <name>` |
| `tl` | `tmux list-sessions` |
| `tk <name>` | `tmux kill-session -t <name>` |
| `tn <name>` | `tmux new -s <name>` |

#### Safety

| Alias | Command |
|-------|---------|
| `rm` | `rm -i` |
| `mv` | `mv -i` |
| `cp` | `cp -i` |

### Functions

#### Yazi File Manager

```bash
y    # Open yazi, cd to directory on exit
```

#### AI Functions (see AI Integration section)

```bash
ask "question"     # Quick AI question
how "task"         # Get a command suggestion
wtf                # Explain last command
ai-review file     # Review code
ai-commit          # Suggest commit message
ai-err             # Explain piped errors
```

### Custom Prompt

The prompt displays:
- Current directory (blue, last 3 segments)
- Git branch (magenta)
- Prompt character: `❯` (yellow, red on error)
- Time (right side, gray)
- Exit code (right side, red, only if non-zero)

**Customization:** Edit `~/.zsh/prompt.zsh`

---

## Tmux

### Configuration

**Config location:** `~/.tmux.conf`

**Plugin manager:** TPM (Tmux Plugin Manager)

### Prefix Key

**Prefix:** `Ctrl+a` (not the default `Ctrl+b`)

All tmux commands start with the prefix unless noted otherwise.

### Plugins

| Plugin | Description |
|--------|-------------|
| `tmux-sensible` | Sensible defaults |
| `tmux-resurrect` | Save/restore sessions |
| `tmux-continuum` | Auto-save sessions |
| `tmux-yank` | Better copy/paste |
| `tmux-fzf` | Fuzzy session finder |

### Keybindings

#### Panes

| Key | Action |
|-----|--------|
| `C-a \|` or `C-a v` | Split vertical |
| `C-a -` or `C-a s` | Split horizontal |
| `Ctrl+h/j/k/l` | Navigate panes (no prefix!) |
| `C-a h/j/k/l` | Navigate panes (with prefix) |
| `C-a H/J/K/L` | Resize panes |
| `C-a z` | Zoom pane (fullscreen toggle) |
| `C-a x` | Kill pane |
| `C-a >` | Swap pane down |
| `C-a <` | Swap pane up |

#### Windows

| Key | Action |
|-----|--------|
| `C-a c` | New window |
| `C-a n` | Next window |
| `C-a p` | Previous window |
| `C-a 1-9` | Go to window 1-9 |
| `C-a C-a` | Last window (double tap) |
| `C-a X` | Kill window |
| `C-a ,` | Rename window |

#### Sessions

| Key | Action |
|-----|--------|
| `C-a S` | Choose session |
| `C-a W` | Choose window |
| `C-a f` | Fuzzy find sessions (fzf) |
| `C-a d` | Detach from session |
| `C-a $` | Rename session |

#### Copy Mode (Vi-style)

| Key | Action |
|-----|--------|
| `C-a Enter` | Enter copy mode |
| `v` | Start selection |
| `C-v` | Rectangle selection |
| `y` | Copy to clipboard |
| `Esc` | Exit copy mode |
| `/` | Search forward |
| `?` | Search backward |

#### Utility

| Key | Action |
|-----|--------|
| `C-a r` | Reload config |
| `C-a m` | Toggle mouse |
| `C-a b` | Toggle status bar |
| `C-a a` | Sync panes (type in all) |
| `C-a I` | Install plugins (TPM) |
| `C-a U` | Update plugins (TPM) |

### Smart Pane Navigation

`Ctrl+h/j/k/l` works seamlessly across tmux panes AND Neovim splits without needing the prefix. The config detects when Neovim is focused and passes the keys through.

### Session Persistence

Sessions are automatically saved and restored:
- `tmux-resurrect` saves session state
- `tmux-continuum` auto-saves every 15 minutes
- Sessions restore automatically when tmux starts

### Theme

The status bar uses Harmony Dark colors:
- Blue accent for session name
- Yellow for current window
- Purple for date
- Gray borders

---

## AstroNvim

### Configuration

**Config location:** `~/.config/nvim/`

**Plugin configs:** `~/.config/nvim/lua/plugins/`

**Colorscheme:** `~/.config/nvim/colors/harmony-dark.lua`

### Leader Key

**Leader:** `Space`

Press `Space` and wait to see all available commands via which-key.

### Essential Keybindings

#### Modes

| Key | Action |
|-----|--------|
| `i` | Insert mode |
| `v` | Visual mode |
| `V` | Visual line mode |
| `Ctrl+v` | Visual block mode |
| `Esc` | Normal mode |
| `:` | Command mode |

#### Movement

| Key | Action |
|-----|--------|
| `h/j/k/l` | Left/down/up/right |
| `w` / `b` | Word forward/back |
| `e` | End of word |
| `0` / `$` | Start/end of line |
| `^` | First non-blank |
| `gg` / `G` | Top/bottom of file |
| `{` / `}` | Paragraph up/down |
| `Ctrl+d/u` | Half page down/up |
| `%` | Matching bracket |

#### Editing

| Key | Action |
|-----|--------|
| `dd` | Delete line |
| `yy` | Yank (copy) line |
| `p` / `P` | Paste after/before |
| `u` | Undo |
| `Ctrl+r` | Redo |
| `ciw` | Change inner word |
| `ci"` | Change inside quotes |
| `cit` | Change inside tag |
| `>>` / `<<` | Indent/unindent |
| `.` | Repeat last action |
| `J` | Join lines |

#### Search

| Key | Action |
|-----|--------|
| `/` | Search forward |
| `?` | Search backward |
| `n` / `N` | Next/previous result |
| `*` / `#` | Search word under cursor |

### File Navigation

| Key | Action |
|-----|--------|
| `<Leader>e` | Toggle file explorer |
| `<Leader>o` | Focus file explorer |
| `<Leader>ff` | Find files |
| `<Leader>fw` | Find word (grep) |
| `<Leader>fb` | Find buffers |
| `<Leader>fr` | Recent files |
| `<Leader>ft` | Find TODOs |

### Buffers & Windows

| Key | Action |
|-----|--------|
| `<Leader>c` | Close buffer |
| `<Leader>C` | Force close buffer |
| `]b` / `[b` | Next/previous buffer |
| `<Leader>bb` | Buffer picker |
| `Ctrl+h/j/k/l` | Navigate windows |
| `<Leader>sv` | Split vertical |
| `<Leader>sh` | Split horizontal |

### Code (LSP)

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `<Leader>la` | Code actions |
| `<Leader>lr` | Rename symbol |
| `<Leader>lf` | Format file |
| `<Leader>ld` | Line diagnostics |
| `<Leader>lD` | Document diagnostics |
| `]d` / `[d` | Next/previous diagnostic |

### Git

| Key | Action |
|-----|--------|
| `<Leader>gg` | LazyGit |
| `<Leader>gd` | Diff view |
| `<Leader>gh` | File history |
| `<Leader>gH` | Branch history |
| `<Leader>gB` | Toggle inline blame |
| `<Leader>gy` | Copy git permalink |
| `<Leader>gY` | Open git permalink |
| `<Leader>gn` | Neogit |
| `]g` / `[g` | Next/previous hunk |
| `<Leader>gl` | Blame line |

#### Git Conflict Resolution

When in a file with conflicts:

| Key | Action |
|-----|--------|
| `co` | Choose ours |
| `ct` | Choose theirs |
| `cb` | Choose both |
| `c0` | Choose none |
| `]x` / `[x` | Next/previous conflict |

### Navigation Plugins

#### Flash (Quick Jump)

| Key | Action |
|-----|--------|
| `s` | Flash jump (type chars to jump) |
| `S` | Flash treesitter (select node) |

#### Harpoon (Quick Files)

| Key | Action |
|-----|--------|
| `<Leader>ha` | Add file to harpoon |
| `<Leader>hh` | Harpoon menu |
| `<Leader>1-4` | Jump to harpooned file 1-4 |

### Diagnostics & Todos

| Key | Action |
|-----|--------|
| `<Leader>xx` | Toggle diagnostics (Trouble) |
| `<Leader>xX` | Buffer diagnostics |
| `<Leader>xs` | Symbols outline |
| `<Leader>xq` | Quickfix list |
| `<Leader>xt` | All TODOs |
| `]t` / `[t` | Next/previous TODO |

### Editing Helpers

#### Surround

| Key | Action |
|-----|--------|
| `ysiw"` | Surround word with `"` |
| `ysiw)` | Surround word with `()` |
| `cs"'` | Change `"` to `'` |
| `ds"` | Delete surrounding `"` |

#### Search & Replace

| Key | Action |
|-----|--------|
| `<Leader>sr` | Search & replace (Spectre) |
| `<Leader>sw` | Search word under cursor |

### Utilities

| Key | Action |
|-----|--------|
| `<Leader>uu` | Undo tree |
| `<Leader>zz` | Zen mode |
| `<Leader>zt` | Twilight (dim inactive) |
| `<Leader>mp` | Markdown preview |
| `<Leader>qs` | Restore session |
| `<Leader>ql` | Restore last session |

### Folding

| Key | Action |
|-----|--------|
| `za` | Toggle fold |
| `zR` | Open all folds |
| `zM` | Close all folds |
| `zK` | Peek fold |

### Commands

| Command | Action |
|---------|--------|
| `:w` | Save |
| `:q` | Quit |
| `:wq` or `ZZ` | Save and quit |
| `:q!` | Quit without saving |
| `:qa` | Quit all |
| `:Lazy` | Plugin manager |
| `:Mason` | LSP/tool installer |
| `:LspInfo` | LSP status |
| `:Copilot auth` | Authenticate Copilot |

### Installed Plugins

#### Core (AstroNvim)

- neo-tree.nvim (file explorer)
- telescope.nvim (fuzzy finder)
- which-key.nvim (keybind hints)
- gitsigns.nvim (git signs)
- heirline.nvim (statusline)
- treesitter (syntax highlighting)
- nvim-lspconfig (LSP)
- conform.nvim (formatting)
- nvim-cmp (completion)

#### Git

- diffview.nvim
- lazygit.nvim
- git-conflict.nvim
- gitlinker.nvim
- git-blame.nvim
- neogit

#### Editing

- nvim-surround
- nvim-autopairs
- nvim-spectre
- undotree
- nvim-ufo (folding)
- todo-comments.nvim
- flash.nvim
- harpoon

#### Visual

- nvim-colorizer.lua
- nvim-hlslens
- zen-mode.nvim
- twilight.nvim
- render-markdown.nvim

#### Languages

- TypeScript/JavaScript (tsserver, prettier, eslint)
- Python (pyright, ruff, debugpy)
- JSON (jsonls, schemastore)
- YAML (yamlls, yamllint)
- Markdown (markdownlint, preview)
- SQL (sqlls, sql-formatter)
- Lua (lua_ls, stylua)

---

## AI Integration

### Copilot (Inline Suggestions)

GitHub Copilot provides inline code suggestions as you type.

**First-time setup:**
```vim
:Copilot auth
```

| Key | Action |
|-----|--------|
| `Ctrl+y` | Accept suggestion |
| `Ctrl+w` | Accept word |
| `Ctrl+l` | Accept line |
| `Ctrl+]` | Next suggestion |
| `Ctrl+[` | Previous suggestion |
| `Ctrl+e` | Dismiss |
| `Ctrl+Enter` | Open panel |

### Claude Code (Terminal Agent)

Claude Code runs in a dedicated terminal split.

| Key | Action |
|-----|--------|
| `<Leader>ac` | Toggle Claude Code terminal |

**Features:**
- Full agentic coding assistant
- Can read/write files
- Can run terminal commands
- Understands your codebase

### Codex CLI (Terminal Agent)

OpenAI Codex runs in a dedicated terminal split.

| Key | Action |
|-----|--------|
| `<Leader>ax` | Toggle Codex CLI terminal |

**Features:**
- Cloud-based software engineering agent
- Parallel task execution
- Pull request generation
- MCP support

### Zsh AI Functions

These use the `llm` CLI tool with your configured model.

| Command | Description |
|---------|-------------|
| `ask "question"` | Quick AI question |
| `how "task"` | Get a command (copies to clipboard) |
| `wtf` | Explain the last command |
| `ai-err` | Pipe errors to explain (`cmd 2>&1 \| ai-err`) |
| `ai-review file` | Review code in a file |
| `ai-commit` | Suggest commit message for staged changes |

**Examples:**
```bash
ask "what is a tarball?"
how "find files larger than 100MB"
git diff --cached | ai-commit
python script.py 2>&1 | ai-err
```

### LLM Configuration

The `llm` CLI is configured with Claude as the default model.

```bash
llm keys set anthropic  # Set API key
llm models default claude-sonnet-4-20250514  # Set default model
```

---

## Common Workflows

### Starting a Development Session

```bash
# Start or attach to dev session
tdev

# Or create a named session
tn myproject
```

### Typical Tmux Layout

```
┌─────────────────────────────────────────┐
│ Window 1: Editor (nvim)                 │
├───────────────────────┬─────────────────┤
│                       │ Terminal/tests  │
│      Neovim           ├─────────────────┤
│                       │ Claude Code     │
└───────────────────────┴─────────────────┘
```

**Setup:**
1. `C-a c` — new window for editor
2. `nvim .` — open editor
3. `C-a |` — split vertical for terminal
4. `C-a -` — split horizontal for AI

### Working with Files

1. `<Leader>ff` — find file
2. `<Leader>e` — toggle file explorer
3. `<Leader>ha` — add to harpoon
4. `<Leader>1-4` — quick switch

### Code Editing Flow

1. `gd` — go to definition
2. Make changes
3. `<Leader>la` — code actions (imports, fixes)
4. `<Leader>lf` — format
5. `<Leader>c` — close buffer

### Git Workflow

1. `<Leader>gg` — open lazygit
2. Stage changes, write commit message
3. Or use: `ai-commit` for AI-suggested message
4. Push from lazygit

### Debugging Errors

```bash
# In terminal
python script.py 2>&1 | ai-err

# Or in Neovim
# 1. Check diagnostics: <Leader>xx
# 2. Jump to error: ]d
# 3. See details: <Leader>ld
# 4. Code actions: <Leader>la
```

### Using AI Agents

**For quick questions:**
```bash
ask "how do I reverse a list in python"
```

**For shell commands:**
```bash
how "find all .py files modified in last 24 hours"
# Command is printed and copied to clipboard
```

**For complex tasks:**
- `<Leader>ac` — open Claude Code
- Describe the task
- Claude Code can edit files and run commands

---

## Quick Reference

### Layer Responsibilities

```
Ghostty  →  Tabs, clipboard, scrollback
Tmux     →  Panes, sessions, persistence
Neovim   →  Code editing, LSP, buffers
Zsh      →  Shell, aliases, AI functions
```

### Navigation Keys (Universal)

```
h/j/k/l          →  Left/Down/Up/Right (everywhere)
Ctrl+h/j/k/l     →  Window/pane navigation
```

### Prefix Keys

```
Ghostty  →  Cmd (macOS)
Tmux     →  Ctrl+a
Neovim   →  Space (Leader)
```

### Most Used Commands

```
# Tmux
C-a |        Split vertical
C-a -        Split horizontal
C-a z        Zoom pane
C-a d        Detach

# Neovim
<Leader>ff   Find files
<Leader>fw   Find word
<Leader>e    File explorer
<Leader>gg   LazyGit
gd           Go to definition
<Leader>la   Code actions

# Zsh
ll           List files
z <dir>      Jump to directory
ask "?"      AI question
how "task"   Get command
```

---

## Troubleshooting

### Colors Look Wrong

Ensure true color support:
```bash
# Check terminal
echo $TERM  # Should be xterm-256color or similar

# Test colors
curl -s https://raw.githubusercontent.com/gnachman/iTerm2/master/tests/24-bit-color.sh | bash
```

### Tmux Keys Not Working

```bash
# Reload config
tmux source-file ~/.tmux.conf

# Or restart
tmux kill-server && tmux
```

### Neovim Plugins Not Loading

```vim
:Lazy sync
:Lazy update
```

### LSP Not Working

```vim
:LspInfo        " Check status
:Mason          " Install/update servers
:LspRestart     " Restart LSP
```

### Copilot Not Suggesting

```vim
:Copilot status
:Copilot auth
```

### Zsh Slow to Start

```bash
# Profile startup
time zsh -i -c exit

# If slow, check for issues
zsh -xv 2>&1 | head -100
```

### Reset Everything

```bash
# Neovim (nuclear option)
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
nvim  # Reinstalls everything

# Tmux plugins
rm -rf ~/.tmux/plugins
# Then C-a I to reinstall

# Zinit plugins
rm -rf ~/.local/share/zinit
exec zsh  # Reinstalls
```

---

## File Locations

| Component | Config Location |
|-----------|-----------------|
| Ghostty | `~/.config/ghostty/config` |
| Ghostty theme | `~/.config/ghostty/themes/Harmony Dark` |
| Zsh | `~/.zshrc` |
| Zsh prompt | `~/.zsh/prompt.zsh` |
| Tmux | `~/.tmux.conf` |
| Neovim | `~/.config/nvim/` |
| Neovim plugins | `~/.config/nvim/lua/plugins/` |
| Neovim theme | `~/.config/nvim/colors/harmony-dark.lua` |

---

## Version Information

- **Ghostty:** Latest
- **Neovim:** 0.11.5+
- **Tmux:** 3.x
- **Zsh:** 5.x
- **Node.js:** Via NVM
- **Python:** Via pyenv

---

*Last updated: January 2026*
