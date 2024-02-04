local floatFrame = Meeting.GUI.CreateButton({
    name = "MettingFloatFrame",
    width = 100,
    height = 34,
    text = "集合石 0/0",
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
floatFrame:SetFrameStrata("DIALOG")
floatFrame:SetPoint("TOP", 0, -20)

Meeting.FloatFrame = floatFrame

function Meeting.FloatFrame.Update()
    local activity = Meeting:FindActivity(Meeting.player)
    local n = activity and table.getn(activity.applicantList) or 0
    floatFrame:SetText("集合石 " .. n .. "/" .. table.getn(Meeting.activities))
end
