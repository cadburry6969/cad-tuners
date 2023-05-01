local QBCore = exports[core_export]:GetCoreObject()

local inVehicle = false
local CheckVehicle = false
local function DeleteVehicle(k)
    CheckVehicle = true
    CreateThread(function()
        while CheckVehicle do
            if not inVehicle then CheckVehicle = false end
            if IsControlJustPressed(0, 38) then
                CheckVehicle = false
                local ped = PlayerPedId()
                QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(ped))
                DeleteEntity(GetVehiclePedIsIn(ped))
                inVehicle = false
                exports[core_export]:HideText()
            end
            Wait(1)
        end
    end)
end

local function GetIsPointClear(cds)
    local coords = cds
    if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
        return false
    end
    return true
end

local function IsTunerJob()
    local pdata = QBCore.Functions.GetPlayerData()
    return pdata.job.name == tuner_job_name
end

local function OpenTunerStash(isShared)
    Wait(100)
    if isShared then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", "tuners_shared", {
            maxweight = 1000000,
            slots = 200,
        })
        TriggerEvent("inventory:client:SetCurrentStash", "tuners_shared")
    else
        local pData = QBCore.Functions.GetPlayerData()
        TriggerServerEvent("inventory:server:OpenInventory", "stash", "tuners_" .. pData.citizenid, {
            maxweight = 500000,
            slots = 100,
        })
        TriggerEvent("inventory:client:SetCurrentStash", "tuners_" .. pData.citizenid)
    end
end

local function LoadExports()
    local TunerBlip = AddBlipForCoord(139.79, -3031.15, 7.04)
    SetBlipSprite(TunerBlip, 488)
    SetBlipDisplay(TunerBlip, 4)
    SetBlipScale(TunerBlip, 0.9)
    SetBlipAsShortRange(TunerBlip, true)
    SetBlipColour(TunerBlip, 13)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("LS Tuners")
    EndTextCommandSetBlipName(TunerBlip)

    exports[target_export]:AddCircleZone("tunercatelogue", vector3(132.96, -3014.89, 7.04), 0.8, {
        name = "tunercatelogue",
        useZ = true,
        debugPoly = false
    }, {
        options = {
            {
                icon = "fas fa-gear",
                label = "Catalogue",
                action = function()
                    OpenTunerCatelogue()
                end
            },
        },
        distance = 2.0
    })
    exports[target_export]:AddBoxZone("tunerbossmenu", vector3(125.58, -3007.23, 7.04), 0.6, 1, {
        name = "tunerbossmenu",
        heading = 352,
        --debugPoly=true,
        minZ = 6.84,
        maxZ = 7.44
    }, {
        options = {
            {
                type = "client",
                event = "qb-bossmenu:client:OpenMenu",
                icon = "fa fa-clipboard",
                label = "Boss Menu",
                job = tuner_job_name,
            },
        },
        distance = 2.0
    })
    exports[target_export]:AddBoxZone("tunersharedstash", vector3(128.67, -3014.47, 7.04), 1.6, 3, {
        name = "tunersharedstash",
        heading = 1,
        --debugPoly=true,
        minZ = 6.04,
        maxZ = 8.84
    }, {
        options = {
            {
                icon = 'fas fa-box',
                label = 'Stash',
                action = function()
                    OpenTunerStash(true)
                end,
                job = tuner_job_name
            }
        },
        distance = 2.0,
    })
    exports[target_export]:AddBoxZone("tunerstashoutfit", vector3(154.24, -3011.35, 7.04), 0.4, 2, {
        name = "tunerstashoutfit",
        heading = 270,
        --debugPoly=true,
        minZ = 6.04,
        maxZ = 8.24,
    }, {
        options = {
            {
                type = "client",
                event = "qb-clothing:client:openOutfitMenu",
                icon = 'fas fa-tshirt',
                label = 'Outfits',
                job = tuner_job_name
            },
            {
                icon = 'fas fa-box',
                label = 'Stash',
                action = function()
                    OpenTunerStash(false)
                end,
                job = tuner_job_name
            },
        },
        distance = 2.0,
    })
    exports[target_export]:AddBoxZone("tunervehiclemenu", vector3(133.04, -3026.48, 7.04), 0.8, 1, {
        name = "tunervehiclemenu",
        heading = 0,
        --debugPoly=true,
        minZ = 6.04,
        maxZ = 7.84
    }, {
        options = {
            {
                type = "client",
                event = "cad-tuners:openmenu",
                icon = 'fas fa-gear',
                label = 'Tuner Options',
                job = tuner_job_name
            },
        },
        distance = 1.5,
    })
    local boxZone = BoxZone:Create(vector3(125.78, -3023.05, 7.04), 4, 4, {
        name = "tunerdeletevehicle",
        heading = 0,
        --debugPoly=true,
        minZ = 6.04,
        maxZ = 8.84
    })
    boxZone:onPlayerInOut(function(isPointInside)
        if isPointInside and IsPedInAnyVehicle(PlayerPedId()) and IsTunerJob() then
            inVehicle = true
            exports[core_export]:DrawText("[E] Store Vehicle", 'left')
            DeleteVehicle(k)
        else
            inVehicle = false
            CheckVehicle = false
            exports[core_export]:HideText()
        end
    end)
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    LoadExports()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        LoadExports()
    end
end)

RegisterNetEvent("cad-tuners:openmenu", function()
    local vehicleMenu = {
        {
            isMenuHeader = true,
            header = "♾ Tuners Menu",
        },
        {
            header = "🚘 Spawn Vehicles",
            txt = 'Shows list of tuner vehicles',
            params = {
                event = 'cad-tuners:spawnmenu',
            }
        },
        {
            header = "🚘 Give Vehicles",
            txt = 'Shows list of tuner vehicles',
            params = {
                event = 'cad-tuners:givevehicle',
            }
        },
        {
            header = "🚘 Delete Vehicle",
            txt = 'Delete vehicle in display area',
            params = {
                event = 'cad-tuners:deletevehicle',
            }
        },
    }
    exports[menu_export]:openMenu(vehicleMenu)
end)

RegisterNetEvent("cad-tuners:deletevehicle", function()
    local cveh, cdist = QBCore.Functions.GetClosestVehicle(vector3(135.89, -3030.69, 7.04))
    if DoesEntityExist(cveh) then
        QBCore.Functions.DeleteVehicle(cveh)
        DeleteEntity(cveh)
        TriggerEvent("QBCore:Notify", "vehicle has been removed", "error")
    else
        TriggerEvent("QBCore:Notify", "No vehicle to remove", "error")
    end
end)

RegisterNetEvent("cad-tuners:givevehicle", function()
    local vehicleMenu = {
        {
            isMenuHeader = true,
            header = "🚘 Give Vehicle",
        },
        {
            header = "⬅️ Go Back",
            txt = 'Return back to main menu',
            params = {
                event = 'cad-tuners:openmenu',
            }
        },
    }
    for k, v in pairs(QBCore.Shared.Vehicles) do
        if v.category == category_vehice then
            vehicleMenu[#vehicleMenu + 1] = {
                header = v.name,
                txt = v.brand,
                params = {
                    event = 'cad-tuners:giveconfirm',
                    args = {
                        vehicle = k,
                        coords = vector4(125.84, -3022.86, 6.43, 270.02),
                    }
                }
            }
        end
    end
    exports[menu_export]:openMenu(vehicleMenu)
end)

RegisterNetEvent("cad-tuners:giveconfirm", function(data)
    local dialog = exports['qb-input']:ShowInput({
        header = 'Give Confirm',
        submitText = "Submit",
        inputs = {
            {
                type = 'number',
                isRequired = true,
                name = 'playerid',
                text = 'Paypal ID',
            }
        }
    })
    if dialog then
        if not dialog.playerid then return end
        TriggerServerEvent('cad-tuners:GiveVehicle', tonumber(dialog.playerid), data, GetIsPointClear(data.coords))
    end
end)

RegisterNetEvent('cad-tuners:TakeOutBuy', function(model, plate, coords)
    local p = promise.new()

    QBCore.Functions.TriggerCallback('cad-tuners:spawnVehicle', function(netId)
        p:resolve(netId)
    end, model, coords, false)

    local result = Citizen.Await(p)
    local veh = NetToVeh(result)

    SetVehicleNumberPlateText(veh, plate)
    exports[fuel_export]:SetFuel(veh, 100)
    TriggerEvent("vehiclekeys:client:SetOwner", plate)
    SetEntityAsMissionEntity(veh, true, true)
    SetVehicleEngineOn(veh, true, true)
    TriggerServerEvent("qb-vehicletuning:server:SaveVehicleProps", QBCore.Functions.GetVehicleProperties(veh))
end)

RegisterNetEvent("cad-tuners:spawnmenu", function()
    local vehicleMenu = {
        {
            isMenuHeader = true,
            header = "🚘 Spawn Vehicle",
        },
        {
            header = "⬅️ Go Back",
            txt = 'Return back to main menu',
            params = {
                event = 'cad-tuners:openmenu',
            }
        },
    }
    for k, v in pairs(QBCore.Shared.Vehicles) do
        if v.category == category_vehice then
            vehicleMenu[#vehicleMenu + 1] = {
                header = v.name,
                txt = v.brand,
                params = {
                    event = 'cad-tuners:TakeOut',
                    args = {
                        vehmodel = v.model,
                        coords = vector4(136.06, -3030.86, 6.43, 359.81),
                    }
                }
            }
        end
    end
    exports[menu_export]:openMenu(vehicleMenu)
end)

RegisterNetEvent('cad-tuners:TakeOut', function(data)
    if not GetIsPointClear(data.coords) then
        local cveh, cdist = QBCore.Functions.GetClosestVehicle(vector3(data.coords.x, data.coords.y, data.coords.z))
        if cdist < 5 then
            QBCore.Functions.DeleteVehicle(cveh)
            DeleteEntity(cveh)
        end
    end
    local p = promise.new()

    QBCore.Functions.TriggerCallback('cad-tuners:spawnVehicle', function(netId)
        p:resolve(netId)
    end, data.vehmodel, data.coords, false)

    local result = Citizen.Await(p)
    local veh = NetToVeh(result)

    local plate = QBCore.Functions.GetPlate(veh)
    exports[fuel_export]:SetFuel(veh, 100)
    TriggerEvent("vehiclekeys:client:SetOwner", plate)
    SetEntityAsMissionEntity(veh, true, true)
    SetVehicleEngineOn(veh, false, false)
end)
