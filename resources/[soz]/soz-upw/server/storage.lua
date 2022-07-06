GlobalState.blackout_level = QBCore.Shared.Blackout.Level.Zero
local consumptionLoopRunning = false
local facilities = {["inverter"] = GetInverter, ["terminal"] = GetTerminal}

RegisterNetEvent("soz-upw:server:FacilityCapacity", function(data)
    local getter = facilities[data.facility]
    if not getter then
        return
    end

    local facility = getter(data.identifier)
    if facility then
        TriggerClientEvent("hud:client:DrawNotification", source,
                           string.format("Remplissage : %s%%", math.floor(facility.capacity / facility.maxCapacity * 100)))
    end
end)

local function GetTerminals(scope)
    if not scope then
        scope = "default"
    end

    local terminals = {}

    for identifier, terminal in pairs(Terminals) do
        if terminal.scope == "default" then
            terminals[identifier] = terminal
        end
    end

    return terminals
end

local function GetTerminalJob(jobId)
    for identifier, terminal in pairs(Terminals) do
        if terminal.scope == "entreprise" and terminal.job == jobId then
            return terminal
        end
    end

    return nil
end

local function GetTerminalCapacities(scope)
    local capacity, maxCapacity = 0, 0

    for _, terminal in pairs(GetTerminals(scope)) do
        if terminal.scope == scope then
            capacity = capacity + terminal.capacity
            maxCapacity = maxCapacity + terminal.maxCapacity
        end
    end

    return capacity, maxCapacity
end

function GetBlackoutLevel()
    return QBCore.Shared.Blackout.Level.Zero
    -- @TODO
    -- local capacity, maxCapacity = GetTerminalCapacities("default")
    -- local percent = math.ceil(capacity / maxCapacity * 100)
    --
    -- if percent >= 100 then
    --    return QBCore.Shared.Blackout.Level.Zero
    -- end
    --
    -- for level, range in pairs(Config.Blackout.Threshold) do
    --    if percent >= range.min and percent < range.max then
    --        return level
    --    end
    -- end
    --
    -- return QBCore.Shared.Blackout.Level.Zero
end

function IsJobBlackout(job)
    return false
    -- @TODO
    -- local terminal = GetTerminalJob(job)
    --
    -- if terminal then
    --    return terminal:GetEnergyPercent() <= 1
    -- end
    --
    -- return false
end

QBCore.Functions.CreateCallback("soz-upw:server:GetBlackoutLevel", function(source, cb)
    cb(GetBlackoutLevel())
end)

QBCore.Functions.CreateCallback("soz-upw:server:IsJobBlackout", function(source, cb, jobId)
    cb(IsJobBlackout(jobId))
end)

--
-- ENERGY CONSUMPTION
--
function StartConsumptionLoop()
    Citizen.CreateThread(function()
        consumptionLoopRunning = true
        GlobalState.job_energy = GlobalState.job_energy or {}

        while consumptionLoopRunning do
            local connectedPlayers = QBCore.Functions.TriggerRpc("smallresources:server:GetCurrentPlayers")[1]

            local consumptionThisTick = Config.Consumption.EnergyPerTick * connectedPlayers

            local identifiers = {}
            for identifier, _ in pairs(GetTerminals("default")) do
                table.insert(identifiers, identifier)
            end

            for i = 1, consumptionThisTick, 1 do
                local n = math.random(1, #identifiers)

                for j = 0, #identifiers - 1, 1 do
                    local index = j + n

                    if index > #identifiers then
                        index = index - #identifiers
                    end

                    local terminal = GetTerminal(identifiers[index])

                    if terminal and terminal:CanConsume() then
                        terminal:Consume(1)
                        break
                    end
                end
            end

            local newBlackoutLevel = GetBlackoutLevel()

            -- Blackout level has changed
            if GlobalState.blackout_level ~= newBlackoutLevel then
                GlobalState.blackout_level = newBlackoutLevel
            end

            -- Handle job terminal consumption
            for jobId, v in pairs(SozJobCore.Jobs) do
                local terminal = GetTerminalJob(jobId)

                if terminal ~= nil then
                    local _, count = QBCore.Functions.GetPlayersOnDuty(jobId)
                    local consumptionJobThisTick = Config.Consumption.EnergyJobPerTick * count

                    if terminal:CanConsume() then
                        terminal:Consume(consumptionJobThisTick)
                    end

                    GlobalState.job_energy[jobId] = 100 -- @TODO terminal:GetEnergyPercent()
                else
                    GlobalState.job_energy[jobId] = 100
                end
            end

            Citizen.Wait(Config.Production.Tick)
        end
    end)
end
