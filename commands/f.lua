registerCommand({"f"}, function(msg, args)
    local ret = ""

    for _, str in ipairs(args) do
        for i = 1, #str do
            local c = str:sub(i, i)

            if (c == "f" or c == "F") and i == 1 then
                ret = ret .. ":b:"
            else
                ret = ret .. c
            end
        end

        ret = ret .. " "
    end

    msg:reply(ret)
end)