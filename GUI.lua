local GUI = {}

Meeting.GUI = GUI

function GUI:CreateFrame(config)
    local parent = config.parent and config.parent or UIParent
    local frame = CreateFrame("Frame", config.name, parent, config.template)
    frame:SetWidth(config.width)
    frame:SetHeight(config.height)
    if config.anchor then
        frame:SetPoint(config.anchor.point, config.anchor.relative, config.anchor.relativePoint, config.anchor.x,
            config.anchor.y)
    end
    return frame
end

function GUI:CreateText(config)
    local parent = config.parent and config.parent or UIParent
    local text = parent:CreateFontString(nil)
    text:SetFont(STANDARD_TEXT_FONT, config.fontSize, "OUTLINE")
    if config.anchor then
        text:SetPoint(config.anchor.point, config.anchor.relative, config.anchor.relativePoint, config.anchor.x,
            config.anchor.y)
    end
    text:SetTextColor(1, 1, 1)
    text:SetText(config.text)
    return text
end

function GUI:CreateButton(config)
    local parent = config.parent and config.parent or UIParent
    local button = CreateFrame("Button", config.name, parent, "UIPanelButtonTemplate")
    button:SetWidth(config.width)
    button:SetHeight(config.height)
    if config.anchor then
        button:SetPoint(config.anchor.point, config.anchor.relative, config.anchor.relativePoint, config.anchor.x,
            config.anchor.y)
    end
    button:SetText(config.text)
    button:SetScript("OnClick", function()
        if arg1 == "LeftButton" and config.click then
            config.click()
        end
    end)
    return button
end
