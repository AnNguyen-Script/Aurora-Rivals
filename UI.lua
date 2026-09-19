-- ============================================================
-- MODULAR RIVALS | MODULE 7: USER INTERFACE, TABS & CONTROLS
-- ============================================================
return function(Shared, Shield, Targeting, ESP, Aim, Player)
    local UI = {}

    local Settings = Shared.Settings
    local LocalPlayer = Shared.LocalPlayer
    local Players = Shared.Players
    local Camera = Shared.Camera
    local TweenService = Shared.TweenService
    local UserInputService = Shared.UserInputService
    local HttpService = Shared.HttpService
    local CoreGui = Shared.CoreGui
    local Workspace = Shared.Workspace
    local Lighting = Shared.Lighting
    local TeleportService = Shared.TeleportService
    local RandomString = Shared.RandomString
    local isMenuConnected = true
    local SendNotification = nil
    local GetActivePreset = Shared.GetActivePreset
    local Theme = Shared.Theme
    local ThemePresets = Shared.ThemePresets
    local MainFrame = nil
    local MainStroke = nil
    local FOVring = (Aim and Aim.FOVring) or Shared.FOVring
    local ThemeObjects = Shared.ThemeObjects
    local SearchIndex = Shared.SearchIndex
    local TabActiveKeys = Shared.TabActiveKeys
    local UI_Elements = Shared.UI_Elements
    local IDS = Shared.IDS
    local parentGui = Shared.parentGui
    local ProtectInstance = Shared.ProtectInstance
    local CheckAndBypassCharacterAC = Shield.CheckAndBypassCharacterAC
    local originalHitboxes = Player.originalHitboxes
    local ResetHitboxes = Player.ResetHitboxes

-- UI CHÍNH
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = IDS.UI
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = parentGui
ProtectInstance(ScreenGui)

MainFrame = Instance.new("Frame")
MainFrame.Name = RandomString(8)
MainFrame.Size = UDim2.new(0, 650, 0, 420)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -210)
MainFrame.BackgroundColor3 = Theme.MainBg
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 45, 50)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

do local c = Instance.new("UICorner", MainFrame); c.CornerRadius = UDim.new(0, 10) end

-- ============================================================
-- TOP-CENTER ESP TARGET COUNTER (KHUNG ĐEN VUÔNG - SỐ PHÓNG TO)
-- ============================================================
local ESPCounterBox = Instance.new("Frame")
ESPCounterBox.Name = "ESPCounterBox"
ESPCounterBox.AnchorPoint = Vector2.new(0.5, 0)
ESPCounterBox.Position = UDim2.new(0.5, 0, 0, 15)
ESPCounterBox.Size = UDim2.new(0, 60, 0, 56)
ESPCounterBox.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
ESPCounterBox.BackgroundTransparency = 0.15
ESPCounterBox.BorderSizePixel = 0
ESPCounterBox.Visible = false
ESPCounterBox.Parent = ScreenGui
Instance.new("UICorner", ESPCounterBox).CornerRadius = UDim.new(0, 8)

do local s = Instance.new("UIStroke", ESPCounterBox); s.Color = Color3.fromRGB(50, 50, 55); s.Thickness = 1.5; s.Transparency = 0.3 end

local ESPCounterLabel = Instance.new("TextLabel")
ESPCounterLabel.Name = "ESPCounterLabel"
ESPCounterLabel.Size = UDim2.new(1, 0, 1, 0)
ESPCounterLabel.Position = UDim2.new(0, 0, 0, 0)
ESPCounterLabel.BackgroundTransparency = 1
ESPCounterLabel.BorderSizePixel = 0
ESPCounterLabel.Text = "0"
ESPCounterLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
ESPCounterLabel.Font = Enum.Font.GothamBold
ESPCounterLabel.TextSize = 36
ESPCounterLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
ESPCounterLabel.TextStrokeTransparency = 0.4
ESPCounterLabel.TextXAlignment = Enum.TextXAlignment.Center
ESPCounterLabel.TextYAlignment = Enum.TextYAlignment.Center
ESPCounterLabel.Parent = ESPCounterBox

-- Watermark
local WatermarkFrame = Instance.new("Frame")
WatermarkFrame.Size = UDim2.new(0, 300, 0, 20)
WatermarkFrame.Position = UDim2.new(1, -310, 1, -30)
WatermarkFrame.BackgroundTransparency = 1
WatermarkFrame.Parent = ScreenGui

local Watermark = Instance.new("TextLabel")
Watermark.Size = UDim2.new(1, 0, 1, 0)
Watermark.BackgroundTransparency = 1
Watermark.RichText = true
Watermark.Text = "✨ ĐẶC QUYỀN ✨ " .. IDS.Watermark .. " | <font color=\"#FFD700\">An Nguyễn Studio</font>"
Watermark.TextColor3 = Color3.fromRGB(255, 215, 0)
Watermark.Font = Theme.FontBold
Watermark.TextSize = 14
Watermark.TextXAlignment = Enum.TextXAlignment.Right
Watermark.TextStrokeTransparency = 0.5
Watermark.Parent = WatermarkFrame

local function UpdateWatermarkColor(color)
    pcall(function() Watermark.TextColor3 = color end)
end

local NotifyFrame = Instance.new("Frame")
NotifyFrame.Name = RandomString(6)
NotifyFrame.Size = UDim2.new(0, 250, 1, -50)
NotifyFrame.Position = UDim2.new(1, -260, 0, 10)
NotifyFrame.BackgroundTransparency = 1
NotifyFrame.Parent = ScreenGui

do local l = Instance.new("UIListLayout", NotifyFrame); l.SortOrder = Enum.SortOrder.LayoutOrder; l.VerticalAlignment = Enum.VerticalAlignment.Bottom; l.Padding = UDim.new(0, 5) end

-- Tooltip theo chuột
local Tooltip = Instance.new("TextLabel")
Tooltip.Text = ""
Tooltip.Size = UDim2.new(0, 190, 0, 26)
Tooltip.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
Tooltip.BackgroundTransparency = 0.1
Tooltip.BorderSizePixel = 0
Tooltip.TextColor3 = Color3.fromRGB(230, 230, 230)
Tooltip.Font = Enum.Font.Gotham
Tooltip.TextSize = 11
Tooltip.TextXAlignment = Enum.TextXAlignment.Center
Tooltip.Visible = false
Tooltip.ZIndex = 50
Tooltip.Parent = ScreenGui
Instance.new("UICorner", Tooltip).CornerRadius = UDim.new(0, 6)

local function ShowTooltip(text)
    -- Disabled hover tooltip to prevent stray text artifacts on screen
    if Tooltip then Tooltip.Visible = false end
end

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and Tooltip.Visible then
        local pos = UserInputService:GetMouseLocation()
        Tooltip.Position = UDim2.new(0, pos.X + 14, 0, pos.Y + 14)
    end
end)

SendNotification = function(title, text)
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(1, 0, 0, 60)
    Notif.BackgroundColor3 = Theme.PanelBg
    Notif.BackgroundTransparency = 1
    Notif.Parent = NotifyFrame

    Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", Notif)
    Stroke.Color = Color3.fromRGB(45, 45, 50)
    Stroke.Transparency = 1

    local Title = Instance.new("TextLabel", Notif)
    Title.Size = UDim2.new(1, -20, 0, 25)
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.TextColor3 = Theme.TextWhite
    Title.TextTransparency = 1
    Title.Font = Theme.FontBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Desc = Instance.new("TextLabel", Notif)
    Desc.Size = UDim2.new(1, -20, 0, 20)
    Desc.Position = UDim2.new(0, 10, 0, 30)
    Desc.BackgroundTransparency = 1
    Desc.Text = text
    Desc.TextColor3 = Theme.TextDark
    Desc.TextTransparency = 1
    Desc.Font = Theme.Font
    Desc.TextSize = 12
    Desc.TextXAlignment = Enum.TextXAlignment.Left

    TweenService:Create(Notif, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
    TweenService:Create(Title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(Desc, TweenInfo.new(0.3), {TextTransparency = 0}):Play()

    task.delay(3, function()
        TweenService:Create(Notif, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        TweenService:Create(Title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(Desc, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        task.wait(0.3)
        Notif:Destroy()
    end)
end

local function MakeDraggable(topbar, main)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    topbar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

MakeDraggable(WatermarkFrame, WatermarkFrame)

-- ============================================================
-- TOP BAR
-- ============================================================
local TopBar = Instance.new("Frame")
TopBar.Name = RandomString(6)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame
MakeDraggable(TopBar, MainFrame)

do local l = Instance.new("Frame", TopBar); l.Size = UDim2.new(1, 0, 0, 1); l.Position = UDim2.new(0, 0, 1, -1); l.BackgroundColor3 = Color3.fromRGB(35, 35, 40); l.BorderSizePixel = 0 end

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(0, 400, 1, 0)
StatusText.Position = UDim2.new(0, 15, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.RichText = true
StatusText.Text = "<font color=\"#ffffff\">● Rivals Menu</font>   <font color=\"#666677\">/</font>   <font color=\"#aaaaaa\">Main</font>"
StatusText.TextColor3 = Theme.TopBarText
StatusText.Font = Theme.Font
StatusText.TextSize = 12
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Visible = true
StatusText.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.TextDark
CloseBtn.Font = Theme.Font
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- SIDEBAR & TABS
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 50, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundTransparency = 1
Sidebar.Visible = true
Sidebar.Parent = MainFrame

do local l = Instance.new("Frame", Sidebar); l.Size = UDim2.new(0, 1, 1, 0); l.Position = UDim2.new(1, -1, 0, 0); l.BackgroundColor3 = Color3.fromRGB(35, 35, 40); l.BorderSizePixel = 0 end

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -60, 1, -50)
ContentArea.Position = UDim2.new(0, 50, 0, 40)
ContentArea.BackgroundTransparency = 1
ContentArea.Visible = true
ContentArea.Parent = MainFrame

-- [ĐÃ BỎ CHECK KEY VÀ SET PROSERS THEO YÊU CẦU: MENU TỰ ĐỘNG MỞ TRỰC TIẾP]
task.spawn(function()
    task.wait(0.5)
    if SendNotification then
        SendNotification("System", "Rivals Pro Menu đã kích hoạt thành công!")
    end
end)

local Tabs = {}
local SidebarButtons = {}
local activeTab = nil

-- Chấm trạng thái trên icon tab: sáng khi tab có feature đang bật
local function UpdateTabDots()
    for tabName, _ in pairs(Tabs) do
        local anyOn = false
        for key, _ in pairs(TabActiveKeys[tabName] or {}) do
            if Settings[key] then
                anyOn = true
                break
            end
        end
        local btn = SidebarButtons[tabName]
        if btn and btn.Indicator then
            btn.Indicator.Visible = anyOn
        end
    end
end

local function CreateSidebarIcon(tabName, iconChar, yPos)
    local TabContent = Instance.new("Frame")
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = false
    TabContent.Parent = ContentArea
    Tabs[tabName] = TabContent

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 30, 0, 30)
    if typeof(yPos) == "UDim2" then
        Btn.Position = yPos
    elseif type(yPos) == "number" and yPos < 0 then
        Btn.Position = UDim2.new(0.5, -15, 1, yPos)
    else
        Btn.Position = UDim2.new(0.5, -15, 0, yPos)
    end
    Btn.BackgroundTransparency = 1
    Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Text = ""
    Btn.Parent = Sidebar
    SidebarButtons[tabName] = Btn
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

    local Icon
    if iconChar:match("rbxasset") then
        Icon = Instance.new("ImageLabel")
        Icon.Name = "Icon"
        Icon.Size = UDim2.new(0, 16, 0, 16)
        Icon.Position = UDim2.new(0.5, -8, 0.5, -8)
        Icon.BackgroundTransparency = 1
        Icon.Image = iconChar
        Icon.ImageColor3 = Theme.TextDark
        Icon.Parent = Btn
    else
        Icon = Instance.new("TextLabel")
        Icon.Name = "Icon"
        Icon.Size = UDim2.new(1, 0, 1, 0)
        Icon.BackgroundTransparency = 1
        Icon.Text = iconChar
        Icon.TextColor3 = Theme.TextDark
        Icon.Font = Enum.Font.Gotham
        Icon.TextSize = 18
        Icon.Parent = Btn
    end

    local Indicator = Instance.new("Frame")
    Indicator.Name = "Indicator"
    Indicator.Size = UDim2.new(0, 3, 0, 16)
    Indicator.Position = UDim2.new(0, -10, 0.5, -8)
    Indicator.BackgroundColor3 = Theme.DotGreen
    Indicator.BorderSizePixel = 0
    Indicator.Visible = false
    Indicator.Parent = Btn
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    Btn.MouseButton1Click:Connect(function()
        if activeTab == tabName then return end
        if activeTab then
            Tabs[activeTab].Visible = false
            SidebarButtons[activeTab].BackgroundTransparency = 1
            local oldIcon = SidebarButtons[activeTab]:FindFirstChild("Icon")
            if oldIcon then
                if oldIcon:IsA("ImageLabel") then
                    oldIcon.ImageColor3 = Theme.TextDark
                else
                    oldIcon.TextColor3 = Theme.TextDark
                end
            end
            SidebarButtons[activeTab].Indicator.Visible = false
        end
        activeTab = tabName
        Tabs[activeTab].Visible = true
        SidebarButtons[activeTab].BackgroundTransparency = 0.9
        local newIcon = SidebarButtons[activeTab]:FindFirstChild("Icon")
        if newIcon then
            if newIcon:IsA("ImageLabel") then
                newIcon.ImageColor3 = Theme.TextWhite
            else
                newIcon.TextColor3 = Theme.TextWhite
            end
        end
        SidebarButtons[activeTab].Indicator.Visible = true
        -- Animation chuyển tab: slide nhẹ
        ContentArea.Position = UDim2.new(0, 32, 0, 40)
        TweenService:Create(ContentArea,
            TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Position = UDim2.new(0, 50, 0, 40)}):Play()
    end)

    Btn.MouseEnter:Connect(function()
        if activeTab ~= tabName then
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.95}):Play()
        end
    end)
    Btn.MouseLeave:Connect(function()
        if activeTab ~= tabName then
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        end
    end)

    return TabContent
end

local TabAimbot = CreateSidebarIcon("Aimbot", "rbxassetid://7733917120", 10)
local TabESP = CreateSidebarIcon("ESP", "rbxassetid://7733774602", 55)
local TabPlayer = CreateSidebarIcon("Player", "rbxassetid://7733920644", 100)
local TabSecurity = CreateSidebarIcon("Security", "rbxassetid://7734053495", UDim2.new(0.5, -15, 1, -40))

Tabs["Aimbot"].Visible = true
SidebarButtons["Aimbot"].BackgroundTransparency = 0.9
if SidebarButtons["Aimbot"]:FindFirstChild("Icon") then
    SidebarButtons["Aimbot"].Icon.ImageColor3 = Theme.TextWhite
end
SidebarButtons["Aimbot"].Indicator.Visible = true
activeTab = "Aimbot"

-- ============================================================
-- CONFIG SYSTEM (CHỐNG LỖI / TỰ ĐỘNG TẢI & LƯU CHUẨN XÁC)
-- ============================================================
local hasLoadedConfig = false

local function SaveConfig(isSilent)
    local isExplicitSilent = (isSilent == true)
    local ok, err = pcall(function()
        if not writefile then
            if not isExplicitSilent then
                SendNotification("Lỗi Lưu", "Executor không hỗ trợ writefile")
            end
            return
        end

        local sanitized = {}
        for k, v in pairs(Settings) do
            local valType = typeof(v)
            if valType == "EnumItem" then
                sanitized[k] = "Enum." .. tostring(v.EnumType) .. "." .. tostring(v.Name)
            elseif valType == "boolean" or valType == "number" or valType == "string" then
                sanitized[k] = v
            end
        end

        local encodeOk, encoded = pcall(function()
            return HttpService:JSONEncode(sanitized)
        end)

        if encodeOk and encoded and encoded ~= "" then
            writefile(IDS.ConfigName, encoded)
            hasLoadedConfig = true
            if not isExplicitSilent then
                SendNotification("Cấu Hình", "Đã lưu cài đặt thành công! ✓")
            end
        end
    end)
    if not ok then warn("SaveConfig error:", err) end
end

local function LoadConfig(isSilent)
    local isExplicitSilent = (isSilent == true)
    local ok, err = pcall(function()
        if not (readfile and isfile) then
            if not isExplicitSilent then
                SendNotification("Lỗi Tải", "Executor không hỗ trợ đọc file")
            end
            return
        end

        local targetFile = nil
        if isfile(IDS.ConfigName) then
            targetFile = IDS.ConfigName
        elseif isfile("FF_Pro_Config.json") then
            targetFile = "FF_Pro_Config.json"
        end

        if not targetFile then
            hasLoadedConfig = true
            if not isExplicitSilent then
                SendNotification("Thông Báo", "Chưa có file cấu hình để tải")
            end
            return
        end

        local rawContent = readfile(targetFile)
        if not rawContent or rawContent == "" then return end

        local decodeOk, data = pcall(function()
            return HttpService:JSONDecode(rawContent)
        end)

        if not decodeOk or type(data) ~= "table" then
            if not isExplicitSilent then
                SendNotification("Lỗi Cấu Hình", "File cấu hình bị lỗi cú pháp")
            end
            return
        end

        -- Áp dụng dữ liệu cấu hình vào Settings với bảo vệ kiểu dữ liệu
        for k, v in pairs(data) do
            if Settings[k] ~= nil then
                if type(v) == "string" and v:sub(1, 5) == "Enum." then
                    local parts = v:split(".")
                    if #parts >= 3 then
                        local enumType, enumName = parts[2], parts[3]
                        if Enum[enumType] and Enum[enumType][enumName] then
                            Settings[k] = Enum[enumType][enumName]
                        end
                    end
                elseif type(v) == type(Settings[k]) then
                    Settings[k] = v
                end
            end
        end

        -- Cập nhật đồng bộ toàn bộ giao diện UI Elements
        for key, ui in pairs(UI_Elements) do
            if Settings[key] ~= nil and ui and ui.SetValue then
                pcall(function() ui.SetValue(Settings[key]) end)
            end
        end

        hasLoadedConfig = true
        if not isExplicitSilent then
            SendNotification("Cấu Hình", "Đã tải cài đặt thành công! ✓")
        end
    end)
    if not ok then warn("LoadConfig error:", err) end
end

-- Tự động lưu định kỳ an toàn (Chỉ lưu khi đã tải xong cấu hình, không bao giờ ghi đè mặc định)
task.spawn(function()
    while task.wait(30) do
        if hasLoadedConfig then
            pcall(function() SaveConfig(true) end)
        end
    end
end)

-- ============================================================
-- UI BUILDERS
-- ============================================================
local function CreatePanel(parent, name, iconChar, posX, posY, sizeX, sizeY)
    local Panel = Instance.new("Frame")
    Panel.Name = name
    Panel.Size = UDim2.new(sizeX, -14, sizeY, -14)
    Panel.Position = UDim2.new(posX, 7, posY, 7)
    Panel.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
    Panel.Parent = parent
    Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 8)

    local HeaderBg = Instance.new("Frame")
    HeaderBg.Size = UDim2.new(1, 0, 0, 45)
    HeaderBg.BackgroundColor3 = Theme.PanelBg
    HeaderBg.BorderSizePixel = 0
    HeaderBg.Parent = Panel
    Instance.new("UICorner", HeaderBg).CornerRadius = UDim.new(0, 8)

    local HeaderSquare = Instance.new("Frame")
    HeaderSquare.Size = UDim2.new(1, 0, 0, 10)
    HeaderSquare.Position = UDim2.new(0, 0, 1, -10)
    HeaderSquare.BackgroundColor3 = Theme.PanelBg
    HeaderSquare.BorderSizePixel = 0
    HeaderSquare.Parent = HeaderBg

    local HeaderLine = Instance.new("Frame")
    HeaderLine.Size = UDim2.new(1, 0, 0, 1)
    HeaderLine.Position = UDim2.new(0, 0, 1, 0)
    HeaderLine.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    HeaderLine.BorderSizePixel = 0
    HeaderLine.Parent = HeaderBg

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -30, 0, 45)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = (iconChar ~= "" and (iconChar .. "  ") or "") .. name
    Title.TextColor3 = Theme.TextWhite
    Title.Font = Theme.FontBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = HeaderBg

    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, 0, 1, -50)
    Container.Position = UDim2.new(0, 0, 0, 45)
    Container.BackgroundTransparency = 1
    Container.ScrollBarThickness = 0
    Container.Parent = Panel

    local PanelStroke = Instance.new("UIStroke")
    PanelStroke.Color = Color3.fromRGB(45, 45, 50)
    PanelStroke.Thickness = 1
    PanelStroke.Parent = Panel

    table.insert(ThemeObjects.Panels, {
        Bg = Panel,
        Header = HeaderBg,
        HeaderSquare = HeaderSquare,
        Stroke = PanelStroke
    })

    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 5)
    Layout.Parent = Container

    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 15)
    Padding.PaddingRight = UDim.new(0, 15)
    Padding.Parent = Container

    Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    return Container
end

local function CreateSectionLabel(parent, text)
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, 0, 0, 24)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = "— " .. text .. " —"
    Lbl.TextColor3 = Theme.TextDark
    Lbl.Font = Theme.FontBold
    Lbl.TextSize = 12
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = parent
    return Lbl
end

local function CreateToggle(parent, text, dotColor, settingKey, callback)
    local isToggled = Settings[settingKey]
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    if dotColor then
        local Dot = Instance.new("Frame")
        Dot.Size = UDim2.new(0, 6, 0, 6)
        Dot.Position = UDim2.new(0, 0, 0.5, -3)
        Dot.BackgroundColor3 = dotColor
        Dot.Parent = Frame
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    end

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, dotColor and 15 or 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.RichText = true
    Label.Text = text
    Label.TextColor3 = Theme.TextWhite
    Label.Font = Theme.Font
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 40, 0, 20)
    ToggleBtn.Position = UDim2.new(1, -40, 0.5, -10)
    ToggleBtn.BackgroundColor3 = isToggled and Theme.AccentOn or Theme.AccentOff
    ToggleBtn.Text = ""
    ToggleBtn.Parent = Frame
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Knob.BackgroundColor3 = isToggled and Theme.KnobOn or Theme.KnobOff
    Knob.Parent = ToggleBtn
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local state = isToggled

    local function SetVisual(val)
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = val and Theme.AccentOn or Theme.AccentOff
        }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.2), {
            Position = val and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = val and Theme.KnobOn or Theme.KnobOff
        }):Play()
    end

    local tabName = nil
    for name, tab in pairs(Tabs) do
        if tab == parent then
            tabName = name
            break
        end
    end
    if tabName then
        if not TabActiveKeys[tabName] then TabActiveKeys[tabName] = {} end
        TabActiveKeys[tabName][settingKey] = true
        SearchIndex[settingKey] = { Label = text, Frame = Frame, Tab = tabName }
    end

    local reg = { State = isToggled }
    table.insert(ThemeObjects.Toggles, {
        Btn = ToggleBtn, Knob = Knob,
        State = isToggled
    })
    reg = ThemeObjects.Toggles[#ThemeObjects.Toggles]

    UI_Elements[settingKey] = {
        SetValue = function(val)
            state = val
            reg.State = val
            SetVisual(val)
            UpdateTabDots()
            if callback then callback(val) end
        end
    }

    Frame.MouseEnter:Connect(function() ShowTooltip(text) end)
    Frame.MouseLeave:Connect(function() ShowTooltip(nil) end)

    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        reg.State = state
        SetVisual(state)
        if state then
            SendNotification("Đã Bật", text)
        else
            SendNotification("Đã Tắt", text)
        end
        UpdateTabDots()
        if callback then callback(state) end
    end)
end

local function CreateSafeToggle(parent, text, dotColor, settingKey, callback)
    local isToggled = Settings[settingKey]
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    if dotColor then
        local Dot = Instance.new("Frame")
        Dot.Size = UDim2.new(0, 6, 0, 6)
        Dot.Position = UDim2.new(0, 0, 0.5, -3)
        Dot.BackgroundColor3 = dotColor
        Dot.Parent = Frame
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    end

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, dotColor and 15 or 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.RichText = true
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 50, 50)
    Label.Font = Theme.FontBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 40, 0, 20)
    ToggleBtn.Position = UDim2.new(1, -40, 0.5, -10)
    ToggleBtn.BackgroundColor3 = isToggled and Theme.AccentOn or Theme.AccentOff
    ToggleBtn.Text = ""
    ToggleBtn.Parent = Frame
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Knob.BackgroundColor3 = isToggled and Theme.KnobOn or Theme.KnobOff
    Knob.Parent = ToggleBtn
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local state = isToggled

    local function SetVisual(val)
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = val and Theme.AccentOn or Theme.AccentOff
        }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.2), {
            Position = val and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = val and Theme.KnobOn or Theme.KnobOff
        }):Play()
    end

    local tabName = nil
    for name, tab in pairs(Tabs) do
        if tab == parent then
            tabName = name
            break
        end
    end
    if tabName then
        if not TabActiveKeys[tabName] then TabActiveKeys[tabName] = {} end
        TabActiveKeys[tabName][settingKey] = true
        SearchIndex[settingKey] = { Label = text, Frame = Frame, Tab = tabName }
    end

    local reg = { State = isToggled }
    table.insert(ThemeObjects.Toggles, {
        Btn = ToggleBtn, Knob = Knob,
        State = isToggled
    })
    reg = ThemeObjects.Toggles[#ThemeObjects.Toggles]

    UI_Elements[settingKey] = {
        SetValue = function(val)
            state = val
            reg.State = val
            SetVisual(val)
            UpdateTabDots()
            if callback then callback(val) end
        end
    }

    Frame.MouseEnter:Connect(function() ShowTooltip(text) end)
    Frame.MouseLeave:Connect(function() ShowTooltip(nil) end)

    local warnState = 0
    ToggleBtn.MouseButton1Click:Connect(function()
        if state == true then
            if warnState == 0 then
                warnState = 1
                SendNotification("Nguy Hiểm", "Tắt chế độ bảo vệ có thể bị Ban! Bấm lần nữa để TẮT.")
                ToggleBtn.BackgroundColor3 = Theme.DotRed
                task.delay(3, function()
                    if warnState == 1 then
                        warnState = 0
                        ToggleBtn.BackgroundColor3 = Theme.AccentOn
                    end
                end)
                return
            end
        end
        warnState = 0
        state = not state
        reg.State = state
        SetVisual(state)
        if state then
            SendNotification("An Toàn", "Hệ thống bảo vệ đã BẬT!")
        else
            SendNotification("Nguy Hiểm", "Hệ thống tự vệ đã tắt, cẩn thận!")
        end
        UpdateTabDots()
        if callback then callback(state) end
    end)
end

local function CreateToggleWithDropdown(parent, toggleText, dotColor, toggleKey, dropKey, options, toggleCb, dropCb)
    local isToggled = Settings[toggleKey]
    local currentVal = Settings[dropKey]
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.ClipsDescendants = true
    Frame.Parent = parent

    -- Dot
    if dotColor then
        local Dot = Instance.new("Frame")
        Dot.Size = UDim2.new(0, 6, 0, 6)
        Dot.Position = UDim2.new(0, 0, 0.5, -3)
        Dot.BackgroundColor3 = dotColor
        Dot.Parent = Frame
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    end

    -- Toggle Label
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -145, 0, 35)
    Label.Position = UDim2.new(0, dotColor and 15 or 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.RichText = true
    Label.Text = toggleText
    Label.TextColor3 = Theme.TextWhite
    Label.Font = Theme.Font
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    -- Dropdown Button in the middle
    local Dropbox = Instance.new("TextButton")
    Dropbox.Size = UDim2.new(0, 75, 0, 24)
    Dropbox.Position = UDim2.new(1, -125, 0, 5)
    Dropbox.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
    Dropbox.Text = ""
    Dropbox.Parent = Frame
    Instance.new("UICorner", Dropbox).CornerRadius = UDim.new(0, 6)

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(1, -20, 1, 0)
    ValLabel.Position = UDim2.new(0, 6, 0, 0)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Text = currentVal
    ValLabel.TextColor3 = Theme.TextWhite
    ValLabel.Font = Theme.Font
    ValLabel.TextSize = 12
    ValLabel.TextXAlignment = Enum.TextXAlignment.Left
    ValLabel.Parent = Dropbox

    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.new(0, 16, 1, 0)
    Arrow.Position = UDim2.new(1, -16, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "v"
    Arrow.TextColor3 = Theme.TextDark
    Arrow.Font = Theme.Font
    Arrow.TextSize = 11
    Arrow.Parent = Dropbox

    local ListFrame = Instance.new("Frame")
    ListFrame.Size = UDim2.new(0, 75, 0, #options * 25)
    ListFrame.Position = UDim2.new(1, -125, 0, 32)
    ListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
    ListFrame.BorderSizePixel = 0
    ListFrame.Parent = Frame
    Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 6)

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = ListFrame

    local isOpen = false

    for _, opt in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, 0, 0, 25)
        OptBtn.BackgroundTransparency = 1
        OptBtn.Text = opt
        OptBtn.TextColor3 = Theme.TextWhite
        OptBtn.Font = Theme.Font
        OptBtn.TextSize = 12
        OptBtn.Parent = ListFrame

        OptBtn.MouseButton1Click:Connect(function()
            ValLabel.Text = opt
            isOpen = false
            TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 35)}):Play()
            Arrow.Text = "v"
            if dropCb then dropCb(opt) end
        end)
    end

    Dropbox.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            TweenService:Create(Frame, TweenInfo.new(0.2), {
                Size = UDim2.new(1, 0, 0, 35 + (#options * 25))
            }):Play()
            Arrow.Text = "^"
        else
            TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 35)}):Play()
            Arrow.Text = "v"
        end
    end)

    -- Toggle Button on the right
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 40, 0, 20)
    ToggleBtn.Position = UDim2.new(1, -40, 0.5, -10)
    ToggleBtn.BackgroundColor3 = isToggled and Theme.AccentOn or Theme.AccentOff
    ToggleBtn.Text = ""
    ToggleBtn.Parent = Frame
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Knob.BackgroundColor3 = isToggled and Theme.KnobOn or Theme.KnobOff
    Knob.Parent = ToggleBtn
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local state = isToggled

    local function SetVisual(val)
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = val and Theme.AccentOn or Theme.AccentOff
        }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.2), {
            Position = val and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = val and Theme.KnobOn or Theme.KnobOff
        }):Play()
    end

    local tabName = nil
    for name, tab in pairs(Tabs) do
        if tab == parent then
            tabName = name
            break
        end
    end
    if tabName then
        if not TabActiveKeys[tabName] then TabActiveKeys[tabName] = {} end
        TabActiveKeys[tabName][toggleKey] = true
        SearchIndex[toggleKey] = { Label = toggleText, Frame = Frame, Tab = tabName }
        SearchIndex[dropKey] = { Label = "Target Part", Frame = Frame, Tab = tabName }
    end

    table.insert(ThemeObjects.Toggles, {
        Btn = ToggleBtn, Knob = Knob,
        State = isToggled
    })
    local reg = ThemeObjects.Toggles[#ThemeObjects.Toggles]
    table.insert(ThemeObjects.Dropbox, { Box = Dropbox })

    UI_Elements[toggleKey] = {
        SetValue = function(val)
            state = val
            reg.State = val
            SetVisual(val)
            UpdateTabDots()
            if toggleCb then toggleCb(val) end
        end
    }

    UI_Elements[dropKey] = {
        SetValue = function(val)
            ValLabel.Text = val
            if dropCb then dropCb(val) end
        end
    }

    Frame.MouseEnter:Connect(function() ShowTooltip(toggleText) end)
    Frame.MouseLeave:Connect(function() ShowTooltip(nil) end)

    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        reg.State = state
        SetVisual(state)
        if state then
            SendNotification("Đã Bật", toggleText)
        else
            SendNotification("Đã Tắt", toggleText)
        end
        UpdateTabDots()
        if toggleCb then toggleCb(state) end
    end)
end

local function CreateToggleWithKeybind(parent, toggleText, dotColor, toggleKey, keyKey, toggleCb, keyCb)
    local isToggled = Settings[toggleKey]
    local currentVal = Settings[keyKey]
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    -- Dot
    if dotColor then
        local Dot = Instance.new("Frame")
        Dot.Size = UDim2.new(0, 6, 0, 6)
        Dot.Position = UDim2.new(0, 0, 0.5, -3)
        Dot.BackgroundColor3 = dotColor
        Dot.Parent = Frame
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    end

    -- Toggle Label
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -145, 0, 35)
    Label.Position = UDim2.new(0, dotColor and 15 or 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.RichText = true
    Label.Text = toggleText
    Label.TextColor3 = Theme.TextWhite
    Label.Font = Theme.Font
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    -- Keybind Button in the middle
    local KeyBtn = Instance.new("TextButton")
    KeyBtn.Size = UDim2.new(0, 75, 0, 24)
    KeyBtn.Position = UDim2.new(1, -125, 0, 5)
    KeyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 38)

    local function FormatKeyName(key)
        if not key then return "None" end
        local name = (typeof(key) == "EnumItem") and key.Name or tostring(key)
        if name == "MouseButton1" then return "LClick" end
        if name == "MouseButton2" then return "RClick" end
        if name == "MouseButton3" then return "MClick" end
        return name
    end

    KeyBtn.Text = FormatKeyName(currentVal)
    KeyBtn.TextColor3 = Theme.TextWhite
    KeyBtn.Font = Theme.Font
    KeyBtn.TextSize = 12
    KeyBtn.Parent = Frame
    Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 6)

    local isBinding = false
    local connection

    KeyBtn.MouseButton1Click:Connect(function()
        if isBinding then return end
        KeyBtn.Text = "..."
        task.wait(0.1)
        isBinding = true

        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard
                or input.UserInputType.Name:match("MouseButton") then
                local newKey = (input.KeyCode == Enum.KeyCode.Unknown)
                    and input.UserInputType or input.KeyCode
                if newKey.Name == "Unknown" then return end

                isBinding = false
                KeyBtn.Text = FormatKeyName(newKey)
                Settings[keyKey] = newKey
                if keyCb then keyCb(newKey) end

                if connection then
                    connection:Disconnect()
                    connection = nil
                end
            end
        end)
    end)

    -- Toggle Button on the right
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 40, 0, 20)
    ToggleBtn.Position = UDim2.new(1, -40, 0.5, -10)
    ToggleBtn.BackgroundColor3 = isToggled and Theme.AccentOn or Theme.AccentOff
    ToggleBtn.Text = ""
    ToggleBtn.Parent = Frame
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Knob.BackgroundColor3 = isToggled and Theme.KnobOn or Theme.KnobOff
    Knob.Parent = ToggleBtn
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local state = isToggled

    local function SetVisual(val)
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = val and Theme.AccentOn or Theme.AccentOff
        }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.2), {
            Position = val and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = val and Theme.KnobOn or Theme.KnobOff
        }):Play()
    end

    local tabName = nil
    for name, tab in pairs(Tabs) do
        if tab == parent then
            tabName = name
            break
        end
    end
    if tabName then
        if not TabActiveKeys[tabName] then TabActiveKeys[tabName] = {} end
        TabActiveKeys[tabName][toggleKey] = true
        SearchIndex[toggleKey] = { Label = toggleText, Frame = Frame, Tab = tabName }
        SearchIndex[keyKey] = { Label = "Aim Key", Frame = Frame, Tab = tabName }
    end

    table.insert(ThemeObjects.Toggles, {
        Btn = ToggleBtn, Knob = Knob,
        State = isToggled
    })
    local reg = ThemeObjects.Toggles[#ThemeObjects.Toggles]
    table.insert(ThemeObjects.Dropbox, { Box = KeyBtn })

    UI_Elements[toggleKey] = {
        SetValue = function(val)
            state = val
            reg.State = val
            SetVisual(val)
            UpdateTabDots()
            if toggleCb then toggleCb(val) end
        end
    }

    UI_Elements[keyKey] = {
        SetValue = function(val)
            KeyBtn.Text = FormatKeyName(val)
            if keyCb then keyCb(val) end
        end
    }

    Frame.MouseEnter:Connect(function() ShowTooltip(toggleText) end)
    Frame.MouseLeave:Connect(function() ShowTooltip(nil) end)

    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        reg.State = state
        SetVisual(state)
        if state then
            SendNotification("Đã Bật", toggleText)
        else
            SendNotification("Đã Tắt", toggleText)
        end
        UpdateTabDots()
        if toggleCb then toggleCb(state) end
    end)
end

local function CreateDropdown(parent, text, settingKey, options, callback)
    local currentVal = Settings[settingKey]
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.ClipsDescendants = true
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 150, 0, 35)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.TextWhite
    Label.Font = Theme.Font
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Dropbox = Instance.new("TextButton")
    Dropbox.Size = UDim2.new(0, 100, 0, 24)
    Dropbox.Position = UDim2.new(1, -100, 0, 5)
    Dropbox.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
    Dropbox.Text = ""
    Dropbox.Parent = Frame
    Instance.new("UICorner", Dropbox).CornerRadius = UDim.new(0, 6)

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(1, -25, 1, 0)
    ValLabel.Position = UDim2.new(0, 10, 0, 0)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Text = currentVal
    ValLabel.TextColor3 = Theme.TextWhite
    ValLabel.Font = Theme.Font
    ValLabel.TextSize = 12
    ValLabel.TextXAlignment = Enum.TextXAlignment.Left
    ValLabel.Parent = Dropbox

    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.new(0, 20, 1, 0)
    Arrow.Position = UDim2.new(1, -20, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "v"
    Arrow.TextColor3 = Theme.TextDark
    Arrow.Font = Theme.Font
    Arrow.TextSize = 12
    Arrow.Parent = Dropbox

    local ListFrame = Instance.new("Frame")
    ListFrame.Size = UDim2.new(0, 100, 0, #options * 25)
    ListFrame.Position = UDim2.new(1, -100, 0, 32)
    ListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
    ListFrame.BorderSizePixel = 0
    ListFrame.Parent = Frame
    Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 6)

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = ListFrame

    local isOpen = false

    local tabName = nil
    for name, tab in pairs(Tabs) do
        if tab == parent then
            tabName = name
            break
        end
    end
    if tabName then
        SearchIndex[settingKey] = { Label = text, Frame = Frame, Tab = tabName }
    end
    table.insert(ThemeObjects.Dropbox, { Box = Dropbox })

    UI_Elements[settingKey] = {
        SetValue = function(val)
            ValLabel.Text = val
            if callback then callback(val) end
        end
    }

    Frame.MouseEnter:Connect(function() ShowTooltip(text) end)
    Frame.MouseLeave:Connect(function() ShowTooltip(nil) end)

    for _, opt in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, 0, 0, 25)
        OptBtn.BackgroundTransparency = 1
        OptBtn.Text = opt
        OptBtn.TextColor3 = Theme.TextWhite
        OptBtn.Font = Theme.Font
        OptBtn.TextSize = 12
        OptBtn.Parent = ListFrame

        OptBtn.MouseButton1Click:Connect(function()
            ValLabel.Text = opt
            isOpen = false
            TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 35)}):Play()
            Arrow.Text = "v"
            if callback then callback(opt) end
        end)
    end

    Dropbox.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            TweenService:Create(Frame, TweenInfo.new(0.2), {
                Size = UDim2.new(1, 0, 0, 35 + (#options * 25))
            }):Play()
            Arrow.Text = "^"
        else
            TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 35)}):Play()
            Arrow.Text = "v"
        end
    end)
end

local function CreateKeybind(parent, text, settingKey, callback)
    local currentVal = Settings[settingKey]
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 150, 0, 35)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.TextWhite
    Label.Font = Theme.Font
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local KeyBtn = Instance.new("TextButton")
    KeyBtn.Size = UDim2.new(0, 80, 0, 24)
    KeyBtn.Position = UDim2.new(1, -80, 0, 5)
    KeyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 38)

    local function FormatKeyName(key)
        if not key then return "None" end
        local name = key.Name
        if name == "MouseButton1" then return "LClick" end
        if name == "MouseButton2" then return "RClick" end
        if name == "MouseButton3" then return "MClick" end
        return name
    end

    KeyBtn.Text = FormatKeyName(currentVal)
    KeyBtn.TextColor3 = Theme.TextWhite
    KeyBtn.Font = Theme.Font
    KeyBtn.TextSize = 12
    KeyBtn.Parent = Frame
    Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 6)

    local isBinding = false
    local connection

    local tabName = nil
    for name, tab in pairs(Tabs) do
        if tab == parent then
            tabName = name
            break
        end
    end
    if tabName then
        SearchIndex[settingKey] = { Label = text, Frame = Frame, Tab = tabName }
    end
    table.insert(ThemeObjects.Dropbox, { Box = KeyBtn })

    Frame.MouseEnter:Connect(function() ShowTooltip(text) end)
    Frame.MouseLeave:Connect(function() ShowTooltip(nil) end)

    KeyBtn.MouseButton1Click:Connect(function()
        if isBinding then return end
        KeyBtn.Text = "..."
        task.wait(0.1)
        isBinding = true

        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard
                or input.UserInputType.Name:match("MouseButton") then
                local newKey = (input.KeyCode == Enum.KeyCode.Unknown)
                    and input.UserInputType or input.KeyCode
                if newKey.Name == "Unknown" then return end

                isBinding = false
                KeyBtn.Text = FormatKeyName(newKey)
                Settings[settingKey] = newKey
                if callback then callback(newKey) end

                if connection then
                    connection:Disconnect()
                    connection = nil
                end
            end
        end)
    end)
end

local function CreatePlayerDropdown(parent, text, settingKey, callback)
    local currentVal = Settings[settingKey]
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.ClipsDescendants = true
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 150, 0, 35)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.TextWhite
    Label.Font = Theme.Font
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Dropbox = Instance.new("TextButton")
    Dropbox.Size = UDim2.new(0, 100, 0, 24)
    Dropbox.Position = UDim2.new(1, -100, 0, 5)
    Dropbox.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
    Dropbox.Text = ""
    Dropbox.Parent = Frame
    Instance.new("UICorner", Dropbox).CornerRadius = UDim.new(0, 6)

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(1, -25, 1, 0)
    ValLabel.Position = UDim2.new(0, 10, 0, 0)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Text = (currentVal == "" or currentVal == nil) and "Chọn Người" or currentVal
    ValLabel.TextColor3 = Theme.TextWhite
    ValLabel.Font = Theme.Font
    ValLabel.TextSize = 12
    ValLabel.TextXAlignment = Enum.TextXAlignment.Left
    ValLabel.Parent = Dropbox

    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.new(0, 20, 1, 0)
    Arrow.Position = UDim2.new(1, -20, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "v"
    Arrow.TextColor3 = Theme.TextDark
    Arrow.Font = Theme.Font
    Arrow.TextSize = 12
    Arrow.Parent = Dropbox

    local ListFrame = Instance.new("Frame")
    ListFrame.Position = UDim2.new(1, -100, 0, 32)
    ListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
    ListFrame.BorderSizePixel = 0
    ListFrame.Parent = Frame
    Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 6)

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = ListFrame

    local isOpen = false

    local tabName = nil
    for name, tab in pairs(Tabs) do
        if tab == parent then
            tabName = name
            break
        end
    end
    if tabName then
        SearchIndex[settingKey] = { Label = text, Frame = Frame, Tab = tabName }
    end
    table.insert(ThemeObjects.Dropbox, { Box = Dropbox })

    UI_Elements[settingKey] = {
        SetValue = function(val)
            ValLabel.Text = (val == "" or val == nil) and "Chọn Người" or val
            if callback then callback(val) end
        end
    }

    Frame.MouseEnter:Connect(function() ShowTooltip(text) end)
    Frame.MouseLeave:Connect(function() ShowTooltip(nil) end)

    Dropbox.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            for _, child in pairs(ListFrame:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end

            local players = Players:GetPlayers()
            local listSize = math.min(#players, 6) * 25
            ListFrame.Size = UDim2.new(0, 100, 0, listSize)

            for _, player in ipairs(players) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 25)
                OptBtn.BackgroundTransparency = 1
                OptBtn.Text = player.Name
                OptBtn.TextColor3 = Theme.TextWhite
                OptBtn.Font = Theme.Font
                OptBtn.TextSize = 12
                OptBtn.Parent = ListFrame

                OptBtn.MouseButton1Click:Connect(function()
                    ValLabel.Text = player.Name
                    isOpen = false
                    TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 35)}):Play()
                    Arrow.Text = "v"
                    if callback then callback(player.Name) end
                end)
            end

            TweenService:Create(Frame, TweenInfo.new(0.2), {
                Size = UDim2.new(1, 0, 0, 35 + listSize)
            }):Play()
            Arrow.Text = "^"
        else
            TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 35)}):Play()
            Arrow.Text = "v"
        end
    end)
end

local function CreateSlider(parent, text, settingKey, min, max, suffix, callback)
    local value = Settings[settingKey]
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 120, 1, 0)
    Label.BackgroundTransparency = 1
    Label.RichText = true
    Label.Text = text
    Label.TextColor3 = Theme.TextWhite
    Label.Font = Theme.Font
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local hasSuffix = suffix and suffix ~= ""
    local inputOffset = hasSuffix and -60 or -40

    local ValInput = Instance.new("TextBox")
    ValInput.Size = UDim2.new(0, 35, 0, 20)
    ValInput.Position = UDim2.new(1, inputOffset, 0.5, -10)
    ValInput.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
    ValInput.TextColor3 = Theme.TextWhite
    ValInput.Font = Theme.Font
    ValInput.TextSize = 12
    ValInput.Text = tostring(value)
    ValInput.Parent = Frame
    Instance.new("UICorner", ValInput).CornerRadius = UDim.new(0, 4)

    if hasSuffix then
        local SuffixLbl = Instance.new("TextLabel")
        SuffixLbl.Size = UDim2.new(0, 20, 1, 0)
        SuffixLbl.Position = UDim2.new(1, -20, 0, 0)
        SuffixLbl.BackgroundTransparency = 1
        SuffixLbl.Text = suffix:gsub(" ", "")
        SuffixLbl.TextColor3 = Theme.TextDark
        SuffixLbl.Font = Theme.Font
        SuffixLbl.TextSize = 12
        SuffixLbl.TextXAlignment = Enum.TextXAlignment.Left
        SuffixLbl.Parent = Frame
    end

    local SliderBg = Instance.new("TextButton")
    SliderBg.Size = UDim2.new(1, -190, 0, 4)
    SliderBg.Position = UDim2.new(0, 125, 0.5, -2)
    SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 42)
    SliderBg.BorderSizePixel = 0
    SliderBg.Text = ""
    SliderBg.AutoButtonColor = false
    SliderBg.Parent = Frame
    Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)

    local pct = math.clamp((value - min) / (max - min), 0, 1)
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(pct, 0, 1, 0)
    SliderFill.BackgroundColor3 = Theme.TextWhite
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBg
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 10, 0, 10)
    Knob.Position = UDim2.new(1, -5, 0.5, -5)
    Knob.BackgroundColor3 = Theme.TextWhite
    Knob.Parent = SliderFill
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function updateSlider(pos)
        pos = math.clamp(pos, 0, 1)
        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
        local newVal = min + (max - min) * pos
        if max <= 1 then
            newVal = math.floor(newVal * 100) / 100
        else
            newVal = math.floor(newVal * 10) / 10
        end
        ValInput.Text = tostring(newVal)
        if callback then callback(newVal) end
    end

    SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local pos = (input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X
            updateSlider(pos)
        end
    end)
    SliderBg.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = (input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X
            updateSlider(pos)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UI_Elements[settingKey] = {
        SetValue = function(val)
            local pos = (val - min) / (max - min)
            SliderFill.Size = UDim2.new(pos, 0, 1, 0)
            ValInput.Text = tostring(val)
            if callback then callback(val) end
        end
    }

    local tabName = nil
    for name, tab in pairs(Tabs) do
        if tab == parent then
            tabName = name
            break
        end
    end
    if tabName then
        SearchIndex[settingKey] = { Label = text, Frame = Frame, Tab = tabName }
    end
    table.insert(ThemeObjects.SliderFills, { Fill = SliderFill })

    Frame.MouseEnter:Connect(function() ShowTooltip(text) end)
    Frame.MouseLeave:Connect(function() ShowTooltip(nil) end)

    ValInput.FocusLost:Connect(function()
        local num = tonumber(ValInput.Text)
        if num then
            num = math.clamp(num, min, max)
            local pos = (num - min) / (max - min)
            updateSlider(pos)
        else
            local currentPos = SliderFill.Size.X.Scale
            updateSlider(currentPos)
        end
    end)
end

local function CreateButtonWithConfirm(parent, text, warningText, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 45)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -30, 1, -10)
    Btn.Position = UDim2.new(0, 15, 0, 5)
    Btn.BackgroundColor3 = Theme.AccentOff
    Btn.TextColor3 = Theme.TextWhite
    Btn.Font = Theme.FontBold
    Btn.TextSize = 13
    Btn.Text = text
    Btn.Parent = Frame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local state = 0
    Btn.MouseButton1Click:Connect(function()
        if state == 0 then
            state = 1
            Btn.Text = "BẤM LẦN NỮA ĐỂ XÁC NHẬN"
            Btn.BackgroundColor3 = Theme.DotRed
            SendNotification("Nguy Hiểm", warningText)
            task.delay(3, function()
                if state == 1 then
                    state = 0
                    Btn.Text = text
                    Btn.BackgroundColor3 = Theme.AccentOff
                end
            end)
        elseif state == 1 then
            state = 2
            Btn.Text = "ĐÃ KÍCH HOẠT"
            Btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            if callback then callback() end
        end
    end)
end

-- Hitbox Expander Cache & Reset Logic
local originalHitboxes = {}
local function ResetHitboxes()
    for part, orig in pairs(originalHitboxes) do
        if part and part.Parent then
            pcall(function()
                part.Size = orig.Size
                part.Transparency = orig.Transparency
                part.CanCollide = orig.CanCollide
            end)
        end
    end
    table.clear(originalHitboxes)
end

-- ============================================================
-- XÂY DỰNG TABS
-- ============================================================
local PanelAimbot = CreatePanel(TabAimbot, "Aimbot", "", 0, 0, 0.5, 1)
CreateToggleWithDropdown(PanelAimbot, "Enable Aimbot", Theme.DotGreen, "AimEnabled", "TargetPart", {"Head", "HumanoidRootPart", "Safe"}, function(v) 
    Settings.AimEnabled = v 
end, function(v) 
    Settings.TargetPart = v
    Settings.ProAimTargetPart = v
end)
CreateSlider(PanelAimbot, "FOV Size", "FOV", 10, 500, " px", function(v)
    Settings.FOV = v
    Settings.ProAimFOV = v
    FOVring.Radius = v
end)
CreateToggle(PanelAimbot, "Aim Safe", Theme.DotGreen, "AimSafe", function(v) Settings.AimSafe = v end)
CreateToggle(PanelAimbot, "Draw FOV", Theme.DotGreen, "FOVVisible", function(v)
    Settings.FOVVisible = v
    Settings.ProAimFOVVisible = v
    Settings.AimSnapline = v
    Settings.ProAimSnapline = v
    FOVring.Visible = v
end)
CreateToggleWithDropdown(PanelAimbot, "Hitbox Expander", Theme.DotGreen, "HitboxExpander", "HitboxPart", {"Head", "Torso"}, function(v)
    Settings.HitboxExpander = v
    if not v then ResetHitboxes() end
end, function(v)
    Settings.HitboxPart = v
    ResetHitboxes()
end)
CreateSlider(PanelAimbot, "Hitbox Size", "HitboxSize", 2, 500, " studs", function(v)
    Settings.HitboxSize = v
end)
CreateToggle(PanelAimbot, "Hide Hitbox (Ẩn Khung)", Theme.DotGreen, "HitboxInvisible", function(v)
    Settings.HitboxInvisible = v
    for part, orig in pairs(originalHitboxes) do
        if part and part.Parent then
            pcall(function()
                part.Transparency = v and 1 or 0.55
            end)
        end
    end
end)

local PanelAimbotSet = CreatePanel(TabAimbot, "Exploits", "", 0.5, 0, 0.5, 1)
CreateToggle(PanelAimbotSet, "Kill Aura", Theme.DotRed, "AutoFire", function(v) Settings.AutoFire = v end)
CreateToggle(PanelAimbotSet, "Wall Check ", Theme.DotRed, "AutoFireWallCheck", function(v) Settings.AutoFireWallCheck = v end)
CreateToggle(PanelAimbotSet, 'Slient Aim <font color="#ff3333">[BETA]</font>', Theme.DotRed, "AutoFireHoldM2", function(v) Settings.AutoFireHoldM2 = v end)
CreateToggleWithKeybind(PanelAimbotSet, 'NO RECOIL <font color="#ff3333">[BETA]</font>', Theme.DotRed, "NoRecoil", "NoRecoilHotkey", function(v) Settings.NoRecoil = v end, function(v) Settings.NoRecoilHotkey = v end)
CreateToggleWithKeybind(PanelAimbotSet, "Aimlock", Theme.DotRed, "ProAimEnabled", "ProAimHoldMouse", function(v) Settings.ProAimEnabled = v end, function(v) Settings.ProAimHoldMouse = v end)
CreateSlider(PanelAimbotSet, "Aimlock Smooth", "ProAimSmoothness", 0.01, 1, "", function(v)
    Settings.ProAimSmoothness = v
    Settings.AimSmoothness = v
end)

local PanelESP = CreatePanel(TabESP, "ESP", "", 0, 0, 0.5, 1)
CreateToggle(PanelESP, "Enable ESP", Theme.DotGreen, "ESPEnabled", function(v)
    Settings.ESPEnabled = v
    if not v and Shared.ESPTable then
        for _, esp in pairs(Shared.ESPTable) do
            if Shared.hideAllESP then
                Shared.hideAllESP(esp)
            elseif ESP and ESP.hideAllESP then
                ESP.hideAllESP(esp)
            end
        end
    end
    if ESPCounterBox then
        ESPCounterBox.Visible = v and Settings.ESPCount
    end
end)
CreateToggleWithDropdown(PanelESP, "Chams", Theme.DotGreen, "ESPChams", "ChamsColor", {"Red", "Green", "White", "Blue", "Yellow", "Pink"}, function(v) Settings.ESPChams = v end, function(v) Settings.ChamsColor = v end)
CreateToggle(PanelESP, "Skeleton", Theme.DotGreen, "ESPSkeleton", function(v) Settings.ESPSkeleton = v end)
CreateToggle(PanelESP, "Box", Theme.DotGreen, "ESPBox", function(v) Settings.ESPBox = v end)
CreateToggle(PanelESP, "Name", Theme.DotGreen, "ESPName", function(v) Settings.ESPName = v end)
CreateToggle(PanelESP, "Health", Theme.DotGreen, "ESPHealth", function(v) Settings.ESPHealth = v end)
CreateToggle(PanelESP, "Distance", Theme.DotGreen, "ESPDistance", function(v) Settings.ESPDistance = v end)
CreateToggle(PanelESP, "Look Line", Theme.DotGreen, "ESPLine", function(v) Settings.ESPLine = v end)
CreateToggle(PanelESP, "Weapon", Theme.DotGreen, "ESPWeapon", function(v) Settings.ESPWeapon = v end)
CreateToggle(PanelESP, "Level/XP", Theme.DotGreen, "ESPLevel", function(v) Settings.ESPLevel = v end)
CreateToggle(PanelESP, "Player Count (Top)", Theme.DotGreen, "ESPCount", function(v)
    Settings.ESPCount = v
    if ESPCounterBox then
        ESPCounterBox.Visible = Settings.ESPEnabled and v
    end
end)
CreateToggle(PanelESP, "Aim Warning", Theme.DotGreen, "AimWarning", function(v) Settings.AimWarning = v end)
CreateToggle(PanelESP, 'Arrows <font color="#ff3333">[BETA]</font>', Theme.DotGreen, "OffscreenArrows", function(v)
    Settings.OffscreenArrows = v
    if not v and Shared.ESPTable then
        for _, esp in pairs(Shared.ESPTable) do
            if esp.Arrow1 then esp.Arrow1.Visible = false end
            if esp.Arrow2 then esp.Arrow2.Visible = false end
            if esp.Arrow3 then esp.Arrow3.Visible = false end
        end
    end
end)

local PanelESPSet = CreatePanel(TabESP, "Settings", "⚙", 0.5, 0, 0.5, 1)
CreateToggle(PanelESPSet, "Team Check", Theme.DotGreen, "TeamCheck", function(v)
    Settings.TeamCheck = v
    Settings.ESPTeamCheck = v
    Settings.ProAimTeamCheck = v
end)
CreateToggle(PanelESPSet, "Bot [BETA]", Theme.DotGreen, "TargetNPC", function(v)
    Settings.TargetNPC = v
    if not v then
        if Shared.NPCCache then table.clear(Shared.NPCCache) end
        if Shared.ESPTable then
            for target, esp in pairs(Shared.ESPTable) do
                if typeof(target) == "Instance" and not target:IsA("Player") then
                    if Shared.removeESP then
                        Shared.removeESP(target)
                    elseif ESP and ESP.removeESP then
                        ESP.removeESP(target)
                    end
                end
            end
        end
    end
end)
CreateSlider(PanelESPSet, "Max Aim Dist", "AimDist", 1, 2000, " m", function(v) 
    Settings.AimDist = v
    Settings.ProAimDist = v
end)
CreateSlider(PanelESPSet, "Max ESP Dist", "ESPDist", 1, 2000, " m", function(v) Settings.ESPDist = v end)

local PanelPlayer = CreatePanel(TabPlayer, "Exploits", "", 0, 0, 0.5, 1)
local function CheckAndBypassCharacterAC(featureName)
    if not Settings.BypassACMove then
        SendNotification("⚠️ NGUY HIỂM ⚠️", "Nguy cơ BAN khi dùng " .. featureName .. ". Bật lại an toàn!")
        return false
    end

    local disconnected = 0
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then
            local connections = {}
            if getconnections then
                for _, conn in pairs(getconnections(hum:GetPropertyChangedSignal("WalkSpeed"))) do
                    table.insert(connections, conn)
                end
                for _, conn in pairs(getconnections(hum:GetPropertyChangedSignal("JumpPower"))) do
                    table.insert(connections, conn)
                end
                for _, conn in pairs(getconnections(hum.StateChanged)) do
                    table.insert(connections, conn)
                end
                for _, conn in pairs(getconnections(Workspace:GetPropertyChangedSignal("Gravity"))) do
                    table.insert(connections, conn)
                end
            end
            for _, conn in ipairs(connections) do
                if conn.Disable then
                    conn:Disable()
                    disconnected = disconnected + 1
                end
            end
        end
    end)
    if disconnected > 0 then
        SendNotification("🛡 Bypass", "Vô hiệu hóa " .. disconnected .. " bẫy theo dõi cho " .. featureName)
    end
    return true
end

CreateToggle(PanelPlayer, "Speed Buff", Theme.DotGreen, "SpeedHack", function(v)
    if v and not CheckAndBypassCharacterAC("SpeedHack") then
        Settings.SpeedHack = false
        if UI_Elements.SpeedHack then UI_Elements.SpeedHack.SetValue(false) end
        return
    end
    Settings.SpeedHack = v
end)
CreateToggle(PanelPlayer, "Jump Buff", Theme.DotGreen, "JumpHack", function(v)
    if v and not CheckAndBypassCharacterAC("JumpHack") then
        Settings.JumpHack = false
        if UI_Elements.JumpHack then UI_Elements.JumpHack.SetValue(false) end
        return
    end
    Settings.JumpHack = v
end)
CreateToggle(PanelPlayer, "Inf Jump", Theme.DotGreen, "InfJump", function(v)
    if v and not CheckAndBypassCharacterAC("Inf Jump") then
        Settings.InfJump = false
        if UI_Elements.InfJump then UI_Elements.InfJump.SetValue(false) end
        return
    end
    Settings.InfJump = v
end)
CreateToggle(PanelPlayer, "Fly", Theme.DotGreen, "Fly", function(v)
    if v and not CheckAndBypassCharacterAC("Fly") then
        Settings.Fly = false
        if UI_Elements.Fly then UI_Elements.Fly.SetValue(false) end
        return
    end
    Settings.Fly = v
end)
CreateToggle(PanelPlayer, "Noclip", Theme.DotGreen, "Noclip", function(v)
    if v and not CheckAndBypassCharacterAC("Noclip") then
        Settings.Noclip = false
        if UI_Elements.Noclip then UI_Elements.Noclip.SetValue(false) end
        return
    end
    Settings.Noclip = v
end)
CreateToggle(PanelPlayer, "Gravity", Theme.DotGreen, "GravityHack", function(v)
    if v and not CheckAndBypassCharacterAC("Gravity") then
        Settings.GravityHack = false
        if UI_Elements.GravityHack then UI_Elements.GravityHack.SetValue(false) end
        return
    end
    Settings.GravityHack = v
    if v then
        Workspace.Gravity = Settings.Gravity
    else
        Workspace.Gravity = 196.2
    end
end)
CreateToggle(PanelPlayer, "Slow Fall", Theme.DotGreen, "SlowFall", function(v)
    if v and not CheckAndBypassCharacterAC("Slow Fall") then
        Settings.SlowFall = false
        if UI_Elements.SlowFall then UI_Elements.SlowFall.SetValue(false) end
        return
    end
    Settings.SlowFall = v
end)

CreateToggleWithKeybind(PanelPlayer, "Chui Đất", Theme.DotGreen, "UndergroundNoclip", "UndergroundHotkey", function(v)
    Settings.UndergroundNoclip = v
    if v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Shared.undergroundSurfaceY = LocalPlayer.Character.HumanoidRootPart.Position.Y
    elseif not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Shared.undergroundSurfaceY then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.CFrame = hrp.CFrame + Vector3.new(0, Shared.undergroundSurfaceY - hrp.Position.Y, 0)
        Shared.undergroundSurfaceY = nil
    end
end, function(v)
    Settings.UndergroundHotkey = v
end)

CreateToggleWithKeybind(PanelPlayer, "Tele", Theme.DotGreen, "AutoTeleport", "AutoTeleportHotkey", function(v)
    if v and not CheckAndBypassCharacterAC("Auto Teleport") then
        Settings.AutoTeleport = false
        if UI_Elements.AutoTeleport then UI_Elements.AutoTeleport.SetValue(false) end
        return
    end
    Settings.AutoTeleport = v
    if v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Shared.originalTeleportCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
    elseif not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Shared.originalTeleportCFrame then
        if Settings.AutoTeleportReturn then
            LocalPlayer.Character.HumanoidRootPart.CFrame = Shared.originalTeleportCFrame
        end
        Shared.originalTeleportCFrame = nil
    end
end, function(v)
    Settings.AutoTeleportHotkey = v
end)
CreateToggleWithKeybind(PanelPlayer, 'Speed Tele <font color="#ff3333">[BETA]</font>', Theme.DotGreen, "SpeedTele", "SpeedTeleHotkey", function(v)
    if v and not CheckAndBypassCharacterAC("Speed Tele") then
        Settings.SpeedTele = false
        if UI_Elements.SpeedTele then UI_Elements.SpeedTele.SetValue(false) end
        return
    end
    Settings.SpeedTele = v
    if v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Shared.originalSpeedTeleCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
    elseif not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Shared.originalSpeedTeleCFrame then
        if Settings.AutoTeleportReturn then
            LocalPlayer.Character.HumanoidRootPart.CFrame = Shared.originalSpeedTeleCFrame
        end
        Shared.originalSpeedTeleCFrame = nil
    end
end, function(v)
    Settings.SpeedTeleHotkey = v
end)
CreateToggle(PanelPlayer, 'SpinBot <font color="#ff3333">[BETA]</font>', Theme.DotGreen, "SpinBot", function(v)
    Settings.SpinBot = v
    if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.AutoRotate = true
    end
end)

local PanelPlayerSet = CreatePanel(TabPlayer, "Settings", "⚙", 0.5, 0, 0.5, 1)
CreateSlider(PanelPlayerSet, "Tốc Độ", "WalkSpeed", 16, 300, "", function(v) Settings.WalkSpeed = v end)
CreateSlider(PanelPlayerSet, "Lực Nhảy", "JumpPower", 50, 500, "", function(v) Settings.JumpPower = v end)
CreateSlider(PanelPlayerSet, "Tốc Độ Bay", "FlySpeed", 10, 300, "", function(v) Settings.FlySpeed = v end)
CreateSlider(PanelPlayerSet, "Trọng Lực (Gravity)", "Gravity", 0, 500, "", function(v)
    Settings.Gravity = v
    if Settings.GravityHack then
        Workspace.Gravity = v
    end
end)
CreateSlider(PanelPlayerSet, "Tốc Độ Rơi (Slow Fall)", "SlowFallSpeed", 1, 50, "", function(v)
    Settings.SlowFallSpeed = v
end)
CreateSlider(PanelPlayerSet, "Độ Sâu Chui", "UndergroundDistance", 1, 50, " m", function(v) Settings.UndergroundDistance = v end)
CreateSlider(PanelPlayerSet, "Phạm Vi Tele", "TeleportRange", 10, 2000, " m", function(v) Settings.TeleportRange = v end)
CreateSlider(PanelPlayerSet, "Cự Ly Bám Địch", "AutoTeleportDistance", 0, 100, " m", function(v) Settings.AutoTeleportDistance = v end)
CreateDropdown(PanelPlayerSet, "Vị Trí Tele", "AutoTeleportPosition", {"Sau Lưng", "Trên Đầu", "Random"}, function(v) Settings.AutoTeleportPosition = v end)
CreateToggle(PanelPlayerSet, "Tự Tele Về", Theme.DotGreen, "AutoTeleportReturn", function(v) Settings.AutoTeleportReturn = v end)
CreateToggle(PanelPlayerSet, "Kiểm Tra Khiên An Toàn", Theme.DotGreen, "SafeShieldCheck", function(v) Settings.SafeShieldCheck = v end)
CreateSlider(PanelPlayerSet, "Tốc Độ Speed Tele", "SpeedTeleSpeed", 10, 300, "", function(v) Settings.SpeedTeleSpeed = v end)
CreateSlider(PanelPlayerSet, "Tốc Độ Xoay", "SpinSpeed", 10, 100, "", function(v) Settings.SpinSpeed = v end)

local PanelOptim = CreatePanel(TabSecurity, "Tối Ưu Hóa Máy Yếu", "🚀", 0, 0, 0.5, 1)
CreateToggle(PanelOptim, "Tắt Đổ Bóng", Theme.DotGreen, "OptimShadows", function(v)
    Settings.OptimShadows = v
    Lighting.GlobalShadows = not v
end)
CreateToggle(PanelOptim, "Plastic Mode", Theme.DotGreen, "OptimTextures", function(v)
    Settings.OptimTextures = v
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = v and Enum.Material.SmoothPlastic or Enum.Material.Plastic
        end
    end
end)
CreateToggle(PanelOptim, "Xóa Sương Mù", Theme.DotGreen, "OptimFog", function(v)
    Settings.OptimFog = v
    if v then
        Lighting.FogEnd = 100000
    else
        Lighting.FogEnd = 10000
    end
end)

CreateButtonWithConfirm(PanelOptim, "POTATO MODE", "Cảnh báo: Không thể hoàn tác! Hình ảnh game bị xóa sạch để buff FPS.", function()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    Lighting.ClockTime = 12

    local Terrain = Workspace:FindFirstChildOfClass("Terrain")
    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterColor = Color3.fromRGB(0, 0, 0)
        pcall(function() sethiddenproperty(Terrain, "Decoration", false) end)
    end

    task.spawn(function()
        local descendants = game:GetDescendants()
        for i = 1, #descendants do
            local obj = descendants[i]
            if obj:IsA("PostEffect") or obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect")
                or obj:IsA("ColorCorrectionEffect") or obj:IsA("BloomEffect")
                or obj:IsA("DepthOfFieldEffect") or obj:IsA("Atmosphere") or obj:IsA("Sky") then
                pcall(function() obj:Destroy() end)
            elseif obj:IsA("BasePart") then
                pcall(function()
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.CastShadow = false
                end)
            elseif obj:IsA("MeshPart") then
                pcall(function()
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.CastShadow = false
                    obj.TextureID = ""
                end)
            elseif obj:IsA("SpecialMesh") then
                if obj.MeshType == Enum.MeshType.FileMesh then
                    pcall(function() obj.TextureID = "" end)
                    pcall(function() obj.TextureId = "" end)
                end
            elseif obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("SurfaceAppearance") then
                pcall(function() obj:Destroy() end)
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
                or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                pcall(function() obj:Destroy() end)
            end
            if i % 250 == 0 then
                task.wait()
            end
        end
        SendNotification("Potato Mode", "Đã dọn dẹp đồ họa để buff FPS!")
    end)
end)

local PanelSettings = CreatePanel(TabSecurity, "Bảo Mật", "", 0.5, 0, 0.5, 1)
CreateKeybind(PanelSettings, "Phím Ẩn/Hiện Menu", "ToggleKeybind", function(key) Settings.ToggleKeybind = key end)

local function RejoinServer()
    SendNotification("🔄 Set Prosers", "Đang kết nối lại Server...")
    task.spawn(function()
        pcall(function()
            if #Players:GetPlayers() <= 1 then
                LocalPlayer:Kick("\n[Rejoin] Đang kết nối lại Server...")
                task.wait(0.5)
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            else
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
        end)
    end)
end



do
    local BtnSave = Instance.new("TextButton")
    BtnSave.Size = UDim2.new(1, 0, 0, 30)
    BtnSave.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
    BtnSave.TextColor3 = Color3.fromRGB(175, 175, 185)
    BtnSave.Font = Theme.Font
    BtnSave.TextSize = 12
    BtnSave.Text = "Lưu Cài Đặt (Save)"
    BtnSave.Parent = PanelSettings
    Instance.new("UICorner", BtnSave).CornerRadius = UDim.new(0, 6)
    BtnSave.MouseButton1Click:Connect(function() SaveConfig(false) end)

    local BtnLoad = Instance.new("TextButton")
    BtnLoad.Size = UDim2.new(1, 0, 0, 32)
    BtnLoad.BackgroundColor3 = Color3.fromRGB(0, 210, 110)
    BtnLoad.TextColor3 = Color3.fromRGB(10, 25, 18)
    BtnLoad.Font = Theme.FontBold
    BtnLoad.TextSize = 13
    BtnLoad.Text = "⚡ Tải Cài Đặt (Load)"
    BtnLoad.Parent = PanelSettings
    Instance.new("UICorner", BtnLoad).CornerRadius = UDim.new(0, 6)
    BtnLoad.MouseButton1Click:Connect(function() LoadConfig(false) end)

    local BtnRejoin = Instance.new("TextButton")
    BtnRejoin.Size = UDim2.new(1, 0, 0, 30)
    BtnRejoin.BackgroundColor3 = Color3.fromRGB(35, 45, 60)
    BtnRejoin.TextColor3 = Theme.TextWhite
    BtnRejoin.Font = Theme.FontBold
    BtnRejoin.TextSize = 13
    BtnRejoin.Text = "Set Prosers"
    BtnRejoin.Parent = PanelSettings
    Instance.new("UICorner", BtnRejoin).CornerRadius = UDim.new(0, 6)
    BtnRejoin.MouseButton1Click:Connect(RejoinServer)
end

-- Toggle UI với slide animation (Chặn mở Menu khi chưa check key/kết nối)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Settings.ToggleKeybind then


        if MainFrame.Visible then
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                {Position = UDim2.new(0.5, -325, 1.5, 0)}):Play()
            task.delay(0.3, function() MainFrame.Visible = false end)
        else
            MainFrame.Position = UDim2.new(0.5, -325, 1.5, 0)
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                {Position = UDim2.new(0.5, -325, 0.5, -210)}):Play()
        end
    end
end)

-- Phím tắt nhanh bật/tắt
UserInputService.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Settings.NoRecoilHotkey and Settings.NoRecoilHotkey ~= Enum.KeyCode.None then
        Settings.NoRecoil = not Settings.NoRecoil
        if UI_Elements.NoRecoil then UI_Elements.NoRecoil.SetValue(Settings.NoRecoil) end
        UpdateTabDots()
        SendNotification("Hotkey", "No Recoil: " .. (Settings.NoRecoil and "BẬT" or "TẮT"))
        return
    end
    if gpe then return end
    if input.KeyCode == Settings.AimHotkey and Settings.AimHotkey ~= Enum.KeyCode.None then
        Settings.AimEnabled = not Settings.AimEnabled
        if UI_Elements.AimEnabled then UI_Elements.AimEnabled.SetValue(Settings.AimEnabled) end
        UpdateTabDots()
        SendNotification("Hotkey", "Aim: " .. (Settings.AimEnabled and "BẬT" or "TẮT"))
    elseif input.KeyCode == Settings.AutoFireHotkey and Settings.AutoFireHotkey ~= Enum.KeyCode.None then
        Settings.AutoFire = not Settings.AutoFire
        if UI_Elements.AutoFire then UI_Elements.AutoFire.SetValue(Settings.AutoFire) end
        UpdateTabDots()
        SendNotification("Hotkey", "Auto Fire: " .. (Settings.AutoFire and "BẬT" or "TẮT"))
    elseif input.KeyCode == Settings.AutoTeleportHotkey and Settings.AutoTeleportHotkey ~= Enum.KeyCode.None then
        if not Settings.AutoTeleport and not CheckAndBypassCharacterAC("Auto Teleport") then
            return
        end
        Settings.AutoTeleport = not Settings.AutoTeleport
        if UI_Elements.AutoTeleport then UI_Elements.AutoTeleport.SetValue(Settings.AutoTeleport) end
        
        if Settings.AutoTeleport and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Shared.originalTeleportCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        elseif not Settings.AutoTeleport and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Shared.originalTeleportCFrame then
            if Settings.AutoTeleportReturn then
                LocalPlayer.Character.HumanoidRootPart.CFrame = Shared.originalTeleportCFrame
            end
            Shared.originalTeleportCFrame = nil
        end
        
        UpdateTabDots()
        SendNotification("Hotkey", "Tele: " .. (Settings.AutoTeleport and "BẬT" or "TẮT"))
    elseif input.KeyCode == Settings.SpeedTeleHotkey and Settings.SpeedTeleHotkey ~= Enum.KeyCode.None then
        if not Settings.SpeedTele and not CheckAndBypassCharacterAC("Speed Tele") then
            return
        end
        Settings.SpeedTele = not Settings.SpeedTele
        if UI_Elements.SpeedTele then UI_Elements.SpeedTele.SetValue(Settings.SpeedTele) end
        
        if Settings.SpeedTele and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Shared.originalSpeedTeleCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        elseif not Settings.SpeedTele and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Shared.originalSpeedTeleCFrame then
            if Settings.AutoTeleportReturn then
                LocalPlayer.Character.HumanoidRootPart.CFrame = Shared.originalSpeedTeleCFrame
            end
            Shared.originalSpeedTeleCFrame = nil
        end
        
        UpdateTabDots()
        SendNotification("Hotkey", "Speed Tele [BETA]: " .. (Settings.SpeedTele and "BẬT" or "TẮT"))
    elseif input.KeyCode == Settings.UndergroundHotkey and Settings.UndergroundHotkey ~= Enum.KeyCode.None then
        Settings.UndergroundNoclip = not Settings.UndergroundNoclip
        if UI_Elements.UndergroundNoclip then UI_Elements.UndergroundNoclip.SetValue(Settings.UndergroundNoclip) end
        
        if Settings.UndergroundNoclip and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Shared.undergroundSurfaceY = LocalPlayer.Character.HumanoidRootPart.Position.Y
        elseif not Settings.UndergroundNoclip and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Shared.undergroundSurfaceY then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            hrp.CFrame = hrp.CFrame + Vector3.new(0, Shared.undergroundSurfaceY - hrp.Position.Y, 0)
            Shared.undergroundSurfaceY = nil
        end
        UpdateTabDots()
        SendNotification("Hotkey", "Chui Đất: " .. (Settings.UndergroundNoclip and "BẬT" or "TẮT"))
    end
end)



    local function ApplyTheme()
        local p = GetActivePreset()
        Theme.MainBg = p.MainBg
        Theme.PanelBg = p.PanelBg
        Theme.AccentOn = p.AccentOn
        Theme.AccentOff = p.AccentOff

        if MainFrame then
            pcall(function() MainFrame.BackgroundColor3 = p.MainBg end)
        end
        if MainStroke then
            pcall(function() MainStroke.Color = p.Stroke end)
        end

        for _, o in pairs(ThemeObjects.Panels) do
            pcall(function()
                o.Bg.BackgroundColor3 = p.Panel
                o.Header.BackgroundColor3 = p.PanelBg
                o.HeaderSquare.BackgroundColor3 = p.PanelBg
                o.Stroke.Color = p.Stroke
            end)
        end
        for _, o in pairs(ThemeObjects.Toggles) do
            pcall(function()
                o.Btn.BackgroundColor3 = o.State and p.AccentOn or p.AccentOff
                o.Knob.BackgroundColor3 = o.State and Theme.KnobOn or Theme.KnobOff
            end)
        end
        for _, o in pairs(ThemeObjects.SliderFills) do
            pcall(function() o.Fill.BackgroundColor3 = p.AccentOn end)
        end
        for _, o in pairs(ThemeObjects.Dropbox) do
            pcall(function() o.Box.BackgroundColor3 = Color3.fromRGB(35, 35, 38) end)
        end
    end

    UI.ScreenGui = ScreenGui
    UI.MainFrame = MainFrame
    UI.StatusText = StatusText
    UI.UpdateWatermarkColor = UpdateWatermarkColor
    UI.GetMenuConnected = function() return isMenuConnected end
    UI.ESPCounterBox = ESPCounterBox
    UI.WatermarkFrame = WatermarkFrame
    UI.NotifyFrame = NotifyFrame
    UI.UpdateTabDots = UpdateTabDots
    UI.ApplyTheme = ApplyTheme

    Shared.SendNotification = SendNotification
    Shared.ApplyTheme = ApplyTheme
    Shared.UI_Elements.ESPCounterBox = ESPCounterBox
    Shared.UI_Elements.ESPCounterLabel = ESPCounterLabel

    return UI
end
