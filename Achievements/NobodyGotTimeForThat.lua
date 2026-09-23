local _G = _G
local nobody_got_time_for_that_achievement = CreateFrame("Frame")
_G.achievements.NobodyGotTimeForThat = nobody_got_time_for_that_achievement

local profession_names = {
	["Alchemy"] = 1,
	["Tailoring"] = 1,
	["Blacksmithing"] = 1,
	["Cooking"] = 1,
	["Enchanting"] = 1,
	["Engineering"] = 1,
	["Herbalism"] = 1,
	["First Aid"] = 1,
	["Fishing"] = 1,
	["Mining"] = 1,
	["Leatherworking"] = 1,
	["Skinning"] = 1,
	["Jewelcrafting"] = 1,
	["Inscription"] = 1,
}

-- General info
nobody_got_time_for_that_achievement.name = "NobodyGotTimeForThat"
nobody_got_time_for_that_achievement.pts = 25
nobody_got_time_for_that_achievement.title = "Nobody Got Time For That"
nobody_got_time_for_that_achievement.class = "All"
nobody_got_time_for_that_achievement.icon_path = "Interface\\Addons\\Hardcore\\Media\\icon_nobody_got_time_for_that.blp"
nobody_got_time_for_that_achievement.description =
	"Complete the Hardcore challenge without learning or using any professions. Secondary professions such as Cooking, Fishing and First Aid are not allowed. Lockpicking, Poisons, and Beast Training are class skills, not professions."
if _G["HardcoreBuildLabel"] == "WotLK" or _G["HardcoreBuildLabel"] == "Cata" then
	nobody_got_time_for_that_achievement.warnings = {
		"Note: Unavailable for Death Knights.",
	}
end

-- Registers
function nobody_got_time_for_that_achievement:Register(fail_function_executor)
	nobody_got_time_for_that_achievement:RegisterEvent("SKILL_LINES_CHANGED")
	nobody_got_time_for_that_achievement:RegisterEvent("PLAYER_ENTERING_WORLD")
	nobody_got_time_for_that_achievement.fail_function_executor = fail_function_executor
end

function nobody_got_time_for_that_achievement:Unregister()
	nobody_got_time_for_that_achievement:UnregisterEvent("SKILL_LINES_CHANGED")
	nobody_got_time_for_that_achievement:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

-- Register Definitions
nobody_got_time_for_that_achievement:SetScript("OnEvent", function(self, event, ...)
	if event == "SKILL_LINES_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
		-- Modern WoW / Cataclysm / Camelot API Check
		if GetProfessions then
			local profs = {GetProfessions()}
			for _, profIndex in pairs(profs) do
				if type(profIndex) == "number" then
					local name = GetProfessionInfo(profIndex)
					if name and profession_names[name] then
						Hardcore:Print("Learned " .. name .. " profession.")
						nobody_got_time_for_that_achievement.fail_function_executor.Fail(
							nobody_got_time_for_that_achievement.name
						)
						return
					end
				end
			end
		-- Classic Era API Fallback Check
		elseif GetNumSkillLines and GetSkillLineInfo then
			for i = 1, GetNumSkillLines() do
				local skillName = GetSkillLineInfo(i)
				if skillName and profession_names[skillName] then
					Hardcore:Print("Learned " .. skillName .. " profession.")
					nobody_got_time_for_that_achievement.fail_function_executor.Fail(
						nobody_got_time_for_that_achievement.name
					)
					return
				end
			end
		end
	end
end)