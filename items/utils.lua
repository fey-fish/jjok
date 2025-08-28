local gcu = generate_card_ui
function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
    local UI_table = gcu(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
    if card_type == 'Joker' and not _c.qdiscovered then
        UI_table.main = {}
        UI_table.info_queue = {}
    end
    return UI_table
end