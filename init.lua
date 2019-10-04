oddbar = {
	players = {},
	max = 32, -- Probably dont change this manually
	default = "inventory", -- Default shape
}

local big32 = false -- Set this to true if you want to enable the experimental >32 hotbar
local PATH = minetest.get_modpath(minetest.get_current_modname())
-- dofile(PATH .. "/gui.lua") -- This is completely broken for now
local presets = dofile(PATH .. "/presets.lua")
local MAX = oddbar.max

if big32 then
	oddbar.max = 64

	sfinv.register_page("sfinv:big", {
		title = "Extended inventory",
		get = function(self, player, context)
			return sfinv.make_formspec(player, context, [[
				list[current_player;main;0,0.7;8,8;]
			]])
		end
	})
end

--[[ Inventory Handling ]]--
-- Each HUD slot has to start at first index :( so duplicate inventory to individual lists
local function updateInventory(player)
	local inv = player:get_inventory()
	minetest.after(0, function()
		for i = 1, inv:get_size("main") do
			inv:set_stack("oddbar"..i, 1, inv:get_stack("main", i))
		end
	end)
end

minetest.register_on_player_inventory_action(updateInventory)

minetest.register_on_item_eat(function(_, _, _, user)
	updateInventory(user)
end)

minetest.register_on_placenode(function(_, _, placer)
	updateInventory(placer)
end)

minetest.register_on_dignode(function(_, _, digger)
	updateInventory(digger)
end)

local item_drop = core.item_drop
core.item_drop = function(itemstack, dropper, pos)
	local out = item_drop(itemstack, dropper, pos)
	updateInventory(dropper)
	return out
end

local pickup = minetest.registered_entities["__builtin:item"].on_punch
minetest.registered_entities["__builtin:item"].on_punch = function(self, puncher)
	local out = pickup(self, puncher)
	updateInventory(puncher)
	return out
end

--[[ Functions ]]--
local function hudDef(wield, idx, pos, method, anchor)
	local selected = 0
	if wield == idx then
		selected = 1
	end

	local huddef = {
		hud_elem_type = "inventory",
		text = "oddbar"..idx,
		position = anchor,
		number = 1,
		direction = 1,
		item = selected,
	}

	if method == "relative" then
		huddef.position = pos
	else
		huddef.offset = pos
	end

	return huddef
end

function oddbar.clear(player)
	for i = 0, MAX do
		local def = player:hud_get(i)
		if def and def.text and def.text:match("^oddbar") then
			player:hud_remove(i)
		end
	end
end

function oddbar.set(player, slots, method, anchor)
	local name = player:get_player_name()
	local inv = player:get_inventory()
	oddbar.players[name].size = #slots

	for i = 1, #slots do
		inv:set_size("oddbar"..i, 1)
	end
	updateInventory(player)

	local hotbar = {}
	local slots, method, anchor = slots, method or "relative", anchor or {x = 0.475, y = 0.475}

	oddbar.clear(player)

	local idx = player:get_wield_index()
	for item, pos in ipairs(slots) do
		if item <= MAX then
			hotbar[#hotbar + 1] = {x = pos.x, y = pos.y, id = player:hud_add(hudDef(idx, item, pos, method, anchor))}
		end
	end

	hotbar.method = method
	hotbar.anchor = anchor
	oddbar.players[name].hotbar = hotbar
end

-- Add HUD
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	-- Overwrite sfinv
	minetest.after(0, function()
		local inv = player:get_inventory()
		player:hud_set_hotbar_image("oddbar_slot.png")
		inv:set_size("main", MAX)
	end)
	-- Hide default hotbar
	player:hud_set_flags({hotbar = false})
	player:hud_set_hotbar_itemcount(32)
	-- Track player and add new hotbar
	oddbar.players[name] = {selected = player:get_wield_index(), last = player:get_wield_index()}
	oddbar.set(player, presets[oddbar.default]())
end)

-- Clear slots and stop tracking player
minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	for i = 1, #oddbar.players[name].hotbar do
		inv:set_size("oddbar"..i, 0)
	end
	oddbar.players[name] = nil
end)

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		if oddbar.players[name].hotbar then
			-- Get current real index and last real index
			local idx = player:get_wield_index()
			local last = oddbar.players[name].last
			-- Index difference
			local d = idx - last
			-- Only change if we have to
			if d ~= 0 then
				-- A change less than -8 means we looped to 1
				if d < -8 then
					-- The difference is actually positive
					d = 32 - math.abs(d)
				-- A change greater than 8 means we looped to 32
				elseif d > 8 then
					-- The difference is still positive, but greater than 32 to loop to our actual index
					d = d + 32
				end

				local selected = oddbar.players[name].selected
				local size = oddbar.players[name].size

				-- Add difference
				oddbar.players[name].selected = selected + d
				selected = oddbar.players[name].selected

				-- Loop back to 1
				if selected > size then
					oddbar.players[name].selected = selected % size
				-- Loop up to highest slot
				-- This should never occur, as the difference should never be -1 when the last index is 1
				elseif selected < 1 then
					oddbar.players[name].selected = size - math.abs(selected)
				end

				-- Update slots
				for _, data in ipairs(oddbar.players[name].hotbar) do
					local s = 0
					if data.id == oddbar.players[name].selected - 1 then
						s = 1
					end
					player:hud_change(data.id, "item", s)
				end

				-- Update wielded item when MAX > 32
				-- TODO: Stay in valid indicies somehow and swap items
				--- if MAX > 32 then
				--- 	local inv = player:get_inventory()
				--- 	-- Do something...?
				--- end

				-- Set last index
				oddbar.players[name].last = idx
			end
		end
		if timer > 5 then
			updateInventory(player)
		end
	end
	if timer > 5 then
		timer = 0
	end
end)

minetest.register_chatcommand("odb", {
	description = "Sets your oddbar. See /odb.",
	func = function(name, preset)
		if not preset or preset == "" then
			local list = ""
			for p in pairs(presets) do
				list = list .. ", " .. p
			end
			return true, "Usage: /odb [preset]. Available presets: " .. list:sub(2)
		else
			if presets[preset] then
				local player = minetest.get_player_by_name(name)
				oddbar.set(player, presets[preset]())
				return true, "Oddbar set."
			else
				return false, ("Oddbar preset '%s' does not exist. Use /odb to list available presets."):format(preset)
			end
		end
	end,
})
