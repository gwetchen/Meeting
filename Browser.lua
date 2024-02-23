local Menu = AceLibrary("Dewdrop-2.0")

local function CreateSyncTip()
    local tip = Meeting.GUI.CreateFrame({
        parent = Meeting.BrowserFrame,
        width = 200,
        height = 24,
        anchor = {
            point = "BOTTOMLEFT",
            relative = Meeting.BrowserFrame,
            relativePoint = "BOTTOMLEFT",
            x = 0,
            y = 4
        }
    })
    tip.text = Meeting.GUI.CreateText({
        parent = tip,
        text = "正在同步数据...",
        fontSize = 10,
        width = 200,
        anchor = {
            point = "TOPLEFT",
            relative = tip,
            relativePoint = "TOPLEFT",
        }
    })
    tip:Show()

    local i = 0
    C_Timer.NewTicker(1, function()
        i = i + 1
        tip.text:SetText("正在同步数据..." .. (math.mod(i, 2) == 0 and "" or "..."))
        if i >= 60 then
            tip:Hide()
            return
        end
    end, 60)
end

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
browserFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

browserFrame:SetScript("OnEvent", function()
    if event == "PLAYER_ENTERING_WORLD" then
        CreateSyncTip()
    end
end)
Meeting.BrowserFrame = browserFrame
browserFrame:EnableMouse(true)
browserFrame:EnableMouseWheel(true)

local categoryTextFrame = Meeting.GUI.CreateText({
    parent = browserFrame,
    text = "活动类型：",
    fontSize = 16,
    anchor = {
        point = "TOPLEFT",
        relative = browserFrame,
        relativePoint = "TOPLEFT",
        y = -18
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
                MeetingBworserSelectButton:SetText("选择活动")
                Meeting.BrowserFrame:UpdateList(true)
            end,
        }
    },
}

for i, value in ipairs(Meeting.Categories) do
    if not value.hide then
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
                    MeetingBworserSelectButton:SetText("全部" .. name)
                    Meeting.BrowserFrame:UpdateList(true)
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
                    MeetingBworserSelectButton:SetText(name)
                    Meeting.BrowserFrame:UpdateList(true)
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
end

local selectButton = Meeting.GUI.CreateButton({
    name = "MeetingBworserSelectButton",
    parent = browserFrame,
    text = "选择活动",
    type = Meeting.GUI.BUTTON_TYPE.PRIMARY,
    width = 120,
    height = 24,
    anchor = {
        point = "TOPLEFT",
        relative = categoryTextFrame,
        relativePoint = "TOPRIGHT",
        x = 10,
        y = 4
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

-- local searchButton = Meeting.GUI.CreateButton({
--     parent = browserFrame,
--     text = "搜索",
--     width = 80,
--     height = 24,
--     anchor = {
--         point = "TOPLEFT",
--         relative = selectButton,
--         relativePoint = "TOPRIGHT",
--         x = 20,
--         y = 0
--     },
--     click = function()
--     end
-- })

local refreshButton = Meeting.GUI.CreateButton({
    parent = browserFrame,
    text = "刷新",
    type = Meeting.GUI.BUTTON_TYPE.SUCCESS,
    width = 80,
    height = 24,
    anchor = {
        point = "TOPRIGHT",
        relative = browserFrame,
        relativePoint = "TOPRIGHT",
        x = 0,
        y = -18
    },
    click = function()
        Meeting.BrowserFrame:UpdateList(true)
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
    width = 135,
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
    width = 40,
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
    width = 70,
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
    width = 90,
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
    width = 370,
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

local hoverBackgrop = {
    edgeFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeSize = 24,
    insets = { left = -1, right = -1, top = -1, bottom = -1 },
}

local activityListFrame = Meeting.GUI.CreateListFrame({
    name = "MeetingActivityListFrame",
    parent = browserFrame,
    width = 746,
    height = 240,
    anchor = {
        point = "TOPLEFT",
        relative = activityListHeaderFrame,
        relativePoint = "BOTTOMLEFT",
        x = 0,
        y = 0
    },
    step = 24,
    display = 10,
    cell = function(f)
        f.OnHover = function(this, isHover)
            if isHover then
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT", 40)
                GameTooltip:SetText(this.category, 1, 1, 1, 1)
                GameTooltip:AddLine(this.leader, this.classColor.r, this.classColor.g, this.classColor.b, 1)

                if this.level > 0 then
                    local color = GetDifficultyColor(this.level)
                    GameTooltip:AddLine(
                        format('%s |cff%02x%02x%02x%s|r', LEVEL, color.r * 255, color.g * 255, color.b * 255,
                            this.level), 1, 1, 1)
                end

                if this.comment ~= "_" then
                    GameTooltip:AddLine(this.comment, 0.75, 0.75, 0.75, 1)
                end
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("<双击>悄悄话", 1, 1, 1, 1)
                GameTooltip:SetWidth(220)
                GameTooltip:Show()
            else
                GameTooltip:Hide()
            end
        end
        f:SetScript("OnDoubleClick", function()
            if this.leader == Meeting.player then
                return
            end
            ChatFrame_OpenChat("/w " .. this.leader, SELECTED_DOCK_FRAME or DEFAULT_CHAT_FRAME)
        end)

        f.nameFrame = Meeting.GUI.CreateText({
            parent = f,
            text = "",
            fontSize = 14,
            width = 135,
            anchor = {
                point = "TOPLEFT",
                relative = f,
                relativePoint = "TOPLEFT",
                x = 0,
                y = -6
            }
        })

        f.hcFrame = Meeting.GUI.CreateText({
            parent = f,
            text = "",
            fontSize = 14,
            width = 40,
            anchor = {
                point = "TOPLEFT",
                relative = f.nameFrame,
                relativePoint = "TOPRIGHT",
                x = 0,
                y = 0
            }
        })

        f.membersFrame = Meeting.GUI.CreateText({
            parent = f,
            text = "",
            width = 70,
            fontSize = 14,
            anchor = {
                point = "TOPLEFT",
                relative = f.hcFrame,
                relativePoint = "TOPRIGHT",
                x = 0,
                y = 0
            }
        })

        f.leaderFrame = Meeting.GUI.CreateText({
            parent = f,
            text = "",
            fontSize = 14,
            width = 90,
            anchor = {
                point = "TOPLEFT",
                relative = f.membersFrame,
                relativePoint = "TOPRIGHT",
                x = 0,
                y = 0
            }
        })

        f.commentFrame = Meeting.GUI.CreateText({
            parent = f,
            text = "",
            fontSize = 14,
            width = 370,
            height = 24,
            anchor = {
                point = "TOPLEFT",
                relative = f.leaderFrame,
                relativePoint = "TOPRIGHT",
                x = 0,
                y = 0
            }
        })
        f.commentFrame:SetJustifyV("TOP")

        f.statusFrame = Meeting.GUI.CreateText({
            parent = f,
            text = "",
            fontSize = 14,
            color = { r = 0, g = 1, b = 0 },
            anchor = {
                point = "TOPLEFT",
                relative = f.commentFrame,
                relativePoint = "TOPRIGHT",
                x = 0,
                y = 0
            }
        })

        f.requestButton = Meeting.GUI.CreateButton({
            parent = f,
            text = "申请",
            width = 34,
            height = 18,
            type = Meeting.GUI.BUTTON_TYPE.PRIMARY,
            anchor = {
                point = "TOPLEFT",
                relative = f.commentFrame,
                relativePoint = "TOPRIGHT",
                x = 0,
                y = 2
            },
            click = function()
                if f.isChat then
                    ChatFrame_OpenChat("/w " .. f.leader, SELECTED_DOCK_FRAME or DEFAULT_CHAT_FRAME)
                else
                    local frame = Meeting.GUI.CreateRequestPrompt({
                        parent = Meeting.BrowserFrame,
                        anchor = {
                            point = "CENTER",
                            relative = Meeting.BrowserFrame,
                            relativePoint = "CENTER",
                            x = 0,
                            y = 0
                        },
                        title = "申请加入" .. f.category,
                        confirm = function(text, role)
                            Meeting.Message.Request(f.id, text, role)
                            local activity = Meeting:FindActivity(f.id)
                            activity.applicantStatus = Meeting.APPLICANT_STATUS.Invited
                            Meeting.BrowserFrame:UpdateActivity(activity)
                            f.requestButton:Disable()
                        end
                    })
                    frame:SetPoint("TOP", Meeting.BrowserFrame, "TOP", 0, -50)
                end
            end
        })
    end
})

local function ReloadCell(frame, activity)
    local category = Meeting.FindCaregoryByCode(activity.category)
    frame.nameFrame:SetText(category.name)
    frame.hcFrame:SetText(activity.isHC and "HC" or "")
    local rgb = Meeting.GetClassRGBColor(activity.class, activity.unitname)
    frame.leaderFrame:SetText(activity.unitname)
    frame.leaderFrame:SetTextColor(rgb.r, rgb.g, rgb.b)
    local maxMambers = Meeting.GetActivityMaxMembers(activity.category)
    local isChat = activity:IsChat()
    if isChat then
        frame.membersFrame:SetText("-")
    else
        frame.membersFrame:SetText(activity.members .. "/" .. maxMambers)
    end

    frame.commentFrame:SetText(activity.comment ~= "_" and activity.comment or "")

    if activity.unitname == Meeting.player or Meeting:IsInActivity(activity.unitname) then
        frame.statusFrame:SetText("已加入")
        frame.statusFrame:SetTextColor(Meeting.GUI.Theme.Green.r, Meeting.GUI.Theme.Green.g,
            Meeting.GUI.Theme.Green.b)
        frame.statusFrame:Show()
        frame.requestButton:Hide()
    else
        if activity.applicantStatus == Meeting.APPLICANT_STATUS.Invited then
            frame.statusFrame:SetText("已申请")
            frame.statusFrame:SetTextColor(Meeting.GUI.Theme.Green.r, Meeting.GUI.Theme.Green.g,
                Meeting.GUI.Theme.Green.b)
            frame.statusFrame:Show()
            frame.requestButton:Hide()
        elseif activity.applicantStatus == Meeting.APPLICANT_STATUS.Declined then
            frame.statusFrame:SetText("已拒绝")
            frame.statusFrame:SetTextColor(Meeting.GUI.Theme.Red.r, Meeting.GUI.Theme.Red.g, Meeting.GUI.Theme.Red.b)
            frame.statusFrame:Show()
            frame.requestButton:Hide()
        elseif activity.applicantStatus == Meeting.APPLICANT_STATUS.Joined then
            frame.statusFrame:SetText("已加入")
            frame.statusFrame:SetTextColor(Meeting.GUI.Theme.Green.r, Meeting.GUI.Theme.Green.g,
                Meeting.GUI.Theme.Green.b)
            frame.statusFrame:Show()
            frame.requestButton:Hide()
        else
            frame.statusFrame:Hide()
            frame.requestButton:Show()
            if activity.members >= maxMambers then
                frame.requestButton:Disable()
                frame.requestButton:SetText("满员")
            else
                frame.requestButton:Enable()
                if isChat then
                    frame.requestButton:SetText("密语")
                else
                    frame.requestButton:SetText("申请")
                end
            end
        end
    end

    frame.id = activity.unitname
    frame.category = category.name
    frame.isChat = isChat
    frame.leader = activity.unitname
    frame.classColor = rgb
    frame.level = activity.level
    frame.comment = activity.comment
end

local activities = {}

function Meeting.BrowserFrame:UpdateList(force, scroll)
    if not Meeting.BrowserFrame:IsShown() then
        return
    end

    if not scroll then
        if not force then
            if Meeting.isHover then
                Meeting.GUI.SetBackground(refreshButton, Meeting.GUI.Theme.Red)
                return
            end
        end
        Meeting.GUI.SetBackground(refreshButton, Meeting.GUI.Theme.Green)

        activities = {}

        local function search(activity)
            if Meeting.searchInfo.parent == "" or Meeting.searchInfo.parent == activity.parent then
                if Meeting.searchInfo.category == "" or Meeting.searchInfo.category == activity.category then
                    table.insert(activities, activity)
                end
            end
        end

        for _, activity in ipairs(Meeting.activities) do
            if activity:IsChat() then
                if Meeting.searchInfo.category ~= "" then
                    local lower = string.lower(activity.comment)
                    local category = Meeting.FindCaregoryByCode(Meeting.searchInfo.category)
                    if category.match then
                        for _, v in ipairs(category.match) do
                            if string.find(lower, v) then
                                table.insert(activities, activity)
                                break
                            end
                        end
                    end
                else
                    search(activity)
                end
            else
                search(activity)
            end
        end
    end

    activityListFrame:Reload(table.getn(activities), function(frame, index)
        ReloadCell(frame, activities[index])
    end)
end

activityListFrame.OnScroll = Meeting.BrowserFrame.UpdateList

function Meeting.BrowserFrame:UpdateActivity(activity)
    local index = -1
    for i, value in ipairs(activities) do
        if value.unitname == activity.unitname then
            index = i
            break
        end
    end
    if index == -1 then
        return
    end

    local offset = FauxScrollFrame_GetOffset(activityListFrame) + 1
    if index < offset or index > offset + table.getn(activityListFrame.pool) then
        return
    end

    local frame = activityListFrame.pool[index - offset + 1]
    ReloadCell(frame, activity)
end
