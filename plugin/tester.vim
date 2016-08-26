" This plugin is intended to make switching between a file and it's unit test
" file easier. 
"
" The interface for this plugin is stored in the g:tester object. This is
" intended to be 'read only'.
"
" CONFIGURATION: 
" These functions can be used to set this plugin's configuration:
"
" g:tester.FileInfo()
"   Explanation:
"       configures the structure of a testfile's name for a given filetype.
"   Parameters:
"       a dictionary where the keys are filetypes and the values are
"       dictionaries with information about the test modules for that file
"       type. Currently supported keys:
"           - 'suffix'
"       ex:
"           {
"               'perl' : {
"                   '_Test'
"               },
"           }
"
"
" INTERFACE:
" g:tester.OpenFile(window_mode)
"   Explanation:
"       attempts to open the test file paired with the current file (if in a
"       non-test file) or the 'real' file (if in the test file).
"   Parameters:
"       displaymode:
"           optional. defaults to g:tester.default_display_mode
"           allowed:  sp || vs || tabfind
"   ex:
"       nnoremap <leader>t :<c-u>call g:tester.OpenFile(vs)<cr>
"       nnoremap <leader>T :<c-u>call g:tester.OpenFile(sp)<cr>
"

"====================init====================
if ! exists("g:tester")
	let g:tester = {}
endif

if ! exists("s:settings")
	let s:settings = { 
		\'file_type_info' : {
			\'default' : { 
				\'suffix' : '_Test',
			\},
		\}, 
		\'display_mode' : 'sp',
	\}
endif

"====================exposed functions====================
function! g:tester.OpenFile(...)
	let l:file = s:IdentifyFile()
	if filereadable(l:file)
		if (a:0 > 0) && (s:IsValidDisplayMode(a:1))
			let l:display_mode = a:1
		else
			let l:display_mode = s:settings['display_mode']
		endif

		execute l:display_mode . " " . l:file
	else 
		echo "no file found!"
	endif
endfunction

function! g:tester.DisplayMode(display_mode)
	if s:IsValidDisplayMode(a:display_mode)
		let s:settings['display_mode'] = a:display_mode
	endif
endfunction

function! g:tester.FileInfo(file_info) 
	for file_type in keys(a:file_info)
		if ! empty(file_type)
			for key in keys(file_type)
				" verify default is supported
				if has_key(s:settings['file_type_info']['default'], key)
					let s:settings['file_type_info']['file_type'][key] = file_type[key]
				endif
			endfor
		endif
	endfor
endfunction

"====================utility====================
" This function is a set method for s:settings.
" Settings supported:
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

" if file_type not found, defaults.
" if key not found, returns empty string
function! s:Suffix(file_type)
	if has_key(s:settings['file_type_info'], a:file_type)
		if has_key(s:settings['file_type_info'][a:file_type], 'suffix')
			return s:settings['file_type_info'][a:file_type]['suffix']
		endif
	else
		return s:settings['file_type_info']['default']['suffix']
	endif
endfunction

function! s:IdentifyFile()
	let l:alternate_file = expand('%:p:h') . '/'
	let l:current_file = expand('%:r')
	let l:suffix = s:Suffix(&filetype)

	" determine if current file is the testfile or the actual file
	if l:current_file =~ l:suffix . '$'
		let l:alternate_file .= substitute(l:current_file, l:suffix, '', '')
	else
		let l:alternate_file .= l:current_file . l:suffix
	endif

	let l:alternate_file .= '.' . expand('%:e')

	return l:alternate_file
endfunction
