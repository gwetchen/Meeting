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

local activityTypeTextFrame = Meeting.GUI.CreateText({
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
    if not value.hide then
        local children = {}

        for j, child in ipairs(value.children) do
            local k = child.key
            local name = child.name
            children[k] = {
                order = j,
                type = "toggle",
                name = name,
                desc = name,
                get = function() return Meeting.createInfo.code == k end,
                set = function()
                    Meeting.createInfo.code = k
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
end

local selectButton = Meeting.GUI.CreateButton({
    parent = creatorInfoFrame,
    name = "MeetingCreatorSelectButton",
    text = "Select activity",
    width = 120,
    height = 24,
    type = Meeting.GUI.BUTTON_TYPE.PRIMARY,
    anchor = {
        point = "TOPLEFT",
        relative = activityTypeTextFrame,
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
    text = "Group Description：",
    fontSize = 16,
    anchor = {
        point = "TOPLEFT",
        relative = activityTypeTextFrame,
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
commentFrame._focus = false
commentFrame.HasFocus = function(self)
    return self._focus == true
end
commentFrame:SetScript("OnEditFocusGained", function()
    this._focus = true
end)
commentFrame:SetScript("OnEditFocusLost", function()
    this._focus = false
    local text = commentFrame:GetText()
    text = string.gsub(text, "\n", "")
    text = string.gsub(text, ":", "：")
    commentFrame:SetText(text)
    if not Meeting.joinedActivity then
        Meeting.createInfo.comment = text
    end
end)
commentFrame:SetScript("OnEscapePressed", function()
    commentFrame:ClearFocus()
end)

local createButton = Meeting.GUI.CreateButton({
    parent = creatorInfoFrame,
    width = 80,
    height = 24,
    text = "CList Group",
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
        Meeting.Message.CreateActivity(Meeting.createInfo.code, Meeting.createInfo.comment)
    end
})
createButton:Disable()

local closeButton = Meeting.GUI.CreateButton({
    parent = creatorInfoFrame,
    width = 80,
    height = 24,
    text = "Delete",
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
    text = "Name",
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
    text = "Level",
    fontSize = 14,
    width = 40,
    height = 24,
    anchor = {
        point = "TOPLEFT",
        relative = nameText,
        relativePoint = "TOPRIGHT",
    }
})

local roleText = Meeting.GUI.CreateText({
    parent = applicantListHeaderFrame,
    text = "Role",
    fontSize = 14,
    width = 40,
    height = 24,
    anchor = {
        point = "TOPLEFT",
        relative = levelText,
        relativePoint = "TOPRIGHT",
    }
})

local scoreText = Meeting.GUI.CreateText({
    parent = applicantListHeaderFrame,
    text = "Gearscore",
    fontSize = 14,
    width = 160,
    height = 24,
    anchor = {
        point = "TOPLEFT",
        relative = roleText,
        relativePoint = "TOPRIGHT",

    }
})

local commentText = Meeting.GUI.CreateText({
    parent = applicantListHeaderFrame,
    text = "message",
    fontSize = 14,
    width = 250,
    height = 24,
    anchor = {
        point = "TOPLEFT",
        relative = scoreText,
        relativePoint = "TOPRIGHT",
    }
})

local actionText = Meeting.GUI.CreateText({
    parent = applicantListHeaderFrame,
    text = "operate",
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
    name = "MeetingApplicantListFrame",
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
        f.OnHover = function(self, isHover)
            if isHover then
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT", 40)
                GameTooltip:SetText(this.applicant.name, this.classColor.r, this.classColor.g, this.classColor.b, 1)
                if this.applicant.score > 0 then
                    GameTooltip:AddLine("Decoration: " .. this.applicant.score)
                end

                local color = GetDifficultyColor(this.applicant.level)
                GameTooltip:AddLine(
                    format('%s |cff%02x%02x%02x%s|r', LEVEL, color.r * 255, color.g * 255, color.b * 255,
                        this.applicant.level), 1, 1, 1)

                if this.applicant.comment ~= "_" then
                    GameTooltip:AddLine(this.applicant.comment, 0.75, 0.75, 0.75, 1)
                end
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("<Double click> Private message", 1, 1, 1, 1)
                GameTooltip:SetWidth(220)
                GameTooltip:Show()
            else
                GameTooltip:Hide()
            end
        end
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

        f.roleFrame = Meeting.GUI.CreateFrame({
            parent = f,
            width = 40,
            height = 24,
            anchor = {
                point = "TOPLEFT",
                relative = f.levelFrame,
                relativePoint = "TOPRIGHT",
                x = 0,
                y = 0
            }
        })

        local tank = f:CreateTexture()
        tank:SetTexture("Interface\\AddOns\\Meeting\\assets\\tank.blp")
        tank:SetWidth(11)
        tank:SetHeight(11)
        f.roleFrame.tank = tank

        local healer = f:CreateTexture()
        healer:SetTexture("Interface\\AddOns\\Meeting\\assets\\healer.blp")
        healer:SetWidth(11)
        healer:SetHeight(11)
        f.roleFrame.healer = healer

        local damage = f:CreateTexture()
        damage:SetTexture("Interface\\AddOns\\Meeting\\assets\\damage.blp")
        damage:SetWidth(11)
        damage:SetHeight(11)
        f.roleFrame.damage = damage

        f.scoreFrame = Meeting.GUI.CreateText({
            parent = f,
            text = "",
            fontSize = 14,
            width = 40,
            anchor = {
                point = "TOPLEFT",
                relative = f.roleFrame,
                relativePoint = "TOPRIGHT",
                x = 0,
                y = 0
            }
        })

        f.commentFrame = Meeting.GUI.CreateText({
            parent = f,
            text = "",
            fontSize = 14,
            width = 250,
            height = 24,
            anchor = {
                point = "TOPLEFT",
                relative = f.scoreFrame,
                relativePoint = "TOPRIGHT",
                x = 0,
                y = 0
            }
        })
        f.commentFrame:SetJustifyV("TOP")

        f.acceptButton = Meeting.GUI.CreateButton({
            parent = f,
            text = "agree",
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
                this:SetText("already agree")
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
                Meeting.Message.Decline(f.applicant.name)
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

    local activity = Meeting.joinedActivity or Meeting:FindActivity(Meeting.player)
    local notLeader = IsRaidLeader() ~= 1
    applicantListFrame:Reload(activity and table.getn(activity.applicantList) or 0, function(frame, index)
        local applicant = activity.applicantList[index]
        local name = applicant.name

        frame.nameFrame:SetText(name)
        local rgb = Meeting.GetClassRGBColor(applicant.class, name)
        frame.nameFrame:SetTextColor(rgb.r, rgb.g, rgb.b)
        frame.levelFrame:SetText(applicant.level)
        frame.scoreFrame:SetText(applicant.score == 0 and "-" or applicant.score)
        frame.commentFrame:SetText(applicant.comment ~= "_" and applicant.comment or "")

        frame.roleFrame.tank:Hide()
        frame.roleFrame.healer:Hide()
        frame.roleFrame.damage:Hide()

        if applicant.role ~= 0 then
            local prev = nil
            if bit.band(applicant.role, Meeting.Role.Tank) == Meeting.Role.Tank then
                prev = frame.roleFrame.tank
                frame.roleFrame.tank:SetPoint("TOPLEFT", frame.roleFrame, "TOPLEFT", 0, 0)
                frame.roleFrame.tank:Show()
            end
            if bit.band(applicant.role, Meeting.Role.Healer) == Meeting.Role.Healer then
                if prev then
                    frame.roleFrame.healer:SetPoint("TOPLEFT", prev, "TOPRIGHT", 1, 0)
                else
                    frame.roleFrame.healer:SetPoint("TOPLEFT", frame.roleFrame, "TOPLEFT", 0, 0)
                end
                prev = frame.roleFrame.healer
                frame.roleFrame.healer:Show()
            end
            if bit.band(applicant.role, Meeting.Role.Damage) == Meeting.Role.Damage then
                if prev then
                    frame.roleFrame.damage:SetPoint("TOPLEFT", prev, "TOPRIGHT", 1, 0)
                else
                    frame.roleFrame.damage:SetPoint("TOPLEFT", frame.roleFrame, "TOPLEFT", 0, 0)
                end
                frame.roleFrame.damage:Show()
            end
        end

        if notLeader then
            frame.acceptButton:Hide()
            frame.declineButton:Hide()
        else
            frame.acceptButton:Show()
            frame.declineButton:Show()
        end

        if applicant.status == Meeting.APPLICANT_STATUS.Accepted then
            frame.acceptButton:SetText("already agree")
            frame.acceptButton:Disable()
        elseif applicant.status == Meeting.APPLICANT_STATUS.None then
            frame.acceptButton:SetText("agree")
            frame.acceptButton:Enable()
        elseif applicant.status == Meeting.APPLICANT_STATUS.Declined then
            frame.acceptButton:SetText("already reject")
            frame.acceptButton:Enable()
        end
        frame.applicant = applicant
        frame.classColor = rgb
    end)
end

applicantListFrame.OnScroll = Meeting.CreatorFrame.UpdateList

function Meeting.CreatorFrame.UpdateActivity()
    if not Meeting.MainFrame:IsShown() or not Meeting.CreatorFrame:IsShown() then
        return
    end

    local ml = table.getn(Meeting.members)
    local isLeader = ml == 0 or (ml > 0 and IsRaidLeader() == 1)
    if isLeader then
        if Meeting.createInfo.code then
            selectButton:SetText(Meeting.GetActivityInfo(Meeting.createInfo.code).name)
        else
            selectButton:SetText("Select activity")
        end
        if not commentFrame:HasFocus() then
            commentFrame:SetText(Meeting.createInfo.comment or "")
        end
        selectButton:Enable()
        local has = Meeting:OwnerActivity()
        if has then
            createButton:SetText("Update Listing")
        else
            createButton:SetText("List Group")
        end

        if string.isempty(Meeting.createInfo.code) then
            createButton:Disable()
        else
            createButton:Enable()
        end

        if has then
            closeButton:Enable()
        else
            closeButton:Disable()
        end

        if table.getn(Meeting.members) > 0 and IsRaidLeader() ~= 1 then
            createButton:Hide()
            closeButton:Hide()
        else
            createButton:Show()
            closeButton:Show()
        end
    elseif Meeting.joinedActivity then
        selectButton:SetText(Meeting.GetActivityInfo(Meeting.joinedActivity.code).name)
        commentFrame:SetText(Meeting.joinedActivity.comment == "_" and "" or Meeting.joinedActivity.comment or "")
        selectButton:Disable()
        createButton:Hide()
        closeButton:Hide()
    else
        selectButton:SetText("Select activity")
        commentFrame:SetText("")
        selectButton:Disable()
        createButton:Hide()
        closeButton:Hide()
    end
end

Meeting.CreatorFrame.UpdateActivity()
