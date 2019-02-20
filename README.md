# vim-bootsrap

Configuration files for vim

## Installation

Clone repo:
```sh
git clone git@github.com:attack/vim-bootstrap.git
```

### using brew + rcm (preferred)

Install [brewdler](https://github.com/Homebrew/homebrew-brewdler)

```sh
brew tap Homebrew/brewdler
```

Install [rcm](https://github.com/thoughtbot/rcm)

From within the `vim-bootstrap` directory

```sh
brew bundle
```

Install dotfiles:
```sh
rcup -d vim-bootstrap -x README.md -x install -x Brewfile
```

## Updating

Update Repo:
```sh
cd <your-vim-bootstrap-location>
git pull
```

Then just re-run the install steps, as they update as well.

## Make your own customizations

Put your project sharable customizations in dotfiles appended with `.shared`:

* `~/.vimrc.shared`
* `~/.vimrc.bundles.shared`

Put your customizations in dotfiles appended with `.local`:

* `~/.gvimrc.local`
* `~/.vimrc.local`
* `~/.vimrc.bundles.local`

## Credits

Heavy influence from [vimified](https://github.com/zaiste/vimified)

# Vim Command CheatSheet

## Discovery
```
:Ag <search_term> = project pattern search (use Ag, install via brew)
,a = call Rg/Ag using the current word under the cursor (or visually selected)
,f = fuzzy file find (via CTRL-P)
,b = fuzzy open buffer find (via CTRL-P)
,F = fuzzy file find after resetign cache
<f5> = while in fuzzy finder, refresh cache
```

## General
```
<space> = clear search higlighting
,v = veritical split
,h = horizontal split
,o = close all other windows in tab, except current
,n = rename file
,qo = open quickfix
,qc = close quickfix
[<space> = addline above
]<space> = addline below
<tab> = autocomplete (except when prefixed with whitespace)
<tab> = <tab> (only when prefixed with whitespace)
tt = toggle fullscreen mode on
ty = toggle fullscreen mode off
```

```
,rv = reload vimrc
,e = open edit command with current path filled in
```

### Visual mode specific
```
<tab> = add indent level
<shift><tab> = remove indent level
```

### MacVim only
```
<shift><command>c = copy current file path to clipboard
,C = copy current file + line number path to clipboard
<shift><command><down> = open next quickfix file listing (ie search result)
<shift><command><up> = open previous quickfix file listing (ie search result)
```

## Plugins

### Fugative
```
,g = git blame
```

### Nerd Tree
```
\ = toggle tree
<shift>\ = toggle tree and focus on current file
```

### Commentary
```
,/ = toggle comment
```

### regreplop
```
<ctrl>k = paste over, keep original buffer
```

### Vim Rspec + dispatch
using vim-dispatch `Dispatch`:
this will capture results and display in quickfix
```
<leader>t = run current spec + line in iTerm
<leader>s = run current spec file in iTerm
<leader>l = run last spec in iTerm
```

using vim-dispatch `Start`:
this will not capture results
```
<leader>dt = run current spec + line in iTerm
<leader>ds = run current spec file in iTerm
<leader>dl = run last spec in iTerm
```

### ctags
*requires ctags installed*
*recommend use of gem-ctags for ruby*
```
<ctrl>] = find first tag match
<ctrl>\ = find next tag match
,rt = regenerate tags file
```

### text object expansion
```
+ (multiple times) = expand text object selection
_ (multiple times) = collapse text object selection
```
