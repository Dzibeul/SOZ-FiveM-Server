local function RotationToDirection(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z,
    }
    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x),
    }
    return direction
end

local function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination = {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance,
    }
    local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z,
                                                               destination.x, destination.y, destination.z, -1,
                                                               PlayerPedId(), 0))
    return b, c, e
end

RegisterNetEvent("soz:client:sit")
AddEventHandler("soz:client:sit", function(data)
    local player = GetPlayerPed(-1)
    local entity = getEntity(PlayerId())
    local coords = GetEntityCoords(entity)
    local heading = GetEntityHeading(entity)
    if heading >= 180 then
        heading = heading - 179
    else
        heading = heading + 179
    end

    local angle = heading * (2 * math.pi) / 360
    SetEntityHeading(player, heading)
    SetPedCoordsKeepVehicle(player, (coords.x - (0.5 * math.sin(angle))), (coords.y + (0.5 * math.cos(angle))),
                            coords.z - 0.6)
    TriggerEvent("animations:client:EmoteCommandStart", {"sitchair"})
end)

function getEntity(player)
    local hit, coords, entity = RayCastGamePlayCamera(player)
    return entity
end
