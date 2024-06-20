BINDING_HEADER_CS_MEETING_HEADER = "集合石"
BINDING_NAME_CS_MEETING_NAME = "显示/隐藏"

MEETING_DB = {}

local _, class = UnitClass("player")

Meeting = {
    VERSION = {
        MAJOR = 0,
        MINOR = 11,
        PATCH = 3
    },

    player = UnitName("player"),

    playerClass = class,

    APPLICANT_STATUS = { None = 1, Invited = 2, Declined = 3, Joined = 4 },

    createInfo = {},

    searchInfo = {},

    activities = {},

    playerIsHC = false,

    channel = "LFT",

    isAFK = false,

    members = {},

    blockWords = {
        '加速器',
        '淘宝',
        '代充',
        '代练'
    }
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
    if not rgb then
        rgb = { r = 0.6, g = 0.6, b = 0.6 }
    end
    return rgb
end

Meeting.Categories = {
    {
        key = "DUNGENO",
        name = "Dungeons",
        members = 5,
        children = {
            {
                key = "RFC",
                name = "Ragefire Chasm",
                minLevel = 13,
                match = { "rfc", "Ragefire" }
            },
            {
                key = "WC",
                name = "Wailing Caverns",
                minLevel = 17,
                match = { "wc", "Wailing Caverns" }
            },
            {
                key = "DM",
                name = "The Dead Mines",
                minLevel = 17,
                match = { "DM", "Dead Mines" }
            },
            {
                key = "SFK",
                name = "Shadowfang Keep",
                minLevel = 22,
                match = { "SFK", "Shadowfang" }
            },
            {
                key = "STOCKS",
                name = "The Stockades",
                minLevel = 22,
                match = { "stockades", "stocks" }
            },
            {
                key = "BFD",
                name = "Blackfathom Deeps",
                minLevel = 23,
                match = { "bfd", "Blackfathom" }
            },
            {
                key = "SMGY",
                name = "Scarlet Monastery: Graveyard",
                minLevel = 27,
                match = { "smgy", "sm gy", "sm Graveyard", "Graveyard" }
            },
            {
                key = "SMLIB",
                name = "Scarlet Monastery: Library",
                minLevel = 28,
                match = { "smlib", "sm library", "Library" }
            },
            {
                key = "GNOMER",
                name = "Gnomeregan",
                minLevel = 29,
                match = {"gnomer", "Gnomeregan"}
            },
            {
                key = "RFK",
                name = "Razorfen Kraul",
                minLevel = 29,
                match = { "rfk", "kraul" }
            },
            {
                key = "TCG",
                name = "The Crescent Grove",
                minLevel = 32,
                match = { "Crescent Grove" }
            },
            {
                key = "SMARMORY",
                name = "Scarlet Monastery: Armory",
                minLevel = 32,
                match = { "smarmory", "sm armory", "Armory" }
            },
            {
                key = "SMCATH",
                name = "Scarlet Monastery: Cathedral",
                minLevel = 35,
                match = { "smcath", "sm cath", "Cathedral" }
            },
            {
                key = "RFD",
                name = "Razorfen Downs",
                minLevel = 36,
                match = { "rfd", "Razorfen Downs" }
            },
            {
                key = "ULDA",
                name = "Uldaman",
                minLevel = 40,
                match = { "Uldaman" }
            },
            {
                key = "GILNEAS",
                name = "Gilneas City",
                minLevel = 42,
                match = {"Gilneas City"}
            },
            {
                key = "ZF",
                name = "Zul'Farrak",
                minLevel = 44,
                match = { "zf", "zul" }
            },
            {
                key = "MARA",
                name = "Maraudon",
                minLevel = 45,
                match = { "Mara", "Maraudon" }
            },
            {
                key = "ST",
                name = "The Sunken Temple",
                minLevel = 50,
                match = { "sunken temple", " st " }
            },
            {
                key = "HFQ",
                name = "Hateforge Quarry",
                minLevel = 50,
                match = { "HFQ", "Hateforge" }
            },
            {
                key = "BRD",
                name = "Blackrock Depths",
                minLevel = 52,
                match = {"brd"}
            },
            {
                key = "UBRS",
                name = "Upper Blackrock Spire",
                minLevel = 55,
                members = 10,
                match = { "UBRS" }
            },
            {
                key = "LBRS",
                name = "Lower Blackrock Spire",
                minLevel = 55,
                match = { "LBRS" }

            },
            {
                key = "DME",
                name = "Dire Maul: East",
                minLevel = 55,
                match = { "DME", "DM:E", "DM East", "DMEast", "DM:East" }
            },
            {
                key = "DMN",
                name = "Dire Maul: North",
                minLevel = 57,
                match = { "DMN", "DM:N", "DM North", "DMNorth", "DM:North", "tribute" }
            },
            {
                key = "DMW",
                name = "Dire Maul: West",
                minLevel = 57,
                match = { "DMW", "DM:W", "DM West", "DMWwest", "DM:West" }
            },
            {
                key = "SCHOLO",
                name = "Scholomance",
                minLevel = 58,
                members = 10,
                match = { "scholo", "Scholomance" }
            },
            {
                key = "STRAT",
                name = "Stratholme",
                minLevel = 58,
                members = 10,
                match = { "strat", "Stratholme" }
            },
            {
                key = "KC",
                name = "Karazhan Crypt",
                minLevel = 58,
                match = { "crypts" }
            },
            {
                key = "COTBM",
                name = "Caverns of Time: Black Morass",
                minLevel = 60,
                match = { "CoT", "BM" }
            },
            {
                key = "SWV",
                name = "Stormwind Vault",
                minLevel = 60,
                match = { "SWV", "Stormwind Vault" }
            },
        }
    },
    {
        key = "RAID",
        name = "Raids",
        members = 40,
        children = {
            {
                key = "MC",
                name = "Molten Core",
                minLevel = 60,
                match = { "mc" }
            },
            {
                key = "ONY",
                name = "Onyxia's Lair",
                minLevel = 60,
                match = { "ony", "onyxia" }
            },
            {
                key = "BWL",
                name = "Blackwing Lair",
                minLevel = 60,
                match = { "bwl" }
            },
            {
                key = "AQ40",
                name = "Temple of Ahn'Qiraj",
                minLevel = 60,
                match = { "AQ40" }
            },
            {
                key = "NAXX",
                name = "Naxxramas",
                minLevel = 60,
                match = { "naxx" }
            },
            {
                key = "ZUG",
                name = "Zul'Gurub",
                minLevel = 60,
                members = 20,
                match = { "zg" }
            },
            {
                key = "AQ20",
                name = "Ruins of Ahn'Qiraj",
                minLevel = 60,
                members = 20,
                match = { "aq20" }
            },
            {
                key = "LKH",
                name = "Lower Karazhan  Halls",
                minLevel = 60,
                members = 10,
                match = { "kara", "kara10", "lkh" }
            },
            {
                key = "ES",
                name = "Emerald Sanctum",
                minLevel = 60,
                match = { "ES", "Emerald Sanctum" }
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
                name = "Alterac Valley",
                minLevel = 51,
                members = 40,
            },
            {
                key = "WSG",
                name = "Warsong Gulch",
                minLevel = 10,
                members = 10,
            },
            {
                key = "AB",
                name = "Arathi Basin",
                minLevel = 20,
                members = 15,
            },
            {
                key = "BR",
                name = "Blood Ring",
                minLevel = 11,
                members = 3
            },
            {
                key = "PVP",
                name = "Open World PvP",
                minLevel = 1,
                members = 40
            },
        }
    },
    {
        key = "OTHER",
        name = "Other",
        members = 40,
        children = {
            {
                key = "QUEST",
                name = "Quest",
                minLevel = 1,
            },
            {
                key = "OTHER",
                name = "Other",
                minLevel = 1,
            },
        }
    },
    {
        key = "CHAT",
        name = "Channels",
        members = 40,
        hide = true,
        children = {
            {
                key = "WORLD",
                name = "/World",
                minLevel = 1,
            },
            {
                key = "CHINA",
                name = "/China",
                minLevel = 1,
            },
            {
                key = "HARDCORE",
                name = "/Hardcore",
                minLevel = 1,
            },
        }
    }
}

local activityCategoryMap = {}

for _, value in ipairs(Meeting.Categories) do
    for _, child in ipairs(value.children) do
        activityCategoryMap[child.key] = { key = value.key, members = value.members }
    end
end

function Meeting.GetActivityCategory(code)
    return activityCategoryMap[code]
end

function Meeting.GetActivityMaxMembers(code)
    local info = Meeting.GetActivityInfo(code)
    if info and info.members then
        return info.members
    end

    local category = Meeting.GetActivityCategory(code)
    if category then
        return category.members
    end

    return 40
end

local activityInfoMap = {}

function Meeting.GetActivityInfo(code)
    if activityInfoMap[code] then
        return activityInfoMap[code]
    end
    for _, value in pairs(Meeting.Categories) do
        for _, value in pairs(value.children) do
            if value.key == code then
                activityInfoMap[code] = value
                return value
            end
        end
    end
    local other = Meeting.GetActivityInfo("OTHER")
    activityInfoMap[code] = other
    return other
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
        if num ~= nil and num > 0 then
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
