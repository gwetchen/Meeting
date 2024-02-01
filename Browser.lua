local Menu = AceLibrary("Dewdrop-2.0")

local browserFrame = CreateFrame("Frame", nil, Meeting.MainFrame)
browserFrame:SetWidth(782)
browserFrame:SetHeight(388)
browserFrame:SetPoint("TOPLEFT", Meeting.MainFrame, "TOPLEFT", 18, -18)
Meeting.BrowserFrame = browserFrame

local categoryTextFrame = Meeting.GUI.CreateText({
    parent = browserFrame,
    text = "活动类型：",
    fontSize = 16,
    anchor = {
        point = "TOPLEFT",
        relative = browserFrame,
        relativePoint = "TOPLEFT",
        x = 0,
        y = 0
    }
})

local options = {
    type = 'group',
    args = {
        ALL = {
            order = 1,
            type = "toggle",
            name = "全部",
            desc = "全部",
            get = function() return Meeting.searchInfo.category == "" end,
            set = function()
                Meeting.searchInfo.category = ""
                Menu:Close()
                categoryTextFrame:SetText("活动类型：全部活动")
            end,
        }
    },
}

for i, value in ipairs(Meeting.Categories) do
    local k = value.key
    local name = value.name
    local children = {
        ALL = {
            order = 1,
            type = "toggle",
            name = "全部",
            desc = "全部",
            get = function() return Meeting.searchInfo.category == k and Meeting.searchInfo.child == "" end,
            set = function()
                Meeting.searchInfo.category = k
                Meeting.searchInfo.child = ""
                Menu:Close()
                categoryTextFrame:SetText("活动类型：全部" .. name)
            end,
        }
    }

    for j, child in ipairs(value.children) do
        local k = child.key
        local name = child.name
        children[k] = {
            order = j + 1,
            type = "toggle",
            name = name,
            desc = name,
            get = function() return Meeting.searchInfo.child == k end,
            set = function()
                Meeting.searchInfo.child = k
                Menu:Close()
                categoryTextFrame:SetText("活动类型：" .. name)
            end,
        }
    end

    options.args[value.key] = {
        order = i + 1,
        type = 'group',
        name = value.name,
        desc = value.name,
        args = children,
    }
end

local selectButton = Meeting.GUI.CreateButton({
    parent = browserFrame,
    text = "选择活动",
    width = 80,
    height = 24,
    anchor = {
        point = "TOPLEFT",
        relative = categoryTextFrame,
        relativePoint = "BOTTOMLEFT",
        x = 0,
        y = -20
    },
    click = function()
        Menu:Open(this)
    end
})

Menu:Register(selectButton,
    'children', function()
        Menu:FeedAceOptionsTable(options)
    end,
    'cursorX', true,
    'cursorY', true,
    'dontHook', true
)

local searchButton = Meeting.GUI.CreateButton({
    parent = browserFrame,
    text = "搜索",
    width = 80,
    height = 24,
    anchor = {
        point = "TOPLEFT",
        relative = selectButton,
        relativePoint = "TOPRIGHT",
        x = 20,
        y = 0
    },
    click = function()
    end
})

local activityListHeaderFrame = CreateFrame("Frame", nil, browserFrame)
activityListHeaderFrame:SetWidth(746)
activityListHeaderFrame:SetHeight(44)
activityListHeaderFrame:SetPoint("TOPLEFT", browserFrame, "TOPLEFT", 18, -56)

local categoryText = Meeting.GUI.CreateText({
    parent = activityListHeaderFrame,
    text = "活动类型",
    fontSize = 14,
    width = 145,
    height = 24,
    anchor = {
        point = "TOPLEFT",
        relative = activityListHeaderFrame,
        relativePoint = "TOPLEFT",
    }
})

local modeText = Meeting.GUI.CreateText({
    parent = activityListHeaderFrame,
    text = "模式",
    fontSize = 14,
    width = 60,
    height = 24,
    anchor = {
        point = "TOPLEFT",
        relative = categoryText,
        relativePoint = "TOPRIGHT",
    }
})

local membersText = Meeting.GUI.CreateText({
    parent = activityListHeaderFrame,
    text = "队伍人数",
    fontSize = 14,
    width = 110,
    height = 24,
    anchor = {
        point = "TOPLEFT",
        relative = modeText,
        relativePoint = "TOPRIGHT",

    }
})

local leaderText = Meeting.GUI.CreateText({
    parent = activityListHeaderFrame,
    text = "队长",
    fontSize = 14,
    width = 110,
    height = 24,
    anchor = {
        point = "TOPLEFT",
        relative = membersText,
        relativePoint = "TOPRIGHT",
    }
})

local commentText = Meeting.GUI.CreateText({
    parent = activityListHeaderFrame,
    text = "说明",
    fontSize = 14,
    width = 290,
    height = 24,
    anchor = {
        point = "TOPLEFT",
        relative = leaderText,
        relativePoint = "TOPRIGHT",
    }
})

local actionText = Meeting.GUI.CreateText({
    parent = activityListHeaderFrame,
    text = "操作",
    fontSize = 14,
    width = 150,
    height = 24,
    anchor = {
        point = "TOPLEFT",
        relative = commentText,
        relativePoint = "TOPRIGHT",
    }
})

local activityListFrame = CreateFrame("Frame", nil, browserFrame)
activityListFrame:SetWidth(746)
activityListFrame:SetHeight(352)
activityListFrame:SetPoint("TOPLEFT", activityListHeaderFrame, "BOTTOMLEFT", 0, 0)

local activityFramePool = {}

local function CreateActivityItemFrame()
    local f = CreateFrame("Frame", nil, activityListFrame)
    f:SetWidth(746)
    f:SetHeight(44)

    local nameText = Meeting.GUI.CreateText({
        parent = f,
        text = "",
        fontSize = 14,
        width = 145,
        anchor = {
            point = "TOPLEFT",
            relative = f,
            relativePoint = "TOPLEFT",
            x = 0,
            y = 0
        }
    })

    local hcText = Meeting.GUI.CreateText({
        parent = f,
        text = "",
        fontSize = 14,
        width = 60,
        anchor = {
            point = "TOPLEFT",
            relative = nameText,
            relativePoint = "TOPRIGHT",
            x = 0,
            y = 0
        }
    })

    local membersText = Meeting.GUI.CreateText({
        parent = f,
        text = "",
        width = 110,
        fontSize = 14,
        anchor = {
            point = "TOPLEFT",
            relative = hcText,
            relativePoint = "TOPRIGHT",
            x = 0,
            y = 0
        }
    })

    local leaderText = Meeting.GUI.CreateText({
        parent = f,
        text = "",
        fontSize = 14,
        width = 110,
        anchor = {
            point = "TOPLEFT",
            relative = membersText,
            relativePoint = "TOPRIGHT",
            x = 0,
            y = 0
        }
    })

    local commentText = Meeting.GUI.CreateText({
        parent = f,
        text = "",
        fontSize = 14,
        width = 290,
        anchor = {
            point = "TOPLEFT",
            relative = leaderText,
            relativePoint = "TOPRIGHT",
            x = 0,
            y = 0
        }
    })

    local item = {
        frame = f,
        nameText = nameText,
        hcText = hcText,
        leaderText = leaderText,
        membersText = membersText,
        commentText = commentText,
    }

    local requestButton = Meeting.GUI.CreateButton({
        parent = f,
        text = "申请",
        width = 44,
        height = 24,
        anchor = {
            point = "TOPLEFT",
            relative = commentText,
            relativePoint = "TOPRIGHT",
            x = 0,
            y = 0
        },
        click = function()
            item.click()
            this:SetText("已申请")
            this:Disable()
        end
    })
    item.requestButton = requestButton

    table.insert(activityFramePool, item)
end

for i = 1, 5 do
    CreateActivityItemFrame()
end

function Meeting.BrowserFrame:UpdateList()
    if not Meeting.BrowserFrame:IsShown() then
        return
    end
    if table.getn(Meeting.activities) > table.getn(activityFramePool) then
        for i = table.getn(activityFramePool) + 1, table.getn(Meeting.activities) do
            CreateActivityItemFrame()
        end
    end

    for i, item in ipairs(activityFramePool) do
        if i > table.getn(Meeting.activities) then
            item.frame:Hide()
        else
            local activity = Meeting.activities[i]
            item.frame:SetPoint("TOPLEFT", activityListFrame, "TOPLEFT", 0, -44 * (i - 1))
            item.nameText:SetText(Meeting.CaregoryCode2Name(activity.category))
            item.hcText:SetText(activity.hc and "HC" or "FHC")
            local rgb = Meeting.GetClassRGBColor(activity.class, activity.unitname)
            item.leaderText:SetText(activity.unitname)
            item.leaderText:SetTextColor(rgb.r, rgb.g, rgb.b)
            item.membersText:SetText(activity.members)
            item.commentText:SetText(activity.comment ~= "_" and activity.comment or "")
            if activity.unitname == Meeting.player then
                item.requestButton:Disable()
            else
                item.requestButton:Enable()
            end
            if activity.applicantStatus == Meeting.APPLICANT_STATUS.Invited then
                item.requestButton:SetText("已申请")
                item.requestButton:Disable()
            elseif activity.applicantStatus == Meeting.APPLICANT_STATUS.Declined then
                item.requestButton:SetText("已拒绝")
            elseif activity.applicantStatus == Meeting.APPLICANT_STATUS.Joined then
                item.requestButton:SetText("已加入")
                item.requestButton:Disable()
            else
                item.requestButton:SetText("申请")
            end
            local id = activity.unitname
            item.click = function()
                local data = string.format("%s:%s:%d:%d:%d:%s", id, Meeting.player, UnitLevel("player"),
                    Meeting.ClassToNumber(Meeting.GetPlayerClass()), Meeting.GetPlayerScore(), "_")
                Meeting:Applicant(data)
                activity.applicantStatus = Meeting.APPLICANT_STATUS.Invited
            end
            item.frame:Show()
        end
    end
end
