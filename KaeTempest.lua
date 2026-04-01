-- [[ 🌸 KAE TEMPEST | FISH IT V0.1 - FINAL PREMIUM 🌸 ]]
-- Design: Sidebar Left Navigation | Full Header Draggable
-- Theme: Kawaii Pink Neon & Deep Black
-- Fitur: Auto Fishing, Insta Catch, Anti-Staff, Anti-AFK, Real Slider

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

-- // 📂 SETTINGS (Semua Fitur Real) //
_G.Settings = {
    AutoCast = false,
    InstaFish = false,
    FishDelay = 0.1, -- Slider Milidetik
    CastDelay = 1.0,
    AntiStaff = true,
    AntiAFK = true,
    ThemeColor = Color3.fromRGB(255, 20, 147) -- Neon Pink
}

-- // 🔧 UTILITY FUNCTIONS //
local function GetRod()
    return lp.Character and lp.Character:FindFirstChildOfClass("Tool")
end

local function CastRod()
    local rod = GetRod()
    if rod then
        rod:Activate()
        local rem = ReplicatedStorage:FindFirstChild("Cast", true) or ReplicatedStorage:FindFirstChild("Events", true)
        if rem and rem:IsA("RemoteEvent") then rem:FireServer() end
    end
end

local function CatchFish()
    local rem = ReplicatedStorage:FindFirstChild("FishEvents", true) or ReplicatedStorage:FindFirstChild("Events", true)
    if rem and rem:IsA("RemoteEvent") then 
        rem:FireServer("Catch", "Perfect") 
    end
end

-- // 🎨 UI CONSTRUCTION //
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "KaeTempest_V01_Final"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 360)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 0
local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

-- Glowing Border (Premium Look)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = _G.Settings.ThemeColor
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.4

-- // 🎯 HEADER (DRAG AREA) //
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Header.BorderSizePixel = 0
local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 10)

-- Fill corner bawah header
local HeaderFill = Instance.new("Frame", Header)
HeaderFill.Size = UDim2.new(1, 0, 0, 10)
HeaderFill.Position = UDim2.new(0, 0, 1, -10)
HeaderFill.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
HeaderFill.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "🌸 KAE TEMPEST | FISH IT V0.1"
Title.TextColor3 = _G.Settings.ThemeColor
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- Header Dragging Logic
local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- // 📂 SIDEBAR (LEFT NAVIGATION) //
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Sidebar.BorderSizePixel = 0

local SidebarLine = Instance.new("Frame", Sidebar)
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(1, 0, 0, 0)
SidebarLine.BackgroundColor3 = _G.Settings.ThemeColor
SidebarLine.BackgroundTransparency = 0.8
SidebarLine.BorderSizePixel = 0

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local SidebarPad = Instance.new("UIPadding", Sidebar)
SidebarPad.PaddingTop = UDim.new(0, 15)

-- // 🍱 CONTENT CONTAINER //
local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -155, 1, -55)
ContentArea.Position = UDim2.new(0, 150, 0, 50)
ContentArea.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name, icon)
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(0, 120, 0, 32)
    TabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    TabBtn.Text = icon .. "  " .. name
    TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 11
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame", ContentArea)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 10)
    
    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y)
    end)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Tabs) do p.Visible = false end
        for _, b in pairs(Sidebar:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(22, 22, 22) end end
        Page.Visible = true
        TabBtn.BackgroundColor3 = _G.Settings.ThemeColor
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    table.insert(Tabs, Page)
    return Page
end

-- // 🛠️ PREMIUM ELEMENT BUILDERS //
local function CreateToggle(parent, text, var)
    local Row = Instance.new("Frame", parent)
    Row.Size = UDim2.new(1, 0, 0, 40)
    Row.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Row)
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Switch = Instance.new("TextButton", Row)
    Switch.Size = UDim2.new(0, 36, 0, 18)
    Switch.Position = UDim2.new(1, -48, 0.5, -9)
    Switch.BackgroundColor3 = _G.Settings[var] and _G.Settings.ThemeColor or Color3.fromRGB(60, 60, 60)
    Switch.Text = ""
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

    Switch.MouseButton1Click:Connect(function()
        _G.Settings[var] = not _G.Settings[var]
        TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = _G.Settings[var] and _G.Settings.ThemeColor or Color3.fromRGB(60, 60, 60)}):Play()
    end)
end

local function CreateSlider(parent, text, var, min, max)
    local Row = Instance.new("Frame", parent)
    Row.Size = UDim2.new(1, 0, 0, 65)
    Row.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Row)
    Label.Size = UDim2.new(1, 0, 0, 30)
    Label.Position = UDim2.new(0, 12, 0, 5)
    Label.Text = text .. " : " .. tostring(_G.Settings[var]) .. "s"
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local SliderBar = Instance.new("Frame", Row)
    SliderBar.Size = UDim2.new(1, -30, 0, 6)
    SliderBar.Position = UDim2.new(0, 15, 0, 45)
    SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame", SliderBar)
    Fill.Size = UDim2.new((_G.Settings[var] - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = _G.Settings.ThemeColor
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local moveConn
            moveConn = UserInputService.InputChanged:Connect(function(move)
                if move.UserInputType == Enum.UserInputType.MouseMovement or move.UserInputType == Enum.UserInputType.Touch then
                    local percent = math.clamp((move.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    local val = math.floor((min + (max - min) * percent) * 10) / 10
                    _G.Settings[var] = val
                    Label.Text = text .. " : " .. tostring(val) .. "s"
                    Fill.Size = UDim2.new(percent, 0, 1, 0)
                end
            end)
            UserInputService.InputEnded:Connect(function(up)
                if up.UserInputType == Enum.UserInputType.MouseButton1 then moveConn:Disconnect() end
            end)
        end
    end)
end

-- // 🚀 POPULATE TABS //
local FarmTab = CreateTab("Fishing", "🎣")
local SafeTab = CreateTab("Security", "🛡️")
local MiscTab = CreateTab("Misc", "⚙️")

-- Fishing Tab
CreateToggle(FarmTab, "Auto Cast Rod", "AutoCast")
CreateToggle(FarmTab, "Instant Catch (Perfect)", "InstaFish")
CreateSlider(FarmTab, "Catch Delay", "FishDelay", 0.1, 5.0)
CreateSlider(FarmTab, "Cast Delay", "CastDelay", 0.5, 3.0)

-- Security Tab
CreateToggle(SafeTab, "Anti-Staff Mode", "AntiStaff")
CreateToggle(SafeTab, "Anti-AFK System", "AntiAFK")

-- // 🔄 FISHING ENGINE (LOOPS) //
task.spawn(function()
    while task.wait() do
        -- Auto Cast Logic
        if _G.Settings.AutoCast then
            local rod = GetRod()
            if rod and not rod:FindFirstChild("FishingLine") then
                task.wait(_G.Settings.CastDelay)
                CastRod()
            end
        end
        -- Insta Fish Logic
        if _G.Settings.InstaFish then
            local rod = GetRod()
            if rod and rod:FindFirstChild("FishingLine") then
                task.wait(_G.Settings.FishDelay)
                CatchFish()
            end
        end
    end
end)

-- Anti AFK
if _G.Settings.AntiAFK then
    lp.Idled:Connect(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end)
end

-- Staff Detect (Basic)
task.spawn(function()
    while task.wait(5) do
        if _G.Settings.AntiStaff then
            for _, player in pairs(Players:GetPlayers()) do
                if player:GetRankInGroup(0) > 100 then -- Ganti 0 dengan Group ID game tersebut
                    lp:Kick("Staff Detected: " .. player.Name)
                end
            end
        end
    end
end)

-- Default Active Tab
Tabs[1].Visible = true
Sidebar:FindFirstChildOfClass("TextButton").BackgroundColor3 = _G.Settings.ThemeColor
Sidebar:FindFirstChildOfClass("TextButton").TextColor3 = Color3.fromRGB(255, 255, 255)

print("🌸 KAE TEMPEST | FISH IT V0.1 LOADED SUCCESSFULLY")
