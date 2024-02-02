local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_HARDCORE")
f:RegisterEvent("CHAT_MSG_CHANNEL")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PARTY_MEMBERS_CHANGED")
f:RegisterEvent("PARTY_LEADER_CHANGED")
f:RegisterEvent("RAID_ROSTER_UPDATE")
f:SetScript("OnEvent", function()
    if event == "CHAT_MSG_CHANNEL" then
        local _, _, source = string.find(arg4, "(%d+)%.")
        if source then
            _, name = GetChannelName(source)
        end
        if name == "LFT" and string.startswith(arg1, "Meeting:") then
            Meeting.Message.OnRecv(arg1)
        end
    elseif event == "CHAT_MSG_HARDCORE" then
        Meeting.playerIsHC = true
    elseif event == "PARTY_LEADER_CHANGED" then
        if Meeting:GetMembers() > 1 and IsRaidLeader() ~= 1 then
            if Meeting:FindActivity(Meeting.player) then
                Meeting.Message.CloseActivity(Meeting.player)
            end
        end
        Meeting.CreatorFrame.UpdateActivity()
    elseif event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" then
        local needUpdateBrowser = false

        local activity = Meeting:FindActivity(Meeting.player)
        if activity then
            needUpdateBrowser = true
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
            Meeting.Message.SyncMembers(data)
            Meeting.CreatorFrame:UpdateList()
        end

        local joined = Meeting:FindJoinedActivity()
        if joined and joined.unitname ~= Meeting.player then
            joined.applicantStatus = Meeting.APPLICANT_STATUS.Joined
            needUpdateBrowser = true
        end

        if Meeting.joinedActivity then
            local activity = Meeting:FindActivity(Meeting.joinedActivity.unitname)
            if activity then
                activity.applicantStatus = Meeting.APPLICANT_STATUS.None
                needUpdateBrowser = true
            end
        end

        if needUpdateBrowser then
            Meeting.BrowserFrame:UpdateList()
        end
        Meeting.CreatorFrame.UpdateActivity()
        Meeting.joinedActivity = joined
    elseif event == "PLAYER_ENTERING_WORLD" then
        Meeting.CheckPlayerHCMode()
    end
end)

function Meeting.CheckPlayerHCMode()
    local i = 1
    while true do
        local spellName, _ = GetSpellName(i, BOOKTYPE_SPELL)
        if not spellName then
            break
        end
        if spellName == "硬核模式" then
            Meeting.playerIsHC = true
            break
        else
            i = i + 1
        end
    end
end

function Meeting:HasActivity()
    for i, item in ipairs(Meeting.activities) do
        if item.unitname == Meeting.player then
            return true
        end
    end
    return false
end

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

local headerFrame = Meeting.GUI.CreateFrame({
    parent = mainFrame,
    width = 818,
    height = 34,
    anchor = {
        point = "TOP",
        relative = mainFrame,
        relativePoint = "TOP",
    }
})

Meeting.GUI.CreateText({
    parent = headerFrame,
    text = "集合石 " .. tostring(GetAddOnMetadata("Meeting", "Version")),
    fontSize = 16,
    anchor = {
        point = "TOP",
        relative = headerFrame,
        relativePoint = "TOP",
        x = 0,
        y = -10
    }
})

Meeting.GUI.CreateText({
    parent = headerFrame,
    text = "问题和建议前往龟壳KOOK",
    fontSize = 10,
    anchor = {
        point = "TOPRIGHT",
        relative = headerFrame,
        relativePoint = "TOPRIGHT",
        x = -10,
        y = -12
    }
})

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

function Meeting:FindActivity(creator)
    local index = -1
    for i, item in ipairs(Meeting.activities) do
        if item.unitname == creator then
            index = i
            break
        end
    end
    if index ~= -1 then
        return Meeting.activities[index], index
    else
        return nil
    end
end

function Meeting:DeleteActivity(id)
    local index = -1
    for i, item in ipairs(Meeting.activities) do
        if item.unitname == id then
            index = i
            break
        end
    end
    if index ~= -1 then
        local activity = Meeting.activities[index]
        table.remove(Meeting.activities, index)
        return activity
    end
end

local syncTimer = nil

function Meeting:SyncActivity()
    if syncTimer then
        syncTimer:Cancel()
    end

    syncTimer = C_Timer.NewTicker(60, function()
        local activity = Meeting:FindActivity(Meeting.player)
        if activity then
            local data = string.format("%s:%s:%s:%d:%d:%d:%d", Meeting.player, activity.category,
                string.isempty(activity.comment) and "_" or activity.comment, UnitLevel("player"),
                Meeting.ClassToNumber(Meeting.playerClass), Meeting:GetMembers(), Meeting.playerIsHC and 1 or 0)
            Meeting.Message.CreateActivity(data)
        end
    end, -1)
end

function Meeting:OnCreate(id, category, comment, level, class, members, hc)
    local item, index = Meeting:FindActivity(id)
    if item then
        item.parent = Meeting.GetCategoryParent(category).key
        item.category = category
        item.comment = comment
        item.level = tonumber(level)
        item.class = Meeting.NumberToClass(tonumber(class))
        item.members = tonumber(members)
        item.isHC = hc == "1"
        table.remove(Meeting.activities, index)
        table.insert(Meeting.activities, 1, item)
    else
        table.insert(Meeting.activities, 1, {
            unitname = id,
            parent = Meeting.GetCategoryParent(category).key,
            category = category,
            comment = comment,
            level = tonumber(level),
            class = Meeting.NumberToClass(tonumber(class)),
            members = tonumber(members),
            isHC = hc == "1",
            applicantList = {}
        })
    end
    Meeting.FloatFrame.Update()
    Meeting.CreatorFrame.UpdateActivity()
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
    Meeting.FloatFrame.Update()
end

function Meeting:OnDecline(id, name)
    if name == Meeting.player then
        local item = Meeting:FindActivity(id)
        if item then
            item.applicantStatus = Meeting.APPLICANT_STATUS.Declined
            Meeting.BrowserFrame:UpdateList()
        end
    end
    Meeting.FloatFrame.Update()
end

function Meeting:OnMembers(id, members)
    local activity, index = Meeting:FindActivity(id)
    if activity then
        activity.members = tonumber(members)
        table.remove(Meeting.activities, index)
        table.insert(Meeting.activities, 1, activity)
        Meeting.BrowserFrame:UpdateList()
    end
end

function Meeting:OnClose(id)
    local activity = Meeting:DeleteActivity(id)
    if activity and activity.unitname == Meeting.player then
        Meeting.CreatorFrame.UpdateActivity()
    end

    if Meeting.joinedActivity and Meeting.joinedActivity.unitname == id then
        Meeting.joinedActivity = nil
    end
    Meeting.BrowserFrame:UpdateList()
    Meeting.FloatFrame.Update()
end
