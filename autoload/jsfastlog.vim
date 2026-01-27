vim9script

import './stringToColor.vim'

var logModes = {
    'simple': 1,
    'jsonStringify': 2,
    'showVar': 3,
    'funcTimestamp': 4,
    'string': 5,
    'separator': 8,
    'lineNumber': 9,
    'traceCollapsed': 10,
}

def GetSelectionColumns(): dict<number>
    var pos1 = getcharpos('v')[2]
    var pos2 = getcharpos('.')[2]
    return {
        start: min([pos1, pos2]),
        end: max([pos1, pos2]),
    }
enddef

def GetWord(visualmode: string): string
    if (visualmode == 'char' || visualmode == 'line')
        var savedReg = getreg('+')
        execute "normal! `[v`]y"
        var res = getreg('+')
        setreg('+', savedReg)
        return res
    endif

    var sel = GetSelectionColumns()
    # "- 1" because sel indexes start from 1, getline starts from 0
    return getline('.')[sel.start - 1 : sel.end - 1]
enddef

def WQ(s: string): string
    # Wrap with Quotes
    return "\'" .. s .. "\'"
enddef

def MakeInner(logmode: number, word: string): string
    var inner = word
    var escapedWord = escape(word, "'")
    if (logmode ==# logModes.string) # string: 'var' => 'console.log('var');'
        return WQ(escapedWord)
    endif

    if (logmode ==# logModes.jsonStringify) # JSON.stringify: 'var' => 'console.log('var='+JSON.stringify(var));'
        return WQ(escapedWord .. '=') .. " + JSON.stringify(" .. word .. ")"
    endif

    if (logmode ==# logModes.showVar)
        var trimmedword = word->trim()
        if (trimmedword[0] == '{' && trimmedword[trimmedword->len() - 1] == '}')
            return trimmedword
        endif
        if (trimmedword->stridx(', ') > -1)
            return '{ ' .. trimmedword .. ' }'
        endif
        return WQ(escapedWord .. '=') .. ', ' .. trimmedword
    endif

    if (logmode ==# logModes.funcTimestamp)
        var filename = expand('%:t:r')
        if (filename == 'index')
            var filepath = split(expand('%:r'), '/')
            filename = filepath[-2] .. '/' .. filepath[-1]
        endif
        return 'Date.now() % 10000, ' .. WQ(filename .. ':' .. line('.') .. ' ' .. escapedWord)
    endif

    if (logmode ==# logModes.separator)
        return WQ(' ========================================')
    endif

    if (logmode ==# logModes.lineNumber)
        var filename = expand('%:t:r')
        return WQ(filename .. ':' .. line('.'))
    endif

    return inner
enddef

def MakeString(inner: string, wrapIntoTrace: bool = false): string
    var filenameWithExt = expand('%:t')
    var filenameWithoutExt = filenameWithExt[filenameWithExt->len() - (expand('%:e')->len() + 1) : ]
    var folders = expand('%:h')->split('/')
    const color = stringToColor.StringToColor(folders[-1] .. filenameWithoutExt)
    # h - folder
    # t - filename with ext
    var result = 'console.' .. (wrapIntoTrace ? 'groupCollapsed' : 'log') .. '('
    result = result .. "'%c" .. g:js_fastlog_prefix .. "', "
    result = result .. "'background:" .. color .. "', "
    result = result .. inner
    result = result .. ')'

    result = result .. (search(';', 'n') > 0 ? ';' : '')
    return result
enddef

export def JsFastLog(visualmode: string, logmode: number, wrapIntoTrace: bool = false): void
    if (visualmode ==# 'V' || visualmode ==# '')
        normal! O// js-fastlog: sorry, but I work only with charwise selection
        return
    endif

    var word = GetWord(visualmode)

    var wordIsEmpty = match(word, '\v\S') == -1
    if (logmode !=# logModes.separator
         && logmode !=# logModes.lineNumber
         && wordIsEmpty)
        execute "normal! aconsole.log();\<esc>hh"
    else
        put = MakeString(MakeInner(logmode, word), wrapIntoTrace)

        if (logmode ==# logModes.funcTimestamp
            || logmode ==# logModes.separator)
            normal! ==f(l
        else
            :-delete _ | normal! ==f(l
        endif
    endif

    if (wrapIntoTrace)
        execute 'normal oconsole.trace()' .. (search(';', 'n') > 0 ? ';' : '')
        execute 'normal oconsole.groupEnd()' .. (search(';', 'n') > 0 ? ';' : '')
        normal kk
    endif

    # move cursor to end of line -2 columns
    normal! $hh
enddef

export def GetLogModes(): dict<number>
    return logModes
enddef
