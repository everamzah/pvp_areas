-- pvp_areas
-- Copyright 2016 James Stevenson (everamzah)
-- LGPL v2.1+


local pvp_areas = {}
local pvp_areas_store = AreaStore()
pvp_areas_store:from_file(minetest.get_worldpath() .. "/pvp_areas_store.dat")

-- Register privilege and chat command.
minetest.register_privilege("pvp_areas_admin", "Can set and remove PvP areas.")

minetest.register_chatcommand("pvp_areas", {
	description = "Mark and set areas for PvP.",
	params = "<pos1> <pos2> <set> <remove>",
	privs = "pvp_areas_admin",
	func = function(name, param)
		local pos = vector.round(minetest.get_player_by_name(name):getpos())
		if param == "pos1" then
			if not pvp_areas[name] then
				pvp_areas[name] = {pos1 = pos}
			else
				pvp_areas[name].pos1 = pos
			end
			minetest.chat_send_player(name, "Position 1: " .. minetest.pos_to_string(pos))
		elseif param == "pos2" then
			if not pvp_areas[name] then
				pvp_areas[name] = {pos2 = pos}
			else
				pvp_areas[name].pos2 = pos
			end
			minetest.chat_send_player(name, "Position 2: " .. minetest.pos_to_string(pos))
		elseif param == "set" then
			if not pvp_areas[name] or not pvp_areas[name].pos1 then
				minetest.chat_send_player(name, "Position 1 missing, use \"/pvp_areas pos1\" to set.")
			elseif not pvp_areas[name].pos2 then
				minetest.chat_send_player(name, "Position 2 missing, use \"/pvp_areas pos2\" to set.")
			else
				minetest.chat_send_player(name, "Setting.")
				pvp_areas_store:insert_area(pvp_areas[name].pos1, pvp_areas[name].pos2, "pvp_areas")
				pvp_areas_store:to_file(minetest.get_worldpath() .. "/pvp_areas_store.dat")
			end
		elseif param == "remove" then
			minetest.chat_send_player(name, "Removing.")
		else
			minetest.chat_send_player(name, "Invalid usage.  Type \"/help pvp_areas\" for more information.")
		end
	end
})

local KILL_NO = true
local KILL_OK = false

-- Register punchplayer callback.
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	for k, v in pairs(pvp_areas_store:get_areas_for_pos(player:getpos())) do
		if k then
			return KILL_NO
		end
	end
	return KILL_OK
end)

if areas then
	if areas.registerHudHandler then

		local function advertise_nokillzone(pos, list)
			for k, v in pairs(pvp_areas_store:get_areas_for_pos(player:getpos())) do
				if k then
					list:insert( {
						id = "pvp_areas:"..tostring(k),
						name = k,
					} )
					return
				end
			end
		end

		areas:registerHudHandler(advertise_nokillzone)
	else
		minetest.log("info","Your version of `areas` does not support registering hud handlers.")
	end
end
