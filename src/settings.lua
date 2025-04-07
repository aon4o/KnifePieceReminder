local metadata = require("src.metadata")
local FONTS = require("src.enums.fonts")

local settings = {
    enabled = true,
    xOffset = 330,
    yOffset = 10,
    scale = 100,
    textOpacity = 1,
    font = FONTS[1],
}

local function getTableIndex(table, searchValue)
    for key, value in ipairs(table) do
        if value == searchValue then
            return key
        end
    end

    return 0
end

function settings:getScale()
    return settings.scale / 100
end

function settings:getHudOffset()
    local hudOffsetScale = Vector(2, 1.2)

    return hudOffsetScale * Options.HUDOffset * 10
end

function settings:load(mod)
    if ModConfigMenu == nil then
        return
    end

    local menu = ModConfigMenu

    local categoryName = metadata.modName
    local sectionAbout = "About"
    local sectionSettings = "Settings"

    menu.RemoveCategory(categoryName)

    menu.UpdateCategory(categoryName, {
        Name = categoryName,
        Info = "Settings for the " .. categoryName .. " mod."
    })

    menu.UpdateSubcategory(categoryName, sectionAbout, {
        Name = sectionAbout,
        Info = "Information about the " .. categoryName .. " mod."
    })

    menu.AddTitle(categoryName, sectionAbout, categoryName)
    menu.AddSpace(categoryName, sectionAbout)
    menu.AddText(categoryName, sectionAbout, "Version: " .. metadata.version)
    menu.AddSpace(categoryName, sectionAbout)
    menu.AddText(categoryName, sectionAbout, "Made with Love <3 by: " .. metadata.author)

    menu.UpdateSubcategory(categoryName, sectionSettings, {
        Name = sectionSettings,
        Info = "Settings for the " .. categoryName .. " mod."
    })

    menu.AddSetting(categoryName, sectionSettings, {
        Type = menu.OptionType.BOOLEAN,
        CurrentSetting = function() return settings.enabled end,
        Display = function() return "Enabled: " .. (settings.enabled and "Yes" or "No") end,
        OnChange = function(value)
            settings.enabled = value;
        end,
        Info = { "Wether the reminders are enabled or not." }
    })

    menu.AddSetting(categoryName, sectionSettings, {
        Type = menu.OptionType.NUMBER,
        CurrentSetting = function() return settings.xOffset / 5 end,
        Minimum = 0,
        Maximum = 100, -- actually 500
        Display = function() return "X Offset: " .. settings.xOffset end,
        OnChange = function(value)
            settings.xOffset = value * 5;
        end,
        Info = { "The offset of the counter from left to right. Default: 330" }
    })

    menu.AddSetting(categoryName, sectionSettings, {
        Type = menu.OptionType.NUMBER,
        CurrentSetting = function() return settings.yOffset / 5 end,
        Minimum = 0,
        Maximum = 60, -- actually 300
        Display = function() return "Y Offset: " .. settings.yOffset end,
        OnChange = function(value)
            settings.yOffset = value * 5;
        end,
        Info = { "The offset of the counter from top to bottom. Default: 10" }
    })

    menu.AddSetting(categoryName, sectionSettings, {
        Type = menu.OptionType.NUMBER,
        CurrentSetting = function() return settings.scale / 5 end,
        Minimum = 1,
        Maximum = 300,
        Display = function() return "Scale: " .. settings.scale .. "%" end,
        OnChange = function(value)
            settings.scale = value * 5;
        end,
        Info = { "The small or big the text will be rendered. Default: 100%" }
    })

    menu.AddSetting(categoryName, sectionSettings, {
        Type = menu.OptionType.SCROLL,
        CurrentSetting = function()
            return settings.textOpacity * 10
        end,
        Display = function()
            return "Text Opacity: $scroll" .. math.tointeger(settings.textOpacity * 10)
        end,
        OnChange = function(value)
            settings.textOpacity = value / 10
            mod:reloadTextSettings()
        end,
        Info = { "How transperent the text is. Default: 1.0" }
    })

    menu.AddSetting(categoryName, sectionSettings, {
        Type = menu.OptionType.NUMBER,
        CurrentSetting = function()
            return getTableIndex(FONTS, settings.font)
        end,
        Minimum = 1,
        Maximum = #FONTS,
        Display = function()
            return "Font: " .. settings.font
        end,
        OnChange = function(index)
            settings.font = FONTS[index]
            mod:reloadTextSettings()
        end,
        Info = { "The font that will be used for rendering the text." }
    })
end

return settings
