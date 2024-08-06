--- UTILITY FUNCTIONS

--- Splits text by a separator.
---@param str string String to split
---@param sep string? Separator. Defauls to whitespace.
---@return table split_text
function JokerDisplay.strsplit(str, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for substr in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(t, substr)
    end
    return t
end

--- Deep copies a table
---@param orig table Table to copy
---@return table? copy
function JokerDisplay.deepcopy(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[JokerDisplay.deepcopy(orig_key)] = JokerDisplay.deepcopy(orig_value)
        end
        setmetatable(copy, JokerDisplay.deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

--- NUMBER FORMATTING

-- Talisman Compat
if not _G["to_big"] then
    to_big = function(x)
        return x
    end
end