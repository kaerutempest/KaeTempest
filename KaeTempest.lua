-- [[ 🌸 KAE TEMPEST | FISH IT V0.1 🌸 ]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local TS = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- // 📂 CONFIG SYSTEM (AUTO-SAVE) //
local ConfigName = "KaeTempest_FishIt.json"
_G.Settings = {
    InstaFish = false,
    AntiStaff = true,
    FPSBoost = false,
    WhiteScreen = false,
    AutoFill = false
}

local function SaveConfig()
    writefile(ConfigName, HttpService:JSONEncode(_G.Settings))
end

local function LoadConfig()
    if isfile(ConfigName) then
        _G.Settings = HttpService:JSONDecode(readfile(ConfigName))
    end
end
LoadConfig()

-- // 🚀 OPTIMIZATION FUNCTIONS //
local function ExtremeFPS()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        elseif v:IsA("Shadow" or "Bloom" or "Blur") then
            v.Enabled = false
        end
    end
    game:GetService("Lighting").GlobalShadows = false
end

-- // 🖥️ WHITE SCREEN (CPU SAVER) //
local WhiteScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Frame = Instance.new("Frame", WhiteScreenGui)
Frame.Size = UDim2.new(1, 0, 1, 0)
Frame.BackgroundColor3 = Color3.new(1, 1, 1)
Frame.Visible = false

-- // 🎣 FISHING LOGIC //
local function InstantFish()
    task.spawn(function()
        while _G.Settings.InstaFish do
            task.wait(0.1)
            local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("FishingLine") then
                local rem = game:GetService("ReplicatedStorage"):FindFirstChild("FishEvents") or game:GetService("ReplicatedStorage"):FindFirstChild("Events")
                if rem then rem:FireServer("Catch", "Perfect") end
            end
        end
    end)
end

-- // 🛡️ ANTI-STAFF PRO //
Players.PlayerAdded:Connect(function(player)
    if _G.Settings.AntiStaff then
        if player:GetRoleInGroup(1234567) ~= "Guest" or player.AccountAge < 2 then 
            game:GetService("TeleportService"):Teleport(game.PlaceId) -- Server Hop
        end
    end
end)

-- // 🎨 UI SETUP (RAYFIELD) //
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "🌸 Kae Tempest | Fish It v2.6 🌸",
   LoadingTitle = "Kae Tempest Hub",
   LoadingSubtitle = "Lynx & Meng Hub standard",
   ConfigurationSaving = { Enabled = false }
})

-- TAB: FARMING
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

-- TAB: OPTIMIZATION (THE LYNX STYLE)
local OptiTab = Window:CreateTab("🖥️ Optimization", 4483362458)
OptiTab:CreateButton({
   Name = "🚀 Extreme FPS Boost (Smooth Plastic)",
   Callback = function() ExtremeFPS() end,
})

OptiTab:CreateToggle({
   Name = "❄️ CPU Saver (White Screen)",
   CurrentValue = _G.Settings.WhiteScreen,
   Callback = function(V)
       _G.Settings.WhiteScreen = V
       Frame.Visible = V
       SaveConfig()
       -- Reduce rendering when white screen active
       RunService:Set3dRenderingEnabled(not V)
   end,
})

-- TAB: SECURITY
local SecTab = Window:CreateTab("🛡️ Security", 4483362458)
SecTab:CreateToggle({
   Name = "Anti-Staff (Auto Server Hop)",
   CurrentValue = _G.Settings.AntiStaff,
   Callback = function(V) _G.Settings.AntiStaff = V; SaveConfig() end,
})

-- TAB: MISC
local MiscTab = Window:CreateTab("⚙️ Misc", 4483362458)
MiscTab:CreateButton({
   Name = "Rejoin Server",
   Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, lp) end,
})

Rayfield:Notify({Title = "Kae Tempest Hub", Content = "Semua fitur Lynx & Meng Hub aktif!", Duration = 5})
