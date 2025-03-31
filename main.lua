local ModName = "KnifePieceReminder"
local mod = RegisterMod(ModName, 1)

local game = Game()
local font = Font()
font:Load("font/terminus.fnt")

local StageType = StageType or {
    STAGETYPE_REPENTANCE = 3,
    STAGETYPE_REPENTANCE_B = 8
}

local displayMessage = ""
local render_text = false
local spawnRoomIndex = nil
local reminderTriggered = false

local settings = {
    enabled = true,
    xOffset = 0,
    yOffset = 0,
    scale = 100,
    transparency = 255
}

function mod:LoadData()
    if mod:HasData() then
        local success, data = pcall(json.decode, mod:LoadData())
        if success and type(data) == "table" then
            for key, value in pairs(data) do
                settings[key] = value
            end
        end
    end
end

function mod:SaveData()
    local success, encoded = pcall(json.encode, settings)
    if success then
        Isaac.SaveModData(mod, encoded) -- FIXED: Now correctly saves data
    end
end

local function remind(text)
    displayMessage = text
    render_text = true
end

local function check_conditions()
    if not settings.enabled then return end -- Prevent reminders if disabled
    
    local level = game:GetLevel()
    local stage_type = level:GetStageType()
    local stage = level:GetStage()
    
    local room = game:GetRoom()
    spawnRoomIndex = room:GetSpawnSeed()
    render_text = false

    if stage_type == StageType.STAGETYPE_REPENTANCE or stage_type == StageType.STAGETYPE_REPENTANCE_B then
        if stage == LevelStage.STAGE1_2 and not Isaac.GetPlayer(0):HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1) then
            remind("Knife Piece 1?")
        elseif stage == LevelStage.STAGE2_2 and Isaac.GetPlayer(0):HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1) and not Isaac.GetPlayer(0):HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_2) then
            remind("Knife Piece 2?")
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
    check_conditions()
    reminderTriggered = false -- Reset when entering a new level
    mod:SaveData()
end)

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function()
    if not settings.enabled then return end -- Prevent rendering if disabled

    local level = game:GetLevel()
    local stage = level:GetStage()
    local stage_type = level:GetStageType()
    local room = game:GetRoom()

    if room:GetType() == RoomType.ROOM_BOSS and room:IsClear() then
        if stage == LevelStage.STAGE2_2 and 
           (stage_type == StageType.STAGETYPE_REPENTANCE or stage_type == StageType.STAGETYPE_REPENTANCE_B) and 
           Isaac.GetPlayer(0):HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1) and 
           Isaac.GetPlayer(0):HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_2) then
            remind("Go to Mausoleum!")
        end
    end
end)


mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if settings.enabled and render_text then
        local x = (Isaac.GetScreenWidth() / 2) + settings.xOffset
        local y = 50 + settings.yOffset
        local textWidth = font:GetStringWidth(displayMessage) * (settings.scale / 100)
        local alpha = settings.transparency / 255
        font:DrawStringScaled(displayMessage, x - textWidth / 2, y, settings.scale / 100, settings.scale / 100, KColor(1, 1, 1, alpha), 0, true)
    end
end)

-- Mod Config Menu Setup
if ModConfigMenu then
    ModConfigMenu.UpdateCategory("Knife Piece Reminder", {
        Name = "Knife Piece Reminder",
        Info = "Customize Knife Piece Reminder settings"
    })

    ModConfigMenu.AddSetting("Knife Piece Reminder", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return settings.enabled end,
        Display = function() return "Enabled: " .. (settings.enabled and "Yes" or "No") end,
        OnChange = function(b) settings.enabled = b; mod:SaveData() end
    })

    ModConfigMenu.AddSetting("Knife Piece Reminder", {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function() return settings.xOffset end,
        Display = function() return "X Offset: " .. settings.xOffset end,
        OnChange = function(i) settings.xOffset = i; mod:SaveData() end
    })

    ModConfigMenu.AddSetting("Knife Piece Reminder", {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function() return settings.yOffset end,
        Display = function() return "Y Offset: " .. settings.yOffset end,
        OnChange = function(i) settings.yOffset = i; mod:SaveData() end
    })

    ModConfigMenu.AddSetting("Knife Piece Reminder", {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function() return settings.scale end,
        Minimum = 50,
        Maximum = 200,
        Display = function() return "Scale: " .. settings.scale .. "%" end,
        OnChange = function(i) settings.scale = i; mod:SaveData() end
    })

    ModConfigMenu.AddSetting("Knife Piece Reminder", {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function() return settings.transparency end,
        Minimum = 0,
        Maximum = 255,
        Display = function() return "Transparency: " .. math.floor((settings.transparency / 255) * 100) .. "%" end,
        OnChange = function(i) settings.transparency = i; mod:SaveData() end
    })
end