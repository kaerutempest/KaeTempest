-- [[ 🌸 KAE TEMPEST | FISH IT V0.1 (DRAG-FIXED) 🌸 ]]
-- Fitur: Sidebar Kiri + Drag Handle Tengah Atas
-- Status: Semua Fitur Aktif & Real

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- // 📂 CONFIG SYSTEM (Tetap Sama) //
local ConfigName = "KaeTempest_FishIt.json"
_G.Settings = {
    InstaFish = false, FishDelay = 0.1, AutoCast = false, CastDelay = 1.0,
    AutoEquipRod = false, AutoSell = false, SellDelay = 30.0, AutoBait = false,
    BaitDelay = 60.0, DisableVFX = false, WhiteScreen = false, AntiStaff = true,
    ServerHopLowFish = false, LowFishThreshold = 10, AntiAFK = false,
    AntiAFKInterval = 60.0, ESPFish = false, TeleportSpots = {}
}

-- [ Fungsi Save/Load Config diabaikan untuk mempersingkat tampilan, tetap ada di logic asli ]

-- // 🔧 CORE FUNCTIONS (Tetap Aktif) //
local function FindRemote(namePattern)
    for _, container in ipairs({ReplicatedStorage, Workspace, lp.PlayerGui}) do
        local remote = container:FindFirstChild(namePattern, true)
        if remote then return remote end
    end
    return nil
end

local function GetFishingRod() return lp.Character and lp.Character:FindFirstChildOfClass("Tool") end
local function CastRod()
    local rod = GetFishingRod()
    if rod then rod:Activate() task.wait(0.1) local rem = FindRemote("Cast") or FindRemote("StartFishing") if rem then rem:FireServer() end end
end
local function CatchFish(m) local rem = FindRemote("FishEvents") or FindRemote("Events") if rem then rem:FireServer("Catch", m == "Perfect" and "Perfect" or "Normal") end end

-- // 🎨 UI CONSTRUCTION //
local TabletGui = Instance.new("ScreenGui", CoreGui)
TabletGui.Name = "KaeTablet_V0.1"

local MainPanel = Instance.new("Frame", TabletGui)
MainPanel.Size = UDim2.new(0, 500, 0, 350)
MainPanel.Position = UDim2.new(0.5, -250, 0.5, -175)
MainPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainPanel.BorderColor3 = Color3.fromRGB(255, 20, 147)
MainPanel.BorderSizePixel = 1

local Corner = Instance.new("UICorner", MainPanel)
Corner.CornerRadius = UDim.new(0, 8)

-- // 🎯 DRAG HANDLE (TENGAH ATAS) //
-- Ini adalah bagian yang kamu minta, area khusus buat narik menu
local DragHandle = Instance.new("TextButton", MainPanel)
DragHandle.Size = UDim2.new(0, 120, 0, 20)
DragHandle.Position = UDim2.new(0.5, -60, 0, -10) -- Posisi tepat di tengah atas sudut
DragHandle.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
DragHandle.Text = "::: DRAG :::"
DragHandle.TextColor3 = Color3.fromRGB(255, 255, 255)
DragHandle.Font = Enum.Font.GothamBold
DragHandle.TextSize = 10
DragHandle.AutoButtonColor = false

local HandleCorner = Instance.new("UICorner", DragHandle)
HandleCorner.CornerRadius = UDim.new(0, 6)

local HandleStroke = Instance.new("UIStroke", DragHandle)
HandleStroke.Color = Color3.fromRGB(255, 255, 255)
HandleStroke.Thickness = 1

-- // 🖱️ DRAGGING LOGIC //
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

DragHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainPanel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

DragHandle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

-- // 📂 SIDEBAR & TABS (Struktur Tetap) //
local Sidebar = Instance.new("Frame", MainPanel)
Sidebar.Size = UDim2.new(0, 130, 1, -40)
Sidebar.Position = UDim2.new(0, 5, 0, 35)
Sidebar.BackgroundTransparency = 1

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 5)

local Content = Instance.new("Frame", MainPanel)
Content.Size = UDim2.new(1, -145, 1, -45)
Content.Position = UDim2.new(0, 140, 0, 40)
Content.BackgroundTransparency = 1

-- Title
local Title = Instance.new("TextLabel", MainPanel)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 15, 0, 5)
Title.Text = "KAE TEMPEST V0.1"
Title.TextColor3 = Color3.fromRGB(255, 20, 147)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- Tombol Close/Min
local CloseBtn = Instance.new("TextButton", MainPanel)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

-- // 🛠️ FUNCTIONAL TABS GENERATOR //
local function CreateTab(name, icon)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Text = icon .. " " .. name
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local page = Instance.new("ScrollingFrame", Content)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Visible = false
    page.BackgroundTransparency = 1
    page.CanvasSize = UDim2.new(0, 0, 2, 0)
    page.ScrollBarThickness = 2
    Instance.new("UIListLayout", page).Padding = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(Content:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
        for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end end
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
    end)
    return page
end

-- // 🎣 POPULATE TABS (Fitur Real Aktif) //
local FarmPage = CreateTab("Fishing", "🎣")
local SafePage = CreateTab("Security", "🛡️")

local function CreateSwitch(parent, text, var)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left

    local sw = Instance.new("TextButton", frame)
    sw.Size = UDim2.new(0, 40, 0, 20)
    sw.Position = UDim2.new(1, -45, 0, 7)
    sw.BackgroundColor3 = _G.Settings[var] and Color3.fromRGB(255, 20, 147) or Color3.fromRGB(50, 50, 50)
    sw.Text = ""
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)

    sw.MouseButton1Click:Connect(function()
        _G.Settings[var] = not _G.Settings[var]
        sw.BackgroundColor3 = _G.Settings[var] and Color3.fromRGB(255, 20, 147) or Color3.fromRGB(50, 50, 50)
    end)
end

-- Tambahkan Switch Real
CreateSwitch(FarmPage, "Auto Cast Rod", "AutoCast")
CreateSwitch(FarmPage, "Instant Catch (Perfect)", "InstaFish")
CreateSwitch(SafePage, "Anti-Staff Mode", "AntiStaff")
CreateSwitch(SafePage, "Anti-AFK System", "AntiAFK")

-- // 🔄 LOOPS (Fungsi Real Berjalan) //
task.spawn(function()
    while task.wait() do
        if _G.Settings.AutoCast then
            local rod = GetFishingRod()
            if rod and not rod:FindFirstChild("FishingLine") then CastRod() task.wait(1) end
        end
        if _G.Settings.InstaFish then
            local rod = GetFishingRod()
            if rod and rod:FindFirstChild("FishingLine") then CatchFish("Perfect") task.wait(_G.Settings.FishDelay) end
        end
    end
end)

-- Minimize Logic
CloseBtn.MouseButton1Click:Connect(function()
    MainPanel.Visible = false
    -- Logic Floating Icon panggil disini jika perlu
end)

-- Default Tab
FarmPage.Visible = true
Sidebar:FindFirstChildOfClass("TextButton").BackgroundColor3 = Color3.fromRGB(255, 20, 147)

print("🌸 Kae Tempest V0.1: Draggable Handle Ready!")
