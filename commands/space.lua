_G.registerCommand({"space", "aesthetic", "ae"}, function(msg, args)
    local ret = ""

    for _, str in ipairs(args) do
        for i = 1, #str do
            local c = str:sub(i,i)

            -- 0xFF01 is the beginning of full-width char unicode table
            ret = ret .. utf8.char(string.byte(c) - 33 + 0xFF01) .. " "
        end

        ret = ret .. " "
    end

    msg:reply(ret)
end)