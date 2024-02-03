local Message = {}

Meeting.Message = Message

local EVENTS = {
    CREATE = "C",
    APPLICANT = "A",
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
    print(data)
    local _, event, arg1, arg2, arg3, arg4, arg5, arg6 = stringsplit(data, ":")
    if event == EVENTS.CREATE then
        Meeting:OnCreate(playerName, arg1, arg2, arg3, arg4, arg5, arg6)
    elseif event == EVENTS.APPLICANT then
        Meeting:OnApplicant(playerName, arg1, arg2, arg3, arg4, arg5)
    elseif event == EVENTS.DECLINE then
        Meeting:OnDecline(playerName, arg1)
    elseif event == EVENTS.MEMBERS then
        Meeting:OnMembers(playerName, arg1)
    elseif event == EVENTS.CLOSE then
        Meeting:OnClose(playerName)
    end
end

function Message.Send(event, msg)
    local channel = GetChannelName("LFT")
    if channel ~= 0 then
        SendChatMessage("Meeting:" .. event .. ":" .. msg, "CHANNEL", nil, channel)
    else
        print("LFT频道不存在，请先加入LFT频道")
    end
end

function Message.CreateActivity(data)
    Message.Send(EVENTS.CREATE, data)
end

function Message.Applicant(data)
    Message.Send(EVENTS.APPLICANT, data)
end

function Message.Decline(data)
    Message.Send(EVENTS.DECLINE, data)
end

function Message.SyncMembers(data)
    Message.Send(EVENTS.MEMBERS, data)
end

function Message.CloseActivity()
    Message.Send(EVENTS.CLOSE, "")
end
