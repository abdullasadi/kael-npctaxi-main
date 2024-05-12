local QBCore = exports[Config.Core]:GetCoreObject()

RegisterNetEvent('kael-ncptaxi:server:paycost', function(Cost)
    local src = source 
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveMoney("bank", Cost, "Taxi Fee")
end)

if Config.VIP.Enable then
    RegisterCommand(Config.VIP.Command, function(source)
        local src = source        
        local Player = QBCore.Functions.GetPlayer(src)
        local HasRole = GetDiscord(src, Config.VIP.DiscordRoleID)
        if HasRole then
            TriggerClientEvent('kael-npctaxi:client:calltaxi', src)
        else
            Notify(src, "Taxi", "You Are Not VIP.", "error")
        end
    end)
end

function GetDiscord(src, role)
    local HasRole = exports.zdiscord:isRolePresent(src, role);
    if HasRole then 
        return true
    else
        return false
    end
end

function Notify(SRC, Title, Message, nType)
    TriggerClientEvent('QBCore:Notify', SRC, Message, nType)
end