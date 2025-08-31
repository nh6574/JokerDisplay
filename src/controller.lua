--- CONTROLLER INPUT

-- Collapse
local controller_queue_L_cursor_press_ref = Controller.queue_L_cursor_press
function Controller:queue_L_cursor_press(x, y)
    controller_queue_L_cursor_press_ref(self, x, y)
    local press_node = self.hovering.target or self.focused.target
    if press_node and press_node.name and press_node.name == "JokerDisplay" and press_node.can_collapse and press_node.parent then
        if not JokerDisplay.config.disable_collapse and not press_node.parent.joker_display_values.disabled then
            press_node.parent.joker_display_values.small = not press_node.parent.joker_display_values.small
        end
    end
end

-- Hide
local controller_queue_R_cursor_press_ref = Controller.queue_R_cursor_press
function Controller:queue_R_cursor_press(x, y)
    controller_queue_R_cursor_press_ref(self, x, y)
    local press_node = self.hovering.target or self.focused.target
    if not JokerDisplay.config.shift_to_hide or love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift') then
        if not G.SETTINGS.paused then
            if press_node and G.jokers then
                local is_display_area = false
                if press_node.area then
                    for _, area in ipairs(JokerDisplay.get_display_areas()) do
                        if press_node.area == area then
                            is_display_area = true
                            break
                        end
                    end
                end
                if (is_display_area
                        or (press_node.name and press_node.name == "JokerDisplay")) then
                    if press_node.name and press_node.name == "JokerDisplay" and press_node.can_collapse and press_node.parent then
                        press_node.parent:joker_display_toggle()
                    end
                    if press_node.ability then
                        press_node:joker_display_toggle()
                    end
                end
            end
        else
            if press_node and (press_node.area or (press_node.name and press_node.name == "JokerDisplay")) then
                JokerDisplay.visible = not JokerDisplay.visible
            end
        end
    end
end

local controller_button_press_update_ref = Controller.button_press_update
function Controller:button_press_update(button, dt)
    controller_button_press_update_ref(self, button, dt)

    if G.jokers then
        local press_node = self.hovering.target or self.focused.target
        local is_display_area = false
        if press_node and press_node.area then
            for _, area in ipairs(JokerDisplay.get_display_areas()) do
                if press_node.area == area then
                    is_display_area = true
                    break
                end
            end
        end
        if is_display_area and press_node and press_node.joker_display_values then
            if button == 'b' then
                press_node:joker_display_toggle()
            elseif button == 'dpup' then
                if not JokerDisplay.config.disable_collapse and not press_node.joker_display_values.disabled then
                    press_node.joker_display_values.small = not press_node.joker_display_values.small
                end
            end
        end
    end
end
