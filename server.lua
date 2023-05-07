_g = {
    currentPath = GetResourcePath(GetCurrentResourceName()),
    lastUpdate  = 0,
    banData     = {},
    remoteData  = {},
}

function PrintLog(text, ...)
    if ... then
        print("^1[国服联合封禁系统]^0 " .. string.format(text, ...))
        return
    end
    print("^1[国服联合封禁系统]^0 " .. text)
end

function FilePutContent(path, content)
    local file = io.open(path, "w")
    if not file then
        return false
    end
    file:write(content)
    file:close()
    return true
end

function IsFileExists(path)
    local file = io.open(path, "r")
    if not file then
        return false
    end
    file:close()
    return true
end

function FileGetContent(path)
    local file = io.open(path, "r")
    if not file then
        return nil
    end
    local content = file:read("*a")
    file:close()
    return content
end

function Count(t)
    local count = 0
    for _, v in pairs(t) do
        count = count + 1
    end
    return count
end

function GetPlayerIdentifierData(player)
    local identifiers = GetPlayerIdentifiers(player)
    local data = {}
    for _, v in pairs(identifiers) do
        if string.find(v, "license:") then
            data.license = v
        elseif string.find(v, "steam:") then
            data.steam = v
        elseif string.find(v, "ip:") then
            data.ip = v
        elseif string.find(v, "discord:") then
            data.discord = v
        elseif string.find(v, "xbl:") then
            data.xbl = v
        elseif string.find(v, "live:") then
            data.live = v
        elseif string.find(v, "fivem:") then
            data.fivem = v
        end
    end
    return data
end

function MergeLocalData()
    if not _g.remoteData or not _g.localBanData then
        return
    end
    for _, v in pairs(_g.localBanData) do
        v.isLocal = true
        table.insert(_g.banData, v)
    end
    for _, v in pairs(_g.remoteData) do
        v.isLocal = false
        table.insert(_g.banData, v)
    end
end

--------------------------------------
-- UpdateBanData 更新封禁数据
--------------------------------------
function UpdateBanData()
    PerformHttpRequest(Config.updateApi, function(errorCode, resultData, resultHeaders)
        if errorCode ~= 200 then
            PrintLog("封禁数据更新失败，错误代码：%s", errorCode)
            return
        end
        local data = json.decode(resultData)
        if not data then
            PrintLog("封禁数据更新失败，无法解析 JSON 数据")
            return
        end
        _g.remoteData = data
        _g.lastUpdate = GetGameTimer()
        -- merge localBanData
        MergeLocalData()
        if Config.printUpdateLog then
            PrintLog("封禁数据更新成功，当前共有 %s 条记录", #data)
        end
    end, "GET", "", {["Content-Type"] = "application/json"})
end

--------------------------------------
-- IsPlayerBanned 判断玩家是否被封禁
--------------------------------------
function IsPlayerBanned(player)
    local identifiers = GetPlayerIdentifierData(player)
    return IsSteamBanned(identifiers.steam) or
        IsLicenseBanned(identifiers.license) or
        IsIpBanned(identifiers.ip) or
        IsDiscordBanned(identifiers.discord) or
        IsXblBanned(identifiers.xbl) or
        IsLiveBanned(identifiers.live) or
        IsFivemBanned(identifiers.fivem)
end

--------------------------------------
-- IsSteamBanned 判断 Steam 是否被封禁
--------------------------------------
function IsSteamBanned(steam)
    if not _g.banData or not steam then
        return false
    end
    for _, v in pairs(_g.banData) do
        if v.steam == steam then
            return v
        end
    end
    return false
end

--------------------------------------
-- IsLicenseBanned 判断 License 是否被封禁
--------------------------------------
function IsLicenseBanned(license)
    if not _g.banData or not license then
        return false
    end
    for _, v in pairs(_g.banData) do
        if v.license == license then
            return v
        end
    end
    return false
end

--------------------------------------
-- IsIpBanned 判断 IP 是否被封禁
--------------------------------------
function IsIpBanned(ip)
    if not _g.banData or not ip then
        return false
    end
    for _, v in pairs(_g.banData) do
        if v.ip == ip then
            return v
        end
    end
    return false
end

--------------------------------------
-- IsDiscordBanned 判断 Discord 是否被封禁
--------------------------------------
function IsDiscordBanned(discord)
    if not _g.banData or not discord then
        return false
    end
    for _, v in pairs(_g.banData) do
        if v.discord == discord then
            return v
        end
    end
    return false
end

--------------------------------------
-- IsXblBanned 判断 XBL 是否被封禁
--------------------------------------
function IsXblBanned(xbl)
    if not _g.banData or not xbl then
        return false
    end
    for _, v in pairs(_g.banData) do
        if v.xbl == xbl then
            return v
        end
    end
    return false
end

--------------------------------------
-- IsLiveBanned 判断 LIVE 是否被封禁
--------------------------------------
function IsLiveBanned(live)
    if not _g.banData or not live then
        return false
    end
    for _, v in pairs(_g.banData) do
        if v.live == live then
            return v
        end
    end
    return false
end

--------------------------------------
-- IsFivemBanned 判断 FiveM 是否被封禁
--------------------------------------
function IsFivemBanned(fivem)
    if not _g.banData or not fivem then
        return false
    end
    for _, v in pairs(_g.banData) do
        if v.fivem == fivem then
            return v
        end
    end
    return false
end

--------------------------------------
-- GetBanData 获取封禁数据
--------------------------------------
function GetRawBanData()
    return _g.banData
end

--------------------------------------
-- LocalBanPlayer 本地封禁玩家
--------------------------------------
function LocalBanPlayer(player, reason)
    if not reason then
        reason = "无"
    end
    if not GetPlayerEndpoint(player) then
        return false
    end
    local identifiers = GetPlayerIdentifierData(player)
    local data = {
        reason = reason,
    }
    local idTexts = ""
    for k, v in pairs(identifiers) do
        data[k] = v
        if v then
            idTexts = string.format("%s%s\n", idTexts, v)
        end
    end
    table.insert(_g.localBanData, data)
    FilePutContent(string.format("%s/%s", _g.currentPath, Config.localBanData), json.encode(_g.localBanData))
    PrintLog("玩家 ^0%s^0 已被本地封禁", GetPlayerName(player))
    MergeLocalData()
    DropPlayer(player, string.format(Config.localBanMsg, reason, idTexts))
    return true
end

--------------------------------------
-- LocalBanOffline 本地封禁离线玩家
--------------------------------------
function LocalBanOffline(identifier, reason)
    if not reason then
        reason = "无"
    end
    local data = {
        reason = reason,
    }
    if string.find(identifier, "steam:") then
        data.steam = identifier
        if IsSteamBanned(identifier) then
            return false
        end
    elseif string.find(identifier, "license:") then
        data.license = identifier
        if IsLicenseBanned(identifier) then
            return false
        end
    elseif string.find(identifier, "ip:") then
        data.ip = identifier
        if IsIpBanned(identifier) then
            return false
        end
    elseif string.find(identifier, "discord:") then
        data.discord = identifier
        if IsDiscordBanned(identifier) then
            return false
        end
    elseif string.find(identifier, "xbl:") then
        data.xbl = identifier
        if IsXblBanned(identifier) then
            return false
        end
    elseif string.find(identifier, "live:") then
        data.live = identifier
        if IsLiveBanned(identifier) then
            return false
        end
    elseif string.find(identifier, "fivem:") then
        data.fivem = identifier
        if IsFivemBanned(identifier) then
            return false
        end
    else
        return false
    end
    table.insert(_g.localBanData, data)
    MergeLocalData()
    FilePutContent(string.format("%s/%s", _g.currentPath, Config.localBanData), json.encode(_g.localBanData))
    PrintLog("^0%s^0 已被本地封禁", identifier)
    return true
end

--------------------------------------
-- LocalUnban 本地解封玩家
--------------------------------------
function LocalUnban(identifier)
    if not identifier then
        return false
    end
    local isFound = false
    for k, v in pairs(_g.localBanData) do
        if v.steam == identifier or
            v.license == identifier or
            v.ip == identifier or
            v.discord == identifier or
            v.xbl == identifier or
            v.live == identifier or
            v.fivem == identifier then
            _g.localBanData[k] = nil
            isFound = true
        end
    end
    for k, v in pairs(_g.banData) do
        if v.steam == identifier or
            v.license == identifier or
            v.ip == identifier or
            v.discord == identifier or
            v.xbl == identifier or
            v.live == identifier or
            v.fivem == identifier then
            _g.banData[k] = nil
            isFound = true
        end
    end
    if isFound then
        MergeLocalData()
        FilePutContent(string.format("%s/%s", _g.currentPath, Config.localBanData), json.encode(_g.localBanData))
        PrintLog("^0%s^0 已被本地解封", identifier)
        return true
    else
        PrintLog("^0%s^0 未被本地封禁", identifier)
    end
    return false
end

function GetMessageTemplate(title, content, image)
    content = string.gsub(content, "<code>", '<code style="background-color: rgba(0,0,0,0.3);padding: 2px 6px;border-radius: 8px;font-family: monospace;color: rgb(255,25,83);border: 2px solid rgba(255,255,255,0.15);">')
    content = string.gsub(content, "\r", "")
    content = string.gsub(content, "\n", "")
    htmlData = [[<style>.globalban>ul>li{line-height: 1.75em;!important}</style><div onclick="console.log('test');" class="globalban" style="background-color: var(--color-modal-background);padding: 0px;margin-top: -13.5em;position: relative;margin-bottom: -2.5em;z-index: 999;min-height: 18em;"><h2 style="color: rgb(255,25,83);">{{TITLE}}</h2><br><div style="font-size: 1.05rem; padding: 0px; line-height: 1.75em">{{CONTENT}}</div>{{IMAGE}}</div>]]
    htmlData = string.gsub(htmlData, "{{TITLE}}", title)
    htmlData = string.gsub(htmlData, "{{CONTENT}}", content)
    if image then
        htmlData = string.gsub(htmlData, "{{IMAGE}}", string.format('<img src="%s" style="position: absolute; right: 15px; bottom: 15px; opacity: 25%;" />', image))
    else
        htmlData = string.gsub(htmlData, "{{IMAGE}}", "")
    end
    return htmlData
end

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    if not Config.rejectBanned or WasEventCanceled() then
        return
    end
    local player      = source
    local identifiers = GetPlayerIdentifierData(player)
    local steam       = identifiers.steam
    local license     = identifiers.license
    if not steam or not license then
        return
    end
    local isBanned = IsPlayerBanned(player)
    if isBanned then
        PrintLog("玩家 %s 被拒绝连接服务器，封禁类型 %s，原因：%s", name, isBanned.isLocal and "本地" or "全局", isBanned.reason)
        local idTexts = ""
        local i = 0
        for _, v in pairs(identifiers) do
            if v then
                i = i + 1
                idTexts = idTexts .. string.format("<li style='line-height: 1.75em;'><code>%s</code></li>", v)
                if i ~= Count(identifiers) then
                    idTexts = idTexts .. "\n"
                end
            end
        end
        deferrals.defer()
        Wait(0)
        deferrals.update(string.format(Config.banMessage, isBanned.reason, idTexts))
        Wait(0)
        if not isBanned.isLocal then
            deferrals.done(GetMessageTemplate('连接被拒绝', string.format(Config.banMessage, isBanned.reason, idTexts)))
            -- setKickReason(string.format(Config.banMessage, isBanned.reason, idTexts))
        else
            deferrals.done(GetMessageTemplate('连接被拒绝', string.format(Config.localBanMsg, isBanned.reason, idTexts)))
            -- setKickReason(string.format(Config.localBanMsg, isBanned.reason, idTexts))
        end
        CancelEvent()
        return
    end
end)

RegisterCommand('localban', function(source, args, rawCommand)
    if source ~= 0 and not IsPlayerAceAllowed(source, "command.localban") then
        return
    end
    if not args[1] then
        PrintLog("参数错误，命令用法：/localban <玩家 ID> [原因]")
        return
    end
    local player = tonumber(args[1])
    if not player or not GetPlayerEndpoint(player) then
        PrintLog("玩家 ID 无效或玩家不在线，命令用法：/localban <玩家 ID> [原因]")
        return
    end
    local reason = args[2] or "无"
    LocalBanPlayer(player, reason)
end, true)

RegisterCommand('localbanoffline', function(source, args, rawCommand)
    if source ~= 0 and not IsPlayerAceAllowed(source, "command.localbanoffline") then
        return
    end
    if not args[1] then
        PrintLog("参数错误，命令用法：/localbanoffline <steam:|license:|ip:|discord:|xbl:|live:|fivem:> [原因]")
        return
    end
    local identifier = args[1]
    local reason = args[2] or "无"
    LocalBanOffline(identifier, reason)
end, true)

RegisterCommand('localunban', function(source, args, rawCommand)
    if source ~= 0 and not IsPlayerAceAllowed(source, "command.localunban") then
        return
    end
    if not args[1] then
        PrintLog("参数错误，命令用法：/localunban <steam:|license:|ip:|discord:|xbl:|live:|fivem:>")
        return
    end
    local identifier = args[1]
    LocalUnban(identifier)
end, true)

RegisterCommand('checkban', function(source, args, rawCommand)
    if source ~= 0 and not IsPlayerAceAllowed(source, "command.checkban") then
        return
    end
    if not args[1] then
        PrintLog("参数错误，命令用法：/checkban <steam:|license:|ip:|discord:|xbl:|live:|fivem:>")
        return
    end
    local isBanned = IsSteamBanned(args[1]) or IsLicenseBanned(args[1]) or IsIpBanned(args[1]) or IsDiscordBanned(args[1]) or IsXblBanned(args[1]) or IsLiveBanned(args[1]) or IsFivemBanned(args[1])
    if isBanned then
        if not isBanned.isLocal then
            PrintLog("玩家已被封禁，封禁原因：^0%s", isBanned.reason)
        else
            PrintLog("玩家已被本地封禁，封禁原因：^0%s", isBanned.reason)
        end
    else
        PrintLog("玩家未被封禁")
    end
end, true)

RegisterCommand('updatebandata', function(source, args, rawCommand)
    if source ~= 0 and not IsPlayerAceAllowed(source, "command.updatebandata") then
        return
    end
    UpdateBanData()
end, true)

Citizen.CreateThread(function()
    if IsFileExists(string.format("%s/bans.json", _g.currentPath)) then
        _g.remoteData = json.decode(FileGetContent(string.format("%s/bans.json", _g.currentPath))) or {}
    else
        UpdateBanData()
    end
    if IsFileExists(string.format("%s/%s", _g.currentPath, Config.localBanData)) then
        _g.localBanData = json.decode(FileGetContent(string.format("%s/%s", _g.currentPath, Config.localBanData))) or {}
        -- merge localBanData
        MergeLocalData()
    else
        _g.localBanData = {}
    end
    while Config.updateInterval > 0 do
        Wait(Config.updateInterval * 1000 * 60)
        UpdateBanData()
    end
end)
