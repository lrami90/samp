-- С любовью от Такуми Фудзивары 04 (Лёша я тебя ненавижу :c)
-- Лёша ты падла. Я заебался фиксить эту хуету. 

local se = require 'lib.samp.events'
local scriptTag = '{ffaa00}[Bot Logger]{ffffff} | '

local arrayCommandsTrigger = {
                                {"/banip", "(%w+_%w+)(%W+)"},
                                {"/ban", "(%w+_%w+) (%d+) (%W+)"},
                                {"/jail", "(%w+_%w+) (%d+) (%W+)"},
                             }
local arrayWordsTrigger = {"бот", "Бот", "рванка", "Рванка"}

-- temp vars
local playerID, causeTime, reason = ""
local bIP = false
local clipboardText = ""
local lastIP = ""

function se.onSendCommand(msg)
    local bCheckCmd = false
    for k = 1, #arrayWordsTrigger do
        if msg:find(arrayWordsTrigger[k]) then
            bCheckCmd = true
            break
        end
    end

    if not bCheckCmd then return true end

    playerID, causeTime, reason = ""
    local lMsg = string.gsub(msg, "/a ", "")
    for i = 1, #arrayCommandsTrigger do
        if arrayCommandsTrigger[i][1] == string.match(lMsg, "(/%w+)") then
            lMsg = string.gsub(lMsg, arrayCommandsTrigger[i][1], "")

            if string.find(arrayCommandsTrigger[i][1], "banip") then
                playerID, reason = string.match(lMsg, arrayCommandsTrigger[i][2])
            else
                playerID, causeTime, reason = string.match(lMsg, arrayCommandsTrigger[i][2])
            end
            if playerID == nil or reason == nil then
                sampAddChatMessage(scriptTag .. "Произошла ошибка логирования.", -1)
                return true
            end
            if isCheckDuplicate(2, playerID) then
                printStringNow("~r~[Bot Logger] ~g~Banoff logged", 1500)
                botLogWriteBan(playerID, reason)
                break
            end
        end
    end   
    bCheckCmd = false   
end

function main()
    while not isSampAvailable() do wait(0) end

    sampAddChatMessage(scriptTag .. 'Загружен! Просмотр логов /bipshow либо /bbanshow', -1)

    sampRegisterChatCommand('bipshow', function()
        sampShowDialog(9669, "{ffaa00}[Bot Logger] IP", botLogReadIP(), 'ОК', nil, 2)
    end)

    sampRegisterChatCommand('bbanshow', function()
        sampShowDialog(9670, "{ffaa00}[Bot Logger] Banoff", botLogReadBan(), 'ОК', nil, 2)
    end)

    sampRegisterChatCommand('nearcopy', function()
        local f = io.open(getWorkingDirectory() .. "\\near.txt", "w+")
        for i = 0,1000 do
            _, ped = sampGetCharHandleBySampPlayerId(i)
            if _ then
                f:write("[" .. sampGetPlayerScore(i) .. "] /banoff 0 " .. sampGetPlayerNickname(i) .. " 2000 Бот // Такуми" .. "\n")
            end
        end
        f:close()
        printStringNow("~r~[Bot Logger] ~g~Near Players Copyed", 1500)
    end)

     lua_thread.create(function()
        while true do
            wait(0)
            if bIP then
                if isCheckDuplicate(1, clipboardText) then
                    botLogWriteIP(clipboardText)
                    bIP = false
                    printStringNow("~r~[Bot Logger] ~g~IP logged", 1500)
                end
            end
        end
    end)

    while true do
        wait(100)
        clipboardText = getClipboardText()
        if isIP(clipboardText) then
            if not string.find(lastIP, clipboardText) then
                lastIP = clipboardText
                bIP = true
            end
        end
    end
end

-- Banoff
function botLogWriteBan(pNick, pReason)
    local f = io.open(getWorkingDirectory() .. "\\botip_logs_banoff.txt", "a")
    f:write("/banoff 0 " .. pNick .. " 2000 " .. pReason .. "\n")
    f:close()
end

function botLogReadBan()
    local f = io.open(getWorkingDirectory() .. "\\botip_logs_banoff.txt", "r")
    fileContent = f:read("*a")
    f:close()
    return fileContent
end

-- IP
function botLogWriteIP(playerIP)
    local f = io.open(getWorkingDirectory() .. "\\botip_logs_ip.txt", "a")
    f:write(playerIP .. "\n")
    f:close()
end

function botLogReadIP()
    local f = io.open(getWorkingDirectory() .. "\\botip_logs_ip.txt", "r")
    fileContent = f:read("*a")
    f:close()
    return fileContent
end

function isCheckDuplicate(mode, text)
    if mode == 1 then
        local f = io.open(getWorkingDirectory() .. "\\botip_logs_ip.txt", "r")
        fileContent = f:read("*a")
        if not fileContent:find(text) then
            return true
        end
        f:close()
    end

    if mode == 2 then
        local f = io.open(getWorkingDirectory() .. "\\botip_logs_banoff.txt", "r")
        fileContent = f:read("*a")
        if not fileContent:find(text) then
            return true
        end
        f:close()
    end
    return false
end

function isIP(ip)
    if not ip then return false end

    local a,b,c,d=ip:match("^(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)$")
    a=tonumber(a)
    b=tonumber(b)
    c=tonumber(c)
    d=tonumber(d)

    if not a or not b or not c or not d then return false end
    if a<0 or 255<a then return false end
    if b<0 or 255<b then return false end
    if c<0 or 255<c then return false end
    if d<0 or 255<d then return false end

    return true
end