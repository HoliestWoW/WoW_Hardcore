local _G = _G
local arcanist_achievement = CreateFrame("Frame")
_G.achievements.Arcanist = arcanist_achievement

-- General info
arcanist_achievement.name = "Arcanist"
arcanist_achievement.title = "Arcanist"
arcanist_achievement.class = "Mage"
arcanist_achievement.pts = 10
arcanist_achievement.icon_path = "Interface\\Addons\\Hardcore\\Media\\icon_arcanist.blp"
arcanist_achievement.bl_text = "Starting Achievement"
arcanist_achievement.description =
	"Complete the Hardcore challenge using only abilities within the “Arcane” (and “General”) tab of your spellbook. No spells outside of those listed under “Arcane” or “General” are allowed. You are allowed to put points into all talent trees, but active abilities thus unlocked that are not in the “Arcane” tab of your spellbook are not allowed to be used."

local whitelist = {
	["133"] = 1,
    [133] = 1, -- Added numerical key check
}

-- Registers
function arcanist_achievement:Register(fail_function_executor)
	arcanist_achievement:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	arcanist_achievement:RegisterEvent("SPELLS_CHANGED")
	arcanist_achievement:GatherBlackList()
	arcanist_achievement.fail_function_executor = fail_function_executor
end

function arcanist_achievement:Unregister()
	arcanist_achievement:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	arcanist_achievement:UnregisterEvent("SPELLS_CHANGED")
end

function arcanist_achievement:GatherBlackList()
	arcanist_achievement.blacklist = {}
	
	-- Determine total tabs dynamically based on available API
	local numTabs = 4
	if C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines then
		numTabs = C_SpellBook.GetNumSpellBookSkillLines()
	end

	for i = 1, numTabs do
		local name, offset, numSlots = nil, nil, nil
		
		if C_SpellBook and C_SpellBook.GetSpellBookSkillLineInfo then
			local info = C_SpellBook.GetSpellBookSkillLineInfo(i)
			if info then
				name = info.name
				offset = info.itemIndexOffset
				numSlots = info.numSpellBookItems
			end
		elseif GetSpellTabInfo then
			local tName, _, tOffset, tSlots = GetSpellTabInfo(i)
			name, offset, numSlots = tName, tOffset, tSlots
		end

		if (name == "Fire" or name == "Frost") and offset and numSlots then
			for j = offset + 1, offset + numSlots do
				local spell_name = nil
				
				if C_SpellBook and C_SpellBook.GetSpellBookItemName then
					spell_name = C_SpellBook.GetSpellBookItemName(j, Enum.SpellBookSpellBank.Player)
				elseif GetSpellInfo then
					spell_name = GetSpellInfo(j, BOOKTYPE_SPELL)
				end

				if spell_name then
					table.insert(arcanist_achievement.blacklist, spell_name)
				end
			end
		end
	end
end

-- Register Definitions
arcanist_achievement:SetScript("OnEvent", function(self, event, ...)
	local arg = { ... }
	if event == "SPELLS_CHANGED" then
		arcanist_achievement:GatherBlackList()
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unit, _, spell_id = ...
		if unit ~= "player" or not spell_id then
			return
		end
		
		local spell_name = GetSpellInfo(spell_id)
		
		-- Safely skip if nil, or if it matches string/number whitelist keys
		if not spell_name or whitelist[spell_id] or whitelist[tostring(spell_id)] then
			return
		end
		
		for i, blacklist_spell in ipairs(arcanist_achievement.blacklist) do
			if spell_name == blacklist_spell then
				arcanist_achievement.fail_function_executor.Fail(arcanist_achievement.name)
				return
			end
		end
	end
end)