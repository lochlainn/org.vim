" Vim filetype plugin for GNU Emacs' Org mode
" Also adds functionality for tab/shift-tab from
" https://gist.github.com/axvr/19dc08a63d9772df5748d557bc52ec76
" 
" Maintainer:   Alex Vear <av@axvr.io>
" License:      Vim (see `:help license`)
" Location:     ftplugin/org.vim
" Website:      https://github.com/axvr/org.vim
" Last Change:  2020-01-04
"
" Reference Specification: Org mode manual
"   GNU Info: `$ info Org`
"   Web: <https://orgmode.org/manual/index.html>

setlocal commentstring=#%s
setlocal comments=fb:*,fb:-,fb:+,b:#,b:\:
setlocal formatoptions+=ncqlt
let &l:formatlistpat = '^\s*\(\d\+[.)]\|[+-]\)\s\+'

setlocal foldexpr=org#fold_expr()
setlocal foldmethod=expr

let b:org_clean_folds = 1

setlocal foldenable
normal zv

function! s:org_tab_cycle() abort
    let next_state = get(b:, 'org_folding_tab_next_state', 'FOLDED')

    if next_state ==# 'CHILDREN'
        normal zo
        let b:org_folding_tab_next_state = 'SUBTREE'
    elseif next_state ==# 'SUBTREE'
        normal zc
        silent .foldopen!
        let b:org_folding_tab_next_state = 'FOLDED'
    elseif next_state ==# 'FOLDED'
        normal zozc
        silent .foldclose!
        normal zvzc
        let b:org_folding_tab_next_state = 'CHILDREN'
    else
        unlet! b:org_folding_tab_next_state
    endif

    echo next_state
endfunction

function! s:org_shift_tab_cycle() abort
    " NOTE: 'CONTENTS'-like behaviour is not supported by Vim.

    let next_state = get(b:, 'org_folding_shift_tab_next_state', 'OVERVIEW')

    if next_state ==# 'OVERVIEW'
        normal zM
        let b:org_folding_shift_tab_next_state = 'SHOW ALL'
    elseif next_state ==# 'SHOW ALL'
        normal zR
        let b:org_folding_shift_tab_next_state = 'OVERVIEW'
    else
        unlet! b:org_folding_shift_tab_next_state
    endif

    echo next_state
endfunction

nnoremap <buffer> <Tab> :call <SID>org_tab_cycle()<CR>
nnoremap <buffer> <S-Tab> :call <SID>org_shift_tab_cycle()<CR>

augroup OrgFold
  autocmd!
  autocmd CursorMoved <buffer> unlet! b:org_folding_tab_next_state
                                    \ b:org_folding_shift_tab_next_state
augroup END

if org#option('org_clean_folds', 0)
    setlocal foldtext=org#fold_text()
    setlocal fillchars-=fold:-
endif
