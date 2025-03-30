" System vimrc file for MacVim
"
" Author:       Bjorn Winckler <bjorn.winckler@gmail.com>
" Maintainer:   macvim-dev (https://github.com/macvim-dev)

set nocompatible

" The default for 'backspace' is very confusing to new users, so change it to a
" more sensible value.  Add "set backspace&" to your ~/.vimrc to reset it.
set backspace+=indent,eol,start

" Python2
" MacVim is configured by default to use the pre-installed System python2
" version. However, following code tries to find a Homebrew, MacPorts or
" an installation from python.org:
if exists("&pythondll") && exists("&pythonhome")
  if filereadable("/usr/local/Frameworks/Python.framework/Versions/2.7/Python")
    " Homebrew python 2.7
    set pythondll=/usr/local/Frameworks/Python.framework/Versions/2.7/Python
  elseif filereadable("/opt/local/Library/Frameworks/Python.framework/Versions/2.7/Python")
    " MacPorts python 2.7
    set pythondll=/opt/local/Library/Frameworks/Python.framework/Versions/2.7/Python
  elseif filereadable("/Library/Frameworks/Python.framework/Versions/2.7/Python")
    " https://www.python.org/downloads/mac-osx/
    set pythondll=/Library/Frameworks/Python.framework/Versions/2.7/Python
  endif
endif

" Python3
" MacVim is configured by default to use Homebrew python3 version
" If this cannot be found, following code tries to find a MacPorts
" or an installation from python.org:
if exists("&pythonthreedll") && exists("&pythonthreehome") &&
      \ !filereadable(&pythonthreedll)
  if filereadable("/opt/local/Library/Frameworks/Python.framework/Versions/3.9/Python")
    " MacPorts python 3.9
    set pythonthreedll=/opt/local/Library/Frameworks/Python.framework/Versions/3.9/Python
  elseif filereadable("/Library/Frameworks/Python.framework/Versions/3.9/Python")
    " https://www.python.org/downloads/mac-osx/
    set pythonthreedll=/Library/Frameworks/Python.framework/Versions/3.9/Python
  endif
endif

" Vim and macVim Custom Editor Settings

" Netrw Key Mapping Function
function! NetrwMapping()
" Map L1 to open Lexplore mode - Non-Recursive Mapping
    nnoremap L1 :Lexplore<CR>:vertical resize 39<CR>
endfunction

" Toggle Copilot on and off
let g:copilot_enabled = v:true

function! ToggleCopilot()
  if g:copilot_enabled
    Copilot disable
    let g:copilot_enabled = v:false
    echo "Copilot disabled"
  else
    Copilot enable
    let g:copilot_enabled = v:true
    echo "Copilot enabled"
  endif
endfunction

" Map Ctrl+p to toggle Copilot
nnoremap <C-p> :call ToggleCopilot()<CR>

" Display line numbers in files
set number

" Set default colorscheme
" Note:  Moved to .gvimrc to avoid conflicts when running mvim or vim
" from the command line
" colorscheme mustang_vim_colorscheme_by_hcalves_d1mxd78

" NERDtree Like Setup
" Disable the Netrw banner
let g:netrw_banner = 0

" Set the default listing style:
" 3 = tree style listing
let g:netrw_liststyle = 3

" Set how files are opened when selected:
" 4 = open file in previous window
let g:netrw_browse_split = 4

" Open vertical splits to the right
let g:netrw_altv = 1

" Set the width of the directory explorer to 25% of the screen
let g:netrw_winsize = 25

" Create an autocommand group netrw_mapping
augroup netrw_mapping
  " Clear any existing autocommands in this group
  autocmd!
  " When Vim starts,automatically perform key mapping
  autocmd filetype netrw call NetrwMapping()
augroup END

" Create an autocommand group named ProjectDrawer
augroup ProjectDrawer
  " Clear any existing autocommands in this group
  autocmd!
  " When Vim starts, automatically open Netrw in the left window
  " and file (if specified) in right window (Note: Use Vexplore to place Netrw
  " in the Right Window)
  autocmd VimEnter * if argc() == 0 | Lexplore | else | Lexplore | wincmd l | endif
augroup END

" Vim-Plugins
call plug#begin()

" List plugins here
Plug 'ryanoasis/vim-devicons'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'github/copilot.vim'

call plug#end()

" Enable/Disable use of PowerLine Fonts
let g:airline_powerline_fonts = 1

" Enable/Disable detection of whitespace errors (mixing of spaces and tabs)
let g:airline#extensions#whitespace#enabled = 0

