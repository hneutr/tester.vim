" ABOUT:
" This plugin is intended to make switching between a file and it's unit test
" file easier. 
"
" The interface for this plugin is stored in the g:tester object. This is
" intended to be 'read only'.
"
" CONFIGURATION: 
" The following functions are available:
" - g:tester.Suffixes(suffixes)
"   - configures the structure of a testfile's name for a given filetype.
"   - default value: { 'default' : '_Test' }
"   - parameters:
"       - suffixes: 
"           - a dictionary where each key is a filetype and each value is a 
"           string indicating the suffix for that filetype. E.G: 
"           { 'perl' : '_Test' }
" - g:tester.OpenFile(windowmode)
"   - attempts to open the test file paired with the current file (if in a
"   non-test file) or the 'real' file (if in the test file).
"   - parameters:
"       - displaymode:
"           - optional. defaults to g:tester.default_display_mode
"           - sp || vs || tabfind
"   - example usage:
"       nnoremap <leader>t :<c-u>call g:tester.OpenFile(vs)<cr>
"       nnoremap <leader>T :<c-u>call g:tester.OpenFile(sp)<cr>
"
" TODOS: 
" - make the substitute call in g:tester.OpenPairedFile only operate on the
"   final part of the filepath.

if ! exists("g:tester")
	let g:tester = {}
endif

if ! exists("s:default_display_mode")
	let s:default_display_mode = 'sp'
endif

if ! exists("s:test_file_suffixes")
	let s:test_file_suffixes = { 'default' : '_Test' }
endif

function! s:IsValidDisplayMode(display_mode)
	if (a:display_mode ==# 'sp') || (a:display_mode ==# 'vs') || (a:display_mode ==# 'tabfind')
		return 1
	else
		return 0
	endif
endfunction

function! g:tester.DisplayMode(display_mode)
	if s:IsValidDisplayMode(a:display_mode)
		let s:default_display_mode = a:display_mode
	endif
endfunction

function! g:tester.Suffixes(suffixes) 
	if ! empty(a:suffixes)
		for key in keys(a:suffixes)
			let s:test_file_suffixes.key = get(a:suffixes, key)
		endfor
	endif
endfunction

function! s:IdentifyFile()
	let l:path = expand('%:p:h')
	let l:current_file = expand('%:r')
	let l:extension = expand('%:e')

	let l:suffix = get(s:test_file_suffixes, 'default')
	if has_key(s:test_file_suffixes, &filetype)
		let l:suffix = get(s:test_file_suffixes, &filetype)
	else

	let l:alternate_file = l:path . '/'

	" determine if current file is the testfile or the actual file
	if l:current_file =~ l:suffix . '$'
		let l:alternate_file .= substitute(l:current_file, l:suffix, '', '')
	else
		let l:alternate_file .= l:current_file . l:suffix
	endif

	let l:alternate_file .= '.' . l:extension

	return l:alternate_file
endfunction

function! g:tester.OpenFile(...)
	let l:display_mode = s:default_display_mode
	if (a:0 > 0) && (s:IsValidDisplayMode(a:1))
		let l:display_mode = a:1
	endif

	let l:file = s:IdentifyFile()

	" open the file if it is readable
	if filereadable(l:file)
		execute l:display_mode . " " . l:file
	else 
		echo "no file found!"
	endif
endfunction
