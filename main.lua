local mod = require('src.mod')
local settings = require('src.settings')

settings:load(mod)

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.init);
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.save)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.checkConditions)
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.spawnCleanAward)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.postRender)
