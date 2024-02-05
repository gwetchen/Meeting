local GUI = {}

Meeting.GUI = GUI

local function SetMovable(frame)
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

function GUI.CreateFrame(config)
    local parent = config.parent or UIParent
    local frame = CreateFrame("Frame", config.name, parent, config.template)
    frame:SetWidth(config.width)
    frame:SetHeight(config.height)
    if config.anchor then
        frame:SetPoint(config.anchor.point, config.anchor.relative, config.anchor.relativePoint, config.anchor.x or 0,
            config.anchor.y or 0)
    end
    if config.movable then
        SetMovable(frame)
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

Meeting.GUI.BUTTON_TYPE = {
    NORMAL = 1,
    PRIMARY = 2,
    SUCCESS = 3,
    DANGER = 4
}

function GUI.CreateButton(config)
    local parent = config.parent or UIParent
    local button = CreateFrame("Button", config.name, parent, config.template)
    button:SetWidth(config.width)
    button:SetHeight(config.height)
    if config.anchor then
        button:SetPoint(config.anchor.point, config.anchor.relative, config.anchor.relativePoint, config.anchor.x or 0,
            config.anchor.y or 0)
    end
    if config.movable then
        SetMovable(button)
    end
    button:SetText(config.text or "")
    button:SetTextColor(1, 1, 1)
    button:SetDisabledTextColor(0.8, 0.8, 0.8)
    button:SetFont(STANDARD_TEXT_FONT, config.fontSize or 16)
    button:SetScript("OnClick", function()
        if config.click then
            config.click(arg1)
        end
    end)

    button:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        -- edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        tile = false,
        tileSize = 0,
        edgeSize = 0.7,
        insets = {
            left = -0.7,
            right = -0.7,
            top = -0.7,
            bottom = -0.7
        }
    })

    if not config.type then
        config.type = Meeting.GUI.BUTTON_TYPE.NORMAL
    end

    if config.type == Meeting.GUI.BUTTON_TYPE.NORMAL then
        button:SetBackdropColor(0, 0, 0, 0)
    elseif config.type == Meeting.GUI.BUTTON_TYPE.PRIMARY then
        button:SetBackdropColor(245 / 255, 127 / 255, 26 / 255, 1)
    elseif config.type == Meeting.GUI.BUTTON_TYPE.SUCCESS then
        button:SetBackdropColor(103 / 255, 194 / 255, 58 / 255, 1)
    elseif config.type == Meeting.GUI.BUTTON_TYPE.DANGER then
        button:SetBackdropColor(245 / 255, 108 / 255, 108 / 255, 1)
    end

    return button
end

local backgroundColor = {
    r = 24 / 255,
    g = 20 / 255,
    b = 18 / 255
}

local borderColor = {
    r = 1,
    g = 1,
    b = 1
}

function GUI.CreateBackground(frame, config)
    frame:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        tile = false,
        tileSize = 0,
        edgeSize = 0.7,
        insets = {
            left = -0.7,
            right = -0.7,
            top = -0.7,
            bottom = -0.7
        }
    })
    if not config.color then
        config.color = backgroundColor
    end
    frame:SetBackdropColor(config.color.r, config.color.g, config.color.b, 1)
    if not config.borderColor then
        config.borderColor = borderColor
    end
    frame:SetBackdropBorderColor(config.borderColor.r, config.borderColor.g, config.borderColor.b, 1)
end

function GUI.CreateListFrame(config)
    local frame = CreateFrame("ScrollFrame", config.name, config.parent or UIParent,
        "FauxScrollFrameTemplate")
    frame:SetWidth(config.width)
    frame:SetHeight(config.height)
    if config.anchor then
        frame:SetPoint(config.anchor.point, config.anchor.relative, config.anchor.relativePoint, config.anchor.x or 0,
            config.anchor.y or 0)
    end
    frame:SetScript("OnVerticalScroll", function()
        FauxScrollFrame_OnVerticalScroll(config.step, function()
            this.scroll(true)
        end)
    end)
    frame.Render = function(self, num, cb)
        FauxScrollFrame_Update(self, num, config.display, config.step, nil, nil, nil, nil, config.width, config
            .height)
        for i = 1, config.display, 1 do
            local j = i + FauxScrollFrame_GetOffset(self)
            if j <= num then
                cb(i, j)
            end
        end
    end
    return frame
end

function Meeting.GUI.CreateTabs(config)
    local parent = config.parent or UIParent
    local f = CreateFrame("Frame", nil, parent)
    f:SetWidth(config.width * table.getn(config.list))
    f:SetHeight(config.height)
    f:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, 0)
    f.tabs = {}
    for index, value in ipairs(config.list) do
        local info = value
        local button = Meeting.GUI.CreateButton({
            parent = f,
            width = config.width,
            height = config.height,
            text = info.title,
            anchor = {
                point = "TOPLEFT",
                relative = f.tabs[index - 1] or f,
                relativePoint = f.tabs[index - 1] and "TOPRIGHT" or "TOPLEFT",
                x = 0,
                y = 0
            },
            click = function()
                for _, value in ipairs(f.tabs) do
                    value:SetBackdropColor(53 / 255, 47 / 255, 44 / 255, 1)
                end
                this:SetBackdropColor(24 / 255, 20 / 255, 18 / 255, 1)
                info.select(index)
            end
        })
        button:SetBackdropColor(53 / 255, 47 / 255, 44 / 255, 1)
        table.insert(f.tabs, button)
    end

    f.tabs[config.default or 1]:SetBackdropColor(24 / 255, 20 / 255, 18 / 255, 1)
end
