local GUI = {

    Theme = {
        Black = {
            r = 0,
            g = 0,
            b = 0
        },
        White = {
            r = 1,
            g = 1,
            b = 1
        },
        Brown = {
            r = 24 / 255,
            g = 20 / 255,
            b = 18 / 255
        },
        LightBrown = {
            r = 53 / 255,
            g = 47 / 255,
            b = 44 / 255
        },
        Orange = {
            r = 245 / 255,
            g = 127 / 255,
            b = 26 / 255
        },
        Green = {
            r = 103 / 255,
            g = 194 / 255,
            b = 58 / 255
        },
        Red = {
            r = 245 / 255,
            g = 108 / 255,
            b = 108 / 255
        }
    },

    BUTTON_TYPE = {
        NORMAL = 1,
        PRIMARY = 2,
        SUCCESS = 3,
        DANGER = 4
    }
}

Meeting.GUI = GUI

function GUI.EnableMovable(frame)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function()
        this:StartMoving()
    end)
    frame:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
    end)
end

function GUI.SetBackground(frame, color, borderColor)
    local bg = {
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        tile = false,
        tileSize = 0,
        edgeSize = 0.7,
        insets = {
            left = -0.7,
            right = -0.7,
            top = -0.7,
            bottom = -0.7
        }
    }
    if borderColor then
        bg.edgeFile = "Interface\\BUTTONS\\WHITE8X8"
    end
    frame:SetBackdrop(bg)

    if not color then
        color = GUI.Theme.Brown
    end
    frame:SetBackdropColor(color.r, color.g, color.b, 1)

    if borderColor then
        frame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, 1)
    end
end

function GUI.CreateFrame(config)
    local parent = config.parent or UIParent
    local frame = CreateFrame(config.frameType or "Frame", config.name, parent, config.template)
    frame:SetWidth(config.width or 0)
    frame:SetHeight(config.height or 0)
    if config.anchor then
        frame:SetPoint(config.anchor.point, config.anchor.relative, config.anchor.relativePoint, config.anchor.x or 0,
            config.anchor.y or 0)
    end
    if config.background then
        GUI.SetBackground(frame, config.background)
    end
    if config.movable then
        GUI.EnableMovable(frame)
    end
    if config.hide then
        frame:Hide()
    end
    return frame
end

function GUI.CreateText(config)
    local parent = config.parent or UIParent
    local text = parent:CreateFontString(nil)
    text:SetWidth(config.width or 0)
    text:SetHeight(config.height or 0)
    text:SetFont(STANDARD_TEXT_FONT, config.fontSize or 14)
    if config.anchor then
        text:SetPoint(config.anchor.point, config.anchor.relative, config.anchor.relativePoint, config.anchor.x or 0,
            config.anchor.y or 0)
    end
    if config.color then
        text:SetTextColor(config.color.r, config.color.g, config.color.b)
    else
        text:SetTextColor(1, 1, 1)
    end
    text:SetJustifyH("LEFT")
    text:SetText(config.text or "")
    return text
end

function GUI.CreateButton(config)
    config.frameType = "Button"
    local button = GUI.CreateFrame(config)
    button:SetText(config.text or "")
    button:SetTextColor(1, 1, 1)
    button:SetDisabledTextColor(0.8, 0.8, 0.8)
    button:SetFont(STANDARD_TEXT_FONT, config.fontSize or 16)
    button:SetScript("OnClick", function()
        if config.click then
            config.click(arg1)
        end
    end)

    if not config.type then
        config.type = Meeting.GUI.BUTTON_TYPE.NORMAL
    end

    if config.type == Meeting.GUI.BUTTON_TYPE.NORMAL then
        GUI.SetBackground(button, GUI.Theme.Brown)
    elseif config.type == Meeting.GUI.BUTTON_TYPE.PRIMARY then
        GUI.SetBackground(button, GUI.Theme.Orange)
    elseif config.type == Meeting.GUI.BUTTON_TYPE.SUCCESS then
        GUI.SetBackground(button, GUI.Theme.Green)
    elseif config.type == Meeting.GUI.BUTTON_TYPE.DANGER then
        GUI.SetBackground(button, GUI.Theme.Red)
    end

    if config.disabled then
        button:Disable()
    end

    return button
end

local hoverBackgrop = {
    edgeFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeSize = 24,
    insets = { left = -1, right = -1, top = -1, bottom = -1 },
}

function GUI.CreateListFrame(config)
    config.frameType = "ScrollFrame"
    config.template = "FauxScrollFrameTemplate"
    local frame = GUI.CreateFrame(config)
    frame.pool = {}
    for i = 1, config.display do
        local cell = Meeting.GUI.CreateButton({
            parent = config.parent,
            width = config.width,
            height = config.step,
        })
        cell:SetPoint("TOPLEFT", config.anchor.relative, "BOTTOMLEFT", 0, -config.step * (i - 1))
        cell:SetBackdrop(hoverBackgrop)
        cell:SetBackdropBorderColor(1, 1, 1, .04)
        cell:EnableMouse(true)
        cell:SetScript("OnEnter", function()
            this:SetBackdropBorderColor(1, 1, 1, .2)
            this:OnHover(true)
        end)
        cell:SetScript("OnLeave", function()
            this:SetBackdropBorderColor(1, 1, 1, .04)
            this:OnHover(false)
        end)
        cell:Hide()
        table.insert(frame.pool, cell)
        config.cell(cell)
    end
    frame:SetScript("OnVerticalScroll", function()
        FauxScrollFrame_OnVerticalScroll(config.step, function()
            this.OnScroll(this, true, true)
        end)
    end)
    frame.Reload = function(self, num, cb)
        if num < config.display then
            for i = num + 1, config.display do
                local cell = frame.pool[i]
                cell:Hide()
            end
        end

        FauxScrollFrame_Update(self, num, config.display, config.step, nil, nil, nil, nil, config.width, config
            .height)
        local offset = FauxScrollFrame_GetOffset(self)
        for i = 1, config.display, 1 do
            local j = i + offset
            if j <= num then
                local cell = frame.pool[i]
                cell:Show()
                cb(cell, j)
            end
        end
    end
    return frame
end

function GUI.CreateTabs(config)
    local tabWidth = config.width
    config.width = tabWidth * table.getn(config.list)
    local frame = GUI.CreateFrame(config)
    frame.tabs = {}
    for index, value in ipairs(config.list) do
        local info = value
        local prev = frame.tabs[index - 1]
        local button = GUI.CreateButton({
            parent = frame,
            width = tabWidth,
            height = config.height,
            text = info.title,
            anchor = {
                point = "TOPLEFT",
                relative = prev or frame,
                relativePoint = prev and "TOPRIGHT" or "TOPLEFT",
                x = 0,
                y = 0
            },
            click = function()
                for _, tab in ipairs(frame.tabs) do
                    tab:SetBackdropColor(GUI.Theme.LightBrown.r, GUI.Theme.LightBrown.g, GUI.Theme.LightBrown.b, 1)
                end
                this:SetBackdropColor(GUI.Theme.Brown.r, GUI.Theme.Brown.g, GUI.Theme.Brown.b, 1)
                info.select(index)
            end
        })
        button:SetBackdropColor(GUI.Theme.LightBrown.r, GUI.Theme.LightBrown.g, GUI.Theme.LightBrown.b, 1)
        table.insert(frame.tabs, button)
    end

    frame.tabs[config.default or 1]:SetBackdropColor(GUI.Theme.Brown.r, GUI.Theme.Brown.g, GUI.Theme.Brown.b, 1)
end

function GUI.CreateInput(config)
    config.frameType = "EditBox"
    local frame = GUI.CreateFrame(config)
    frame:SetFontObject("ChatFontNormal")
    if config.limit then
        frame:SetMaxBytes(config.limit)
    end
    frame:SetScript("OnEscapePressed", function()
        frame:ClearFocus()
    end)
    frame:SetAutoFocus(false)
    frame:SetMultiLine(config.multiLine or false)
    return frame
end

function GUI.CreateDialog(config)
    if Meeting.GUI.currentDialog then
        Meeting.GUI.currentDialog:Hide()
    end

    config.width = config.width or 300
    config.height = config.height or 75
    local parent = GUI.CreateFrame(config)
    parent:SetFrameLevel(999)
    GUI.SetBackground(parent, GUI.Theme.Brown, GUI.Theme.White)
    local title = GUI.CreateText({
        parent = parent,
        width = config.width,
        height = 20,
        anchor = {
            point = "TOP",
            relative = parent,
            relativePoint = "TOP",
            x = 10,
            y = -10
        },
        text = config.title,
        color = GUI.Theme.White
    })

    local customFrame = nil
    if config.onCustomFrame then
        customFrame = config.onCustomFrame(parent, title)
    end

    GUI.CreateButton({
        parent = parent,
        width = 80,
        height = 24,
        text = "Confirm",
        type = GUI.BUTTON_TYPE.PRIMARY,
        anchor = {
            point = "TOPRIGHT",
            relative = customFrame or title,
            relativePoint = "BOTTOMRIGHT",
            x = 0,
            y = -10
        },
        click = function()
            config._confirm()
            parent:Hide()
            Meeting.GUI.currentDialog = nil
        end
    })

    GUI.CreateButton({
        parent = parent,
        width = 80,
        height = 24,
        text = "Cancel",
        type = GUI.BUTTON_TYPE.DANGER,
        anchor = {
            point = "TOPLEFT",
            relative = customFrame or title,
            relativePoint = "BOTTOMLEFT",
            x = 0,
            y = -10
        },
        click = function()
            parent:Hide()
            Meeting.GUI.currentDialog = nil
        end
    })
    Meeting.GUI.currentDialog = parent
    return parent
end

function GUI.CreateCheck(config)
    config.frameType = "CheckButton"
    local c = CreateFrame("CheckButton", config.name, config.parent, "UICheckButtonTemplate")
    c:SetWidth(config.width or 20)
    c:SetHeight(config.height or 20)
    if config.anchor then
        c:SetPoint(config.anchor.point, config.anchor.relative, config.anchor.relativePoint, config.anchor.x or 0,
            config.anchor.y or 0)
    end
    c:SetScript("OnClick", function()
        if config.click then
            config.click(this:GetChecked())
        end
    end)
    if config.checked then
        c:SetChecked(true)
    else
        c:SetChecked(false)
    end
    return c
end
