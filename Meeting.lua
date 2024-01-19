local activity = {
    list = {}
}

local activityFrames = {}

local isHC = false

local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_HARDCORE")
f:RegisterEvent("CHAT_MSG_CHANNEL")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    if event == "CHAT_MSG_HARDCORE" then
        isHC = true
    end

    if event == "PLAYER_ENTERING_WORLD" then

    end

    if event == "CHAT_MSG_CHANNEL" then
        local _, _, source = string.find(arg4, "(%d+)%.")
        if source then
            _, name = GetChannelName(source)
        end
        if name == "LFT" and Meeting.Util:StringStarts(arg1, "Meeting:") then
            Meeting:OnRecv(arg1)
        end
    end
end)

local function hasActivity()
    local unitname = UnitName("player")
    for i, item in ipairs(activity.list) do
        if item.unitname == unitname then
            return true
        end
    end
    return false
end

local meetingFrame = Meeting.GUI:CreateButton({
    name = "MettingFrame",
    width = 80,
    height = 40,
    text = "集合石",
    anchor = {
        point = "CENTER",
        x = 0,
        y = 0
    },
    movable = true,
    click = function()
        Meeting:ShowMainFrame()
    end
})

local main = CreateFrame("Frame", "MettingMainFrame", UIParent)
main:SetWidth(800)
main:SetHeight(400)
main:SetPoint("CENTER", UIParent, "CENTER")
main:SetMovable(true)
main:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    tile = true,
    tileSize = 30,
    edgeSize = 30,
    insets = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0
    }
})
main:Hide()

local categoryMenu = CreateFrame("Frame", "MeetingCreateActivityCategoryMenu", main, "UIDropDownMenuTemplate")
categoryMenu:SetPoint("TOPLEFT", 18, -18)

local raidMenu = CreateFrame("Frame", "MeetingCreateActivityRaidMenu", main, "UIDropDownMenuTemplate")
raidMenu:SetPoint("TOPLEFT", 180, -18)

local scroll = CreateFrame("ScrollFrame", "MeetingCreateScrollFrame", main, "UIPanelScrollFrameTemplate")
scroll:SetWidth(220)
scroll:SetHeight(140)
scroll:SetPoint("TOPLEFT", categoryMenu, "BOTTOMLEFT", 10, 0)

local createActivityInfo = {}

local input = CreateFrame("EditBox", "MeetingCreateScrollFrameText", scroll)
input:SetWidth(220)
input:SetHeight(140)
input:SetMultiLine(true)
input:SetMaxLetters(255)
input:SetAutoFocus(false)
input:SetScript("OnTextChanged", function(e)
    createActivityInfo.comment = input:GetText()
end)
input:SetScript("OnEscapePressed", function()
    input:ClearFocus()
end)
input:SetFontObject("ChatFontNormal")

scroll:SetScrollChild(input)

UIDropDownMenu_Initialize(categoryMenu, function()
    for _, value in pairs(Meeting.Categories) do
        local info = {}
        info.text = value.label
        local children = value.children
        info.func = function()
            UIDropDownMenu_SetSelectedID(categoryMenu, this:GetID())
            UIDropDownMenu_SetSelectedID(raidMenu, 0)
            createActivityInfo.category = Meeting.Categories[this:GetID()].value

            UIDropDownMenu_Initialize(raidMenu, function()
                for _, value in pairs(children) do
                    local info = {}
                    info.text = value.label
                    info.func = function()
                        UIDropDownMenu_SetSelectedID(raidMenu, this:GetID())
                        createActivityInfo.name = children[this:GetID()].value
                    end
                    UIDropDownMenu_AddButton(info)
                end
            end)
        end
        UIDropDownMenu_AddButton(info)
    end
end)

local function GetPlayerClass()
    local _, class = UnitClass("player")
    return class
end

Meeting.GUI:CreateButton({
    parent = main,
    width = 80,
    height = 40,
    text = "创建活动",
    anchor = {
        point = "TOPLEFT",
        relative = main,
        relativePoint = "TOPLEFT",
        x = 350,
        y = -18
    },
    click = function()
        if hasActivity() then
            local data = string.format("%s:%s:%s:%s:%d:%s:%d:%d", UnitName("player"), createActivityInfo.category,
                createActivityInfo.name, createActivityInfo.comment, UnitLevel("player"), GetPlayerClass(),
                Meeting:GetMembers() + 1)
            Meeting:CreateActivity(data, isHC and 1 or 0)
        else
            local data = string.format("%s:%s:%s:%s:%d:%s:%d:%d", UnitName("player"), createActivityInfo.category,
                createActivityInfo.name, createActivityInfo.comment, UnitLevel("player"), GetPlayerClass(),
                Meeting:GetMembers() + 1, isHC and 1 or 0)
            Meeting:CreateActivity(data)
        end
    end
})

function Meeting:ShowMainFrame()
    if main:IsShown() then
        main:Hide()
    else
        main:Show()
    end
end

function Meeting:SendMessage(event, data)
    if GetChannelName("LFT") ~= 0 then
        SendChatMessage("Meeting:" .. event .. data, "CHANNEL", nil, GetChannelName("LFT"))
    end
end

function Meeting:CreateActivity(data)
    Meeting:SendMessage("CREATE", data)
end

function Meeting:Applicant(data)
    Meeting:SendMessage("APPLICANT", data)
end

function FindActivity(creator)
    local index = -1
    for i, item in ipairs(activity.list) do
        if item.unitname == creator then
            index = i
            break
        end
    end
    if index ~= -1 then
        return activity.list[index]
    else
        return nil
    end
end

function Meeting:OnRecv(data)
    print(data)
    local _, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 = Meeting.Util:StringSplit(data, ":")
    if event == "CREATE" then
        Meeting:OnCreate(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    elseif event == "APPLICANT" then
        Meeting:OnApplicant(arg1, arg2, arg3, arg4)
    elseif event == "DECLINE" then
        Meeting:OnDecline(arg1, arg2)
    end
end

function Meeting:OnCreate(id, category, name, comment, level, class, members, hc)
    local item = FindActivity(id)
    if item then
        item.category = category
        item.name = name
        item.comment = comment
        item.level = tonumber(level)
        item.class = class
        item.members = tonumber(members)
        item.isHC = hc == "1"
    else
        table.insert(activity.list, {
            unitname = id,
            category = category,
            name = comment,
            comment = tonumber(level),
            level = tonumber(level),
            class = class,
            members = tonumber(members),
            isHC = hc == "1",
            applicantList = {}
        })
    end

    for _, f in ipairs(activityFrames) do
        f:Hide()
    end
    activityFrames = {}

    for _, item in ipairs(activity.list) do
        local id = item.unitname

        local f = CreateFrame("Frame")
        f:SetWidth(300)
        f:SetHeight(44)
        f:SetPoint("TOPLEFT", main, 300, -80)

        local name = f:CreateFontString(nil)
        name:SetFont(STANDARD_TEXT_FONT, 18, "OUTLINE")
        name:SetPoint("TOPLEFT", 0, 0)
        name:SetTextColor(1, 1, 1)
        name:SetText(item.name)

        local button = Meeting.GUI:CreateButton({
            parent = f,
            text = "申请",
            width = 80,
            height = 24,
            anchor = {
                point = "TOPLEFT",
                relative = name,
                relativePoint = "TOPRIGHT",
                x = 0,
                y = 0
            },
            click = function()
                local data = string.format("%s:%s:%d:%s", id, UnitName("player"), UnitLevel("player"),
                    GetPlayerClass())
                Meeting:Applicant(data)
                item.applicantStatus = Meeting.APPLICANT_STATUS.Invited
                button:SetText("已申请")
                button:Disable()
            end
        })
        if item.unitname == UnitName("player") then
            button:Disable()
        else
            item.applicantStatus = Meeting.APPLICANT_STATUS.None
        end
        activityFrames[id] = f
    end
end

function Meeting:OnApplicant(id, name, level, class)
    local item = FindActivity(id)
    if item and item.unitname == UnitName("player") then
        local applicant = {
            name = name,
            level = tonumber(level),
            class = class,
            status = Meeting.APPLICANT_STATUS.Invited
        }

        table.insert(item.applicantList, applicant)
        local f = activityFrames[id]

        local applicantFrame = Meeting.GUI:CreateFrame({
            parent = f,
            width = 280,
            height = 44,
            anchor = {
                point = "TOPLEFT",
                relative = f,
                relativePoint = "BOTTOMLEFT",
                x = 0,
                y = 0
            }
        })

        local nameText = Meeting.GUI:CreateText({
            parent = applicantFrame,
            text = name,
            anchor = {
                point = "TOPLEFT",
                relative = applicantFrame,
                relativePoint = "TOPLEFT",
                x = 0,
                y = 0
            }
        })

        local acceptButton = Meeting.GUI:CreateButton({
            parent = f,
            text = "同意",
            width = 80,
            height = 24,
            anchor = {
                point = "TOPLEFT",
                relative = nameText,
                relativePoint = "TOPRIGHT",
                x = 0,
                y = 0
            },
            click = function()
                applicant.status = Meeting.APPLICANT_STATUS.Invited
                InviteByName(name)
            end
        })

        local declineButton = Meeting.GUI:CreateButton({
            parent = f,
            text = "拒绝",
            width = 80,
            height = 24,
            anchor = {
                point = "TOPLEFT",
                relative = acceptButton,
                relativePoint = "TOPRIGHT",
                x = -20,
                y = 0
            },
            click = function()
                applicant.status = Meeting.APPLICANT_STATUS.Declined
                Meeting:SendMessage("DECLINE", string.format("%s:%s", id, name))
            end
        })
    end
end

function Meeting:OnDecline(id, name)
    if name == UnitName("player") then
        local item = FindActivity(id)
        if item then
            item.applicantStatus = Meeting.APPLICANT_STATUS.Declined
        end
    end
end
