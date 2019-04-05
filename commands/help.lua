_G.registerCommand({"help", "man"}, function(msg)
    membed = embed:new()

    membed:setColor(_G.colorChart.default)
    membed:setAuthor("Liste des commandes", "", msg.client.user:getAvatarURL())
    membed:setDescription("Voici la liste de toutes les commandes que je peux effectuer, ainsi que leurs options.\n" ..
    "Pour toute question/report de problème, veuillez envoyer un message privé à " .. msg.client.owner.mentionString)
    membed:addField(
        "**1 - Challenges Grofuri**",
[[
**%help (alias: man)** : affiche cette bulle d'aide
**%register USER** : intègre USER à la liste des participants au jeu du Grofuri
**%challenge**  : affiche le challenge du jour
**%gperdu**     : enregistre une défaite pour ce jour
**%display USER [-dwmy, --in-pixel]** : affiche le challenge des X derniers jours avec l'état de la victoire de USER
        
    *__OPTIONS__*:

    **-d, --day=YY/MM/DD**  : renvoie le challenge du jour actuel ou celui spécifié en argument
    **-w, --week=[1-52]**   : renvoie les challenges de la semaine actuelle ou celle spécifiée en argument
    **-m, --month=[1-12]**  : renvoie les challenges du mois actuel ou celui spécifié en argument
    **-y, --year=YY**       : renvoie les challenges de l'année actuelle ou celle spécifiée en argument
    **--in-pixel**          : affiche la/les victoire(s) sous forme de carrés de couleurs 
]])

    msg.author:send({embed = membed})
    msg:delete()
end)