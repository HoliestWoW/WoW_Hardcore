local _G = _G
local void_servant_achievement = CreateFrame("Frame")
_G.achievements.VoidServant = void_servant_achievement

-- General info
void_servant_achievement.name = "VoidServant"
void_servant_achievement.title = "Void Servant"
void_servant_achievement.pts = 10
void_servant_achievement.class = "Priest"
void_servant_achievement.icon_path = "Interface\\Addons\\Hardcore\\Media\\icon_void_servant.blp"
void_servant_achievement.description =
	"Complete the Hardcore challenge without at any point using an ability within the “Holy” tab of your spellbook. Only spells listed under “Shadow Magic”, “Discipline”, or “General” are allowed. You are allowed to put points into all talent trees, but active abilities thus unlocked that are in the “Holy” tab of your spellbook are not allowed to be used."

-- Registers
function void_servant_achievement:Register(fail_function_executor)
	void_servant_achievement:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	void_servant_achievement:RegisterEvent("SPELLS_CHANGED")
	void_servant_achievement:GatherBlackList()
	void_servant_achievement.fail_function_executor = fail_function_executor
end

function void_servant_achievement:Unregister()
	void_servant_achievement:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	void_servant_achievement:UnregisterEvent("SPELLS_CHANGED")
end

function void_servant_achievement:GatherBlackList()
	void_servant_achievement.blacklist = {}
	
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

		if name == "Holy" and offset and numSlots then
			for j = offset + 1, offset + numSlots do
				local spell_name = nil
				if C_SpellBook and C_SpellBook.GetSpellBookItemName then
					spell_name = C_SpellBook.GetSpellBookItemName(j, Enum.SpellBookSpellBank.Player)
				elseif GetSpellInfo then
					spell_name = GetSpellInfo(j, "")
				end

				if spell_name then
					table.insert(void_servant_achievement.blacklist, spell_name)
				end
			end
		end
	end
end

-- Register Definitions
void_servant_achievement:SetScript("OnEvent", function(self, event, ...)
	local arg = { ... }
	if event == "SPELLS_CHANGED" then
		void_servant_achievement:GatherBlackList()
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unit, _, spell_id = ...
		if unit ~= "player" or not spell_id then
			return
		end
		
		local spell_name = GetSpellInfo(spell_id)
		if not spell_name then return end
		
		for i, blacklist_spell in ipairs(void_servant_achievement.blacklist) do
			if spell_name == blacklist_spell then
				void_servant_achievement.fail_function_executor.Fail(void_servant_achievement.name)
				return
			end
		end
	end
end)