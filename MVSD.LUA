-- Configuration management
local HttpService = game:GetService("HttpService")
local function saveConfig(Config)
    writefile("MVSDConfig.json", HttpService:JSONEncode(Config))
end

local function loadConfig()
    if isfile("MVSDConfig.json") then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile("MVSDConfig.json"))
        end)
        if success then
            Config = result
        end
    end
end

-- Load configuration at start
loadConfig()

-- The UI Lib, self hosted on my Deta instance
local kavoUi = loadstring(game:HttpGet("https://wastebin-1-j0561772.deta.app/raw/mxtpfizx"))()
local window = kavoUi.CreateLib("MVSD GUI - Pre-Release 2", "Ocean")

-- Tabs
local MainTab = window:NewTab("Main")
local MiscTab = window:NewTab("Misc")
local OtherTab = window:NewTab("Other")
local CreditsTab = window:NewTab("Credits")

-- Sections
local Main = MainTab:NewSection("主要 - insanely obvious")
local Misc = MiscTab:NewSection("杂项 - less/not noticeable")
local Other = OtherTab:NewSection("其他 - some custom stuff")
local Credits = CreditsTab:NewSection("关于")

-- Credits
Credits:NewLabel("huh")
Credits:NewLabel("QQ1759437335")

-- Settings for multiple functions
local Config = Config or {
    Hitbox = {
        HeadSize = 8,
        Disabled = false
    },
    Other = {
        CurrentThreads = 0,
        MaxThreads = 2,
        AimBot = false,
        Delay = 0.5
    },
    Debug = false,
    Waiting = false,
    AimBot = {
        Enabled = false,
        TeamCheck = false,
        WallCheck = true,
        DamageCheck = false,
        AutoShoot = true,
        BetterTargetting = true,
        AntiDetection = true,
        UseVelocity = true,
        ShootFactor = 150,
        ShootProbability = 0.9,
        Delay = 3,
        InitDistance = 600,
        RayLength = 600,
        VisibilityFactor = 0.5,
        VelocityFactor = 0.3
    }
}

-- Debug function
local function debugPrint(...)
    if Config.Debug then
        print("[MVSD Debug]", ...)
    end
end

-- Killall Button
Main:NewButton("Kill All", "Sends multiple shoot events, targeting every player in the server", function()
    local success, result = pcall(kill_all)
    if not success then
        debugPrint("Error in kill_all:", result)
    end
end)

function kill_all()
    -- Equips the first tool it finds in your backpack
    for _, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if v:FindFirstChild("Fire") then
            game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
            break
        end
    end

    -- Sends a shoot event for every player online  
    for _, v in pairs(game.Players:GetPlayers()) do
        task.spawn(function()
            pcall(function()
                local Vec1 = Vector3.new(-186.46624755859375, 49.74998474121094, math.random(-49.323232, 49.488882))
                local Vec2 = Vector3.new(-254.47802734375, 68.99893188476562, math.random(-49.323232, 49.488882))
                local Vec3 = v.Character.LowerTorso
                local Vec4 = Vector3.new(-222.7018585205078, 60.864871978759766, math.random(-49.323232, 49.488882))
                
                game:GetService("ReplicatedStorage").Remotes.Shoot:FireServer(Vec1, Vec2, Vec3, Vec4)
            end)
        end)
    end
end

-- Killall Toggle
Main:NewToggle("Loop Kill All", "The name says it all", function(state)
    while state do
        if Config.Other.CurrentThreads < Config.Other.MaxThreads and state then
            task.spawn(function()
                Config.Other.CurrentThreads = Config.Other.CurrentThreads + 1
                local success, result = pcall(kill_all)
                if not success then
                    debugPrint("Error in kill_all loop:", result)
                end
                Config.Other.CurrentThreads = Config.Other.CurrentThreads - 1
            end)
            task.wait(Config.Other.Delay)
        end
    end
end)

-- The UI to change settings in the Config.Other table
Main:NewSlider("Max Threads", "How many threads should looped functions spawn", 20, 1, function(value)
    Config.Other.MaxThreads = value or Config.Other.MaxThreads
    saveConfig(Config)
end)

Main:NewSlider("Delay", "A variable used by a couple of functions.", 1, 0.001, function(value)
    Config.Other.Delay = value or 0.5
    saveConfig(Config)
end)

-- Hitbox Toggle
Misc:NewToggle("Hitbox", "Increase Range", function(state)
    if state then
        local function onRenderStepped()
            if Config.Hitbox.Disabled then return end
            for _, player in pairs(game:GetService('Players'):GetPlayers()) do
                if player.Name ~= game:GetService('Players').LocalPlayer.Name then
                    pcall(function()
                        local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if rootPart then
                            rootPart.Size = Vector3.new(Config.Hitbox.HeadSize, Config.Hitbox.HeadSize, Config.Hitbox.HeadSize)
                            rootPart.Transparency = 0.7
                            rootPart.BrickColor = BrickColor.new("Really black")
                            rootPart.Material = Enum.Material.Neon
                            rootPart.CanCollide = false
                        end
                    end)
                end
            end
        end

        game:GetService('RunService').RenderStepped:Connect(onRenderStepped)
    else
        Config.Hitbox.Disabled = true
    end
    saveConfig(Config)
end)

Misc:NewSlider("Hitbox Size", "Adjust the hitbox size", 50, 1, function(value)
    Config.Hitbox.HeadSize = value or 15
    saveConfig(Config)
end)

-- ESP Toggle
Misc:NewToggle("ESP", "Player ESP", function(state)
  if state then
    local Settings = {
      Material = Enum.Material.Neon,
      Color = Color3.fromRGB(0, 255, 255),
      Transparency = 0.7
    }
    
    local RunService = game:GetService('RunService')
    local Players = game:GetService('Players')
    local LocalPlayer = Players.LocalPlayer
    local ScreenGui = Instance.new('ScreenGui')
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = game.CoreGui
    
    local ViewportFrame = Instance.new('ViewportFrame')
    ViewportFrame.CurrentCamera = workspace.CurrentCamera
    ViewportFrame.Size = UDim2.new(1, 0, 1, 0)
    ViewportFrame.BackgroundTransparency = 1
    ViewportFrame.ImageTransparency = Settings.Transparency
    ViewportFrame.Parent = ScreenGui

    local Chasms = {}
    local ChasmPool = {}

    local function getChasm()
      local chasm = table.remove(ChasmPool)
      if not chasm then
        chasm = Instance.new('Part')
        chasm.Material = Settings.Material
        chasm.Color = Settings.Color
        chasm.Anchored = true
      end
      return chasm
    end

    local function recycleChasm(chasm)
      chasm.Parent = nil
      table.insert(ChasmPool, chasm)
    end

    local function updateESP()
      for _, chasm in pairs(Chasms) do
        recycleChasm(chasm)
      end
      Chasms = {}

      for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
          local character = player.Character
          if character then
            for _, part in ipairs(character:GetChildren()) do
              if part:IsA('BasePart') then
                local chasm = getChasm()
                chasm.Size = part.Size
                chasm.CFrame = part.CFrame
                chasm.Parent = ViewportFrame
                table.insert(Chasms, chasm)
              end
            end
          end
        end
      end
    end

    local espConnection = RunService.Heartbeat:Connect(updateESP)

    -- Clean up function
    local function cleanUpESP()
      if espConnection then
        espConnection:Disconnect()
      end
      for _, chasm in pairs(Chasms) do
        chasm:Destroy()
      end
      for _, chasm in pairs(ChasmPool) do
        chasm:Destroy()
      end
      Chasms = {}
      ChasmPool = {}
      if ScreenGui then
        ScreenGui:Destroy()
      end
    end

    -- Assign clean up function to be called when toggle is turned off
    return cleanUpESP
  end
end)

-- Xray Toggle
Misc:NewToggle("Xray", "Makes all objects in the workspace transparent", function(state) 
    if state then
        while state do
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v.Parent:FindFirstChildWhichIsA("Humanoid") and not v.Parent.Parent:FindFirstChildWhichIsA("Humanoid") then
                    v.LocalTransparencyModifier = state and 0.5 or 0
                end
            end
            task.wait(5)
        end
    end
end)

-- Invisibility Button
Misc:NewButton("Invisibility", "Makes you invisible", function()
  local Players = game:GetService("Players")
  local Char = Players.LocalPlayer.Character
  local touched = false
  local box = Instance.new("Part")
  box.Anchored = true
  box.CanCollide = true
  box.Size = Vector3.new(10, 1, 10)
  box.Position = Vector3.new(0, 10000, 0)
  box.Parent = workspace

  local function apply()
    local no = Char.HumanoidRootPart:Clone()
    wait(0.25)
    Char.HumanoidRootPart:Destroy()
    no.Parent = Char
    Char:MoveTo(loc)
    touched = false
  end

  local boxTouched = box.Touched:Connect(function(part)
    if part.Parent.Name == Players.LocalPlayer.Name and not touched then
      touched = true
      if Char then
        apply()
      end
    end
  end)

  repeat
    wait()
  until Char

  local cleanUp
  cleanUp = Players.LocalPlayer.CharacterAdded:Connect(function(char)
    boxTouched:Disconnect()
    box:Destroy()
    cleanUp:Disconnect()
  end)

  loc = Char.HumanoidRootPart.Position
  Char:MoveTo(box.Position + Vector3.new(0, 0.5, 0))
end)

-- AimBot Settings
Other:NewToggle("AimBot", "My custom aimbot, made specifically to work in this game", function(state)
    saveConfig(Config)
    if state then
        local success, result = pcall(function()
            loadstring(game:HttpGet("https://wastebin-1-j0561772.deta.app/raw/rcgrylfj"))()
        end)
        if success then
            debugPrint("AimBot loaded successfully")
        else
            debugPrint("Error loading AimBot:", result)
        end
    end
end)

-- The GUI elements for the AimBot options
Other:NewToggle("Auto Aim", "Enable/disable cframe modifications", function(state)
  Config.AimBot.Enabled = state
end)

Other:NewToggle("Team Check", "Enable/disable team check for AimBot", function(state)
  Config.AimBot.TeamCheck = state
end)

Other:NewToggle("Wall Check", "Enable/disable wall check for AimBot", function(state)
  Config.AimBot.WallCheck = state
end)

Other:NewToggle("Damage Check", "Enable/disable damage check for AimBot", function(state)
  Config.AimBot.DamageCheck = state
end)

Other:NewToggle("Auto Shoot", "Enable/disable auto shoot for AimBot", function(state)
  Config.AimBot.AutoShoot = state
end)

Other:NewToggle("Anti Detection", "Enable/disable anti-detection for AimBot", function(state)
  Config.AimBot.AntiDetection = state
end)

Other:NewToggle("Use Velocity", "Enable/disable velocity consideration for AimBot", function(state)
  Config.AimBot.UseVelocity = state
end)

Other:NewSlider("Shoot Factor", "Adjust the shoot factor for AimBot", 10, 1, function(value)
  Config.AimBot.ShootFactor = value
end)

Other:NewSlider("Shoot Probability", "Adjust the shoot probability for AimBot", 1, 0, function(value)
  Config.AimBot.ShootProbability = value
end)

Other:NewSlider("AimBot Delay", "Adjust the delay for AimBot", 10, 0.1, function(value)
  Config.AimBot.Delay = value
end)

Other:NewSlider("Init Distance", "Adjust the initial distance for AimBot", 1000, 100, function(value)
  Config.AimBot.InitDistance = value
end)

Other:NewSlider("Ray Length", "Adjust the ray length for AimBot", 1000, 100, function(value)
  Config.AimBot.RayLength = value
end)

-- LightSpy Loader
Other:NewButton("Load LightSpy", "BAC compatible remote event/function spy", function() 
  loadstring(game:HttpGet("https://wastebin-1-j0561772.deta.app/raw/lpzekmyj"))()
end)

-- Debug mode toggle
Other:NewToggle("Debug Mode", "Enable/disable debug prints", function(state)
    Config.Debug = state
    debugPrint("Debug mode set to", state)
    saveConfig(Config)
end)

-- Add a button to manually save the configuration
Other:NewButton("Save Config", "Manually save the current configuration", function()
    saveConfig(Config)
    print("Configuration saved successfully")
end)
