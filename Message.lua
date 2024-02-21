local Message = {}

Meeting.Message = Message

local EVENTS = {
    CREATE = "C",
    REQUEST = "R",
    DECLINE = "D",
    MEMBERS = "M",
    CLOSE = "L",
}

local function stringsplit(str, delimiter)
    if not str then
        return nil
    end
    local delimiter, fields = delimiter or ":", {}
    local pattern = string.format("([^%s]+)", delimiter)
    string.gsub(str, pattern, function(c)
        fields[table.getn(fields) + 1] = c
    end)
    return unpack(fields)
end

function Message.OnRecv(playerName, data)
    local _, event, arg1, arg2, arg3, arg4, arg5, arg6 = stringsplit(data, ":")
    if event == EVENTS.CREATE then
        Meeting:OnCreate(playerName, arg1, arg2, arg3, arg4, arg5, arg6)
    elseif event == EVENTS.REQUEST then
        Meeting:OnRequest(playerName, arg1, arg2, arg3, arg4, arg5, arg6)
    elseif event == EVENTS.DECLINE then
        Meeting:OnDecline(playerName, arg1)
    elseif event == EVENTS.MEMBERS then
        Meeting:OnMembers(playerName, arg1)
    elseif event == EVENTS.CLOSE then
        Meeting:OnClose(playerName)
    end
end

local matchText = {}
for _, parent in ipairs(Meeting.Categories) do
    for _, value in ipairs(parent.children) do
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

function Message.OnRecvFormChat(playerName, message)
    local activity = Meeting:FindActivity(playerName)
    if activity and activity.category ~= "WORLD" then
        return
    end

    local lowerMessage = string.lower(message)
    for _, v in ipairs(matchText) do
        if string.find(lowerMessage, v) then
            Meeting:OnCreate(playerName, "WORLD", message, "0", "0", "0", "0")
            return
        end
    end
end

function Message.Send(event, msg)
    local channel = GetChannelName(Meeting.channel)
    if channel ~= 0 then
        SendChatMessage("Meeting:" .. event .. ":" .. msg, "CHANNEL", nil, channel)
    else
        print("请先加入" .. Meeting.channel .. "频道")
    end
end

function Message.CreateActivity(category, comment)
    local data = string.format("%s:%s:%d:%d:%d:%d", category,
        string.isempty(comment) and "_" or comment, UnitLevel("player"),
        Meeting.ClassToNumber(Meeting.playerClass),
        Meeting:GetMembers(), Meeting.playerIsHC and 1 or 0)
    MEETING_DB.activity = {
        category = category,
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
    Message.Send(EVENTS.MEMBERS, string.format("%d", members))
end

function Message.CloseActivity()
    Message.Send(EVENTS.CLOSE, "")
end

local syncTimer = nil

function Message.InvokeSyncActivityTimer()
    if syncTimer then
        syncTimer:Cancel()
    end

    syncTimer = C_Timer.NewTicker(60, function()
        local activity = Meeting:FindActivity(Meeting.player)
        if activity then
            Message.CreateActivity(activity.category, activity.comment)
        end
    end, -1)
end
