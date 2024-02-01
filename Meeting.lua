local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_HARDCORE")
f:RegisterEvent("CHAT_MSG_CHANNEL")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PARTY_MEMBERS_CHANGED")
f:RegisterEvent("RAID_ROSTER_UPDATE")
f:SetScript("OnEvent", function()
    if event == "CHAT_MSG_CHANNEL" then
        local _, _, source = string.find(arg4, "(%d+)%.")
        if source then
            _, name = GetChannelName(source)
        end
        if name == "LFT" and Meeting.Util:StringStarts(arg1, "Meeting:") then
            Meeting:OnRecv(arg1)
        end
    elseif event == "CHAT_MSG_HARDCORE" then
        isHC = true
    elseif event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" then
        local activity = Meeting:FindActivity(Meeting.player)
        if activity then
            for i, applicant in ipairs(activity.applicantList) do
                if Meeting:IsInActivity(applicant.name) then
                    table.remove(activity.applicantList, i)
                else
                    applicant.status = Meeting.APPLICANT_STATUS.None
                end
            end
            local members = Meeting:GetMembers()
            activity.members = members
            local data = string.format("%s:%d", Meeting.player, members)
            Meeting:SyncMembers(data)
            Meeting.BrowserFrame:UpdateList()
            Meeting.CreatorFrame:UpdateList()
        end

        local joined = Meeting:FindJoinedActivity()
        if joined and joined.unitname ~= Meeting.player then
            joined.applicantStatus = Meeting.APPLICANT_STATUS.Joined
            Meeting.BrowserFrame:UpdateList()
        end

        if Meeting.joinedActivity then
            local activity = Meeting:FindActivity(Meeting.joinedActivity.unitname)
            if activity then
                activity.applicantStatus = Meeting.APPLICANT_STATUS.None
                Meeting.BrowserFrame:UpdateList()
            end
        end
        Meeting.joinedActivity = joined
    elseif event == "PLAYER_ENTERING_WORLD" then

    end
end)

function Meeting:HasActivity()
    for i, item in ipairs(Meeting.activities) do
        if item.unitname == Meeting.player then
            return true
        end
    end
    return false
end

local floatFrame = Meeting.GUI.CreateButton({
    name = "MettingFloatFrame",
    width = 80,
    height = 40,
    text = "集合石",
    anchor = {
        point = "TOP",
        x = 0,
        y = 0
    },
    movable = true,
    click = function()
        Meeting:Toggle()
    end
})

local mainFrame = Meeting.GUI.CreateFrame({
    name = "MeetingMainFrame",
    width = 818,
    height = 424,
    movable = true,
    anchor = {
        point = "CENTER",
        x = 0,
        y = 0
    },
})
mainFrame:SetFrameStrata("DIALOG")
mainFrame:SetBackdrop({
    bgFile = "Interface\\BUTTONS\\WHITE8X8",
    tile = false,
    tileSize = 0,
    edgeSize = 0,
    insets = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0
    }
})
mainFrame:SetBackdropColor(0, 0, 0, 1)
mainFrame:Hide()
tinsert(UISpecialFrames, "MeetingMainFrame");
Meeting.MainFrame = mainFrame

local browserButton = Meeting.GUI.CreateButton({
    parent = mainFrame,
    width = 80,
    height = 34,
    text = "浏览活动",
    anchor = {
        point = "TOPLEFT",
        relative = mainFrame,
        relativePoint = "BOTTOMLEFT",
        x = 0,
        y = 0
    },
    click = function()
        Meeting.CreatorFrame:Hide()
        Meeting.BrowserFrame:Show()
        Meeting.BrowserFrame:UpdateList()
    end
})

Meeting.GUI.CreateButton({
    parent = mainFrame,
    width = 80,
    height = 34,
    text = "创建活动",
    anchor = {
        point = "TOPLEFT",
        relative = browserButton,
        relativePoint = "TOPRIGHT",
        x = 10,
        y = 0
    },
    click = function()
        Meeting.BrowserFrame:Hide()
        Meeting.CreatorFrame:Show()
        Meeting.CreatorFrame:UpdateList()
    end
})

function Meeting:Toggle()
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
        if Meeting.BrowserFrame:IsShown() then
            Meeting.BrowserFrame:UpdateList()
        elseif Meeting.CreatorFrame:IsShown() then
            Meeting.CreatorFrame:UpdateList()
        end
    end
end

function Meeting:SendMessage(event, data)
    if GetChannelName("LFT") ~= 0 then
        SendChatMessage("Meeting:" .. event .. ":" .. data, "CHANNEL", nil, GetChannelName("LFT"))
    end
end

function Meeting:CreateActivity(data)
    Meeting:SendMessage("CREATE", data)
end

function Meeting:Applicant(data)
    Meeting:SendMessage("APPLICANT", data)
end

function Meeting:Decline(data)
    Meeting:SendMessage("DECLINE", data)
end

function Meeting:SyncMembers(data)
    Meeting:SendMessage("MEMBERS", data)
end

function Meeting:FindActivity(creator)
    local index = -1
    for i, item in ipairs(Meeting.activities) do
        if item.unitname == creator then
            index = i
            break
        end
    end
    if index ~= -1 then
        return Meeting.activities[index]
    else
        return nil
    end
end

function Meeting:OnRecv(data)
    print(data)
    local _, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7 = Meeting.Util:StringSplit(data, ":")
    if event == "CREATE" then
        Meeting:OnCreate(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    elseif event == "APPLICANT" then
        Meeting:OnApplicant(arg1, arg2, arg3, arg4, arg5, arg6)
    elseif event == "DECLINE" then
        Meeting:OnDecline(arg1, arg2)
    elseif event == "MEMBERS" then
        Meeting:OnMembers(arg1, arg2)
    end
end

function Meeting:OnCreate(id, category, comment, level, class, members, hc)
    local item = Meeting:FindActivity(id)
    if item then
        item.category = category
        item.comment = comment
        item.level = tonumber(level)
        item.class = Meeting.NumberToClass(tonumber(class))
        item.members = tonumber(members)
        item.isHC = hc == "1"
    else
        table.insert(Meeting.activities, {
            unitname = id,
            category = category,
            comment = comment,
            level = tonumber(level),
            class = Meeting.NumberToClass(tonumber(class)),
            members = tonumber(members),
            isHC = hc == "1",
            applicantList = {}
        })
    end

    Meeting.BrowserFrame:UpdateList()
end

function Meeting:OnApplicant(id, name, level, class, score, comment)
    local item = Meeting:FindActivity(id)
    if item and item.unitname == Meeting.player then
        local applicant = {
            name = name,
            level = tonumber(level),
            class = Meeting.NumberToClass(tonumber(class)),
            score = tonumber(score),
            comment = comment,
            status = Meeting.APPLICANT_STATUS.Invited
        }

        table.insert(item.applicantList, applicant)

        Meeting.CreatorFrame:UpdateList()
    end
end

function Meeting:OnDecline(id, name)
    if name == Meeting.player then
        local item = Meeting:FindActivity(id)
        if item then
            item.applicantStatus = Meeting.APPLICANT_STATUS.Declined
            Meeting.BrowserFrame:UpdateList()
        end
    end
end

function Meeting:OnMembers(id, members)
    local activity = Meeting:FindActivity(id)
    if activity then
        activity.members = tonumber(members)
        Meeting.BrowserFrame:UpdateList()
    end
end
