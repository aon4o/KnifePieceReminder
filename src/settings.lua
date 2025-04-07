local metadata = require("src.metadata")

local settings = {
    enabled = true,
    xOffset = 0,
    yOffset = 0,
    scale = 100,
    transparency = 255
}

function settings:load()
    if ModConfigMenu == nil then
        return
    end

    local menu = ModConfigMenu

    menu.RemoveCategory(metadata.displayName)

    menu.UpdateCategory(metadata.displayName, {
        Name = metadata.displayName,
        Info = "Customize Knife Piece Reminder settings"
    })

    menu.AddSetting(metadata.displayName, {
        Type = menu.OptionType.BOOLEAN,
        CurrentSetting = function() return settings.enabled end,
        Display = function() return "Enabled: " .. (settings.enabled and "Yes" or "No") end,
        OnChange = function(b)
            settings.enabled = b;
        end
    })

    menu.AddSetting(metadata.displayName, {
        Type = menu.OptionType.NUMBER,
        CurrentSetting = function() return settings.xOffset end,
        Display = function() return "X Offset: " .. settings.xOffset end,
        OnChange = function(i)
            settings.xOffset = i;
        end
    })

    menu.AddSetting(metadata.displayName, {
        Type = menu.OptionType.NUMBER,
        CurrentSetting = function() return settings.yOffset end,
        Display = function() return "Y Offset: " .. settings.yOffset end,
        OnChange = function(i)
            settings.yOffset = i;
        end
    })

    menu.AddSetting(metadata.displayName, {
        Type = menu.OptionType.NUMBER,
        CurrentSetting = function() return settings.scale end,
        Minimum = 50,
        Maximum = 200,
        Display = function() return "Scale: " .. settings.scale .. "%" end,
        OnChange = function(i)
            settings.scale = i;
        end
    })

    menu.AddSetting(metadata.displayName, {
        Type = menu.OptionType.NUMBER,
        CurrentSetting = function() return settings.transparency end,
        Minimum = 0,
        Maximum = 255,
        Display = function() return "Transparency: " .. math.floor((settings.transparency / 255) * 100) .. "%" end,
        OnChange = function(i)
            settings.transparency = i;
        end
    })
end

return settings
