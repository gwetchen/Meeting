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
    if Meeting.GUI_DEBUG then
        GUI.CreateBackground(frame, {
            borderColor = {
                r = math.random(0, 1),
                g = math.random(0, 1),
                b = math.random(0, 1)
            }
        })
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
    text:SetFont(STANDARD_TEXT_FONT, config.fontSize or 14, "OUTLINE")
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
    text:SetText(config.text)

    return text
end

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
    button:SetText(config.text)
    button:SetTextColor(1, 1, 1)
    button:SetFont(STANDARD_TEXT_FONT, config.fontSize or 16, "OUTLINE")
    button:SetScript("OnClick", function()
        if arg1 == "LeftButton" and config.click then
            config.click()
        end
    end)
    button:SetDisabledTextColor(0.5, 0.5, 0.5)

    if Meeting.GUI_DEBUG then
        GUI.CreateBackground(button, {
            borderColor = {
                r = math.random(0, 1),
                g = math.random(0, 1),
                b = math.random(0, 1)
            }
        })
    else
        button:SetBackdrop({
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
        button:SetBackdropColor(0, 0, 0, 1)
    end
    return button
end

local backgroundColor = {
    r = 0.1,
    g = 0.1,
    b = 0.1
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
