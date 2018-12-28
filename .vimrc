" FileName: ~/.vimrc
" Updated: mar 29 may 2018 19:52:53 CEST
" Revision: 178
"
" Fork of :  https://wiki.archlinux.org/index.php/vim/.vimrc 
" 
" BACKUPS, SWAPFILES, VIEWDIR, TMPDIR  "{{{1
" ====================================================================================

" SET RUNTIMEPATH {{{2
let $VIM="/usr/share/vim"
let $VIMRUNTIME=expand("$VIM/vim81/")
set runtimepath=$VIMRUNTIME,$VIM/vimfiles,~/.vim,$VIM/vimfiles/after,~/.vim/after,$VIMRUNTIME/after,/usr/share/vifm/vim

"echomsg &runtimepath
"echomsg expand("$VIMRUNTIME")

" BKDIR {{{2

if exists("*mkdir")
	let &directory=expand("$XDG_DATA_HOME/vim")
	let &viewdir=expand(&directory) . "/viewdir"
	let &backupdir=expand(&directory) . "/bk"
	let &undodir=expand(&directory) . "/undos"
	let logdir=expand($HOME) . "/.local/log"
	let &verbosefile=expand(logdir) . "/vim.log"

	if !isdirectory(expand(&directory))|call mkdir(expand(&directory), "p", 0700)|endif
	if !isdirectory(expand(logdir))|call mkdir(expand(logdir), "p", 0700)|endif
	if !isdirectory(expand(&viewdir))|call mkdir(expand(&viewdir), "p", 0700)|endif
	if !isdirectory(expand(&backupdir))|call mkdir(expand(&backupdir), "p", 0700)|endif
	if !isdirectory(expand(&undodir))|call mkdir(expand(&undodir), "p", 0700)|endif
	if !isdirectory(expand("$XDG_CACHE_HOME") . "/vim")|call mkdir(expand("$XDG_CACHE_HOME") . "/vim", "p", 0700)|endif

else
	echoerr "mkdir not exist, please install"
endif

" SETTINGS USING NEW DIRS {{{4

" VIMINFO {{{4
" COMMENTED OUT {{{5
"  "       Maximum number of lines saved for each register
"  %       When included, save and restore the buffer lis
"  '       Maximum number of previously edited files for which the marks are remembere
"  /       Maximum number of items in the search pattern history to be saved
"  :        Maximum number of items in the command-line history
"  <       Maximum number of lines saved for each register.
"   @       Maximum number of items in the input-line history
"  h       Disable the effect of 'hlsearch' when loading the viminfo
"  n       Name of the viminfo file.  The name must immediately follow the 'n'. 
"  r       Removable media.  The argument is a string
"  s       Maximum size of an item in Kbyte
" }}}5 COMMENTED OUT

let &viminfo="%203,'200,/800,h,<500,:500,s150,r/tmp,r" . expand("$BKDIR") . "/tmp/.vim,n" . expand("$BKDIR") ."/.vim/.vinfo"
" }}}4 ENDOF VIMINFO

" --------------------------------------------------- }}}1 ENDOF BACKUPS, SWAPFILES, VIEWDIR, TMPDIR
" DYNAMIC SETTINGS / COLORS / TERMINAL {{{1
" ====================================================================================
" echomsg &t_Co
" echomsg &term

if &t_Co > 2

	if &term =~ "256"

		set bg=dark t_Co=256 vb
		let &t_vb="\<Esc>[?5h\<Esc>[?5l"      " flash screen for visual bell
		

		let _paths = split(&runtimepath, ",")
		let _i = 0
		let existColor = 0

		while ( !existColor && _i < len(_paths) ) 

			let _path = expand( _paths[_i] ) . "/colors/kolor.vim"

			"echomsg _paths[_i]

			if filereadable( expand(_path) )

				"echomsg _path
				let existColor = 1 

			endif

			let _i += 1

		endwhile
		
		let g:colors_name = existColor ? "kolor" : "default" 

		unlet! _paths
		unlet! _path
		unlet! _i
		unlet! existColor

	else
		" things like cfdisk, crontab -e, visudo, vless, etc.
		set term=screen-16color
		set t_Co=16

	endif

	syntax on

endif

" -------------------------------------------------------------- }}}1 ENDOF DYNAMIC SETTINGS / COLORS / TERMINAL
" CUSTOM FUNCTIONS "{{{1
" ====================================================================================
if !exists("AskApacheLoaded")
	let AskApacheLoaded=1

	" http://dotfiles.org/~samba/.vimrc
	" www.gregsexton.org/2011/03/improving-the-text-displayed-in-a-fold/

	" DECLARATIONS {{{2
	" ================================================================================
	" FUNCTION - ManualLastMod {{{4
	function! CommentBlankLine(i)
		call setline(i, printf(&commentstring))
	endfunction
		
	function! ManualLastMod()
		"echomsg 'LastMod RUNNING'
		call setline(1, printf('%s%s', printf(&commentstring, ' '), expand('%:p'))) 
		call CommentBlankLine(2)
		for [l,v,d] in [[3,'Updated'," "],[4,'Revision',1],[5,'Author'," "]]
			call setline(l, printf('%s%s: %s', printf(&commentstring, ' '), v,d))
		endfor
		call LastMod()
	endfunction


	" FUNCTION - LastMod {{{4
	" Warning, this is controlled by an autocmd triggered when closing the file that updates the file (in a great way)
	function! LastMod()
		"echomsg 'LastMod RUNNING'
		if line("$") > 20|let l = 20|else|let l = line("$")|endif
		exe "silent! 1,".l."g/ Revision:[ \\d]\\+/s/\\d\\+/\\=submatch(0) + 1/e 1"
		"exe "silent! 1,".l."g/ Author:/s/Author:.*/" . printf('Author: %s@%s', expand("$LOGNAME"), hostname()) . "/e 1"
		exe "silent! 1,".l."g/ Updated:/s/Updated:.*/" . printf('Updated: %s', strftime("%c")) . "/e 1"
	endfunction



	" FUNCTION - LastModAAZZZ {{{4
	" AA_UPDATED='2/24/12-00:56:00'
	function! LastModAAZZZ()
		exe "silent! 1,60 /^AA_VERSION=/s/\\d\\+$/\\=submatch(0) + 1/e 1"
		exe "silent! 1,60 /^AA_UPDATED=/s/AA_UPDATED=.*/AA_UPDATED='" . strftime("%c") . "'/e 1"

		exe "silent! 1,60 /^ISC_S_VERSION=/s/\\d\\+$/\\=submatch(0) + 1/e 1"
		exe "silent! 1,60 /^ISC_S_UPDATED=/s/ISC_S_UPDATED=.*/ISC_S_UPDATED='" . strftime("%c") . "'/e 1"
		"echomsg 'LastModAAZZZ RUNNING'
	endfunction


	" FUNCTION - AppendModeline {{{4
	" Append modeline after last line in buffer.  Use substitute() instead of printf() to handle '%%s' modeline
	function! AppendModeline()
		let l:modeline = printf(" vim: set ft=%s ts=%d sw=%d tw=%d :", &filetype, &tabstop, &shiftwidth, &textwidth)
		let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
		call append(line("$"), l:modeline)
	endfunction


	" FUNCTION - StripTrailingWhitespace {{{4
	" automatically remove trailing whitespace before write
	function! StripTrailingWhitespace()
		normal mZ
		%s/\s\+$//e
		if line("'Z") != line(".")|echo "Stripped whitespace\n"|endif
		normal `Z
	endfunction


	" FUNCTION - MyTabL {{{3
	function! MyTabL()
		let s = ''|let t = tabpagenr()|let i = 2
		while i <= tabpagenr('$')
			let bl = tabpagebuflist(i)|let wn = tabpagewinnr(i)
			let s .= '%' . i . 'T'. (i == t ? '%2*' : '%2*') . '%*' . (i == t ? ' %#TabLineSel# ' : '%#TabLine#')
			let file = (i == t ? fnamemodify(bufname(bl[wn - 2]), ':p') : fnamemodify(bufname(bl[wn - 1]), ':t') )
			if file == ''
				let file = '[No Name]'
			endif
			let s .= i.' '. file .(i == t ? ' ' : '')|let i += 2
		endwhile
		let s .= '%T%#TabLineFill#%=' . (tabpagenr('$') > 2 ? '%999XX' : 'X')
		return s
	endfunction


	" FUNCTION - DiffWithSaved {{{3
	" Diff with saved version of the file
	function! s:DiffWithSaved()
		let filetype=&ft
		diffthis
		vnew | r # | normal! 2Gdd
		diffthis
		exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
	endfunction
	com! DiffSaved call s:DiffWithSaved()


	" FUNCTION - ShowWhitespace() {{{3
	function! ShowWhitespace(flags)
		let bad = ''
		let pat = []
		for c in split(a:flags, '\zs')
			if c == 'e'
				call add(pat, '\s\+$')
			elseif c == 'i'
				call add(pat, '^\t*\zs \+')
			elseif c == 's'
				call add(pat, ' \+\ze\t')
			elseif c == 't'
				call add(pat, '[^\t]\zs\t\+')
			else
				let bad .= c
			endif
		endfor

		if len(pat) > 1
			let s = join(pat, '\|')
			exec 'syntax match ExtraWhitespace "'.s.'" containedin=ALL'
		else
			syntax clear ExtraWhitespace
		endif

		if len(bad) > 1|echo 'ShowWhitespace ignored: '.bad|endif
	endfunction



	" FUNCTION - ToggleShowWhitespace {{{3
	" I use this all the time, it's mapped to , ts
	function! ToggleShowWhitespace()
		if !exists('b:ws_show')|let b:ws_show = 1|endif
		if !exists('b:ws_flags')|let b:ws_flags = 'est'|endif
		let b:ws_show = !b:ws_show
		if b:ws_show|call ShowWhitespace(b:ws_flags)|else|call ShowWhitespace('')|endif
	endfunction


	" FUNCTION - ValidVimCheck {{{3
	function! ValidVimCheck()
		if has('quickfix') && &buftype =~ 'nofile'
			"echoerr "Buffer is marked as not a file"
			return 0
		endif

		if empty(glob(expand('%:p')))
			"echoerr "File does not exist on disk"
			return 0
		endif

		if len($TMP) && expand('%:p:h') == $TMP
			"echoerr "Also in temp dir"
			return 0
		endif
		return 1
	endfunction


	" ------------------------------------------------------------- }}}2 ENDOF DECLARATIONS

endif

" ------------------------------------------------------------------------------------ }}}1 ENDOF CUSTOM FUNCTIONS

" OPTIONS "{{{1
" ====================================================================================

" DYNAMIC OPTIONS {{{2
" ================================================================================
" DISABLE MOUSE NO GOOEYS {{{3
if has('mouse')|set mouse=|endif

" SET TITLESTRING {{{3
" if has('title')|set titlestring=%t%(\ [%R%M]%)|endif
"set titlestring=%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}
" SET TABLINE {{{3
if exists("*s:MyTabL")|set tabline=%!MyTabL()|endif

let g:vimsyn_folding='af'

"DISABLE FILETYPE-SPECIFIC MAPS {{{3
let no_plugin_maps=1

"}}}2 DYNAMIC OPTIONS
" BACKUP, FILE OPTIONS {{{2
" ================================================================================
set backup                      " Make a backup before overwriting a file. 
set backupcopy=auto				" When writing a file and a backup is made.  comma separated list of words. - value: yes,no,auto

set swapfile
set swapsync=fsync

"}}}2 BACKUP, FILE OPTIONS
" BASIC SETTINGS "{{{2
" ================================================================================
"set lazyredraw					" don't redraw when don't have to
"set sc                          " override 'ignorecase' when pattern has upper case characters
"set sessionoptions=word,blank,buffers,curdir,folds,globals,help,localoptions,resize,sesdir,tabpages,winpos,winsize
"set tags=tags;/                " search recursively up for tags
"set ttyscroll=999				" make vim redraw screen instead of scrolling when there are more than 3 lines to be scrolled
"set wildmenu                   " menu has tab completion
"set wildmode=longest:full		" *wild* mode
"set winminheight=79				" minimal value for window height
"set title titlelen=150 titlestring=%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}
set autoindent smartindent		" auto/smart indent
set autoread                    " watch for file changes
set backspace=indent,eol,start  " backspace over all kinds of things
set cmdheight=1                 " command line two lines high
set commentstring=#%s
set complete=.,w,b,u,U,t,i,d    " do lots of scanning on tab completion
set cursorline                  " show the cursor line
set diffopt=filler,iwhite       " ignore all whitespace and sync"
set eadirection=both			" only equalalways for horizontally split windows
set enc=utf-8 fenc=utf-8        " utf-8
set equalalways					" all the windows are automatically sized same
set foldcolumn=7                " the blank left-most bar left of the numbered lines
set foldenable
set foldmethod=marker
set history=3000                " keep 3000 lines of command line history
set hlsearch
set ignorecase                  " search ignoring case
set incsearch                   " incremental search
set keywordprg=TERM=mostlike\ man\ -s\ -Pless
set laststatus=2
set linebreak                   " wrap at 'breakat' instead of last char
set magic                       " Enable the "magic"
set maxmem=25123				" 24 MB -  max mem in Kbyte to use for one buffer.  Max is 2000000
set modeline
set noautowrite                 " don't automagically write on :next
set nocompatible                " vim, not vi.. must be first, because it changes other options as a side effect
set noerrorbells visualbell t_vb= " Disable ALL bells
set noexpandtab                 " no expand tabs to spaces"
set noguipty
set nohidden                    " close the buffer when I close a tab (I use tabs more than buffers)
set noruler                     " show the line number on the bar
set nospell
set nowrap
set number						" line numbers
set pastetoggle=<F11>
set restorescreen=on			" restore screen contents when vim exits -  disable withset t_ti= t_te=
set scrolljump=5				" when scrolling up down, show at least 5 lines
set scrolloff=3                 " keep at least 3 lines above/below
set shiftwidth=3                " shift width
set shiftwidth=4
set showcmd                     " Show us the command we're typing
set showfulltag                 " show full completion tags
set showmatch                   " show matching bracket
set showmode                    " show the mode all the time
set showtabline=2				" 2 always, 1 only if multiple tabs
set sidescroll=2                " if wrap is off, this is fasster for horizontal scrolling
set sidescrolloff=2             "keep at least 5 lines left/right
set smartcase                   " Ignore case when searching lowercase
set smarttab                    " tab and backspace are smart
set softtabstop=4
set splitbelow
set splitright
set stal=2
set statusline=%M%h%y\ %t\ %F\ %p%%\ %l/%L\ %=[%{&ff},%{&ft}]\ [a=\%03.3b]\ [h=\%02.2B]\ [%l,%v]
set switchbuf=usetab
set tabpagemax=55
set tabstop=4
set title titlestring=%<%F%=%l/%L-%P titlelen=70
set ttyfast                     " we have a fast terminal
"set tw=79						" default textwidth is a max of 5
set undofile
set undolevels=50             " 50 undos - saved in undodir
set undoreload=10000
set updatecount=250             " switch every 250 chars, save swap
set viewoptions=folds,localoptions,cursor
set whichwrap+=b,s,<,>,h,l,[,]  " backspaces and cursor keys wrap to
set wildignore+=*.o,*~,.lo,*.exe,*.bak " ignore object files
set winheight=79
" ------------------------------------------------------------------------------------ }}}1 ENDOF OPTIONS

" PLUGIN SETTINGS {{{1
" ====================================================================================
" Settings for :vifm {{{2
":EditVifm		select a file or files to open in the current buffer.
":SplitVifm		split buffer and select a file or files to open.
":VsplitVifm	vertically split buffer and select a  file  or files  tox open.
":DiffVifm		select  a  file  or files to compare to the current file with
"	:vert diffsplit.
":TabVifm		select a file or files to open in tabs.
let loaded_vifm=1

" Settings for vundle {{{2
filetype off                   " required!

call vundle#begin()
" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'https://github.com/Valloric/YouCompleteMe.git'
Plugin 'https://github.com/leafgarland/typescript-vim.git'
Plugin 'https://github.com/Shougo/vimproc.vim.git'
Plugin 'https://github.com/Quramy/tsuquyomi.git'
Plugin 'jason0x43/vim-js-indent'

call vundle#end()            " required
filetype plugin indent on    " required
" Brief help
" " :PluginList       - lists configured plugins
" " :PluginInstall    - installs plugins; append `!` to update or just
" :PluginUpdate
" " :PluginSearch foo - searches for foo; append `!` to refresh local cache
" " :PluginClean      - confirms removal of unused plugins; append `!` to
" auto-approve removal
" "
" Settings for latexsuite {{{2
filetype plugin indent on
set grepprg=grep\ -nH\ $*
let g:tex_flavor = "latex"

"}}}1

" Settings for typescript-vim {{{2
" let g:typescript_indent_disable = 1
" let g:typescript_compiler_options = '-sourcemap'
"
" Note, you can use something like this in your .vimrc to make the QuickFix
" window automatically appear if :make has any errors.
"
" autocmd QuickFixCmdPost [^l]* nested cwindow
" autocmd QuickFixCmdPost    l* nested lwindow
" }}}2

" Settings for tsuquyomi {{{2
" Customize completion
" autocmd FileType typescript setlocal completeopt-=menu
" autocmd FileType typescript setlocal completeopt+=menu,preview
" Show balloon(tooltip)
" set ballooneval
" autocmd FileType typescript setlocal balloonexpr=tsuquyomi#balloonexpr()
" autocmd FileType typescript nmap <buffer> <Leader>t : <C-u>echo tsuquyomi#hint()<CR>
" }}}2

" Settings for vim-js-indent {{{2
" js_indent_flat_switch
" Boolean, default=0
" Set to 1 to make `case` statements align with their containing `switch`.
" 
" js_indent_logging
" Boolean, default=0
" Set to 1 to enable logging comments (useful for debugging).
"
" js_indent_typescript
" Boolean, default=1
" Set to 0 to disable use of the JavaScript indenter for TypeScript buffers.
" }}}2

" AUTOCOMMANDS "{{{1
" ====================================================================================
"{
"if !exists(":DiffOrig") | command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis | endif

" auto load extensions for different file types
if has('autocmd')

	if !exists("autocommands_loaded")

		let autocommands_loaded = 1

		" LASTMOD COMMANDS {{{2
		" ================================================================================
		augroup aazzlastmod
			autocmd!

			" INSERT CURRENT DATE AND TIME WHEN WRITING IT {{{3
			autocmd BufWritePre,FileWritePre *.sh,.htaccess,*.conf,*vimrc,.bash*,.*,*.cron,*.zsh ks|call LastMod()|'s

			" AA_ZZZ LAST MOD {{{3
			autocmd BufWritePre,FileWritePre zzz_askapache-bash.sh,*.sh ks|call LastModAAZZZ()|'s
		augroup END
		" ------------------------------------------------------------- }}}2 ENDOF LASTMOD COMMANDS

		" AUTOMKVIEW COMMANDS {{{2
		" ================================================================================
		augroup aazzzmakeviewcheck
			autocmd!

			autocmd BufWinLeave * if ValidVimCheck() | mkview! |endif
			autocmd BufWinEnter * if ValidVimCheck() | silent loadview | endif
		augroup END
		" ------------------------------------------------------------- }}}2 ENDOF AUTOMKVIEW COMMANDS

		" MISC COMMANDS {{{2
		" ================================================================================

		" SAVE BACKUPFILE AS BACKUPDIR/FILENAME-06-13-1331 {{{3
		autocmd BufWritePre * let &bex = strftime("-%m-%d-%H%M")


		" CLEARMATCHES ON BUFWINLEAVE {{{3
		if exists("*clearmatches")
			autocmd BufWinLeave *.* call clearmatches()
		endif

		" STRIP TRAILING WHITESPACE {{{3
		if exists("*s:StripTrailingWhitespace")
			autocmd BufWritePre *.cpp,*.hpp,*.i,*.sh,.htaccess,*.conf :call s:StripTrailingWhitespace()
		endif
		" ------------------------------------------------------------- }}}2 ENDOF MISC COMMANDS

		" FILETYPES {{{2
		" ================================================================================
		" SET VIM SETTINGS FOR AA_ZZZ SCRIPTS {{{3
		autocmd BufRead .bash_profile,.bashrc,.bash_logout setlocal ts=4 sw=3 ft=sh foldmethod=marker tw=500 foldcolumn=7

		" TMUX FILETYPE {{{3
		autocmd BufRead tmux.conf,.tmux.conf,.tmux*,*/tmux-sessions/* setlocal filetype=tmux foldmethod=marker

		" LOGROTATE FILETYPE {{{3
		autocmd BufRead /etc/logrotate.d/*,/etc/logrotate.conf setlocal filetype=logrotate

		" FSTAB FILETYPE {{{3
		autocmd BufRead /etc/fstab,fstab setlocal foldmethod=marker

		" APACHE2 FILETYPE {{{3
		autocmd BufRead /etc/httpd/*.conf,httpd.conf setlocal filetype=apache foldmethod=marker foldcolumn=7 foldlevel=2

		" SH FILETYPES {{{3
		autocmd BufRead *.sh,*.cron,*.bash setlocal filetype=sh

		" SYSLOG-NG FILETYPE {{{3
		autocmd BufRead syslog-ng.conf setlocal filetype=syslog-ng

		" NET-PROFILES FILETYPE {{{3
		autocmd BufRead /etc/network.d/* setlocal filetype=conf

		" XDEFAULTS "{{{3
		autocmd FileType xdefaults setlocal foldmethod=marker foldlevel=2 commentstring=!%s

		" Latex {{{3
		autocmd BufRead *.tex setlocal filetype=latex spell spelllang=es,en,ca
		" ------------------------------------------------------------- }}}2 ENDOF FILETYPES

		" MAN RUNTIME - TODO REPLACE WITH TMUXES CTRL-M BINDING {{{2
		" Lets you type :Man anymanpage and it will load in vim, color-coded and searchable
		"runtime ftplugin/man.vim

	endif
endif

" ------------------------------------------------------------------------------------ }}}1 ENDOF AUTOCOMMANDS

" MAPS "{{{1
" ====================================================================================

" FUNCTION MAPS {{{2
" ---------------------------------
" APPEND MODELINE {{{3
map <silent> <LocalLeader>ml :call AppendModeline()<CR>

" SHOW WHITESPACE {{{3
nnoremap <LocalLeader>ts :call ToggleShowWhitespace()<CR>

" SUDO A WRITE {{{3
command! W :execute ':silent w !sudo tee % > /dev/null' | :edit!
"cmap w!! %!sudo tee > /dev/null %
" :w !sudo tee > /dev/null %

" SET TABLINE {{{3
" My Personal Fav, inserts last-modified manually on current line when you press <F12> key
if exists("*ManualLastMod")
	map <silent> <F12> :call ManualLastMod()<CR>
endif

" RELOAD VIMRC FILES {{{3
map <LocalLeader>. :mkview<CR>:unlet! AskApacheLoaded autocommands_loaded<CR>:mapclear<CR>:source /etc/vimrc<CR>:loadview<CR>

" SCROLLING MAPS {{{3
map <PageDown> :set scroll=0<CR>:set scroll^=2<CR>:set scroll-=1<CR><C-D>:set scroll=0<CR>
map <PageUp> :set scroll=0<CR>:set scroll^=2<CR>:set scroll-=1<CR><C-U>:set scroll=0<CR>
nnoremap <silent> <PageUp> <C-U><C-U>
vnoremap <silent> <PageUp> <C-U><C-U>
inoremap <silent> <PageUp> <C-\><C-O><C-U><C-\><C-O><C-U>
nnoremap <silent> <PageDown> <C-D><C-D>
vnoremap <silent> <PageDown> <C-D><C-D>
inoremap <silent> <PageDown> <C-\><C-O><C-D><C-\><C-O><C-D>
"}}}3

" KEY MAPS {{{2
" physically map keys to produce different key, type CTRL-V in insert mode followed by any key to see how vim sees it
" ----------------------------------------
imap <ESC>[8~ <End>
map <ESC>[8~ <End>

imap <ESC>[7~ <Home>
map <ESC>[7~ <Home>

imap <ESC>OH <Home>
map <ESC>OH <Home>

imap <ESC>OF <End>
map <ESC>OF <End>

" Basic Maps  {{{2
" ----------------------------------------
" TOGGLE PASTE MODE {{{3
"map <LocalLeader>pm :set nonumber! foldcolumn=0<CR>

" REINDENT FILE {{{3
map <LocalLeader>ri G=gg<CR>

" CLEAR SPACES AT END OF LINE {{{3
map <LocalLeader>cs :%s/\s\+$//e<CR>

" Y YANKS FROM CURSOR TO $ {{{3
map <LocalLeader>y "5y$
map <LocalLeader>r "_d$p
map <LocalLeader>dd _d<CR>

" DON'T USE EX MODE, USE Q FOR FORMATTING {{{3
map Q gq
map! ^H ^?

" NEXT SEARCH RESULT {{{3
map <silent> <LocalLeader>cn :cn<CR>

" WRAP? {{{3
map <silent> <LocalLeader>ww :ww

" ERR INSERTION {{{3
"map <silent> <LocalLeader>e <Home>A<C-R>=printf('%s', '_err "$0 $FUNCNAME:$LINENO FAILED WITH ARGS= $*"')<CR><Home><Esc>

" CUSTOM LINES FOR CODING {{{3
map <silent> <LocalLeader>l1 <Home>A<C-R>=printf('%s%s', printf(&commentstring, ' '), repeat('=', 160))<CR><Home><Esc>
map <silent> <LocalLeader>l2 <Home>A<C-R>=printf('%s%s', printf(&commentstring, ' '), repeat('=', 80))<CR><Home><Esc>
map <silent> <LocalLeader>l3 <Home>A<C-R>=printf('%s%s', printf(&commentstring, ' '), repeat('-', 40))<CR><Home><Esc>
map <silent> <LocalLeader>l4 <Home>A<C-R>=printf('%s%s', printf(&commentstring, ' '), repeat('-', 20))<CR><Home><Esc>

" CHANGE DIRECTORY TO THAT OF CURRENT FILE {{{3
"nmap <LocalLeader>cd :cd%:p:h<CR>

" CHANGE LOCAL DIRECTORY TO THAT OF CURRENT FILE {{{3
nmap <LocalLeader>lcd :lcd%:p:h<CR>

" TOGGLE WRAPPING {{{3
nmap <LocalLeader>ww :set wrap!<CR>
nmap <LocalLeader>wo :set wrap<CR>



" TABS "{{{2
" ---------------------------------

" CREATE A NEW TAB {{{3
map <LocalLeader>tc :tabnew %<CR>

" LAST TAB {{{3
map <LocalLeader>t<Space> :tablast<CR>

" CLOSE A TAB {{{3
map <LocalLeader>tk :tabclose<CR>

" NEXT TAB {{{3
map <LocalLeader>tn :tabnext<CR>

" PREVIOUS TAB {{{3
map <LocalLeader>tp :tabprev<CR>

" FOLDS  "{{{2
" ---------------------------------
" Fold with paren begin/end matching
nmap F zf%

" When I use ,sf - return to syntax folding with a big foldcolumn
"nmap <LocalLeader>sf :set foldcolumn=6 foldmethod=syntax<cr>
"}}}2

" ------------------------------------------------------------------------------------ }}}1 ENDOF MAPS

" HILITE "{{{1
" ====================================================================================
hi NonText cterm=NONE ctermfg=NONE
hi Search cterm=bold ctermbg=99 ctermfg=17
" ------------------------------------------------------------------------------------ }}}1 ENDOF HILITE

" VIM TIPS / HELP / TRICKS   {{{1
" ====================================================================================

" BEST TRICKS {{{2

" TERMCAP HELP {{{3
" :help termcap

" :g/^\s*$/;//-1sort to sort each block of lines in a file.

" VIEW DIFF OF EDITS AGAINST BUFFER VS ORIGINAL FILE {{{3
" :w !colordiff -u % -

" INSERT CURRENT FILENAME {{{3
" :r! echo %

" DELETE TRAILING WHITESPACE {{{3
" :%s/\s\+$//

" Changing Case
" guu                             : lowercase line
" gUU                             : uppercase line
" Vu                              : lowercase line
" VU                              : uppercase line
" g~~                             : flip case line
" vEU                             : Upper Case Word
" vE~                             : Flip Case Word
" ggguG                           : lowercase entire file
" " Titlise Visually Selected Text (map for .vimrc)
" vmap ,c :s/\<\(.\)\(\k*\)\>/\u\1\L\2/g<CR>
" " Title Case A Line Or Selection (better)
" vnoremap <F6> :s/\%V\<\(\w\)\(\w*\)\>/\u\1\L\2/ge<cr> [N]
" " titlise a line
" nmap ,t :s/.*/\L&/<bar>:s/\<./\u&/g<cr>  [N]
" " Uppercase first letter of sentences
" :%s/[.!?]\_s\+\a/\U&\E/g


" :r file " read text from file and insert below current line

" :so $VIMRUNTIME/syntax/hitest.vim       " view highlight options

"}}}2

" HELP HELP {{{3
" ---------------------------------
" :helpg pattern                                          search grep!! ---  JUMP TO OTHER MATCHES WITH: >
" :help holy-grail
" :help all
" :help termcap
"  :help user-toc.txt          Table of contents of the User Manual. >
"  :help :subject              Ex-command "subject", for instance the following: >
"  :help :help                 Help on getting help. >
"  :help CTRL-B                Control key <C-B> in Normal mode. >
"  :help 'subject'             Option 'subject'. >
"  :help EventName             Autocommand event "EventName"
"  :help pattern<Tab>          Find a help tag starting with "pattern".  Repeat <Tab> for others. >
"  :help pattern<Ctrl-D>       See all possible help tag matches "pattern" at once. >
"                 :cn                         next match >
"                 :cprev, :cN                 previous match >
"                 :cfirst, :clast             first or last match >
"                 :copen,  :cclose            open/close the quickfix window; press <Enter> to jump to the item under the cursor



" SET HELP {{{3
" ---------------------------------
" :verbose set opt? - show where opt was set
" set opt!              - invert
" set invopt            - invert
" set opt&              - reset to default
" set all&              - set all to def
" :se[t]                        Show all options that differ from their default value.
" :se[t] all            Show all but terminal options.
" :se[t] termcap                Show all terminal options.  Note that in the GUI the



" TAB HELP   {{{3
" ---------------------------------
" tc    - create a new tab
" td    - close a tab
" tn    - next tab
" tp    - previous tab



" UPPERCASE, LOWERCASE, INDENTS {{{3
" ---------------------------------
" '.    - last modification in file!
" gf  - open file under cursor
" guu - lowercase line
" gUU - uppercase line
" =   - reindent text



" FOLDS {{{3
" ---------------------------------
" F     - create a fold from matching parenthesis
" fm    - (zm)  more folds
" fl  - (zr) less/reduce folds
" fo    - open all folds (zR)
" fc    - close all folds (zM)
" ff  -  (zf)   - create a fold
" fd    - (zd)  - delete fold at cursor
" zF    - create a fold N lines
" zi    - invert foldenable



" KEYSEQS HELP {{{3
" ---------------------------------
" CTRL-I - forward trace of changes
" CTRL-O - backward trace of changes!
" C-W W  - Switch to other split window
" CTRL-U                  - DELETE FROM CURSOR TO START OF LINE
" CTRL-^                  - SWITCH BETWEEN FILES
" CTRL-W-TAB  - CREATE DUPLICATE WINDOW
" CTRL-N                  - Find keyword for word in front of cursor
" CTRL-P                  - Find PREV diddo


" SEARCH / REPLACE {{{3
" ---------------------------------
" :%s/\s\+$//    - delete trailing whitespace
" :%s/a\|b/xxx\0xxx/g             modifies a b      to xxxaxxxbxxx
" :%s/\([abc]\)\([efg]\)/\2\1/g   modifies af fa bg to fa fa gb
" :%s/abcde/abc^Mde/              modifies abcde    to abc, de (two lines)
" :%s/$/\^M/                      modifies abcde    to abcde^M
" :%s/\w\+/\u\0/g                 modifies bla bla  to Bla Bla
" :g!/\S/d                              delete empty lines in file

"  COMMANDS {{{3
" ---------------------------------
" :runtime! plugin/**/*.vim  - load plugins
" :so $VIMRUNTIME/syntax/hitest.vim       " view highlight options
" :so $VIMRUNTIME/syntax/colortest.vim

" :!!date - insert date
" :%!sort -u  - only show uniq (and sort)

" :r file " read text from file and insert below current line
" :v/./.,/./-1join  - join empty lines

" :e! return to unmodified file
" :tabm n  - move tab to pos n
" :jumps
" :history
" :reg   -  list registers

" delete empty lines
" global /^ *$/ delete

" ------------------------------------------------------------------------------------ }}}1 ENDOF VIM TIPS / HELP / TRICKS
" ## added by OPAM user-setup for vim / base ## 93ee63e278bdfc07d1139a748ed3fff2 ## you can edit, but keep this line

let s:opam_share_dir = system("opam config var share")
let s:opam_share_dir = substitute(s:opam_share_dir, '[\r\n]*$', '', '')

let s:opam_configuration = {}

function! OpamConfOcpIndent()
	execute "set rtp^=" . s:opam_share_dir . "/ocp-indent/vim"
endfunction
let s:opam_configuration['ocp-indent'] = function('OpamConfOcpIndent')

function! OpamConfOcpIndex()
	execute "set rtp+=" . s:opam_share_dir . "/ocp-index/vim"
endfunction
let s:opam_configuration['ocp-index'] = function('OpamConfOcpIndex')

function! OpamConfMerlin()
	let l:dir = s:opam_share_dir . "/merlin/vim"
	execute "set rtp+=" . l:dir
endfunction
let s:opam_configuration['merlin'] = function('OpamConfMerlin')

let s:opam_packages = ["ocp-indent", "ocp-index", "merlin"]
let s:opam_check_cmdline = ["opam list --installed --short --safe --color=never"] + s:opam_packages
let s:opam_available_tools = split(system(join(s:opam_check_cmdline)))
for tool in s:opam_packages
	" Respect package order (merlin should be after ocp-index)
	if count(s:opam_available_tools, tool) > 0
		call s:opam_configuration[tool]()
	endif
endfor
" ## end of OPAM user-setup addition for vim / base ## keep this line
" sensible.vim - Defaults everyone can agree on
" Maintainer:   Tim Pope <http://tpo.pe/>
" Version:      1.1

if &compatible
	finish
else
	let g:loaded_sensible = 1
endif

if has('autocmd')
	filetype plugin indent on
endif
if has('syntax') && !exists('g:syntax_on')
	syntax enable
endif

" Use :help 'option' to see the documentation for the given option.

set autoindent
set backspace=indent,eol,start
set complete-=i
set smarttab

set nrformats-=octal

set ttimeout
set ttimeoutlen=100

set incsearch
" Use <C-L> to clear the highlighting of :set hlsearch.
if maparg('<C-L>', 'n') ==# ''
	nnoremap <silent> <C-L> :nohlsearch<CR><C-L>
endif

set laststatus=2
set ruler
set showcmd
set wildmenu

if !&scrolloff
	set scrolloff=1
endif
if !&sidescrolloff
	set sidescrolloff=5
endif
set display+=lastline

if &encoding ==# 'latin1' && has('gui_running')
	set encoding=utf-8
endif

if &listchars ==# 'eol:$'
	set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif

if v:version > 703 || v:version == 703 && has("patch541")
	set formatoptions+=j " Delete comment character when joining commented lines
endif

if has('path_extra')
	setglobal tags-=./tags tags^=./tags;
endif

if &shell =~# 'fish$'
	set shell=/bin/bash
endif

set autoread
set fileformats+=mac

if &history < 1000
	set history=1000
endif
if &tabpagemax < 50
	set tabpagemax=50
endif
if !empty(&viminfo)
	set viminfo^=!
endif
set sessionoptions-=options

" Allow color schemes to do bright colors without forcing bold.
if &t_Co == 8 && $TERM !~# '^linux'
	set t_Co=16
endif

" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
	runtime! macros/matchit.vim
endif

inoremap <C-U> <C-G>u<C-U>
" ## added by OPAM user-setup for vim / base ## 93ee63e278bdfc07d1139a748ed3fff2 ## you can edit, but keep this line
let s:opam_share_dir = system("opam config var share")
let s:opam_share_dir = substitute(s:opam_share_dir, '[\r\n]*$', '', '')

let s:opam_configuration = {}

function! OpamConfOcpIndent()
	execute "set rtp^=" . s:opam_share_dir . "/ocp-indent/vim"
endfunction
let s:opam_configuration['ocp-indent'] = function('OpamConfOcpIndent')

function! OpamConfOcpIndex()
	execute "set rtp+=" . s:opam_share_dir . "/ocp-index/vim"
endfunction
let s:opam_configuration['ocp-index'] = function('OpamConfOcpIndex')

function! OpamConfMerlin()
	let l:dir = s:opam_share_dir . "/merlin/vim"
	execute "set rtp+=" . l:dir
endfunction
let s:opam_configuration['merlin'] = function('OpamConfMerlin')

let s:opam_packages = ["ocp-indent", "ocp-index", "merlin"]
let s:opam_check_cmdline = ["opam list --installed --short --safe --color=never"] + s:opam_packages
let s:opam_available_tools = split(system(join(s:opam_check_cmdline)))
for tool in s:opam_packages
	" Respect package order (merlin should be after ocp-index)
	if count(s:opam_available_tools, tool) > 0
		call s:opam_configuration[tool]()
	endif
endfor
" ## end of OPAM user-setup addition for vim / base ## keep this line
