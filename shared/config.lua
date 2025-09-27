Config = {}

Config.PrimaryColor = 'green' -- Default if left none its grape
Config.language = 'en' -- Default language.
Config.UseItem = true -- Use item to open quest menu.
Config.RefreshTime = 0.1 -- Time in hours to refresh quests. 1 = 1 hour.
Config.XpToStart = 500 -- XP required to reach level 2.
Config.XPmultiplier = 1.1 -- Multiplier for XP gain.
Config.RewardMultiplierPerLevel = 1.05 -- Multiplier for money reward per level.

Config.MaxQuest = 3 -- Set the max quest that can be on. number | false (if set to false it will go all and only put them on if chance)
Config.Quests = {{
    name = "The First Water", -- Name of the quest.
    reward = 5000, -- Money reward.
    xp = 750, -- XP reward.
    claimed = false, -- If the quest is claimed or not.
    items = {{ -- MAX 6 items
        name = "water",
        count = 5
    }},
    chance = 100 -- 100% chance of quest getting put on
}, {
    name = "Magnus lost Items",
    reward = 5000,
    xp = 750,
    claimed = false,
    items = {{
        name = "panties",
        count = 2
    }, {
        name = "burger",
        count = 1
    }},
    chance = 100
}, {
    name = "Taco's lost Items",
    reward = 5000,
    xp = 750,
    claimed = false,
    items = {{
        name = "panties",
        count = 5
    }, {
        name = "burger",
        count = 2
    }},
    chance = 100
}, {
    name = "Tacos Secret",
    reward = 50000,
    xp = 250,
    claimed = false,
    items = {}, -- No items needed for completion
    chance = 100 -- 20% chance of quest getting put on
}, {
    name = "Who stole my car",
    reward = 5,
    xp = 6000,
    claimed = false,
    items = {}, -- No items needed for completion
    chance = 5 -- 5% chance of quest getting put on
}}
