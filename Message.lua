local Message = {}

Meeting.Message = Message

local EVENTS = {
    CREATE = "C",
    APPLICANT = "A",
    DECLINE = "D",
    MEMBERS = "M"
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

function Message.OnRecv(data)
    print(data)
    local _, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7 = stringsplit(data, ":")
    if event == EVENTS.CREATE then
        Meeting:OnCreate(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    elseif event == EVENTS.APPLICANT then
        Meeting:OnApplicant(arg1, arg2, arg3, arg4, arg5, arg6)
    elseif event == EVENTS.DECLINE then
        Meeting:OnDecline(arg1, arg2)
    elseif event == EVENTS.MEMBERS then
        Meeting:OnMembers(arg1, arg2)
    end
end

function Message.Send(event, msg)
    local lft = GetChannelName("LFT")
    if lft ~= 0 then
        SendChatMessage("Meeting:" .. event .. ":" .. msg, "CHANNEL", nil, lft)
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
