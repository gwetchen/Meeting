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

    channel = "LFT",
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

local classChineseNameMap = {
    [1] = "术士",
    [2] = "猎人",
    [3] = "牧师",
    [4] = "圣骑士",
    [5] = "法师",
    [6] = "盗贼",
    [7] = "德鲁伊",
    [8] = "萨满",
    [9] = "战士",
}

function Meeting.NumberToClass(n)
    return classNameMap[n]
end

function Meeting.ClassToNumber(class)
    return classNumberMap[class]
end

function Meeting.GetClassRGBColor(class, unitname)
    local rgb = RAID_CLASS_COLORS[class]
    if not class or not rgb then
        if SCCN_storage then
            local cache = SCCN_storage[unitname]
            if cache then
                return Meeting.GetClassRGBColor(Meeting.NumberToClass(cache.c))
            end
        end
        rgb = RAID_CLASS_COLORS[nil]
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
                match = { "怒焰" }
            },
            {
                key = "WC",
                name = "哀嚎洞穴",
                minLevel = 17,
                match = { "哀嚎" }
            },
            {
                key = "DM",
                name = "死亡矿井",
                minLevel = 17,
                match = { "死矿" }
            },
            {
                key = "SFK",
                name = "影牙城堡",
                minLevel = 22,
                match = { "影牙" }
            },
            {
                key = "STOCKS",
                name = "暴风城：监狱",
                minLevel = 22,
                match = { "监狱" }
            },
            {
                key = "BFD",
                name = "黑暗深渊",
                minLevel = 23,
                match = { "黑暗深渊" }
            },
            {
                key = "SMGY",
                name = "血色修道院墓地",
                minLevel = 27,
                match = { "血色" }
            },
            {
                key = "SMLIB",
                name = "血色修道院图书馆",
                minLevel = 28,
                match = { "血色" }
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
                match = { "剃刀" }
            },
            {
                key = "TCG",
                name = "新月林地",
                minLevel = 32,
            },
            {
                key = "SMARMORY",
                name = "血色修道院军械库",
                minLevel = 32,
                match = { "血色" }
            },
            {
                key = "SMCATH",
                name = "血色修道院大教堂",
                minLevel = 35,
                match = { "血色" }
            },
            {
                key = "RFD",
                name = "剃刀高地",
                minLevel = 36,
                match = { "剃刀" }
            },
            {
                key = "ULDA",
                name = "奥达曼",
                minLevel = 40,
                match = { "奥达曼" }
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
                match = { "祖尔", "zul" }
            },
            {
                key = "MARA",
                name = "玛拉顿",
                minLevel = 45,
                match = { "玛拉顿" }
            },
            {
                key = "ST",
                name = "阿塔哈卡神庙",
                minLevel = 50,
                match = { "神庙" }
            },
            {
                key = "HFQ",
                name = "仇恨熔炉采石场",
                minLevel = 50,
                match = { "采石场" }
            },
            {
                key = "BRD",
                name = "黑石深渊",
                minLevel = 52,
            },
            {
                key = "UBRS",
                name = "黑石塔上层",
                minLevel = 55,
                members = 10,
                match = { "黑上" }
            },
            {
                key = "LBRS",
                name = "黑石塔下层",
                minLevel = 55,
                match = { "黑下" }

            },
            {
                key = "DME",
                name = "厄运之槌：东",
                minLevel = 55,
                match = { "厄运东" }
            },
            {
                key = "DMN",
                name = "厄运之槌：北",
                minLevel = 57,
                match = { "厄运北" }
            },
            {
                key = "DMW",
                name = "厄运之槌：西",
                minLevel = 57,
                match = { "厄运西" }
            },
            {
                key = "SCHOLO",
                name = "通灵学院",
                minLevel = 58,
                members = 10,
                match = { "通灵", "tl" }
            },
            {
                key = "STRAT",
                name = "斯坦索姆",
                minLevel = 58,
                members = 10,
                match = { "stsm" }
            },
            {
                key = "KC",
                name = "卡拉赞地穴",
                minLevel = 58,
                match = { "卡拉赞", "klz" }
            },
            {
                key = "COTBM",
                name = "时间之穴：黑色沼泽",
                minLevel = 60,
                match = { "时光", "沼泽" }
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
                match = { "mc" }
            },
            {
                key = "ONY",
                name = "奥妮克希亚的巢穴",
                minLevel = 60,
                match = { "黑龙" }
            },
            {
                key = "BWL",
                name = "黑翼之巢",
                minLevel = 60,
                match = { "黑翼", "bwl" }
            },
            {
                key = "AQ40",
                name = "安其拉神殿",
                minLevel = 60,
                match = { "安其拉", "taq" }
            },
            {
                key = "NAXX",
                name = "纳克萨玛斯",
                minLevel = 60,
                match = { "naxx" }
            },
            {
                key = "ZUG",
                name = "祖尔格拉布",
                minLevel = 60,
                members = 20,
                match = { "祖格", "zug", "zg", "龙虎金" }
            },
            {
                key = "AQ20",
                name = "安其拉废墟",
                minLevel = 60,
                members = 20,
                match = { "废墟", "fx" }
            },
            {
                key = "LKH",
                name = "卡拉赞下层",
                minLevel = 60,
                members = 10,
                match = { "卡拉赞", "klz" }
            },
            {
                key = "ES",
                name = "翡翠圣殿",
                minLevel = 60,
                match = { "翡翠" }
            }
        }
    },
    -- {
    --     key = "QUEST",
    --     name = "任务",
    --     members = 5,
    --     children = {

    --     }
    -- },
    -- {
    --     key = "BOSS",
    --     name = "世界首领",
    --     members = 40,
    --     children = {

    --     }
    -- },
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
        name = "其它",
        members = 40,
        children = {
            {
                key = "QUEST",
                name = "任务",
                minLevel = 1,
            },
            {
                key = "OTHER",
                name = "其它",
                minLevel = 1,
            },
        }
    },
    {
        key = "CHAT",
        name = "频道",
        members = 40,
        hide = true,
        children = {
            {
                key = "WORLD",
                name = "世界频道",
                minLevel = 1,
            },
        }
    }
}

local categoryParentMap = {}
for _, value in ipairs(Meeting.Categories) do
    for _, child in ipairs(value.children) do
        categoryParentMap[child.key] = { key = value.key, members = value.members }
    end
end

function Meeting.GetCategoryParent(category)
    return categoryParentMap[category]
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

local categoryMap = {}

function Meeting.FindCaregoryByCode(code)
    if categoryMap[code] then
        return categoryMap[code]
    end
    for _, value in pairs(Meeting.Categories) do
        for _, value in pairs(value.children) do
            if value.key == code then
                categoryMap[code] = value
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

local Role = {
    Tank = bit.lshift(1, 1),
    Healer = bit.lshift(1, 2),
    Damage = bit.lshift(1, 3)
}
Meeting.Role = Role

local classRoleMap = {
    ["WARLOCK"] = Role.Damage,
    ["HUNTER"] = Role.Damage,
    ["PRIEST"] = bit.bor(Role.Healer, Role.Damage),
    ["PALADIN"] = bit.bor(Role.Tank, Role.Healer, Role.Damage),
    ["MAGE"] = Role.Damage,
    ["ROGUE"] = Role.Damage,
    ["DRUID"] = bit.bor(Role.Tank, Role.Healer, Role.Damage),
    ["SHAMAN"] = bit.bor(Role.Healer, Role.Damage),
    ["WARRIOR"] = bit.bor(Role.Tank, Role.Damage),
}

function Meeting.GetClassRole(class)
    return classRoleMap[class]
end

local fortyone = { "0",
    "1", "2", "3", "4", "5",
    "6", "7", "8", "9", "a",
    "b", "c", "d", "e", "f",
    "g", "h", "i", "j", "k",
    "l", "m", "n", "o", "p",
    "q", "r", "s", "t", "u",
    "v", "w", "x", "y", "z",
    "A", "B", "C", "D", "E" }
local fortyoneIndexes = {}
for index, value in ipairs(fortyone) do
    fortyoneIndexes[value] = index - 1
end

function Meeting.EncodeGroupClass()
    local raid = false
    local arr = {}
    for _, value in ipairs(classNameMap) do
        if value == Meeting.playerClass then
            arr[value] = 1
        else
            arr[value] = 0
        end
    end

    for i = 1, GetNumRaidMembers() do
        raid = true
        local _, class = UnitClass("raid" .. i)
        arr[class] = arr[class] + 1
    end

    if not raid then
        for i = 1, GetNumPartyMembers() do
            local _, class = UnitClass("party" .. i)
            arr[class] = arr[class] + 1
        end
    end

    local result = ""
    for _, v in ipairs(classNameMap) do
        local num = arr[v]
        result = result .. fortyone[num + 1]
    end
    return result
end

function Meeting.DecodeGroupClass(str)
    if not str then
        return
    end
    local arr = {}
    for i = 1, string.len(str) do
        local c = string.sub(str, i, i)
        local num = fortyoneIndexes[c]
        if num > 0 then
            arr[i] = num
        end
    end
    return arr
end

local colorCache = {}

function Meeting.GetClassLocaleName(i)
    if colorCache[i] then
        return colorCache[i]
    end
    local color = Meeting.GetClassRGBColor(Meeting.NumberToClass(i))
    local str = string.format("|cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, classChineseNameMap
        [i])
    colorCache[i] = str
    return str
end
