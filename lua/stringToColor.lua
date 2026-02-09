local M = {}

local function getArrayFromString(str, p)
    local res = {}
    local i = p
    while i < #str do
        table.insert(res, string.byte(str, i + 1)) -- TODO: is it correct?
        i = i + 3
    end
    return res
end

local function getArraySum(arr)
    local acc = 0
    for _, v in pairs(arr) do
        acc = acc + v
    end
    return acc
end

local function gentleMap(arr)
    local min = math.min(unpack(arr))
    local max = math.max(unpack(arr)) - min
    local res = {}
    for _, v in pairs(arr) do
        local val = max == 0 and v or (v - min) * 255 / max
        local hexstr = string.format('%x', val)
        local newItem = #hexstr == 1 and '0' .. hexstr or hexstr
        table.insert(res, newItem)
    end
    return res
end

M.stringToColor = function(strArg)
    -- local str = table.concat({select(-2, unpack(vim.split(strArg, '/')))}, '')
    local parts = vim.split(strArg, '/')
    local dir = parts[#parts - 1]
    local filename = parts[#parts]
    local str = dir ~= nil and dir .. '/' .. filename or filename
    local numbersRedArray = getArrayFromString(str, 0)
    local numbersGreenArray = getArrayFromString(str, 1)
    local numbersBlueArray = getArrayFromString(str, 2)

    local unnormR = getArraySum(numbersRedArray) / #numbersRedArray
    local unnormG = getArraySum(numbersGreenArray) / #numbersGreenArray
    local unnormB = getArraySum(numbersBlueArray) / #numbersBlueArray

    local unnormArr = { unnormR, unnormG, unnormB }
    local arr = gentleMap(unnormArr)

    return '#' .. table.concat(arr, '')
end

return M
