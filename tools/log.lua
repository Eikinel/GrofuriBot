local log = {
    level = {
        "INFO",
        "WARNING",
        "ERROR"
    },
    first_entry = true,
    default = "grofuri.log",
    __metatable = false
}

-- Write to log file
function log:print(msg, index, file)
    local f = io.open(file or self.default, "a")
    local date = os.date("%Y/%m/%d | %X | ")
    local scope = "[" .. (index and self.level[index] or self.level[1]) .. "] | "

    -- Append a \n for the first log entry
    if self.first_entry then
        print()
        f:write("\n")
        self.first_entry = false
    end

    print(date .. scope .. msg)
    f:write(date .. scope .. msg, "\n")
    f:close()
end

return log