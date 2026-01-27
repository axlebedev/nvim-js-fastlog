vim9script

import autoload '../autoload/jsfastlog.vim'


if (exists("g:loaded_js_fastlog") || &cp || v:version < 700)
    finish
endif

g:loaded_js_fastlog = 1

g:js_fastlog_prefix = get(g:, 'js_fastlog_prefix', '')
def JsFastLog_setPrefix(newPrefix: string): void
    g:js_fastlog_prefix = newPrefix
enddef
command! -nargs=1 JsFastLogSetPrefix JsFastLog_setPrefix(<f-args>)

var logModes = jsfastlog.GetLogModes()

export def JsFastLog_simple(visualmode: string): void
    jsfastlog.JsFastLog(visualmode, logModes.simple)
enddef

export def JsFastLog_simple_trace(visualmode: string): void
    jsfastlog.JsFastLog(visualmode, logModes.simple, true)
enddef

export def JsFastLog_JSONstringify(visualmode: string): void
    jsfastlog.JsFastLog(visualmode, logModes.jsonStringify)
enddef

export def JsFastLog_variable(visualmode: string): void
    jsfastlog.JsFastLog(visualmode, logModes.showVar)
enddef

export def JsFastLog_variable_trace(visualmode: string): void
    jsfastlog.JsFastLog(visualmode, logModes.showVar, true)
enddef

export def JsFastLog_function(visualmode: string): void
    jsfastlog.JsFastLog(visualmode, logModes.funcTimestamp)
enddef

export def JsFastLog_string(visualmode: string): void
    jsfastlog.JsFastLog(visualmode, logModes.string)
enddef

export def JsFastLog_string_trace(visualmode: string): void
    jsfastlog.JsFastLog(visualmode, logModes.string, true)
enddef

export def JsFastLog_separator(): void
    jsfastlog.JsFastLog('', logModes.separator)
enddef

export def JsFastLog_lineNumber(): void
    jsfastlog.JsFastLog('', logModes.lineNumber)
enddef
