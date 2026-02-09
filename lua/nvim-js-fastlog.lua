local M = {}

local js_fastlog_prefix = ''

M.setup = function(opts)
    s_fastlog_prefix = opts['js_fastlog_prefix'] or ''
end

local logModes = {
    simple = 'simple',
    jsonStringify = 'jsonStringify',
    showVar = 'showVar',
    funcTimestamp = 'funcTimestamp',
    string = 'string',
    separator = 'separator',
    lineNumber = 'lineNumber',
    traceCollapsed = 'traceCollapsed',
}

local function getSelectionColumns()
    local pos1 = vim.fn.getcharpos('v')[2]
    local pos2 = vim.fn.getcharpos('.')[2]
    return {
        start = math.min(pos1, pos2),
        finish = math.max(pos1, pos2),
    }
end

local function getWord()
    local start = vim.api.nvim_buf_get_mark(0, '[')[2]
    local end_pos = vim.api.nvim_buf_get_mark(0, ']')[2]
    local line = vim.api.nvim_get_current_line()
    local text = line:sub(start + 1, end_pos + 1)
    return text
end

local function WQ(s)
    -- Wrap with Quotes
    return "\'" .. s .. "\'"
end

local function makeInner(logmode, word)
    local inner = word
    local escapedWord = vim.fn.escape(word, "'")
    local line = vim.api.nvim_get_current_line()

    if logmode == logModes.string then -- string: 'var' => 'console.log('var');'
        return WQ(escapedWord)
    end

    if logmode == logModes.jsonStringify then -- JSON.stringify: 'var' => 'console.log('var='+JSON.stringify(var));'
        return WQ(escapedWord .. '=') .. " + JSON.stringify(" .. word .. ")"
    end

    if logmode == logModes.showVar then
        local trimmedword = vim.trim(word)
        if trimmedword:sub(1, 1) == '{' and trimmedword:sub(-1) == '}' then
            return trimmedword
        end
        if vim.fn.stridx(trimmedword, ', ') > -1 then
            return '{ ' .. trimmedword .. ' }'
        end
        return WQ(escapedWord .. '=') .. ', ' .. trimmedword
    end

    if logmode == logModes.funcTimestamp then
        local filename = vim.fn.expand('%:t:r')
        if filename == 'index' then
            local parts = vim.split(vim.fn.expand('%:r'), '/')
            filename = parts[#parts - 1] .. '/' .. parts[#parts]
        end
        return 'Date.now() % 10000, ' .. WQ(filename .. ':' .. line .. ' ' .. escapedWord)
    end

    if logmode == logModes.separator then
        return WQ(' ========================================')
    end

    if logmode == logModes.lineNumber then
        local filename = vim.fn.expand('%:t:r')
        return WQ(filename .. ':' .. line)
    end

    return inner
end

local function makeString(inner, wrapIntoTrace) 
    local filenameWithExt = vim.fn.expand('%:t')
    local filenameWithoutExt = vim.fn.expand('%:t:r')
    local folders = vim.split(vim.fn.expand('%:h'), '/')
    local color = require('./stringToColor').stringToColor(folders[#folders] .. filenameWithoutExt)
    local result = 'console.' .. (wrapIntoTrace and 'groupCollapsed' or 'log') .. '('
        .. "'%c" .. js_fastlog_prefix .. "', "
        .. "'background:" .. color .. "', "
        .. inner
        .. ')'

    result = result .. (vim.fn.search(';', 'n') > 0 and ';' or '')
    return result
end

local function jsFastLog(logmode, wrapIntoTrace)
    local word = getWord()
    print('word=', word)

    local wordIsEmpty = not word:match('%S')
    if logmode ~= logModes.separator
         and logmode ~= logModes.lineNumber
         and wordIsEmpty then
         vim.cmd('normal aconsole.log();')
         vim.cmd('normal hh')
    else
        print(124)
        local finalstring = makeString(makeInner(logmode, word), wrapIntoTrace)
        vim.cmd('normal! 0d$i' .. finalstring)
        vim.cmd('normal! ==')

        -- if logmode == logModes.funcTimestamp
        --     or logmode == logModes.separator then
        --     vim.cmd('normal! ==f(l')
        -- else
        --     vim.cmd('.-delete _')
        --     vim.cmd('normal! ==f(')
        -- end
    end

    -- if wrapIntoTrace then
    --     vim.cmd('normal oconsole.trace()' .. (vim.fn.search(';', 'n') > 0 and ';' or ''))
    --     vim.cmd('normal oconsole.groupEnd()' .. (vim.fn.search(';', 'n') > 0 and '; : '))
    --     vim.cmd('normal kk')
    -- end

    -- move cursor to end of line -2 columns
    vim.cmd('normal $hh')
end

M.getLogModes = function()
    return logModes
end

local getFuncForMap = function(func, funcName)
    _G[funcName] = func
    return function()
        vim.o.operatorfunc = 'v:lua._G.' .. funcName
        vim.api.nvim_feedkeys('g@', 'n', false)
    end
end

M.JsFastLog_simple = getFuncForMap(function() jsFastLog(logModes.simple) end, 'JsFastLog_simple')

-- M.JsFastLog_simple_trace = function(visualmode)
--     visualmode = visualmode or ''
--     jsFastLog(visualmode, logModes.simple, true)
-- end
--
-- M.JsFastLog_JSONstringify = function(visualmode)
--     visualmode = visualmode or ''
--     jsFastLog(visualmode, logModes.jsonStringify)
-- end

M.JsFastLog_variable = getFuncForMap(function() jsFastLog(logModes.showVar) end, 'JsFastLog_variable')

-- M.JsFastLog_variable_trace = function(visualmode)
--     visualmode = visualmode or ''
--     jsFastLog(visualmode, logModes.showVar, true)
-- end
--
-- M.JsFastLog_function = function(visualmode)
--     visualmode = visualmode or ''
--     jsFastLog(visualmode, logModes.funcTimestamp)
-- end
--
-- M.JsFastLog_string = function(visualmode)
--     visualmode = visualmode or ''
--     jsFastLog(visualmode, logModes.string)
-- end
--
-- M.JsFastLog_string_trace = function(visualmode)
--     visualmode = visualmode or ''
--     jsFastLog(visualmode, logModes.string, true)
-- end
--
-- M.JsFastLog_separator = function()
--     jsFastLog('', logModes.separator)
-- end
--
-- M.JsFastLog_lineNumber = function()
--     jsFastLog('', logModes.lineNumber)
-- end

return M
