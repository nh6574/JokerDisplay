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
        x_chips_text = nil,
        mult = nil,
        x_mult = nil,
        x_mult_text = nil,
        dollars = nil,
    }
end

function JokerDisplayBox:recalculate()
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

function JokerDisplayBox:add_text(nodes, config, custom_parent)
    self.has_text = true
    for i = 1, #nodes do
        self:add_child(JokerDisplay.create_display_object(custom_parent or self.parent, nodes[i], config), self.text)
    end
end

function JokerDisplayBox:remove_text()
    self.has_text = false
    self:remove_children(self.text)
end

function JokerDisplayBox:add_reminder_text(nodes, config, custom_parent)
    self.has_reminder_text = true
    for i = 1, #nodes do
        self:add_child(JokerDisplay.create_display_object(custom_parent or self.parent, nodes[i], config),
            self.reminder_text)
    end
end

function JokerDisplayBox:remove_reminder_text()
    self.has_reminder_text = false
    self:remove_children(self.reminder_text)
end

function JokerDisplayBox:add_extra(node_rows, config, custom_parent)
    self.has_extra = true
    for i = #node_rows, 1, -1 do
        local row_nodes = {}
        for j = 1, #node_rows[i] do
            table.insert(row_nodes,
                JokerDisplay.create_display_object(custom_parent or self.parent, node_rows[i][j], config))
        end
        local extra_row = {
            n = G.UIT.R,
            config = { ref_table = parent, align = "cm", padding = 0.03 },
            nodes = row_nodes
        }
        self:add_child(extra_row, self.extra)
    end
end

function JokerDisplayBox:remove_extra()
    self.has_extra = false
    self:remove_children(self.extra)
end

function JokerDisplayBox:change_modifiers(modifiers, reset)
    local new_modifiers = {
        chips = modifiers.chips,     --or not reset and self.modifiers.chips or nil,
        x_chips = modifiers.x_chips, --or not reset and self.modifiers.x_chips or nil,
        mult = modifiers.mult,       --or not reset and self.modifiers.mult or nil,
        x_mult = modifiers.x_mult,   --or not reset and self.modifiers.x_mult or nil,
        dollars = modifiers.dollars, -- not reset and self.modifiers.dollars or nil,
    }

    local mod_keys = { "chips", "x_chips", "mult", "x_mult", "dollars" }
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

    self.modifiers.x_chips_text = self.modifiers.x_chips and tonumber(string.format("%.2f", self.modifiers.x_chips)) or
        nil
    self.modifiers.x_mult_text = self.modifiers.x_mult and tonumber(string.format("%.2f", self.modifiers.x_mult)) or nil

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

    if self.modifiers.chips then
        local chip_node = {}
        table.insert(chip_node, JokerDisplay.create_display_object(self, { text = "+", colour = G.C.CHIPS }))
        table.insert(chip_node,
            JokerDisplay.create_display_object(self,
                { ref_table = "card.modifiers", ref_value = "chips", colour = G.C.CHIPS }))
        table.insert(mod_nodes, chip_node)
    end

    if self.modifiers.x_chips then
        local xchip_node = {}
        table.insert(xchip_node,
            JokerDisplay.create_display_object(self,
                {
                    border_nodes = { { text = "X" },
                        { ref_table = "card.modifiers", ref_value = "x_chips_text" } },
                    border_colour = G.C.CHIPS
                }))
        table.insert(mod_nodes, xchip_node)
    end

    if self.modifiers.mult then
        local mult_node = {}
        table.insert(mult_node, JokerDisplay.create_display_object(self, { text = "+", colour = G.C.MULT }))
        table.insert(mult_node,
            JokerDisplay.create_display_object(self,
                { ref_table = "card.modifiers", ref_value = "mult", colour = G.C.MULT }))
        table.insert(mod_nodes, mult_node)
    end

    if self.modifiers.x_mult then
        local xmult_node = {}
        table.insert(xmult_node,
            JokerDisplay.create_display_object(self,
                {
                    border_nodes = {
                        { text = "X" },
                        { ref_table = "card.modifiers", ref_value = "x_mult_text" }
                    }
                }
            ))
        table.insert(mod_nodes, xmult_node)
    end

    if self.modifiers.dollars then
        local dollars_node = {}
        table.insert(dollars_node,
            JokerDisplay.create_display_object(self, { text = "+" .. localize('$'), colour = G.C.GOLD }))
        table.insert(dollars_node,
            JokerDisplay.create_display_object(self,
                { ref_table = "card.modifiers", ref_value = "dollars", colour = G.C.GOLD }))
        table.insert(mod_nodes, dollars_node)
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
            config = { ref_table = self, align = "cm", padding = 0.03 },
            nodes = mod_nodes[i]
        }
        table.insert(mod_rows[row_index], mod_column)
    end

    for i = 1, #mod_rows do
        local extra_row = {
            n = G.UIT.R,
            config = { ref_table = self, align = "cm", padding = 0.03 },
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
    self:recalculate()
end

function JokerDisplayBox:align_to_text()
    local y_value = self.T and self.T.y - (self.has_text and self.text.T.y or
        self.has_extra and self.extra.children[#self.extra.children] and self.extra.children[#self.extra.children].T and self.extra.children[#self.extra.children].T.y or
        self.has_modifiers and self.modifier_row.children[#self.modifier_row.children] and self.modifier_row.children[#self.modifier_row.children].T and self.modifier_row.children[#self.modifier_row.children].T.y or
        (self.T.y - self.alignment.offset.y))
    self.alignment.offset.y = y_value or self.alignment.offset.y
end

function JokerDisplayBox:has_info()
    return self.has_text or self.has_extra or self.has_modifiers or self.has_reminder_text
end

function Card:joker_display_has_info()
    return (self.children.joker_display and self.children.joker_display:has_info()) or
        (self.children.joker_display_small and self.children.joker_display_small:has_info())
end

--- HELPER FUNCTIONS

---Creates an object with JokerDisplay configurations.
---@param card table Reference card
---@param display_config {text: string?, ref_table: string?, ref_value: string?, scale: number?, colour: table?, border_nodes: table?, border_colour: table?, dynatext: table?} Node configuration
---@param defaults_config? {colour: table?, scale: number?} Defaults for all text objects
---@return table
JokerDisplay.create_display_object = function(card, display_config, defaults_config)
    local default_text_colour = defaults_config and defaults_config.colour or G.C.UI.TEXT_LIGHT
    local default_text_scale = defaults_config and defaults_config.scale or 0.4

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
        return JokerDisplay.create_display_text_object({
            ref_table = ref_table,
            ref_value = display_config.ref_value,
            colour = display_config.colour or default_text_colour,
            scale = display_config.scale or default_text_scale
        })
    end
    if display_config.text then
        return JokerDisplay.create_display_text_object({
            text = display_config.text,
            colour = display_config.colour or default_text_colour,
            scale = display_config.scale or default_text_scale
        })
    end
    return node
end

---Creates a G.UIT.T object with JokerDisplay configurations for text display.
---@param config {text: string?, ref_table: table?, ref_value: string?, scale: number?, colour: table?}
---@return table
JokerDisplay.create_display_text_object = function(config)
    local text_node = {}
    if config.ref_table then
        text_node = { n = G.UIT.T, config = { ref_table = config.ref_table, ref_value = config.ref_value, scale = config.scale or 0.4, colour = config.colour or G.C.UI.TEXT_LIGHT } }
    else
        text_node = { n = G.UIT.T, config = { text = config.text or "ERROR", scale = config.scale or 0.4, colour = config.colour or G.C.UI.TEXT_LIGHT } }
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