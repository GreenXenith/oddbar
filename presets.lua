--[[ Presets ]]--
-- Hotbar shapes
local presets = {
	border = function()
		return {
			{x = 0.136, y = 0.935},
			{x = 0.252, y = 0.935},
			{x = 0.368, y = 0.935},
			{x = 0.484, y = 0.935},
			{x = 0.600, y = 0.935},
			{x = 0.716, y = 0.935},
			{x = 0.832, y = 0.935},
			{x = 0.935, y = 0.935},

			{x = 0.935, y = 0.832},
			{x = 0.935, y = 0.716},
			{x = 0.935, y = 0.600},
			{x = 0.935, y = 0.484},
			{x = 0.935, y = 0.368},
			{x = 0.935, y = 0.252},
			{x = 0.935, y = 0.136},
			{x = 0.935, y = 0.01},

			{x = 0.832, y = 0.01},
			{x = 0.716, y = 0.01},
			{x = 0.600, y = 0.01},
			{x = 0.484, y = 0.01},
			{x = 0.368, y = 0.01},
			{x = 0.252, y = 0.01},
			{x = 0.136, y = 0.01},
			{x = 0.01, y = 0.01},

			{x = 0.01, y = 0.136},
			{x = 0.01, y = 0.252},
			{x = 0.01, y = 0.368},
			{x = 0.01, y = 0.484},
			{x = 0.01, y = 0.600},
			{x = 0.01, y = 0.716},
			{x = 0.01, y = 0.832},
			{x = 0.01, y = 0.935},
		}, "relative"
	end,
	spiral = function()
		local slots = {}
		local function spiral(n)
			local k = math.ceil((math.sqrt(n) - 1) / 2)
			local t = 2 * k + 1
			local m = t ^ 2 
			t = t - 1
			if n >= m - t then return k - (m - n), -k        else m = m - t end
			if n >= m - t then return -k, -k + (m - n)       else m = m - t end
			if n >= m - t then return -k + (m - n), k else return k, k - (m - n - t) end
		end
		
		for i = 1, 32 do
			local x, y = spiral(i)
			slots[i] = {x = x * 100, y = y * 100}
		end

		return slots, "offset"
	end,
	circle1 = function()
		local slots = {}
		for i = 1, 32 do
			local angle = ((math.pi * 2) / 32) * i
			local pX = math.cos(angle) * 2 
			local pY = math.sin(angle) * 2
		
			slots[i] = {x = 0.48 + pX * 0.2, y = 0.48 + pY * 0.2}
		end
		return slots, "relative"
	end,
	circle2 = function()
		local slots = {}
		for i = 1, 32 do
			local angle = ((math.pi * 2) / 32) * i
			local pX = math.cos(angle) * 2 
			local pY = math.sin(angle) * 2
		
			slots[i] = {x = pX * 220, y = pY * 220}
		end
		return slots, "offset"
	end,
	inventory = function()
		local slots = {
			{x = 0.0, y = 0.0},
			{x = 0.05, y = 0.0},
			{x = 0.1, y = 0.0},
			{x = 0.15, y = 0.0},
			{x = 0.2, y = 0.0},
			{x = 0.25, y = 0.0},
			{x = 0.3, y = 0.0},
			{x = 0.35, y = 0.0},

			{x = 0.0, y = 0.05},
			{x = 0.05, y = 0.05},
			{x = 0.1, y = 0.05},
			{x = 0.15, y = 0.05},
			{x = 0.2, y = 0.05},
			{x = 0.25, y = 0.05},
			{x = 0.3, y = 0.05},
			{x = 0.35, y = 0.05},

			{x = 0.0, y = 0.1},
			{x = 0.05, y = 0.1},
			{x = 0.1, y = 0.1},
			{x = 0.15, y = 0.1},
			{x = 0.2, y = 0.1},
			{x = 0.25, y = 0.1},
			{x = 0.3, y = 0.1},
			{x = 0.35, y = 0.1},

			{x = 0.0, y = 0.15},
			{x = 0.05, y = 0.15},
			{x = 0.1, y = 0.15},
			{x = 0.15, y = 0.15},
			{x = 0.2, y = 0.15},
			{x = 0.25, y = 0.15},
			{x = 0.3, y = 0.15},
			{x = 0.35, y = 0.15},
		}
		for i, pos in pairs(slots) do
			slots[i] = {x = pos.x * 1200, y = pos.y * 1200}
		end
		return slots, "offset", {x = 0.01, y = 0.65}
	end,
}

if oddbar.max > 32 then
	presets.big = function()
		local slots = {}
		local n = 8
		for y = 1, n do
			for x = 1, n do
				slots[#slots + 1] = {x = (0.9 / n) * x, y = (0.9 / n) * y}
			end
		end
		return slots, "relative"
	end

	presets.bigcircle = function()
		local slots = {}
		for i = 1, 64 do
			local angle = ((math.pi * 2) / 64) * i
			local pX = math.cos(angle) * 2 
			local pY = math.sin(angle) * 2
		
			slots[i] = {x = pX * 220, y = pY * 220}
		end
		return slots, "offset"
	end
end

return presets
