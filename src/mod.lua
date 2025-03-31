local json = require("json")
local metadata = require("src.metadata")
local settings = require("src.settings")

local mod = RegisterMod(metadata.modName, 1)

local SaveState = {}

local StageType = StageType or {
    STAGETYPE_REPENTANCE = 3,
    STAGETYPE_REPENTANCE_B = 8
}

function mod:load()
    if not mod:HasData() then
        return
    end

    SaveState = json.decode(mod:LoadData())

    for key, value in pairs(SaveState.Settings) do
        settings[key] = value
    end
end

function mod:save()
    SaveState.Settings = {}

    for key, value in pairs(settings) do
        SaveState.Settings[key] = value
    end

    mod:SaveData(json.encode(SaveState))
end

function mod:remind(text)
    self.displayMessage = text
    self.renderText = true
end

function mod:init()
    mod:load()

    self.font = Font()
    self.font:Load("font/terminus.fnt")

    self.displayMessage = ""
    self.renderText = false

    mod:checkConditions()
end

function mod:checkConditions()
    if not settings.enabled then
        return
    end

    local level = Game():GetLevel()
    local stage_type = level:GetStageType()
    local stage = level:GetStage()

    self.renderText = false

    if stage_type == StageType.STAGETYPE_REPENTANCE or stage_type == StageType.STAGETYPE_REPENTANCE_B then
        if stage == LevelStage.STAGE1_2 and not Isaac.GetPlayer(0):HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1) then
            mod:remind("Knife Piece 1?")
        elseif stage == LevelStage.STAGE2_2 and Isaac.GetPlayer(0):HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1)
            and not Isaac.GetPlayer(0):HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_2) then
            mod:remind("Knife Piece 2?")
        end
    end
end

function mod:spawnCleanAward()
    if not settings.enabled then
        return
    end

    local level = Game():GetLevel()
    local stage = level:GetStage()
    local stage_type = level:GetStageType()
    local room = Game():GetRoom()

    if room:GetType() == RoomType.ROOM_BOSS and room:IsClear() then
        if stage == LevelStage.STAGE2_2 and
            (stage_type == StageType.STAGETYPE_REPENTANCE or stage_type == StageType.STAGETYPE_REPENTANCE_B) and
            Isaac.GetPlayer(0):HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1) and
            Isaac.GetPlayer(0):HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_2) then
            mod:remind("Go to Mausoleum!")
        end
    end
end

function mod:postRender()
    if not settings.enabled or not self.renderText then
        return
    end

    local x = (Isaac.GetScreenWidth() / 2) + settings.xOffset
    local y = 50 + settings.yOffset
    local textWidth = self.font:GetStringWidth(self.displayMessage) * (settings.scale / 100)
    local alpha = settings.transparency / 255

    self.font:DrawStringScaled(
        self.displayMessage, x - textWidth / 2, y,
        settings.scale / 100,
        settings.scale / 100,
        KColor(1, 1, 1, alpha),
        0,
        true
    )
end

return mod
