# tester.vim
A plugin to facilitate switching between a file (the 'primary' file) and its
test file with ease.

Currently only supports switching files based on the filetype of the current
buffer.

# Future:
The following will (hopefully) be developed in the future:

1. Support different types of mappings to/from test files.

    - directory mappings (things in _this_ directory have test files
    in _that_ directory)
    - file to file (_this_ file maps to _that_ file)

2. Scoping of different types of mappings

    - look for a file-to-file mapping first, then a directory 
    mapping, then a language mapping

# License
MIT license
