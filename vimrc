set nocompatible
filetype on
filetype off

let mapleader = ','

let s:shared_config = expand($HOME . '/.vimrc.shared')
if filereadable(s:shared_config)
  exec ':source ' . s:shared_config
endif

let s:local_config = expand($HOME . '/.vimrc.local')
if filereadable(s:local_config)
  exec ':source ' . s:local_config
endif

" PACKAGE LIST
" Use this variable inside your local configuration to declare
" which package you would like to include
"
if ! exists('g:vimified_packages')
  let g:vimified_packages = ['general', 'fancy', 'coding', 'indent', 'ruby', 'rails', 'rspec', 'javascript', 'ctags', 'snippets', 'colour']
endif

" Vundle
"
"""""""""""""""""""""""""""""""""""""""
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'tpope/vim-sensible'

let s:shared_bundles = expand($HOME . '/.vimrc.bundles.shared')
if filereadable(s:shared_bundles)
  silent! exec ':source ' . s:shared_bundles
endif

let s:local_bundles = expand($HOME . '/.vimrc.bundles.local')
if filereadable(s:local_bundles)
  silent! exec ':source ' . s:local_bundles
endif

" Package: General
"
"""""""""""""""""""""""""""""""""""""""
if count(g:vimified_packages, 'general')
  Plugin 'regreplop.vim'
  Plugin 'tpope/vim-repeat'
  Plugin 'tpope/vim-unimpaired'
  Plugin 'tpope/vim-vinegar'

  Plugin 'rking/ag.vim'
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

  Plugin 'tpope/vim-surround'
  " Add $ as a jQuery surround, _ for Underscore.js
  autocmd FileType javascript let b:surround_36 = "$(\r)"
        \ | let b:surround_95 = "_(\r)"

  Plugin 'kana/vim-textobj-user'
  Plugin 'kana/vim-textobj-line'
  Plugin 'sjl/gundo.vim'
  Plugin 'Peeja/vim-cdo'

  Plugin 'scrooloose/nerdtree'
  let NERDTreeHijackNetrw = 0
  let g:NERDTreeWinSize = 25
  let g:NERDTreeChDirMode = 2
  let NERDTreeShowHidden = 1
  map \ :NERDTreeToggle<CR>
  map \| :NERDTreeFind<CR>

  Plugin 'ctrlpvim/ctrlp.vim'
  let g:ctrlp_match_window = 'bottom,order:ttb,min:1,max:10,results:10'
  let g:ctrlp_clear_cache_on_exit = 0
  let g:ctrlp_max_files = 0

  nnoremap <silent> <leader>f :CtrlP<CR>
  noremap <leader>b :CtrlPBuffer<CR>

  Plugin 'FelikZ/ctrlp-py-matcher'
  let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }

  if executable('ag')
    " Use Ag over Grep
    set grepprg=ag\ --nogroup\ --nocolor

    let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup --ignore ".git" --ignore ".DS_Store" --hidden -g ""'
  else
    nnoremap <silent> <leader>F :ClearCtrlPCache<CR>\|:CtrlP<CR>
  endif

  " File Renaming (credit: garybernhardt)
  function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
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
  Plugin 'itchyny/lightline.vim'

  :set noshowmode " mode is displayed by lightline
  let g:lightline = {
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             [ 'filename', 'syntastic' ],
    \             [ 'ctrlpmark' ] ],
    \   'right': [ [ 'fugitive', 'ctrlpdir' ],
    \              [ 'lineinfo' ],
    \              [ 'filetype' ] ]
    \ },
    \ 'inactive': {
    \   'left': [ [ 'filename' ] ],
    \   'right': [ ]
    \ },
    \ 'component_function': {
    \   'fugitive': 'MyFugitive',
    \   'filename': 'MyFilename',
    \   'mode': 'MyMode',
    \   'ctrlpmark': 'CtrlPMark',
    \   'ctrlpdir': 'CtrlPDir',
    \   'lineinfo': 'MyLineinfo',
    \   'filetype': 'MyFiletype'
    \ },
    \ 'component_expand': {
    \   'syntastic': 'SyntasticStatuslineFlag'
    \ },
    \ 'component_type': {
    \   'syntastic': 'error'
    \ }
    \ }

  function! MyMinStatus(colour_mode, mode, fugitive, filename, lineinfo)
    if a:colour_mode != ''
      call lightline#link(a:colour_mode)
    endif

    if a:fugitive == 1
      let g:lightline.my_fugitive = MyDefaultFugitive()
    else
      let g:lightline.my_fugitive = ''
    endif

    let g:lightline.my_mode = a:mode
    if ! exists('g:lightline.my_filename')
      let g:lightline.my_filename = {}
    endif
    let g:lightline.my_filename[bufnr('%')] = a:filename

    let g:lightline.my_filetype = ''
    if a:lineinfo == 1
      let g:lightline.my_lineinfo = printf('%3u:%-2u', line('.'), virtcol('.'))
    else
      let g:lightline.my_lineinfo = ''
    endif
  endfunction

  function! MyFullStatus(mode, filename, filetype)
    call MyMinStatus('', a:mode, 1, a:filename, 1)

    let g:lightline.my_filetype = a:filetype
  endfunction

  function! MyDefaultFilename()
    let fname = expand('%:t')
    let path_list = split(expand('%:p'), getcwd() . '/')
    let relative_path = fname != '' && len(path_list) > 0 ? path_list[0] : ''
    let display_name = winwidth(0) > 42 ? relative_path : fname

    return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
         \ ('' != display_name ? display_name : '[No Name]') .
         \ ('' != MyModified() ? ' ' . MyModified() : '')
  endfunction

  function! MyDefaultFugitive()
    try
      if exists('*fugitive#head')
        let mark = ''
        let _ = fugitive#head()
        return strlen(_) ? mark._ : ''
      endif
    catch
    endtry
    return ''
  endfunction

  function! MyDefault()
    let my_filename = MyDefaultFilename()
    let my_mode = (winwidth(0) > 60 ? lightline#mode() : '')
    let my_filetype = (winwidth(0) > 70 ? strlen(&filetype) ? &filetype : 'no ft' : '')

    call MyFullStatus(my_mode, my_filename, my_filetype)
  endfunction

  function! DetectMode()
    if expand('%:t') == 'ControlP'
      call MyMinStatus('', 'CtrlP', 0, '', 0)

    elseif expand('%:t') =~ 'NERD_tree'
      call MyMinStatus('i', 'NERDTree', 0, '', 1)

    elseif &filetype == 'netrw'
      call MyMinStatus('R', 'NETRW', 0, b:netrw_curdir, 0)

    elseif &filetype == 'fugitiveblame'
      call MyMinStatus('V', 'GIT BLAME', 1, '', 1)

    elseif &filetype == 'qf' && len(getloclist(0)) > 0
      call MyMinStatus('R', 'LOCATION', 0, len(getloclist(0)) . ' locations', 1)

    elseif &filetype == 'qf'
      call MyMinStatus('R', 'QUICKFIX', 0, len(getqflist()) . ' results', 1)

    elseif &filetype == 'help'
      call MyMinStatus('V', 'HELP', 0, expand('%:t'), 1)

    elseif &filetype == 'vundle'
      call MyMinStatus('V', 'VUNDLE', 0, expand('%:t'), 1)

    else
      call MyDefault()
    endif
  endfunction

  function! PruneFilenames()
    if exists('g:lightline.my_filename')
      let buffersInCurrentTab = tabpagebuflist(tabpagenr())
      let filenameKeys = keys(g:lightline.my_filename)
      for iKey in filenameKeys
        if index(buffersInCurrentTab, iKey * 1) < 0
          unlet g:lightline.my_filename[iKey]
        endif
      endfor
    endif
  endfunction

  function! MyMode()
    call PruneFilenames()
    call DetectMode()
    return exists('g:lightline.my_mode') ? g:lightline.my_mode : ''
  endfunction

  function! MyModified()
    return &modified ? '+' : &modifiable ? '' : '-'
  endfunction

  function! MyReadonly()
    return &readonly ? 'RO' : ''
  endfunction

  function! MyFilename()
    if exists('g:lightline.my_filename') && has_key(g:lightline.my_filename, bufnr('%'))
      let fname = g:lightline.my_filename[bufnr('%')]
    else
      let fname = expand('%:t')
    endif
    return fname
  endfunction

  function! MyFugitive()
    return exists('g:lightline.my_fugitive') ? g:lightline.my_fugitive : ''
  endfunction

  function! MyFiletype()
    return exists('g:lightline.my_filetype') ? g:lightline.my_filetype : ''
  endfunction

  function! MyLineinfo()
    return exists('g:lightline.my_lineinfo') ? g:lightline.my_lineinfo : ''
  endfunction

  function! CtrlPMark()
    if expand('%:t') == 'ControlP'
      call lightline#link('iR'[g:lightline.ctrlp_regex])
      return g:lightline.ctrlp_item
    else
      return ''
    endif
  endfunction

  function! CtrlPDir()
    if expand('%:t') == 'ControlP'
      return getcwd()
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
    let g:lightline.ctrlp_item = a:item
    return lightline#statusline(0)
  endfunction

  function! CtrlPStatusFunc_2(str)
    return lightline#statusline(0)
  endfunction

  " colorcolumn on active windows only
  if exists('+colorcolumn')
    augroup ccolumn
      au!
      au VimEnter,WinEnter,BufWinEnter * setlocal colorcolumn=80
      au WinLeave * setlocal colorcolumn=
    augroup END
  else
    au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
  endif

  " cursorline on active windows only
  augroup cline
    au!
    au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
  augroup END

  " fix windows on resize
  au VimResized * :wincmd =
endif

" Package: Coding
"
"""""""""""""""""""""""""""""""""""""""
if count(g:vimified_packages, 'coding')
  Plugin 'tpope/vim-abolish'

  Plugin 'tpope/vim-fugitive'
  map <leader>g :Gblame<CR>

  Plugin 'tpope/vim-commentary'
  xmap <leader>/ <Plug>Commentary
  nmap <leader>/ <Plug>CommentaryLine

  Plugin 'AndrewRadev/splitjoin.vim'
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
  autocmd BufWritePre *.rb,*.yml,*.js,*.css,*.less,*.sass,*.scss,*.html,*.xml,*.erb,*.haml,*.coffee call StripTrailingWhitespace()

  Plugin 'scrooloose/syntastic'
  let g:syntastic_enable_signs=1
  let g:syntastic_auto_loc_list=2
  let g:syntastic_enable_highlighting=0
  let g:syntastic_enable_balloons=0
  let g:syntastic_check_on_wq=0
  let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': [] }
  let g:syntastic_stl_format = '%E{%e errors}%B{, }%W{%w warnings}'

  function! s:syntastic()
    SyntasticCheck
    call lightline#update()
  endfunction

  augroup AutoSyntastic
    autocmd!
    autocmd BufWritePost *.rb call s:syntastic()
  augroup END

  Plugin 'argtextobj.vim'
  Plugin 'terryma/vim-expand-region'
endif

" Package: Indent
"
"""""""""""""""""""""""""""""""""""""""
if count(g:vimified_packages, 'indent')
  Plugin 'michaeljsmith/vim-indent-object'
  let g:indentobject_meaningful_indentation = ['haml', 'sass', 'yaml', 'markdown']

  Plugin 'Yggdroot/indentLine'
  let g:indentLine_fileType = ['yaml', 'coffee']
endif

" Package: Ruby
"
"""""""""""""""""""""""""""""""""""""""
if count(g:vimified_packages, 'ruby') || count(g:vimified_packages, 'rails')
  Plugin 'vim-ruby/vim-ruby'
  Plugin 'tpope/vim-bundler'
  Plugin 'nelstrom/vim-textobj-rubyblock'

  let g:textobj_rubysymbol_no_default_key_mappings = 1
  xmap as <Plug>(textobj-rubysymbol-a)
  omap as <Plug>(textobj-rubysymbol-a)
  xmap is <Plug>(textobj-rubysymbol-i)
  omap is <Plug>(textobj-rubysymbol-i)
  Plugin 'bootleq/vim-textobj-rubysymbol'

  " set question mark to be part of a VIM word. in Ruby it is!
  autocmd FileType ruby set iskeyword=@,48-57,_,?,!,192-255

  set wildignore+=*.gem

  " ysiw#   Wrap the token under the cursor in #{}
  " v...s#  Wrap the selection in #{}
  let g:surround_113 = "#{\r}"   " v
  let g:surround_35  = "#{\r}"   " #

  " ,# Surround a word with #{ruby interpolation}
  map ,# ysiw#
  vmap ,# c#{<C-R>"}<ESC>
endif

" Package: Rails
"
"""""""""""""""""""""""""""""""""""""""
if count(g:vimified_packages, 'rails')
  Plugin 'tpope/vim-rails'
  let g:rails_ctags_arguments='--exclude=".git" --exclude="log" --exclude="doc" --exclude="spec/javascripts/helpers"'
  
  Plugin 'othree/html5.vim'
  Plugin 'tpope/vim-haml'

  Plugin 'plasticboy/vim-markdown'
  let g:vim_markdown_folding_disabled=1

  autocmd FileType scss set iskeyword=@,48-57,_,-,?,!,192-255

  set wildignore+=*/public/assets/**
  set wildignore+=*/vendor/rails/**
  set wildignore+=*/vendor/cache/**

  " wrap selection in erb tags
  let g:surround_45 = "<% \r %>"    " -
  let g:surround_61 = "<%= \r %>"   " =
endif

" Package: Rspec
"
"""""""""""""""""""""""""""""""""""""""
if count(g:vimified_packages, 'rspec')
  Plugin 'tpope/vim-dispatch'
  Plugin 'thoughtbot/vim-rspec'

  let g:rspec_command = "Dispatch bundle exec rspec {spec}"
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
  Plugin 'kchmck/vim-coffee-script'
  Plugin 'mustache/vim-mustache-handlebars'
  Plugin 'pangloss/vim-javascript'
  Plugin 'kana/vim-textobj-function'
  Plugin 'thinca/vim-textobj-function-javascript'

  au BufNewFile,BufRead *.json set filetype=javascript
endif

" Package: Ctags
"
"""""""""""""""""""""""""""""""""""""""
if count(g:vimified_packages, 'ctags')
  Plugin 'folke/AutoTag'

  let g:autotagExcludeSuffixes="tml.xml.text.txt.vim"
  map <leader>rt :!ctags --extra=+f --exclude=.git --exclude=log --exclude=doc -R *<CR><CR>
  map <C-\> :tnext<CR>
endif

" Package: Snippets
"
"""""""""""""""""""""""""""""""""""""""
if count(g:vimified_packages, 'snippets')
  Plugin 'SirVer/ultisnips'
  Plugin 'honza/vim-snippets'

  let g:UltiSnipsExpandTrigger='<c-s>'
  let g:UltiSnipsJumpForwardTrigger='<c-s>'
  let g:UltiSnipsJumpBackwardTrigger='<c-a>'
endif

" Package: Colour
"
"""""""""""""""""""""""""""""""""""""""
if count(g:vimified_packages, 'colour') || count(g:vimified_packages, 'color')
  Plugin 'chriskempson/tomorrow-theme', {'rtp': 'vim/'}

  :hi TabLineFill term=bold cterm=bold ctermbg=237
endif

call vundle#end()
filetype plugin indent on
syntax on

if count(g:vimified_packages, 'coding')
  let g:expand_region_text_objects = {
      \ 'iw'  :0,
      \ 'i"'  :0,
      \ 'i''' :0,
      \ 'i]'  :1,
      \ 'ia'  :0,
      \ 'aa'  :0,
      \ 'ib'  :1,
      \ 'iB'  :1,
      \ 'il'  :0
      \ }

  if count(g:vimified_packages, 'ruby') || count(g:vimified_packages, 'rails')
    call expand_region#custom_text_objects('ruby', {
      \ 'as' :1,
      \ 'ir' :1,
      \ 'ar' :1
      \ })
    call expand_region#custom_text_objects('html', {
      \ 'it' :1
      \ })
  endif

  if count(g:vimified_packages, 'javascript')
    call expand_region#custom_text_objects('javascript', {
      \ 'if' :1,
      \ 'af' :1
      \ })
    call expand_region#custom_text_objects('coffee', {
      \ 'ii' :1
      \ })
  endif
endif

if count(g:vimified_packages, 'colour') || count(g:vimified_packages, 'color')
  colorscheme Tomorrow-Night-Eighties
endif

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
set textwidth=0
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

" toggle fullscreen
:noremap tt :tab split<CR>
:noremap ty :tabc <CR>

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