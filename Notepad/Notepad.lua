-- Notepad Addon for WoW Classic

-- /notepad or /np to toggle. /np font (8-24), /np reset

local ADDON_NAME = "Notepad"

local DEFAULTS = {
    pages = { "" },
    current = 1,
    width = 420,
    height = 360,
    fontSize = 13,
    point = nil, -- {point, relPoint, x, y}
}

local db -- set on ADDON_LOADED

-- Main Frame

local f = CreateFrame("Frame", "NotepadFrame", UIParent, "BasicFrameTemplateWithInset")
f:SetSize(DEFAULTS.width, DEFAULTS.height)
f:SetPoint("CENTER")
f:SetFramaStrata("HIGH")
f:SetClampedToScreen(true)
f:SetMovable(true)
f:SetResizable(true)
if f.SetResizeBounds then
    f:SetResizeBounds(300, 200, 1200, 1000)
else
    f:SetMinResize(300, 200)
    f:SetMaxResize(1200, 1000)
end

f:EnableMouse(true)
f:REgisterForDrag("LeftButton")
f:Hide()

-- Escape closes the window
tinsert(UISpecialFrames, "NotepadFrame")

f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
if f.TitleBg then
    f.title:SetPoint("LEFT", f.TitleBg, "LEFT", 6, 0)
else
    f.title:SetPoint("TOP", 0, -6)
end
f.title:SetText("Notepad")

local function SavePosition()
    local point, _, relPoint, x, y = f:GetPoint()
    db.point = { point, relPoint, x, y }
    db.width, db.height = f:GetSize()
end

f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SavePosition()
end)

-- Scrolling Edit Box

local sf = CreateFrame("ScrollFrame", "NotepadScrollFrame", f, "UIPanelScrollFrameTemplate")
sf:SetPoint("TOPLEFT", 12, -30)
sf:SetPoint("BOTTOMRIGHT", -32, 42)

local eb = CreateFrame("EditBox", "NotepadEditBox", sf)
eb:SetMultiLine(true)
eb:SetAutoFocus(false)
eb:SetFontObject(ChatFontNormal)
eb:SetMaxLetters(0)
eb:SetTextInsets(2, 2, 2, 2)
eb:SetWidth(300)
sf:SetScrollChild(eb)

--Keep the edit box as wide as the scroll area
sf:SetScript("OnSizeChanged", function(self, w)
    eb:SetWidth(w)
end)

--Click anywhere in the text area to shit window focus

sf:EnableMouse(true)
sf:SetScript("OnMouseDown", function()
    eb:SetFocus()
end)

eb:SetScript("OnEscapePressed", eb.ClearFocus)

--Always visible cursor while typing
eb:SetScript("OnCursorChanged", function(self, x, y, w, h)
    y = -y
    local scroll = sf:GetVerticalScroll()
    local viewH = sf:GetHeight()
    if y < scroll then
        sf:SetVerticalScroll(y)
    elseif y + h > scroll + viewH then
        sf:SetVerticalScroll(y + h - viewH)
    end
end)

eb:SetScript("OnTextChanged", function(self, UserInput)
    if UserInput then
        db.pages[db.current] = self:GetText()
    end
end)

-- Shift+Click items/spells/quests to insert them in notepad

hooksecurefunc("ChatEdit_InsertLink", function(text)
    if IsShiftKeyDown() and f:IsShown() and eb:HasFocus() then
        eb:Insert(text)
    end
end)

--Resize grip

local grip = CreateFrame("Button", nil, f)
grip:SetSize(16, 16)
grip:SetPoint("BOTTOMRIGHT", -4, 4)
grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
grip:SetScript("OnMouseDown", function() f:StartSizing("BOTTOMRIGHT") end)
grip:SetScript("OnMouseUp", function()
    f:StopMovingOrSizing()
    SavePosition()
end)

--Page Controls
local function MakeButton(text, width)
    local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    b:SetSize(width, 22)
    b:SetText(text)
    return b
end

local prevBtn = MakeButton("<", 28)
prevBtn:SetPoint("BOTTOMLEFT", 12, 12)

local pageLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
pageLabel:SetPoint("LEFT", prevBtn, "RIGHT", 8, 0)
pageLabel:SetWidth(80)

local nextBtn = MakeButton(">", 28)
nextBtn:SetPoint("LEFT", pageLabel, "RIGHT", 8, 0)

local newBtn = MakeButton("New", 50)
newBtn:SetPoint("LEFT", nextBtn, "RIGHT", 10, 0)

local delBtn = MakeButton("Delete", 60)
delBtn:SetPoint("BOTTOMRIGHT", -26, 12)

local function Refresh(
    if not db then return end
    eb:SetText(db.pages[db.current] or "")
    eb:SetCursorPosition(0)
    sf:SetVerticalScroll(0)
    pageLabel:SetText(("Page %d / %d"):format(db.current, #db.pages)
    prevBtn:SetEnabled(db.current > 1)
    nextBtn:SetEnabled(db.current < #db.pages)
end

local function GoToPage(n)
    db.current = math.max(1, math.min(n, #db.pages))
    Refresh()
end

prevBtn:SetScript("OnClick", function() GoToPage(db.current - 1) end)
nextBtn:SetScript("OnClick", function() GoToPage(db.current + 1) end)
newBtn:SetScript("OnClick", function()
    tinsert(db.page, "")
    GoToPage(#db.pages)
    eb:SetFocus()
end)

StaticPopupDialogs["NOTEPAD_DELETE_PAGE"] = {
    text = "Are you sure you want to delete this page?",
    button1 = "Delete",
    button2 = "Cancel",
    OnAccept = function()
        tremove(db.pages, db.current)
        if db.current > #db.pages then
            db.current = #db.pages
        end
        if #db.pages == 0 then
            tinsert(db.pages, "")
            db.current = 1
        end
        Refresh()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

delBtn:SetScript("OnClick", function()
    if (db.pages[db.current] or "") == "" and #db.pages > 1 then
        --Empty page: delete without asking")
        tremove(db.pages, db.current)
        GoToPage(db.current)
    else
        StaticPopup_Show("NOTEPAD_DELETE_PAGE")
    end
end)

--Settings Tip

local function ApplyFont()
    local path, _, flags = ChatFontNormal:GetFont()
    eb:SetFont(path, db.fontSize, flags)
end

local function ApplyLayout()
    f:ClearAllPoints()
    if db.point then
        local p = db.point
        f:SetPoint(p[1], UIParent, p[2], p[3], p[4])
    else
        f:SetPoint("CENTER")
    end
    f:SetSize(db.width, db.height)
end

--Init

f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, name)
    if event == "ADDON_LOADED" and name == ADDON_NAME then
        NotepadDB = NotepadDB or {}
        db = NotepadDB
        for k, v, in pairs(DEFAULTS) do
            if db[k] == nil then
                db[k] = type(v) == "table" and CopyTable(v) or v
            end
        end
        if #db_pages == 0 then db.pages[1] = "" end
        db.current = math.max(1, math.min(db.current, #db.pages))

        ApplyLayout()
        ApplyFont()
        Refresh()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

f:SetScript("OnShow", Refresh)
f:SetScript("OnHide", function() eb:ClearFocus() end)

--Slash Chat Commands
SLASH_NOTEPAD1 = "/notepad"
SLASH_NOTEPAD2 = "/np"
SlashCmdList["NOTEPAD"] = function(msg)
    local cmd, arg = msg:match("^(%S*)%s*(.-)$")
        cmd = (cmd or ""):lower()

        if cmd == "font" then
            local size = tonumber(arg)
            if size and size >=8 and size <= 24 then
                db.fontSize = size
                ApplyFont()
                print(("|cff33ff99Notepad|r: font size set to %d."):format(size))
            else
                print("|cff33ff99Notepad|r: usage /np font <8-24>")
            end
        elseif cmd == "reset" then
            db.point, db.width, db.height = nil, DEFAULTS.width, DEFAULTS.height
            ApplyLayout()
            f:Show()
            print("|cff33ff99Notepad|r: window position and size reset.")
        elseif cmd == "help" then
            print("|cff33ff99Notepad|r commands:")
            print("  /np - toggle the window")
            print("  /np font <8-24> - set text size")
            print("  /np reset - reset window position and size")
        else
            f:SetShown(not f:IsShown())
        end
end