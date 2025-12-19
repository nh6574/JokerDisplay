---DISPLAY BOX CLASS

JokerDisplayBox = UIBox:extend()

function JokerDisplayBox:init(parent, func, args)
    args = args or {}

    args.definition = args.definition or {
        n = G.UIT.ROOT,
        config = {
            minh = 0.6,
            minw = 2,
            maxw = 2,
            r = 0.001,
            padding = 0.1,
            align = 'cm',
            colour = adjust_alpha(darken(G.C.BLACK, 0.2), 0.8),
            shadow = true,
            func = func,
            ref_table = parent
        },
        nodes = {
            {
                n = G.UIT.R,
                config = { ref_table = parent, align = "cm", func = "joker_display_style_override" },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { id = "modifiers", ref_table = parent, align = "cm" },
                    },
                    {
                        n = G.UIT.R,
                        config = { id = "extra", ref_table = parent, align = "cm" },
                    },
                    {
                        n = G.UIT.R,
                        config = { id = "text", ref_table = parent, align = "cm" },
                    },
                    {
                        n = G.UIT.R,
                        config = { id = "reminder_text", ref_table = parent, align = "cm" },
                    }
                }
            },
        }
    }

    args.config = args.config or {}
    args.config.align = args.config.align or "bm"
    args.config.parent = parent
    args.config.offset = { x = 0, y = -0.1 }

    UIBox.init(self, args)

    self.states.collide.can = true
    self.name = "JokerDisplay"
    self.joker_display_type = args.type or "NORMAL"
    self.can_collapse = true

    self.text = self.UIRoot.children[1].children[3]
    self.has_text = false
    self.reminder_text = self.UIRoot.children[1].children[4]
    self.has_reminder_text = false
    self.extra = self.UIRoot.children[1].children[2]
    self.has_extra = false
    self.modifier_row = self.UIRoot.children[1].children[1]
    self.has_modifiers = false

    self.modifiers = {
        chips = nil,
        x_chips = nil,
        mult = nil,
        x_mult = nil,
        dollars = nil,
        e_mult = nil,
    }
end

function JokerDisplayBox:recalculate(from_update)
    if not from_update then return end
    if not (self.has_text or self.has_extra or self.has_modifiers) and self.has_reminder_text then
        self.text.config.minh = 0.4
    else
        self.text.config.minh = nil
    end

    if self.has_text then
        self.text.config.padding = 0.03
    else
        self.text.config.padding = nil
    end

    UIBox.recalculate(self)
    self:align_to_text()
end

function JokerDisplayBox:align_to_text()
    local y_value = self.T and self.T.y - (self.has_text and self.text.T.y or
        self.has_extra and self.extra.children[#self.extra.children] and self.extra.children[#self.extra.children].T and self.extra.children[#self.extra.children].T.y or
        self.has_modifiers and self.modifier_row.children[#self.modifier_row.children] and self.modifier_row.children[#self.modifier_row.children].T and self.modifier_row.children[#self.modifier_row.children].T.y or
        (self.T.y - self.alignment.offset.y))
    self.alignment.offset.y = y_value or self.alignment.offset.y
end

function JokerDisplayBox:add_text(nodes, config, custom_parent)
    for i = 1, #nodes do
        local display_object = JokerDisplay.create_display_object(custom_parent or self.parent, nodes[i], config)
        if display_object then
            self:add_child(display_object, self.text)
        end
    end
    self.has_text = #self.text.children > 0
end

function JokerDisplayBox:remove_text()
    self.has_text = false
    self:remove_children(self.text)
end

function JokerDisplayBox:add_reminder_text(nodes, config, custom_parent)
    for i = 1, #nodes do
        local display_object = JokerDisplay.create_display_object(custom_parent or self.parent, nodes[i], config)

        if display_object then
            self:add_child(display_object, self.reminder_text)
        end
    end
    self.has_reminder_text = #self.reminder_text.children > 0
end

function JokerDisplayBox:remove_reminder_text()
    self.has_reminder_text = false
    self:remove_children(self.reminder_text)
end

function JokerDisplayBox:add_extra(node_rows, config, custom_parent)
    for i = #node_rows, 1, -1 do
        local row_nodes = {}
        for j = 1, #node_rows[i] do
            local display_object = JokerDisplay.create_display_object(custom_parent or self.parent, node_rows[i][j],
                config)
            if display_object then
                table.insert(row_nodes, display_object)
            end
        end

        if #row_nodes > 0 then
            local extra_row = {
                n = G.UIT.R,
                config = { ref_table = custom_parent or self.parent, align = "cm", padding = 0.03 },
                nodes = row_nodes
            }
            self:add_child(extra_row, self.extra)
        end
    end
    self.has_extra = #self.extra.children > 0
end

function JokerDisplayBox:remove_extra()
    self.has_extra = false
    self:remove_children(self.extra)
end

function JokerDisplayBox:change_modifiers(modifiers, reset)
    local new_modifiers = {
        chips = modifiers.chips,
        x_chips = modifiers.x_chips,
        mult = modifiers.mult,
        x_mult = modifiers.x_mult,
        dollars = modifiers.dollars,
        e_mult = modifiers.e_mult,
    }

    local mod_keys = { "chips", "x_chips", "mult", "x_mult", "dollars", "e_mult" }
    local modifiers_changed = reset or false
    local has_modifiers = false

    for i = 1, #mod_keys do
        if (not not self.modifiers[mod_keys[i]]) ~= (not not new_modifiers[mod_keys[i]]) then
            modifiers_changed = true
        end
        self.modifiers[mod_keys[i]] = new_modifiers[mod_keys[i]]
        if self.modifiers[mod_keys[i]] then
            has_modifiers = true
        end
    end

    if modifiers_changed then
        self:remove_modifiers()
        if has_modifiers then
            self:add_modifiers()
        end
    end
end

function JokerDisplayBox:add_modifiers()
    self.has_modifiers = true

    local mod_nodes = {}

    if self.modifiers.dollars then
        local dollars_node = {}
        table.insert(dollars_node,
            JokerDisplay.create_display_object(self, { text = "+" .. localize('$'), colour = G.C.GOLD }))
        table.insert(dollars_node,
            JokerDisplay.create_display_object(self,
                { ref_table = "card.modifiers", ref_value = "dollars", colour = G.C.GOLD }))
        table.insert(mod_nodes, dollars_node)
    end

    if self.modifiers.e_mult then
        local emult_node = {}
        table.insert(emult_node,
            JokerDisplay.create_display_object(self,
                {
                    border_nodes = { { text = "^" },
                        { ref_table = "card.modifiers", ref_value = "e_mult" } },
                    border_colour = G.C.DARK_EDITION
                }))
        table.insert(mod_nodes, emult_node)
    end

    if self.modifiers.x_chips then
        local xchip_node = {}
        table.insert(xchip_node,
            JokerDisplay.create_display_object(self,
                {
                    border_nodes = { { text = "X" },
                        { ref_table = "card.modifiers", ref_value = "x_chips" } },
                    border_colour = G.C.CHIPS
                }))
        table.insert(mod_nodes, xchip_node)
    end

    if self.modifiers.x_mult then
        local xmult_node = {}
        table.insert(xmult_node,
            JokerDisplay.create_display_object(self,
                {
                    border_nodes = {
                        { text = "X" },
                        { ref_table = "card.modifiers", ref_value = "x_mult" }
                    }
                }
            ))
        table.insert(mod_nodes, xmult_node)
    end

    if self.modifiers.chips then
        local chip_node = {}
        table.insert(chip_node, JokerDisplay.create_display_object(self, { text = "+", colour = G.C.CHIPS }))
        table.insert(chip_node,
            JokerDisplay.create_display_object(self,
                { ref_table = "card.modifiers", ref_value = "chips", colour = G.C.CHIPS }))
        table.insert(mod_nodes, chip_node)
    end

    if self.modifiers.mult then
        local mult_node = {}
        table.insert(mult_node, JokerDisplay.create_display_object(self, { text = "+", colour = G.C.MULT }))
        table.insert(mult_node,
            JokerDisplay.create_display_object(self,
                { ref_table = "card.modifiers", ref_value = "mult", colour = G.C.MULT }))
        table.insert(mod_nodes, mult_node)
    end

    local row_index = 1
    local mod_rows = {}
    for i = 1, #mod_nodes do
        if mod_rows[row_index] and #mod_rows[row_index] >= 2 then
            row_index = row_index + 1
        end
        if not mod_rows[row_index] then
            mod_rows[row_index] = {}
        end
        local mod_column = {
            n = G.UIT.C,
            config = { ref_table = self.parent, align = "cm", padding = 0.03 },
            nodes = mod_nodes[i]
        }
        table.insert(mod_rows[row_index], mod_column)
    end

    for i = 1, #mod_rows do
        local extra_row = {
            n = G.UIT.R,
            config = { ref_table = self.parent, align = "cm", padding = 0.03 },
            nodes = mod_rows[i]
        }
        self:add_child(extra_row, self.modifier_row)
    end
end

function JokerDisplayBox:remove_modifiers()
    self.has_modifiers = false
    self:remove_children(self.modifier_row)
end

function JokerDisplayBox:remove_children(node)
    if not node.children then
        return
    end
    remove_all(node.children)
    node.children = {}
    self:recalculate(true)
end

function JokerDisplayBox:add_child(node, parent)
    UIBox.add_child(self, node, parent)
    self:recalculate(true)
end

function JokerDisplayBox:has_info()
    return self.has_text or self.has_extra or self.has_modifiers or self.has_reminder_text
end

function JokerDisplayBox:move_wh(dt)
    UIBox.move_wh(self, dt or G.real_dt or 0)
end

function Card:joker_display_has_info()
    return (self.children.joker_display and self.children.joker_display:has_info()) or
        (self.children.joker_display_small and self.children.joker_display_small:has_info())
end

local uielement_update_text_ref = UIElement.update_text
function UIElement:update_text()
    if self.UIBox.name and self.UIBox.name == "JokerDisplay" then
        if self.config and self.config.text and not self.config.text_drawable then
            self.config.lang = self.config.lang or G.LANG
            self.config.text_drawable = love.graphics.newText(self.config.lang.font.FONT, { G.C.WHITE, self.config.text })
        end
        local card = self.UIBox.parent
        if JokerDisplay.config.enabled and (card.joker_display_values and not card.joker_display_values.disabled) and self.config.ref_table then
            local formatted_text = JokerDisplay.text_format(self.config.ref_table[self.config.ref_value], self)
            local prev_value = self.config.prev_value_joker_display or
                JokerDisplay.text_format(self.config.prev_value, self)
            if formatted_text ~= prev_value then
                self.config.text = formatted_text
                self.config.text_drawable:set(self.config.text)
                if not self.config.no_recalc and prev_value and string.len(prev_value) ~= string.len(self.config.text) then
                    self.config.prev_value_joker_display = formatted_text
                    self.UIBox:recalculate(true)
                end
                self.config.prev_value = formatted_text
                self.config.prev_value_joker_display = formatted_text
            end
        end
    else
        uielement_update_text_ref(self)
    end
end

function JokerDisplayBox:calculate_xywh(node, _T, recalculate, _scale)
    node.ARGS.xywh_node_trans = node.ARGS.xywh_node_trans or {}
    local _nt = node.ARGS.xywh_node_trans

    if node.UIT == G.UIT.T then
        _nt.x, _nt.y, _nt.w, _nt.h =
            _T.x,
            _T.y,
            node.config.w or (node.config.object and node.config.object.T.w),
            node.config.h or (node.config.object and node.config.object.T.h)

        node.config.text_drawable = nil
        local scale = node.config.scale or 1
        local card = self.parent
        if ((JokerDisplay.config.enabled and card.joker_display_values and not card.joker_display_values.disabled) or not node.config.text) and node.config.ref_table and node.config.ref_value then
            node.config.text = JokerDisplay.text_format(node.config.ref_table[node.config.ref_value], node)
            if node.config.func and not recalculate then G.FUNCS[node.config.func](node) end
        end
        if not node.config.text then node.config.text = '[UI ERROR]' end
        node.config.lang = node.config.lang or G.LANG

        if type(node.config.text) ~= "string" then node.config.text = "" .. node.config.text end

        local tx = node.config.lang.font.FONT:getWidth(node.config.text) * node.config.lang.font.squish * scale *
            G.TILESCALE * node.config.lang.font.FONTSCALE
        local ty = node.config.lang.font.FONT:getHeight() * scale * G.TILESCALE * node.config.lang.font.FONTSCALE *
            node.config.lang.font.TEXT_HEIGHT_SCALE
        if node.config.vert then
            local thunk = tx; tx = ty; ty = thunk
        end
        _nt.x, _nt.y, _nt.w, _nt.h =
            _T.x,
            _T.y,
            tx / (G.TILESIZE * G.TILESCALE),
            ty / (G.TILESIZE * G.TILESCALE)

        node.content_dimensions = node.content_dimensions or {}
        node.content_dimensions.w = _T.w
        node.content_dimensions.h = _T.h
        node:set_values(_nt, recalculate)

        return _nt.w, _nt.h
    else
        return UIBox.calculate_xywh(self, node, _T, recalculate, _scale)
    end
end

--- HELPER FUNCTIONS

JokerDisplay.text_format = function(text, node)
    if not text then return text or 'ERROR' end
    if type(text) == "function" then text = text() end

    local card = node.UIBox.parent

    text = JokerDisplay.retrigger_format(text, node, card)
    text = JokerDisplay.number_format(text)

    return text
end

JokerDisplay.retrigger_format = function(num, node, card)
    if (type(num) ~= 'number' and type(num) ~= 'table') then return num or '' end

    local retrigger_type = node.config.retrigger_type
    local triggers = card.joker_display_values and card.joker_display_values.trigger_count or 1

    if not retrigger_type then
        return num
    end
    if type(retrigger_type) == "function" then
        return retrigger_type(num, triggers)
    end
    if retrigger_type == "add" or retrigger_type == "+" then
        return num + triggers - 1
    end
    if retrigger_type == "mult" or retrigger_type == "multiply" or retrigger_type == "*" then
        return num * triggers
    end
    if retrigger_type == "exp" or retrigger_type == "exponentiate" or retrigger_type == "^" then
        return num ^ (triggers > 0 and triggers or 1)
    end

    return num
end

---Creates an object with JokerDisplay configurations.
---@param card table Reference card.
---@param display_config {text: string?, ref_table: string?, ref_value: string?, scale: number?, colour: table?, border_nodes: table?, border_colour: table?, dynatext: table?, retrigger_type: function|string?} Node configuration.
---@param defaults_config? {colour: table?, scale: number?} Defaults for all text objects.
---@return table? # Display object.
JokerDisplay.create_display_object = function(card, display_config, defaults_config)
    if not display_config or not next(display_config) then
        return nil
    end
    local default_text_colour = defaults_config and defaults_config.colour or G.C.UI.TEXT_LIGHT
    local default_text_scale = defaults_config and defaults_config.scale or 0.4
    local default_text_font = defaults_config and defaults_config.font or nil

    local node = {}
    if display_config.dynatext then
        return {
            n = G.UIT.O,
            config = {
                object = DynaText(
                    JokerDisplay.deepcopy(display_config.dynatext)
                )
            }
        }
    end
    if display_config.border_nodes then
        local inside_nodes = {}
        for i = 1, #display_config.border_nodes do
            table.insert(inside_nodes,
                JokerDisplay.create_display_object(card, display_config.border_nodes[i], defaults_config))
        end
        return JokerDisplay.create_display_border_text_object(inside_nodes, display_config.border_colour or G.C.XMULT)
    end
    if display_config.ref_value and display_config.ref_table then
        local table_path = JokerDisplay.strsplit(display_config.ref_table, ".")
        local ref_table = table_path[1] == "card" and card or _G[table_path[1]]
        for i = 2, #table_path do
            if ref_table[table_path[i]] then
                ref_table = ref_table[table_path[i]]
            end
        end
        local colour = display_config.colour or default_text_colour
        if colour.ref_table then
            colour = colour.ref_table[colour.ref_value]
        end
        return JokerDisplay.create_display_text_object({
            ref_table = ref_table,
            ref_value = display_config.ref_value,
            colour = colour,
            scale = display_config.scale or default_text_scale,
            font = display_config.font or default_text_font,
            retrigger_type = display_config.retrigger_type
        })
    end
    if display_config.text then
        local colour = display_config.colour or default_text_colour
        if colour.ref_table then
            colour = colour.ref_table[colour.ref_value]
        end
        return JokerDisplay.create_display_text_object({
            text = display_config.text,
            colour = colour,
            scale = display_config.scale or default_text_scale,
            font = display_config.font or default_text_font,
            retrigger_type = display_config.retrigger_type
        })
    end
    return node
end

---Creates a G.UIT.T object with JokerDisplay configurations for text display.
---@param config {text: string?, ref_table: table?, ref_value: string?, scale: number?, colour: table?, retrigger_type: function|string? }
---@return table
JokerDisplay.create_display_text_object = function(config)
    local text_node = {}
    if config.ref_table then
        text_node = { n = G.UIT.T, config = { ref_table = config.ref_table, ref_value = config.ref_value, scale = config.scale or 0.4, colour = config.colour or G.C.UI.TEXT_LIGHT, font = ((SMODS or {}).Fonts or {})[config.font] or G.FONTS[tonumber(config.font)], retrigger_type = config.retrigger_type } }
    else
        text_node = { n = G.UIT.T, config = { text = config.text or "ERROR", scale = config.scale or 0.4, colour = config.colour or G.C.UI.TEXT_LIGHT, font = ((SMODS or {}).Fonts or {})[config.font] or G.FONTS[tonumber(config.font)], retrigger_type = config.retrigger_type } }
    end
    return text_node
end

---Creates a G.UIT.C object with JokerDisplay configurations for text borders (e.g. for XMULT).
---@param nodes table Nodes contained inside the border.
---@param border_color table Color of the border.
---@return table
JokerDisplay.create_display_border_text_object = function(nodes, border_color)
    return {
        n = G.UIT.C,
        config = { colour = border_color, r = 0.05, padding = 0.03, res = 0.15 },
        nodes = nodes
    }
end

-- Joker slot count over display
local cardarea_draw_ref = CardArea.draw
function CardArea:draw(...)
    cardarea_draw_ref(self, ...)
    if self == G.jokers then
        if not self.children.joker_display_count then
            self.children.joker_display_count = UIBox {
                definition =
                { n = G.UIT.ROOT, config = { align = 'cm', colour = G.C.CLEAR }, nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = 'cl', padding = 0.03, no_fill = true },
                        nodes = {
                            { n = G.UIT.B, config = { w = 0.1, h = 0.1 } },
                            { n = G.UIT.T, config = { ref_table = self.config, ref_value = 'card_count', scale = 0.3, colour = G.C.WHITE } },
                            { n = G.UIT.T, config = { text = '/', scale = 0.3, colour = G.C.WHITE } },
                            { n = G.UIT.T, config = { ref_table = self.config.card_limits, ref_value = 'total_slots', scale = 0.3, colour = G.C.WHITE } },
                            { n = G.UIT.B, config = { w = 0.1, h = 0.1 } }
                        }
                    }
                } },
                config = { align = 'cm', offset = { x = 0, y = 0 }, major = self.children.area_uibox.UIRoot.children[2], parent = self.children.area_uibox.UIRoot.children[2], instance_type = "ALERT" }
            }
        end

        self.children.joker_display_count.T = self.children.area_uibox.UIRoot.children[2].T
        self.children.joker_display_count.states.visible = JokerDisplay.config.joker_count and not G.OVERLAY_MENU
    end
end
