function showTable(table, n)
    if type(table) ~= "table" then return end
    if not n then
        print("\nContent of table")
        n = 0
    end

    for k, v in pairs(table) do
        for i = 1, n do io.write("\t") end
        print("'-> ", k, v)
        showTable(v, n + 1) 
    end
end