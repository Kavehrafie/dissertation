## Basic Navigation
| Command | Action |
|---------|--------|
| `h/j/k/l` | Left/down/up/right |
| `w/b` | Next/previous word |
| `0/$` | Start/end of line |
| `gg/G` | Top/bottom of document |
| `^` | First non-blank character |
| `{/}` | Previous/next paragraph |
| `zz` | Center cursor on screen |

## Editing
| Command | Action |
|---------|--------|
| `i/a` | Insert before/after cursor |
| `I/A` | Insert at line start/end |
| `o/O` | New line below/above |
| `dd/yy` | Delete/copy line |
| `p/P` | Paste after/before cursor |
| `u/Ctrl+r` | Undo/redo |
| `>>/<<` | Indent/unindent |
| `.` | Repeat last command |

## Text Objects
| Command | Action |
|---------|--------|
| `ciw/diw` | Change/delete word |
| `ci"/di"` | Change/delete in quotes |
| `ci)/di)` | Change/delete in parentheses |
| `cip/dip` | Change/delete paragraph |
| `ci}/di}` | Change/delete in braces |

## Search and Replace
| Command | Action |
|---------|--------|
| `/word` | Search forward |
| `?word` | Search backward |
| `n/N` | Next/previous match |
| `*/#` | Search word under cursor forward/backward |
| `:noh` | Clear search highlighting |
| `/\cword` | Case-insensitive search |
| `/\<word\>` | Whole word search |
| `:%s/old/new/g` | Replace all occurrences |
| `:%s/old/new/gc` | Replace with confirmation |

## Visual Mode
| Command | Action |
|---------|--------|
| `v` | Character-wise visual |
| `V` | Line-wise visual |
| `Ctrl+v` | Block-wise visual |
| `gv` | Reselect last selection |

## Macros
| Command | Action |
|---------|--------|
| `q{reg}` | Start recording to register |
| `q` | Stop recording |
| `@{reg}` | Play macro |
| `@@` | Replay last macro |

## Custom Tips for Dissertation
- Use `gq` to format paragraphs
- `vi"` to select text in quotes
- `=ip` to auto-indent paragraph
- `marks` for important sections
- `Ctrl+o/i` to jump between positions

*Note: Some commands may vary based on Obsidian's Vim mode implementation*