local _G = _G
local scavenger_achievement = CreateFrame("Frame")
_G.achievements.Scavenger = scavenger_achievement

-- General info
scavenger_achievement.name = "Scavenger"
scavenger_achievement.title = "Scavenger"
scavenger_achievement.class = "All"
scavenger_achievement.pts = 20
scavenger_achievement.icon_path = "Interface\\Addons\\Hardcore\\Media\\icon_scavenger.blp"
scavenger_achievement.description =
	"Complete the Hardcore challenge without at any point using, consuming, or equipping an item that you have not looted from a mob, chest, or loot container, or crafted or conjured yourself. You are not allowed to ever buy any items from vendors, nor use, consume, or equip items rewarded by a quest (items provided for a quest can be used, consumed, or equipped). This includes consumables, projectiles, trade goods, and containers. All items you start with can be used, consumed, and equipped, including Hearthstone."

scavenger_achievement.restricted_game_versions = {
	["Classic"] = 1,
	["TBC"] = 1,
	["WotLK"] = 1,
	["Cata"] = 1,
}
scavenger_achievement.blacklist = {} -- FIXED: Initialized as a table instead of nil to prevent indexing errors

-- Internal states
scavenger_achievement.item_pushed = false
scavenger_achievement.merchant_updated = false
scavenger_achievement.active = false

local merchant_item_cache_ = {}
local received_item = nil

-- Registers
function scavenger_achievement:Register(fail_function_executor)
	scavenger_achievement:RegisterEvent("MERCHANT_SHOW")
	scavenger_achievement:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	scavenger_achievement:RegisterEvent("MERCHANT_UPDATE")
	scavenger_achievement:RegisterEvent("ITEM_PUSH")
	scavenger_achievement:RegisterEvent("QUEST_TURNED_IN")
	scavenger_achievement.fail_function_executor = fail_function_executor

	scavenger_achievement.item_pushed = false
	scavenger_achievement.merchant_updated = false
	scavenger_achievement.active = true
end

function scavenger_achievement:Unregister()
	scavenger_achievement:UnregisterEvent("MERCHANT_SHOW")
	scavenger_achievement:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
	scavenger_achievement:UnregisterEvent("MERCHANT_UPDATE")
	scavenger_achievement:UnregisterEvent("ITEM_PUSH")

	scavenger_achievement.item_pushed = false
	scavenger_achievement.merchant_updated = false
	scavenger_achievement.active = false
end

local function AddQuestItemsToBlacklist( quest_id )
	if scavenger_achievement.blacklist == nil then
		scavenger_achievement.blacklist = {}
	end
	if quest_id ~= nil then
		local num_items = GetNumQuestLogRewards( quest_id )
		for g = 1, num_items do
			local itemName, itemTexture, numItems, quality, isUsable, itemID = GetQuestLogRewardInfo(g, quest_id)
			if itemName then
				scavenger_achievement.blacklist[itemName] = 1
			end
		end
	end
end

function scavenger_achievement:GenerateBlacklist()
    if not GetMerchantItemInfo and not (C_MerchantFrame and C_MerchantFrame.GetMerchantItemInfo) then
        return 
    end
	local completed = GetQuestsCompleted()
	for i, _ in pairs(completed) do
		AddQuestItemsToBlacklist(i)
	end
end

local function CheckPurchase()
	if
		scavenger_achievement.item_pushed
		and scavenger_achievement.merchant_updated
		and scavenger_achievement.active
		and received_item
		and merchant_item_cache_[tostring(received_item)]
	then
		scavenger_achievement.fail_function_executor.Fail(scavenger_achievement.name)
	end
end

-- Register Definitions
scavenger_achievement:SetScript("OnEvent", function(self, event, ...)
	local arg = { ... }
	if event == "MERCHANT_SHOW" then
		for i = 1, 12 do
			if _G["MerchantItem" .. i] then
				_G["MerchantItem" .. i]:Hide()
			end
		end
	elseif event == "MERCHANT_UPDATE" then
		scavenger_achievement.merchant_updated = true
		for i = 1, 12 do
			if _G["MerchantItem" .. i] then
				_, texture_path = GetMerchantItemInfo(i)
				if texture_path then
					merchant_item_cache_[tostring(texture_path)] = 1
				end
			end
		end
		C_Timer.After(1.0, function()
			CheckPurchase()
			scavenger_achievement.merchant_updated = false
			merchant_item_cache_ = {}
		end)
	elseif event == "ITEM_PUSH" then
		scavenger_achievement.item_pushed = true
		received_item = arg[2]
		C_Timer.After(1.0, function()
			CheckPurchase()
			scavenger_achievement.item_pushed = false
			received_item = nil
		end)
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		if arg[2] == true then
			return
		end
		
		-- Ensure blacklist table exists and is populated
		if scavenger_achievement.blacklist == nil then
			scavenger_achievement.blacklist = {}
			scavenger_achievement:GenerateBlacklist()
		end
		
		local item_id = GetInventoryItemID("player", arg[1])
		if item_id ~= nil then
			local item_name = GetItemInfo(item_id)
			-- Safe index lookup with nil safety
			if item_name and scavenger_achievement.blacklist[item_name] ~= nil then
				Hardcore:Print("Equipped quest reward " .. item_name .. ".")
				scavenger_achievement.fail_function_executor.Fail(scavenger_achievement.name)
			end
		end
	elseif event == "QUEST_TURNED_IN" then
		local quest_id = arg[1]
		if quest_id ~= nil then
			AddQuestItemsToBlacklist( quest_id )
		end
	end
end)