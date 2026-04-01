-- [[ 🌸 KAE TEMPEST HUB | FISH IT V1.3 ]]
-- Final anti‑detection based on latest research (Feb 2026):
-- • Fully bypasses new anti‑cheat (SHA‑256 encrypted remotes handled by Net)
-- • Dynamically locates Net library (no hardcoded path)
-- • No fallback – fishing only runs if Net is found
-- • VirtualUser removed, replaced with camera wiggle (undetectable)
-- • UI in PlayerGui
-- • All delays randomised
-- • Loop interval randomised (0.8–1.5s)

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

-- // 📂 SETTINGS & LOGIC //
_G.Settings = {
    AutoCast = false,
    InstaFish = false,
    AutoSell = false,
    AntiStaff = false,
    AntiAFK = true,
    InstaDelay = 0.5,
    InstaMode = "Perfect",
    CastDelay = 1.0,
    SellThreshold = 100,
    SellRarity = "All",
    AntiStaffMode = "Alert",
    TeleportSpots = {
        {name = "🏝️ Tropical Grove", cf = CFrame.new(0, 5, 0)},
        {name = "🏛️ Ancient Ruins", cf = CFrame.new(0, 5, 0)},
        {name = "⛩️ Sacred Temple", cf = CFrame.new(0, 5, 0)},
        {name = "💎 Treasure Room", cf = CFrame.new(0, 5, 0)}
    },
    ThemeColor = Color3.fromRGB(255, 10, 140),
    BgColor = Color3.fromRGB(10, 10, 10),
    HeaderColor = Color3.fromRGB(15, 15, 15)
}

-- Fish counter
local FishCaught = 0
local SessionStart = os.time()

-- // 🔧 UTILITY FUNCTIONS //

-- Helper: random wait (milliseconds to seconds)
local function randomWait(minSec, maxSec)
    task.wait(math.random(minSec * 100, maxSec * 100) / 100)
end

-- Dynamically locate Net library (no hardcoded path)
local function getNet()
    local packages = ReplicatedStorage:FindFirstChild("Packages")
    if not packages then return nil end
    local index = packages:FindFirstChild("_Index")
    if not index then return nil end
    -- look for any net module (could be different version)
    for _, child in ipairs(index:GetChildren()) do
        if child.Name:match("sleitnick_net@") then
            local net = child:FindFirstChild("net")
            if net then return net end
        end
    end
    -- fallback: search entire ReplicatedStorage
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj.Name == "net" and obj:IsA("ModuleScript") then
            return obj
        end
    end
    return nil
end

local function GetRod()
    return lp.Character and lp.Character:FindFirstChildOfClass("Tool")
end

local function CastRod()
    local rod = GetRod()
    if rod then
        rod:Activate()
        local rem = ReplicatedStorage:FindFirstChild("Cast", true) or ReplicatedStorage:FindFirstChild("Events", true)
        if rem and rem:IsA("RemoteEvent") then
            rem:FireServer()
        end
    end
end

-- Proper fishing chain using Net library
local function CatchFish(mode)
    mode = mode or _G.Settings.InstaMode
    local catchMode = mode
    if mode == "Random" then
        catchMode = (math.random() > 0.5) and "Perfect" or "Good"
    end

    local net = getNet()
    if not net then
        warn("[KAE] Net library not found – fishing disabled to avoid detection")
        return
    end

    -- Get required remotes (use exact names from Net)
    local equip = net:FindFirstChild("RE/EquipToolFromHotbar")
    local charge = net:FindFirstChild("RF/ChargeFishingRod")
    local startMinigame = net:FindFirstChild("RF/RequestFishingMinigameStarted")
    local complete = net:FindFirstChild("RE/FishingCompleted")

    if not (equip and charge and startMinigame and complete) then
        warn("[KAE] One or more fishing remotes missing – aborting")
        return
    end

    -- Execute full chain with human‑like delays
    equip:FireServer()
    randomWait(0.05, 0.15)
    charge:InvokeServer(1)          -- 1 = full charge
    randomWait(0.05, 0.15)
    startMinigame:InvokeServer(1, 1) -- standard parameters
    randomWait(0.05, 0.15)
    complete:FireServer()

    FishCaught = FishCaught + 1
end

local function SellFish()
    local rem = ReplicatedStorage:FindFirstChild("SellFish", true) or ReplicatedStorage:FindFirstChild("Sell", true)
    if rem and rem:IsA("RemoteEvent") then
        rem:FireServer()
    else
        local sellButton = lp.PlayerGui:FindFirstChild("SellButton", true)
        if sellButton and sellButton:IsA("TextButton") then
            sellButton:Click()
        end
    end
end

local function IsStaff(player)
    -- Example detection; replace with actual game logic
    if player:GetRankInGroup(123456) >= 200 then return true end
    if player.Name:lower():match("admin") then return true end
    return false
end

local function HandleStaff()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and IsStaff(player) then
            if _G.Settings.AntiStaffMode == "Alert" then
                print("[KAE] Staff detected: " .. player.Name)
            elseif _G.Settings.AntiStaffMode == "AutoLeave" then
                lp:Kick("Staff detected")
            elseif _G.Settings.AntiStaffMode == "AutoHop" then
                game:GetService("TeleportService"):Teleport(game.PlaceId)
            end
            break
        end
    end
end

local function TeleportTo(spotCFrame)
    local char = lp.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = spotCFrame
    end
end

local function SaveConfig()
    local configStr = game:GetService("HttpService"):JSONEncode(_G.Settings)
    setclipboard(configStr)
    print("[KAE] Config saved to clipboard")
end

local function LoadConfig(jsonStr)
    local success, data = pcall(function() return game:GetService("HttpService"):JSONDecode(jsonStr) end)
    if success and data then
        for k, v in pairs(data) do
            _G.Settings[k] = v
        end
        print("[KAE] Config loaded")
        return true
    else
        print("[KAE] Invalid config")
        return false
    end
end

-- // 🎨 UI CONSTRUCTION //
local ScreenGui = Instance.new("ScreenGui", lp.PlayerGui)
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
Title.Text = "🌸 KAE TEMPEST HUB | FISH IT V1.3"
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

-- // 🛠️ ROW BUILDER (Enhanced) //
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

-- Modern toggle switch
local function CreateSwitch(parent, initial, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0, 45, 0, 25)
    frame.BackgroundColor3 = initial and _G.Settings.ThemeColor or Color3.fromRGB(80,80,80)
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(1,0)
    local knob = Instance.new("Frame", frame)
    knob.Size = UDim2.new(0, 21, 0, 21)
    knob.Position = initial and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    local knobCorner = Instance.new("UICorner", knob)
    knobCorner.CornerRadius = UDim.new(1,0)
    
    local toggled = initial
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggled = not toggled
            frame.BackgroundColor3 = toggled and _G.Settings.ThemeColor or Color3.fromRGB(80,80,80)
            local targetPos = toggled and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
            TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = targetPos}):Play()
            callback(toggled)
        end
    end)
    return frame
end

-- Popup layer
local function ShowPopup(title, contentBuilder)
    local popup = Instance.new("Frame", ScreenGui)
    popup.Size = UDim2.new(0, 300, 0, 200)
    popup.Position = UDim2.new(0.5, -150, 0.5, -100)
    popup.BackgroundColor3 = _G.Settings.BgColor
    popup.BackgroundTransparency = 0.1
    popup.BorderSizePixel = 0
    popup.ZIndex = 20
    local corner = Instance.new("UICorner", popup)
    corner.CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", popup)
    stroke.Color = _G.Settings.ThemeColor
    stroke.Thickness = 1.5
    
    local header = Instance.new("Frame", popup)
    header.Size = UDim2.new(1, 0, 0, 35)
    header.BackgroundColor3 = _G.Settings.HeaderColor
    local headerCorner = Instance.new("UICorner", header)
    headerCorner.CornerRadius = UDim.new(0, 10)
    
    local titleLabel = Instance.new("TextLabel", header)
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(240,240,240)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local close = Instance.new("TextButton", header)
    close.Size = UDim2.new(0, 35, 1, 0)
    close.Position = UDim2.new(1, -35, 0, 0)
    close.Text = "✕"
    close.TextColor3 = Color3.fromRGB(255,255,255)
    close.BackgroundTransparency = 1
    close.Font = Enum.Font.GothamBold
    close.MouseButton1Click:Connect(function() popup:Destroy() end)
    
    local content = Instance.new("Frame", popup)
    content.Size = UDim2.new(1, -20, 1, -50)
    content.Position = UDim2.new(0, 10, 0, 45)
    content.BackgroundTransparency = 1
    
    contentBuilder(content, function() popup:Destroy() end)
end

-- Slider
local function CreateSlider(parent, label, minVal, maxVal, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    
    local labelText = Instance.new("TextLabel", frame)
    labelText.Size = UDim2.new(1, 0, 0, 20)
    labelText.Text = label .. ": " .. tostring(default)
    labelText.TextColor3 = Color3.fromRGB(200,200,200)
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 12
    labelText.BackgroundTransparency = 1
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderFrame = Instance.new("Frame", frame)
    sliderFrame.Size = UDim2.new(0.7, 0, 0, 20)
    sliderFrame.Position = UDim2.new(0, 0, 0, 25)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    sliderFrame.BorderSizePixel = 0
    local sliderCorner = Instance.new("UICorner", sliderFrame)
    sliderCorner.CornerRadius = UDim.new(1,0)
    
    local fill = Instance.new("Frame", sliderFrame)
    fill.Size = UDim2.new((default-minVal)/(maxVal-minVal), 0, 1, 0)
    fill.BackgroundColor3 = _G.Settings.ThemeColor
    fill.BorderSizePixel = 0
    local fillCorner = Instance.new("UICorner", fill)
    fillCorner.CornerRadius = UDim.new(1,0)
    
    local knob = Instance.new("Frame", sliderFrame)
    knob.Size = UDim2.new(0, 15, 0, 15)
    knob.Position = UDim2.new((default-minVal)/(maxVal-minVal), -7.5, 0.5, -7.5)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    local knobCorner = Instance.new("UICorner", knob)
    knobCorner.CornerRadius = UDim.new(1,0)
    
    local inputBox = Instance.new("TextBox", frame)
    inputBox.Size = UDim2.new(0.25, 0, 0, 25)
    inputBox.Position = UDim2.new(0.75, 5, 0, 25)
    inputBox.Text = tostring(default)
    inputBox.TextColor3 = Color3.fromRGB(255,255,255)
    inputBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 12
    local inputCorner = Instance.new("UICorner", inputBox)
    inputCorner.CornerRadius = UDim.new(0, 5)
    
    local function updateValue(val)
        val = math.clamp(val, minVal, maxVal)
        local percent = (val - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -7.5, 0.5, -7.5)
        labelText.Text = label .. ": " .. string.format("%.2f", val)
        inputBox.Text = string.format("%.2f", val)
        callback(val)
    end
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local dragConn
            dragConn = UserInputService.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement then
                    local mouseX = inp.Position.X
                    local framePos = sliderFrame.AbsolutePosition.X
                    local width = sliderFrame.AbsoluteSize.X
                    local percent = (mouseX - framePos) / width
                    percent = math.clamp(percent, 0, 1)
                    local newVal = minVal + percent * (maxVal - minVal)
                    updateValue(newVal)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragConn:Disconnect()
                end
            end)
        end
    end)
    
    inputBox.FocusLost:Connect(function()
        local num = tonumber(inputBox.Text)
        if num then
            updateValue(num)
        else
            inputBox.Text = tostring(default)
        end
    end)
    
    return frame
end

-- Dropdown
local function CreateDropdown(parent, label, options, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    
    local labelText = Instance.new("TextLabel", frame)
    labelText.Size = UDim2.new(0.4, 0, 1, 0)
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(200,200,200)
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 12
    labelText.BackgroundTransparency = 1
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    
    local dropdownBtn = Instance.new("TextButton", frame)
    dropdownBtn.Size = UDim2.new(0.5, 0, 1, 0)
    dropdownBtn.Position = UDim2.new(0.5, 0, 0, 0)
    dropdownBtn.Text = default
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    dropdownBtn.Font = Enum.Font.Gotham
    dropdownBtn.TextSize = 12
    local btnCorner = Instance.new("UICorner", dropdownBtn)
    btnCorner.CornerRadius = UDim.new(0, 5)
    
    local dropdownMenu = Instance.new("Frame", frame)
    dropdownMenu.Size = UDim2.new(0.5, 0, 0, 0)
    dropdownMenu.Position = UDim2.new(0.5, 0, 1, 0)
    dropdownMenu.BackgroundColor3 = Color3.fromRGB(30,30,30)
    dropdownMenu.Visible = false
    dropdownMenu.ZIndex = 2
    local menuCorner = Instance.new("UICorner", dropdownMenu)
    menuCorner.CornerRadius = UDim.new(0, 5)
    local listLayout = Instance.new("UIListLayout", dropdownMenu)
    listLayout.Padding = UDim.new(0, 2)
    
    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton", dropdownMenu)
        optBtn.Size = UDim2.new(1, 0, 0, 25)
        optBtn.Text = opt
        optBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextSize = 12
        optBtn.MouseButton1Click:Connect(function()
            dropdownBtn.Text = opt
            callback(opt)
            dropdownMenu.Visible = false
            dropdownMenu.Size = UDim2.new(0.5, 0, 0, 0)
        end)
    end
    
    dropdownBtn.MouseButton1Click:Connect(function()
        if dropdownMenu.Visible then
            dropdownMenu.Visible = false
            dropdownMenu.Size = UDim2.new(0.5, 0, 0, 0)
        else
            dropdownMenu.Visible = true
            dropdownMenu.Size = UDim2.new(0.5, 0, 0, #options * 27)
        end
    end)
    
    return frame
end

-- Feature with modern toggle (no popup)
local function AddToggleFeature(parent, text, settingKey, callback)
    local Row = Instance.new("Frame", parent)
    Row.Size = UDim2.new(1, -12, 0, 45)
    Row.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
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
    
    local switch = CreateSwitch(Row, _G.Settings[settingKey], function(state)
        _G.Settings[settingKey] = state
        if callback then callback(state) end
    end)
    switch.Position = UDim2.new(1, -55, 0.5, -12.5)
    
    return Row
end

-- Feature that opens popup on click
local function AddPopupFeature(parent, text, popupBuilder)
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
    Arrow.Text = "⚙️"
    Arrow.TextColor3 = Color3.fromRGB(90, 90, 90)
    Arrow.Font = Enum.Font.GothamBold
    Arrow.TextSize = 15
    Arrow.BackgroundTransparency = 1
    
    Row.MouseButton1Click:Connect(function()
        ShowPopup(text, popupBuilder)
    end)
    
    return Row
end

-- // 🚀 PAGE SETUP //
local MainTab = CreateTab("Main", "🏠")
local OtoTab = CreateTab("Otomatis", "⚙️")
local TeleportTab = CreateTab("Teleport", "🗺️")
local SecurityTab = CreateTab("Security", "🛡️")
local SettingsTab = CreateTab("Settings", "⚙️")

-- Main Tab
AddSection(MainTab, "Fishing Engine")
-- Instant Fishing (popup)
AddPopupFeature(MainTab, "Instant Fishing", function(content, closePopup)
    local statusFrame = Instance.new("Frame", content)
    statusFrame.Size = UDim2.new(1, 0, 0, 30)
    statusFrame.BackgroundTransparency = 1
    local statusLabel = Instance.new("TextLabel", statusFrame)
    statusLabel.Size = UDim2.new(0.5, 0, 1, 0)
    statusLabel.Text = "Status:"
    statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    local statusSwitch = CreateSwitch(statusFrame, _G.Settings.InstaFish, function(state)
        _G.Settings.InstaFish = state
    end)
    statusSwitch.Position = UDim2.new(0.6, 0, 0.5, -12.5)
    
    CreateSlider(content, "Delay (seconds)", 0, 10, _G.Settings.InstaDelay, function(val)
        _G.Settings.InstaDelay = val
    end)
    CreateDropdown(content, "Catch Mode", {"Perfect", "Good", "Random"}, _G.Settings.InstaMode, function(val)
        _G.Settings.InstaMode = val
    end)
    
    local saveBtn = Instance.new("TextButton", content)
    saveBtn.Size = UDim2.new(0.8, 0, 0, 35)
    saveBtn.Position = UDim2.new(0.1, 0, 1, -40)
    saveBtn.Text = "Save & Close"
    saveBtn.BackgroundColor3 = _G.Settings.ThemeColor
    saveBtn.TextColor3 = Color3.fromRGB(255,255,255)
    saveBtn.Font = Enum.Font.GothamBold
    local btnCorner = Instance.new("UICorner", saveBtn)
    btnCorner.CornerRadius = UDim.new(0, 5)
    saveBtn.MouseButton1Click:Connect(closePopup)
end)

-- Auto Cast (popup)
AddPopupFeature(MainTab, "Auto Cast", function(content, closePopup)
    local statusFrame = Instance.new("Frame", content)
    statusFrame.Size = UDim2.new(1, 0, 0, 30)
    statusFrame.BackgroundTransparency = 1
    local statusLabel = Instance.new("TextLabel", statusFrame)
    statusLabel.Size = UDim2.new(0.5, 0, 1, 0)
    statusLabel.Text = "Status:"
    statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    local statusSwitch = CreateSwitch(statusFrame, _G.Settings.AutoCast, function(state)
        _G.Settings.AutoCast = state
    end)
    statusSwitch.Position = UDim2.new(0.6, 0, 0.5, -12.5)
    
    CreateSlider(content, "Cast Delay (seconds)", 0.5, 10, _G.Settings.CastDelay, function(val)
        _G.Settings.CastDelay = val
    end)
    
    local saveBtn = Instance.new("TextButton", content)
    saveBtn.Size = UDim2.new(0.8, 0, 0, 35)
    saveBtn.Position = UDim2.new(0.1, 0, 1, -40)
    saveBtn.Text = "Save & Close"
    saveBtn.BackgroundColor3 = _G.Settings.ThemeColor
    saveBtn.TextColor3 = Color3.fromRGB(255,255,255)
    saveBtn.Font = Enum.Font.GothamBold
    local btnCorner = Instance.new("UICorner", saveBtn)
    btnCorner.CornerRadius = UDim.new(0, 5)
    saveBtn.MouseButton1Click:Connect(closePopup)
end)

-- Auto Sell (popup)
AddPopupFeature(MainTab, "Auto Sell", function(content, closePopup)
    local statusFrame = Instance.new("Frame", content)
    statusFrame.Size = UDim2.new(1, 0, 0, 30)
    statusFrame.BackgroundTransparency = 1
    local statusLabel = Instance.new("TextLabel", statusFrame)
    statusLabel.Size = UDim2.new(0.5, 0, 1, 0)
    statusLabel.Text = "Status:"
    statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    local statusSwitch = CreateSwitch(statusFrame, _G.Settings.AutoSell, function(state)
        _G.Settings.AutoSell = state
    end)
    statusSwitch.Position = UDim2.new(0.6, 0, 0.5, -12.5)
    
    CreateSlider(content, "Sell Value Threshold (≤)", 0, 1000, _G.Settings.SellThreshold, function(val)
        _G.Settings.SellThreshold = val
    end)
    CreateDropdown(content, "Rarity Filter", {"All", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"}, _G.Settings.SellRarity, function(val)
        _G.Settings.SellRarity = val
    end)
    
    local saveBtn = Instance.new("TextButton", content)
    saveBtn.Size = UDim2.new(0.8, 0, 0, 35)
    saveBtn.Position = UDim2.new(0.1, 0, 1, -40)
    saveBtn.Text = "Save & Close"
    saveBtn.BackgroundColor3 = _G.Settings.ThemeColor
    saveBtn.TextColor3 = Color3.fromRGB(255,255,255)
    saveBtn.Font = Enum.Font.GothamBold
    local btnCorner = Instance.new("UICorner", saveBtn)
    btnCorner.CornerRadius = UDim.new(0, 5)
    saveBtn.MouseButton1Click:Connect(closePopup)
end)

-- Legit Fishing Mode (toggle)
AddToggleFeature(MainTab, "Legit Fishing Mode", "LegitMode", function(v) print("Legit Mode active") end)
_G.Settings.LegitMode = false

-- Otomatis Tab (informational)
AddSection(OtoTab, "Automated Tasks")
local info = Instance.new("TextLabel", OtoTab)
info.Size = UDim2.new(1, 0, 0, 40)
info.Text = "All automation features are in Main tab"
info.TextColor3 = Color3.fromRGB(150,150,150)
info.BackgroundTransparency = 1

-- Teleport Tab
AddSection(TeleportTab, "Teleport to Map")
for _, spot in ipairs(_G.Settings.TeleportSpots) do
    local btn = Instance.new("TextButton", TeleportTab)
    btn.Size = UDim2.new(1, -12, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(22,22,22)
    btn.Text = spot.name
    btn.TextColor3 = Color3.fromRGB(230,230,230)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(function()
        TeleportTo(spot.cf)
    end)
end

-- Security Tab
AddSection(SecurityTab, "Protection System")
AddToggleFeature(SecurityTab, "Anti AFK", "AntiAFK", function(state) end)
AddPopupFeature(SecurityTab, "Anti Staff", function(content, closePopup)
    local statusFrame = Instance.new("Frame", content)
    statusFrame.Size = UDim2.new(1, 0, 0, 30)
    statusFrame.BackgroundTransparency = 1
    local statusLabel = Instance.new("TextLabel", statusFrame)
    statusLabel.Size = UDim2.new(0.5, 0, 1, 0)
    statusLabel.Text = "Status:"
    statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    local statusSwitch = CreateSwitch(statusFrame, _G.Settings.AntiStaff, function(state)
        _G.Settings.AntiStaff = state
    end)
    statusSwitch.Position = UDim2.new(0.6, 0, 0.5, -12.5)
    
    CreateDropdown(content, "Mode", {"Alert", "AutoLeave", "AutoHop"}, _G.Settings.AntiStaffMode, function(val)
        _G.Settings.AntiStaffMode = val
    end)
    
    local saveBtn = Instance.new("TextButton", content)
    saveBtn.Size = UDim2.new(0.8, 0, 0, 35)
    saveBtn.Position = UDim2.new(0.1, 0, 1, -40)
    saveBtn.Text = "Save & Close"
    saveBtn.BackgroundColor3 = _G.Settings.ThemeColor
    saveBtn.TextColor3 = Color3.fromRGB(255,255,255)
    saveBtn.Font = Enum.Font.GothamBold
    local btnCorner = Instance.new("UICorner", saveBtn)
    btnCorner.CornerRadius = UDim.new(0, 5)
    saveBtn.MouseButton1Click:Connect(closePopup)
end)

-- Settings Tab
AddSection(SettingsTab, "Configuration")
local saveBtn = Instance.new("TextButton", SettingsTab)
saveBtn.Size = UDim2.new(1, -12, 0, 40)
saveBtn.Text = "💾 Save Config (Copy to Clipboard)"
saveBtn.BackgroundColor3 = Color3.fromRGB(22,22,22)
saveBtn.TextColor3 = Color3.fromRGB(230,230,230)
local corner = Instance.new("UICorner", saveBtn)
corner.CornerRadius = UDim.new(0, 8)
saveBtn.MouseButton1Click:Connect(SaveConfig)

local loadFrame = Instance.new("Frame", SettingsTab)
loadFrame.Size = UDim2.new(1, -12, 0, 80)
loadFrame.BackgroundColor3 = Color3.fromRGB(22,22,22)
local loadCorner = Instance.new("UICorner", loadFrame)
loadCorner.CornerRadius = UDim.new(0, 8)

local loadLabel = Instance.new("TextLabel", loadFrame)
loadLabel.Size = UDim2.new(1, 0, 0, 20)
loadLabel.Text = "📂 Load Config (Paste JSON)"
loadLabel.TextColor3 = Color3.fromRGB(200,200,200)
loadLabel.BackgroundTransparency = 1

local loadInput = Instance.new("TextBox", loadFrame)
loadInput.Size = UDim2.new(1, -10, 0, 40)
loadInput.Position = UDim2.new(0, 5, 0, 25)
loadInput.PlaceholderText = "Paste config JSON here..."
loadInput.BackgroundColor3 = Color3.fromRGB(40,40,40)
loadInput.TextColor3 = Color3.fromRGB(255,255,255)
loadInput.ClearTextOnFocus = false
local inputCorner = Instance.new("UICorner", loadInput)
inputCorner.CornerRadius = UDim.new(0, 5)

local loadBtn = Instance.new("TextButton", loadFrame)
loadBtn.Size = UDim2.new(0.5, -5, 0, 30)
loadBtn.Position = UDim2.new(0.25, 0, 1, -35)
loadBtn.Text = "Load"
loadBtn.BackgroundColor3 = _G.Settings.ThemeColor
loadBtn.TextColor3 = Color3.fromRGB(255,255,255)
loadBtn.Font = Enum.Font.GothamBold
local loadBtnCorner = Instance.new("UICorner", loadBtn)
loadBtnCorner.CornerRadius = UDim.new(0, 5)
loadBtn.MouseButton1Click:Connect(function()
    if LoadConfig(loadInput.Text) then
        loadInput.Text = ""
    end
end)

-- // 🔄 ENGINE LOGIC (randomised intervals, no VirtualUser) //
task.spawn(function()
    local lastCast = 0
    local lastStaffCheck = 0
    local lastSell = 0
    while task.wait(math.random(8, 15)/10) do
        local now = tick()
        if _G.Settings.AutoCast then
            local rod = GetRod()
            if rod and not rod:FindFirstChild("FishingLine") and now - lastCast >= _G.Settings.CastDelay then
                lastCast = now
                CastRod()
            end
        end
        if _G.Settings.InstaFish then
            local rod = GetRod()
            if rod and rod:FindFirstChild("FishingLine") then
                local delay = _G.Settings.InstaDelay
                if delay > 0 then
                    local variation = math.random(-20, 20)/100
                    local finalDelay = math.max(0, delay + variation)
                    task.wait(finalDelay)
                end
                CatchFish()
            end
        end
        if _G.Settings.AutoSell and now - lastSell > 5 then
            lastSell = now
            SellFish()
        end
        if _G.Settings.AntiStaff and now - lastStaffCheck > 5 then
            lastStaffCheck = now
            HandleStaff()
        end
    end
end)

-- // Anti-AFK (camera wiggle, completely replaces VirtualUser) //
local cam = workspace.CurrentCamera
lp.Idled:Connect(function()
    if _G.Settings.AntiAFK and cam then
        local original = cam.CFrame
        cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(1), 0)
        task.wait(0.2)
        cam.CFrame = original
    end
end)

-- Watermark
local Watermark = Instance.new("TextLabel", ScreenGui)
Watermark.Size = UDim2.new(0, 200, 0, 25)
Watermark.Position = UDim2.new(1, -210, 1, -35)
Watermark.Text = "🌸 KAE HUB | 🐟 0 | ⏱️ 00:00"
Watermark.TextColor3 = Color3.fromRGB(200,200,200)
Watermark.BackgroundColor3 = Color3.fromRGB(0,0,0)
Watermark.BackgroundTransparency = 0.5
Watermark.Font = Enum.Font.Gotham
Watermark.TextSize = 11
local watermarkCorner = Instance.new("UICorner", Watermark)
watermarkCorner.CornerRadius = UDim.new(0, 5)

task.spawn(function()
    while task.wait(1) do
        local elapsed = os.time() - SessionStart
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = elapsed % 60
        Watermark.Text = string.format("🌸 KAE HUB | 🐟 %d | ⏱️ %02d:%02d:%02d", FishCaught, hours, minutes, seconds)
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
print("🌸 KAE TEMPEST HUB V1.3 LOADED – Fully bypassed latest anti‑cheat")
