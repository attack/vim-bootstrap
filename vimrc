set nocompatible
filetype on
filetype off

let mapleader = ','

let s:shared_config = expand($HOME . '/.vimrc.shared')
if filereadable(s:shared_config)
  exec ':so ' . s:shared_config
endif

let s:local_config = expand($HOME . '/.vimrc.local')
if filereadable(s:local_config)
  exec ':so ' . s:local_config
endif

" PACKAGE LIST
" Use this variable inside your local configuration to declare
" which package you would like to include
"
if ! exists('g:vimified_packages')
  let g:vimified_packages = ['general', 'fancy', 'coding', 'ruby', 'rails', 'rspec', 'javascript', 'ctags', 'colour']
endif

" Vundle
"
"""""""""""""""""""""""""""""""""""""""
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'
Bundle 'tpope/vim-sensible'

let s:shared_bundles = expand($HOME . '/.vimrc.bundles.shared')
if filereadable(s:shared_bundles)
  exec ':so ' . s:shared_bundles
endif

let s:local_bundles = expand($HOME . '/.vimrc.bundles.local')
if filereadable(s:local_bundles)
  exec ':so ' . s:local_bundles
endif

" Package: General
"
"""""""""""""""""""""""""""""""""""""""
if count(g:vimified_packages, 'general')
  Bundle 'regreplop.vim'
  Bundle 'tpope/vim-repeat'
  Bundle 'tpope/vim-unimpaired'
  Bundle 'tpope/vim-vinegar'

  Bundle 'epmatsw/ag.vim'
  function! AgGrep()
    let command = 'ag -i '.expand('<cword>')
    cexpr system(command)
    cw
  endfunction

  function! AgVisual()
    normal gv"xy
    let command = 'ag -i '.@x
    cexpr system(command)
    cw
  endfunction

  map <leader>a :call AgGrep()<CR>
  vmap <leader>a :call AgVisual()<CR>

  Bundle 'tpope/vim-surround'
  " Add $ as a jQuery surround, _ for Underscore.js
  autocmd FileType javascript let b:surround_36 = "$(\r)"
        \ | let b:surround_95 = "_(\r)"

  Bundle 'kana/vim-textobj-user'
  Bundle 'Peeja/vim-cdo'

  Bundle 'scrooloose/nerdtree'
  let NERDTreeHijackNetrw = 0
  let g:NERDTreeWinSize = 20
  let g:NERDTreeChDirMode=2
  let NERDTreeShowHidden=1
  map \ :NERDTreeToggle<CR>
  map \| :NERDTreeFind<CR>

  Bundle 'kien/ctrlp.vim'
  let g:ctrlp_match_window = 'bottom,order:ttb,min:1,max:10,results:10'
  nnoremap <silent> <leader>f :CtrlP<CR>
  noremap <leader>b :CtrlPBuffer<CR>

  if executable('ag')
    " Use Ag over Grep
    set grepprg=ag\ --nogroup\ --nocolor

    let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
    let g:ctrlp_use_caching = 0
  else
    nnoremap <silent> <leader>F :ClearCtrlPCache<CR>\|:CtrlP<CR>
  endif

  " File Renaming (credit: garybernhardt)
  function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'))
    if new_name != '' && new_name != old_name
      exec ':saveas ' . new_name
      exec ':silent !rm ' . old_name
      redraw!
    endif
  endfunction
  map <leader>n :call RenameFile()<cr>

  " Smart Tab completion (credit: garybernhardt)
  function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
      return "\<tab>"
    else
      return "\<c-p>"
    endif
  endfunction
  inoremap <tab> <c-r>=InsertTabWrapper()<cr>
  inoremap <s-tab> <c-n>

  function! SetupWrapping()
    set wrap
    set wrapmargin=2
    set textwidth=72
  endfunction
  au BufRead,BufNewFile *.txt call SetupWrapping()
endif

" Package: Fancy
"
"""""""""""""""""""""""""""""""""""""""
if count(g:vimified_packages, 'fancy')
  Bundle 'itchyny/lightline.vim'

  :set noshowmode " mode is displayed by lightline
  let g:lightline = {
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             [ 'fugitive', 'filename' ],
    \             [ 'ctrlpmark' ] ]
    \ },
    \ 'component_function': {
    \   'fugitive': 'MyFugitive',
    \   'filename': 'MyFilename',
    \   'mode': 'MyMode',
    \   'ctrlpmark': 'CtrlPMark',
    \   'filetype': 'MyFiletype',
    \   'fileencoding': 'MyFileencoding',
    \   'fileformat': 'MyFileformat'
    \ }
    \ }

  function! MyModified()
    return &filetype =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
  endfunction

  function! MyReadonly()
    return &filetype !~? 'help' && &readonly ? 'RO' : ''
  endfunction

  function! MyFilename()
    let fname = expand('%:t')
    let fullname_list = split(expand('%:p'), getcwd() . '/')
    let fullname = fname != '' && len(fullname_list) > 0 ? fullname_list[0] : ''
    let displayname = winwidth(0) > 42 ? fullname : fname

    return fname == 'ControlP' ? g:lightline.ctrlp_item :
          \ &filetype == 'netrw' ? '' :
          \ &filetype == 'fugitiveblame' ? '' :
          \ &filetype == 'qf' ? len(getqflist()) . ' results' :
          \ &filetype == 'help' ? fname :
          \ fname =~ 'NERD_tree' ? '' :
          \ ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
          \ ('' != displayname ? displayname : '[No Name]') .
          \ ('' != MyModified() ? ' ' . MyModified() : '')
  endfunction

  function! MyFugitive()
    try
      if expand('%:t') !~? 'NERD' && &filetype != 'qf' && exists('*fugitive#head')
        let mark = ''
        let _ = fugitive#head()
        return strlen(_) ? mark._ : ''
      endif
    catch
    endtry
    return ''
  endfunction

  function! MyMode()
    let fname = expand('%:t')

    if fname =~ 'NERD_tree'
      call lightline#link('i')
    endif

    if &filetype == 'netrw'
      call lightline#link('R')
    endif

    if &filetype == 'fugitiveblame'
      call lightline#link('V')
    endif

    if &filetype == 'qf'
      call lightline#link('R')
    endif

    if &filetype == 'help'
      call lightline#link('V')
    endif

    return fname == 'ControlP' ? 'CtrlP' :
          \ fname =~ 'NERD_tree' ? 'NERDTree' :
          \ &filetype == 'netrw' ? 'NETRW' :
          \ &filetype == 'fugitiveblame' ? 'GIT BLAME' :
          \ &filetype == 'qf' ? 'QUICKFIX' :
          \ &filetype == 'help' ? 'HELP' :
          \ winwidth(0) > 60 ? lightline#mode() : ''
  endfunction

  function! CtrlPMark()
    if expand('%:t') =~ 'ControlP'
      call lightline#link('iR'[g:lightline.ctrlp_regex])
      return lightline#concatenate([g:lightline.ctrlp_prev, g:lightline.ctrlp_item
            \ , g:lightline.ctrlp_next], 0)
    else
      return ''
    endif
  endfunction

  let g:ctrlp_status_func = {
    \ 'main': 'CtrlPStatusFunc_1',
    \ 'prog': 'CtrlPStatusFunc_2',
    \ }

  function! CtrlPStatusFunc_1(focus, byfname, regex, prev, item, next, marked)
    let g:lightline.ctrlp_regex = a:regex
    let g:lightline.ctrlp_prev = a:prev
    let g:lightline.ctrlp_item = a:item
    let g:lightline.ctrlp_next = a:next
    return lightline#statusline(0)
  endfunction

  function! CtrlPStatusFunc_2(str)
    return lightline#statusline(0)
  endfunction

  function! MyFiletype()
    return &filetype == 'nerdtree' ? '' :
          \ &filetype == 'netrw' ? '' :
          \ &filetype == 'fugitiveblame' ? '' :
          \ &filetype == 'qf' ? '' :
          \ expand('%:t') == 'ControlP' ? '' :
          \ winwidth(0) > 70 ? strlen(&filetype) ? &filetype : 'no ft' : ''
  endfunction

  function! MyFileencoding()
    return &filetype == 'nerdtree' ? '' :
          \ &filetype == 'netrw' ? '' :
          \ &filetype == 'fugitiveblame' ? '' :
          \ &filetype == 'qf' ? '' :
          \ expand('%:t') == 'ControlP' ? '' :
          \ winwidth(0) > 80 ? (strlen(&fenc) ? &fenc : &enc) : ''
  endfunction

  function! MyFileformat()
    return &filetype == 'nerdtree' ? '' :
          \ &filetype == 'netrw' ? '' :
          \ &filetype == 'fugitiveblame' ? '' :
          \ &filetype == 'qf' ? '' :
          \ expand('%:t') == 'ControlP' ? '' :
          \ winwidth(0) > 90 ? &fileformat : ''
  endfunction

  if exists('+colorcolumn')
    set colorcolumn=80
  else
    au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
  endif

  Bundle 'myusuf3/numbers.vim'
  let g:numbers_exclude = ['nerdtree']
endif

" Package: Coding
"
"""""""""""""""""""""""""""""""""""""""
if count(g:vimified_packages, 'coding')
  Bundle 'tpope/vim-abolish'

  Bundle 'tpope/vim-fugitive'
  map <leader>g :Gblame<CR>

  Bundle 'tpope/vim-commentary'
  xmap <leader>/ <Plug>Commentary
  nmap <leader>/ <Plug>CommentaryLine

  Bundle 'Julian/vim-textobj-variable-segment'

  Bundle 'AndrewRadev/splitjoin.vim'
  let g:splitjoin_split_mapping = ''
  let g:splitjoin_join_mapping = ''
  nmap Ss :SplitjoinSplit<cr>
  nmap Sj :SplitjoinJoin<cr>

  " strip trailing whitespace on save
  function! StripTrailingWhitespace()
    let save_cursor = getpos('.')
    %s/\s\+$//e
    call setpos('.', save_cursor)
  endfunction
  autocmd BufWritePre *.rb,*.yml,*.js,*.css,*.less,*.sass,*.scss,*.html,*.xml,*.erb,*.haml call StripTrailingWhitespace()
endif

" Package: Ruby
"
"""""""""""""""""""""""""""""""""""""""
if count(g:vimified_packages, 'ruby') || count(g:vimified_packages, 'rails')
  Bundle 'vim-ruby/vim-ruby'
  Bundle 'tpope/vim-bundler'
  Bundle 'nelstrom/vim-textobj-rubyblock'

  " set question mark to be part of a VIM word. in Ruby it is!
  autocmd FileType ruby set iskeyword=@,48-57,_,?,!,192-255

  set wildignore+=*.gem
endif

" Package: Rails
"
"""""""""""""""""""""""""""""""""""""""
if count(g:vimified_packages, 'rails')
  Bundle 'tpope/vim-rails'
  let g:rails_ctags_arguments='--exclude=".git" --exclude="log" --exclude="doc" --exclude="spec/javascripts/helpers"'

  Bundle 'tpope/vim-haml'

  Bundle 'plasticboy/vim-markdown'
  let g:vim_markdown_folding_disabled=1

  autocmd FileType scss set iskeyword=@,48-57,_,-,?,!,192-255

  set wildignore+=*/public/assets/**
  set wildignore+=*/vendor/rails/**
  set wildignore+=*/vendor/cache/**
endif

" Package: Rspec
"
"""""""""""""""""""""""""""""""""""""""
if count(g:vimified_packages, 'rspec')
  Bundle 'tpope/vim-dispatch'
  Bundle 'thoughtbot/vim-rspec'

  let g:rspec_command = "Dispatch rspec {spec}"
  map <leader>t :call RunCurrentSpecFile()<CR>
  map <leader>s :call RunNearestSpec()<CR>
  map <leader>l :call RunLastSpec()<CR>

  " non-capture dispatch
  let g:debug_rspec_command = "Start rspec {spec}"
  function! StartCurrentSpecFile()
    let previous_command = g:rspec_command
    let g:rspec_command = g:debug_rspec_command
    call RunCurrentSpecFile()
    let g:rspec_command = previous_command
  endfunction

  function! StartNearestSpec()
    let previous_command = g:rspec_command
    let g:rspec_command = g:debug_rspec_command
    call RunNearestSpec()
    let g:rspec_command = previous_command
  endfunction

  function! StartLastSpec()
    let previous_command = g:rspec_command
    let g:rspec_command = g:debug_rspec_command
    call RunLastSpec()
    let g:rspec_command = previous_command
  endfunction

  map <leader>dt :call StartCurrentSpecFile()<CR>
  map <leader>ds :call StartNearestSpec()<CR>
  map <leader>dl :call StartLastSpec()<CR>

  " Promote to let (credit: garybernhardt)
  function! PromoteToLet()
    :normal! dd
    :normal! P
    :.s/\(\w\+\) = \(.*\)$/let(:\1) { \2 }/
    :normal ==
  endfunction
  :command! PromoteToLet :call PromoteToLet()
  map <leader>p :PromoteToLet<cr>
endif

" Package: Javascript
"
"""""""""""""""""""""""""""""""""""""""
if count(g:vimified_packages, 'javascript')
  Bundle 'kchmck/vim-coffee-script'
  Bundle 'mustache/vim-mustache-handlebars'
  Bundle 'pangloss/vim-javascript'

  au BufNewFile,BufRead *.json set filetype=javascript
endif

" Package: Ctags
"
"""""""""""""""""""""""""""""""""""""""
if count(g:vimified_packages, 'ctags')
  Bundle 'folke/AutoTag'

  let g:autotagExcludeSuffixes="tml.xml.text.txt.vim"
  map <leader>rt :!ctags --extra=+f --exclude=.git --exclude=log --exclude=doc -R *<CR><CR>
  map <C-\> :tnext<CR>
endif

" Package: Colour
"
"""""""""""""""""""""""""""""""""""""""
if count(g:vimified_packages, 'colour') || count(g:vimified_packages, 'color')
  Bundle 'chriskempson/tomorrow-theme', {'rtp': 'vim/'}

  colorscheme Tomorrow-Night-Eighties
  :hi TabLineFill term=bold cterm=bold ctermbg=237
endif

filetype plugin indent on
syntax on

"
" Options
"
"""""""""""""""""""""""""""""""""""""""

set notimeout      " no command timeout
set expandtab      " use soft tabs
set tabstop=2
set shiftwidth=2   " width of auto-indent
set softtabstop=2
set nowrap         " no wrapping
set number         " line numbers
set numberwidth=4

" completion sources: (current file, loaded buffers, unloaded buffers, tags)
set complete=.,b,u,]

set wildmode=longest,list:longest
set wildignore+=*vim/backups*
set wildignore+=*DS_Store*
set wildignore+=tags
set wildignore+=*/tmp/**
set wildignore+=*/log/**
set wildignore+=.git,*.rbc,*.class,.svn,*.png,*.jpg,*.gif

set list           " show whitespace
if has('gui_running')
  set listchars=trail:·
else
  set listchars=trail:~
endif

set showtabline=2  " always show tab bar
set showmatch      " show matching brackets
set hidden         " allow hidden, unsaved buffers
set splitbelow     " add new window towards right
set splitright     " add new window towards bottom
set scrolloff=3    " scroll when the cursor is 3 lines from bottom
set sidescroll=1
set sidescrolloff=5
set cursorline     " highlight current line

" Turn folding off for real, hopefully
set foldmethod=manual
set nofoldenable

" make searches case-sensitive only if they contain upper-case characters
set smartcase

" store temporary files in a central spot
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp

" switch syntax highlighting on, when the terminal has colors
if &t_Co > 2 || has('gui_running')
  set hlsearch
endif

" keep undo history across sessions, by storing in file.
if has('persistent_undo')
  silent !mkdir ~/.vim/backups > /dev/null 2>&1
  set undodir=~/.vim/backups
  set undofile
endif

"
" Keybindings
"
"""""""""""""""""""""""""""""""""""""""

" clear the search buffer when hitting space
:nnoremap <space> :nohlsearch<cr>

" sometimes I hold the shift too long ... just allow it
cabbrev W w
cabbrev Q q
cabbrev Tabe tabe

" split screen
:noremap <leader>v :vsp<CR>
:noremap <leader>h :split<CR>

" opens an edit command with the path of the currently edited file filled in
map <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

" opens a tab edit command with the path of the currently edited file filled in
" map <Leader>te :tabe <C-R>=expand("%:p:h") . "/" <CR>

" make Y consistent with D and C
map Y y$
map <silent> <leader>y :<C-u>silent '<,'>w !pbcopy<CR>

" copy current file path to system pasteboard
map <silent> <D-C> :let @* = expand("%")<CR>:echo "Copied: ".expand("%")<CR>
map <leader>C :let @* = expand("%").":".line(".")<CR>:echo "Copied: ".expand("%").":".line(".")<CR>

" indent/unindent visual mode selection with tab/shift+tab
vmap <tab> >gv
vmap <s-tab> <gv

" reload .vimrc
map <leader>rv :source ~/.vimrc<CR>

" open next/previous quickfix row
map <M-D-Down>  :cn<CR>
map <M-D-Up>    :cp<CR>

" open/close quickfix window
map <leader>qo  :copen<CR>
map <leader>qc  :cclose<CR>

if has('gui_macvim')
  " Fullscreen takes up entire screen
  set fuoptions=maxhorz,maxvert
  map <D-CR> :set invfu<cr>
endif
