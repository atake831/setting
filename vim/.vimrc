if has('vim_starting')
    set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.vim/bundle/'))
    NeoBundleFetch 'Shougo/neobundle.vim'
    NeoBundle 'thinca/vim-quickrun' 
    NeoBundle "tyru/caw.vim.git"
    NeoBundle 'kien/ctrlp.vim'
    NeoBundle 'scrooloose/nerdtree'
    NeoBundle 'Shougo/neocomplcache'
    NeoBundle 'Shougo/neosnippet'
    NeoBundle 'vim-scripts/yanktmp.vim'
    NeoBundle 'Shougo/neosnippet-snippets'
    NeoBundle 'Shougo/unite.vim'
    NeoBundle 'Shougo/neomru.vim'
    NeoBundle 'wavded/vim-stylus'
    NeoBundle 'wavded/vim-jade'
    NeoBundle 'leafgarland/typescript-vim'
call neobundle#end()

set nocompatible
filetype off

let g:quickrun_config={'*': {'split': 'vertical'}}
set splitright

nmap <Leader>c <Plug>(caw:i:toggle)
vmap <Leader>c <Plug>(caw:i:toggle)

let g:neocomplcache_enable_at_startup = 1

imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \ "\<Plug>(neosnippet_expand_or_jump)"
            \: pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \ "\<Plug>(neosnippet_expand_or_jump)"
            \: "\<TAB>"

if has('conceal')
    set conceallevel=2 concealcursor=i
endif

filetype plugin on
filetype indent on

set nocompatible
scriptencoding utf-8
set fileencodings=utf8,iso-2022-jp,cp932,euc-jp
if isdirectory($HOME . '/.vim') 
  let $MY_VIMRUNTIME = $HOME.'/.vim' 
elseif isdirectory($HOME . '\vimfiles') 
  let $MY_VIMRUNTIME = $HOME.'\vimfiles' 
elseif isdirectory($VIM . '\vimfiles') 
  let $MY_VIMRUNTIME = $VIM.'\vimfiles' 
endif 
set nowritebackup
set nobackup
set clipboard+=unnamed
set nrformats-=octal
set timeoutlen=3500
set hidden
set history=50
set formatoptions+=mM
set virtualedit=block
set whichwrap=b,s,[,],<,>
set ambiwidth=double
set wildmenu
if has('mouse')
  set mouse=a
endif
filetype plugin indent on

set ignorecase
set smartcase
set wrapscan
set incsearch
set hlsearch
set noerrorbells
set novisualbell
set visualbell t_vb=
set shellslash
set number
set showmatch matchtime=1
set ts=4 sw=4 sts=4
set autoindent
set cinoptions+=:0
set title
set cmdheight=2
set laststatus=2
set showcmd
set display=lastline
if &t_Co > 2 || has('gui_running')
  syntax on
endif

if has('iconv')
  set statusline=%<%f\ %m\ %r%h%w%{'['.(&fenc!=''?&fenc:&enc).(&bomb?':BOM':'').']['.&ff.']'}%=[0x%{FencB()}]\ (%v,%l)/%L%8P\ 
else
  set statusline=%<%f\ %m\ %r%h%w%{'['.(&fenc!=''?&fenc:&enc).(&bomb?':BOM':'').']['.&ff.']'}%=\ (%v,%l)/%L%8P\ 
endif
function! FencB()
  let c = matchstr(getline('.'), '.', col('.') - 1)
  let c = iconv(c, &enc, &fenc)
  return s:Byte2hex(s:Str2byte(c))
endfunction

function! s:Str2byte(str)
  return map(range(len(a:str)), 'char2nr(a:str[v:val])')
endfunction

function! s:Byte2hex(bytes)
  return join(map(copy(a:bytes), 'printf("%02X", v:val)'), '')
endfunction

if has('win95') || has('win16') || has('win32') || has('win64')
  set diffexpr=MyDiff()
  function! MyDiff()
    silent! let saved_sxq=&shellxquote
    silent! set shellxquote=
    let opt = '-a --binary '
    if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
    if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
    let arg1 = v:fname_in
    if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
    let arg2 = v:fname_new
    if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
    let arg3 = v:fname_out
    if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
    let cmd = '!""' . $VIM . '\diff" ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . '"'
    silent exe cmd
    silent! let &shellxquote = saved_sxq
  endfunction
endif
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
command! -nargs=? -complete=file Diff if '<args>'=='' | browse vertical diffsplit|else| vertical diffsplit <args>|endif
set patchexpr=MyPatch()
function! MyPatch()
   :call system($VIM."\\'.'patch -o " . v:fname_out . " " . v:fname_in . " < " . v:fname_diff)
endfunction

nnoremap <F1> K
nnoremap <F8> :source %<CR>
nnoremap ZZ <Nop>
nnoremap <Down> gj
nnoremap <Up>   gk
nnoremap h <Left>zv
nnoremap j gj
nnoremap k gk
nnoremap l <Right>zv

augroup vimrcEx
  autocmd!
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line('$') |
    \   exe "normal! g`\"" |
    \ endif
augroup END

let g:hi_insert = 'highlight StatusLine guifg=darkblue guibg=darkyellow gui=none ctermfg=blue ctermbg=yellow cterm=none'

if has('syntax')
  augroup InsertHook
    autocmd!
    autocmd InsertEnter * call s:StatusLine('Enter')
    autocmd InsertLeave * call s:StatusLine('Leave')
  augroup END
endif

let s:slhlcmd = ''
function! s:StatusLine(mode)
  if a:mode == 'Enter'
    silent! let s:slhlcmd = 'highlight ' . s:GetHighlight('StatusLine')
    silent exec g:hi_insert
  else
    highlight clear StatusLine
    silent exec s:slhlcmd
    redraw
  endif
endfunction

function! s:GetHighlight(hi)
  redir => hl
  exec 'highlight '.a:hi
  redir END
  let hl = substitute(hl, '[\r\n]', '', 'g')
  let hl = substitute(hl, 'xxx', '', '')
  return hl
endfunction

function! ZenkakuSpace()
  highlight ZenkakuSpace cterm=underline ctermfg=darkgrey gui=underline guifg=darkgrey
endfunction

if has('syntax')
  augroup ZenkakuSpace
    autocmd!
    autocmd ColorScheme       * call ZenkakuSpace()
    autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
  augroup END
  call ZenkakuSpace()
endif

inoremap jj <ESC>
set matchpairs& matchpairs+=<:>
set smartindent
set smarttab
set expandtab
set tabstop=2
set shiftwidth=2
imap {} {}<Left>
imap [] []<Left>
imap () ()<Left>
imap "" ""<Left>
imap '' ''<Left>
imap <> <><Left>

noremap ma 0
noremap me $
noremap md %
inoremap <C-d> <C-h>
inoremap <C-h> <Left>
inoremap <C-l> <Right>

map <silent> my :call YanktmpYank()<CR> 
map <silent> mp :call YanktmpPaste_p()<CR>
map <silent> mP :call YanktmpPaste_P()<CR>

noremap 1 :bN<cr>
noremap 2 :bn<cr>
noremap mw :bd<cr>

let g:unite_enable_start_insert=1
let g:unite_source_history_yank_enable =1
let g:unite_source_file_mru_limit = 200
noremap <silent> ,uy :<C-u>Unite history/yank<CR>
noremap <silent> ,ub :<C-u>Unite buffer<CR>
noremap <silent> ,ud :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
noremap <silent> ,ur :<C-u>Unite -buffer-name=register register<CR>
noremap <silent> ,uc :<C-u>Unite file<CR>
noremap <silent> ,uu :<C-u>Unite file_mru<CR>
