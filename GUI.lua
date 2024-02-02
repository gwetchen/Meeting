local GUI = {}

Meeting.GUI = GUI

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
    button:SetText(config.text)
    button:SetTextColor(1, 1, 1)
    button:SetFont(STANDARD_TEXT_FONT, config.fontSize or 16, "OUTLINE")
    button:SetScript("OnClick", function()
        if arg1 == "LeftButton" and config.click then
            config.click()
        end
    end)
    button:SetDisabledTextColor(0.5, 0.5, 0.5)
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
    return button
end

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
    frame:SetBackdropColor(config.color.r, config.color.g, config.color.b, 1)
end
