-- Parkour.lua
-- Parkour jumping achievement for WOW Classic Hardcore Addon
-- Written by Frank de Jong

local _G = _G
local _achievement = CreateFrame("Frame")
_G.passive_achievements.Parkour = _achievement

-- 	General info
_achievement.name = "Parkour"
_achievement.title = "Parkour"
_achievement.class = "All"
_achievement.icon_path = "Interface\\Addons\\Hardcore\\Media\\icon_speedrunner.blp"
_achievement.category = "Miscellaneous"
_achievement.level_cap = 60
_achievement.bl_text = "Miscellaneous"
_achievement.pts = 5
_achievement.description = "Jump to various hard to reach points in Orgrimmar and do a /flex there."
_achievement.restricted_game_versions = {
	["WotLK"] = 1,
	["Cata"] = 1,
}

local first_aid_name = "First Aid"		
local parkour_x, parkour_y				
local parkour_map_id = 0
local parkour_id_names = {
	["ORGAH"] = "Vanillaman's Lair",
	["ORGB1"] = "Keanu's Korner",
	["ORGB2"] = "Krueger's Point",		
}

local function StoreRoundedPlayerPosition()
	local x,y = UnitPosition("player")
	parkour_x = math.floor((tonumber(x) * 10) + 0.5)/10		
	parkour_y = math.floor((tonumber(y) * 10) + 0.5)/10		
end

local function UpdateParkourPoints()

	if Hardcore_Character == nil then
		return 0
	end
	if Hardcore_Character.parkour == nil then
		return 0
	end

	local points = 0
	for k, v in pairs( Hardcore_Character.parkour ) do
		if parkour_id_names[ k ] ~= nil then
			points = points + v.points
		end
	end
	_achievement.title = "Parkour (" .. points .. ")"
	return points
end

local function UpdateParkourAchievement( parkour_id )

	if Hardcore_Character == nil then
		return
	end

	if Hardcore_Character.parkour == nil then
		Hardcore_Character.parkour = {}
	end

	if parkour_id_names[ parkour_id ] == nil then
		Hardcore:Debug("Parkour: unknown parkour_id " .. parkour_id)
		return
	end

	local again
	if Hardcore_Character.parkour[ parkour_id ] ~= nil then
		again = " (again)"
	else
		again = ""
	end

	local PARKOUR_DATA = {}
	PARKOUR_DATA.points = 1								
	PARKOUR_DATA.coords = { parkour_x, parkour_y }		
	PARKOUR_DATA.map_id = parkour_map_id				
	PARKOUR_DATA.date = date("%m/%d/%y")
	Hardcore_Character.parkour[ parkour_id ] = PARKOUR_DATA

	local points = UpdateParkourPoints()

	Hardcore:Print( "You have reached " .. parkour_id_names[ parkour_id ] .. again )
	Hardcore:Print( "You currently have " .. points .. " Parkour points")

	_achievement.succeed_function_executor.Succeed(_achievement.name)

	return
end

local function IsPointWithinTriangle( x, y, x1, y1, x2, y2, x3, y3)

	local dx1, dy1, dx2, dy2, dx3, dy3
	dx1 = x - x1
	dy1 = y - y1
	dx2 = x - x2
	dy2 = y - y2
	dx3 = x - x3
	dy3 = y - y3

	local nx1, ny1, nx2, ny2, nx3, ny3
	nx1 = y2 - y1
	ny1 = -(x2 - x1)
	nx2 = y3 - y2
	ny2 = -(x3 - x2)
	nx3 = y1 - y3
	ny3 = -(x1 - x3)

	local ip1, ip2, ip3
	ip1 = dx1 * nx1 + dy1 * ny1
	ip2 = dx2 * nx2 + dy2 * ny2
	ip3 = dx3 * nx3 + dy3 * ny3

	if ip1 >= 0 and ip2 >= 0 and ip3 >= 0 then
		return true
	end
	return false
end

local function OnOrgrimmarBankLedge()
	if IsPointWithinTriangle( parkour_x, parkour_y, 1614.8, -4384.7, 1616.4, -4388.4, 1613.8, -4386.0 ) then
		return true
	end
	return false
end

local function OnOrgrimmarBankLedgeTwo()
	if IsPointWithinTriangle( parkour_x, parkour_y, 1610.1, -4373.3, 1611.1, -4376.1, 1610.9, -4377.4 ) then
		return true
	end
	return false
end

local function OnOrgrimmarAuctionHouseLedge()
	if IsPointWithinTriangle( parkour_x, parkour_y, 1671.5, -4429.7, 1671.6, -4428.4, 1675.8, -4427.6 ) then
		return true
	end
	return false
end

local function RegisterSpellEventHandlers()
	_achievement:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")			
	_achievement:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

---------------------------------
---- GLOBAL FUNCTIONS
---------------------------------

function _achievement:Register(succeed_function_executor)
	_achievement.succeed_function_executor = succeed_function_executor
	_achievement:RegisterEvent("CHAT_MSG_TEXT_EMOTE")
	UpdateParkourPoints()
end

function _achievement:Unregister()
	_achievement:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	_achievement:UnregisterEvent("CHAT_MSG_TEXT_EMOTE")
	_achievement:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

-- Event handling
_achievement:SetScript("OnEvent", function(self, event, ...)
	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unit, _, spell_id = ...
		if unit ~= "player" then
			return
		end
		
		if spell_id == 746 or spell_id == 1159 or spell_id == 3267 or spell_id == 3268 or
			spell_id == 7926 or spell_id == 7927 or spell_id == 10838 or spell_id == 10839 or
			spell_id == 18608 or spell_id == 23696 then
			local spell_name = GetSpellInfo(spell_id)
			if spell_name then 
			    first_aid_name = spell_name 
			end
		end
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
	    -- Safely bypass if CombatLog is fully restricted in Camelot
	    local payload = { CombatLogGetCurrentEventInfo() }
	    if not payload or not payload[2] then return end 
	    
		local subevent = payload[2]
		local source_guid = payload[4]
		local dest_guid = payload[8]
		local spell_name = payload[13]
		
		if subevent == "SPELL_CAST_SUCCESS" then
		    -- Protect against a false positive where nil == nil
			if spell_name and spell_name == first_aid_name then
				if source_guid ~= UnitGUID("player") then
					return
				end
				
				local target_type, _, _, map_id, _, target_type_id = string.split("-", dest_guid)
				map_id = tonumber( map_id )
				target_type_id = tonumber( target_type_id )
				if target_type ~= "Creature" or map_id ~= 1 or target_type_id ~= 13842 then
					return
				end

				StoreRoundedPlayerPosition()
				if OnOrgrimmarBankLedge() == true then
					UpdateParkourAchievement("ORGB1")
				elseif OnOrgrimmarBankLedgeTwo() == true then
					UpdateParkourAchievement("ORGB2")
				end
			end
		end
	elseif event == "CHAT_MSG_TEXT_EMOTE" then			 
		local _, _, _, _, _, _, _, _, _, _, _, guid = ...
		if guid == nil or guid ~= UnitGUID("player") then
			return
		end
		if IsInInstance() == false then
			local mapID = C_Map.GetBestMapForUnit("player")
			if mapID == 1454 then						
				StoreRoundedPlayerPosition()
				parkour_map_id = mapID
				if OnOrgrimmarBankLedge() then
					Hardcore:Print( "You are at " .. parkour_id_names[ "ORGB1" ] .. ", bandage Ambassador Rokhstrom from here for the Parkour achievement" )
					RegisterSpellEventHandlers()
				elseif OnOrgrimmarBankLedgeTwo() then
					Hardcore:Print( "You are at " .. parkour_id_names[ "ORGB2" ] .. ", bandage Ambassador Rokhstrom from here for the Parkour achievement" )
					RegisterSpellEventHandlers()
				elseif OnOrgrimmarAuctionHouseLedge() then
					UpdateParkourAchievement("ORGAH")
				end
			end
		end
		return
	end
end)