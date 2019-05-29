require('tools/embed')

_G.registerCommand({"help", "man"}, function(msg)
    membed = embed:new()

    membed:setColor(_G.colorChart.default)
    membed:setAuthor("Liste des commandes", "", msg.client.user:getAvatarURL())
    membed:setDescription("Voici la liste de toutes les commandes que je peux effectuer, ainsi que leurs options.\n" ..
    "Pour toute question/report de problème, veuillez envoyer un message privé à " .. msg.client.owner.mentionString)
    membed:addField(
        "**1 - Challenges Grofuri**",
[[
**%help, %man** : affiche cette bulle d'aide
**%register, %add USER** : intègre USER à la liste des participants au jeu du Grofuri
**%unregister, %remove USER** : supprime USER de la liste des participants au jeu du Grofuri
**%gperdu** : enregistre une défaite pour ce jour
**%suggest, %suggestion --title "TITLE" --description "DESCRIPTION"** : propose un nouveau challenge avec réaction en guise de vote
*[Désactivée]* **%display, %show [USER1, ...] [-dwmy, --in-pixel]** : affiche le challenge des X derniers jours avec l'état de la victoire de(s) USER(S)
        
    *__OPTIONS__*:

    **-d, --day [1-31]**  : renvoie le challenge du jour actuel ou celui spécifié en argument
    **-m, --month [1-12]**  : renvoie les challenges du mois actuel ou celui spécifié en argument
    **-y, --year YYYY**       : renvoie les challenges de l'année actuelle ou celle spécifiée en argument
]])

    msg.author:send({embed = membed})
    msg:delete()
end)