
let s:screenname = 'vim_repl'

""
" Sends one line to screen
function! s:LineToScreen(line)
    exec ':silent! :!screen -x '.s:screenname.' -X stuff "'.a:line.'\n"'
endfunction

""
" Sends lines to screen
function! s:LinesToIPython(lines)
    call s:LineToScreen(escape('%cpaste', '%'))
    for line in a:lines
        call s:LineToScreen(escape(l:line, '^#"!'))
    endfor
    call s:LineToScreen("--")
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

    call s:LinesToIPython(l:selection)
endfunction

command! SetupScreenRepl call s:LineToScreen('cd '.expand('%:p:h')) | exec ':redraw!'
" Opens a terminal and starts screen
command! OpenScreenRepl exec ':!$TERMINAL -e screen -DR -S '.s:screenname.' &' | exec ':SetupScreenRepl!'
command! -range -nargs=1 ScreenReplExec <line1>,<line2>call s:ReplExecFun(<f-args>) | exec ':redraw!'

