local Menu = AceLibrary("Dewdrop-2.0")

local creatorFrame = CreateFrame("Frame", nil, Meeting.MainFrame)
creatorFrame:SetWidth(782)
creatorFrame:SetHeight(388)
creatorFrame:SetPoint("TOPLEFT", Meeting.MainFrame, "TOPLEFT", 18, -18)
creatorFrame:Hide()
Meeting.CreatorFrame = creatorFrame

local categoryTextFrame = Meeting.GUI.CreateText({
    parent = creatorFrame,
    text = "活动类型：",
    fontSize = 16,
    anchor = {
        point = "TOPLEFT",
        relative = creatorFrame,
        relativePoint = "TOPLEFT",
        x = 0,
        y = 0
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
                categoryTextFrame:SetText("活动类型：" .. name)
                Menu:Close()
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
    parent = creatorFrame,
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

local commentTextFrame = Meeting.GUI.CreateText({
    parent = creatorFrame,
    text = "活动说明：",
    fontSize = 16,
    anchor = {
        point = "TOPLEFT",
        relative = selectButton,
        relativePoint = "BOTTOMLEFT",
        x = 0,
        y = -22
    }
})

local scrollFrame = CreateFrame("ScrollFrame", "MeetingCreateScrollFrame", creatorFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetWidth(220)
scrollFrame:SetHeight(140)
scrollFrame:SetPoint("TOPLEFT", commentTextFrame, 0, -22)

local commentFrame = CreateFrame("EditBox", "MeetingCreateEditBox", scrollFrame)
commentFrame:SetWidth(220)
commentFrame:SetHeight(140)
commentFrame:SetMultiLine(true)
commentFrame:SetMaxLetters(255)
commentFrame:SetAutoFocus(false)
commentFrame:SetScript("OnTextChanged", function(e)
    Meeting.createInfo.comment = commentFrame:GetText()
end)
commentFrame:SetScript("OnEscapePressed", function()
    commentFrame:ClearFocus()
end)
commentFrame:SetFontObject("ChatFontNormal")
scrollFrame:SetScrollChild(commentFrame)

local createButton = Meeting.GUI.CreateButton({
    parent = creatorFrame,
    width = 80,
    height = 24,
    text = "创建活动",
    anchor = {
        point = "TOPLEFT",
        relative = scrollFrame,
        relativePoint = "BOTTOMLEFT",
        x = 0,
        y = -20
    },
    click = function()
        this:SetText("修改活动")
        commentFrame:ClearFocus()
        local data = string.format("%s:%s:%s:%d:%d:%d:%d", UnitName("player"), Meeting.createInfo.category,
            string.isempty(Meeting.createInfo.comment) and "_" or Meeting.createInfo.comment, UnitLevel("player"),
            Meeting.ClassToNumber(Meeting.GetPlayerClass()),
            Meeting:GetMembers() + 1, Meeting.playerIsHC and 1 or 0)
        Meeting:CreateActivity(data)
    end
})

local closeButton = Meeting.GUI.CreateButton({
    parent = creatorFrame,
    width = 80,
    height = 24,
    text = "解散活动",
    anchor = {
        point = "TOPLEFT",
        relative = createButton,
        relativePoint = "TOPRIGHT",
        x = 0,
        y = 0
    },
    click = function()

    end
})
closeButton:Disable()

local applicantListHeaderFrame = CreateFrame("Frame", nil, creatorFrame)
applicantListHeaderFrame:SetWidth(520)
applicantListHeaderFrame:SetHeight(24)
applicantListHeaderFrame:SetPoint("TOPLEFT", creatorFrame, "TOPLEFT", 260, 0)

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
    width = 60,
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
    width = 60,
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

local applicantListFrame = CreateFrame("Frame", nil, creatorFrame)
applicantListFrame:SetWidth(520)
applicantListFrame:SetHeight(352)
applicantListFrame:SetPoint("TOPLEFT", applicantListHeaderFrame, "BOTTOMLEFT", 0, 0)

local applicantFramePool = {}

local function CreateApplicantItemFrame()
    local f = CreateFrame("Frame", nil, applicantListFrame)
    f:SetWidth(520)
    f:SetHeight(44)

    local nameText = Meeting.GUI.CreateText({
        parent = f,
        text = "",
        fontSize = 14,
        width = 80,
        anchor = {
            point = "TOPLEFT",
            relative = f,
            relativePoint = "TOPLEFT",
            x = 0,
            y = 0
        }
    })


    local levelText = Meeting.GUI.CreateText({
        parent = f,
        text = "",
        width = 60,
        fontSize = 14,
        anchor = {
            point = "TOPLEFT",
            relative = nameText,
            relativePoint = "TOPRIGHT",
            x = 0,
            y = 0
        }
    })

    local scoreText = Meeting.GUI.CreateText({
        parent = f,
        text = "",
        fontSize = 14,
        width = 60,
        anchor = {
            point = "TOPLEFT",
            relative = levelText,
            relativePoint = "TOPRIGHT",
            x = 0,
            y = 0
        }
    })

    local commentText = Meeting.GUI.CreateText({
        parent = f,
        text = "",
        fontSize = 14,
        width = 250,
        anchor = {
            point = "TOPLEFT",
            relative = scoreText,
            relativePoint = "TOPRIGHT",
            x = 0,
            y = 0
        }
    })

    local item = {
        frame = f,
        nameText = nameText,
        levelText = levelText,
        scoreText = scoreText,
        commentText = commentText,
    }

    local acceptButton = Meeting.GUI.CreateButton({
        parent = f,
        text = "同意",
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
            item.accept()
            this:SetText("已同意")
            this:Disable()
        end
    })

    local declineButton = Meeting.GUI.CreateButton({
        parent = f,
        text = "拒绝",
        width = 44,
        height = 24,
        anchor = {
            point = "TOPLEFT",
            relative = acceptButton,
            relativePoint = "TOPRIGHT",
            x = 0,
            y = 0
        },
        click = function()
            item.decline()
        end
    })

    item.acceptButton = acceptButton
    item.declineButton = declineButton

    table.insert(applicantFramePool, item)
end

for i = 1, 5 do
    CreateApplicantItemFrame()
end

function Meeting.CreatorFrame:UpdateApplicantList()
    local id = UnitName("player")
    local activity = FindActivity()
    if table.getn(activity.applicantList) > table.getn(applicantFramePool) then
        for i = table.getn(applicantFramePool) + 1, table.getn(activity.applicantList) do
            CreateApplicantItemFrame()
        end
    end

    for i, item in ipairs(applicantFramePool) do
        if i > table.getn(activity.applicantList) then
            item.frame:Hide()
        else
            local applicant = activity.applicantList[i]
            local name = applicant.name

            item.frame:SetPoint("TOPLEFT", applicantListFrame, "TOPLEFT", 0, -44 * (i - 1))
            item.nameText:SetText(applicant.name)
            local rgb = Meeting.GetClassRGBColor(applicant.class, applicant.name)
            item.nameText:SetTextColor(rgb.r, rgb.g, rgb.b)
            item.levelText:SetText(applicant.level)
            item.scoreText:SetText(applicant.score)
            item.commentText:SetText(applicant.comment ~= "_" and applicant.comment or "")

            item.accept = function()
                applicant.status = Meeting.APPLICANT_STATUS.Invited
                InviteByName(name)
            end
            item.decline = function()
                applicant.status = Meeting.APPLICANT_STATUS.Declined
                Meeting:SendMessage("DECLINE", string.format("%s:%s", id, name))
            end
            item.frame:Show()
        end
    end
end
