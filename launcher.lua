--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║                    ULTIM-MENU LAUNCHER v1.0                  ║
    ║         Advanced Menu System with Themes & Animations         ║
    ║                Created by Robanik - 2026                      ║
    ╚═══════════════════════════════════════════════════════════════╝
    
    Features:
    - Dynamic Theme System
    - Smooth Animations
    - Toggle Function Management
    - Menu Navigation & Controls
    - Persistent Settings
    - Performance Monitoring
]]

-- ============================================================================
-- CONFIGURATION & CONSTANTS
-- ============================================================================

local LAUNCHER = {
    VERSION = "1.0.0",
    AUTHOR = "Robanik",
    BUILD_DATE = "2026-01-09"
}

local CONFIG = {
    -- Menu Positioning
    MENU_X = 10,
    MENU_Y = 10,
    MENU_WIDTH = 300,
    MENU_HEIGHT = 600,
    MENU_PADDING = 15,
    ITEM_HEIGHT = 40,
    
    -- Animation Settings
    ANIMATION_SPEED = 0.1,
    TRANSITION_DURATION = 0.3,
    FADE_SPEED = 0.05,
    
    -- UI Constants
    CORNER_RADIUS = 8,
    BORDER_WIDTH = 2,
    SHADOW_OFFSET = 3,
    
    -- Timing
    DOUBLE_CLICK_TIME = 0.3,
    TOOLTIP_DELAY = 0.5,
    
    -- Input
    MENU_TOGGLE_KEY = "F5",
    NAVIGATION_UP = "UP",
    NAVIGATION_DOWN = "DOWN",
    SELECT_KEY = "RETURN",
    BACK_KEY = "ESCAPE",
}

-- ============================================================================
-- THEME SYSTEM
-- ============================================================================

local THEMES = {
    DARK = {
        name = "Dark",
        primary = {r = 25, g = 25, b = 35},
        secondary = {r = 45, g = 45, b = 60},
        accent = {r = 100, g = 180, b = 255},
        text_primary = {r = 255, g = 255, b = 255},
        text_secondary = {r = 180, g = 180, b = 180},
        background = {r = 15, g = 15, b = 20},
        success = {r = 80, g = 200, b = 120},
        warning = {r = 255, g = 180, b = 60},
        error = {r = 255, g = 100, b = 100},
        shadow = {r = 0, g = 0, b = 0, a = 0.4}
    },
    
    LIGHT = {
        name = "Light",
        primary = {r = 240, g = 240, b = 245},
        secondary = {r = 220, g = 220, b = 230},
        accent = {r = 50, g = 120, b = 200},
        text_primary = {r = 20, g = 20, b = 30},
        text_secondary = {r = 100, g = 100, b = 100},
        background = {r = 255, g = 255, b = 255},
        success = {r = 60, g = 150, b = 100},
        warning = {r = 200, g = 140, b = 40},
        error = {r = 220, g = 80, b = 80},
        shadow = {r = 0, g = 0, b = 0, a = 0.2}
    },
    
    NEON = {
        name = "Neon",
        primary = {r = 10, g = 10, b = 15},
        secondary = {r = 30, g = 30, b = 45},
        accent = {r = 0, g = 255, b = 255},
        text_primary = {r = 0, g = 255, b = 200},
        text_secondary = {r = 100, g = 200, b = 200},
        background = {r = 5, g = 5, b = 10},
        success = {r = 0, g = 255, b = 100},
        warning = {r = 255, g = 255, b = 0},
        error = {r = 255, g = 0, b = 100},
        shadow = {r = 0, g = 255, b = 255, a = 0.3}
    },
    
    CYBERPUNK = {
        name = "Cyberpunk",
        primary = {r = 20, g = 10, b = 40},
        secondary = {r = 60, g = 20, b = 80},
        accent = {r = 255, g = 20, b = 180},
        text_primary = {r = 255, g = 20, b = 180},
        text_secondary = {r = 200, g = 100, b = 150},
        background = {r = 10, g = 5, b = 20},
        success = {r = 100, g = 255, b = 100},
        warning = {r = 255, g = 150, b = 30},
        error = {r = 255, g = 30, b = 100},
        shadow = {r = 255, g = 20, b = 180, a = 0.25}
    }
}

-- ============================================================================
-- STATE MANAGEMENT
-- ============================================================================

local STATE = {
    current_theme = THEMES.DARK,
    menu_visible = false,
    menu_alpha = 0,
    selected_index = 1,
    scroll_offset = 0,
    active_page = "main",
    hovering_item = nil,
    animation_time = 0,
    last_key_time = 0,
    last_click_time = 0,
    is_animating = false,
}

-- ============================================================================
-- FUNCTION MANAGEMENT & REGISTRY
-- ============================================================================

local FUNCTION_REGISTRY = {}
local TOGGLE_STATES = {}

function RegisterFunction(id, name, category, callback, icon, description)
    if not FUNCTION_REGISTRY[category] then
        FUNCTION_REGISTRY[category] = {}
    end
    
    FUNCTION_REGISTRY[category][id] = {
        id = id,
        name = name,
        category = category,
        callback = callback,
        icon = icon or "⚙",
        description = description or "No description available",
        enabled = true,
        execution_count = 0,
        last_execution = nil,
        execution_time = 0,
    }
    
    return id
end

function RegisterToggle(id, name, category, initial_state, callback, icon)
    if not TOGGLE_STATES[id] then
        TOGGLE_STATES[id] = {
            id = id,
            name = name,
            category = category,
            enabled = initial_state or false,
            callback = callback,
            icon = icon or "◆",
            toggle_count = 0,
            first_enabled = nil,
            last_toggled = nil,
        }
    end
    
    return id
end

function ToggleFunction(id)
    if TOGGLE_STATES[id] then
        local toggle = TOGGLE_STATES[id]
        toggle.enabled = not toggle.enabled
        toggle.toggle_count = toggle.toggle_count + 1
        toggle.last_toggled = GetTimeInMs()
        
        if toggle.enabled and not toggle.first_enabled then
            toggle.first_enabled = GetTimeInMs()
        end
        
        if toggle.callback then
            toggle.callback(toggle.enabled)
        end
        
        return toggle.enabled
    end
    return false
end

function ExecuteFunction(category, id)
    if FUNCTION_REGISTRY[category] and FUNCTION_REGISTRY[category][id] then
        local func = FUNCTION_REGISTRY[category][id]
        
        if func.enabled and func.callback then
            local start_time = GetTimeInMs()
            
            local success, result = pcall(func.callback)
            
            func.execution_time = GetTimeInMs() - start_time
            func.execution_count = func.execution_count + 1
            func.last_execution = GetTimeInMs()
            
            return success, result
        end
    end
    return false, "Function not found or disabled"
end

-- ============================================================================
-- ANIMATION SYSTEM
-- ============================================================================

local ANIMATIONS = {
    active = {},
}

function CreateAnimation(duration, callback, easing_type)
    local animation = {
        duration = duration,
        elapsed = 0,
        callback = callback,
        easing = easing_type or "linear",
        active = true,
    }
    
    table.insert(ANIMATIONS.active, animation)
    return animation
end

function EaseLinear(t)
    return t
end

function EaseInQuad(t)
    return t * t
end

function EaseOutQuad(t)
    return t * (2 - t)
end

function EaseInOutQuad(t)
    return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t
end

function EaseCubicInOut(t)
    if t < 0.5 then
        return 4 * t * t * t
    else
        return (t - 1) * (2 * (t - 2)) * (2 * (t - 2)) + 1
    end
end

function ApplyEasing(easing_type, t)
    local easing_functions = {
        linear = EaseLinear,
        in_quad = EaseInQuad,
        out_quad = EaseOutQuad,
        in_out_quad = EaseInOutQuad,
        cubic_in_out = EaseCubicInOut,
    }
    
    local func = easing_functions[easing_type] or EaseLinear
    return func(math.min(1, math.max(0, t)))
end

function UpdateAnimations(delta_time)
    for i = #ANIMATIONS.active, 1, -1 do
        local anim = ANIMATIONS.active[i]
        anim.elapsed = anim.elapsed + delta_time
        
        local progress = anim.elapsed / anim.duration
        local eased_progress = ApplyEasing(anim.easing, progress)
        
        if anim.callback then
            anim.callback(eased_progress, anim.elapsed >= anim.duration)
        end
        
        if anim.elapsed >= anim.duration then
            anim.active = false
            table.remove(ANIMATIONS.active, i)
        end
    end
end

-- ============================================================================
-- MENU RENDERING UTILITIES
-- ============================================================================

local RENDER = {
    draw_calls = 0,
    last_frame_time = 0,
}

function DrawRectangle(x, y, width, height, color, alpha, rounded)
    alpha = alpha or 1.0
    
    -- Draw with rounded corners if requested
    if rounded then
        local radius = CONFIG.CORNER_RADIUS
        -- Simplified rounded rectangle (would use DrawRoundedRectangle in actual implementation)
        DrawFilledRect(x + radius, y, width - 2 * radius, height, 
                      color.r, color.g, color.b, alpha * 255)
        DrawFilledRect(x, y + radius, width, height - 2 * radius,
                      color.r, color.g, color.b, alpha * 255)
    else
        DrawFilledRect(x, y, width, height, color.r, color.g, color.b, alpha * 255)
    end
    
    RENDER.draw_calls = RENDER.draw_calls + 1
end

function DrawBorder(x, y, width, height, color, thickness, alpha)
    alpha = alpha or 1.0
    thickness = thickness or CONFIG.BORDER_WIDTH
    
    -- Top
    DrawFilledRect(x, y, width, thickness, color.r, color.g, color.b, alpha * 255)
    -- Bottom
    DrawFilledRect(x, y + height - thickness, width, thickness, color.r, color.g, color.b, alpha * 255)
    -- Left
    DrawFilledRect(x, y, thickness, height, color.r, color.g, color.b, alpha * 255)
    -- Right
    DrawFilledRect(x + width - thickness, y, thickness, height, color.r, color.g, color.b, alpha * 255)
end

function DrawShadow(x, y, width, height, alpha)
    alpha = alpha or 0.3
    local shadow = STATE.current_theme.shadow
    
    for i = CONFIG.SHADOW_OFFSET, 1, -1 do
        local fade = alpha * (1 - (i / CONFIG.SHADOW_OFFSET))
        DrawFilledRect(x + i, y + i, width, height, 
                      shadow.r, shadow.g, shadow.b, fade * 255)
    end
end

function DrawText(x, y, text, size, color, alpha, centered)
    alpha = alpha or 1.0
    centered = centered or false
    
    -- SetTextFont(4)
    -- SetTextScale(size / 10)
    -- SetTextColour(color.r, color.g, color.b, alpha * 255)
    -- if centered then SetTextCentre(true) end
    -- BeginTextCommandDisplayText("STRING")
    -- AddTextComponentString(text)
    -- EndTextCommandDisplayText(x, y)
    
    RENDER.draw_calls = RENDER.draw_calls + 1
end

function DrawIcon(x, y, icon, size, color, alpha)
    alpha = alpha or 1.0
    DrawText(x, y, icon, size, color, alpha, false)
end

-- ============================================================================
-- MENU STRUCTURE & PAGES
-- ============================================================================

local MENU_STRUCTURE = {
    main = {
        title = "ULTIM-MENU",
        description = "Advanced Menu System",
        items = {
            {type = "label", text = "Main Menu", icon = "▶"},
            {type = "button", id = "functions", text = "Functions", icon = "⚙", category = "functions"},
            {type = "button", id = "toggles", text = "Toggles", icon = "◆", category = "toggles"},
            {type = "button", id = "settings", text = "Settings", icon = "⚙", category = "settings"},
            {type = "button", id = "themes", text = "Themes", icon = "🎨", category = "themes"},
            {type = "button", id = "about", text = "About", icon = "ℹ", category = "about"},
            {type = "separator"},
        }
    },
    
    functions = {
        title = "Functions",
        description = "Manage available functions",
        items = {},
        back = "main",
    },
    
    toggles = {
        title = "Toggles",
        description = "Toggle features on/off",
        items = {},
        back = "main",
    },
    
    settings = {
        title = "Settings",
        description = "Customize menu behavior",
        items = {
            {type = "label", text = "Settings", icon = "⚙"},
            {type = "slider", id = "menu_opacity", text = "Menu Opacity", min = 0.3, max = 1.0, step = 0.1, value = 0.95},
            {type = "slider", id = "animation_speed", text = "Animation Speed", min = 0.1, max = 1.0, step = 0.1, value = 1.0},
            {type = "toggle_item", id = "show_fps", text = "Show FPS", value = false},
            {type = "toggle_item", id = "show_tooltips", text = "Show Tooltips", value = true},
            {type = "toggle_item", id = "sound_effects", text = "Sound Effects", value = true},
            {type = "separator"},
        },
        back = "main",
    },
    
    themes = {
        title = "Themes",
        description = "Select menu theme",
        items = {
            {type = "label", text = "Themes", icon = "🎨"},
            {type = "theme", id = "dark", text = "Dark", theme_key = "DARK"},
            {type = "theme", id = "light", text = "Light", theme_key = "LIGHT"},
            {type = "theme", id = "neon", text = "Neon", theme_key = "NEON"},
            {type = "theme", id = "cyberpunk", text = "Cyberpunk", theme_key = "CYBERPUNK"},
            {type = "separator"},
        },
        back = "main",
    },
    
    about = {
        title = "About",
        description = "Information about ULTIM-MENU",
        items = {
            {type = "label", text = "ULTIM-MENU v1.0.0", icon = "ℹ"},
            {type = "info", text = "Advanced Menu System"},
            {type = "info", text = "Created by Robanik"},
            {type = "info", text = "Build: 2026-01-09"},
            {type = "separator"},
            {type = "info", text = "Features:"},
            {type = "info", text = "• Dynamic Themes"},
            {type = "info", text = "• Smooth Animations"},
            {type = "info", text = "• Toggle Management"},
            {type = "info", text = "• Performance Monitoring"},
            {type = "separator"},
        },
        back = "main",
    }
}

-- ============================================================================
-- MENU BUILDING & POPULATION
-- ============================================================================

function BuildFunctionsMenu()
    MENU_STRUCTURE.functions.items = {{type = "label", text = "Functions", icon = "⚙"}}
    
    for category, functions in pairs(FUNCTION_REGISTRY) do
        table.insert(MENU_STRUCTURE.functions.items, {type = "category", text = category})
        
        for id, func in pairs(functions) do
            table.insert(MENU_STRUCTURE.functions.items, {
                type = "button",
                id = id,
                text = func.name,
                icon = func.icon,
                category = category,
                description = func.description,
                execution_count = func.execution_count,
            })
        end
    end
    
    table.insert(MENU_STRUCTURE.functions.items, {type = "separator"})
end

function BuildTogglesMenu()
    MENU_STRUCTURE.toggles.items = {{type = "label", text = "Toggles", icon = "◆"}}
    
    local categories = {}
    for id, toggle in pairs(TOGGLE_STATES) do
        if not categories[toggle.category] then
            categories[toggle.category] = {}
        end
        table.insert(categories[toggle.category], toggle)
    end
    
    for category, toggles in pairs(categories) do
        table.insert(MENU_STRUCTURE.toggles.items, {type = "category", text = category})
        
        for _, toggle in ipairs(toggles) do
            table.insert(MENU_STRUCTURE.toggles.items, {
                type = "toggle_button",
                id = toggle.id,
                text = toggle.name,
                icon = toggle.icon,
                category = toggle.category,
                enabled = toggle.enabled,
                toggle_count = toggle.toggle_count,
            })
        end
    end
    
    table.insert(MENU_STRUCTURE.toggles.items, {type = "separator"})
end

-- ============================================================================
-- MENU RENDERING
-- ============================================================================

function RenderMenuBackground()
    local theme = STATE.current_theme
    local x, y = CONFIG.MENU_X, CONFIG.MENU_Y
    local w, h = CONFIG.MENU_WIDTH, CONFIG.MENU_HEIGHT
    
    -- Shadow
    DrawShadow(x, y, w, h, 0.4)
    
    -- Main background
    DrawRectangle(x, y, w, h, theme.primary, STATE.menu_alpha, true)
    
    -- Top bar
    DrawRectangle(x, y, w, 50, theme.secondary, STATE.menu_alpha, true)
    
    -- Border
    DrawBorder(x, y, w, h, theme.accent, CONFIG.BORDER_WIDTH, STATE.menu_alpha * 0.6)
end

function RenderMenuHeader()
    local theme = STATE.current_theme
    local current_page = MENU_STRUCTURE[STATE.active_page]
    
    if not current_page then return end
    
    local x = CONFIG.MENU_X + CONFIG.MENU_PADDING
    local y = CONFIG.MENU_Y + 10
    
    -- Title
    DrawText(x, y, current_page.title, 1.5, theme.text_primary, STATE.menu_alpha)
    
    -- Close button (X)
    DrawText(CONFIG.MENU_X + CONFIG.MENU_WIDTH - 25, y, "✕", 1.2, theme.text_secondary, STATE.menu_alpha)
end

function RenderMenuItem(item, index, y_pos)
    local theme = STATE.current_theme
    local x = CONFIG.MENU_X + CONFIG.MENU_PADDING
    local w = CONFIG.MENU_WIDTH - CONFIG.MENU_PADDING * 2
    local h = CONFIG.ITEM_HEIGHT
    
    local is_selected = (index == STATE.selected_index)
    local is_hovering = (index == STATE.hovering_item)
    
    -- Item background
    if is_selected then
        DrawRectangle(x - 5, y_pos, w + 10, h, theme.accent, STATE.menu_alpha * 0.3)
    elseif is_hovering then
        DrawRectangle(x - 5, y_pos, w + 10, h, theme.accent, STATE.menu_alpha * 0.15)
    end
    
    local text_color = is_selected and theme.accent or theme.text_primary
    local text_alpha = STATE.menu_alpha * (is_hovering and 1.0 or 0.8)
    
    -- Icon
    if item.icon then
        DrawText(x, y_pos + 10, item.icon, 1.0, text_color, text_alpha)
    end
    
    -- Text
    local text_x = x + 30
    if item.type == "label" then
        DrawText(text_x, y_pos + 5, item.text, 1.3, theme.accent, text_alpha)
    elseif item.type == "separator" then
        DrawRectangle(x, y_pos + 15, w, 1, theme.secondary, STATE.menu_alpha * 0.5)
    elseif item.type == "category" then
        DrawText(text_x, y_pos + 10, item.text, 0.9, theme.text_secondary, text_alpha * 0.7)
    elseif item.type == "info" then
        DrawText(text_x, y_pos + 10, item.text, 0.85, theme.text_secondary, text_alpha * 0.8)
    elseif item.type == "toggle_button" then
        DrawText(text_x, y_pos + 10, item.text, 1.0, text_color, text_alpha)
        local status = item.enabled and "ON" or "OFF"
        local status_color = item.enabled and theme.success or theme.error
        DrawText(x + w - 50, y_pos + 10, status, 0.9, status_color, text_alpha)
    elseif item.type == "theme" then
        DrawText(text_x, y_pos + 10, item.text, 1.0, text_color, text_alpha)
        if STATE.current_theme.name == item.text then
            DrawText(x + w - 30, y_pos + 10, "✓", 1.0, theme.success, text_alpha)
        end
    else
        DrawText(text_x, y_pos + 10, item.text, 1.0, text_color, text_alpha)
    end
end

function RenderMenu()
    if STATE.menu_alpha <= 0 then return end
    
    RENDER.draw_calls = 0
    
    RenderMenuBackground()
    RenderMenuHeader()
    
    local current_page = MENU_STRUCTURE[STATE.active_page]
    if not current_page then return end
    
    local y = CONFIG.MENU_Y + 60
    local visible_items = 0
    local item_index = 1
    
    for i, item in ipairs(current_page.items) do
        if item.type == "separator" then
            y = y + 10
        else
            if visible_items < 12 and visible_items >= STATE.scroll_offset then
                RenderMenuItem(item, i, y)
                y = y + CONFIG.ITEM_HEIGHT
            end
            visible_items = visible_items + 1
            item_index = i
        end
    end
    
    -- Render scroll indicator
    if visible_items > 12 then
        local scroll_bar_x = CONFIG.MENU_X + CONFIG.MENU_WIDTH - 5
        local scroll_bar_y = CONFIG.MENU_Y + 60
        local scroll_bar_h = CONFIG.MENU_HEIGHT - 80
        local progress = STATE.scroll_offset / (visible_items - 12)
        
        DrawRectangle(scroll_bar_x - 2, scroll_bar_y + progress * scroll_bar_h, 4, 40,
                     STATE.current_theme.accent, STATE.menu_alpha * 0.5)
    end
end

-- ============================================================================
-- INPUT HANDLING
-- ============================================================================

function HandleMenuInput(key)
    local current_page = MENU_STRUCTURE[STATE.active_page]
    if not current_page then return end
    
    if key == CONFIG.NAVIGATION_UP then
        STATE.selected_index = math.max(1, STATE.selected_index - 1)
    elseif key == CONFIG.NAVIGATION_DOWN then
        STATE.selected_index = math.min(#current_page.items, STATE.selected_index + 1)
    elseif key == CONFIG.SELECT_KEY then
        local selected_item = current_page.items[STATE.selected_index]
        if selected_item then
            HandleMenuItemSelect(selected_item)
        end
    elseif key == CONFIG.BACK_KEY then
        if current_page.back then
            STATE.active_page = current_page.back
            STATE.selected_index = 1
            STATE.scroll_offset = 0
        else
            ToggleMenu()
        end
    end
end

function HandleMenuItemSelect(item)
    if item.type == "button" then
        if item.category == "functions" then
            ExecuteFunction(item.category, item.id)
        elseif item.category == "settings" then
            STATE.active_page = item.category
        elseif item.category then
            STATE.active_page = item.category
            STATE.selected_index = 1
            STATE.scroll_offset = 0
        end
    elseif item.type == "toggle_button" then
        ToggleFunction(item.id)
    elseif item.type == "theme" then
        if THEMES[item.theme_key] then
            STATE.current_theme = THEMES[item.theme_key]
        end
    elseif item.type == "toggle_item" then
        -- Handle settings toggle
        local settings = GetMenuSettings()
        if settings then
            settings[item.id] = not settings[item.id]
        end
    end
end

-- ============================================================================
-- MENU VISIBILITY & ANIMATION
-- ============================================================================

function ToggleMenu()
    STATE.menu_visible = not STATE.menu_visible
    
    if STATE.menu_visible then
        CreateAnimation(CONFIG.TRANSITION_DURATION, function(progress, finished)
            STATE.menu_alpha = progress
            if finished then
                STATE.is_animating = false
            end
        end, "cubic_in_out")
    else
        CreateAnimation(CONFIG.TRANSITION_DURATION, function(progress, finished)
            STATE.menu_alpha = 1 - progress
            if finished then
                STATE.is_animating = false
            end
        end, "cubic_in_out")
    end
end

function ShowMenu()
    if not STATE.menu_visible then
        STATE.menu_visible = true
        CreateAnimation(CONFIG.TRANSITION_DURATION, function(progress, finished)
            STATE.menu_alpha = progress
        end, "cubic_in_out")
    end
end

function HideMenu()
    if STATE.menu_visible then
        STATE.menu_visible = false
        CreateAnimation(CONFIG.TRANSITION_DURATION, function(progress, finished)
            STATE.menu_alpha = 1 - progress
        end, "cubic_in_out")
    end
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

function GetTimeInMs()
    return os.time() * 1000
end

function GetMenuSettings()
    return {
        show_fps = false,
        show_tooltips = true,
        sound_effects = true,
    }
end

function GetSystemStats()
    return {
        fps = math.floor(1 / (RENDER.last_frame_time + 0.001)),
        draw_calls = RENDER.draw_calls,
        active_animations = #ANIMATIONS.active,
        registered_functions = CountTableItems(FUNCTION_REGISTRY),
        active_toggles = CountTableItems(TOGGLE_STATES),
    }
end

function CountTableItems(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

function FormatTime(milliseconds)
    local seconds = milliseconds / 1000
    if seconds < 1 then
        return string.format("%.1fms", milliseconds)
    else
        return string.format("%.2fs", seconds)
    end
end

-- ============================================================================
-- EXAMPLE FUNCTION REGISTRATION
-- ============================================================================

function RegisterExampleFunctions()
    -- Utility Functions
    RegisterFunction("teleport", "Teleport", "utility", function()
        return {success = true, message = "Teleported"}
    end, "🚀", "Teleport to marked location")
    
    RegisterFunction("heal", "Heal", "utility", function()
        return {success = true, message = "Health restored"}
    end, "❤", "Restore health")
    
    RegisterFunction("spawn_vehicle", "Spawn Vehicle", "utility", function()
        return {success = true, message = "Vehicle spawned"}
    end, "🚗", "Spawn a vehicle")
    
    -- Combat Functions
    RegisterFunction("god_mode", "God Mode", "combat", function()
        return {success = true, message = "God mode enabled"}
    end, "⚡", "Become invincible")
    
    RegisterFunction("infinite_ammo", "Infinite Ammo", "combat", function()
        return {success = true, message = "Infinite ammo enabled"}
    end, "🔫", "Get unlimited ammunition")
    
    -- Appearance Functions
    RegisterFunction("change_outfit", "Change Outfit", "appearance", function()
        return {success = true, message = "Outfit changed"}
    end, "👕", "Switch to different outfit")
    
    RegisterFunction("apply_effects", "Visual Effects", "appearance", function()
        return {success = true, message = "Effects applied"}
    end, "✨", "Apply visual effects")
    
    -- Toggle Functions
    RegisterToggle("player_godmode", "Player God Mode", "toggles", false, function(enabled)
        -- print("God mode: " .. (enabled and "ON" or "OFF"))
    end, "🛡")
    
    RegisterToggle("unlimited_stamina", "Unlimited Stamina", "toggles", false, function(enabled)
        -- print("Unlimited stamina: " .. (enabled and "ON" or "OFF"))
    end, "⚙")
    
    RegisterToggle("no_hunger", "No Hunger", "toggles", false, function(enabled)
        -- print("No hunger: " .. (enabled and "ON" or "OFF"))
    end, "🍖")
    
    RegisterToggle("noclip", "No Clip", "toggles", false, function(enabled)
        -- print("No clip: " .. (enabled and "ON" or "OFF"))
    end, "👻")
end

-- ============================================================================
-- MAIN UPDATE & RENDER LOOP
-- ============================================================================

function Update(delta_time)
    RENDER.last_frame_time = delta_time
    
    -- Update animations
    UpdateAnimations(delta_time)
    
    -- Update menu state
    if STATE.menu_visible then
        -- Handle input while menu is visible
        -- This would be integrated with actual key input system
    end
end

function Render()
    if STATE.menu_visible or STATE.menu_alpha > 0 then
        RenderMenu()
    end
    
    -- Draw debug info if enabled
    local settings = GetMenuSettings()
    if settings.show_fps then
        local stats = GetSystemStats()
        DrawText(10, 10, "FPS: " .. stats.fps, 1.0, STATE.current_theme.text_primary, 0.8)
        DrawText(10, 30, "Draw Calls: " .. stats.draw_calls, 0.8, STATE.current_theme.text_secondary, 0.6)
    end
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

function Initialize()
    -- Register example functions and toggles
    RegisterExampleFunctions()
    
    -- Build menus
    BuildFunctionsMenu()
    BuildTogglesMenu()
    
    -- Set initial state
    STATE.current_theme = THEMES.DARK
    STATE.menu_alpha = 0
    STATE.menu_visible = false
    
    return {
        version = LAUNCHER.VERSION,
        author = LAUNCHER.AUTHOR,
        build_date = LAUNCHER.BUILD_DATE,
        status = "initialized"
    }
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

local ULTIM_MENU = {
    -- Core Functions
    Initialize = Initialize,
    Update = Update,
    Render = Render,
    ToggleMenu = ToggleMenu,
    ShowMenu = ShowMenu,
    HideMenu = HideMenu,
    
    -- Configuration
    SetTheme = function(theme_name)
        if THEMES[theme_name] then
            STATE.current_theme = THEMES[theme_name]
            return true
        end
        return false
    end,
    
    GetCurrentTheme = function()
        return STATE.current_theme
    end,
    
    GetAvailableThemes = function()
        return THEMES
    end,
    
    -- Function Management
    RegisterFunction = RegisterFunction,
    RegisterToggle = RegisterToggle,
    ExecuteFunction = ExecuteFunction,
    ToggleFunction = ToggleFunction,
    
    -- State Management
    GetState = function()
        return STATE
    end,
    
    GetStats = GetSystemStats,
    
    -- Input
    HandleInput = HandleMenuInput,
    
    -- Utils
    FormatTime = FormatTime,
}

-- Initialize on load
if pcall(Initialize) then
    -- print("[ULTIM-MENU] Successfully initialized version " .. LAUNCHER.VERSION)
else
    -- print("[ULTIM-MENU] Initialization failed!")
end

return ULTIM_MENU
