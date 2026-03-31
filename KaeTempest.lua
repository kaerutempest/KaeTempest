-- [[ 🌸 KAE TEMPEST | FISH IT V0.2 (MODERN SWITCH) 🌸 ]]
-- Floating Icon with "KAE" Logo | Tablet UI with Toggle Switches
-- Theme: Deep Black & Neon Pink | All Features + Disable VFX, Auto Equip Rod

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

-- // 📂 CONFIG SYSTEM //
local ConfigName = "KaeTempest_FishIt.json"
_G.Settings = {
    -- Farming
    InstaFish = false,
    FishDelay = 0.1,
    AutoCast = false,
    CastDelay = 1.0,
    AutoEquipRod = false,
    -- Auto Sell
    AutoSell = false,
    SellDelay = 30.0,
    -- Auto Bait
    AutoBait = false,
    BaitDelay = 60.0,
    -- Performance
    DisableVFX = false,
    WhiteScreen = false,
    -- Security
    AntiStaff = true,
    ServerHopLowFish = false,
    LowFishThreshold = 10,
    -- Misc
    AntiAFK = false,
    AntiAFKInterval = 60.0,
    ESPFish = false,
    TeleportSpots = {}
}

local function SaveConfig()
    local saveData = {}
    for k, v in pairs(_G.Settings) do
        if k == "TeleportSpots" then
            saveData[k] = {}
            for name, cframe in pairs(v) do
                saveData[k][name] = tostring(cframe)
            end
        else
            saveData[k] = v
        end
    end
    writefile(ConfigName, HttpService:JSONEncode(saveData))
end

if isfile(ConfigName) then
    local success, data = pcall(function() return HttpService:JSONDecode(readfile(ConfigName)) end)
    if success then
        for k, v in pairs(data) do
            if k == "TeleportSpots" then
                _G.Settings[k] = {}
                for name, cframeStr in pairs(v) do
                    local x, y, z = cframeStr:match("(%d+%.?%d*), (%d+%.?%d*), (%d+%.?%d*)")
                    if x and y and z then
                        _G.Settings[k][name] = CFrame.new(tonumber(x), tonumber(y), tonumber(z))
                    end
                end
            else
                _G.Settings[k] = v
            end
        end
    end
end

-- // 🔧 UTILITY FUNCTIONS //
local function FindRemote(namePattern)
    for _, container in ipairs({ReplicatedStorage, Workspace, lp.PlayerGui}) do
        local remote = container:FindFirstChild(namePattern, true)
        if remote then return remote end
    end
    return nil
end

local function GetFishingRod()
    return lp.Character and lp.Character:FindFirstChildOfClass("Tool")
end

local function EquipBestRod()
    local bestRod = nil
    for _, tool in pairs(lp.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():match("rod") then
            if not bestRod or tool.Name > bestRod.Name then -- sederhana: ambil berdasarkan nama
                bestRod = tool
            end
        end
    end
    if bestRod then
        lp.Character.Humanoid:EquipTool(bestRod)
    end
end

local function CastRod()
    local rod = GetFishingRod()
    if rod then
        rod:Activate()
        task.wait(0.1)
        local castRemote = FindRemote("Cast") or FindRemote("StartFishing")
        if castRemote then castRemote:FireServer() end
    end
end

local function CatchFish(method)
    local rem = FindRemote("FishEvents") or FindRemote("Events")
    if rem then
        rem:FireServer("Catch", method == "Perfect" and "Perfect" or "Normal")
    end
end

local function SellFish()
    local sellRemote = FindRemote("SellFish") or FindRemote("SellAll")
    if sellRemote then
        sellRemote:FireServer()
    else
        local sellBtn = lp.PlayerGui:FindFirstChild("SellButton", true)
        if sellBtn and sellBtn:IsA("TextButton") then sellBtn:Click() end
    end
end

local function UseBait()
    local baitTool = lp.Backpack:FindFirstChild("Bait") or lp.Character:FindFirstChild("Bait")
    if baitTool then
        baitTool:Activate()
        task.wait(0.5)
        local baitRemote = FindRemote("EquipBait")
        if baitRemote then baitRemote:FireServer() end
    end
end

local function AntiAFKAction()
    local mouse = lp:GetMouse()
    local originalPos = mouse.X
    TweenService:Create(mouse, TweenInfo.new(0.1), {X = originalPos + 1}):Play()
    task.wait(0.2)
    TweenService:Create(mouse, TweenInfo.new(0.1), {X = originalPos}):Play()
end

local function TeleportToPosition(position)
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.CFrame = position
    end
end

local function GetPlayerFishCount()
    local leaderstats = lp:FindFirstChild("leaderstats")
    if leaderstats then
        local fishStat = leaderstats:FindFirstChild("Fish") or leaderstats:FindFirstChild("Fishes")
        if fishStat then return fishStat.Value end
    end
    local count = 0
    for _, item in pairs(lp.Backpack:GetChildren()) do
        if item:IsA("Tool") and item.Name:match("Fish") then count = count + 1 end
    end
    return count
end

local function CheckStaff()
    -- Ganti ID group sesuai game yang dimainkan
    for _, player in pairs(Players:GetPlayers()) do
        if player:IsInGroup(123456) or player:GetRankInGroup(123456) >= 100 then
            return true
        end
    end
    return false
end

local function DisableGameVFX()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") then
            v.Enabled = false
        end
        if v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        end
    end
    Lighting.Brightness = 1
    Lighting.ClockTime = 12
    Lighting.FogEnd = 1000
    Lighting.GlobalShadows = false
end

-- // 🎣 FISHING LOOPS (Thread Management) //
local activeThreads = {}

local function startLoop(name, func, enabledVar)
    if activeThreads[name] then coroutine.close(activeThreads[name]) end
    if _G.Settings[enabledVar] then
        activeThreads[name] = coroutine.create(func)
        coroutine.resume(activeThreads[name])
    end
end

local function stopLoop(name)
    if activeThreads[name] then
        coroutine.close(activeThreads[name])
        activeThreads[name] = nil
    end
end

-- Loop functions
local function InstantFishLoop()
    while _G.Settings.InstaFish do
        task.wait(_G.Settings.FishDelay)
        local rod = GetFishingRod()
        if rod and rod:FindFirstChild("FishingLine") then
            CatchFish("Perfect")
        end
    end
end

local function AutoCastLoop()
    while _G.Settings.AutoCast do
        task.wait(_G.Settings.CastDelay)
        local rod = GetFishingRod()
        if rod and not rod:FindFirstChild("FishingLine") then
            CastRod()
        end
    end
end

local function AutoEquipRodLoop()
    while _G.Settings.AutoEquipRod do
        task.wait(5)
        if not GetFishingRod() then
            EquipBestRod()
        end
    end
end

local function AutoSellLoop()
    while _G.Settings.AutoSell do
        task.wait(_G.Settings.SellDelay)
        SellFish()
    end
end

local function AutoBaitLoop()
    while _G.Settings.AutoBait do
        task.wait(_G.Settings.BaitDelay)
        UseBait()
    end
end

local function AntiAFKLoop()
    while _G.Settings.AntiAFK do
        task.wait(_G.Settings.AntiAFKInterval)
        AntiAFKAction()
    end
end

local function StaffCheckLoop()
    while _G.Settings.AntiStaff do
        if CheckStaff() then
            showNotification("⚠️ Staff detected! Hopping server...")
            task.wait(1)
            TeleportService:Teleport(game.PlaceId, lp)
            break
        end
        task.wait(10)
    end
end

local function LowFishCheckLoop()
    while _G.Settings.ServerHopLowFish do
        if GetPlayerFishCount() <= _G.Settings.LowFishThreshold then
            showNotification("🐟 Low fish count! Hopping server...")
            task.wait(1)
            TeleportService:Teleport(game.PlaceId, lp)
            break
        end
        task.wait(30)
    end
end

local function ESPLoop()
    while _G.Settings.ESPFish do
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:lower():match("fish") and obj:IsA("Model") then
                local highlight = obj:FindFirstChild("FishESP")
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "FishESP"
                    highlight.FillColor = Color3.fromRGB(255, 20, 147)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Parent = obj
                end
            end
        end
        task.wait(0.5)
    end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "FishESP" then obj:Destroy() end
    end
end

local function VFXLoop()
    while _G.Settings.DisableVFX do
        DisableGameVFX()
        task.wait(10)
    end
end

local function updateLoops()
    startLoop("InstaFish", InstantFishLoop, "InstaFish")
    startLoop("AutoCast", AutoCastLoop, "AutoCast")
    startLoop("AutoEquipRod", AutoEquipRodLoop, "AutoEquipRod")
    startLoop("AutoSell", AutoSellLoop, "AutoSell")
    startLoop("AutoBait", AutoBaitLoop, "AutoBait")
    startLoop("AntiAFK", AntiAFKLoop, "AntiAFK")
    startLoop("StaffCheck", StaffCheckLoop, "AntiStaff")
    startLoop("LowFishCheck", LowFishCheckLoop, "ServerHopLowFish")
    startLoop("ESP", ESPLoop, "ESPFish")
    startLoop("VFX", VFXLoop, "DisableVFX")
end

-- // 🖥️ WHITE SCREEN //
local WhiteScreenGui = Instance.new("ScreenGui", CoreGui)
local WhiteFrame = Instance.new("Frame", WhiteScreenGui)
WhiteFrame.Size = UDim2.new(1, 0, 1, 0)
WhiteFrame.BackgroundColor3 = Color3.new(1, 1, 1)
WhiteFrame.Visible = false

_G.Settings.WhiteScreen = _G.Settings.WhiteScreen or false
WhiteFrame.Visible = _G.Settings.WhiteScreen
RunService:Set3dRenderingEnabled(not _G.Settings.WhiteScreen)

-- // 🎨 UI CONSTRUCTION (Tablet Style) //
local TabletGui = Instance.new("ScreenGui", CoreGui)
TabletGui.Name = "KaeTablet"

local MainPanel = Instance.new("Frame", TabletGui)
MainPanel.Size = UDim2.new(0, 420, 0, 580)
MainPanel.Position = UDim2.new(0.5, -210, 0.5, -290)
MainPanel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainPanel.BorderColor3 = Color3.fromRGB(255, 20, 147)
MainPanel.BorderSizePixel = 2
MainPanel.ClipsDescendants = true
MainPanel.Visible = false

local Corner = Instance.new("UICorner", MainPanel)
Corner.CornerRadius = UDim.new(0, 12)

-- Title Bar
local TitleBar = Instance.new("Frame", MainPanel)
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TitleBar.BorderSizePixel = 0

local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 12)

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(1, -100, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🌸 KAE TEMPEST | V0.2 🌸"
TitleText.TextColor3 = Color3.fromRGB(255, 20, 147)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 16

local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinBtn.Text = "–"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 20
local MinCorner = Instance.new("UICorner", MinBtn)
MinCorner.CornerRadius = UDim.new(0, 8)

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
local CloseCorner = Instance.new("UICorner", CloseBtn)
CloseCorner.CornerRadius = UDim.new(0, 8)

-- Dragging
local dragging = false
local dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainPanel.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        MainPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Scrollable Content
local ScrollingFrame = Instance.new("ScrollingFrame", MainPanel)
ScrollingFrame.Size = UDim2.new(1, 0, 1, -40)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 40)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local UIPadding = Instance.new("UIPadding", ScrollingFrame)
UIPadding.PaddingTop = UDim.new(0, 10)
UIPadding.PaddingBottom = UDim.new(0, 10)
UIPadding.PaddingLeft = UDim.new(0, 10)
UIPadding.PaddingRight = UDim.new(0, 10)

local UIListLayout = Instance.new("UIListLayout", ScrollingFrame)
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Helper: Create Separator Line
local function createSeparator()
    local sep = Instance.new("Frame", ScrollingFrame)
    sep.Size = UDim2.new(1, 0, 0, 1)
    sep.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
    sep.BackgroundTransparency = 0.5
    sep.BorderSizePixel = 0
    return sep
end

-- Helper: Create Section Header
local function createSection(title)
    local header = Instance.new("TextLabel", ScrollingFrame)
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    header.Text = title
    header.TextColor3 = Color3.fromRGB(255, 20, 147)
    header.Font = Enum.Font.GothamBold
    header.TextSize = 14
    header.TextXAlignment = Enum.TextXAlignment.Left
    local headerCorner = Instance.new("UICorner", header)
    headerCorner.CornerRadius = UDim.new(0, 6)
    return header
end

-- Helper: Create Modern Toggle Switch (Slider)
local function createSwitchRow(labelText, settingKey, onToggle)
    local row = Instance.new("Frame", ScrollingFrame)
    row.Size = UDim2.new(1, 0, 0, 45)
    row.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    row.BorderSizePixel = 0
    local rowCorner = Instance.new("UICorner", row)
    rowCorner.CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14

    -- Switch container
    local switchFrame = Instance.new("Frame", row)
    switchFrame.Size = UDim2.new(0, 60, 0, 30)
    switchFrame.Position = UDim2.new(1, -70, 0, 7.5)
    switchFrame.BackgroundColor3 = _G.Settings[settingKey] and Color3.fromRGB(255, 20, 147) or Color3.fromRGB(80, 80, 80)
    switchFrame.BorderSizePixel = 0
    local switchCorner = Instance.new("UICorner", switchFrame)
    switchCorner.CornerRadius = UDim.new(1, 0) -- bulat penuh

    local thumb = Instance.new("Frame", switchFrame)
    thumb.Size = UDim2.new(0, 24, 0, 24)
    thumb.Position = _G.Settings[settingKey] and UDim2.new(1, -28, 0, 3) or UDim2.new(0, 4, 0, 3)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    local thumbCorner = Instance.new("UICorner", thumb)
    thumbCorner.CornerRadius = UDim.new(1, 0)

    local function setState(state)
        _G.Settings[settingKey] = state
        switchFrame.BackgroundColor3 = state and Color3.fromRGB(255, 20, 147) or Color3.fromRGB(80, 80, 80)
        local targetPos = state and UDim2.new(1, -28, 0, 3) or UDim2.new(0, 4, 0, 3)
        TweenService:Create(thumb, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Position = targetPos}):Play()
        SaveConfig()
        if onToggle then onToggle(state) end
        updateLoops()
        if settingKey == "WhiteScreen" then
            WhiteFrame.Visible = state
            RunService:Set3dRenderingEnabled(not state)
        end
    end

    switchFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            setState(not _G.Settings[settingKey])
        end
    end)
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            setState(not _G.Settings[settingKey])
        end
    end)

    return row
end

-- Helper: Create Slider Row (sama seperti sebelumnya)
local function createSliderRow(labelText, settingKey, minVal, maxVal, increment, suffix)
    local row = Instance.new("Frame", ScrollingFrame)
    row.Size = UDim2.new(1, 0, 0, 70)
    row.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    row.BorderSizePixel = 0
    local rowCorner = Instance.new("UICorner", row)
    rowCorner.CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14

    local valueBox = Instance.new("TextBox", row)
    valueBox.Size = UDim2.new(0, 80, 0, 30)
    valueBox.Position = UDim2.new(1, -170, 0, 30)
    valueBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    valueBox.Text = tostring(_G.Settings[settingKey])
    valueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueBox.Font = Enum.Font.Gotham
    valueBox.TextSize = 14
    local valueCorner = Instance.new("UICorner", valueBox)
    valueCorner.CornerRadius = UDim.new(0, 4)

    local minus = Instance.new("TextButton", row)
    minus.Size = UDim2.new(0, 30, 0, 30)
    minus.Position = UDim2.new(1, -90, 0, 30)
    minus.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    minus.Text = "-"
    minus.TextColor3 = Color3.fromRGB(255, 255, 255)
    minus.Font = Enum.Font.GothamBold
    minus.TextSize = 20
    local minusCorner = Instance.new("UICorner", minus)
    minusCorner.CornerRadius = UDim.new(0, 4)

    local plus = Instance.new("TextButton", row)
    plus.Size = UDim2.new(0, 30, 0, 30)
    plus.Position = UDim2.new(1, -50, 0, 30)
    plus.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    plus.Text = "+"
    plus.TextColor3 = Color3.fromRGB(255, 255, 255)
    plus.Font = Enum.Font.GothamBold
    plus.TextSize = 20
    local plusCorner = Instance.new("UICorner", plus)
    plusCorner.CornerRadius = UDim.new(0, 4)

    local suffixLabel = Instance.new("TextLabel", row)
    suffixLabel.Size = UDim2.new(0, 40, 0, 30)
    suffixLabel.Position = UDim2.new(1, -20, 0, 30)
    suffixLabel.BackgroundTransparency = 1
    suffixLabel.Text = suffix
    suffixLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    suffixLabel.TextXAlignment = Enum.TextXAlignment.Left
    suffixLabel.Font = Enum.Font.Gotham
    suffixLabel.TextSize = 14

    local function updateValue(newVal)
        newVal = math.clamp(newVal, minVal, maxVal)
        _G.Settings[settingKey] = newVal
        valueBox.Text = tostring(newVal)
        SaveConfig()
        updateLoops()
    end

    minus.MouseButton1Click:Connect(function()
        updateValue(_G.Settings[settingKey] - increment)
    end)
    plus.MouseButton1Click:Connect(function()
        updateValue(_G.Settings[settingKey] + increment)
    end)
    valueBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local num = tonumber(valueBox.Text)
            if num then updateValue(num) end
        end
    end)
    return row
end

-- Helper: Create Button Row
local function createButtonRow(text, callback)
    local row = Instance.new("TextButton", ScrollingFrame)
    row.Size = UDim2.new(1, 0, 0, 40)
    row.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
    row.Text = text
    row.TextColor3 = Color3.fromRGB(255, 255, 255)
    row.Font = Enum.Font.GothamBold
    row.TextSize = 14
    local rowCorner = Instance.new("UICorner", row)
    rowCorner.CornerRadius = UDim.new(0, 8)
    row.MouseButton1Click:Connect(callback)
    return row
end

-- Build UI with Separators and Modern Switches
createSection("🎣 FARMING")
createSwitchRow("Instant Fishing (Perfect Catch)", "InstaFish")
createSliderRow("Catch Delay (s)", "FishDelay", 0.05, 2, 0.05, "s")
createSeparator()
createSwitchRow("Auto Cast", "AutoCast")
createSliderRow("Cast Delay (s)", "CastDelay", 0.5, 5, 0.1, "s")
createSeparator()
createSwitchRow("Auto Equip Rod", "AutoEquipRod")

createSection("💰 AUTO SELL")
createSwitchRow("Auto Sell Fish", "AutoSell")
createSliderRow("Sell Interval (s)", "SellDelay", 10, 120, 5, "s")

createSection("🐟 AUTO BAIT")
createSwitchRow("Auto Use Bait", "AutoBait")
createSliderRow("Bait Usage Interval (s)", "BaitDelay", 30, 300, 10, "s")

createSection("📍 TELEPORT SPOTS")
local spots = {
    ["Spawn Area"] = CFrame.new(0, 10, 0),
    ["Pond"] = CFrame.new(100, 5, 50),
    ["Lake"] = CFrame.new(-80, 5, 120),
    ["Ocean"] = CFrame.new(200, 2, 300),
}
for name, cframe in pairs(spots) do
    createButtonRow("Teleport to " .. name, function()
        TeleportToPosition(cframe)
    end)
end
for name, cframe in pairs(_G.Settings.TeleportSpots) do
    createButtonRow("Teleport to " .. name, function()
        TeleportToPosition(cframe)
    end)
end
createButtonRow("+ Add Current Spot", function()
    local spotName = "Spot " .. tostring(os.time())
    local cframe = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp.Character.HumanoidRootPart.CFrame or CFrame.new(0,0,0)
    _G.Settings.TeleportSpots[spotName] = cframe
    SaveConfig()
    createButtonRow("Teleport to " .. spotName, function()
        TeleportToPosition(cframe)
    end)
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Wait()
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end)

createSection("🖥️ PERFORMANCE")
createButtonRow("🚀 Extreme FPS Boost", function()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
        if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
    end
    showNotification("FPS Boost Applied!")
end)
createSeparator()
createSwitchRow("❄️ White Screen (CPU Saver)", "WhiteScreen")
createSeparator()
createSwitchRow("🎨 Disable VFX (Particles/Lights)", "DisableVFX")

createSection("🛡️ SECURITY")
createSwitchRow("Anti-Staff (Auto Server Hop)", "AntiStaff")
createSwitchRow("Server Hop on Low Fish", "ServerHopLowFish")
createSliderRow("Low Fish Threshold", "LowFishThreshold", 1, 50, 1, "fish")

createSection("⚙️ MISC")
createSwitchRow("Anti AFK", "AntiAFK")
createSliderRow("Anti AFK Interval (s)", "AntiAFKInterval", 30, 300, 10, "s")
createSeparator()
createSwitchRow("ESP Fish Highlight", "ESPFish")
createButtonRow("Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, lp)
end)

-- Adjust canvas size
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end)
task.wait(0.1)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)

-- Minimize / Close
MinBtn.MouseButton1Click:Connect(function()
    MainPanel.Visible = false
    FloatingIcon.Visible = true
end)
CloseBtn.MouseButton1Click:Connect(function()
    MainPanel.Visible = false
    FloatingIcon.Visible = true
end)

-- // 🖱️ FLOATING ICON (KAE Logo) //
local FloatingGui = Instance.new("ScreenGui", CoreGui)
FloatingGui.Name = "KaeFloating"

local FloatingIcon = Instance.new("ImageButton", FloatingGui)
FloatingIcon.Size = UDim2.new(0, 55, 0, 55)
FloatingIcon.Position = UDim2.new(0.02, 0, 0.4, 0)
FloatingIcon.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
FloatingIcon.BorderSizePixel = 2
FloatingIcon.BorderColor3 = Color3.fromRGB(255, 255, 255)
local iconCorner = Instance.new("UICorner", FloatingIcon)
iconCorner.CornerRadius = UDim.new(1, 0)

local iconText = Instance.new("TextLabel", FloatingIcon)
iconText.Size = UDim2.new(1, 0, 1, 0)
iconText.BackgroundTransparency = 1
iconText.Text = "KAE"
iconText.TextColor3 = Color3.fromRGB(255, 255, 255)
iconText.Font = Enum.Font.GothamBold
iconText.TextSize = 20
iconText.TextScaled = true

-- Draggable Floating Icon
local draggingIcon = false
local dragIconStart, startIconPos
FloatingIcon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingIcon = true
        dragIconStart = input.Position
        startIconPos = FloatingIcon.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and draggingIcon then
        local delta = input.Position - dragIconStart
        FloatingIcon.Position = UDim2.new(startIconPos.X.Scale, startIconPos.X.Offset + delta.X, startIconPos.Y.Scale, startIconPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingIcon = false
    end
end)

FloatingIcon.MouseButton1Click:Connect(function()
    FloatingIcon.Visible = false
    MainPanel.Visible = true
end)

-- // 🔔 NOTIFICATION SYSTEM //
local function showNotification(msg)
    local notif = Instance.new("TextLabel", TabletGui)
    notif.Size = UDim2.new(0, 250, 0, 40)
    notif.Position = UDim2.new(0.5, -125, 0.9, 0)
    notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notif.BackgroundTransparency = 0.6
    notif.Text = msg
    notif.TextColor3 = Color3.fromRGB(255, 20, 147)
    notif.Font = Enum.Font.GothamBold
    notif.TextSize = 14
    local notifCorner = Instance.new("UICorner", notif)
    notifCorner.CornerRadius = UDim.new(0, 8)
    task.wait(3)
    notif:Destroy()
end

-- Start loops
updateLoops()
showNotification("🌸 KAE TEMPEST V0.2 Loaded! Click the pink icon to open menu.")
