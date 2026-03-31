-- [[ 🌸 KAE TEMPEST | FISH IT V0.1 🌸 ]]
-- Design: Sidebar Left (Vertical Nav)
-- Theme: Deep Black & Neon Pink

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- // 📂 CONFIG SYSTEM //
local ConfigName = "KaeTempest_FishIt.json"
_G.Settings = {
    InstaFish = false,
    FishDelay = 0.1,
    AntiStaff = true,
    FPSBoost = false,
    WhiteScreen = false
}

local function SaveConfig()
    writefile(ConfigName, HttpService:JSONEncode(_G.Settings))
end

if isfile(ConfigName) then
    _G.Settings = HttpService:JSONDecode(readfile(ConfigName))
end

-- // 🖥️ WHITE SCREEN //
local WhiteScreenGui = Instance.new("ScreenGui", CoreGui)
local Frame = Instance.new("Frame", WhiteScreenGui)
Frame.Size = UDim2.new(1, 0, 1, 0)
Frame.BackgroundColor3 = Color3.new(1, 1, 1)
Frame.Visible = false

-- // 🎣 FISHING LOGIC //
local function InstantFish()
    task.spawn(function()
        while _G.Settings.InstaFish do
            task.wait(_G.Settings.FishDelay)
            local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("FishingLine") then
                local rem = game:GetService("ReplicatedStorage"):FindFirstChild("FishEvents") or game:GetService("ReplicatedStorage"):FindFirstChild("Events")
                if rem then rem:FireServer("Catch", "Perfect") end
            end
        end
    end)
end

-- // 🎨 UI SETUP (RAYFIELD SIDEBAR) //
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "🌸 Kae Tempest | V0.1 🌸",
   LoadingTitle = "Kae Tempest Hub",
   LoadingSubtitle = "誰もが楽しく快適に過ごせる国を作る",
   ConfigurationSaving = { Enabled = false },
   Theme = "DarkBlue", -- Base for color override
   DisableRayfieldPrompts = true
})

-- // ✨ CUSTOM DESIGN OVERRIDE (PINK & BLACK) //
local RayfieldGui = CoreGui:FindFirstChild("RayfieldGui")
if RayfieldGui then
    local Main = RayfieldGui:FindFirstChild("Main", true)
    if Main then
        Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10) -- Hitam Sangat Pekat
        Main.BorderColor3 = Color3.fromRGB(255, 20, 147) -- Pink Neon Border
        Main.BorderSizePixel = 2
    end
end

-- // 🖱️ FLOATING ICON (PINK BLACK) //
local FloatingGui = Instance.new("ScreenGui", CoreGui)
FloatingGui.Name = "KaeFloating"

local MainBtn = Instance.new("ImageButton", FloatingGui)
MainBtn.Size = UDim2.new(0, 45, 0, 45)
MainBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
MainBtn.Image = "rbxassetid://15125902170" 
MainBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainBtn.BorderColor3 = Color3.fromRGB(255, 20, 147)
MainBtn.BorderSizePixel = 2
MainBtn.Visible = false

-- Draggable Function
local dragging, dragInput, dragStart, startPos
MainBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainBtn.Position
    end
end)
MainBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
MainBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

MainBtn.MouseButton1Click:Connect(function()
    MainBtn.Visible = false
    Window:Minimize(false)
end)

task.spawn(function()
    while task.wait(0.5) do
        if Window.Minimized then MainBtn.Visible = true else MainBtn.Visible = false end
    end
end)

-- // 📑 SIDEBAR TABS (URUT KE BAWAH) //

local FarmTab = Window:CreateTab("🎣 Farming", 4483362458)
FarmTab:CreateToggle({
   Name = "Instant Fishing",
   CurrentValue = _G.Settings.InstaFish,
   Callback = function(V)
       _G.Settings.InstaFish = V
       SaveConfig()
       if V then InstantFish() end
   end,
})
FarmTab:CreateSlider({
   Name = "Fishing Speed Delay",
   Range = {0, 2},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = _G.Settings.FishDelay,
   Callback = function(V) _G.Settings.FishDelay = V; SaveConfig() end,
})

local OptiTab = Window:CreateTab("🖥️ Performance", 4483362458)
OptiTab:CreateButton({
   Name = "🚀 Extreme FPS Boost",
   Callback = function()
       for _, v in pairs(game:GetDescendants()) do
           if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
           if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
       end
   end,
})
OptiTab:CreateToggle({
   Name = "❄️ White Screen (CPU Saver)",
   CurrentValue = _G.Settings.WhiteScreen,
   Callback = function(V)
       _G.Settings.WhiteScreen = V
       Frame.Visible = V
       SaveConfig()
       RunService:Set3dRenderingEnabled(not V)
   end,
})

local SecTab = Window:CreateTab("🛡️ Security", 4483362458)
SecTab:CreateToggle({
   Name = "Anti-Staff (Auto Server Hop)",
   CurrentValue = _G.Settings.AntiStaff,
   Callback = function(V) _G.Settings.AntiStaff = V; SaveConfig() end,
})

local MiscTab = Window:CreateTab("⚙️ Misc", 4483362458)
MiscTab:CreateButton({
   Name = "Rejoin Server",
   Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, lp) end,
})

Rayfield:Notify({Title = "Kae Tempest | V0.1", Content = "Design Cool Sidebar Aktif!", Duration = 3})
