QBCore = exports["qb-core"]:GetCoreObject()
SozJobCore = exports["soz-jobs"]:GetCoreObject()

QBCore.Functions.CreateCallback("banking:getBankingInformation", function(source, cb, account)
    local Player = QBCore.Functions.GetPlayer(source)

    if Player then
        if account == nil then
            account = Account(Player.PlayerData.charinfo.account)
        else
            if string.find(account, "%d%d%u%d%d%d%d%u%d%d%d%d") then
                account = Account(account)
            elseif SozJobCore.Functions.HasPermission(account, Player.PlayerData.job.id, Player.PlayerData.job.grade,
                                                      SozJobCore.JobPermission.SocietyBankAccount) then
                account = Account(account)
            else
                cb(nil)
                return
            end
        end

        local banking = {
            ["name"] = Player.Functions.GetName(),
            ["accountinfo"] = account.id,
            ["bankbalance"] = QBCore.Shared.GroupDigits(account.money) .. "$",
            ["money"] = QBCore.Shared.GroupDigits(Player.PlayerData.money["money"]) .. "$",
        }

        local offshore = Account("offshore_" .. account.id)
        if offshore ~= nil then
            banking["offshore"] = QBCore.Shared.GroupDigits(offshore.marked_money) .. "$"
        end

        cb(banking)
    else
        cb(nil)
    end
end)

QBCore.Functions.CreateCallback("banking:server:createOffshoreAccount", function(source, cb, account)
    local Player = QBCore.Functions.GetPlayer(source)
    local offshore = Account("offshore_" .. account)

    if SozJobCore.Functions.HasPermission(account, Player.PlayerData.job.id, Player.PlayerData.job.grade, SozJobCore.JobPermission.SocietyBankAccount) then
        if offshore == nil then
            Account.Create("offshore_" .. account, "Compte offshore " .. account, "offshore", "offshore_" .. account)
            cb(true)
            return
        else
            cb(false, "already_exist")
            return
        end
    else
        cb(false, "action_forbidden")
    end
end)

QBCore.Functions.CreateCallback("banking:server:TransfertOffshoreMoney", function(source, cb, accountTarget, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    local CurrentMoney = Player.Functions.GetMoney("marked_money")
    amount = tonumber(amount)

    if SozJobCore.Functions.HasPermission(accountTarget, Player.PlayerData.job.id, Player.PlayerData.job.grade, SozJobCore.JobPermission.SocietyBankAccount) then
        if amount <= CurrentMoney then
            if Player.Functions.RemoveMoney("marked_money", amount) then
                Account.AddMoney("offshore_" .. accountTarget, amount, "marked_money")
                cb(true)
                return
            end
        end
    else
        cb(false, "action_forbidden")
        return
    end

    cb(false, "unknown")
end)

QBCore.Functions.CreateCallback("banking:server:TransfertMoney", function(source, cb, accountSource, accountTarget, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    local CurrentMoney = Player.Functions.GetMoney("money")
    amount = tonumber(amount)

    if accountSource == "player" then
        if amount <= CurrentMoney then
            if Player.Functions.RemoveMoney("money", amount) then
                Account.AddMoney(accountTarget, amount)
                cb(true)
                return
            end
        end
    elseif accountTarget == "player" then
        local AccountMoney = Account(accountSource).money
        if amount <= AccountMoney then
            if Player.Functions.AddMoney("money", amount) then
                Account.RemoveMoney(accountSource, amount)
                cb(true)
                return
            end
        end
    else
        Account.TransfertMoney(accountSource, accountTarget, amount, function(success, reason)
            cb(success, reason)
            return
        end)
    end

    cb(false, "unknown")
end)

RegisterNetEvent("banking:server:TransfertMoney", function(accountSource, accountTarget, amount)
    Account.TransfertMoney(accountSource, accountTarget, amount)
end)

RegisterNetEvent("baking:server:SafeStorageDeposit", function(money_type, safeStorage, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    local CurrentMoney = Player.Functions.GetMoney(money_type)
    amount = tonumber(amount)

    if money_type == "money" or money_type == "marked_money" then
        if amount <= CurrentMoney then
            if Player.Functions.RemoveMoney(money_type, amount) then
                Account.AddMoney(safeStorage, amount, money_type)
            end
        else
            TriggerClientEvent("hud:client:DrawNotification", Player.PlayerData.source, "Vous n'avez pas assez d'argent", "error")
        end
    end
end)

RegisterNetEvent("baking:server:SafeStorageWithdraw", function(money_type, safeStorage, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    amount = tonumber(amount)

    if money_type == "money" or money_type == "marked_money" then
        local CurrentMoney = Account(safeStorage)[money_type]
        if amount <= CurrentMoney then
            if Player.Functions.AddMoney(money_type, amount) then
                Account.RemoveMoney(safeStorage, amount, money_type)
            end
        else
            TriggerClientEvent("hud:client:DrawNotification", Player.PlayerData.source, "Vous n'avez pas assez d'argent", "error")
        end
    end
end)

QBCore.Functions.CreateCallback("banking:server:openSafeStorage", function(source, cb, safeStorage)
    local account = Account(safeStorage)

    if account and Account.AccessGranted(account, source) then
        cb(true, account.money, account.marked_money)
    else
        cb(false)
    end
end)

RegisterNetEvent("banking:server:updatePhoneBalance", function()
    local Player = QBCore.Functions.GetPlayer(source)
    local account = Account(Player.PlayerData.charinfo.account)

    TriggerClientEvent("phone:client:bank:updateBalance", Player.PlayerData.source, Player.Functions.GetName(), account.money)
end)
