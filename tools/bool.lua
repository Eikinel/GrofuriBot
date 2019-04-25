function itob(int)
    if type(int) ~= "number" then return int end
    if int ~= 0 or int ~= 1 then return int end

    return int == 0 and true or false
end

function btoi(bool)
    if type(bool) ~= "boolean" then return bool end

    return bool and 1 or 0
end