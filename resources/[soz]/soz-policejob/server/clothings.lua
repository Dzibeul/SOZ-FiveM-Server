--- Item
QBCore.Functions.CreateUseableItem("armor", function(source, item)
    local ped = GetPlayerPed(source)
    local Player = QBCore.Functions.GetPlayer(source)
    local armorType = item.metadata["type"] or "unmark"

    if exports["soz-inventory"]:RemoveItem(Player.PlayerData.source, item.name, 1, item.metadata) then
        Player.Functions.SetMetaData("armor", 100)
        SetPedArmour(ped, 100)

        TriggerClientEvent("police:client:setupArmor", source, armorType)
    end
end)

QBCore.Functions.CreateUseableItem("outfit", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)

    if exports["soz-inventory"]:RemoveItem(Player.PlayerData.source, item.name, 1, item.metadata) then
        if item.metadata["type"] == "lspd" or item.metadata["type"] == "bcso" then
            TriggerClientEvent("police:client:applyDutyClothing", source, item.metadata["type"])
        end
    end
end)