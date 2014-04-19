set guifont=Inconsolata-dz:h14,Source\ Code\ Pro:h14,Monaco:h14

" No audible bell
set visualbell

set guioptions-=T  " no toolbar
set guioptions-=e  " no tab bar
set guioptions-=rL " no scrollbars
set guioptions+=c  " use console dialogs

" Turn off ri tooltips that don't work with Ruby 1.9 yet
" http://code.google.com/p/macvim/issues/detail?id=342
if has('gui_running')
  set noballooneval
endif

" Local config
if filereadable($HOME . '/.gvimrc.local')
  source ~/.gvimrc.local
endif
