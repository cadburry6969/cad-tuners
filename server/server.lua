local QBCore = exports[core_export]:GetCoreObject()

function GeneratePlate()
    local plate = QBCore.Shared.RandomInt(1) ..
    QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(2)
    local result = MySQL.Sync.fetchScalar('SELECT plate FROM player_vehicles WHERE plate = ?', { plate })
    if result then
        return GeneratePlate()
    else
        return plate:upper()
    end
end

function GenerateReceipt()
    local receipt = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomInt(3)
    local result = MySQL.Sync.fetchScalar('SELECT receipt FROM player_vehicles WHERE receipt = ?', { receipt })
    if result then
        return GenerateReceipt()
    else
        return receipt:upper()
    end
end

RegisterNetEvent('cad-tuners:GiveVehicle', function(playerid, data, IsClear)
    local src = source
    local vehicle = data.vehicle
    local pData = QBCore.Functions.GetPlayer(playerid)
    local name = QBCore.Shared.Vehicles[vehicle]['name']
    local model = QBCore.Shared.Vehicles[vehicle]['model']
    local category = QBCore.Shared.Vehicles[vehicle]['category']
    local price = QBCore.Shared.Vehicles[vehicle]['price']
    if IsClear then
        if pData.PlayerData.money['bank'] > price then
            local plate = GeneratePlate()
            local receipt = GenerateReceipt()
            local date = os.date("%x", 906000490)
            MySQL.Async.insert(
            'INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state, Balancepaid, balanceleft, vehiclePrice , receipt, ownername, phonenumber, soldby, solddate, commission) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                { pData.PlayerData.license, pData.PlayerData.citizenid, vehicle, GetHashKey(vehicle), '{}', plate,
                    "tunerparking", 0, price, "0", price, receipt, pData.PlayerData.charinfo.firstname,
                    pData.PlayerData.phone, "TUNERS", date, "1" })
            TriggerClientEvent('QBCore:Notify', playerid, 'Congratulations on purchase of ' .. name .. '!', 'success')
            TriggerClientEvent('QBCore:Notify', src, 'You sold a vehicle to [' .. playerid .. ']!', 'success')
            TriggerClientEvent('cad-tuners:TakeOutBuy', playerid, model, plate, data.coords)
            pData.Functions.RemoveMoney('bank', price, 'vehicle-bought-tuners')
            exports['qb-management']:AddMoney("tuner", price)
        else
            TriggerClientEvent('QBCore:Notify', playerid, 'Not enough money', 'error')
            TriggerClientEvent('QBCore:Notify', src, 'Persons payment did not go through', 'error')
        end
    else
        TriggerClientEvent("QBCore:Notify", src, "There is a vehicle in way", "error")
    end
end)

QBCore.Functions.CreateCallback('cad-tuners:spawnVehicle', function(source, cb, model, coords, warp)
    model = type(model) == 'string' and GetHashKey(model) or model
    if not coords then coords = GetEntityCoords(GetPlayerPed(source)) end
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, true)
    while not DoesEntityExist(veh) do Wait(0) end
    if warp then TaskWarpPedIntoVehicle(GetPlayerPed(source), veh, -1) end
    while NetworkGetEntityOwner(veh) ~= source do Wait(0) end
    cb(NetworkGetNetworkIdFromEntity(veh))
    SetTimeout(500, function()
        TriggerEvent("x99-vehstance:server:sync", GetVehicleNumberPlateText(veh), NetworkGetNetworkIdFromEntity(veh),
            source)
    end)
end)
