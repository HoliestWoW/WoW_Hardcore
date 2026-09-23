local CLASS_COLOR_BY_NAME = {
	["DRUID"] = "FF7C0A",
	["WARLOCK"] = "8788EE",
	["WARRIOR"] = "C69B6D",
	["MAGE"] = "3FC7EB",
	["HUNTER"] = "AAD372",
	["PRIEST"] = "FFFFFF",
	["SHAMAN"] = "0070DD",
	["PALADIN"] = "F48CBA",
	["ROGUE"] = "FFF468",
	["DEATHKNIGHT"] = "C41E3A",
	["MONK"] = "00FF96",
	["GENERAL"] = "FFFFFF",
}
local AceGUI = LibStub("AceGUI-3.0")
local ICON_SIZE = 39

local Panel, f, f2, TabGUI
local tab_gui_left, tab_gui_middle, tab_gui_right
local inactive_tab_gui_left, inactive_tab_gui_middle, inactive_tab_gui_right
local isModernUI, Hardcore_OldTitleText

-- Safely initialize after login to prevent global file-load taint
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function()
    -- Prevent duplicate initialization
    if Panel then return end

    isModernUI = (_G["HardcoreBuildLabel"] == "Cata") or _G.HC_IS_CAMELOT or (CharacterFrame.NineSlice ~= nil)

    -- Anchor Panel to CharacterFrame for BOTH versions to fix Era layering
    Panel = CreateFrame("Frame", nil, CharacterFrame)
    Panel:Hide()

    if not isModernUI then
        -- CLASSIC ERA LOGIC
        local frameOffsetX = 2
        local frameOffsetY = -1

        Panel:SetPoint("CENTER", 0, 0)
        Panel:SetAllPoints(CharacterFrame)

        -- Shrink native tabs to make room for the HC tab
        if _G["CharacterFrameTab3Text"] then _G["CharacterFrameTab3Text"]:SetText("Rep.") end
        if _G["TokenFrame"] ~= nil and _G["CharacterFrameTab5Text"] ~= nil and _G["CharacterFrameTab5Text"]:GetText() == "Currency" then
            _G["CharacterFrameTab5Text"]:SetText("Curr.")
        end

        f = CreateFrame("Frame", "HardcoreOuterFrame", Panel)
        f:SetFrameStrata("HIGH")
        f:SetSize(400, 400)
        f:SetPoint("CENTER")
        f:Hide()

        local t = f:CreateTexture(nil, "BACKGROUND")
        t:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft")
        t:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", frameOffsetX, frameOffsetY)
        t:SetSize(256, 256)

        local tr = f:CreateTexture(nil, "BACKGROUND")
        tr:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight")
        tr:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", frameOffsetX + 256, frameOffsetY)
        tr:SetSize(128, 256)

        local bl = f:CreateTexture(nil, "BACKGROUND")
        bl:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomLeft")
        bl:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", frameOffsetX, frameOffsetY - 256)
        bl:SetSize(256, 256)

        local br = f:CreateTexture(nil, "BACKGROUND")
        br:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight")
        br:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", frameOffsetX + 256, frameOffsetY - 256)
        br:SetSize(128, 256)

        local title_text = f:CreateFontString(nil, "ARTWORK")
        title_text:SetFont("Interface\\Addons\\Hardcore\\Media\\BreatheFire.ttf", 22, "")
        title_text:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", frameOffsetX + 148, frameOffsetY - 44)
        title_text:SetTextColor(1, 0.82, 0)
        title_text:SetText("Hardcore")

        TabGUI = CreateFrame("Button", "CharacterFrameTab" .. (CharacterFrame.numTabs + 1), CharacterFrame)
        _G["HardcoreCharacterTab"] = TabGUI

        TabGUI.text = TabGUI:CreateFontString(nil, "OVERLAY")
        TabGUI.text:SetDrawLayer("ARTWORK", 8)
        TabGUI.text:SetFontObject(GameFontNormalSmall)
        TabGUI.text:SetPoint("CENTER", 0, 1)
        TabGUI.text:SetText("HC")

        local buttonActiveOffset = -5
        local buttonVertSizeActive = 32
        local buttonVertSizeInactive = 32

        tab_gui_left = TabGUI:CreateTexture()
        tab_gui_left:SetDrawLayer("ARTWORK", 1)
        tab_gui_left:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ActiveTab")
        tab_gui_left:SetSize(25, buttonVertSizeActive)
        tab_gui_left:SetRotation(3.14)
        tab_gui_left:SetTexCoord(0.8, 1.0, 1.0, 0.0)
        tab_gui_left:SetPoint("TOPLEFT", 0, buttonActiveOffset)

        tab_gui_middle = TabGUI:CreateTexture(nil, "ARTWORK")
        tab_gui_middle:SetDrawLayer("ARTWORK", 1)
        tab_gui_middle:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ActiveTab")
        tab_gui_middle:SetSize(25, buttonVertSizeActive)
        tab_gui_middle:SetRotation(3.14)
        tab_gui_middle:SetTexCoord(0.8, 0.20, 1.0, 0.0)
        tab_gui_middle:SetPoint("TOP", 0, buttonActiveOffset)

        tab_gui_right = TabGUI:CreateTexture(nil, "ARTWORK")
        tab_gui_right:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ActiveTab")
        tab_gui_right:SetSize(25, buttonVertSizeActive)
        tab_gui_right:SetRotation(3.14)
        tab_gui_right:SetTexCoord(0.0, 0.20, 1.0, 0.0)
        tab_gui_right:SetPoint("TOPRIGHT", 0, buttonActiveOffset)

        tab_gui_left:Hide()
        tab_gui_middle:Hide()
        tab_gui_right:Hide()

        inactive_tab_gui_left = TabGUI:CreateTexture(nil, "ARTWORK")
        inactive_tab_gui_left:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-InactiveTab")
        inactive_tab_gui_left:SetSize(25, buttonVertSizeInactive)
        inactive_tab_gui_left:SetRotation(3.14)
        inactive_tab_gui_left:SetTexCoord(0.8, 1.0, 1.0, 0.0)
        inactive_tab_gui_left:SetPoint("TOPLEFT", 0, -9)

        inactive_tab_gui_middle = TabGUI:CreateTexture(nil, "ARTWORK")
        inactive_tab_gui_middle:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-InactiveTab")
        inactive_tab_gui_middle:SetSize(25, buttonVertSizeInactive)
        inactive_tab_gui_middle:SetRotation(3.14)
        inactive_tab_gui_middle:SetTexCoord(0.8, 0.20, 1.0, 0.0)
        inactive_tab_gui_middle:SetPoint("TOP", 0, -9)

        inactive_tab_gui_right = TabGUI:CreateTexture(nil, "ARTWORK")
        inactive_tab_gui_right:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-InactiveTab")
        inactive_tab_gui_right:SetSize(25, buttonVertSizeInactive)
        inactive_tab_gui_right:SetRotation(3.14)
        inactive_tab_gui_right:SetTexCoord(0.0, 0.20, 1.0, 0.0)
        inactive_tab_gui_right:SetPoint("TOPRIGHT", 0, -9)

        local tab_higlight = TabGUI:CreateTexture(nil, "OVERLAY")
        tab_higlight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-RealHighlight")
        tab_higlight:SetSize(46, 43)
        tab_higlight:SetRotation(3.14)
        tab_higlight:SetTexCoord(1.0, 0.0, 1.0, 0.0)
        tab_higlight:SetPoint("TOP", 0, 0)
        TabGUI:SetHighlightTexture(tab_higlight, "ADD")
        TabGUI:SetWidth(60)
        TabGUI:SetHeight(50)
        TabGUI:Show()

        hooksecurefunc(CharacterFrame, "Show", function()
            local rightMostVisible = "CharacterFrameTab1Text"
            for i = 2, 5 do
                local tabLabel = "CharacterFrameTab" .. i .. "Text"
                if _G[tabLabel] ~= nil and _G[tabLabel]:IsVisible() then
                    rightMostVisible = tabLabel
                end
            end
            local x = _G[rightMostVisible]:GetRight() - _G["CharacterFrame"]:GetLeft()
            local y = _G[rightMostVisible]:GetTop() - _G["CharacterFrame"]:GetTop()
            TabGUI:SetPoint("TOPLEFT", CharacterFrame, x+4, y+19)
            TabGUI:Show()
        end)

        hooksecurefunc(CharacterFrame, "Hide", function()
            TabGUI:Hide()
        end)

    else
        -- MODERN CAMELOT UI SETUP
        Panel:SetAllPoints(CharacterFrame)

        Panel.LeftInset = CreateFrame("Frame", nil, _G.CharacterFrameLeftPaneHost or Panel)
        Panel.LeftInset:SetAllPoints()
        Panel.LeftInset:SetFrameLevel((_G.CharacterFrameLeftPaneHost and _G.CharacterFrameLeftPaneHost:GetFrameLevel() or 1) + 20)
        Panel.LeftInset:EnableMouse(true)
        Panel.LeftInset:Hide()

        local leftBg = Panel.LeftInset:CreateTexture(nil, "BACKGROUND")
        leftBg:SetAllPoints()
        leftBg:SetColorTexture(0.06, 0.06, 0.06, 1.0)

        Panel.RightInset = CreateFrame("Frame", nil, _G.CharacterFrameRightPaneHost or Panel)
        Panel.RightInset:SetAllPoints()
        Panel.RightInset:SetFrameLevel((_G.CharacterFrameRightPaneHost and _G.CharacterFrameRightPaneHost:GetFrameLevel() or 1) + 20)
        Panel.RightInset:SetClipsChildren(true)
        Panel.RightInset:EnableMouse(true)
        Panel.RightInset:Hide()

        local rightBg = Panel.RightInset:CreateTexture(nil, "BACKGROUND")
        rightBg:SetAllPoints()
        rightBg:SetColorTexture(0.06, 0.06, 0.06, 1.0)

        local emblem = Panel.RightInset:CreateTexture(nil, "ARTWORK")
        emblem:SetSize(128, 128)
        emblem:SetPoint("CENTER", 0, 20)
        emblem:SetTexture("Interface\\AddOns\\Hardcore\\Media\\wowhc-emblem-white-red.blp")

        local title = Panel.RightInset:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
        title:SetPoint("TOP", emblem, "BOTTOM", 0, -10)
        title:SetText("Hardcore")

        local baseTab
        for i = 10, 1, -1 do
            if _G["CharacterFrameModeTab"..i] then
                baseTab = _G["CharacterFrameModeTab"..i]
                break
            end
        end

        if baseTab then
            TabGUI = CreateFrame("Button", "HardcoreCharacterTab", baseTab:GetParent())
            local w, h = baseTab:GetSize()
            TabGUI:SetSize((w and w > 0) and w or 32, (h and h > 0) and h or 32)
            TabGUI:SetPoint("TOPLEFT", baseTab, "BOTTOMLEFT", 0, 0)

            TabGUI.Icon = TabGUI:CreateTexture(nil, "ARTWORK")
            TabGUI.Icon:SetPoint("TOPLEFT", TabGUI, "TOPLEFT", 3, -7)
            TabGUI.Icon:SetPoint("BOTTOMRIGHT", TabGUI, "BOTTOMRIGHT", -11, 7)
            TabGUI.Icon:SetTexture("Interface\\AddOns\\Hardcore\\Media\\logo-emblem.blp")

            for _, region in ipairs({baseTab:GetRegions()}) do
                if region:IsObjectType("Texture") then
                    local atlas = region:GetAtlas()
                    if atlas == "common-sidetab" then
                        if not TabGUI.Background then
                            TabGUI.Background = TabGUI:CreateTexture(nil, "BACKGROUND")
                            TabGUI.Background:SetAllPoints()
                            TabGUI.Background:SetAtlas(atlas)
                        end
                    elseif atlas == "common-sidetab-selected" then
                        if not TabGUI.TabGlow then
                            TabGUI.TabGlow = TabGUI:CreateTexture(nil, "OVERLAY")
                            TabGUI.TabGlow:SetAllPoints()
                            TabGUI.TabGlow:SetAtlas(atlas)
                            TabGUI.TabGlow:SetBlendMode("ADD")
                            TabGUI.TabGlow:Hide()
                        end
                    elseif atlas == "common-sidetab-hover" then
                        if not TabGUI.HighlightTexture then
                            TabGUI.HighlightTexture = TabGUI:CreateTexture(nil, "HIGHLIGHT")
                            TabGUI.HighlightTexture:SetAllPoints()
                            TabGUI.HighlightTexture:SetAtlas(atlas)
                            TabGUI.HighlightTexture:SetBlendMode("ADD")
                            TabGUI.HighlightTexture:Hide()
                        end
                    end
                end
            end

            TabGUI:SetScript("OnEnter", function(self) 
                if self.HighlightTexture then self.HighlightTexture:Show() end 
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Hardcore", 1, 0.82, 0)
                GameTooltip:Show()
            end)
            
            TabGUI:SetScript("OnLeave", function(self) 
                if self.HighlightTexture then self.HighlightTexture:Hide() end 
                GameTooltip:Hide()
            end)
        else
            TabGUI = CreateFrame("Button", "HardcoreCharacterTab", CharacterFrame, "UIPanelButtonTemplate")
            TabGUI:SetSize(60, 22)
            TabGUI:SetPoint("TOPRIGHT", CharacterFrame, "TOPRIGHT", -40, -40)
            TabGUI:SetText("HC")
        end
        TabGUI:Show()
    end

    f2 = AceGUI:Create("HardcoreFrameEmpty")
    if isModernUI then
        f2.frame:SetParent(Panel.LeftInset)
        f2.frame:ClearAllPoints()
        f2.frame:SetPoint("TOPLEFT", Panel.LeftInset, "TOPLEFT", 5, -5)
    else
        -- CLASSIC ERA LOGIC
        local frameOffsetX = 2
        local frameOffsetY = -1
        f2:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", frameOffsetX, frameOffsetY - 40)
        f2:SetWidth(360)
        f2:SetHeight(350)
    end
    f2:Hide()

    TabGUI:SetScript("OnClick", function(self)
        if not isModernUI then
            for i = 1, 5 do
                if _G["CharacterFrameTab"..i] then
                    PanelTemplates_DeselectTab(_G["CharacterFrameTab"..i])
                end
            end
            CharacterFrame.activeTab = 6

            local nativePanels = {
                "PaperDollFrame", 
                "PetPaperDollFrame",
                "HonorFrame",
                "SkillFrame",
                "ReputationFrame",
                "TokenFrame"
            }
            for _, panelName in ipairs(nativePanels) do
                if _G[panelName] then
                    _G[panelName]:Hide()
                end
            end
        else
            if self.TabGlow then
                self.TabGlow:Show()
                for i = 1, 10 do
                    local tab = _G["CharacterFrameModeTab"..i] or _G["CharacterFrameTab"..i]
                    if tab then
                        local nativeGlow = tab.TabGlow or tab.SelectedTexture
                        if nativeGlow then nativeGlow:Hide() end
                        for _, region in ipairs({tab:GetRegions()}) do
                            if region:IsObjectType("Texture") then
                                local atlas = region:GetAtlas()
                                if atlas and (atlas:find("selected") or atlas:find("Glow")) then
                                    region:Hide()
                                end
                            end
                        end
                    end
                end
            end

            local nativePanels = { 
                "PaperDollFrame", 
                "ReputationFrame", 
                "SkillsFrame", 
                "PVPRankFrame", 
                "TokenFrame",
                "PetPaperDollFrame",
                "StatisticsFrame",
                "CharacterStatsPane",
                "HonorFrame",
                "SkillFrame"
            }
            for _, panelName in ipairs(nativePanels) do
                if _G[panelName] then
                    _G[panelName]:Hide()
                end
            end
        end

        ShowCharacterHC(Hardcore_Character)
    end)

    if isModernUI then
        for i = 1, 10 do
            local tab = _G["CharacterFrameModeTab"..i] or _G["CharacterFrameTab"..i]
            if tab then
                pcall(function()
                    tab:HookScript("OnClick", function()
                        if TabGUI and TabGUI.TabGlow then
                            TabGUI.TabGlow:Hide()
                        end
                        for _, region in ipairs({tab:GetRegions()}) do
                            if region:IsObjectType("Texture") then
                                local atlas = region:GetAtlas()
                                if atlas and (atlas:find("selected") or atlas:find("Glow")) then
                                    region:Show()
                                end
                            end
                        end
                    end)
                end)
            end
        end
    end

    TabGUI:RegisterEvent("PLAYER_ENTER_COMBAT")
    TabGUI:RegisterEvent("PLAYER_LEAVE_COMBAT")
    TabGUI:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_ENTER_COMBAT" then
            if not isModernUI and TabGUI.text then
                TabGUI.text:SetText("|c00808080HC|r")
            end
            HideCharacterHC()
            TabGUI:Disable()
        elseif event == "PLAYER_LEAVE_COMBAT" then
            if not isModernUI and TabGUI.text then
                TabGUI.text:SetText("HC")
            end
            TabGUI:Enable()
        end
    end)

    hooksecurefunc(CharacterFrame, "Hide", function(self)
        HideCharacterHC()
    end)

    if not isModernUI then
        hooksecurefunc("PanelTemplates_SetTab", function(frame, id)
            if frame == CharacterFrame and id and id ~= 6 then
                if Panel and Panel:IsShown() then
                    HideCharacterHC()
                end
            end
        end)
    end
end)

function extractDetails(str, ignoreKeys)
	if str == nil then return {} end
	str = str:gsub("^%s*%((.+)%)%s*$", "%1")
	local details_table = {}
	for key, value in str:gmatch("(%S+)=(%S+)") do
		local ignore = false
		for _, ignoreKey in ipairs(ignoreKeys or {}) do
			if key == ignoreKey then
				ignore = true
				break
			end
		end
		if not ignore then
			details_table[key] = value
		end
	end
	return details_table
end

function formatDetails(details_table)
	local str = ""
	for key, value in pairs(details_table) do
	  str = str .. key .. " = " .. value .. ", "
	end
	return str:sub(1, -3)
end

function UpdateCharacterHC(_hardcore_character, _player_name, _version, frame_to_update, _player_class, _player_class_en, _player_level)
	frame_to_update:ReleaseChildren()
	if _hardcore_character == nil then return end

	local character_meta_data_container = AceGUI:Create("SimpleGroup")
	character_meta_data_container:SetRelativeWidth(1.0)
	character_meta_data_container:SetHeight(200)
	character_meta_data_container:SetLayout("List")
	frame_to_update:AddChild(character_meta_data_container)

	local character_name = AceGUI:Create("HardcoreClassTitleLabel")
	character_name:SetRelativeWidth(1.0)
	character_name:SetHeight(60)
	character_name:SetText("\n" .. _player_name .. "\n\n")
	character_name:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
	character_meta_data_container:AddChild(character_name)

	local team_title = AceGUI:Create("HardcoreClassTitleLabel")
	team_title:SetRelativeWidth(1.0)
	team_title:SetHeight(60)
	local mode_type_str = "unknown"
	local teammate_1 = "missing_team"
	local teammate_2 = "unknown"

	if _hardcore_character.team ~= nil then
		teammate_1 = _hardcore_character.team[1] or "unknown"
		teammate_2 = _hardcore_character.team[2] or "unknown"
	end
	if _hardcore_character.party_mode ~= nil then
		if _hardcore_character.party_mode == "Solo" then
			mode_type_str = "Solo"
		elseif _hardcore_character.party_mode == "Duo" then
			mode_type_str = "Duo with " .. teammate_1
		elseif _hardcore_character.party_mode == "Trio" then
			mode_type_str = "Trio with " .. teammate_1 .. " and " .. teammate_2
		else
			mode_type_str = "|c00FF0000" .. _hardcore_character.party_mode .. "|r"
		end
	end
	team_title:SetText(mode_type_str)
	team_title:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
	character_meta_data_container:AddChild(team_title)

	local level_title_text = AceGUI:Create("HardcoreClassTitleLabel")
	level_title_text:SetRelativeWidth(1.0)
	level_title_text:SetHeight(60)
	local level_text = _player_level or "?"
	local class_text
	if _player_class_en ~= nil and _player_class ~= nil then
		class_text = "|c00" .. CLASS_COLOR_BY_NAME[_player_class_en] .. _player_class .. "|r"
	else
		class_text = "?"
	end
	level_title_text:SetText("Level " .. level_text .. " " .. class_text)
	level_title_text:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
	character_meta_data_container:AddChild(level_title_text)

	local creation_date_label = AceGUI:Create("HardcoreClassTitleLabel")
	creation_date_label:SetRelativeWidth(1.0)
	creation_date_label:SetHeight(60)
	local start_date = "(unknown - data loss / previous version)"
	if _hardcore_character.first_recorded ~= nil and _hardcore_character.first_recorded ~= -1 then
		start_date = date("%m/%d/%y", _hardcore_character.first_recorded)
		if start_date == nil then
			start_date = "(unknown - data loss / previous version)"
		end
	end
	creation_date_label:SetText("Started on " .. start_date)
	creation_date_label:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
	character_meta_data_container:AddChild(creation_date_label)

	local version_name = AceGUI:Create("HardcoreClassTitleLabel")
	version_name:SetRelativeWidth(1.0)
	version_name:SetHeight(60)
	local version = _version
	local game_version = _hardcore_character.game_version or _G["HardcoreBuildLabel"]
	version_name:SetText("Addon version: " .. version .. ", " .. game_version)
	version_name:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
	character_meta_data_container:AddChild(version_name)

	local filtered_status = _hardcore_character.verification_status
	local filtered_details = _hardcore_character.verification_details

	if _player_name ~= UnitName("player") then
		local ignoreKeys = {"tracked_time", "deaths", "appeals", "repeat_dung", "overlvl_dung"}
		local details_table = extractDetails(_hardcore_character.verification_details, ignoreKeys)
		filtered_details = formatDetails(details_table)

		if filtered_details == "" and _hardcore_character.verification_status == "PASS" then
			filtered_status = "|cff1eff0cPASS|r"
		elseif filtered_details == "" and _hardcore_character.verification_status == "FAIL" then
			filtered_status = "|cffff8000PENDING|r"
		elseif _hardcore_character.verification_status == "FAIL" then
			filtered_status = "|cffff3f40FAIL|r"
		else
			filtered_status = "|cff99ff99UNKNOWN|r\n(previous addon version)"
		end
	end

	if _hardcore_character.hardcore_player_name ~= nil and _hardcore_character.hardcore_player_name ~= "" then
		local hc_tag_f = AceGUI:Create("HardcoreClassTitleLabel")
		hc_tag_f:SetRelativeWidth(1.0)
		hc_tag_f:SetHeight(60)
		hc_tag_f:SetText("HC Tag: " .. _hardcore_character.hardcore_player_name)
		hc_tag_f:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
		character_meta_data_container:AddChild(hc_tag_f)
	end

	local verif_msg = "\n\nVerification status: \n\n"
	if _hardcore_character.verification_status == nil then
		verif_msg = verif_msg .. "(unknown - version not supported)"
	else
		verif_msg = verif_msg .. filtered_status
	end

	local hc_tag_g = AceGUI:Create("HardcoreClassTitleLabel")
	hc_tag_g:SetRelativeWidth(1.0)
	hc_tag_g:SetHeight(60)
	hc_tag_g:SetText(verif_msg)
	hc_tag_g:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
	character_meta_data_container:AddChild(hc_tag_g)

	local verif_msg2 = ""
	if _hardcore_character.verification_details == nil then
		verif_msg2 = verif_msg2 .. "(unknown - version not supported)"
	else
		verif_msg2 = verif_msg2 .. filtered_details
	end

	local hc_tag_h = AceGUI:Create("HardcoreClassTitleLabel")
	hc_tag_h:SetRelativeWidth(1.0)
	hc_tag_h:SetHeight(60)
	hc_tag_h:SetText(verif_msg2)
	hc_tag_h:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
	character_meta_data_container:AddChild(hc_tag_h)
	
	local explanatory_key_msg = "\n\nWhat does this mean?\n|cff1eff0cPASS|r - Valid HC Character, Dungeon-legal\n|cffff8000PENDING|r - Death or data appeal in progress\n|cffff3f40FAIL|r - Has failed the challenge - INVALID CHARACTER\n"
	
	local hc_tag_i = AceGUI:Create("HardcoreClassTitleLabel")
	hc_tag_i:SetRelativeWidth(1.0)
	hc_tag_i:SetHeight(60)
	hc_tag_i:SetText(explanatory_key_msg)
	hc_tag_i:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
	character_meta_data_container:AddChild(hc_tag_i)

	local v_buffer = AceGUI:Create("Label")
	v_buffer:SetRelativeWidth(1.0)
	v_buffer:SetHeight(50)
	v_buffer:SetText("\n")
	frame_to_update:AddChild(v_buffer)

	local achievements_container = AceGUI:Create("SimpleGroup")
	achievements_container:SetRelativeWidth(1.0)
	achievements_container:SetHeight(50)
	achievements_container:SetLayout("Flow")
	frame_to_update:AddChild(achievements_container)

	local _acheivement_pts = CalculateHCAchievementPts(_hardcore_character)
	local achievements_title = AceGUI:Create("HardcoreClassTitleLabel")
	achievements_title:SetRelativeWidth(1.0)
	achievements_title:SetHeight(40)
	achievements_title:SetText("Achievements - " .. _acheivement_pts .. " pts")
	achievements_title:SetFont("Interface\\Addons\\Hardcore\\Media\\BreatheFire.ttf", 16, "")
	achievements_container:AddChild(achievements_title)

	local padding = AceGUI:Create("Label")
	padding:SetRelativeWidth(0.05)
	padding:SetHeight(30)
	achievements_container:AddChild(padding)

	local scroll_container = AceGUI:Create("SimpleGroup")
	scroll_container:SetRelativeWidth(0.9)
	scroll_container:SetHeight(100)
	scroll_container:SetLayout("Fill")
	achievements_container:AddChild(scroll_container)

	local scroll_frame = AceGUI:Create("ScrollFrame")
	scroll_frame:SetLayout("Flow")
	scroll_frame:SetFullWidth(true)
	scroll_frame:SetFullHeight(true)
	scroll_container:AddChild(scroll_frame)

	if _hardcore_character.achievements ~= nil then
		for i, v in ipairs(_hardcore_character.achievements) do
			if _G.achievements[v] ~= nil then
				local achievement_icon = AceGUI:Create("Icon")
				achievement_icon:SetWidth(ICON_SIZE)
				achievement_icon:SetHeight(ICON_SIZE)
				achievement_icon:SetImage(_G.achievements[v].icon_path)
				achievement_icon:SetImageSize(ICON_SIZE, ICON_SIZE)
				achievement_icon.image:SetVertexColor(1, 1, 1)
				SetAchievementTooltip(achievement_icon, _G.achievements[v], _player_name)
				scroll_frame:AddChild(achievement_icon)
			end
		end
	end

	if _hardcore_character.passive_achievements ~= nil then
		for i, v in ipairs(_hardcore_character.passive_achievements) do
			if _G.passive_achievements[v] ~= nil then
				local achievement_icon = AceGUI:Create("Icon")
				achievement_icon:SetWidth(ICON_SIZE)
				achievement_icon:SetHeight(ICON_SIZE)
				achievement_icon:SetImage(_G.passive_achievements[v].icon_path)
				achievement_icon:SetImageSize(ICON_SIZE, ICON_SIZE)
				achievement_icon.image:SetVertexColor(1, 1, 1)
				SetAchievementTooltip(achievement_icon, _G.passive_achievements[v], _player_name)
				scroll_frame:AddChild(achievement_icon)
			end
		end
	end
end

function ShowCharacterHC(_hardcore_character)
    if not isModernUI and tab_gui_left then
        tab_gui_left:Show()
        tab_gui_middle:Show()
        tab_gui_right:Show()
        inactive_tab_gui_left:Hide()
        inactive_tab_gui_middle:Hide()
        inactive_tab_gui_right:Hide()
        TabGUI.text:SetFontObject(GameFontHighlightSmall)
        TabGUI.text:SetPoint("CENTER", 0, 3)
        TabGUI:SetFrameStrata("HIGH")
        TabGUI:Disable()
    end

    f2:ReleaseChildren()
    local class, class_en, _ = UnitClass("player")
    
    if isModernUI then
        f2:SetWidth(Panel.LeftInset:GetWidth() - 10)
        f2:SetHeight(Panel.LeftInset:GetHeight() - 10)

        if _G.CharacterFrameTitleText then
            Hardcore_OldTitleText = _G.CharacterFrameTitleText:GetText()
            _G.CharacterFrameTitleText:SetText("Hardcore")
        end
        
        if Panel.LeftInset then Panel.LeftInset:Show() end
        if Panel.RightInset then Panel.RightInset:Show() end
    end

    UpdateCharacterHC(
        _hardcore_character,
        UnitName("player"),
        (C_AddOns and C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata)("Hardcore", "Version"),
        f2,
        class,
        class_en,
        UnitLevel("player")
    )
    
    Panel:Show()
    if f and not isModernUI then f:Show() end
    f2:Show()
end

function HideCharacterHC()
    if not isModernUI and tab_gui_left then
        tab_gui_left:Hide()
        tab_gui_middle:Hide()
        tab_gui_right:Hide()
        inactive_tab_gui_left:Show()
        inactive_tab_gui_middle:Show()
        inactive_tab_gui_right:Show()
        TabGUI.text:SetFontObject(GameFontNormalSmall)
        TabGUI.text:SetPoint("CENTER", 0, 1)
        TabGUI:SetFrameStrata("MEDIUM")
        TabGUI:Enable()
    end

    if TabGUI and TabGUI.TabGlow then
        TabGUI.TabGlow:Hide()
    end

    if Panel then Panel:Hide() end
    if f then f:Hide() end
    if f2 then
        f2:Hide()
        f2:ReleaseChildren()
    end

    if isModernUI then
        if _G.CharacterFrameTitleText and Hardcore_OldTitleText then
            _G.CharacterFrameTitleText:SetText(Hardcore_OldTitleText)
        end
        
        if Panel.LeftInset then Panel.LeftInset:Hide() end
        if Panel.RightInset then Panel.RightInset:Hide() end
    end
end