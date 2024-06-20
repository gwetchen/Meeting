local Message = {}

Meeting.Message = Message

local EVENTS = {
    CREATE = "C",
    REQUEST = "R",
    DECLINE = "D",
    MEMBERS = "M",
    CLOSE = "L",
    VERSION = "V",
}

local function CheckBlockWords(playerName, message)
    if playerName ~= Meeting.player and message and message ~= "_" then
        for _, word in ipairs(Meeting.blockWords) do
            if string.find(message, word) then
                return true
            end
        end
    end
    return false
end

function Message.OnRecv(playerName, data)
    local _, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7 = string.meetingsplit(data, ":")
    if event == EVENTS.CREATE then
        if CheckBlockWords(playerName, arg2) then
            return
        end
        Meeting:OnCreate(playerName, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    elseif event == EVENTS.REQUEST then
        Meeting:OnRequest(playerName, arg1, arg2, arg3, arg4, arg5, arg6)
    elseif event == EVENTS.DECLINE then
        Meeting:OnDecline(playerName, arg1)
    elseif event == EVENTS.MEMBERS then
        Meeting:OnMembers(playerName, arg1, arg2)
    elseif event == EVENTS.CLOSE then
        Meeting:OnClose(playerName)
    elseif event == EVENTS.VERSION then
        Meeting:OnVersion(arg1)
    end
end

local matchText = {}
for _, category in ipairs(Meeting.Categories) do
    for _, value in ipairs(category.children) do
        if value.match then
            for _, match in ipairs(value.match) do
                table.insert(matchText, match)
            end
        end
    end
end

local distinct = {}
for _, v in ipairs(matchText) do
    if not distinct[v] then
        distinct[v] = true
    end
end
matchText = {}
for k, _ in pairs(distinct) do
    table.insert(matchText, k)
end
distinct = nil

function Message.OnRecvFormChat(channel, playerName, message)
    local activity = Meeting:FindActivity(playerName)
    if activity and not activity:IsChat() then
        return
    end

    if string.find(message, "LFG") then
        return
    end

    if CheckBlockWords(playerName, message) then
        return
    end

    local lowerMessage = string.lower(message)
    for _, v in ipairs(matchText) do
        if string.find(lowerMessage, v) then
            Meeting:OnCreate(playerName, string.upper(channel), message, "0", "0", "0",
                channel == "hardcore" and "1" or "0")
            return
        end
    end
end

function Message.Send(event, msg)
    local channel = GetChannelName(Meeting.channel)
    if channel ~= 0 then
        SendChatMessage("Tub:" .. event .. ":" .. msg, "CHANNEL", nil, channel)
    else
        print("Plaese join the " .. Meeting.channel .. " channel first")
    end
end

function Message.CreateActivity(code, comment)
    local data = string.format("%s:%s:%d:%d:%d:%d:%s", code,
        string.isempty(comment) and "_" or comment, UnitLevel("player"),
        Meeting.ClassToNumber(Meeting.playerClass),
        table.getn(Meeting.members) + 1, Meeting.playerIsHC and 1 or 0, Meeting.EncodeGroupClass())
    MEETING_DB.activity = {
        code = code,
        comment = comment,
        lastTime = time()
    }
    Message.InvokeSyncActivityTimer()
    Message.Send(EVENTS.CREATE, data)
end

function Message.Request(id, comment, role)
    local data = string.format("%s:%d:%d:%d:%s:%d", id, UnitLevel("player"),
        Meeting.ClassToNumber(Meeting.playerClass), Meeting.GetPlayerScore(), string.isempty(comment) and "_" or comment,
        role)
    Message.Send(EVENTS.REQUEST, data)
end

function Message.Decline(name)
    Message.Send(EVENTS.DECLINE, string.format("%s", name))
end

function Message.SyncMembers(members)
    Message.Send(EVENTS.MEMBERS, string.format("%d:%s", members, Meeting.EncodeGroupClass()))
end

function Message.CloseActivity(leave)
    Message.Send(EVENTS.CLOSE, "")
    if not leave then
        MEETING_DB.activity = nil
    end
end

function Message.SendVersion()
    Message.Send(EVENTS.VERSION, Meeting.VERSION.MAJOR .. "." .. Meeting.VERSION.MINOR .. "." .. Meeting.VERSION.PATCH)
end

local syncTimer = nil

function Message.InvokeSyncActivityTimer()
    if syncTimer then
        syncTimer:Cancel()
    end

    syncTimer = C_Timer.NewTicker(60, function()
        if Meeting.isAFK then
            return
        end
        local activity = Meeting:FindActivity(Meeting.player)
        if activity then
            Message.CreateActivity(activity.code, activity.comment)
        end
    end, -1)
end
