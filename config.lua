Config = {
    Debug = false,
    Core = 'qb-core',  
    Target = 'qb-target',
}

Config.VIP = {
    Enable = true, -- Required zdiscord 
    DiscordRoleID = "1035785646083678208",
    Command = "calltaxi",
}

Config.DriverModel = "csb_prologuedriver"
Config.TaxiModel = "taxi"
Config.TaxiSpeed = 60.0
Config.DrivingStyle = 262462 -- Don't Change If you don't know.
Config.AutoDesapwnAfter = 30 -- min
Config.Cost = 0.01 -- per milisecound

Config.StandBlip = {
    Enable = true,
    Color = 60,
    Icon = 198,  
    Size = 0.5, 
    Text = "Taxi Stand", 
}
Config.BoothModel = "prop_phonebox_04"
Config.TaxiStands = {
    vector4(216.03, -813.73, 29.66, 332.51),
    vector4(418.18, -986.4, 28.39, 272.54),
    vector4(-94.27, 6391.36, 30.45, 224.51),
    vector4(1692.51, 3737.79, 32.83, 37.19),
    vector4(291.52, -561.52, 43.26, 252.53),
}

Config.VehKeyExports = function(veh, plate, model)
    -- Set your own vehicle keys export here..
    TriggerEvent("vehiclekeys:client:SetOwner", plate)
    -- Set your own vehicle keys export here.. 
end




