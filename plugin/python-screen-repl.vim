
""
" Sends one line to screen
function! s:LineToScreen(line)
    exec ':silent! :!screen -x '.g:vim_screen_screenname.' -X stuff "'.a:line.'"'
endfunction

""
" Sends lines to ipython in screen
function! s:LinesToIPython(lines)
    call s:LineToScreen(escape('%cpaste', '%'))
    let joined = join(a:lines, "")
    call s:LineToScreen(escape(l:joined, '^#"!'))
    call s:LineToScreen("--")
endfunction

" Sends lines raw to mysql
function! s:LinesToSql(lines)
    let joined = join(a:lines, "")
    let escaped = escape(l:joined, "`")
    call s:LineToScreen(l:escaped)
endfunction

" Sends lines to screen
function! s:rawLinesToScreen(lines)
    let joined = join(a:lines, "")
    call s:LineToScreen(l:joined)
endfunction

""
" Sends a range of chars or lines to screen.
" In normal mode, the current line is sent.
" In visual mode the selection is sent.
" {mode}: [v, n]
" 
function! s:ReplExecFun(mode) range

    echo a:firstline a:lastline

    if a:mode == 'n'
        " Normal mode, use current line
        let selection = getline('.', '.')
    elseif a:mode == 'v'
        " Visual mode
        if a:firstline == a:lastline
            " Char select
            normal! gv"ay
            let selection = getreg('a', 1, 1)
        else
            " Multiline
            let selection = getline(a:firstline, a:lastline)
        endif
    else
        throw "Supported modes: [n, v]. Invalid mode: " a:mode
    endif

    if &filetype == 'python'
        call s:LinesToIPython(l:selection)
    elseif &filetype == 'python'
        call s:LinesToSql(l:selection)
    else 
        call s:rawLinesToScreen(l:selection)
    endif
endfunction

command! SetupScreenRepl call s:LineToScreen('cd '.expand('%:p:h')) | exec ':redraw!'
" Opens a terminal and starts screen
command! OpenScreenRepl exec ':!$TERMINAL -e screen -DR -S '.g:vim_screen_screenname.' &' | exec ':SetupScreenRepl!'
command! -range -nargs=1 ScreenReplExec <line1>,<line2>call s:ReplExecFun(<f-args>) | exec ':redraw!'

" Settings
let g:vim_screen_screenname = get(g:, 'vim_screen_screenname ', "vim_screen_repl_default")
