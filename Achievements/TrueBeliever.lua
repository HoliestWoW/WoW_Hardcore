local _G = _G
local true_believer_achievement = CreateFrame("Frame")
_G.achievements.TrueBeliever = true_believer_achievement

-- General info
true_believer_achievement.name = "TrueBeliever"
true_believer_achievement.title = "True Believer"
true_believer_achievement.class = "Priest"
true_believer_achievement.pts = 10
true_believer_achievement.icon_path = "Interface\\Addons\\Hardcore\\Media\\icon_true_believer.blp"
true_believer_achievement.description =
	"Complete the Hardcore challenge without at any point using an ability within the “Shadow Magic” tab of your spellbook. Only spells listed under “Holy”, “Discipline”, or “General” are allowed. You are allowed to put points into all talent trees, but active abilities thus unlocked that are in the “Shadow Magic” tab of your spellbook are not allowed to be used."

-- Registers
function true_believer_achievement:Register(fail_function_executor)
	true_believer_achievement:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	true_believer_achievement:RegisterEvent("SPELLS_CHANGED")
	true_believer_achievement:GatherBlackList()
	true_believer_achievement.fail_function_executor = fail_function_executor
end

function true_believer_achievement:Unregister()
	true_believer_achievement:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	true_believer_achievement:UnregisterEvent("SPELLS_CHANGED")
end

function true_believer_achievement:GatherBlackList()
	true_believer_achievement.blacklist = {}
	
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

		if name == "Shadow Magic" and offset and numSlots then
			for j = offset + 1, offset + numSlots do
				local spell_name = nil
				if C_SpellBook and C_SpellBook.GetSpellBookItemName then
					spell_name = C_SpellBook.GetSpellBookItemName(j, Enum.SpellBookSpellBank.Player)
				elseif GetSpellInfo then
					spell_name = GetSpellInfo(j, "")
				end

				if spell_name then
					table.insert(true_believer_achievement.blacklist, spell_name)
				end
			end
		end
	end
end

-- Register Definitions
true_believer_achievement:SetScript("OnEvent", function(self, event, ...)
	local arg = { ... }
	if event == "SPELLS_CHANGED" then
		true_believer_achievement:GatherBlackList()
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unit, _, spell_id = ...
		if unit ~= "player" or not spell_id then
			return
		end
		
		local spell_name = GetSpellInfo(spell_id)
		if not spell_name then return end
		
		for i, blacklist_spell in ipairs(true_believer_achievement.blacklist) do
			if spell_name == blacklist_spell then
				true_believer_achievement.fail_function_executor.Fail(true_believer_achievement.name)
				return
			end
		end
	end
end)