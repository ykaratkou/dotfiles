augroup filetypedetect
autocmd BufNewFile,BufRead *.yml,*yaml,*.tmpl,*.tpl if search('{{-.\+}}', 'nw') | setlocal filetype=gotmpl | endif
augroup END
