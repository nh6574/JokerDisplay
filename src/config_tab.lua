--- MOD CONFIG

local ui_config = {
    bg_colour = HEX("44D72344"),
    back_colour = HEX("D63939"),
    tab_button_colour = HEX("D63939"),
    collection_option_cycle_colour = HEX("D63939"),
    author_colour = HEX("D63939")
}

function G.FUNCS.jokerdisplay_github(e)
    love.system.openURL("https://github.com/nh6574/JokerDisplay")
end

function G.FUNCS.jokerdisplay_bluesky(e)
    love.system.openURL("https://bsky.app/profile/nh6574.com")
end

function G.FUNCS.jokerdisplay_kofi(e)
    love.system.openURL("https://ko-fi.com/nh6574")
end

function G.FUNCS.jokerdisplay_joyousspring(e)
    love.system.openURL("https://github.com/nh6574/JoyousSpring")
end

function G.FUNCS.jokerdisplay_repertorium(e)
    love.system.openURL("https://github.com/nh6574/Repertorium")
end

function G.FUNCS.jokerdisplay_playlog(e)
    love.system.openURL("https://github.com/nh6574/PlayLog")
end

function G.FUNCS.jokerdisplay_vanillaremade(e)
    love.system.openURL("https://github.com/nh6574/VanillaRemade")
end

JokerDisplay.save_config = JokerDisplay.save_config or function() end

JokerDisplay.custom_menu_ui = function(modNodes)
    local ui_icon_button = function(button, colour, pos)
        return {
            n = G.UIT.R,
            config = { align = 'cm' },
            nodes = {
                {
                    n = G.UIT.C,
                    config = {
                        align = "cm",
                        r = 0.1,
                        hover = true,
                        minh = 0.8,
                        shadow = true,
                        colour = colour,
                        minw = 2,
                        button = "jokerdisplay_" .. button,
                    },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = { align = "cm" },
                            nodes = {
                                {
                                    n = G.UIT.T,
                                    config = {
                                        text = localize("k_jdis_" .. button),
                                        colour = G.C.UI.TEXT_LIGHT,
                                        scale = 0.4,
                                    }
                                }
                            }
                        }
                    }
                },
            }
        }
    end

    local socials = {
        {
            n = G.UIT.C,
            config = {
                padding = 0.07,
                align = "cm",
            },
            nodes = {
                ui_icon_button("github", HEX("1f1f1f"), { x = 1, y = 0 })
            }
        },
        {
            n = G.UIT.C,
            config = {
                padding = 0.07,
                align = "cm",
            },
            nodes = {
                ui_icon_button("bluesky", HEX("0886fe"), { x = 1, y = 1 })
            }
        },
        {
            n = G.UIT.C,
            config = {
                padding = 0.07,
                align = "cm",
            },
            nodes = {
                ui_icon_button("kofi", HEX("60b7e0"), { x = 1, y = 2 })
            }
        },
    }

    local make_mod_column = function(mod, colour)
        return {
            n = G.UIT.C,
            config = {
                padding = 0.2,
                align = "cm",
            },
            nodes = {
                UIBox_button({
                    colour = colour,
                    minw = 2.6,
                    minh = 0.45,
                    scale = 0.35,
                    button = "jokerdisplay_" .. mod,
                    label = { localize('k_jdis_' .. mod) }
                })
            }
        }
    end

    local othermods1 = {
        make_mod_column("joyousspring", HEX("F4A6C7")),
        make_mod_column("repertorium", HEX("1E7A0A")),
    }

    local othermods2 = {
        make_mod_column("playlog", HEX("178BAC")),
        make_mod_column("vanillaremade", G.C.BLUE),
    }

    modNodes[#modNodes + 1] = {
        n = G.UIT.R,
        config = {
            padding = 0.01,
            align = "cm",
        },
        nodes = {
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.01, no_fill = true },
                nodes = socials
            },
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.07, no_fill = true },
                nodes = {
                    {
                        n = G.UIT.T,
                        config = { text = localize("k_jdis_othermods"), colour = G.C.UI.TEXT_LIGHT, scale = 0.35 },
                    },
                },
            },
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.1, no_fill = true },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = -0.3, no_fill = true },
                        nodes = othermods1
                    },
                }
            },
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.1, no_fill = true },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = -0.3, no_fill = true },
                        nodes = othermods2
                    },
                }
            },
        }
    }
end

local function hsv_to_rgb(h, s, v)
    h, s, v = (h or 0) / 60, (s or 0) / 100, (v or 0) / 100
    local c = v * s
    local x = c * (1 - math.abs(h % 2 - 1))
    local m = v - c
    local r, g, b = 0, 0, 0
    if h < 1 then r, g = c, x
    elseif h < 2 then r, g = x, c
    elseif h < 3 then g, b = c, x
    elseif h < 4 then g, b = x, c
    elseif h < 5 then r, b = x, c
    else r, b = c, x end
    return r + m, g + m, b + m
end

local function rgb_to_hsv(r, g, b)
    local maxc, minc = math.max(r, g, b), math.min(r, g, b)
    local d, h = maxc - minc, 0
    if d ~= 0 then
        if maxc == r then h = 60 * (((g - b) / d) % 6)
        elseif maxc == g then h = 60 * ((b - r) / d + 2)
        else h = 60 * ((r - g) / d + 4) end
    end
    return h, maxc == 0 and 0 or d / maxc * 100, maxc * 100
end

local function hex_to_rgb(value)
    value = tostring(value or ""):gsub("#", "")
    if #value ~= 6 or not value:match("^%x+$") then return end
    return tonumber(value:sub(1, 2), 16) / 255, tonumber(value:sub(3, 4), 16) / 255,
        tonumber(value:sub(5, 6), 16) / 255
end

local function colour_hex(colour)
    return string.format("#%02X%02X%02X", math.floor(colour[1] * 255 + 0.5),
        math.floor(colour[2] * 255 + 0.5), math.floor(colour[3] * 255 + 0.5))
end

local function update_box_colour(card, colour)
    if not card or not card.children then return end
    for _, key in ipairs({ "joker_display", "joker_display_small", "joker_display_debuff" }) do
        local box = card.children[key]
        if box and box.UIRoot then
            box.UIRoot.config.colour = colour
            box._canvas_dirty = true
        end
    end
    if JokerDisplay.update_sticker_colours then JokerDisplay.update_sticker_colours(card) end
end

local function apply_background_colour(save)
    local config = JokerDisplay.config
    local r, g, b = hsv_to_rgb(config.background_hue, config.background_saturation, config.background_brightness)
    local colour = config.background_colour or { 0, 0, 0, 0.8 }
    colour[1], colour[2], colour[3], colour[4] = r, g, b, config.background_opacity or colour[4] or 0.8
    config.background_colour = colour
    if G.jokerdisplay_config_card_area then
        update_box_colour(G.jokerdisplay_config_card_area.cards[1], colour)
    end
    if JokerDisplay.should_display() then
        for _, area in pairs(JokerDisplay.get_display_areas()) do
            for _, card in pairs(area.cards or {}) do update_box_colour(card, colour) end
        end
    end
    if save then JokerDisplay.save_config() end
end

local function invalidate_display_colours()
    local function invalidate(node)
        if node.UIT == G.UIT.O and node.config.object then
            node._text = nil
            if node.config.object.joker_display_lightweight then node.config.object:_set_drawable() end
        end
        for _, child in ipairs(node.children or {}) do invalidate(child) end
    end
    local function invalidate_card(card)
        if not card or not card.children then return end
        for _, key in ipairs({ "joker_display", "joker_display_small", "joker_display_debuff" }) do
            local box = card.children[key]
            if box and box.UIRoot then invalidate(box.UIRoot); box._canvas_dirty = true end
        end
        JokerDisplay.update_sticker_colours(card)
    end
    if G.jokerdisplay_config_card_area then invalidate_card(G.jokerdisplay_config_card_area.cards[1]) end
    if JokerDisplay.should_display() then
        for _, area in pairs(JokerDisplay.get_display_areas()) do
            for _, card in pairs(area.cards or {}) do invalidate_card(card) end
        end
    end
end

local function picker_target_colour(picker)
    local target = picker.targets[picker.target]
    if target.id == "background" then return JokerDisplay.get_background_colour() end
    return (JokerDisplay.config.text_colour_overrides or {})[target.id] or target.colour
end

local function picker_load_target(picker)
    local colour = picker_target_colour(picker)
    picker.h, picker.s, picker.v = rgb_to_hsv(colour[1], colour[2], colour[3])
    picker.s, picker.v, picker.a = picker.s / 100, picker.v / 100, colour[4] or 1
    picker.hex_focus, picker.hex_input, picker.dragging = false, nil, nil
end

local function picker_apply(picker, save)
    local target = picker.targets[picker.target]
    local r, g, b = hsv_to_rgb(picker.h, picker.s * 100, picker.v * 100)
    if target.id == "background" then
        JokerDisplay.config.background_colour_override = true
        JokerDisplay.config.background_hue = picker.h
        JokerDisplay.config.background_saturation = picker.s * 100
        JokerDisplay.config.background_brightness = picker.v * 100
        JokerDisplay.config.background_opacity = picker.a
        apply_background_colour(save)
    else
        JokerDisplay.config.text_colour_overrides = JokerDisplay.config.text_colour_overrides or {}
        JokerDisplay.config.text_colour_overrides[target.id] = { r, g, b, picker.a }
        invalidate_display_colours()
        if save then JokerDisplay.save_config() end
    end
end

local function picker_contains(rect, x, y) return rect and x >= rect.x and x <= rect.x + rect.w and y >= rect.y and y <= rect.y + rect.h end

local function picker_move(picker, x, y)
    local rect = picker.dragging == "hue" and picker._hbar_rect
        or picker.dragging == "alpha" and picker._alpha_rect or picker._sq_rect
    if not rect then return end
    local nx = math.max(0, math.min(1, (x - rect.x) / rect.w))
    local ny = math.max(0, math.min(1, (y - rect.y) / rect.h))
    if picker.dragging == "hue" then picker.h = nx * 360
    elseif picker.dragging == "alpha" then picker.a = nx
    else picker.s, picker.v = nx, 1 - ny end
    picker_apply(picker, true)
end

function JokerDisplay.draw_colour_picker()
    local pk = G.jokerdisplay_colour_picker
    if not pk then return end
    local sw, sh = love.graphics.getDimensions()
    local panel_w, panel_h = math.min(500, sw - 40), math.min(390, sh - 40)
    local panel_x, panel_y = (sw - panel_w) / 2, (sh - panel_h) / 2
    pk._panel_rect = { x = panel_x, y = panel_y, w = panel_w, h = panel_h }
    local cx, cy, cw = panel_x + 18, panel_y + 18, panel_w - 36
    local sq_w, sq_h, hbar_h, pad = cw - 4, math.floor((cw - 4) * 0.55), 16, 8
    local sq_x, sq_y = cx, cy + 24
    local hbar_x, hbar_y = cx, sq_y + sq_h + pad
    love.graphics.push("all")
    love.graphics.origin()
    love.graphics.setColor(0.03, 0.03, 0.08, 0.98)
    love.graphics.rectangle("fill", panel_x, panel_y, panel_w, panel_h, 8, 8)
    love.graphics.setColor(0.95, 0.73, 0.25, 0.9)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panel_x, panel_y, panel_w, panel_h, 8, 8)
    love.graphics.setColor(0.95, 0.73, 0.25, 0.7)
    love.graphics.rectangle("fill", cx, cy, 60, 18, 3, 3)
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.print("< BACK", cx + 4, cy + 2, 0, 0.7, 0.7)
    love.graphics.setColor(0.95, 0.73, 0.25, 1)
    local target = pk.targets[pk.target]
    local selector_x, selector_w = cx + 68, panel_w - 164
    love.graphics.setColor(0, 0, 0, 0.55)
    love.graphics.rectangle("fill", selector_x, cy, selector_w, 18, 3, 3)
    love.graphics.setColor(0.95, 0.73, 0.25, 1)
    love.graphics.rectangle("line", selector_x, cy, selector_w, 18, 3, 3)
    love.graphics.print("EDITING: " .. target.label, selector_x + 5, cy + 3, 0, 0.62, 0.62)
    love.graphics.print(pk.dropdown and "^" or "v", selector_x + selector_w - 13, cy + 3, 0, 0.62, 0.62)
    love.graphics.setColor(0.95, 0.73, 0.25, 0.7)
    love.graphics.rectangle("fill", panel_x + panel_w - 56, cy, 38, 18, 3, 3)
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.print("RESET", panel_x + panel_w - 53, cy + 3, 0, 0.52, 0.52)
    local verts = {}
    for j = 0, 32 do
        local s = j / 32
        local r, g, b = hsv_to_rgb(pk.h, s * 100, 100)
        verts[#verts + 1] = { sq_x + s * sq_w, sq_y, 0, 0, r, g, b, 1 }
        verts[#verts + 1] = { sq_x + s * sq_w, sq_y + sq_h, 0, 1, 0, 0, 0, 1 }
    end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(love.graphics.newMesh(verts, "strip", "static"))
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.circle("line", sq_x + pk.s * sq_w, sq_y + (1 - pk.v) * sq_h, 7)
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.circle("line", sq_x + pk.s * sq_w, sq_y + (1 - pk.v) * sq_h, 6)
    local hverts = {}
    for i = 0, 24 do
        local r, g, b = hsv_to_rgb(i * 15, 100, 100)
        hverts[#hverts + 1] = { hbar_x + i / 24 * sq_w, hbar_y, 0, 0, r, g, b, 1 }
        hverts[#hverts + 1] = { hbar_x + i / 24 * sq_w, hbar_y + hbar_h, 0, 1, r, g, b, 1 }
    end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(love.graphics.newMesh(hverts, "strip", "static"))
    local hcur_x = hbar_x + pk.h / 360 * sq_w
    love.graphics.setLineWidth(2)
    love.graphics.line(hcur_x, hbar_y - 2, hcur_x, hbar_y + hbar_h + 2)
    local alpha_y = hbar_y + hbar_h + pad
    local r, g, b = hsv_to_rgb(pk.h, pk.s * 100, pk.v * 100)
    for i = 0, 23 do
        local x = hbar_x + i / 24 * sq_w
        love.graphics.setColor(i % 2 == 0 and 0.7 or 0.35, i % 2 == 0 and 0.7 or 0.35, i % 2 == 0 and 0.7 or 0.35, 1)
        love.graphics.rectangle("fill", x, alpha_y, sq_w / 24 + 1, hbar_h)
    end
    local averts = {
        { hbar_x, alpha_y, 0, 0, r, g, b, 0 }, { hbar_x, alpha_y + hbar_h, 0, 1, r, g, b, 0 },
        { hbar_x + sq_w, alpha_y, 1, 0, r, g, b, 1 }, { hbar_x + sq_w, alpha_y + hbar_h, 1, 1, r, g, b, 1 }
    }
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(love.graphics.newMesh(averts, "strip", "static"))
    local acur_x = hbar_x + pk.a * sq_w
    love.graphics.line(acur_x, alpha_y - 2, acur_x, alpha_y + hbar_h + 2)
    love.graphics.print("Opacity " .. math.floor(pk.a * 100 + 0.5) .. "%", hbar_x, alpha_y + hbar_h + 2, 0, 0.6, 0.6)
    local hex_y, input_w = alpha_y + hbar_h + pad + 10, 120
    love.graphics.setColor(r, g, b, 1)
    love.graphics.rectangle("fill", cx, hex_y, 36, 26, 4, 4)
    love.graphics.setColor(0, 0, 0, 0.45)
    love.graphics.rectangle("fill", cx + 42, hex_y, input_w, 26, 4, 4)
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.print("#" .. (pk.hex_focus and (pk.hex_input or "") or colour_hex({ r, g, b }):sub(2)), cx + 46, hex_y + 5, 0, 0.8, 0.8)
    love.graphics.setColor(0.55, 0.55, 0.55, 0.7)
    love.graphics.print("click to type hex", cx + 42 + input_w + 8, hex_y + 7, 0, 0.65, 0.65)
    pk._sq_rect = { x = sq_x, y = sq_y, w = sq_w, h = sq_h }
    pk._hbar_rect = { x = hbar_x, y = hbar_y, w = sq_w, h = hbar_h }
    pk._alpha_rect = { x = hbar_x, y = alpha_y, w = sq_w, h = hbar_h }
    pk._hex_rect = { x = cx + 42, y = hex_y, w = input_w, h = 26 }
    pk._back_rect = { x = cx, y = cy, w = 60, h = 18 }
    pk._selector_rect = { x = selector_x, y = cy, w = selector_w, h = 18 }
    pk._reset_rect = { x = panel_x + panel_w - 58, y = cy, w = 42, h = 18 }
    pk._dropdown_rows = {}
    if pk.dropdown then
        local row_h, visible = 20, math.min(8, #pk.targets)
        pk.dropdown_scroll = math.max(1, math.min(pk.dropdown_scroll or 1, #pk.targets - visible + 1))
        local list_y = cy + 21
        love.graphics.setColor(0.02, 0.02, 0.05, 0.98)
        love.graphics.rectangle("fill", selector_x, list_y, selector_w, row_h * visible, 3, 3)
        love.graphics.setColor(0.95, 0.73, 0.25, 1)
        love.graphics.rectangle("line", selector_x, list_y, selector_w, row_h * visible, 3, 3)
        for row = 1, visible do
            local index = pk.dropdown_scroll + row - 1
            local option = pk.targets[index]
            local rect = { x = selector_x, y = list_y + (row - 1) * row_h, w = selector_w, h = row_h }
            pk._dropdown_rows[#pk._dropdown_rows + 1] = { rect = rect, index = index }
            if index == pk.target then
                love.graphics.setColor(0.95, 0.73, 0.25, 0.25)
                love.graphics.rectangle("fill", rect.x + 1, rect.y + 1, rect.w - 2, rect.h - 2)
            end
            love.graphics.setColor(1, 1, 1, 0.9)
            love.graphics.print(option.label, rect.x + 5, rect.y + 4, 0, 0.6, 0.6)
        end
    end
    love.graphics.pop()
end

local game_draw_ref = Game.draw
function Game:draw(...)
    game_draw_ref(self, ...)
    JokerDisplay.draw_colour_picker()
end

local mouse_position_ref = love.mouse.getPosition
function love.mouse.getPosition()
    local x, y = mouse_position_ref()
    local picker = G and G.jokerdisplay_colour_picker
    if picker and picker_contains(picker._panel_rect, x, y) then return -1, -1 end
    return x, y
end

local mousepressed_ref = love.mousepressed or function() end
function love.mousepressed(x, y, button, ...)
    local picker = G and G.jokerdisplay_colour_picker
    if picker then
        if button == 1 then
            if picker_contains(picker._back_rect, x, y) then G.jokerdisplay_colour_picker = nil
            elseif picker_contains(picker._selector_rect, x, y) then
                picker.dropdown = not picker.dropdown
                picker.dropdown_scroll = math.max(1, math.min(picker.target, #picker.targets - 7))
            elseif picker.dropdown then
                local selected
                for _, row in ipairs(picker._dropdown_rows or {}) do
                    if picker_contains(row.rect, x, y) then selected = row.index; break end
                end
                if selected then
                    picker.target, picker.dropdown = selected, false
                    picker_load_target(picker)
                else
                    picker.dropdown = false
                end
            elseif picker_contains(picker._reset_rect, x, y) then
                local target = picker.targets[picker.target]
                if target.id == "background" then
                    JokerDisplay.config.background_colour_override = false
                    local colour = JokerDisplay.get_background_colour()
                    if G.jokerdisplay_config_card_area then update_box_colour(G.jokerdisplay_config_card_area.cards[1], colour) end
                    if JokerDisplay.should_display() then
                        for _, area in pairs(JokerDisplay.get_display_areas()) do
                            for _, card in pairs(area.cards or {}) do update_box_colour(card, colour) end
                        end
                    end
                else
                    JokerDisplay.config.text_colour_overrides[target.id] = nil
                end
                picker_load_target(picker)
                invalidate_display_colours()
                JokerDisplay.save_config()
            elseif picker_contains(picker._hex_rect, x, y) then picker.hex_focus, picker.hex_input = true, ""
            elseif picker_contains(picker._sq_rect, x, y) then picker.hex_focus, picker.dragging = false, "sv"
            elseif picker_contains(picker._hbar_rect, x, y) then picker.hex_focus, picker.dragging = false, "hue"
            elseif picker_contains(picker._alpha_rect, x, y) then picker.hex_focus, picker.dragging = false, "alpha" end
            if picker.dragging then picker_move(picker, x, y) end
        end
        return
    end
    return mousepressed_ref(x, y, button, ...)
end

local keypressed_ref = love.keypressed or function() end
function love.keypressed(key, ...)
    local picker = G and G.jokerdisplay_colour_picker
    if picker and key == "escape" then
        G.jokerdisplay_colour_picker = nil
        return
    end
    if picker and picker.hex_focus then
        if key == "return" or key == "kpenter" then
            local r, g, b = hex_to_rgb(picker.hex_input)
            if r then
                picker.h, picker.s, picker.v = rgb_to_hsv(r, g, b)
                picker.s, picker.v = picker.s / 100, picker.v / 100
                picker_apply(picker, true)
            end
            picker.hex_focus = false
        elseif key == "backspace" then
            picker.hex_input = (picker.hex_input or ""):sub(1, -2)
        end
    end
    if picker then return end
    return keypressed_ref(key, ...)
end

local textinput_ref = love.textinput or function() end
function love.textinput(text)
    local picker = G and G.jokerdisplay_colour_picker
    if picker and picker.hex_focus and text:match("^%x+$") and #(picker.hex_input or "") < 6 then
        picker.hex_input = (picker.hex_input or "") .. text
    end
    if picker then return end
    return textinput_ref(text)
end

local mousemoved_ref = love.mousemoved or function() end
function love.mousemoved(x, y, dx, dy, ...)
    local picker = G.jokerdisplay_colour_picker
    if picker and picker.dragging then picker_move(picker, x, y) end
    if picker then return end
    return mousemoved_ref(x, y, dx, dy, ...)
end

local mousereleased_ref = love.mousereleased or function() end
function love.mousereleased(x, y, button, ...)
    local picker = G.jokerdisplay_colour_picker
    if picker and button == 1 and picker.dragging then
        picker.dragging = nil
        JokerDisplay.save_config()
    end
    if picker then return end
    return mousereleased_ref(x, y, button, ...)
end

local wheelmoved_ref = love.wheelmoved or function() end
function love.wheelmoved(x, y, ...)
    if G and G.jokerdisplay_colour_picker then
        local picker = G.jokerdisplay_colour_picker
        if picker.dropdown then
            local visible = math.min(8, #picker.targets)
            picker.dropdown_scroll = math.max(
                1,
                math.min((picker.dropdown_scroll or 1) - y, #picker.targets - visible + 1)
            )
        end
        return
    end
    return wheelmoved_ref(x, y, ...)
end

G.FUNCS.joker_display_open_colour_picker = function()
    local targets = { { id = "background", label = "Background", colour = JokerDisplay.config.background_colour } }
    local known = {
        { "chips", "Chips", G.C.CHIPS }, { "mult", "Mult", G.C.MULT },
        { "xmult", "XMult", G.C.XMULT }, { "money", "Money", G.C.GOLD },
        { "odds", "Chance", G.C.GREEN },
        { "required", "Required text", G.C.ORANGE },
        { "perishable", "Perishable", lighten(G.C.PERISHABLE, 0.35) },
        { "rental", "Rental", G.C.GOLD },
        { "sticker_background", "Sticker background", JokerDisplay.get_background_colour() },
        { "suit_hearts", "Hearts", lighten(G.C.SUITS.Hearts, 0.35) },
        { "suit_diamonds", "Diamonds", lighten(G.C.SUITS.Diamonds, 0.35) },
        { "suit_spades", "Spades", lighten(G.C.SUITS.Spades, 0.35) },
        { "suit_clubs", "Clubs", lighten(G.C.SUITS.Clubs, 0.35) },
        { "text", "Default text", G.C.UI.TEXT_LIGHT },
        { "inactive", "Inactive text", G.C.UI.TEXT_INACTIVE }
    }
    local added = { background = true }
    for _, target in ipairs(known) do
        targets[#targets + 1] = { id = target[1], label = target[2], colour = target[3] }
        added[target[1]] = true
    end
    local custom = {}
    for id, entry in pairs(JokerDisplay.display_colour_registry or {}) do
        if not added[id] then custom[#custom + 1] = { id = id, label = entry.label, colour = entry.colour } end
    end
    table.sort(custom, function(a, b) return a.label < b.label end)
    for _, target in ipairs(custom) do targets[#targets + 1] = target end
    local picker = { targets = targets, target = 1 }
    G.jokerdisplay_colour_picker = picker
    picker_load_target(picker)
end

JokerDisplay.config_tab = function()
    if not JokerDisplay.init_loc then init_localization() end
    -- Create a card area that will display an example joker
    G.jokerdisplay_config_card_area = CardArea(G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h, 1.03 * G.CARD_W,
        1.03 * G.CARD_H,
        { card_limit = 1, type = 'title', highlight_limit = 0, })
    local center = G.P_CENTERS['j_bloodstone']
    local card = Card(G.jokerdisplay_config_card_area.T.x + G.jokerdisplay_config_card_area.T.w / 2,
        G.jokerdisplay_config_card_area.T.y, G.CARD_W, G.CARD_H,
        nil, center)
    card:set_edition('e_foil', true, true)
    card:set_perishable(true)
    card:set_rental(true)
    G.jokerdisplay_config_card_area:emplace(card)
    G.jokerdisplay_config_card_area.cards[1]:update_joker_display()
    G.jokerdisplay_config_card_area.cards[1].joker_display_values.disabled = false

    local old_remove = G.jokerdisplay_config_card_area.remove
    function G.jokerdisplay_config_card_area:remove()
        old_remove(self)
        if G.jokerdisplay_config_card_area == self then
            G.jokerdisplay_config_card_area = nil
        end
    end

    local modNodes = {}

    local authors = localize('jdis_author') .. ': ' .. "nh6574"

    -- Authors names
    table.insert(modNodes, {
        n = G.UIT.R,
        config = {
            align = "cm",
            r = 0.1,
            emboss = 0.1,
            outline = 1,
            padding = 0.07,
            outline_colour = ui_config.author_outline_colour,
            colour = ui_config.author_bg_colour,
        },
        nodes = {
            {
                n = G.UIT.T,
                config = {
                    text = authors,
                    shadow = true,
                    scale = 0.75 * 0.65,
                    colour = ui_config.author_colour or G.C.BLUE,
                }
            }
        }
    })

    modNodes[#modNodes + 1] = {}
    local loc_vars = { background_colour = G.C.CLEAR, text_colour = G.C.UI.TEXT_LIGHT, scale = 1.2 }
    localize { type = 'descriptions', key = loc_vars.key or "JokerDisplay", set = 'Mod', nodes = modNodes[#modNodes], vars = loc_vars.vars, scale = loc_vars.scale, text_colour = loc_vars.text_colour, shadow = loc_vars.shadow }
    modNodes[#modNodes] = desc_from_rows(modNodes[#modNodes])
    modNodes[#modNodes].config.colour = loc_vars.background_colour or modNodes[#modNodes].config.colour

    JokerDisplay.custom_menu_ui(modNodes)

    local config = {
        {
            n = G.UIT.R,
            config = { padding = 0.2 },
            nodes = {
                {
                    n = G.UIT.C,
                    config = { align = "cm" },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = { align = "cr", padding = 0.01 },
                            nodes = {
                                create_toggle({
                                    label = localize('jdis_enabled'),
                                    ref_table = JokerDisplay.config,
                                    ref_value = 'enabled',
                                    callback = JokerDisplay.save_config
                                })
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { padding = 0.01, align = "cr" },
                            nodes = {
                                create_toggle({
                                    label = localize('jdis_hide_by_default'),
                                    ref_table = JokerDisplay.config,
                                    ref_value =
                                    'hide_by_default',
                                    callback = JokerDisplay.save_config
                                })
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { padding = 0.01, align = "cr" },
                            nodes = {
                                create_toggle({
                                    label = localize('jdis_hide_empty'),
                                    ref_table = JokerDisplay.config,
                                    ref_value =
                                    'hide_empty',
                                    callback = JokerDisplay.save_config
                                })
                            }
                        },
                    }
                },
                {
                    n = G.UIT.C,
                    config = { align = "cm" },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = { padding = 0.01, align = "cr" },
                            nodes = {
                                create_toggle({
                                    label = localize('jdis_disable_collapse'),
                                    ref_table = JokerDisplay.config,
                                    ref_value =
                                    'disable_collapse',
                                    callback = JokerDisplay.save_config
                                })
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { padding = 0.01, align = "cr" },
                            nodes = {
                                create_toggle({
                                    label = localize('jdis_disable_perishable'),
                                    ref_table = JokerDisplay.config,
                                    ref_value =
                                    'disable_perishable',
                                    callback = JokerDisplay.save_config
                                })
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { padding = 0.01, align = "cr" },
                            nodes = {
                                create_toggle({
                                    label = localize('jdis_disable_rental'),
                                    ref_table = JokerDisplay.config,
                                    ref_value =
                                    'disable_rental',
                                    callback = JokerDisplay.save_config
                                })
                            }
                        },
                    }
                },
            }
        },
        {
            n = G.UIT.R,
            config = { padding = 0.2 },
            nodes = {
                {
                    n = G.UIT.C,
                    config = { align = "cm" },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = { align = "cm" },
                            nodes = {
                                {
                                    n = G.UIT.C,
                                    config = { align = "cr", padding = 0.2 },
                                    nodes = {
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cm" },
                                            nodes = {
                                                {
                                                    n = G.UIT.T,
                                                    config = { text = localize('jdis_default_display'), colour = G.C.UI.TEXT_LIGHT, scale = 0.5, align = "cr" }
                                                },
                                            }
                                        },
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cr" },
                                            nodes = {
                                                create_toggle({
                                                    label = localize('jdis_modifiers'),
                                                    ref_table = JokerDisplay.config.default_rows,
                                                    callback = update_display,
                                                    ref_value = 'modifiers',
                                                    w = 2,
                                                }),
                                            }
                                        },
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cr" },
                                            nodes = {
                                                create_toggle({
                                                    label = localize('jdis_reminders'),
                                                    ref_table = JokerDisplay.config.default_rows,
                                                    callback = update_display,
                                                    ref_value = 'reminder',
                                                    w = 2
                                                }),
                                            }
                                        },
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cr" },
                                            nodes = {
                                                create_toggle({
                                                    label = localize('jdis_extras'),
                                                    ref_table = JokerDisplay.config.default_rows,
                                                    callback = update_display,
                                                    ref_value = 'extra',
                                                    w = 2
                                                })
                                            }
                                        },
                                    }
                                },
                                {
                                    n = G.UIT.C,
                                    config = { align = "cr", padding = 0.2 },
                                    nodes = {
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cm" },
                                            nodes = {
                                                { n = G.UIT.T, config = { text = localize('jdis_small_display'), colour = G.C.UI.TEXT_LIGHT, scale = 0.5, align = "cr" } },
                                            }
                                        },
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cr" },
                                            nodes = {
                                                create_toggle({
                                                    label = localize('jdis_modifiers'),
                                                    ref_table = JokerDisplay.config.small_rows,
                                                    callback = update_display,
                                                    ref_value = 'modifiers',
                                                    w = 2
                                                }),
                                            }
                                        },
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cr" },
                                            nodes = {
                                                create_toggle({
                                                    label = localize('jdis_reminders'),
                                                    ref_table = JokerDisplay.config.small_rows,
                                                    callback = update_display,
                                                    ref_value = 'reminder',
                                                    w = 2
                                                }),
                                            }
                                        },
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cr" },
                                            nodes = {
                                                create_toggle({
                                                    label = localize('jdis_extras'),
                                                    ref_table = JokerDisplay.config.small_rows,
                                                    callback = update_display,
                                                    ref_value = 'extra',
                                                    w = 2
                                                })
                                            }
                                        },
                                    }
                                }
                            }
                        }
                    }
                },
                {
                    n = G.UIT.C,
                    config = { align = "tm", padding = 0.1, no_fill = true },
                    nodes = {
                        { n = G.UIT.O, config = { object = G.jokerdisplay_config_card_area } }
                    }
                }
            }
        },
        {
            n = G.UIT.R,
            config = { padding = 0.01, align = "cr" },
            nodes = {
                create_toggle({
                    label = localize('jdis_shift_to_hide'),
                    ref_table = JokerDisplay.config,
                    ref_value =
                    'shift_to_hide',
                    callback = JokerDisplay.save_config
                })
            }
        },
        {
            n = G.UIT.R,
            config = { padding = 0.01, align = "cr" },
            nodes = {
                create_toggle({
                    label = localize('jdis_joker_count'),
                    ref_table = JokerDisplay.config,
                    ref_value =
                    'joker_count',
                    callback = JokerDisplay.save_config
                })
            }
        },
        { n = G.UIT.R, config = { minh = 0.1 } }
    }

    return SMODS and {
        n = G.UIT.ROOT,
        config = { r = 0.1, minw = 8, align = "tm", padding = 0.2, colour = G.C.BLACK },
        nodes = config
    } or {
        n = G.UIT.ROOT,
        config = { align = "tm", colour = G.C.CLEAR },
        nodes = {
            {
                n = G.UIT.R,
                config = { r = 0.1, minw = 8, align = "tm", padding = 0.2, colour = G.C.CLEAR },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { r = 0.1, minw = 8, align = "tm", padding = 0.2, colour = G.C.BLACK },
                        nodes = config
                    },
                    {
                        n = G.UIT.C,
                        config = {
                            minh = 6,
                            r = 0.1,
                            minw = 6,
                            align = "tm",
                            padding = 0.2,
                            colour = G.C.BLACK
                        },
                        nodes = modNodes
                    }
                }
            }
        }
    }
end

if SMODS then
    SMODS.current_mod.ui_config = ui_config

    SMODS.current_mod.description_loc_vars = function()
        return { background_colour = G.C.CLEAR, text_colour = G.C.WHITE, scale = 1.2 }
    end

    SMODS.current_mod.config_tab = function()
        return JokerDisplay.config_tab()
    end
end

-- Callback function for config toggles, updates the example joker and any current jokers if a game is being played
function update_display()
    JokerDisplay.save_config()

    if G.jokerdisplay_config_card_area then
        G.jokerdisplay_config_card_area.cards[1]:update_joker_display(true, true, "config_update")
    end
    if JokerDisplay.should_display() then
        for _, area in pairs(JokerDisplay.get_display_areas()) do
            for _, joker in pairs(area.cards or {}) do
                joker:update_joker_display(true, true, "config_update")
            end
        end
    end
end
