local Menu = AceLibrary("Dewdrop-2.0")

local creatorFrame = Meeting.GUI.CreateFrame({
    parent = Meeting.MainFrame,
    width = 782,
    height = 390,
    anchor = {
        point = "TOPLEFT",
        relative = Meeting.MainFrame,
        relativePoint = "TOPLEFT",
        x = 18,
        y = -34
    },
    hide = true
})
Meeting.CreatorFrame = creatorFrame

local creatorInfoFrame = Meeting.GUI.CreateFrame({
    parent = creatorFrame,
    width = 260,
    height = 372,
    anchor = {
        point = "TOPLEFT",
        relative = creatorFrame,
        relativePoint = "TOPLEFT",
    }
})

local line = creatorFrame:CreateTexture()
line:SetWidth(0.5)
line:SetHeight(390)
line:SetTexture(1, 1, 1, 0.5)
line:SetPoint("TOPLEFT", creatorInfoFrame, "TOPRIGHT", -18, 0)

local categoryTextFrame = Meeting.GUI.CreateText({
    parent = creatorInfoFrame,
    text = "活动类型：",
    fontSize = 16,
    anchor = {
        point = "TOPLEFT",
        relative = creatorInfoFrame,
        relativePoint = "TOPLEFT",
        x = 0,
        y = -18
    }
})

local options = {
    type = 'group',
    args = {},
}

for i, value in ipairs(Meeting.Categories) do
    local children = {}

    for j, child in ipairs(value.children) do
        local k = child.key
        local name = child.name
        children[k] = {
            order = j,
            type = "toggle",
            name = name,
            desc = name,
            get = function() return Meeting.createInfo.category == k end,
            set = function()
                Meeting.createInfo.category = k
                MeetingCreatorSelectButton:SetText(name)
                Menu:Close()
                Meeting.CreatorFrame.UpdateActivity()
            end,
        }
    end

    options.args[value.key] = {
        order = i,
        type = 'group',
        name = value.name,
        desc = value.name,
        args = children,
    }
end

local selectButton = Meeting.GUI.CreateButton({
    parent = creatorInfoFrame,
    name = "MeetingCreatorSelectButton",
    text = "选择活动",
    width = 120,
    height = 24,
    type = Meeting.GUI.BUTTON_TYPE.PRIMARY,
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

local commentTextFrame = Meeting.GUI.CreateText({
    parent = creatorInfoFrame,
    text = "活动说明：",
    fontSize = 16,
    anchor = {
        point = "TOPLEFT",
        relative = categoryTextFrame,
        relativePoint = "BOTTOMLEFT",
        x = 0,
        y = -22
    }
})

local commentButton = CreateFrame("Button", nil, creatorInfoFrame)
commentButton:SetWidth(220)
commentButton:SetHeight(140)
commentButton:SetPoint("TOPLEFT", commentTextFrame, "BOTTOMLEFT", 0, -18)
commentButton:SetScript("OnClick", function()
    MeetingCreateEditBox:SetFocus()
end)
Meeting.GUI.SetBackground(commentButton, Meeting.GUI.Theme.Black, Meeting.GUI.Theme.White)

local commentFrame = CreateFrame("EditBox", "MeetingCreateEditBox", commentButton)
commentFrame:SetWidth(220)
commentFrame:SetHeight(140)
commentFrame:SetPoint("TOPLEFT", commentButton, "TOPLEFT", 0, 0)
commentFrame:SetMultiLine(true)
commentFrame:SetJustifyV("TOP")
commentFrame:SetJustifyH("LEFT")
commentFrame:SetMaxBytes(128)
commentFrame:SetAutoFocus(false)
commentFrame:SetFontObject("ChatFontNormal")
commentFrame:SetScript("OnTextChanged", function(e)
    local text = commentFrame:GetText()
    text = string.gsub(text, "\n", "")
    text = string.gsub(text, ":", "：")
    commentFrame:SetText(text)
    Meeting.createInfo.comment = text
end)
commentFrame:SetScript("OnEscapePressed", function()
    commentFrame:ClearFocus()
end)

local createButton = Meeting.GUI.CreateButton({
    parent = creatorInfoFrame,
    width = 80,
    height = 24,
    text = "创建活动",
    type = Meeting.GUI.BUTTON_TYPE.SUCCESS,
    anchor = {
        point = "TOPLEFT",
        relative = commentButton,
        relativePoint = "BOTTOMLEFT",
        x = 0,
        y = -20
    },
    click = function()
        commentFrame:ClearFocus()
        local data = string.format("%s:%s:%d:%d:%d:%d", Meeting.createInfo.category,
            string.isempty(Meeting.createInfo.comment) and "_" or Meeting.createInfo.comment, UnitLevel("player"),
            Meeting.ClassToNumber(Meeting.playerClass),
            Meeting:GetMembers(), Meeting.playerIsHC and 1 or 0)
        Meeting.Message.CreateActivity(data)
        MEETING_DB.activity = {
            category = Meeting.createInfo.category,
            comment = Meeting.createInfo.comment,
            lastTime = time()
        }
        Meeting:SyncActivity()
    end
})
createButton:Disable()

local closeButton = Meeting.GUI.CreateButton({
    parent = creatorInfoFrame,
    width = 80,
    height = 24,
    text = "解散活动",
    type = Meeting.GUI.BUTTON_TYPE.DANGER,
    anchor = {
        point = "TOP",
        relative = createButton,
        relativePoint = "TOP",
    },
    click = function()
        Meeting.Message.CloseActivity()
    end
})
closeButton:SetPoint("RIGHT", commentFrame, "RIGHT", 0, 0)
closeButton:Disable()

local applicantListHeaderFrame = Meeting.GUI.CreateFrame({
    parent = creatorFrame,
    width = 504,
    height = 24,
    anchor = {
        point = "TOPLEFT",
        relative = creatorInfoFrame,
        relativePoint = "TOPRIGHT",
        x = 0,
        y = 0
    }
})

local nameText = Meeting.GUI.CreateText({
    parent = applicantListHeaderFrame,
    text = "角色名",
    fontSize = 14,
    width = 80,
    height = 24,
    anchor = {
        point = "TOPLEFT",
        relative = applicantListHeaderFrame,
        relativePoint = "TOPLEFT",
    }
})

local levelText = Meeting.GUI.CreateText({
    parent = applicantListHeaderFrame,
    text = "等级",
    fontSize = 14,
    width = 40,
    height = 24,
    anchor = {
        point = "TOPLEFT",
        relative = nameText,
        relativePoint = "TOPRIGHT",
    }
})

local scoreText = Meeting.GUI.CreateText({
    parent = applicantListHeaderFrame,
    text = "装等",
    fontSize = 14,
    width = 40,
    height = 24,
    anchor = {
        point = "TOPLEFT",
        relative = levelText,
        relativePoint = "TOPRIGHT",

    }
})

local commentText = Meeting.GUI.CreateText({
    parent = applicantListHeaderFrame,
    text = "说明",
    fontSize = 14,
    width = 290,
    height = 24,
    anchor = {
        point = "TOPLEFT",
        relative = scoreText,
        relativePoint = "TOPRIGHT",
    }
})

local actionText = Meeting.GUI.CreateText({
    parent = applicantListHeaderFrame,
    text = "操作",
    fontSize = 14,
    width = 100,
    height = 24,
    anchor = {
        point = "TOPLEFT",
        relative = commentText,
        relativePoint = "TOPRIGHT",
    }
})



local applicantListFrame = Meeting.GUI.CreateListFrame({
    name = "MeetingActivityListFrame",
    parent = creatorFrame,
    width = 504,
    height = 336,
    anchor = {
        point = "TOPLEFT",
        relative = applicantListHeaderFrame,
        relativePoint = "BOTTOMLEFT",
        x = 0,
        y = 0
    },
    step = 24,
    display = 14,
    cell = function(f)
        f:SetScript("OnEnter", function()
            this:SetBackdropBorderColor(1, 1, 1, .2)

            GameTooltip:SetOwner(this, "ANCHOR_RIGHT", 40)
            GameTooltip:SetText(this.applicant.name, this.classColor.r, this.classColor.g, this.classColor.b, 1)
            if this.applicant.score > 0 then
                GameTooltip:AddLine("装等：" .. this.applicant.score)
            end

            local color = GetDifficultyColor(this.applicant.level)
            GameTooltip:AddLine(format('%s |cff%02x%02x%02x%s|r', LEVEL, color.r * 255, color.g * 255, color.b * 255,
                this.applicant.level), 1, 1, 1)

            if this.applicant.comment ~= "_" then
                GameTooltip:AddLine(this.applicant.comment, 0.75, 0.75, 0.75, 1)
            end
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("<双击>悄悄话", 1, 1, 1, 1)
            GameTooltip:SetWidth(220)
            GameTooltip:Show()
        end)
        f:SetScript("OnLeave", function()
            this:SetBackdropBorderColor(1, 1, 1, .04)
            GameTooltip:Hide()
        end)
        f:SetScript("OnDoubleClick", function()
            if this.applicant.name == Meeting.player then
                return
            end
            ChatFrame_OpenChat("/w " .. this.applicant.name, SELECTED_DOCK_FRAME or DEFAULT_CHAT_FRAME)
        end)

        f.nameFrame = Meeting.GUI.CreateText({
            parent = f,
            text = "",
            fontSize = 14,
            width = 80,
            anchor = {
                point = "TOPLEFT",
                relative = f,
                relativePoint = "TOPLEFT",
                x = 0,
                y = -6
            }
        })

        f.levelFrame = Meeting.GUI.CreateText({
            parent = f,
            text = "",
            width = 40,
            fontSize = 14,
            anchor = {
                point = "TOPLEFT",
                relative = f.nameFrame,
                relativePoint = "TOPRIGHT",
                x = 0,
                y = 0
            }
        })

        f.scoreFrame = Meeting.GUI.CreateText({
            parent = f,
            text = "",
            fontSize = 14,
            width = 40,
            anchor = {
                point = "TOPLEFT",
                relative = f.levelFrame,
                relativePoint = "TOPRIGHT",
                x = 0,
                y = 0
            }
        })

        f.commentFrame = Meeting.GUI.CreateText({
            parent = f,
            text = "",
            fontSize = 14,
            width = 290,
            height = 24,
            anchor = {
                point = "TOPLEFT",
                relative = f.scoreFrame,
                relativePoint = "TOPRIGHT",
                x = 0,
                y = 0
            }
        })

        f.acceptButton = Meeting.GUI.CreateButton({
            parent = f,
            text = "同意",
            type = Meeting.GUI.BUTTON_TYPE.SUCCESS,
            width = 34,
            height = 18,
            anchor = {
                point = "TOPLEFT",
                relative = f.commentFrame,
                relativePoint = "TOPRIGHT",
                x = 0,
                y = 3
            },
            click = function()
                f.applicant.status = Meeting.APPLICANT_STATUS.Invited
                InviteByName(f.applicant.name)
                this:SetText("已同意")
                this:Disable()
            end
        })

        f.declineButton = Meeting.GUI.CreateButton({
            parent = f,
            text = "x",
            type = Meeting.GUI.BUTTON_TYPE.DANGER,
            width = 18,
            height = 18,
            anchor = {
                point = "TOPLEFT",
                relative = f.acceptButton,
                relativePoint = "TOPRIGHT",
                x = 4,
                y = 0
            },
            click = function()
                f.applicant.status = Meeting.APPLICANT_STATUS.Declined
                Meeting.Message.Decline(string.format("%s", f.applicant.name))
                local activity = Meeting:FindActivity(Meeting.player)
                if activity then
                    local i = -1
                    for index, value in ipairs(activity.applicantList) do
                        if value.name == f.applicant.name then
                            i = index
                            break
                        end
                    end
                    table.remove(activity.applicantList, i)
                    Meeting.CreatorFrame:UpdateList()
                end
            end
        })
    end
})

function Meeting.CreatorFrame:UpdateList()
    if not Meeting.CreatorFrame:IsShown() then
        return
    end

    local activity = Meeting:FindActivity(Meeting.player)
    applicantListFrame:Reload(activity and table.getn(activity.applicantList) or 0, function(frame, index)
        local applicant = activity.applicantList[index]
        local name = applicant.name

        frame.nameFrame:SetText(name)
        local rgb = Meeting.GetClassRGBColor(applicant.class, name)
        frame.nameFrame:SetTextColor(rgb.r, rgb.g, rgb.b)
        frame.levelFrame:SetText(applicant.level)
        frame.scoreFrame:SetText(applicant.score == 0 and "-" or applicant.score)
        frame.commentFrame:SetText(applicant.comment ~= "_" and applicant.comment or "")

        if applicant.status == Meeting.APPLICANT_STATUS.Accepted then
            frame.acceptButton:SetText("已同意")
            frame.acceptButton:Disable()
        elseif applicant.status == Meeting.APPLICANT_STATUS.None then
            frame.acceptButton:SetText("同意")
            frame.acceptButton:Enable()
        end
        frame.applicant = applicant
        frame.classColor = rgb
    end)
end

applicantListFrame.OnScroll = Meeting.CreatorFrame.UpdateList

function Meeting.CreatorFrame.UpdateActivity()
    if Meeting.createInfo.category then
        selectButton:SetText(Meeting.FindCaregoryByCode(Meeting.createInfo.category).name)
    end
    commentFrame:SetText(Meeting.createInfo.comment or "")

    if Meeting:GetMembers() > 1 and IsRaidLeader() ~= 1 then
        createButton:Disable()
        closeButton:Disable()
    else
        local has = Meeting:HasActivity()
        if has then
            createButton:SetText("修改活动")
        else
            createButton:SetText("创建活动")
        end

        if string.isempty(Meeting.createInfo.category) then
            createButton:Disable()
        else
            createButton:Enable()
        end

        if has then
            closeButton:Enable()
        else
            closeButton:Disable()
        end
    end
end

Meeting.CreatorFrame.UpdateActivity()
