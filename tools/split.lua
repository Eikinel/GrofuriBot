function string:split(sep, prsvquotes)
    if not sep then return self end
    if not prsvquotes then prsvquotes = false end

    local words = {}
    local tmpword = ""
    local inquote = false
    local len = 1

    -- Capture every words that does not contain the breaking character
    for word in self:gmatch("([^".. sep .."]+)") do
        if prsvquotes and word:find("\"") then
            if inquote then tmpword = tmpword .. " " .. word end
            inquote = not inquote
        end

        if inquote and self:find("\"", len + 1) then
            tmpword = tmpword .. (tmpword == "" and "" or " ") .. word
        else
            table.insert(words, tmpword == "" and word or tmpword:gsub("\"", ""))
            tmpword = ""
        end

        len = len + #word
    end

    return words
end