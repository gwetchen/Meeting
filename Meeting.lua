local AFK_MESSAGE = string.format(MARKED_AFK_MESSAGE, DEFAULT_AFK_MESSAGE)

local function GetMembers()
    local members = {}
    for i = 1, GetNumRaidMembers() do
        local n = UnitName("raid" .. i)
        table.insert(members, n)
    end
    if table.getn(members) == 0 then
        for i = 1, GetNumPartyMembers() do
            local n = UnitName("party" .. i)
            table.insert(members, n)
        end
    end
    return members
end

local function OnMemberChange()
    Meeting.members = GetMembers()

    local joined = nil
    for _, activity in ipairs(Meeting.activities) do
        for _, member in ipairs(Meeting.members) do
            if member == activity.unitname then
                joined = activity
                break
            end
        end
    end

    local needUpdateBrowser = false
    local needUpdateCreator = false
    local activity = joined or Meeting:FindActivity(Meeting.player)
    if activity then
        needUpdateBrowser = true
        for i, applicant in ipairs(activity.applicantList) do
            local isMember = false
            for _, member in ipairs(Meeting.members) do
                if member == applicant.name then
                    isMember = true
                    break
                end
            end
            if isMember then
                table.remove(activity.applicantList, i)
            else
                applicant.status = Meeting.APPLICANT_STATUS.None
            end
        end

        if activity.unitname == Meeting.player then
            local members = table.getn(Meeting.members) + 1
            activity.members = members
            Meeting.Message.SyncMembers(members)
            if members >= Meeting.GetActivityMaxMembers(activity.code) then
                Meeting.Message.CloseActivity()
            end
        end
        needUpdateCreator = true
    end

    local ml = table.getn(Meeting.members)
    local isLeader = ml == 0 or (ml > 0 and IsRaidLeader() == 1)
    if not isLeader then
        local activity
        Meeting:FindActivity(Meeting.player)
        if activity and not activity:IsChat() then
            Meeting.Message.CloseActivity()
            needUpdateBrowser = true
            needUpdateCreator = true
        end
    end

    if joined and joined.unitname ~= Meeting.player then
        joined.applicantStatus = Meeting.APPLICANT_STATUS.Joined
        Meeting.BrowserFrame:UpdateActivity(joined)
        needUpdateBrowser = true
    end

    if Meeting.joinedActivity then
        local activity = Meeting:FindActivity(Meeting.joinedActivity.unitname)
        if activity then
            activity.applicantStatus = Meeting.APPLICANT_STATUS.None
            needUpdateBrowser = true
        end
        if not joined then
            needUpdateCreator = true
        end
    end

    Meeting.joinedActivity = joined

    if needUpdateBrowser then
        Meeting.BrowserFrame:UpdateList()
    end
    Meeting.CreatorFrame.UpdateActivity()
    if needUpdateCreator then
        Meeting.CreatorFrame:UpdateList()
    end
end

local f = CreateFrame("Frame", "Meeting", UIParent)
f:RegisterEvent("CHAT_MSG_HARDCORE")
f:RegisterEvent("CHAT_MSG_CHANNEL")
f:RegisterEvent("CHAT_MSG_SYSTEM")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LEAVING_WORLD")
f:RegisterEvent("PARTY_MEMBERS_CHANGED")
f:RegisterEvent("PARTY_LEADER_CHANGED")
f:RegisterEvent("RAID_ROSTER_UPDATE")
f:RegisterEvent("SPELLS_CHANGED")
f:SetScript("OnEvent", function()
    if event == "CHAT_MSG_CHANNEL" then
        local _, _, source = string.find(arg4, "(%d+)%.")
        local name = nil
        if source then
            _, name = GetChannelName(source)
        end
        if name then
            if name == Meeting.channel and string.startswith(arg1, "Meeting:") then
                Meeting.Message.OnRecv(arg2, arg1)
            else
                local lowname = string.lower(name)
                if lowname == "world" or lowname == "china" or lowname == "世界频道" then
                    if lowname == "世界频道" then
                        lowname = "world"
                    end
                    Meeting.Message.OnRecvFormChat(lowname, arg2, arg1)
                end
            end
        end
    elseif event == "CHAT_MSG_HARDCORE" then
        Meeting.Message.OnRecvFormChat("hardcore", arg2, arg1)
    elseif event == "PARTY_LEADER_CHANGED" then
        if table.getn(Meeting.members) > 0 and IsRaidLeader() ~= 1 then
            if Meeting:FindActivity(Meeting.player) then
                Meeting.Message.CloseActivity()
            end
        end
        Meeting.CreatorFrame.UpdateActivity()
    elseif event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" then
        OnMemberChange()
    elseif event == "PLAYER_ENTERING_WORLD" then
        Meeting.CheckLFTChannel()
        Meeting.CheckPlayerHCMode()
        Meeting.Message.SendVersion()
        Meeting.members = GetMembers()
        if MEETING_DB.activity then
            local now = time()
            if now - MEETING_DB.activity.lastTime < 120 then
                MEETING_DB.activity.lastTime = now
                Meeting.createInfo.code = MEETING_DB.activity.code
                Meeting.createInfo.comment = MEETING_DB.activity.comment == "_" and "" or MEETING_DB.activity.comment
                Meeting.CreatorFrame.UpdateActivity()
                Meeting.Message.CreateActivity(Meeting.createInfo.code, Meeting.createInfo.comment)
            end
        end

        if MEETING_DB.hideFloat == 1 then
            Meeting.FloatFrame:Hide()
        else
            Meeting.FloatFrame:Show()
        end
    elseif event == "PLAYER_LEAVING_WORLD" then
        if Meeting:FindActivity(Meeting.player) then
            Meeting.Message.CloseActivity(true)
        end
    elseif event == "CHAT_MSG_SYSTEM" then
        local _, _, playerName = string.find(arg1, "^(.+)拒绝了你邀请其加入队伍的请求。")
        if playerName then
            Meeting.DeclinedInvite(playerName)
        end

        if arg1 == AFK_MESSAGE then
            Meeting.isAFK = true
        elseif arg1 == CLEARED_AFK then
            Meeting.isAFK = false
        end
    elseif event == "SPELLS_CHANGED" then
        Meeting.CheckPlayerHCMode()
    end
end)

Meeting.isHover = false
f:SetScript("OnUpdate", function()
    if not Meeting.MainFrame:IsShown() or not Meeting.BrowserFrame:IsShown() then
        return
    end
    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    local t = Meeting.MainFrame:GetTop() * scale
    local b = Meeting.MainFrame:GetBottom() * scale
    local l = Meeting.MainFrame:GetLeft() * scale
    local r = Meeting.MainFrame:GetRight() * scale
    local cur = x >= l and x <= r and y >= b and y <= t
    if cur ~= Meeting.isHover then
        Meeting.isHover = cur
        if not cur then
            Meeting.BrowserFrame:UpdateList()
        end
    end
end)

function Meeting.CheckPlayerHCMode()
    local isHC = false
    local i = 1
    while true do
        local spellName, _ = GetSpellName(i, BOOKTYPE_SPELL)
        if not spellName then
            break
        end
        if spellName == "硬核模式" then
            isHC = true
            break
        else
            i = i + 1
        end
    end
    Meeting.playerIsHC = isHC
end

function Meeting:OwnerActivity()
    for i, item in ipairs(Meeting.activities) do
        if item.unitname == Meeting.player then
            return item
        end
    end
    return nil
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
Meeting.GUI.SetBackground(mainFrame, Meeting.GUI.Theme.Brown)
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
local line = mainFrame:CreateTexture()
line:SetWidth(818)
line:SetHeight(0.5)
line:SetTexture(1, 1, 1, 0.5)
line:SetPoint("TOPLEFT", headerFrame, "BOTTOMLEFT", 0, 0)

local title = "集合石 " .. Meeting.VERSION.MAJOR .. "." .. Meeting.VERSION.MINOR .. "." .. Meeting.VERSION.PATCH
local titleFrame = Meeting.GUI.CreateText({
    parent = headerFrame,
    text = title,
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
        point = "TOPLEFT",
        relative = headerFrame,
        relativePoint = "TOPLEFT",
        x = 10,
        y = -12
    }
})

Meeting.GUI.CreateButton({
    parent = headerFrame,
    width = 14,
    height = 14,
    text = "X",
    type = Meeting.GUI.BUTTON_TYPE.DANGER,
    anchor = {
        point = "TOPRIGHT",
        relative = headerFrame,
        relativePoint = "TOPRIGHT",
        x = -10,
        y = -10
    },
    click = function()
        Meeting:Toggle()
    end
})

Meeting.GUI.CreateTabs({
    parent = mainFrame,
    width = 80,
    height = 34,
    anchor = {
        point = "TOPLEFT",
        relative = mainFrame,
        relativePoint = "BOTTOMLEFT",
        x = 0,
        y = 0
    },
    list = {
        {
            title = "浏览活动",
            select = function()
                Meeting.CreatorFrame:Hide()
                Meeting.BrowserFrame:Show()
                Meeting.BrowserFrame:UpdateList()
            end
        },
        {
            title = "管理活动",
            select = function()
                Meeting.BrowserFrame:Hide()
                Meeting.CreatorFrame:Show()
                Meeting.CreatorFrame:UpdateList()
                Meeting.CreatorFrame:UpdateActivity()
            end
        },
    }
})

function Meeting:Toggle()
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
        if Meeting.BrowserFrame:IsShown() then
            Meeting.BrowserFrame:UpdateList(true)
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

function Meeting:OnCreate(id, code, comment, level, class, members, hc, classnum)
    local item, index = Meeting:FindActivity(id)
    local code = Meeting.GetActivityInfo(code).key
    local class = Meeting.NumberToClass(tonumber(class))
    local classColor = Meeting.GetClassRGBColor(class, id)
    if item then
        item.category = Meeting.GetActivityCategory(code).key
        item.code = code
        item.comment = comment
        item.level = tonumber(level)
        item.class = class
        item.members = tonumber(members)
        item.isHC = hc == "1"
        item.updated = time()
        item.classColor = classColor
        if classnum then
            item.classnum = classnum
        end
        table.remove(Meeting.activities, index)
    else
        item = {
            unitname = id,
            category = Meeting.GetActivityCategory(code).key,
            code = code,
            comment = comment,
            level = tonumber(level),
            class = class,
            members = tonumber(members),
            isHC = hc == "1",
            updated = time(),
            applicantList = {},
            classnum = classnum,
            classColor = classColor,
            IsChat = function(self)
                return self.category == "CHAT"
            end,
            GetClassMap = function(self)
                return Meeting.DecodeGroupClass(self.classnum)
            end
        }
    end

    for _, member in ipairs(Meeting.members) do
        if member == item.unitname then
            Meeting.joinedActivity = item
            break
        end
    end

    table.insert(Meeting.activities, 1, item)
    if item:IsChat() and table.getn(Meeting.activities) > 1 then
        table.sort(Meeting.activities, function(a, b)
            if a:IsChat() and not b:IsChat() then
                return false
            elseif not a:IsChat() and b:IsChat() then
                return true
            else
                return a.updated > b.updated
            end
        end)
    end

    Meeting.FloatFrame.Update()
    Meeting.CreatorFrame.UpdateActivity()
    Meeting.BrowserFrame:UpdateList()
end

function Meeting:OnRequest(name, id, level, class, score, comment, role)
    local activity = Meeting:FindActivity(id)
    if activity and (activity.unitname == Meeting.player or (Meeting.joinedActivity and Meeting.joinedActivity.unitname == id)) then
        local i = -1
        for index, value in ipairs(activity.applicantList) do
            if value.name == name then
                i = index
                break
            end
        end
        if i ~= -1 then
            local applicant = activity.applicantList[i]
            applicant.level = tonumber(level)
            applicant.score = tonumber(score)
            applicant.comment = comment
            applicant.status = Meeting.APPLICANT_STATUS.None
            applicant.role = role and tonumber(role) or 0
        else
            local applicant = {
                name = name,
                level = tonumber(level),
                class = Meeting.NumberToClass(tonumber(class)),
                score = tonumber(score),
                comment = comment,
                status = Meeting.APPLICANT_STATUS.None,
                role = role and tonumber(role) or 0
            }
            table.insert(activity.applicantList, applicant)
        end
        PlaySoundFile("Interface\\AddOns\\Meeting\\assets\\request.ogg")

        Meeting.CreatorFrame:UpdateList()
        Meeting.FloatFrame.Update()
    end
end

function Meeting:OnDecline(id, name)
    if name == Meeting.player then
        local activity = Meeting:FindActivity(id)
        if activity then
            activity.applicantStatus = Meeting.APPLICANT_STATUS.Declined
            Meeting.BrowserFrame:UpdateActivity(activity)
            Meeting.BrowserFrame:UpdateList()
        end
    end
    if id ~= Meeting.player and Meeting.joinedActivity and Meeting.joinedActivity.unitname == id then
        local i = -1
        for index, value in ipairs(Meeting.joinedActivity.applicantList) do
            if value.name == name then
                i = index
                break
            end
        end
        table.remove(Meeting.joinedActivity.applicantList, i)
        Meeting.CreatorFrame:UpdateList()
    end
    Meeting.FloatFrame.Update()
end

function Meeting:OnMembers(id, members, classnum)
    local activity, index = Meeting:FindActivity(id)
    if activity then
        activity.members = tonumber(members)
        activity.classnum = classnum
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
    Meeting.CreatorFrame:UpdateList()
    Meeting.FloatFrame.Update()
end

function Meeting.DeclinedInvite(playerName)
    local activity = Meeting:FindActivity(Meeting.player)
    if activity then
        for i, applicant in ipairs(activity.applicantList) do
            if applicant.name == playerName then
                applicant.status = Meeting.APPLICANT_STATUS.Declined
                Meeting.CreatorFrame:UpdateList()
                Meeting.FloatFrame.Update()
                break
            end
        end
    end
end

local needUpdate = false
function Meeting:OnVersion(version)
    if needUpdate then
        return
    end
    local major, minor, patch = string.meetingsplit(version, ".")
    if not major or not minor or not patch then
        return
    end
    major, minor, patch = tonumber(major), tonumber(minor), tonumber(patch)
    if major ~= nil and minor ~= nil and patch ~= nil then
        if major > Meeting.VERSION.MAJOR or (major == Meeting.VERSION.MAJOR and minor > Meeting.VERSION.MINOR) or
            (major == Meeting.VERSION.MAJOR and minor == Meeting.VERSION.MINOR and patch > Meeting.VERSION.PATCH) then
            needUpdate = true
        end
    end
    if needUpdate then
        titleFrame:SetText(title .. "  (有新版本，请更新)")
    end
end

function Meeting.CheckLFTChannel()
    local i = -1
    for index, value in ipairs({ GetChannelList() }) do
        if value == Meeting.channel then
            i = index
            break
        end
    end
    if i == -1 then
        JoinChannelByName(Meeting.channel)
    end
    Meeting.RemoveLFTChannelFromWindows()
end

function Meeting.RemoveLFTChannelFromWindows()
    for windowIndex = 1, 9 do
        local DefaultChannels = { GetChatWindowChannels(windowIndex) }
        for _, v in DefaultChannels do
            if v == Meeting.channel then
                if getglobal("ChatFrame" .. windowIndex) then
                    ChatFrame_RemoveChannel(getglobal("ChatFrame" .. windowIndex), Meeting.channel)
                end
            end
        end
    end
end

C_Timer.NewTicker(5, function()
    local now = time()
    local update = false
    for index, activity in ipairs(Meeting.activities) do
        local rm = false
        if activity:IsChat() then
            rm = activity.updated + 60 < now
        elseif activity.unitname ~= Meeting.player then
            rm = activity.updated + 120 < now
        end

        if rm then
            update = true
            table.remove(Meeting.activities, index)
        end
    end

    if update then
        Meeting.BrowserFrame:UpdateList()
        Meeting.FloatFrame.Update()
    end
end)

SLASH_MEETING1 = "/meeting"
SlashCmdList["MEETING"] = function(msg, editbox)
    if (msg == "" or msg == nil) then
        print("Meeting 集合石:")
        print("  /meeting visible |cffcccccc- 显示或关闭悬浮窗")
        print("  /meeting toggle |cffcccccc- 显示或者关闭集合石主界面")
        print("  /meeting reset |cffcccccc- 重置")
        return
    end

    local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
    cmd = string.lower(cmd)
    if cmd == "visible" then
        MEETING_DB.hideFloat = MEETING_DB.hideFloat == 1 and 0 or 1
        if MEETING_DB.hideFloat == 1 then
            Meeting.FloatFrame:Hide()
        else
            Meeting.FloatFrame:Show()
        end
    elseif cmd == "toggle" then
        Meeting:Toggle()
    elseif cmd == "reset" then
        MEETING_DB = {}
        Meeting.FloatFrame:ClearAllPoints()
        Meeting.FloatFrame:SetPoint("TOP", 0, -20)
        Meeting.FloatFrame:Show()

        Meeting.MainFrame:ClearAllPoints()
        Meeting.MainFrame:SetPoint("CENTER", 0, 0)
    end
end
