 _G.registerCommand({"help"}, function(msg)
    membed = embed:new()

    membed:setTitle("Help")
    membed:setAuthor("Eikinel", "https://discordapp.com/", "https://yt3.ggpht.com/a-/AN66SAyTgDAsFyi6Ptt-XmuUtbZu7edjBW25GgoVtA=s900-mo-c-c0xffffffff-rj-k-no")
    membed:setDescription("De l'aide pour mes compatriotes")

    msg:reply({embed = membed})
end)