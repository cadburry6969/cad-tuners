local lastSelectedVehicleEntity
local inTheShop = false
local vehiclesTable = {}
local provisoryObject = {}
local rgbColorSelected = { 255, 255, 255 }
local rgbSecondaryColorSelected = { 255, 255, 255 }
local QBCore = exports[core_export]:GetCoreObject()

RegisterNetEvent('cad-tuners.notify', function(type, message)
    SendNUIMessage({ type = "notify", typenotify = type, message = message })
end)

RegisterNetEvent('cad-tuners.vehiclesInfos', function()
    for k, v in pairs(QBCore.Shared.Vehicles) do
        if v.shop == catelogue_shop then
            vehiclesTable[v.category] = {}
        end
    end

    for k, v in pairs(QBCore.Shared.Vehicles) do
        if v.shop == catelogue_shop then
            provisoryObject = {
                brand = v.brand,
                name = v.name,
                price = v.price,
                model = v.model,
                qtd = 5000,
            }
            table.insert(vehiclesTable[v.category], provisoryObject)
        end
    end
end)

function OpenTunerCatelogue()
    inTheShop = true
    TriggerEvent("cad-tuners.notify", 'error', 'Use A and D To Rotate')
    TriggerEvent('cad-tuners.vehiclesInfos')
    Wait(1000)
    SendNUIMessage({ data = vehiclesTable, type = "display" })
    SetNuiFocus(true, true)
    RequestCollisionAtCoord(x, y, z)
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", -953.39, -3538.13, 14.81, 326.39, 0.00, 0.00, 60.00, false, 0)
    PointCamAtCoord(cam, -950.12, -3533.20, 14.00)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 1, true, true)
    SetFocusPosAndVel(-950.12, -3533.20, 14.00, 0.0, 0.0, 0.0)
    DisplayHud(false)
    DisplayRadar(false)

    if lastSelectedVehicleEntity ~= nil then
        DeleteEntity(lastSelectedVehicleEntity)
    end
end

function updateSelectedVehicle(model)
    local hash = GetHashKey(model)

    if not HasModelLoaded(hash) then
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Wait(10)
        end
    end

    if lastSelectedVehicleEntity ~= nil then
        DeleteEntity(lastSelectedVehicleEntity)
    end

    lastSelectedVehicleEntity = CreateVehicle(hash, -950.12, -3533.20, 14.00, 111.61, 0, 1)


    local vehicleData = {}


    vehicleData.traction = GetVehicleMaxTraction(lastSelectedVehicleEntity)


    vehicleData.breaking = GetVehicleMaxBraking(lastSelectedVehicleEntity) * 0.9650553
    if vehicleData.breaking >= 1.0 then
        vehicleData.breaking = 1.0
    end

    vehicleData.maxSpeed = GetVehicleEstimatedMaxSpeed(lastSelectedVehicleEntity) * 0.9650553
    if vehicleData.maxSpeed >= 50.0 then
        vehicleData.maxSpeed = 50.0
    end

    vehicleData.acceleration = GetVehicleAcceleration(lastSelectedVehicleEntity) * 2.6
    if vehicleData.acceleration >= 1.0 then
        vehicleData.acceleration = 1.0
    end


    SendNUIMessage({ data = vehicleData, type = "updateVehicleInfos" })

    SetVehicleCustomPrimaryColour(lastSelectedVehicleEntity, rgbColorSelected[1], rgbColorSelected[2],
        rgbColorSelected[3])
    SetVehicleCustomSecondaryColour(lastSelectedVehicleEntity, rgbSecondaryColorSelected[1], rgbSecondaryColorSelected
        [2], rgbSecondaryColorSelected[3])
    SetEntityHeading(lastSelectedVehicleEntity, 89.5)
end

function rotation(dir)
    local entityRot = GetEntityHeading(lastSelectedVehicleEntity) + dir
    SetEntityHeading(lastSelectedVehicleEntity, entityRot % 360)
end

RegisterNUICallback("rotate", function(data, cb)
    if (data["key"] == "left") then
        rotation(2)
    else
        rotation(-2)
    end
    cb("ok")
end)

RegisterNUICallback("SpawnVehicle", function(data, cb)
    updateSelectedVehicle(data.modelcar)
end)

RegisterNUICallback("RGBVehicle", function(data, cb)
    if data.primary then
        rgbColorSelected = data.color
        SetVehicleCustomPrimaryColour(lastSelectedVehicleEntity, math.ceil(data.color[1]), math.ceil(data.color[2]),
            math.ceil(data.color[3]))
    else
        rgbSecondaryColorSelected = data.color
        SetVehicleCustomSecondaryColour(lastSelectedVehicleEntity, math.ceil(data.color[1]), math.ceil(data.color[2]),
            math.ceil(data.color[3]))
    end
end)

RegisterNUICallback("menuSelected", function(data, cb)
    local categoryVehicles

    local playerIdx = GetPlayerFromServerId(source)
    local ped = GetPlayerPed(playerIdx)

    if data.menuId ~= 'all' then
        categoryVehicles = vehiclesTable[data.menuId]
    else
        SendNUIMessage({ data = vehiclesTable, type = "display" })
        return
    end

    SendNUIMessage({ data = categoryVehicles, type = "menu" })
end)

RegisterNUICallback("Close", function(data, cb)
    CloseNui()
end)

function CloseNui()
    SendNUIMessage({ type = "hide" })
    SetNuiFocus(false, false)
    if inTheShop then
        if lastSelectedVehicleEntity ~= nil then
            DeleteVehicle(lastSelectedVehicleEntity)
        end
        RenderScriptCams(false)
        DestroyAllCams(true)
        SetFocusEntity(GetPlayerPed(PlayerId()))
        DisplayHud(true)
        DisplayRadar(true)
    end
    inTheShop = false
    vehiclesTable = {}
    provisoryObject = {}
end

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CloseNui()
    end
end)
