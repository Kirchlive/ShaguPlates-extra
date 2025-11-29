-- load ShaguPlates environment
setfenv(1, ShaguPlates:GetEnvironment())

-- Settings GUI Module for ShaguPlates-extra
ShaguPlates:RegisterModule("settings", "vanilla:tbc:wotlk", function()

  -- Local references
  local C = ShaguPlates_config
  local T = T or {}

  -- GUI dimensions
  local GUI_WIDTH = 750
  local GUI_HEIGHT = 500
  local CONTENT_WIDTH = 540  -- Fixed width for content area

  -- Helper function to create a config entry
  local function CreateConfigWidget(parent, widgetType, category, subcat, key, label, desc, options)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetHeight(24)
    frame:SetWidth(CONTENT_WIDTH - 30)

    -- Label
    frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.label:SetPoint("LEFT", frame, "LEFT", 5, 0)
    frame.label:SetText(label)
    frame.label:SetTextColor(1, 1, 1)

    -- Get current value
    local function GetValue()
      if subcat then
        return C[category] and C[category][subcat] and C[category][subcat][key]
      else
        return C[category] and C[category][key]
      end
    end

    -- Set value
    local function SetValue(value)
      if subcat then
        if not C[category] then C[category] = {} end
        if not C[category][subcat] then C[category][subcat] = {} end
        C[category][subcat][key] = value
      else
        if not C[category] then C[category] = {} end
        C[category][key] = value
      end
    end

    if widgetType == "checkbox" then
      frame.input = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
      frame.input:SetWidth(20)
      frame.input:SetHeight(20)
      frame.input:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
      frame.input:SetChecked(GetValue() == "1")
      SkinCheckbox(frame.input)
      frame.input:SetScript("OnClick", function()
        SetValue(this:GetChecked() and "1" or "0")
      end)

    elseif widgetType == "text" then
      frame.input = CreateFrame("EditBox", nil, frame)
      frame.input:SetWidth(150)
      frame.input:SetHeight(20)
      frame.input:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
      frame.input:SetAutoFocus(false)
      frame.input:SetFontObject(GameFontWhite)
      frame.input:SetText(GetValue() or "")
      frame.input:SetScript("OnEscapePressed", function() this:ClearFocus() end)
      frame.input:SetScript("OnEnterPressed", function()
        SetValue(this:GetText())
        this:ClearFocus()
      end)
      CreateBackdrop(frame.input, nil, true)

    elseif widgetType == "number" then
      frame.input = CreateFrame("EditBox", nil, frame)
      frame.input:SetWidth(60)
      frame.input:SetHeight(20)
      frame.input:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
      frame.input:SetAutoFocus(false)
      frame.input:SetFontObject(GameFontWhite)
      frame.input:SetNumeric(false)
      frame.input:SetText(GetValue() or "0")
      frame.input:SetScript("OnEscapePressed", function() this:ClearFocus() end)
      frame.input:SetScript("OnEnterPressed", function()
        SetValue(this:GetText())
        this:ClearFocus()
      end)
      CreateBackdrop(frame.input, nil, true)

    elseif widgetType == "dropdown" then
      frame.input = CreateDropDownButton(nil, frame)
      frame.input:SetWidth(150)
      frame.input:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
      frame.input:SetMenu(options or {})
      frame.input:SetSelectionByText(GetValue() or "")
      frame.input.OnSelect = function(id, text)
        SetValue(text)
      end

    elseif widgetType == "color" then
      frame.input = CreateFrame("Button", nil, frame)
      frame.input:SetWidth(20)
      frame.input:SetHeight(20)
      frame.input:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
      CreateBackdrop(frame.input, nil, true)

      local colorStr = GetValue() or "1,1,1,1"
      local r, g, b, a = strsplit(",", colorStr)
      r, g, b, a = tonumber(r) or 1, tonumber(g) or 1, tonumber(b) or 1, tonumber(a) or 1

      frame.input.color = frame.input:CreateTexture(nil, "OVERLAY")
      frame.input.color:SetPoint("TOPLEFT", 3, -3)
      frame.input.color:SetPoint("BOTTOMRIGHT", -3, 3)
      frame.input.color:SetTexture(r, g, b, a)

      frame.input:SetScript("OnClick", function()
        local current = GetValue() or "1,1,1,1"
        local cr, cg, cb, ca = strsplit(",", current)
        cr, cg, cb, ca = tonumber(cr) or 1, tonumber(cg) or 1, tonumber(cb) or 1, tonumber(ca) or 1

        ColorPickerFrame:SetColorRGB(cr, cg, cb)
        ColorPickerFrame.hasOpacity = true
        ColorPickerFrame.opacity = 1 - ca
        ColorPickerFrame.previousValues = {cr, cg, cb, ca}

        ColorPickerFrame.func = function()
          local nr, ng, nb = ColorPickerFrame:GetColorRGB()
          local na = 1 - OpacitySliderFrame:GetValue()
          local newColor = string.format("%.2f,%.2f,%.2f,%.2f", nr, ng, nb, na)
          SetValue(newColor)
          frame.input.color:SetTexture(nr, ng, nb, na)
        end

        ColorPickerFrame.cancelFunc = function()
          local prev = ColorPickerFrame.previousValues
          local newColor = string.format("%.2f,%.2f,%.2f,%.2f", prev[1], prev[2], prev[3], prev[4])
          SetValue(newColor)
          frame.input.color:SetTexture(prev[1], prev[2], prev[3], prev[4])
        end

        ColorPickerFrame:Show()
      end)
    end

    -- Description tooltip
    if desc then
      frame:EnableMouse(true)
      frame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:SetText(label, 1, 1, 1)
        GameTooltip:AddLine(desc, 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
      end)
      frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
      end)
    end

    return frame
  end

  -- Helper to create a section header
  local function CreateHeader(parent, text)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetHeight(30)
    frame:SetWidth(CONTENT_WIDTH - 30)

    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.text:SetPoint("LEFT", frame, "LEFT", 5, 0)
    frame.text:SetText(text)
    frame.text:SetTextColor(0.3, 1, 0.8)

    frame.line = frame:CreateTexture(nil, "ARTWORK")
    frame.line:SetPoint("TOPLEFT", frame.text, "BOTTOMLEFT", 0, -2)
    frame.line:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
    frame.line:SetHeight(1)
    frame.line:SetTexture(0.3, 1, 0.8, 0.5)

    return frame
  end

  -- Helper to create a scrollable content area
  local function CreateScrollableContent(parent, name)
    local scrollFrame = CreateFrame("ScrollFrame", name .. "Scroll", parent)
    scrollFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -12, 0)

    -- Create scroll child
    local content = CreateFrame("Frame", name .. "Content", scrollFrame)
    content:SetWidth(CONTENT_WIDTH)
    content:SetHeight(1)  -- Will be updated dynamically
    scrollFrame:SetScrollChild(content)

    -- Create scrollbar
    local scrollbar = CreateFrame("Slider", name .. "ScrollBar", scrollFrame)
    scrollbar:SetOrientation("VERTICAL")
    scrollbar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, -2)
    scrollbar:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 2)
    scrollbar:SetWidth(10)
    scrollbar:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
    scrollbar:SetMinMaxValues(0, 1)
    scrollbar:SetValue(0)
    CreateBackdrop(scrollbar, nil, true)

    scrollbar:SetScript("OnValueChanged", function()
      scrollFrame:SetVerticalScroll(this:GetValue())
    end)

    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function()
      local current = scrollbar:GetValue()
      local step = 30
      if arg1 > 0 then
        scrollbar:SetValue(max(0, current - step))
      else
        local _, maxVal = scrollbar:GetMinMaxValues()
        scrollbar:SetValue(min(maxVal, current + step))
      end
    end)

    -- Update scrollbar when content changes
    content.UpdateScrollRange = function()
      local contentHeight = content:GetHeight()
      local frameHeight = scrollFrame:GetHeight()
      local maxScroll = max(0, contentHeight - frameHeight)
      scrollbar:SetMinMaxValues(0, maxScroll)
      if maxScroll > 0 then
        scrollbar:Show()
      else
        scrollbar:Hide()
      end
    end

    return content, scrollFrame
  end

  -- Create the main GUI frame
  local function CreateGUI()
    local gui = CreateFrame("Frame", "ShaguPlatesSettingsGUI", UIParent)
    gui:SetWidth(GUI_WIDTH)
    gui:SetHeight(GUI_HEIGHT)
    gui:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    gui:SetFrameStrata("DIALOG")
    gui:SetMovable(true)
    gui:EnableMouse(true)
    gui:SetClampedToScreen(true)
    gui:RegisterForDrag("LeftButton")
    gui:SetScript("OnDragStart", function() this:StartMoving() end)
    gui:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    gui:Hide()

    CreateBackdrop(gui, nil, nil, 0.9)
    CreateBackdropShadow(gui)

    -- Title bar
    gui.title = gui:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    gui.title:SetPoint("TOP", gui, "TOP", 0, -10)
    gui.title:SetText("ShaguPlates-extra Settings")
    gui.title:SetTextColor(0.3, 1, 0.8)

    -- Version info
    gui.version = gui:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    gui.version:SetPoint("TOPRIGHT", gui, "TOPRIGHT", -35, -10)
    gui.version:SetText("v" .. (ShaguPlates.version.string or "1.0.0"))
    gui.version:SetTextColor(0.6, 0.6, 0.6)

    -- Close button
    gui.close = CreateFrame("Button", nil, gui)
    gui.close:SetWidth(20)
    gui.close:SetHeight(20)
    gui.close:SetPoint("TOPRIGHT", gui, "TOPRIGHT", -8, -8)
    SkinCloseButton(gui.close)
    gui.close:SetScript("OnClick", function()
      gui:Hide()
    end)

    -- Tab frame for categories
    local tabs = CreateTabFrame(gui, "LEFT", false)
    tabs:SetPoint("TOPLEFT", gui, "TOPLEFT", 10, -35)
    tabs:SetPoint("BOTTOMRIGHT", gui, "BOTTOMRIGHT", -10, 40)

    -- =============================================
    -- CATEGORY: Nameplates
    -- =============================================
    local npContent = tabs:CreateTabChild("Nameplates", 120, nil, nil, true)
    local npChild, npScroll = CreateScrollableContent(npContent, "ShaguPlatesNP")

    local yOffset = -10
    local widgets = {}

    -- Nameplate Visibility Header
    local npVisHeader = CreateHeader(npChild, "Visibility")
    npVisHeader:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 35

    local npHostile = CreateConfigWidget(npChild, "checkbox", "nameplates", nil, "showhostile", "Show Hostile", "Show nameplates for hostile units")
    npHostile:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npFriendly = CreateConfigWidget(npChild, "checkbox", "nameplates", nil, "showfriendly", "Show Friendly", "Show nameplates for friendly units")
    npFriendly:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npCritters = CreateConfigWidget(npChild, "checkbox", "nameplates", nil, "critters", "Show Critters", "Show nameplates for critter NPCs")
    npCritters:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npTotems = CreateConfigWidget(npChild, "checkbox", "nameplates", nil, "totems", "Show Totems", "Show nameplates for totems")
    npTotems:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npTotemIcons = CreateConfigWidget(npChild, "checkbox", "nameplates", nil, "totemicons", "Totem Icons", "Show totem icons instead of names")
    npTotemIcons:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 40

    -- Nameplate Appearance Header
    local npAppHeader = CreateHeader(npChild, "Appearance")
    npAppHeader:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 35

    local npWidth = CreateConfigWidget(npChild, "number", "nameplates", nil, "width", "Width", "Width of nameplates in pixels")
    npWidth:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npHealthHeight = CreateConfigWidget(npChild, "number", "nameplates", nil, "heighthealth", "Health Bar Height", "Height of health bar in pixels")
    npHealthHeight:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npCastHeight = CreateConfigWidget(npChild, "number", "nameplates", nil, "heightcast", "Cast Bar Height", "Height of cast bar in pixels")
    npCastHeight:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npVPos = CreateConfigWidget(npChild, "number", "nameplates", nil, "vpos", "Vertical Position", "Vertical offset of nameplates")
    npVPos:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npVertHealth = CreateConfigWidget(npChild, "checkbox", "nameplates", nil, "verticalhealth", "Vertical Health", "Display health bar vertically")
    npVertHealth:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 40

    -- Nameplate Features Header
    local npFeatHeader = CreateHeader(npChild, "Features")
    npFeatHeader:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 35

    local npCastbar = CreateConfigWidget(npChild, "checkbox", "nameplates", nil, "showcastbar", "Show Castbar", "Display cast bar on nameplates")
    npCastbar:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npSpellName = CreateConfigWidget(npChild, "checkbox", "nameplates", nil, "spellname", "Show Spell Name", "Display spell name on cast bar")
    npSpellName:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npDebuffs = CreateConfigWidget(npChild, "checkbox", "nameplates", nil, "showdebuffs", "Show Debuffs", "Display debuff icons on nameplates")
    npDebuffs:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npSelfDebuff = CreateConfigWidget(npChild, "checkbox", "nameplates", nil, "selfdebuff", "Only Own Debuffs", "Only show debuffs you applied")
    npSelfDebuff:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npDebuffSize = CreateConfigWidget(npChild, "number", "nameplates", nil, "debuffsize", "Debuff Size", "Size of debuff icons")
    npDebuffSize:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npShowHP = CreateConfigWidget(npChild, "checkbox", "nameplates", nil, "showhp", "Show Health Text", "Display health values on nameplates")
    npShowHP:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npFullHealth = CreateConfigWidget(npChild, "checkbox", "nameplates", nil, "fullhealth", "Full Health Only", "Only show health when full")
    npFullHealth:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npGuildName = CreateConfigWidget(npChild, "checkbox", "nameplates", nil, "showguildname", "Show Guild Name", "Display guild name under player name")
    npGuildName:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 40

    -- Target Highlight Header
    local npTargetHeader = CreateHeader(npChild, "Target Highlight")
    npTargetHeader:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 35

    local npTarget = CreateConfigWidget(npChild, "checkbox", "nameplates", nil, "target", "Highlight Target", "Highlight current target nameplate")
    npTarget:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npTargetGlow = CreateConfigWidget(npChild, "checkbox", "nameplates", nil, "targetglow", "Target Glow", "Add glow effect around target")
    npTargetGlow:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npGlowColor = CreateConfigWidget(npChild, "color", "nameplates", nil, "glowcolor", "Glow Color", "Color of the target glow effect")
    npGlowColor:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npTargetZoom = CreateConfigWidget(npChild, "checkbox", "nameplates", nil, "targetzoom", "Target Zoom", "Zoom in on current target nameplate")
    npTargetZoom:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npTargetZoomVal = CreateConfigWidget(npChild, "number", "nameplates", nil, "targetzoomval", "Zoom Amount", "How much to zoom (0.0-1.0)")
    npTargetZoomVal:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npNotargAlpha = CreateConfigWidget(npChild, "number", "nameplates", nil, "notargalpha", "Non-Target Alpha", "Transparency of non-target plates (0-1)")
    npNotargAlpha:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 40

    -- Colors Header
    local npColorHeader = CreateHeader(npChild, "Class Colors")
    npColorHeader:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 35

    local npEnemyClass = CreateConfigWidget(npChild, "checkbox", "nameplates", nil, "enemyclassc", "Enemy Class Colors", "Use class colors for enemy players")
    npEnemyClass:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npFriendClass = CreateConfigWidget(npChild, "checkbox", "nameplates", nil, "friendclassc", "Friendly Class Colors", "Use class colors for friendly players")
    npFriendClass:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npNameFightColor = CreateConfigWidget(npChild, "checkbox", "nameplates", nil, "namefightcolor", "Combat Name Colors", "Color names based on combat state")
    npNameFightColor:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 40

    -- Raid Icons Header
    local npRaidHeader = CreateHeader(npChild, "Raid Icons")
    npRaidHeader:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 35

    local npRaidIconSize = CreateConfigWidget(npChild, "number", "nameplates", nil, "raidiconsize", "Icon Size", "Size of raid target icons")
    npRaidIconSize:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npRaidIconOffX = CreateConfigWidget(npChild, "number", "nameplates", nil, "raidiconoffx", "Icon Offset X", "Horizontal offset of raid icons")
    npRaidIconOffX:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npRaidIconOffY = CreateConfigWidget(npChild, "number", "nameplates", nil, "raidiconoffy", "Icon Offset Y", "Vertical offset of raid icons")
    npRaidIconOffY:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 40

    -- Interaction Header
    local npInteractHeader = CreateHeader(npChild, "Interaction")
    npInteractHeader:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 35

    local npClickthrough = CreateConfigWidget(npChild, "checkbox", "nameplates", nil, "clickthrough", "Clickthrough", "Make nameplates non-clickable")
    npClickthrough:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npRightClick = CreateConfigWidget(npChild, "checkbox", "nameplates", nil, "rightclick", "Right-Click Menu", "Enable right-click context menu")
    npRightClick:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local npOverlap = CreateConfigWidget(npChild, "checkbox", "nameplates", nil, "overlap", "Allow Overlap", "Allow nameplates to overlap")
    npOverlap:SetPoint("TOPLEFT", npChild, "TOPLEFT", 10, yOffset)

    -- Set content height for scrolling
    npChild:SetHeight(math.abs(yOffset) + 40)

    -- =============================================
    -- CATEGORY: Appearance
    -- =============================================
    local appContent = tabs:CreateTabChild("Appearance", 120, nil, nil, true)
    local appChild, appScroll = CreateScrollableContent(appContent, "ShaguPlatesApp")

    yOffset = -10

    -- Border Settings
    local borderHeader = CreateHeader(appChild, "Border & Background")
    borderHeader:SetPoint("TOPLEFT", appChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 35

    local borderBg = CreateConfigWidget(appChild, "color", "appearance", "border", "background", "Background Color", "Background color for UI elements")
    borderBg:SetPoint("TOPLEFT", appChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local borderColor = CreateConfigWidget(appChild, "color", "appearance", "border", "color", "Border Color", "Border color for UI elements")
    borderColor:SetPoint("TOPLEFT", appChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local borderShadow = CreateConfigWidget(appChild, "checkbox", "appearance", "border", "shadow", "Enable Shadow", "Enable shadow effect on borders")
    borderShadow:SetPoint("TOPLEFT", appChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local shadowIntensity = CreateConfigWidget(appChild, "number", "appearance", "border", "shadow_intensity", "Shadow Intensity", "Intensity of the shadow effect (0-1)")
    shadowIntensity:SetPoint("TOPLEFT", appChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local borderDefault = CreateConfigWidget(appChild, "number", "appearance", "border", "default", "Default Border Size", "Default border thickness")
    borderDefault:SetPoint("TOPLEFT", appChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 40

    -- Cooldown Settings
    local cdHeader = CreateHeader(appChild, "Cooldown Display")
    cdHeader:SetPoint("TOPLEFT", appChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 35

    local cdThreshold = CreateConfigWidget(appChild, "number", "appearance", "cd", "threshold", "Low Threshold", "Seconds before cooldown is considered 'low'")
    cdThreshold:SetPoint("TOPLEFT", appChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local cdFontSize = CreateConfigWidget(appChild, "number", "appearance", "cd", "font_size", "Font Size", "Cooldown text font size")
    cdFontSize:SetPoint("TOPLEFT", appChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local cdMillis = CreateConfigWidget(appChild, "checkbox", "appearance", "cd", "milliseconds", "Show Milliseconds", "Show milliseconds for short cooldowns")
    cdMillis:SetPoint("TOPLEFT", appChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local cdLowColor = CreateConfigWidget(appChild, "color", "appearance", "cd", "lowcolor", "Low CD Color", "Color when cooldown is low")
    cdLowColor:SetPoint("TOPLEFT", appChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local cdNormalColor = CreateConfigWidget(appChild, "color", "appearance", "cd", "normalcolor", "Normal CD Color", "Normal cooldown text color")
    cdNormalColor:SetPoint("TOPLEFT", appChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 40

    -- Castbar Settings
    local castHeader = CreateHeader(appChild, "Castbar")
    castHeader:SetPoint("TOPLEFT", appChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 35

    local castColor = CreateConfigWidget(appChild, "color", "appearance", "castbar", "castbarcolor", "Cast Color", "Color for casting spells")
    castColor:SetPoint("TOPLEFT", appChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local channelColor = CreateConfigWidget(appChild, "color", "appearance", "castbar", "channelcolor", "Channel Color", "Color for channeled spells")
    channelColor:SetPoint("TOPLEFT", appChild, "TOPLEFT", 10, yOffset)

    appChild:SetHeight(math.abs(yOffset) + 40)

    -- =============================================
    -- CATEGORY: Global
    -- =============================================
    local globalContent = tabs:CreateTabChild("Global", 120, nil, nil, true)
    local globalChild, globalScroll = CreateScrollableContent(globalContent, "ShaguPlatesGlobal")

    yOffset = -10

    -- Font Settings
    local fontHeader = CreateHeader(globalChild, "Font Settings")
    fontHeader:SetPoint("TOPLEFT", globalChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 35

    local fontBlizz = CreateConfigWidget(globalChild, "checkbox", "global", nil, "font_blizzard", "Use Blizzard Fonts", "Keep default Blizzard fonts instead of custom ones")
    fontBlizz:SetPoint("TOPLEFT", globalChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local fontSize = CreateConfigWidget(globalChild, "number", "global", nil, "font_size", "Default Font Size", "Default font size for UI elements")
    fontSize:SetPoint("TOPLEFT", globalChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local fontUnitSize = CreateConfigWidget(globalChild, "number", "global", nil, "font_unit_size", "Unit Font Size", "Font size for unit frames")
    fontUnitSize:SetPoint("TOPLEFT", globalChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 40

    -- General Settings
    local genHeader = CreateHeader(globalChild, "General")
    genHeader:SetPoint("TOPLEFT", globalChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 35

    local pixelPerfect = CreateConfigWidget(globalChild, "checkbox", "global", nil, "pixelperfect", "Pixel Perfect", "Enable pixel-perfect UI scaling")
    pixelPerfect:SetPoint("TOPLEFT", globalChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local errors = CreateConfigWidget(globalChild, "checkbox", "global", nil, "errors", "Show Errors", "Show Lua error messages")
    errors:SetPoint("TOPLEFT", globalChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local twentyfour = CreateConfigWidget(globalChild, "checkbox", "global", nil, "twentyfour", "24-Hour Time", "Use 24-hour time format")
    twentyfour:SetPoint("TOPLEFT", globalChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local autoSell = CreateConfigWidget(globalChild, "checkbox", "global", nil, "autosell", "Auto-Sell Junk", "Automatically sell grey items")
    autoSell:SetPoint("TOPLEFT", globalChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local autoRepair = CreateConfigWidget(globalChild, "checkbox", "global", nil, "autorepair", "Auto-Repair", "Automatically repair equipment")
    autoRepair:SetPoint("TOPLEFT", globalChild, "TOPLEFT", 10, yOffset)

    globalChild:SetHeight(math.abs(yOffset) + 40)

    -- =============================================
    -- CATEGORY: Buffs
    -- =============================================
    local buffContent = tabs:CreateTabChild("Buffs", 120, nil, nil, true)
    local buffChild, buffScroll = CreateScrollableContent(buffContent, "ShaguPlatesBuff")

    yOffset = -10

    local buffHeader = CreateHeader(buffChild, "Buff Display")
    buffHeader:SetPoint("TOPLEFT", buffChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 35

    local buffEnable = CreateConfigWidget(buffChild, "checkbox", "buffs", nil, "buffs", "Show Buffs", "Display buffs on unit frames")
    buffEnable:SetPoint("TOPLEFT", buffChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local debuffEnable = CreateConfigWidget(buffChild, "checkbox", "buffs", nil, "debuffs", "Show Debuffs", "Display debuffs on unit frames")
    debuffEnable:SetPoint("TOPLEFT", buffChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local weaponBuffs = CreateConfigWidget(buffChild, "checkbox", "buffs", nil, "weapons", "Show Weapon Buffs", "Display weapon enchant buffs")
    weaponBuffs:SetPoint("TOPLEFT", buffChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local buffSize = CreateConfigWidget(buffChild, "number", "buffs", nil, "size", "Buff Size", "Size of buff icons")
    buffSize:SetPoint("TOPLEFT", buffChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local buffSpacing = CreateConfigWidget(buffChild, "number", "buffs", nil, "spacing", "Buff Spacing", "Space between buff icons")
    buffSpacing:SetPoint("TOPLEFT", buffChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local buffRowSize = CreateConfigWidget(buffChild, "number", "buffs", nil, "buffrowsize", "Buffs Per Row", "Number of buffs per row")
    buffRowSize:SetPoint("TOPLEFT", buffChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local debuffRowSize = CreateConfigWidget(buffChild, "number", "buffs", nil, "debuffrowsize", "Debuffs Per Row", "Number of debuffs per row")
    debuffRowSize:SetPoint("TOPLEFT", buffChild, "TOPLEFT", 10, yOffset)

    buffChild:SetHeight(math.abs(yOffset) + 40)

    -- =============================================
    -- CATEGORY: Loot
    -- =============================================
    local lootContent = tabs:CreateTabChild("Loot", 120, nil, nil, true)
    local lootChild, lootScroll = CreateScrollableContent(lootContent, "ShaguPlatesLoot")

    yOffset = -10

    local lootHeader = CreateHeader(lootChild, "Loot Settings")
    lootHeader:SetPoint("TOPLEFT", lootChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 35

    local lootResize = CreateConfigWidget(lootChild, "checkbox", "loot", nil, "autoresize", "Auto-Resize", "Automatically resize loot window")
    lootResize:SetPoint("TOPLEFT", lootChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local lootPickup = CreateConfigWidget(lootChild, "checkbox", "loot", nil, "autopickup", "Auto-Pickup", "Automatically loot items")
    lootPickup:SetPoint("TOPLEFT", lootChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local lootCursor = CreateConfigWidget(lootChild, "checkbox", "loot", nil, "mousecursor", "Loot at Cursor", "Show loot window at mouse cursor")
    lootCursor:SetPoint("TOPLEFT", lootChild, "TOPLEFT", 10, yOffset)
    yOffset = yOffset - 28

    local lootAdvanced = CreateConfigWidget(lootChild, "checkbox", "loot", nil, "advancedloot", "Advanced Loot", "Enable advanced loot features")
    lootAdvanced:SetPoint("TOPLEFT", lootChild, "TOPLEFT", 10, yOffset)

    lootChild:SetHeight(math.abs(yOffset) + 40)

    -- =============================================
    -- CATEGORY: Profiles
    -- =============================================
    local profileContent = tabs:CreateTabChild("Profiles", 120, nil, true, true)

    local profileNote = profileContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    profileNote:SetPoint("TOPLEFT", profileContent, "TOPLEFT", 15, -15)
    profileNote:SetText("Profile Management")
    profileNote:SetTextColor(0.3, 1, 0.8)

    local profileDesc = profileContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    profileDesc:SetPoint("TOPLEFT", profileNote, "BOTTOMLEFT", 0, -10)
    profileDesc:SetText("Available profiles: Modern, Legacy, Adapta, Slim\nProfiles can be loaded from env/profiles.lua")
    profileDesc:SetTextColor(0.7, 0.7, 0.7)

    -- Reload UI Button
    local reloadBtn = CreateFrame("Button", nil, profileContent, "UIPanelButtonTemplate")
    reloadBtn:SetWidth(120)
    reloadBtn:SetHeight(25)
    reloadBtn:SetPoint("BOTTOMLEFT", profileContent, "BOTTOMLEFT", 15, 15)
    reloadBtn:SetText("Reload UI")
    SkinButton(reloadBtn)
    reloadBtn:SetScript("OnClick", function()
      ReloadUI()
    end)

    -- =============================================
    -- Bottom buttons
    -- =============================================

    -- Reload hint
    gui.hint = gui:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    gui.hint:SetPoint("BOTTOM", gui, "BOTTOM", 0, 12)
    gui.hint:SetText("Some settings require /reload to take effect")
    gui.hint:SetTextColor(0.6, 0.6, 0.6)

    return gui
  end

  -- Initialize GUI
  ShaguPlates.gui = CreateGUI()

  -- Print welcome message
  DEFAULT_CHAT_FRAME:AddMessage("|cff33ffccShaguPlates-extra|r: Type |cff00ff00/sp|r or |cff00ff00/shaguplates|r to open settings")

end)
