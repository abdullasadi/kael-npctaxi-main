local QBCore = exports[Config.Core]:GetCoreObject()
local Destination = nil
local CanEnter = false
local CanLeave = false
local AtDestination = false
local Taxi = nil 
local Driver = nil
local Cost = 0.0
local Targets = {}
local TargetObjs = {}

CreateThread(function()
    LoadModel(Config.BoothModel)
    for k, v in pairs(Config.TaxiStands) do 
        local Stand = CreateObject(Config.BoothModel, v.x, v.y, v.z, v.w, false, true, false)
        SetEntityHeading(Stand, v.w)
        PlaceObjectOnGroundProperly(Stand)
        FreezeEntityPosition(Stand, true)
        TargetObjs[#TargetObjs + 1] = Stand
        Targets[Stand] = exports[Config.Target]:AddTargetEntity(Stand, { 
            options = { 
                { 
                    icon = 'fas fa-taxi', 
                    label = 'Call Taxi',  
                    event = "kael-npctaxi:client:calltaxi",
                },
            },
            distance = 2.5, 
        })

        if Config.StandBlip then 
            local Blip = AddBlipForCoord(v)
            SetBlipSprite (Blip, Config.StandBlip.Icon)
            SetBlipDisplay(Blip, 4)
            SetBlipScale  (Blip, Config.StandBlip.Size)
            SetBlipAsShortRange(Blip, true)
            SetBlipColour(Blip, Config.StandBlip.Color)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(Config.StandBlip.Text)
            EndTextCommandSetBlipName(Blip)
        end
    end
end)


CreateThread(function()
    while true do 
        local Sleep = 1000
        if Taxi and CanEnter then 
            local PlayerCoords = GetEntityCoords(PlayerPedId())
            local TaxiCoords = GetEntityCoords(Taxi)
            local Distance = GetDistanceBetweenCoords(TaxiCoords, PlayerCoords, true)
            if Distance <= 2.5 then
                Sleep = 0
                DrawText3D(TaxiCoords.x, TaxiCoords.y, TaxiCoords.z + 1.0, "[ ~b~E~s~ ] Enter ~y~Taxi~s~")
                if IsControlJustReleased(0, 38) then
                    TaskEnterVehicle(PlayerPedId(), Taxi, 1000, math.random(0,2), 1.0, 1, 0)
                end
            end
        end
        if Taxi and CanLeave then 
            local PlayerCoords = GetEntityCoords(PlayerPedId())
            local TaxiCoords = GetEntityCoords(Taxi)
            local Distance = GetDistanceBetweenCoords(TaxiCoords, PlayerCoords, true)
            if Distance <= 2.5 then
                Sleep = 0
                DrawText3D(TaxiCoords.x, TaxiCoords.y, TaxiCoords.z + 1.0, "[ ~b~E~s~ ] Leave ~y~Taxi~s~")
                if IsControlJustReleased(0, 38) then
                    TaskLeaveVehicle(PlayerPedId(), Taxi, 1)
                end
            end
        end
        Wait(Sleep)
    end
end)


RegisterNetEvent('kael-npctaxi:client:calltaxi', function()
    CallNpcTaxi()
end)

function CallNpcTaxi()
    if Taxi then Notify("Taxi", "You Can't Call Taxi Now!", "error") return end
    local PlayerPed = PlayerPedId()
    local PlayerCoords = GetEntityCoords(PlayerPed)
    local SapwnCoords = RandomSpawnCoords(PlayerCoords, 100)
    local Found, Coords1, Coords2 = GetClosestRoad(SapwnCoords.x, SapwnCoords.y, SapwnCoords.z, 1.0, 1, false)
    if Found then 
        local Spawn = Coords1 and Coords1 or Coords2
        LoadModel(Config.TaxiModel)
        LoadModel(Config.DriverModel)
        Taxi = CreateVehicle(Config.TaxiModel, Spawn, true, true)
        SetVehicleFuelLevel(Taxi, 100.0)
        DecorSetFloat(Taxi, "_FUEL_LEVEL", GetVehicleFuelLevel(Taxi))
        local Plate = QBCore.Functions.GetPlate(Taxi)
        Config.VehKeyExports(Taxi, Plate, Config.TaxiModel) 
        Driver = CreatePed(26, Config.DriverModel, Spawn, true, true)
        SetPedCanBeDraggedOut(Driver, false)
        SetBlockingOfNonTemporaryEvents(Driver, true)
        SetPedIntoVehicle(Driver, Taxi, -1)
        TaxiBlip = AddBlipForEntity(Taxi)
        SetBlipSprite (TaxiBlip, 198)
        SetBlipDisplay(TaxiBlip, 4)
        SetBlipScale  (TaxiBlip, 0.9)
        SetBlipAsShortRange(TaxiBlip, true)
        SetBlipColour(TaxiBlip, 0)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Taxi")
        EndTextCommandSetBlipName(TaxiBlip)
        Notify("Taxi", "Taxi On The Way!", "success")
        SetTimeout(Config.AutoDesapwnAfter * 60 * 1000, function()
            if Taxi then 
                DeleteEntity(Taxi)
                DeleteEntity(Driver)
                Destination = nil
                CanEnter = false
                CanLeave = false
                AtDestination = false
                Taxi = nil 
                Driver = nil
                Cost = 0.0
            end
        end) 
        TaskVehicleDriveToCoordLongrange(Driver, Taxi, PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, Config.TaxiSpeed, Config.DrivingStyle, 10.0) 
        repeat 
            Wait(10)
        until (IsEntityAtCoord(Taxi, PlayerCoords, 10.0, 10.0, 10.0, false, false, 0)) 
        CanEnter = true
        repeat 
            Wait(10)
        until (IsPedInVehicle(PlayerPed, Taxi, false))
        CanEnter = false
        Notify("Taxi", "Pin Your Location.", "primary")        
        while not Destination do 
            local waypointHandle = GetFirstBlipInfoId(8)
            local waypointCoords = GetBlipInfoIdCoord(waypointHandle)
            if waypointCoords and waypointCoords ~= vec3(0.000000, 0.000000, 0.000000) then
                Destination = waypointCoords
                break
            end
            Wait(1000)
        end
        repeat 
            Wait(10)
        until (Destination)
        TaskVehicleDriveToCoordLongrange(Driver, Taxi, Destination.x, Destination.y, Destination.z, Config.TaxiSpeed, Config.DrivingStyle, 40.0) 
        -- Cost Display -- 
        CreateThread(function()
            while not AtDestination do 
                Cost += Config.Cost
                DrawCostText(0.01, 0.5, "~b~Meter Cost~s~ : ~g~" .. string.format("$%.2f", Cost) .. "~s~")
                Wait(0)
            end
        end)
        -- Cost Display -- 
        repeat 
            Wait(10)
        until (IsEntityAtCoord(Taxi, Destination, 40.0, 40.0, 40.0, false, false, 0)) 
        AtDestination = true
        CanLeave = true 
        TriggerServerEvent('kael-ncptaxi:server:paycost', Cost)
        repeat 
            Wait(10)
        until (not IsPedInVehicle(PlayerPed, Taxi, false))
        TriggerEvent('kael-ncptaxi:client:desapwntaxi')
    else
        Notify("Taxi", "No road Nearby", 'error')
    end
end

RegisterNetEvent('kael-ncptaxi:client:desapwntaxi', function()
    Destination = nil
    CanEnter = false
    CanLeave = false
    AtDestination = false
    TaskVehicleDriveWander(Driver, Taxi, 50.0, 447)
    Wait(10000)
    DeleteEntity(Taxi)
    DeleteEntity(Driver)
    Taxi = nil 
    Driver = nil
    Cost = 0.0
end)

function RandomSpawnCoords(coords, radius)
    local x = coords.x + math.random(-radius, radius)
    local y = coords.y + math.random(-radius, radius)
    safeCoords = vector3(x, y, coords.z)    
    return safeCoords 
end


function DrawText3D(x, y, z, text)
    AddTextEntry('taxidrawtextui', text)
    SetFloatingHelpTextWorldPosition(1, x, y, z)
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
    BeginTextCommandDisplayHelp('taxidrawtextui')
    EndTextCommandDisplayHelp(2, false, true, -1)
end

function DrawCostText(x, y, text)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.5, 0.5)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

function LoadModel(model)
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        Wait(0)
    end
end

function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

function Notify(Title, Message, nType)
    QBCore.Functions.Notify(Message, nType)
end

AddEventHandler('onResourceStop', function(r) if r ~= GetCurrentResourceName() then return end
    for k, v in pairs(Targets) do exports[Config.Target]:RemoveTargetEntity(k) end
    for k, v in pairs(TargetObjs) do DeleteEntity(v) end
    RemoveBlip(TaxiBlip)
    DeleteEntity(Driver)
    DeleteEntity(Taxi)
end)

