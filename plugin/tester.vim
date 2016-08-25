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

if ! exists("s:settings")
	let s:settings = { 'default' : { 'suffix' : '_Test' }, }
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

function! g:tester.Settings(settings) 
	if ! empty(a:settings)
		for file_type in keys(a:settings)
			if ! empty(file_type)
				for key in keys(file_type)
					let s:settings.file_type.key = get(file_type, key)
				endfor
			endif
		endfor
	endif
endfunction

" if file_type not found, defaults.
" if key not found, returns empty string
function! s:GetSetting(file_type, key)
	if has_key(s:settings, a:file_type)
		let l:file_type_settings = get(s:settings, a:file_type)
	else
		let l:file_type_settings = get(s:settings, 'default')
	endif

	if has_key(l:file_type_settings, a:key)
		return get(l:file_type_settings, a:key)
	else
		return ''
	endif
endfunction

function! s:IdentifyFile()
	let l:suffix = s:GetSetting(&filetype, 'suffix')
	let l:current_file = expand('%:r')
	let l:alternate_file = expand('%:p:h') . '/'

	" determine if current file is the testfile or the actual file
	if l:current_file =~ l:suffix . '$'
		let l:alternate_file .= substitute(l:current_file, l:suffix, '', '')
	else
		let l:alternate_file .= l:current_file . l:suffix
	endif

	let l:alternate_file .= '.' . expand('%:e')

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
