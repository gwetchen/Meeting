local Menu = AceLibrary("Dewdrop-2.0")

local browserFrame = Meeting.GUI.CreateFrame({
    parent = Meeting.MainFrame,
    width = 782,
    height = 390,
    anchor = {
        point = "TOPLEFT",
        relative = Meeting.MainFrame,
        relativePoint = "TOPLEFT",
        x = 18,
        y = -34
    }
})
Meeting.BrowserFrame = browserFrame

local categoryTextFrame = Meeting.GUI.CreateText({
    parent = browserFrame,
    text = "活动类型：全部活动",
    fontSize = 16,
    anchor = {
        point = "TOPLEFT",
        relative = browserFrame,
        relativePoint = "TOPLEFT",
        x = 0,
        y = 0
    }
})

Meeting.searchInfo.parent = ""
Meeting.searchInfo.category = ""

local options = {
    type = 'group',
    args = {
        ALL = {
            order = 1,
            type = "toggle",
            name = "全部",
            desc = "全部",
            get = function() return Meeting.searchInfo.parent == "" end,
            set = function()
                Meeting.searchInfo.parent = ""
                Meeting.searchInfo.category = ""
                Menu:Close()
                categoryTextFrame:SetText("活动类型：全部活动")
                Meeting.BrowserFrame:UpdateList()
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
            get = function() return Meeting.searchInfo.parent == k and Meeting.searchInfo.category == "" end,
            set = function()
                Meeting.searchInfo.parent = k
                Meeting.searchInfo.category = ""
                Menu:Close()
                categoryTextFrame:SetText("活动类型：全部" .. name)
                Meeting.BrowserFrame:UpdateList()
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
            get = function() return Meeting.searchInfo.category == k end,
            set = function()
                Meeting.searchInfo.category = k
                Menu:Close()
                categoryTextFrame:SetText("活动类型：" .. name)
                Meeting.BrowserFrame:UpdateList()
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

local activityListHeaderFrame = Meeting.GUI.CreateFrame({
    parent = browserFrame,
    width = 746,
    height = 44,
    anchor = {
        point = "TOPLEFT",
        relative = browserFrame,
        relativePoint = "TOPLEFT",
        x = 18,
        y = -56
    }
})

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

local activityListFrame = Meeting.GUI.CreateFrame({
    parent = browserFrame,
    width = 746,
    height = 270,
    anchor = {
        point = "TOPLEFT",
        relative = activityListHeaderFrame,
        relativePoint = "BOTTOMLEFT",
        x = 0,
        y = 0
    }
})

local activityFramePool = {}

local function CreateActivityItemFrame()
    local f = Meeting.GUI.CreateFrame({
        parent = activityListFrame,
        width = 746,
        height = 24,
    })

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

    local activities = {}
    for i, activity in ipairs(Meeting.activities) do
        if Meeting.searchInfo.parent == "" or Meeting.searchInfo.parent == activity.parent then
            if Meeting.searchInfo.category == "" or Meeting.searchInfo.category == activity.category then
                table.insert(activities, activity)
            end
        end
    end
    local len = table.getn(activities)
    local poolLen = table.getn(activityFramePool)
    if len > poolLen then
        for i = poolLen + 1, len do
            CreateActivityItemFrame()
        end
    end

    for i, item in ipairs(activityFramePool) do
        if i > len then
            item.frame:Hide()
        else
            local activity = activities[i]
            item.frame:SetPoint("TOPLEFT", activityListFrame, "TOPLEFT", 0, -24 * (i - 1))
            local category = Meeting.FindCaregoryByCode(activity.category)
            item.nameText:SetText(category.name)
            item.hcText:SetText(activity.hc and "HC" or "FHC")
            local rgb = Meeting.GetClassRGBColor(activity.class, activity.unitname)
            item.leaderText:SetText(activity.unitname)
            item.leaderText:SetTextColor(rgb.r, rgb.g, rgb.b)
            item.membersText:SetText(activity.members .. "/" .. Meeting.GetActivityMaxMembers(activity.category))
            item.commentText:SetText(activity.comment ~= "_" and activity.comment or "")
            if activity.unitname == Meeting.player then
                item.requestButton:Disable()
            else
                item.requestButton:Enable()
            end
            if Meeting:IsInActivity(activity.unitname) then
                item.requestButton:SetText("已加入")
                item.requestButton:Disable()
            else
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
            end

            local id = activity.unitname
            item.click = function()
                local data = string.format("%s:%s:%d:%d:%d:%s", id, Meeting.player, UnitLevel("player"),
                    Meeting.ClassToNumber(Meeting.GetPlayerClass()), Meeting.GetPlayerScore(), "_")
                Meeting.Message.Applicant(data)
                activity.applicantStatus = Meeting.APPLICANT_STATUS.Invited
            end
            item.frame:Show()
        end
    end
end
