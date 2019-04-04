function string:split(sep)
    if not sep then return self end

    local words = {}

    -- Capture every words that does not contain the breaking character
    for word in string.gmatch(self, "([^".. sep .."]+)") do
        table.insert(words, word)
    end

    return words
end