BINDING_HEADER_CS_MEETING_HEADER = "集合石"
BINDING_NAME_CS_MEETING_NAME = "显示/隐藏"

MEETING_DB = {}

local _, class = UnitClass("player")

Meeting = {
    player = UnitName("player"),

    playerClass = class,

    APPLICANT_STATUS = { None = 1, Invited = 2, Declined = 3, Joined = 4 },

    createInfo = {},

    searchInfo = {},

    activities = {},

    playerIsHC = false,

    -- GUI_DEBUG = true
}

local classNameMap = {
    [1] = "WARLOCK",
    [2] = "HUNTER",
    [3] = "PRIEST",
    [4] = "PALADIN",
    [5] = "MAGE",
    [6] = "ROGUE",
    [7] = "DRUID",
    [8] = "SHAMAN",
    [9] = "WARRIOR",
}

local classNumberMap = {
    ["WARLOCK"] = 1,
    ["HUNTER"] = 2,
    ["PRIEST"] = 3,
    ["PALADIN"] = 4,
    ["MAGE"] = 5,
    ["ROGUE"] = 6,
    ["DRUID"] = 7,
    ["SHAMAN"] = 8,
    ["WARRIOR"] = 9,
}

function Meeting.NumberToClass(n)
    return classNameMap[n]
end

function Meeting.ClassToNumber(class)
    return classNumberMap[class]
end

function Meeting.GetClassRGBColor(class, unitname)
    local rgb = RAID_CLASS_COLORS[class]
    if not rgb then
        if SCCN_storage then
            local cache = SCCN_storage[unitname]
            if cache then
                return Meeting.GetClassRGBColor(Meeting.NumberToClass(cache.c))
            end
        end
        rgb = { r = 1, g = 1, b = 1 }
    end
    return rgb
end

Meeting.Categories = {
    {
        key = "DUNGENO",
        name = "地下城",
        members = 5,
        children = {
            {
                key = "RFC",
                name = "怒焰裂谷",
                minLevel = 13,
            },
            {
                key = "WC",
                name = "哀号洞穴",
                minLevel = 17,
            },
            {
                key = "DM",
                name = "死亡矿井",
                minLevel = 17,
            },
            {
                key = "SFK",
                name = "影牙城堡",
                minLevel = 22,
            },
            {
                key = "STOCKS",
                name = "暴风城：监狱",
                minLevel = 22,
            },
            {
                key = "BFD",
                name = "黑暗深渊",
                minLevel = 23,
            },
            {
                key = "SMGY",
                name = "血色修道院墓地",
                minLevel = 27,
            },
            {
                key = "SMLIB",
                name = "血色修道院图书馆",
                minLevel = 28,
            },
            {
                key = "GNOMER",
                name = "诺莫瑞根",
                minLevel = 29,
            },
            {
                key = "RFK",
                name = "剃刀沼泽",
                minLevel = 29,
            },
            {
                key = "SMGY",
                name = "新月林地",
                minLevel = 32,
            },
            {
                key = "SMARMORY",
                name = "血色修道院军械库",
                minLevel = 32,
            },
            {
                key = "SMCATH",
                name = "血色修道院大教堂",
                minLevel = 35,
            },
            {
                key = "RFD",
                name = "剃刀高地",
                minLevel = 36,
            },
            {
                key = "ULDA",
                name = "奥达曼",
                minLevel = 40,
            },
            {
                key = "GILNEAS",
                name = "吉尔尼斯城",
                minLevel = 42,
            },
            {
                key = "ZF",
                name = "祖尔法拉克",
                minLevel = 44,
            },
            {
                key = "MARAPPURPLE",
                name = "玛拉顿紫门",
                minLevel = 45,
            },
            {
                key = "MARAORANGE",
                name = "玛拉顿橙门",
                minLevel = 47,
            },
            {
                key = "MARAPRINCESS",
                name = "玛拉顿公主",
                minLevel = 47,
            },
            {
                key = "ST",
                name = "阿塔哈卡神庙",
                minLevel = 50,
            },
            {
                key = "HFQ",
                name = "仇恨熔炉采石场",
                minLevel = 50,
            },
            {
                key = "BRD",
                name = "黑石深渊",
                minLevel = 52,
            },
            {
                key = "BRDARENA",
                name = "黑石深渊竞技场",
                minLevel = 52,
            },
            {
                key = "UBRS",
                name = "黑石塔上层",
                minLevel = 55,
                members = 10,
            },
            {
                key = "LBRS",
                name = "黑石塔下层",
                minLevel = 55,
            },
            {
                key = "DM",
                name = "厄运之槌：东",
                minLevel = 55,
            },
            {
                key = "DMN",
                name = "厄运之槌：北",
                minLevel = 57,
            },
            {
                key = "DMT",
                name = "厄运之槌完美贡品",
                minLevel = 57,
            },
            {
                key = "DMW",
                name = "厄运之槌：西",
                minLevel = 57,
            },
            {
                key = "SCHOLO",
                name = "通灵学院",
                minLevel = 58,
            },
            {
                key = "STRATUD",
                name = "斯坦索姆：DK区",
                minLevel = 58,
            },
            {
                key = "STRATLIVE",
                name = "斯坦索姆：血色区",
                minLevel = 58,
            },
            {
                key = "KC",
                name = "卡拉赞地穴",
                minLevel = 58,
            },
            {
                key = "COTBM",
                name = "时间之穴：黑色沼泽",
                minLevel = 60,
            },
            {
                key = "SWV",
                name = "暴风城：地牢",
                minLevel = 60,
            },
        }
    },
    {
        key = "RAID",
        name = "团队副本",
        members = 40,
        children = {
            {
                key = "MC",
                name = "熔火之心",
                minLevel = 60,
            },
            {
                key = "ONY",
                name = "奥妮克希亚的巢穴",
                minLevel = 60,
            },
            {
                key = "BWL",
                name = "黑翼之巢",
                minLevel = 60,
            },
            {
                key = "AQ40",
                name = "安其拉神殿",
                minLevel = 60,
            },
            {
                key = "NAXX",
                name = "纳克萨玛斯",
                minLevel = 60,
            },
            {
                key = "ZUG",
                name = "祖尔格拉布",
                minLevel = 60,
                members = 20,
            },
            {
                key = "AQ20",
                name = "安其拉废墟",
                minLevel = 60,
                members = 20,
            },
            {
                key = "LKH",
                name = "卡拉赞下层",
                minLevel = 60,
                members = 10,
            },
            {
                key = "ES",
                name = "翡翠圣殿",
                minLevel = 60,
            }
        }
    },
    {
        key = "QUEST",
        name = "任务",
        members = 5,
        children = {

        }
    },
    {
        key = "BOSS",
        name = "世界首领",
        members = 40,
        children = {

        }
    },
    {
        key = "PVP",
        name = "PvP",
        children = {
            {
                key = "AV",
                name = "奥特兰克山谷",
                minLevel = 51,
                members = 40,
            },
            {
                key = "WSG",
                name = "战歌峡谷",
                minLevel = 10,
                members = 10,
            },
            {
                key = "AB",
                name = "阿拉希盆地",
                minLevel = 20,
                members = 15,
            },
            {
                key = "BR",
                name = "血环竞技场",
                minLevel = 11,
                members = 3
            },
            {
                key = "PVP",
                name = "野外PvP",
                minLevel = 1,
                members = 40
            },
        }
    },
    {
        key = "OTHER",
        name = "其他",
        members = 40,
        children = {}
    }
}

local CategoryParentMap = {}
for _, value in ipairs(Meeting.Categories) do
    for _, child in ipairs(value.children) do
        CategoryParentMap[child.key] = { key = value.key, members = value.members }
    end
end

function Meeting.GetCategoryParent(category)
    return CategoryParentMap[category]
end

function Meeting.GetActivityMaxMembers(category)
    local info = Meeting.FindCaregoryByCode(category)
    if info and info.members then
        return info.members
    end

    local parent = Meeting.GetCategoryParent(category)
    if parent then
        return parent.members
    end

    return 40
end

function Meeting.FindCaregoryByCode(code)
    for _, value in pairs(Meeting.Categories) do
        for _, value in pairs(value.children) do
            if value.key == code then
                return value
            end
        end
    end
end

function Meeting:GetMembers()
    local partyCount = GetNumPartyMembers()
    local raidCount = GetNumRaidMembers()
    if raidCount > 0 then
        return raidCount + 1
    else
        return partyCount + 1
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

function Meeting:FindJoinedActivity()
    for _, item in ipairs(Meeting.activities) do
        if Meeting:IsInActivity(item.unitname) then
            return item
        end
    end
end

function Meeting.GetPlayerScore()
    if ItemSocre and ItemSocre.ScanUnit then
        local score = ItemSocre:ScanUnit("player")
        if score and score > 0 then
            return score
        end
    end
    return 0
end
