--- UTILITY FUNCTIONS

--- Splits text by a separator.
---@param str string String to split.
---@param sep string? Separator. Defaults to whitespace.
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

--- Deep copies a table.
---@param orig table Table to copy.
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

-- Talisman compat
if not _G["to_big"] then
    to_big = function(x)
        return x
    end
end

---Formats number.
---@see number_format
---@param num any Number to format. Accepts Talisman's bignum/omeganum.
---@param e_switch_point number? Number from where to switch to scientic notation. Defaults to 1000000.
---@param places number? Maximum decimal places. Defaults to 2.
---@return any # The formatted string or `num` if it's not a number.
function JokerDisplay.number_format(num, e_switch_point, places)
    if not num then return num or '' end
    if type(num) == "function" then num = num() end
    if (type(num) ~= 'number' and type(num) ~= 'table') then return num or '' end
    -- Talisman compat. Copied from it with some changes :)
    if type(num) == 'table' then
        local big_num = to_big(num)
        if big_num >= to_big(e_switch_point or 1000000) then
            return Notations.Balatro:format(big_num, places or 2)
        end
        num = num:to_number()
    end
    -- Copied from the main game.. with some changes :)
    if num >= (e_switch_point or 1000000) then
        local x = string.format("%.4g", num)
        local fac = math.floor(math.log(tonumber(x), 10))
        return string.format("%." .. (places or 2) .. "f", x / (10 ^ fac)):gsub("(%.%d-)0+$", "%1"):gsub("%.$", "") ..
            'e' .. fac
    end
    return string.format(num ~= math.floor(num) and (num >= 100 and "%.0f" or num >= 10 and "%.1f" or "%.2f") or "%.0f",
        num):gsub("(%.%d-)0+$", "%1"):gsub("%.$", ""):reverse():gsub("(%d%d%d)", "%1,"):gsub(",$", ""):reverse()
end

---Get all areas available for JokerDisplay
---Hook to add more areas
---@return table
function JokerDisplay.get_display_areas()
    return { G.jokers }
end
