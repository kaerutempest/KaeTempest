-- [[ 🌸 KAE TEMPEST HUB | FISH IT V0.1 ]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

-- // 📂 SETTINGS & LOGIC //
_G.Settings = {
    AutoCast = false,
    InstaFish = false,
    AntiStaff = true,
    AntiAFK = true,
    ThemeColor = Color3.fromRGB(255, 10, 140), -- Solid Neon Pink
    BgColor = Color3.fromRGB(10, 10, 10),
    HeaderColor = Color3.fromRGB(15, 15, 15)
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
ScreenGui.Name = "KaeTempestHub_Official"
ScreenGui.ResetOnSpawn = false

-- Floating Logo (Minimize Button)
local FloatingIcon = Instance.new("TextButton", ScreenGui)
FloatingIcon.Size = UDim2.new(0, 55, 0, 55)
FloatingIcon.Position = UDim2.new(0, 20, 0.5, -25)
FloatingIcon.BackgroundColor3 = _G.Settings.BgColor
FloatingIcon.Text = "🌸"
FloatingIcon.TextSize = 28
FloatingIcon.Visible = false
FloatingIcon.ZIndex = 15
local IconCorner = Instance.new("UICorner", FloatingIcon)
IconCorner.CornerRadius = UDim.new(1, 0)
local IconStroke = Instance.new("UIStroke", FloatingIcon)
IconStroke.Color = _G.Settings.ThemeColor
IconStroke.Thickness = 2.5

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 560, 0, 340)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -170)
MainFrame.BackgroundColor3 = _G.Settings.BgColor
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = _G.Settings.ThemeColor
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.4

-- // 🎯 HEADER (DRAGGABLE) //
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 38)
Header.BackgroundColor3 = _G.Settings.HeaderColor
Header.BorderSizePixel = 0
local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "🌸 KAE TEMPEST HUB | FISH IT V0.1"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 38, 1, 0)
CloseBtn.Position = UDim2.new(1, -38, 0, 0)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold

local MiniBtn = Instance.new("TextButton", Header)
MiniBtn.Size = UDim2.new(0, 38, 1, 0)
MiniBtn.Position = UDim2.new(1, -76, 0, 0)
MiniBtn.Text = "—"
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.BackgroundTransparency = 1
MiniBtn.Font = Enum.Font.GothamBold

-- // 📂 SIDEBAR & ACTIVE INDICATOR //
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 150, 1, -38)
Sidebar.Position = UDim2.new(0, 0, 0, 38)
Sidebar.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
Sidebar.BorderSizePixel = 0

local SidebarLine = Instance.new("Frame", Sidebar)
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(1, 0, 0, 0)
SidebarLine.BackgroundColor3 = _G.Settings.ThemeColor
SidebarLine.Transparency = 0.7

-- Active Line Indicator (Meluncur Smooth)
local ActiveLine = Instance.new("Frame", Sidebar)
ActiveLine.Size = UDim2.new(0, 3, 0, 28)
ActiveLine.Position = UDim2.new(0, 0, 0, 20)
ActiveLine.BackgroundColor3 = _G.Settings.ThemeColor
ActiveLine.BorderSizePixel = 0
ActiveLine.ZIndex = 10

local TabContainer = Instance.new("Frame", Sidebar)
TabContainer.Size = UDim2.new(1, 0, 1, -40)
TabContainer.Position = UDim2.new(0, 0, 0, 20)
TabContainer.BackgroundTransparency = 1
local TabLayout = Instance.new("UIListLayout", TabContainer)
TabLayout.Padding = UDim.new(0, 8)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- // 🍱 CONTENT AREA //
local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Size = UDim2.new(1, -170, 1, -55)
PageContainer.Position = UDim2.new(0, 165, 0, 50)
PageContainer.BackgroundTransparency = 1

local Pages = {}
local function CreateTab(name, icon)
    local TabBtn = Instance.new("TextButton", TabContainer)
    TabBtn.Size = UDim2.new(0, 130, 0, 35)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = icon .. "  " .. name
    TabBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 12
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    local Pad = Instance.new("UIPadding", TabBtn); Pad.PaddingLeft = UDim.new(0, 15)

    local Page = Instance.new("ScrollingFrame", PageContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 0
    Page.CanvasSize = UDim2.new(0,0,0,0)
    local PageLayout = Instance.new("UIListLayout", Page); PageLayout.Padding = UDim.new(0, 10)
    
    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0,0,0, PageLayout.AbsoluteContentSize.Y)
    end)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(TabContainer:GetChildren()) do if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(140, 140, 140) end end
        
        Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TweenService:Create(ActiveLine, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, TabBtn.Position.Y)}):Play()
    end)

    table.insert(Pages, Page)
    return Page
end

-- // 🛠️ ROW BUILDER (Mirroring Photo Style) //
local function AddSection(parent, name)
    local Label = Instance.new("TextLabel", parent)
    Label.Size = UDim2.new(1, 0, 0, 30)
    Label.Text = "[ " .. name:upper() .. " ]"
    Label.TextColor3 = Color3.fromRGB(110, 110, 110)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
end

local function AddFeature(parent, text, callback)
    local Row = Instance.new("TextButton", parent)
    Row.Size = UDim2.new(1, -12, 0, 45)
    Row.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    Row.AutoButtonColor = false
    Row.Text = ""
    local RowCorner = Instance.new("UICorner", Row); RowCorner.CornerRadius = UDim.new(0, 8)
    
    local Label = Instance.new("TextLabel", Row)
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 18, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Arrow = Instance.new("TextLabel", Row)
    Arrow.Size = UDim2.new(0, 40, 1, 0)
    Arrow.Position = UDim2.new(1, -45, 0, 0)
    Arrow.Text = ">"
    Arrow.TextColor3 = Color3.fromRGB(90, 90, 90)
    Arrow.Font = Enum.Font.GothamBold
    Arrow.TextSize = 15
    Arrow.BackgroundTransparency = 1

    local toggled = false
    Row.MouseButton1Click:Connect(function()
        toggled = not toggled
        Arrow.TextColor3 = toggled and _G.Settings.ThemeColor or Color3.fromRGB(90, 90, 90)
        Arrow.Rotation = toggled and 90 or 0
        Row.BackgroundColor3 = toggled and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(22, 22, 22)
        callback(toggled)
    end)
end

-- // 🚀 PAGE SETUP //
local MainTab = CreateTab("Main", "🏠")
local OtoTab = CreateTab("Otomatis", "⚙️")
local SafeTab = CreateTab("Security", "🛡️")
local ShopTab = CreateTab("Shop", "🛒")

-- Main Tab
AddSection(MainTab, "Fishing Engine")
AddFeature(MainTab, "Instant Fishing (Perfect)", function(v) _G.Settings.InstaFish = v end)
AddFeature(MainTab, "Legit Fishing Mode", function(v) print("Legit Mode active") end)

-- Otomatis Tab
AddSection(OtoTab, "Automated Tasks")
AddFeature(OtoTab, "Auto Cast Rod", function(v) _G.Settings.AutoCast = v end)

-- Security Tab
AddSection(SafeTab, "Protection System")
AddFeature(SafeTab, "Anti-Staff Mode", function(v) _G.Settings.AntiStaff = v end)
AddFeature(SafeTab, "Anti-AFK System", function(v) _G.Settings.AntiAFK = v end)

-- Shop Tab
AddSection(ShopTab, "Luckycat Store")
AddFeature(ShopTab, "Copy Link Toko", function() setclipboard("https://luckycat.store") end)

-- // 🔄 ENGINE LOGIC //
task.spawn(function()
    while task.wait(0.1) do
        if _G.Settings.AutoCast then
            local rod = GetRod()
            if rod and not rod:FindFirstChild("FishingLine") then
                task.wait(0.5); CastRod()
            end
        end
        if _G.Settings.InstaFish then
            local rod = GetRod()
            if rod and rod:FindFirstChild("FishingLine") then
                task.wait(0.1); CatchFish()
            end
        end
    end
end)

-- Anti AFK Connection
lp.Idled:Connect(function()
    if _G.Settings.AntiAFK then
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end
end)

-- // 🖱️ INTERACTION (DRAG & BUTTONS) //
local function MakeDraggable(frame, handle)
    local drag, dinput, dstart, spos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true; dstart = input.Position; spos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dstart
            frame.Position = UDim2.new(spos.X.Scale, spos.X.Offset + delta.X, spos.Y.Scale, spos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

MakeDraggable(MainFrame, Header)
MakeDraggable(FloatingIcon, FloatingIcon)

MiniBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatingIcon.Visible = true
end)

FloatingIcon.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    FloatingIcon.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Initialization
Pages[1].Visible = true
TabContainer:FindFirstChildOfClass("TextButton").TextColor3 = Color3.fromRGB(255, 255, 255)
print("🌸 KAE TEMPEST HUB V0.1 LOADED")
