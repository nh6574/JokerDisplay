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
    local resolution = config.render_res or config.res or (shortest > 3.5 and 0.8 or shortest > 0.3 and 0.6 or 0.15)
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
    love.graphics.draw(
        drawable,
        x + font.TEXT_OFFSET.x * scale * font.FONTSCALE / G.TILESIZE,
        y + font.TEXT_OFFSET.y * scale * font.FONTSCALE / G.TILESIZE,
        0,
        scale * font.squish * font.FONTSCALE / G.TILESIZE,
        scale * font.FONTSCALE / G.TILESIZE
    )
end

JokerDisplay.display_colour_registry = JokerDisplay.display_colour_registry or {}
local display_colour_ids = setmetatable({}, { __mode = "k" })
local function suit_display_colour(suit) return lighten(G.C.SUITS[suit], 0.35) end

local function same_colour(a, b)
    return a and b and math.abs((a[1] or 0) - (b[1] or 0)) < 0.002
        and math.abs((a[2] or 0) - (b[2] or 0)) < 0.002
        and math.abs((a[3] or 0) - (b[3] or 0)) < 0.002
end

local function display_colour_id(colour)
    if type(colour) ~= "table" then return end
    if display_colour_ids[colour] then return display_colour_ids[colour] end
    local known = {
        { "chips", "Chips", G.C.CHIPS }, { "mult", "Mult", G.C.MULT },
        { "xmult", "XMult", G.C.XMULT }, { "money", "Money", G.C.GOLD },
        { "odds", "Chance", G.C.GREEN },
        { "required", "Required text", G.C.ORANGE },
        { "text", "Default text", G.C.UI.TEXT_LIGHT },
        { "inactive", "Inactive text", G.C.UI.TEXT_INACTIVE }
    }
    for _, entry in ipairs(known) do
        if colour == entry[3] then
            display_colour_ids[colour] = entry[1]
            JokerDisplay.display_colour_registry[entry[1]] = { label = entry[2], colour = colour, builtin = true }
            return entry[1]
        end
    end
    for _, suit in ipairs({ "Hearts", "Diamonds", "Spades", "Clubs" }) do
        local themed = suit_display_colour(suit)
        if same_colour(colour, themed) then
            local id = "suit_" .. suit:lower()
            display_colour_ids[colour] = id
            JokerDisplay.display_colour_registry[id] = { label = suit, colour = themed, builtin = true }
            return id
        end
    end
    if colour[1] and colour[2] and colour[3] then
        local id = string.format("custom_%02X%02X%02X", math.floor(colour[1] * 255 + 0.5),
            math.floor(colour[2] * 255 + 0.5), math.floor(colour[3] * 255 + 0.5))
        JokerDisplay.display_colour_registry[id] = { label = "Custom #" .. id:sub(8), colour = colour }
        return id
    end
end

JokerDisplay.get_display_colour = function(colour)
    local id = display_colour_id(colour)
    local override = id and JokerDisplay.config.text_colour_overrides
        and JokerDisplay.config.text_colour_overrides[id]
    if override then return override end
    local suit = id and id:match("^suit_(.+)$")
    if suit then return suit_display_colour(suit:sub(1, 1):upper() .. suit:sub(2)) end
    return colour
end

JokerDisplay.get_background_colour = function()
    if JokerDisplay.config.background_colour_override and JokerDisplay.config.background_colour then
        return JokerDisplay.config.background_colour
    end
    local colour = G.C.UI.BACKGROUND_DARK
    local default_ui = math.abs(colour[1] - 0x7A / 255) < 0.002
        and math.abs(colour[2] - 0x9E / 255) < 0.002 and math.abs(colour[3] - 0x9F / 255) < 0.002
    if default_ui then
        colour = G.C.BLACK
        local default_black = math.abs(colour[1] - 0x37 / 255) < 0.002
            and math.abs(colour[2] - 0x42 / 255) < 0.002 and math.abs(colour[3] - 0x44 / 255) < 0.002
        if default_black then colour = { 0, 0, 0, 1 } end
    end
    return adjust_alpha(darken(colour, 0.2), JokerDisplay.config.background_opacity or 0.8)
end

JokerDisplay.get_sticker_colour = function(kind)
    local overrides = JokerDisplay.config.text_colour_overrides or {}
    if overrides[kind] then return overrides[kind] end
    if kind == "perishable" then return lighten(G.C.PERISHABLE, 0.35) end
    if kind == "rental" then return G.C.GOLD end
    return JokerDisplay.get_background_colour()
end

JokerDisplay.update_sticker_colours = function(card)
    if not card or not card.children then return end
    local function update(key, kind)
        local box = card.children[key]
        if not (box and box.UIRoot) then return end
        box.UIRoot.config.colour = JokerDisplay.get_sticker_colour("sticker_background")
        local function update_text(node)
            if node.config and node.config.ref_value == kind then
                node.config.colour = JokerDisplay.get_sticker_colour(kind)
            end
            for _, child in ipairs(node.children or {}) do update_text(child) end
        end
        update_text(box.UIRoot)
    end
    update("joker_display_perishable", "perishable")
    update("joker_display_rental", "rental")
end

local palette_signature, palette_revision = nil, 0
local function current_palette_revision()
    local colours = { G.C.CHIPS, G.C.MULT, G.C.XMULT, G.C.GOLD, G.C.CHANCE, G.C.GREEN, G.C.ORANGE,
        G.C.PERISHABLE, G.C.BLACK,
        G.C.SUITS.Hearts, G.C.SUITS.Diamonds, G.C.SUITS.Spades, G.C.SUITS.Clubs,
        G.C.UI.BACKGROUND_DARK, G.C.UI.TEXT_LIGHT,
        G.C.UI.TEXT_INACTIVE, G.C.RED, G.C.BLUE, G.C.GREEN, G.C.PURPLE }
    local parts = {}
    for _, colour in ipairs(colours) do
        parts[#parts + 1] = string.format(
            "%.4f,%.4f,%.4f,%.4f",
            colour[1] or 0,
            colour[2] or 0,
            colour[3] or 0,
            colour[4] or 1
        )
    end
    local signature = table.concat(parts, ";")
    if signature ~= palette_signature then
        palette_signature, palette_revision = signature, palette_revision + 1
    end
    return palette_revision
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
        table.insert(result, JokerDisplay.get_display_colour(letter.colour or self.colours[index % #self.colours + 1]))
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
        config.text_outline or config.scale_function or config.text_rot then
        return false
    end
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
            colour = JokerDisplay.get_background_colour(),
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
    self._canvas_dirty = true
    self:recalculate(true)
end

function JokerDisplayBox:recalculate(from_update)
    if not from_update then return end
    self._canvas_dirty = true
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
            if node._drawable then
                node._drawable:set(text)
            else
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
                local colour = JokerDisplay.get_display_colour(letter.prefix or letter.suffix or letter.colour or colours[index % #colours + 1])
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
    local padding = (config.render_padding or config.padding or 0) * scale
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
        if node.children[#node.children].UIT == G.UIT.R then
            content_h = content_h - padding
        else
            content_w = content_w -
                padding
        end
    end
    node.T.w = math.max((config.minw or 0) * scale, content_w + padding * 2)
    node.T.h = math.max((config.minh or 0) * scale, content_h + padding * 2)
    return node.T.w, node.T.h
end

function JokerDisplayBox:_place(node, x, y)
    node.T.x, node.T.y = x, y
    local padding = (node.config.render_padding or node.config.padding or 0) * (node._layout_scale or 1)
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
    self._canvas_dirty = true
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
    local modifiers_changed = reset or false
    local has_modifiers = false

    for i = 1, #JokerDisplay.mod_keys do
        local key = JokerDisplay.mod_keys[i]
        if (not not self.modifiers[key]) ~= (not not modifiers[key]) then
            modifiers_changed = true
        end
        self.modifiers[key] = modifiers[key]
        if self.modifiers[key] then
            has_modifiers = true
        end
    end

    if (not not self.modifiers.extra_text) ~= (not not modifiers.extra_text) then
        modifiers_changed = true
    end
    self.modifiers.extra_text = modifiers.extra_text
    if self.modifiers.extra_text then
        has_modifiers = true
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

    for _, key in ipairs(JokerDisplay.mod_keys) do
        local mod = JokerDisplay.Modifier_Definitions[key]
        if self.modifiers[key] and mod then
            local inner_nodes = {}
            for _, element in ipairs(mod.text or {}) do
                table.insert(inner_nodes, JokerDisplay.create_display_object(self, element))
            end
            table.insert(mod_nodes, inner_nodes)
        end
    end

    if self.modifiers.extra_text then
        for _, line in ipairs(self.modifiers.extra_text) do
            local inner_nodes = {}
            for _, element in ipairs(line or {}) do
                table.insert(inner_nodes, JokerDisplay.create_display_object(self, element))
            end
            table.insert(mod_nodes, inner_nodes)
        end
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
        local revision = current_palette_revision()
        if self._palette_revision ~= revision then
            self._palette_revision = revision
            self.UIRoot.config.colour = JokerDisplay.get_background_colour()
            JokerDisplay.update_sticker_colours(self.parent)
            local function refresh_colours(node)
                if node.UIT == G.UIT.O and node.config.object then
                    node._text = nil
                    if node.config.object.joker_display_lightweight then node.config.object:_set_drawable() end
                end
                for _, child in ipairs(node.children or {}) do refresh_colours(child) end
            end
            refresh_colours(self.UIRoot)
            self._canvas_dirty = true
        end
        self:_refresh_text(self.UIRoot)
        if self._layout_dirty then self:_calculate_layout() end
    end
end

function JokerDisplayBox:_draw_node(node, pass)
    local config = node.config
    if node.UIT == G.UIT.T and pass ~= "shapes" then
        local font = self:_font(node)
        local scale = (config.scale or 0.4) * (node._render_scale or 1)
        love.graphics.setColor(JokerDisplay.get_display_colour(config.colour or G.C.UI.TEXT_LIGHT))
        draw_text(node._drawable, font, scale, node.T.x, node.T.y)
    elseif node.UIT == G.UIT.O and node._drawable and pass ~= "shapes" then
        local font = node._font or G.LANG.font
        local scale = (node._object_scale or 1) * (node._render_scale or 1)
        love.graphics.setColor(node._object_colour or G.C.UI.TEXT_LIGHT)
        draw_text(node._drawable, font, scale, node.T.x, node.T.y)
    elseif pass ~= "text" and (node.UIT == G.UIT.C or node.UIT == G.UIT.R) and config.colour and config.colour[4] > 0.01 then
        love.graphics.setColor(JokerDisplay.get_display_colour(config.colour))
        if config.r then
            draw_pixel_rect(node.T.x, node.T.y, node.T.w, node.T.h, config)
        else
            love.graphics.rectangle("fill", node.T.x, node.T.y, node.T.w, node.T.h)
        end
    end
    for _, child in ipairs(node.children or {}) do self:_draw_node(child, pass) end
end

function JokerDisplayBox:_draw_contents(width, height, pass)
    if pass ~= "text" then
        love.graphics.setColor(self.UIRoot.config.colour or G.C.CLEAR)
        if self.UIRoot.config.r then
            draw_pixel_rect(0, 0, width, height, self.UIRoot.config)
        else
            love.graphics.rectangle("fill", 0, 0, width, height)
        end
    end
    self:_draw_node(self.UIRoot, pass)
end

function JokerDisplayBox:_update_canvas()
    local supersample = 2
    local width = math.max(1, math.ceil(self.VT.w * G.TILESIZE * supersample))
    local height = math.max(1, math.ceil(self.VT.h * G.TILESIZE * supersample))
    if not self.canvas or self.canvas:getWidth() ~= width or self.canvas:getHeight() ~= height then
        if self.canvas and self.canvas.release then self.canvas:release() end
        self.canvas = love.graphics.newCanvas(width, height, { dpiscale = 1 })
        self.canvas:setFilter("linear", "linear")
    end

    love.graphics.push("all")
    love.graphics.setCanvas(self.canvas)
    love.graphics.origin()
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.scale(G.TILESIZE * supersample)
    self:_draw_contents(self.VT.w, self.VT.h, "shapes")
    love.graphics.pop()
    self._canvas_dirty = false
    self._canvas_scale = supersample
    self._canvas_width, self._canvas_height = self.VT.w, self.VT.h
end

function JokerDisplayBox:draw()
    if not self.states.visible then return end
    add_to_drawhash(self)
    prep_draw(self, 1)
    if G.SETTINGS.GRAPHICS.texture_scaling == 2 then
        if self._canvas_dirty or not self.canvas or self._canvas_width ~= self.VT.w or
            self._canvas_height ~= self.VT.h then
            self:_update_canvas()
        end
        love.graphics.setColor(G.C.WHITE)
        local scale = 1 / (G.TILESIZE * self._canvas_scale)
        love.graphics.draw(self.canvas, 0, 0, 0, scale, scale)
        self:_draw_contents(self.VT.w, self.VT.h, "text")
    else
        self:_draw_contents(self.VT.w, self.VT.h)
    end
    love.graphics.pop()
end

function JokerDisplayBox:remove()
    remove_compat_node(self.UIRoot)
    if self.canvas and self.canvas.release then self.canvas:release() end
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
            local prev_value = self.config.prev_value_joker_display or
                JokerDisplay.text_format(self.config.prev_value, self)
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
    text = JokerDisplay.number_format(text, nil, nil, node.config.signed)

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
---@param display_config {text: string?, ref_table: string?, ref_value: string?, scale: number?, colour: table|function?, border_nodes: table?, border_colour: table|function?, dynatext: table?, retrigger_type: function|string?, signed: boolean|string|table?, font:integer|string|table?} Node configuration.
---@param defaults_config? {colour: table?, scale: number?, font:integer|string|table?} Defaults for all text objects.
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
        return JokerDisplay.create_display_border_text_object(inside_nodes, display_config.border_colour)
    end
    if display_config.ref_value and display_config.ref_table then
        local ref_table
        if type(display_config.ref_table) == "string" then
            local table_path = JokerDisplay.strsplit(display_config.ref_table, ".")
            ref_table = table_path[1] == "card" and card or _G[table_path[1]]
            for i = 2, #table_path do
                if ref_table[table_path[i]] then
                    ref_table = ref_table[table_path[i]]
                end
            end
        else
            ref_table = display_config.ref_table
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
            retrigger_type = display_config.retrigger_type,
            signed = display_config.signed
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
            retrigger_type = display_config.retrigger_type,
            signed = display_config.signed
        })
    end
    return node
end

---creates a G.UIT.T-compatible definition...JokerDisplayBox consumes it as a lightweight node..external callers should be able to insert it into a normal UIBox i think
---@param config {text: string?, ref_table: table?, ref_value: string?, scale: number?, colour: table?, retrigger_type: function|string?, signed: boolean|string|table?, font:integer|string|table? }
---@return table
JokerDisplay.create_display_text_object = function(config)
    local colour = type(config.colour) == "function" and config.colour() or config.colour or G.C.UI.TEXT_LIGHT
    return {
        n = G.UIT.T,
        config = {
            text = config.text,
            ref_table = config.ref_table,
            ref_value = config.ref_value,
            scale = config.scale or 0.4,
            colour = colour,
            font = ((SMODS or {}).Fonts or {})[config.font] or G.FONTS[tonumber(config.font)],
            retrigger_type = config.retrigger_type,
            signed = config.signed
        }
    }
end

---Creates a G.UIT.C object with JokerDisplay configurations for text borders (e.g. for XMULT).
---@param nodes table Nodes contained inside the border.
---@param border_color table Color of the border.
---@return table
JokerDisplay.create_display_border_text_object = function(nodes, border_color)
    local colour = type(border_color) == "function" and border_color() or border_color or G.C.XMULT
    return {
        n = G.UIT.C,
        config = { colour = colour, r = 0.05, padding = 0.03, res = 0.15, render_padding = 0.05, render_res = 0.2 },
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
