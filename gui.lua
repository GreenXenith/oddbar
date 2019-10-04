-- Customizer formspec [THIS IS COMPLETELY BROKEN!]
local function form(name, selected)
	local player = minetest.get_player_by_name(name)
	if not player then
		return
	end
	local meta = player:get_meta()
	local hotbar = minetest.deserialize(meta:get_string("hotbar"))
	selected = selected or 1

	local slots = ""
	for i = 1, #hotbar do
		slots = slots .. "," .. i
	end

	local count = ""
	for i = 1, 32 do
		count = count .. "," .. i
	end

	local pstr = ""
	for preset in pairs(layouts) do
		pstr = pstr .. "," .. preset
	end

	local form = ([=[
		size[6,6]
		position[0.5,0.5]
		no_prepend[]
		bgcolor[#00000000]

		label[0,2.6;Slot]
		dropdown[0,3;1;slot;%s;%s]

		label[1.5,3.1;(]
		button[1.65,2;1,1;incx;↑]
		field[1.95,3.25;1,1;x;X;%s]
		button[1.65,4;1,1;decx;↓]
		label[2.5,3.1;,]
		button[2.65,2;1,1;incy;↑]
		field[2.95,3.25;1,1;y;Y;%s]
		button[2.65,4;1,1;decy;↓]
		label[3.5,3.1;)]

		label[4,2.6;Count]
		dropdown[4,3;1;count;%s;%s]

		label[1.65,4.8;Presets]
		dropdown[1.65,5.2;2;presets;%s;1]

		field_close_on_enter[x;false]
		field_close_on_enter[y;false]
	]=]):format(slots:sub(2), selected, hotbar[selected].x, hotbar[selected].y, count:sub(2), #hotbar, pstr:sub(2))

	minetest.show_formspec(name, "oddbar:customize"..selected, form)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname:match("^oddbar:customize%d+$") and not fields.quit then
		local name = player:get_player_name()
		local meta = player:get_meta()
		local hotbar = minetest.deserialize(meta:get_string("hotbar"))

		local slot = tonumber(formname:match("%d+"))
		local count = #hotbar

		local function noButtons()
			if fields.incx or fields.decx or fields.incy or fields.decy then
				return false
			end
			return true
		end

		local do_change = false
		if fields.slot and noButtons() then
			slot = tonumber(fields.slot)
		elseif fields.count and noButtons() then
			for i = 1, 32 do
				if i <= tonumber(fields.count) then
					if not hotbar[i] then
						hotbar[i] = {
							x = 0,
							y = 0,
							id = player:hud_add(hudDef(player, i, "relative", {x = 0.475, y = 0.475}))
						}
					end
				elseif hotbar[i] then
					player:hud_remove(hotbar[i].id)
					hotbar[i] = nil
				end
			end
			if slot > tonumber(fields.count) then
				slot = tonumber(fields.count)
			end
		elseif fields.presets and noButtons() then
			oddbar.clear(player)
			hotbar, hotbar.method, hotbar.anchor = layouts[fields.presets]()
			oddbar.set(player, layouts[fields.presets]())
		else
			do_change = true
			if fields.incx then
				hotbar[slot].x = hotbar[slot].x + 0.1
			elseif fields.decx then
				hotbar[slot].x = hotbar[slot].x - 0.1
			elseif fields.incy then
				hotbar[slot].y = hotbar[slot].y + 0.1
			elseif fields.decy then
				hotbar[slot].y = hotbar[slot].y - 0.1
			elseif fields.x or fields.y then
				hotbar[slot].x = tonumber(fields.x)
				hotbar[slot].y = tonumber(fields.y)
			end
		end

		if do_change and (fields.x or fields.y or not noButtons()) then
			local stat = "position"
			local def = player:hud_get(hotbar[slot].id)
			if def.offset then
				stat = "offset"
			end
			player:hud_change(hotbar[slot].id, stat, {x = hotbar[slot].x, y = hotbar[slot].y})
		end

		minetest.chat_send_all(minetest.serialize(fields))
		meta:set_string("hotbar", minetest.serialize(hotbar))
		form(name, slot)
	end
end)

minetest.register_chatcommand("myhb", {
	func = function(name)
		form(name)
	end,
})
