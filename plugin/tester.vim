" This plugin is intended to make switching between a file and it's unit test
" file easier. 
"
" The interface for this plugin is stored in the g:tester object. 
"
" CONFIGURATION: 
" These variables can be set to control this plugin's configuration:
"
" g:tester.file_info
"   Explanation:
"       A dictionary where the keys are filetypes and the values are
"       dictionaries with information about the test modules for that file
"       type. 
"   Example Settings:
"       {
"           'perl' : {
"               'suffix' : '_Test',
"           },
"       },
"   Currently Supported Keys:
"       - 'suffix'
"
" g:tester.display_mode
"   Explanation:
"       The default display mode for the g:tester.OpenPairedFile method.
"   Example Settings:
"       a string. One of:
"           'sp' || 'vs' || 'tabfind'
"
" INTERFACE:
" g:tester.OpenPairedFile(...)
"   Explanation:
"       attempts to open the test file paired with the current file (if in a
"       non-test file) or the 'real' file (if in the test file).
"   Parameters:
"       displaymode:
"           optional. defaults to 'sp'
"           allowed:  'sp' || 'vs' || 'tabfind'
"   Example Bindings:
"       nnoremap <leader>t :<c-u>call g:tester.OpenPairedFile(vs)<cr>
"       nnoremap <leader>T :<c-u>call g:tester.OpenPairedFile(sp)<cr>

"====================init====================
if ! exists("g:tester")
	let g:tester = {}
endif

function! s:GetDisplayMode()
	if ! exists("g:tester.display_mode")
		let g:tester.display_mode = 'sp'
	endif
	return g:tester.display_mode
endfunction

function! s:GetFileTypeSetting(file_type, setting)
	if ! exists("g:tester.file_types")
		let g:tester.file_types = {}
	endif

	if ! has_key(g:tester.file_types, a:file_type)
		let g:tester.file_types[ a:file_type ] = {}
	endif

	if ! has_key(g:tester.file_types[ a:file_type ], a:setting)
		if a:setting ==# 'suffix'
			let g:tester.file_types[ a:file_type ][ a:setting ] = '_Test'
		endif
	endif

	return g:tester.file_types[ a:file_type ][ a:setting ]
endfunction

"====================exposed functions====================
function! g:tester.OpenPairedFile(...)
	let l:file = s:IdentifyFile()

	if filereadable(l:file)
		let l:display_mode = s:GetDisplayMode()

		if (a:0 > 0) && (s:IsValidDisplayMode(a:1))
			let l:display_mode = a:1
		endif

		execute l:display_mode . " " . l:file
	else 
		echo "no file found!"
	endif
endfunction

"====================utility====================
function! s:IsValidDisplayMode(display_mode)
	let l:valid_display_modes = [
		\'sp',
		\'vs',
		\'tabfind',
	\]

	for valid_display_mode in l:valid_display_modes
		if valid_display_mode ==# a:display_mode
			return 1
		endif
	endfor

	return 0
endfunction

function! s:IdentifyFile()
	let l:current_directory = expand('%:p:h') . '/'
	let l:current_file = expand('%:p:t:r')
	let l:suffix = s:GetFileTypeSetting(&filetype, 'suffix')

	" determine if current file is the testfile or the actual file
	let l:alternate_file = l:current_directory
	if l:current_file =~ l:suffix . '$'
		let l:alternate_file .= substitute(l:current_file, l:suffix, '', '')
	else
		let l:alternate_file .= l:current_file . l:suffix
	endif

	let l:alternate_file .= '.' . expand('%:e')

	return l:alternate_file
endfunction
