---DISPLAY BOX CLASS
local function create_compat_node(definition, parent, box)
    local node = {
        UIT = definition.n,
        n = definition.n,
        config = definition.config or {},
        children = {},
        parent = parent,
        UIBox = box,
        T = { x = 0, y = 0, w = 0, h = 0 },
        states = { visible = true, collide = { can = false } },
    }
    for _, child in ipairs(definition.nodes or {}) do
        if child then
            table.insert(node.children, create_compat_node(child, node, box))
        end
    end
    return node
end

local function remove_compat_node(node)
    for _, child in ipairs(node.children or {}) do remove_compat_node(child) end
    if node.UIT == G.UIT.O and node.config.object and node.config.object.remove then
        node.config.object:remove()
        node.config.object = nil
    end
    node.children = {}
end

local function draw_pixel_rect(x, y, w, h, config)
    local shortest = math.min(w, h)
    local resolution = config.res or (shortest > 3.5 and 0.8 or shortest > 0.3 and 0.6 or 0.15)
    local step = resolution / G.TILESIZE
    local right = w - 4 * step
    local bottom = h - 4 * step
    love.graphics.polygon("fill",
        x + right / 2, y + bottom / 2,
        x, y + 4 * step,
        x + step, y + 4 * step,
        x + step, y + 2 * step,
        x + 2 * step, y + 2 * step,
        x + 2 * step, y + step,
        x + 4 * step, y + step,
        x + 4 * step, y,
        x + right, y,
        x + right, y + step,
        x + right + 2 * step, y + step,
        x + right + 2 * step, y + 2 * step,
        x + right + 3 * step, y + 2 * step,
        x + right + 3 * step, y + 4 * step,
        x + w, y + 4 * step,
        x + w, y + bottom,
        x + right + 3 * step, y + bottom,
        x + right + 3 * step, y + bottom + 2 * step,
        x + right + 2 * step, y + bottom + 2 * step,
        x + right + 2 * step, y + bottom + 3 * step,
        x + right, y + bottom + 3 * step,
        x + right, y + h,
        x + 4 * step, y + h,
        x + 4 * step, y + bottom + 3 * step,
        x + 2 * step, y + bottom + 3 * step,
        x + 2 * step, y + bottom + 2 * step,
        x + step, y + bottom + 2 * step,
        x + step, y + bottom,
        x, y + bottom,
        x, y + 4 * step
    )
end

local function disable_interaction(object)
    for _, state in ipairs({ "hover", "click", "collide", "drag", "release_on" }) do
        object.states[state].can = false
    end
end

local function text_size(font, text, scale)
    return font.FONT:getWidth(text) * font.squish * scale * font.FONTSCALE / G.TILESIZE,
        font.FONT:getHeight() * scale * font.FONTSCALE * font.TEXT_HEIGHT_SCALE / G.TILESIZE
end

local function draw_text(drawable, font, scale, x, y)
    love.graphics.draw(drawable,
        x + font.TEXT_OFFSET.x * scale * font.FONTSCALE / G.TILESIZE,
        y + font.TEXT_OFFSET.y * scale * font.FONTSCALE / G.TILESIZE,
        0,
        scale * font.squish * font.FONTSCALE / G.TILESIZE,
        scale * font.FONTSCALE / G.TILESIZE)
end

local function utf8_length(text)
    local count = 0
    for _ in utf8.chars(text) do count = count + 1 end
    return count
end

--caching of dynatext strings for transitions
JokerDisplayDynaText = Moveable:extend()
function JokerDisplayDynaText:init(config)
    self.config = config
    self.joker_display_lightweight = true
    self.colours = config.colours or { G.C.RED }
    if #self.colours == 0 then self.colours = { G.C.UI.TEXT_LIGHT } end
    self.scale = config.scale or 1
    self.font = config.font or G.LANG.font
    self.focused_string = 1
    self.strings = {}
    for index = 1, #(config.string or {}) do
        self:_update_entry(index, true)
    end
    if #self.strings == 0 then
        self.strings[1] = { string = "ERROR", font = self.font, letters = { { char = "E" } } }
    end
    self.drawable = love.graphics.newText(self.font.FONT)
    self:_set_drawable()
    local width, height = self:_measure()
    Moveable.init(self, 0, 0, width, height)
    disable_interaction(self)
    self.next_cycle = G.TIMERS.REAL + (config.pop_delay or 1.5)
end

function JokerDisplayDynaText:_update_entry(index, first_pass)
    local entry = self.config.string[index]
    local value, prefix, suffix = entry, "", ""
    local colour, outer_colour, font, scale
    if type(entry) == "table" then
        value = entry.ref_table and entry.ref_table[entry.ref_value] or entry.string
        prefix, suffix = entry.prefix or "", entry.suffix or ""
        colour, outer_colour = entry.colour, entry.outer_colour
        font, scale = entry.font, entry.scale
    end
    local inner = tostring(value == nil and "" or value)
    local text = prefix .. inner .. suffix
    local current = self.strings[index]
    if not first_pass and current and current.string == text and current.font == (font or self.font) and
        current.entry_colour == colour and current.outer_colour == outer_colour and current.entry_scale == scale then
        return false
    end
    local letters, prefix_length, inner_length = {}, utf8_length(prefix), utf8_length(inner)
    for letter_index, character in utf8.chars(text) do
        local is_outer = letter_index <= prefix_length or letter_index > prefix_length + inner_length
        letters[#letters + 1] = {
            char = character,
            colour = is_outer and outer_colour or colour,
        }
    end
    self.strings[index] = {
        string = text,
        font = font or self.font,
        letters = letters,
        condition = type(entry) == "table" and entry.condition or nil,
        entry_colour = colour,
        outer_colour = outer_colour,
        entry_scale = scale,
    }
    return true
end

function JokerDisplayDynaText:_entry_scale()
    return self.strings[self.focused_string].entry_scale or 1
end

function JokerDisplayDynaText:_coloured_text()
    local result = {}
    for index, letter in ipairs(self.strings[self.focused_string].letters) do
        table.insert(result, letter.colour or self.colours[index % #self.colours + 1])
        table.insert(result, letter.char)
    end
    return result
end

function JokerDisplayDynaText:_set_drawable()
    local focused = self.strings[self.focused_string]
    if not self.drawable or self.drawable:getFont() ~= focused.font.FONT then
        self.drawable = love.graphics.newText(focused.font.FONT)
    end
    self.drawable:set(self:_coloured_text())
end

function JokerDisplayDynaText:_measure()
    local focused = self.strings[self.focused_string]
    local font, scale = focused.font, self.scale * self:_entry_scale()
    return text_size(font, focused.string, scale)
end

function JokerDisplayDynaText:_select(index)
    if not index or not self.strings[index] or index == self.focused_string then return false end
    self.focused_string = index
    self:_set_drawable()
    local width, height = self:_measure()
    if self.T and (width ~= self.T.w or height ~= self.T.h) then
        self.T.w, self.T.h = width, height
        self.ui_object_updated = true
    end
    return true
end

function JokerDisplayDynaText:update()
    local focused_changed = false
    for index = 1, #self.config.string do
        local changed = self:_update_entry(index)
        focused_changed = focused_changed or (changed and index == self.focused_string)
    end
    if focused_changed then
        self:_set_drawable()
        local width, height = self:_measure()
        self.T.w, self.T.h = width, height
        self.ui_object_updated = true
    end
    if #self.strings < 2 or G.TIMERS.REAL < self.next_cycle then return end
    local delay = math.max(self.config.pop_delay or 1.5, 0.001)
    repeat self.next_cycle = self.next_cycle + delay until self.next_cycle > G.TIMERS.REAL
    local next_index = self.focused_string
    repeat
        next_index = self.config.random_element and math.random(1, #self.strings) or
            (next_index % #self.strings) + 1
    until not self.strings[next_index].condition or self.strings[next_index].condition()
    self:_select(next_index)
end

JokerDisplayDynaTextView = Moveable:extend()
function JokerDisplayDynaTextView:init(source, scale)
    self.source = source
    self.scale = scale or source.scale
    self.font = source.font
    local width, height = self:_measure()
    Moveable.init(self, 0, 0, width, height)
    disable_interaction(self)
end

function JokerDisplayDynaTextView:_measure()
    local focused = self.source.strings[self.source.focused_string]
    local font = focused.font
    local scale = self.scale * (focused.entry_scale or 1)
    return text_size(font, focused.string, scale)
end

function JokerDisplayDynaTextView:update()
    local width, height = self:_measure()
    if width ~= self.T.w or height ~= self.T.h then
        self.T.w, self.T.h = width, height
        self.ui_object_updated = true
    end
end

function JokerDisplayDynaTextView:draw()
    local focused = self.source.strings[self.source.focused_string]
    local font = focused.font
    local scale = self.scale * (focused.entry_scale or 1)
    prep_draw(self, 1)
    love.graphics.setColor(G.C.WHITE)
    draw_text(self.source.drawable, font, scale, 0, 0)
    love.graphics.pop()
end

function JokerDisplayDynaText:draw()
    local focused = self.strings[self.focused_string]
    local font = focused.font
    local scale = self.scale * (focused.entry_scale or 1)
    prep_draw(self, 1)
    love.graphics.setColor(G.C.WHITE)
    draw_text(self.drawable, font, scale, 0, 0)
    love.graphics.pop()
end

local function can_use_lightweight_dynatext(config)
    if config.min_cycle_time ~= 0 or type(config.string) ~= "table" then return false end
    if config.text_effect or config.shaders or config.shadow or config.rotate or config.float or
        config.bump or config.pulse or config.quiver or config.marquee or config.spacing or
        config.text_outline or config.scale_function or config.text_rot then return false end
    for _, value in ipairs(config.string) do
        local value_type = type(value)
        if value_type ~= "string" and value_type ~= "number" then
            if value_type ~= "table" or (value.string == nil and not (value.ref_table and value.ref_value)) then
                return false
            end
        end
    end
    return true
end

JokerDisplayBox = Moveable:extend()
function JokerDisplayBox:init(parent, func, args)
    args = args or {}

    local definition = args.definition or {
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

    self.definition = definition
    self.config = args.config or {}
    self.config.align = self.config.align or "bm"
    self.config.parent = parent
    self.config.offset = { x = 0, y = -0.1 }
    self.parent = parent

    Moveable.init(self, 0, 0, 2, 0.6)
    self:set_alignment({
        major = parent,
        type = self.config.align,
        bond = self.config.bond or "Strong",
        offset = self.config.offset,
    })
    self:set_role({ wh_bond = "Weak", scale_bond = "Strong" })
    self.states.collide.can = true
    self.name = "JokerDisplay"
    self.joker_display_type = args.type or "NORMAL"
    self.can_collapse = true

    self.UIRoot = create_compat_node(definition, nil, self)
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
    self._layout_dirty = true
    self:recalculate(true)
end

function JokerDisplayBox:recalculate(from_update)
    if not from_update then return end
    if self._styling then self._layout_dirty = true end
    local old_min_height = self.text.config.minh
    local old_padding = self.text.config.padding
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
    if old_min_height ~= self.text.config.minh or old_padding ~= self.text.config.padding then
        self._layout_dirty = true
    end
    local style_node = self.UIRoot.children[1]
    if not self._styling and style_node and style_node.config.func and G.FUNCS[style_node.config.func] then
        self._styling = true
        G.FUNCS[style_node.config.func](style_node)
        self._styling = nil
    end
    self:_refresh_text(self.UIRoot)
    if self._layout_dirty then self:_calculate_layout() end
    self:has_info()
end

function JokerDisplayBox:align_to_text()
    local anchor = self.has_text and self.text or
        self.has_extra and self.extra.children[#self.extra.children] or
        self.has_modifiers and self.modifier_row.children[#self.modifier_row.children]
    self.alignment.offset.y = -((anchor and anchor.T.y) or 0) - 0.1
    self:align_to_major()
end

function JokerDisplayBox:_font(node)
    return node.config.font or G.LANG.font
end

function JokerDisplayBox:_text(node)
    local config = node.config
    local value = config.text
    if config.ref_table and config.ref_value then value = config.ref_table[config.ref_value] end
    return JokerDisplay.text_format(value, node)
end

function JokerDisplayBox:_refresh_text(node)
    local changed = false
    if node.UIT == G.UIT.T then
        local text = self:_text(node)
        if text ~= node._text then
            local font = self:_font(node)
            local width = font.FONT:getWidth(text)
            changed = node._source_width ~= width
            node._source_width = width
            node._text = text
            node.config.text = text
            node.config.prev_value = text
            node.config.prev_value_joker_display = text
            if node._drawable then node._drawable:set(text) else
                node._drawable = love.graphics.newText(font.FONT, text)
            end
        end
    elseif node.UIT == G.UIT.O and node.config.object then
        local object = node.config.object
        local focused_index = object.focused_string or 1
        local focused = object.strings and object.strings[focused_index]
        local text = focused and focused.string
        if text and (text ~= node._text or focused_index ~= node._focused_string) then
            node._text = tostring(text)
            node._focused_string = focused_index
            node._font = focused.font or object.font or G.LANG.font
            node._object_scale = (object.scale or 1) * (focused.entry_scale or 1)
            local width = node._font.FONT:getWidth(node._text) * node._object_scale
            changed = node._source_width ~= width
            node._source_width = width
            local coloured_text = {}
            local colours = object.colours or { G.C.UI.TEXT_LIGHT }
            if #colours == 0 then colours = { G.C.UI.TEXT_LIGHT } end
            for index, letter in ipairs(focused.letters or {}) do
                local colour = letter.prefix or letter.suffix or letter.colour or colours[index % #colours + 1]
                table.insert(coloured_text, colour)
                table.insert(coloured_text, letter.char)
            end
            if #coloured_text == 0 then coloured_text = { colours[1], node._text } end
            node._object_colour = G.C.WHITE
            if object.joker_display_lightweight then
                node._drawable = object.drawable
            elseif node._drawable then
                node._drawable:set(coloured_text)
            else
                node._drawable = love.graphics.newText(node._font.FONT, coloured_text)
            end
        end
    end
    for _, child in ipairs(node.children or {}) do
        changed = self:_refresh_text(child) or changed
    end
    self._layout_dirty = self._layout_dirty or changed
    return changed
end

function JokerDisplayBox:_measure(node, scale)
    scale = scale or 1
    node._layout_scale = scale
    local config = node.config
    local padding = (config.padding or 0) * scale
    if node.UIT == G.UIT.T then
        local font = self:_font(node)
        local text_scale = (config.scale or 0.4) * scale
        node._render_scale = scale
        node.T.w, node.T.h = text_size(font, node._text or "", text_scale)
        return node.T.w, node.T.h
    elseif node.UIT == G.UIT.O and config.object then
        node._render_scale = scale
        if node._drawable then
            local font = node._font or G.LANG.font
            local text_scale = (node._object_scale or 1) * scale
            node.T.w, node.T.h = text_size(font, node._text or "", text_scale)
        else
            node.T.w = (config.w or config.object.T.w or 0) * scale
            node.T.h = (config.h or config.object.T.h or 0) * scale
        end
        return node.T.w, node.T.h
    end
    local content_w, content_h = 0, 0
    for _, child in ipairs(node.children) do
        local child_w, child_h = self:_measure(child, scale)
        if child.UIT == G.UIT.R then
            content_w = math.max(content_w, child_w)
            content_h = content_h + child_h + padding
        else
            content_w = content_w + child_w + padding
            content_h = math.max(content_h, child_h)
        end
    end
    if #node.children > 0 then
        if node.children[#node.children].UIT == G.UIT.R then content_h = content_h - padding else content_w = content_w - padding end
    end
    node.T.w = math.max((config.minw or 0) * scale, content_w + padding * 2)
    node.T.h = math.max((config.minh or 0) * scale, content_h + padding * 2)
    return node.T.w, node.T.h
end

function JokerDisplayBox:_place(node, x, y)
    node.T.x, node.T.y = x, y
    local padding = (node.config.padding or 0) * (node._layout_scale or 1)
    local cursor_x, cursor_y = x + padding, y + padding
    for _, child in ipairs(node.children or {}) do
        if child.UIT == G.UIT.R then
            self:_place(child, x + (node.T.w - child.T.w) / 2, cursor_y)
            cursor_y = cursor_y + child.T.h + padding
        else
            self:_place(child, cursor_x, y + (node.T.h - child.T.h) / 2)
            cursor_x = cursor_x + child.T.w + padding
        end
    end
end

function JokerDisplayBox:_calculate_layout()
    local root = self.UIRoot
    local natural_w = self:_measure(root, 1)
    local maxw = root.config.maxw or natural_w
    local scale = natural_w > maxw and maxw / natural_w or 1
    root._layout_scale = scale
    if scale < 1 then self:_measure(root, scale) end
    self:_place(root, 0, 0)
    self.T.w, self.T.h = root.T.w, root.T.h
    self._layout_dirty = false
    self:align_to_text()
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
    for _, child in ipairs(node.children) do remove_compat_node(child) end
    node.children = {}
    self._layout_dirty = true
    self:recalculate(true)
end

function JokerDisplayBox:add_child(node, parent)
    table.insert(parent.children, create_compat_node(node, parent, self))
    self._layout_dirty = true
    self:recalculate(true)
end

function JokerDisplayBox:has_info()
    local has_info = self.has_text or self.has_extra or self.has_modifiers or self.has_reminder_text
    local values = self.parent and self.parent.joker_display_values
    if values and self.joker_display_type ~= "DEBUFF" then
        values.has_info = values.has_info or {}
        values.has_info[self.joker_display_type] = has_info
    end
    return has_info
end

function JokerDisplayBox:move_wh(dt)
    Moveable.move_wh(self, dt or G.real_dt or 0)
end

function JokerDisplayBox:get_UIE_by_ID(id, node)
    node = node or self.UIRoot
    if node.config and node.config.id == id then return node end
    for _, child in ipairs(node.children or {}) do
        local found = self:get_UIE_by_ID(id, child)
        if found then return found end
    end
end

function JokerDisplayBox:_is_visible()
    local card = self.parent
    if not card or not card.joker_display_values then return false end
    if not JokerDisplay.config.enabled or card.joker_display_values.disabled or card.facing == "back" then return false end
    if JokerDisplay.config.hide_empty and not card:joker_display_has_info() then return false end
    if self.joker_display_type == "DEBUFF" then return card.debuff end
    if card.debuff then return false end
    if self.joker_display_type == "SMALL" then return card.joker_display_values.small end
    return not card.joker_display_values.small
end

function JokerDisplayBox:update(dt)
    local visible = self:_is_visible()
    self.states.visible = visible
    self.states.collide.can = visible and self.joker_display_type ~= "DEBUFF"
    if visible then
        self:_refresh_text(self.UIRoot)
        if self._layout_dirty then self:_calculate_layout() end
    end
end

function JokerDisplayBox:_draw_node(node)
    local config = node.config
    if node.UIT == G.UIT.T then
        local font = self:_font(node)
        local scale = (config.scale or 0.4) * (node._render_scale or 1)
        love.graphics.setColor(config.colour or G.C.UI.TEXT_LIGHT)
        draw_text(node._drawable, font, scale, node.T.x, node.T.y)
    elseif node.UIT == G.UIT.O and node._drawable then
        local font = node._font or G.LANG.font
        local scale = (node._object_scale or 1) * (node._render_scale or 1)
        love.graphics.setColor(node._object_colour or G.C.UI.TEXT_LIGHT)
        draw_text(node._drawable, font, scale, node.T.x, node.T.y)
    elseif (node.UIT == G.UIT.C or node.UIT == G.UIT.R) and config.colour and config.colour[4] > 0.01 then
        love.graphics.setColor(config.colour)
        if config.r then
            draw_pixel_rect(node.T.x, node.T.y, node.T.w, node.T.h, config)
        else
            love.graphics.rectangle("fill", node.T.x, node.T.y, node.T.w, node.T.h)
        end
    end
    for _, child in ipairs(node.children or {}) do self:_draw_node(child) end
end

function JokerDisplayBox:draw()
    if not self.states.visible then return end
    add_to_drawhash(self)
    prep_draw(self, 1)
    love.graphics.setColor(self.UIRoot.config.colour or G.C.CLEAR)
    if self.UIRoot.config.r then
        draw_pixel_rect(0, 0, self.VT.w, self.VT.h, self.UIRoot.config)
    else
        love.graphics.rectangle("fill", 0, 0, self.VT.w, self.VT.h)
    end
    self:_draw_node(self.UIRoot)
    love.graphics.pop()
end

function JokerDisplayBox:remove()
    remove_compat_node(self.UIRoot)
    Moveable.remove(self)
end

local function collect_lightweight_dynatext(node, result)
    result = result or {}
    if not node then return result end
    local object = node.config and node.config.object
    if object and object.joker_display_lightweight then result[#result + 1] = object end
    for _, child in ipairs(node.children or {}) do
        collect_lightweight_dynatext(child, result)
    end
    return result
end

local function dynatext_strings_match(left, right)
    if not left or not right or #left ~= #right then return false end
    for index = 1, #left do
        if tostring(left[index].string) ~= tostring(right[index].string) then return false end
    end
    return true
end

local function replace_matching_tooltip_dynatext(definition, source)
    if type(definition) ~= "table" then return false end
    local object = definition.config and definition.config.object
    if object and object ~= source and not object.joker_display_lightweight and
        dynatext_strings_match(object.strings, source.strings) then
        local scale = object.scale
        if object.remove then object:remove() end
        definition.config.object = JokerDisplayDynaTextView(source, scale)
        return true
    end
    for _, child in ipairs(definition.nodes or {}) do
        if replace_matching_tooltip_dynatext(child, source) then return true end
    end
    if not definition.nodes then
        for index = 1, #definition do
            if replace_matching_tooltip_dynatext(definition[index], source) then return true end
        end
        for _, key in ipairs({ "main", "info", "name" }) do
            if replace_matching_tooltip_dynatext(definition[key], source) then return true end
        end
    end
    return false
end

-- as a way around the whole creating dynatext objects each time the ability is built we can just copy the existing one
local card_generate_UIBox_ability_table_ref = Card.generate_UIBox_ability_table
function Card:generate_UIBox_ability_table(...)
    local definition, main_start, main_end = card_generate_UIBox_ability_table_ref(self, ...)
    local sources = {}
    for _, child_name in ipairs({ "joker_display", "joker_display_small", "joker_display_debuff" }) do
        local display = self.children and self.children[child_name]
        if display and display:_is_visible() then
            collect_lightweight_dynatext(display.UIRoot, sources)
        end
    end
    for _, source in ipairs(sources) do
        local replaced = replace_matching_tooltip_dynatext(definition, source)
        if not replaced then replaced = replace_matching_tooltip_dynatext(main_start, source) end
        if not replaced then replace_matching_tooltip_dynatext(main_end, source) end
    end
    return definition, main_start, main_end
end

function Card:joker_display_has_info()
    local cached = self.joker_display_values and self.joker_display_values.has_info or {}
    local normal = self.children.joker_display and self.children.joker_display:has_info()
    local small = self.children.joker_display_small and self.children.joker_display_small:has_info()
    if normal == nil then normal = cached.NORMAL end
    if small == nil then small = cached.SMALL end
    return normal or small
end

local uielement_update_text_ref = UIElement.update_text
function UIElement:update_text()
    if self.UIBox.name and self.UIBox.name == "JokerDisplay" then
        if self.config and self.config.text and not self.config.text_drawable then
            self.config.lang = self.config.lang or G.LANG
            local font = self.config.font or self.config.lang.font
            self.config.text_drawable = love.graphics.newText(font.FONT, { G.C.WHITE, self.config.text })
        end
        local card = self.UIBox.parent
        if JokerDisplay.config.enabled and card.joker_display_values and
            not card.joker_display_values.disabled and self.config.ref_table then
            local formatted_text = JokerDisplay.text_format(self.config.ref_table[self.config.ref_value], self)
            local prev_value = self.config.prev_value_joker_display or JokerDisplay.text_format(self.config.prev_value, self)
            if formatted_text ~= prev_value then
                self.config.text = formatted_text
                self.config.text_drawable:set(formatted_text)
                if not self.config.no_recalc and prev_value and string.len(prev_value) ~= string.len(formatted_text) then
                    self.config.prev_value_joker_display = formatted_text
                    self.UIBox:recalculate()
                end
                self.config.prev_value = formatted_text
                self.config.prev_value_joker_display = formatted_text
            end
        end
    else
        uielement_update_text_ref(self)
    end
end

--- HELPER FUNCTIONS

JokerDisplay.text_format = function(text, node)
    if not text then return text or 'ERROR' end
    if type(text) == "function" then text = text() end

    local card = node.UIBox.parent

    text = JokerDisplay.retrigger_format(text, node, card)
    text = JokerDisplay.number_format(text)

    return tostring(text)
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
        local dynatext_config = JokerDisplay.deepcopy(display_config.dynatext)
        return {
            n = G.UIT.O,
            config = {
                object = can_use_lightweight_dynatext(dynatext_config) and
                    JokerDisplayDynaText(dynatext_config) or DynaText(dynatext_config)
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

---creates a G.UIT.T-compatible definition...JokerDisplayBox consumes it as a lightweight node..external callers should be able to insert it into a normal UIBox i think
---@param config {text: string?, ref_table: table?, ref_value: string?, scale: number?, colour: table?, retrigger_type: function|string? }
---@return table
JokerDisplay.create_display_text_object = function(config)
    return {
        n = G.UIT.T,
        config = {
            text = config.text,
            ref_table = config.ref_table,
            ref_value = config.ref_value,
            scale = config.scale or 0.4,
            colour = config.colour or G.C.UI.TEXT_LIGHT,
            font = ((SMODS or {}).Fonts or {})[config.font] or G.FONTS[tonumber(config.font)],
            retrigger_type = config.retrigger_type,
        }
    }
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
    if self == G.jokers and JokerDisplay and JokerDisplay.config and JokerDisplay.config.joker_count and not G.OVERLAY_MENU then
        -- Skip vanilla label draw
        if self.children and self.children.area_uibox then
            self.children.area_uibox.FRAME.DRAW = G.FRAMES.DRAW
        end
        -- Draw background box first (behind jokers)
        if self.children and self.children.area_uibox and self.children.area_uibox.UIRoot and self.states.visible then
            local container_row = self.children.area_uibox.UIRoot.children[1]
            if container_row and container_row.draw_self then
                container_row:draw_self() -- Draws just the background box
            end
        end
        cardarea_draw_ref(self, ...) -- Draw jokers (vanilla)
        -- Draw label on top (after jokers)
        if self.children and self.children.area_uibox and self.states.visible then
            -- Draw only text children
            local card_count_row = self.children.area_uibox.UIRoot.children[2]
            if card_count_row and card_count_row.children then
                for _, child in ipairs(card_count_row.children) do
                    if child.draw_self then
                        child:draw_self()
                    end
                end
            end
        end
    else
        cardarea_draw_ref(self, ...) -- over display disabled
    end
end
