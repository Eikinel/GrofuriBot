function string:split(sep, prsvquotes)
    if not sep then return self end
    if not prsvquotes then prsvquotes = false end

    local words = {}
    local tmpword = ""
    local inquote = false
    local len = 1

    -- Capture every words that does not contain the breaking character
    for word in self:gmatch("([^".. sep .."]+)") do
        -- Toggle "in quote" mode if the word contains one quote.
        -- If this word is between two quotes, then it's just a word and not a sentence : just add it like any other words
        if prsvquotes and word:find("\"") and not word:match("\".+\"") then
            if inquote then tmpword = tmpword .. " " .. word end
            inquote = not inquote
        end

        if inquote and self:find("\"", len + 1) then
            tmpword = tmpword .. (tmpword == "" and "" or " ") .. word
        else
            words[#words + 1] = tmpword == "" and word:gsub("\"", "") or tmpword:gsub("\"", "")
            tmpword = ""
        end

        len = len + #word
    end

    return words
end