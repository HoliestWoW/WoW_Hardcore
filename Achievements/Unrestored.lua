local _G = _G
local unrestored_achievement = CreateFrame("Frame")
_G.achievements.Unrestored = unrestored_achievement

-- General info
unrestored_achievement.name = "Unrestored"
unrestored_achievement.title = "Unrestored"
unrestored_achievement.pts = 10
unrestored_achievement.class = "Druid"
unrestored_achievement.icon_path = "Interface\\Addons\\Hardcore\\Media\\icon_unrestored.blp"
unrestored_achievement.description =
	"Complete the Hardcore challenge without at any point using an ability within the “Restoration” tab of your spellbook. Only spells listed under “Feral Combat”, “Balance”, or “General” are allowed. You are allowed to put points into all talent trees, but active abilities thus unlocked that are in the “Restoration” tab of your spellbook are not allowed to be used."

-- Registers
function unrestored_achievement:Register(fail_function_executor)
	unrestored_achievement:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	unrestored_achievement:RegisterEvent("SPELLS_CHANGED")
	unrestored_achievement:GatherBlackList()
	unrestored_achievement.fail_function_executor = fail_function_executor
end

function unrestored_achievement:Unregister()
	unrestored_achievement:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	unrestored_achievement:UnregisterEvent("SPELLS_CHANGED")
end

function unrestored_achievement:GatherBlackList()
	unrestored_achievement.blacklist = {}
	
	-- Camelot C_SpellBook compatibility logic
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

		if name == "Restoration" and offset and numSlots then
			for j = offset + 1, offset + numSlots do
				local spell_name = nil
				if C_SpellBook and C_SpellBook.GetSpellBookItemName then
					spell_name = C_SpellBook.GetSpellBookItemName(j, Enum.SpellBookSpellBank.Player)
				elseif GetSpellInfo then
					spell_name = GetSpellInfo(j, "")
				end

				if spell_name then
					table.insert(unrestored_achievement.blacklist, spell_name)
				end
			end
		end
	end
end

-- Register Definitions
unrestored_achievement:SetScript("OnEvent", function(self, event, ...)
	local arg = { ... }
	if event == "SPELLS_CHANGED" then
		unrestored_achievement:GatherBlackList()
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unit, _, spell_id = ...
		if unit ~= "player" or not spell_id then
			return
		end
		
		local spell_name = GetSpellInfo(spell_id)
		if not spell_name then return end
		
		for i, blacklist_spell in ipairs(unrestored_achievement.blacklist) do
			if spell_name == blacklist_spell then
				unrestored_achievement.fail_function_executor.Fail(unrestored_achievement.name)
				return
			end
		end
	end
end)