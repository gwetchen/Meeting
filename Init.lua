Meeting = {
    APPLICANT_STATUS = { None = 1, Invited = 2, Declined = 3, Joined = 4 },

    Categories = {
        [1] = {
            value = "QUEST",
            label = "任务",
            children = {}
        },
        [2] = {
            value = "RAID",
            label = "团队副本",
            children = {
                [1] = {
                    value = "MC",
                    label = "熔火之心"
                },
                [2] = {
                    value = "ONY",
                    label = "奥妮克希亚的巢穴"
                },
                [3] = {
                    value = "BWL",
                    label = "黑翼之巢"
                },
                [4] = {
                    value = "AQ40",
                    label = "安其拉神殿"
                },
                [5] = {
                    value = "NAXX",
                    label = "纳克萨玛斯"
                },
                [6] = {
                    value = "ZUG",
                    label = "祖尔格拉布"
                },
                [7] = {
                    value = "AQ20",
                    label = "安其拉废墟"
                },
                [8] = {
                    value = "LKH",
                    label = "卡拉赞下层"
                },
                [9] = {
                    value = "ES",
                    label = "翡翠圣殿"
                }
            }
        },
        [3] = {
            value = "DUNGENO",
            label = "地下城",
            children = {}
        },
        [4] = {
            value = "BOSS",
            label = "世界首领",
            children = {}
        },
        [5] = {
            value = "PVP",
            label = "PvP",
            children = {}
        },
        [6] = {
            value = "OTHER",
            label = "其他",
            children = {}
        }
    }
}

function Meeting:GetMembers()
    local partyCount = GetNumPartyMembers()
    local raidCount = GetNumRaidMembers()
    if raidCount > 0 then
        return raidCount
    else
        return partyCount
    end
end

function Meeting:IsInActivity(id)
    for i = 1, GetNumRaidMembers() do
        local n = UnitName("raid" .. i)
        if n and n == id then
            return true
        end
    end
    for i = 1, GetNumPartyMembers() do
        local n = UnitName("party" .. i)
        if n and n == id then
            return true
        end
    end
    return false
end
