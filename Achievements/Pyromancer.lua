local _G = _G
local pyromancer_achievement = CreateFrame("Frame")
_G.achievements.Pyromancer = pyromancer_achievement

-- General info
pyromancer_achievement.name = "Pyromancer"
pyromancer_achievement.title = "Pyromancer"
pyromancer_achievement.class = "Mage"
pyromancer_achievement.icon_path = "Interface\\Addons\\Hardcore\\Media\\icon_pyromancer.blp"
pyromancer_achievement.pts = 10
pyromancer_achievement.description =
	"Complete the Hardcore challenge using only abilities within the “Fire” (and “General”) tab of your spellbook. No spells outside of those listed under “Fire” or “General” are allowed. You are allowed to put points into all talent trees, but active abilities thus unlocked that are not in the “Fire” tab of your spellbook are not allowed to be used."

-- Registers
function pyromancer_achievement:Register(fail_function_executor)
	pyromancer_achievement:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	pyromancer_achievement:RegisterEvent("SPELLS_CHANGED")
	pyromancer_achievement:GatherBlackList()
	pyromancer_achievement.fail_function_executor = fail_function_executor
end

function pyromancer_achievement:Unregister()
	pyromancer_achievement:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	pyromancer_achievement:UnregisterEvent("SPELLS_CHANGED")
end

function pyromancer_achievement:GatherBlackList()
	pyromancer_achievement.blacklist = {}
	
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

		if (name == "Arcane" or name == "Frost") and offset and numSlots then
			for j = offset + 1, offset + numSlots do
				local spell_name = nil
				if C_SpellBook and C_SpellBook.GetSpellBookItemName then
					spell_name = C_SpellBook.GetSpellBookItemName(j, Enum.SpellBookSpellBank.Player)
				elseif GetSpellInfo then
					spell_name = GetSpellInfo(j, "")
				end

				if spell_name then
					table.insert(pyromancer_achievement.blacklist, spell_name)
				end
			end
		end
	end
end

-- Register Definitions
pyromancer_achievement:SetScript("OnEvent", function(self, event, ...)
	local arg = { ... }
	if event == "SPELLS_CHANGED" then
		pyromancer_achievement:GatherBlackList()
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unit, _, spell_id = ...
		if unit ~= "player" or not spell_id then
			return
		end
		
		local spell_name = GetSpellInfo(spell_id)
		if not spell_name then return end -- Camelot nil safety
		
		for i, blacklist_spell in ipairs(pyromancer_achievement.blacklist) do
			if spell_name == blacklist_spell then
				pyromancer_achievement.fail_function_executor.Fail(pyromancer_achievement.name)
				return
			end
		end
	end
end)