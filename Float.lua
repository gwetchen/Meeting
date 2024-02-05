local floatFrame = Meeting.GUI.CreateButton({
    name = "MettingFloatFrame",
    width = 100,
    height = 34,
    text = "集合石 0/0",
    type = Meeting.GUI.BUTTON_TYPE.NORMAL,
    anchor = {
        point = "TOP",
        x = 0,
        y = 0
    },
    movable = true,
    click = function()
        Meeting:Toggle()
    end
})
Meeting.GUI.SetBackground(floatFrame, Meeting.GUI.Theme.Brown, Meeting.GUI.Theme.White)
floatFrame:SetFrameStrata("DIALOG")
floatFrame:SetPoint("TOP", 0, -20)
floatFrame:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT", 85, -5)
    local activity = Meeting:FindActivity(Meeting.player)
    GameTooltip:SetText((activity and table.getn(activity.applicantList) or 0) .. "人申请", 1, 1, 1, 1)
    GameTooltip:AddLine(table.getn(Meeting.activities) .. "个活动", 1, 1, 1, 1)
    GameTooltip:Show()
end)
floatFrame:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

Meeting.FloatFrame = floatFrame

function floatFrame.Update()
    local activity = Meeting:FindActivity(Meeting.player)
    local n = activity and table.getn(activity.applicantList) or 0
    floatFrame:SetText("集合石 " .. n .. "/" .. table.getn(Meeting.activities))
end
