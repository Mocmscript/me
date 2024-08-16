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
local window = kavoUi.CreateLib("ERT MVSD", "XD")

-- Tabs
local MainTab = window:NewTab("对决")
local MiscTab = window:NewTab("杂项")
local OtherTab = window:NewTab("其他")
local CreditsTab = window:NewTab("确实")

-- Sections
local Main = MainTab:NewSection("主要")
local Misc = MiscTab:NewSection("杂项")
local Other = OtherTab:NewSection("其他")
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
Main:NewButton("击杀所有", "仅限当前对局", function()
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
Main:NewToggle("循环击杀所有(无法关闭谨慎)", "仅限当前对局l", function(state)
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
Main:NewSlider("最大线程数", "循环函数应该产生多少个线程", 20, 1, function(value)
    Config.Other.MaxThreads = value or Config.Other.MaxThreads
    saveConfig(Config)
end)

Main:NewSlider("延迟", "A", 1, 0.001, function(value)
    Config.Other.Delay = value or 0.5
    saveConfig(Config)
end)

-- Hitbox Toggle
Misc:NewToggle("攻击碰撞箱", "射击或攻击范围", function(state)
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

Misc:NewSlider("攻击碰撞箱大小", "调整攻击碰撞箱大小", 50, 1, function(value)
    Config.Hitbox.HeadSize = value or 15
    saveConfig(Config)
end)

-- ESP Toggle
Misc:NewToggle("ESP", "透视玩家", function(state)
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
Misc:NewToggle("X光", "透视墙体", function(state) 
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
Other:NewToggle("自动瞄准(无法使用)", "E", function(state)
  Config.AimBot.Enabled = state
end)

Other:NewToggle("团队检测", "运用于瞄准机器人", function(state)
  Config.AimBot.TeamCheck = state
end)

Other:NewToggle("墙壁检测", "启用/禁用瞄准机器人的墙壁检查", function(state)
  Config.AimBot.WallCheck = state
end)

Other:NewToggle("伤害检测", "启用/禁用瞄准机器人的伤害检查", function(state)
  Config.AimBot.DamageCheck = state
end)

Other:NewToggle("自动射击", "启用/禁用瞄准机器人的自动射击", function(state)
  Config.AimBot.AutoShoot = state
end)

Other:NewToggle("反检测", "启用/禁用瞄准机器人的反检测", function(state)
  Config.AimBot.AntiDetection = state
end)

Other:NewToggle("使用速度", "启用/禁用瞄准机器人的速度注意事项", function(state)
  Config.AimBot.UseVelocity = state
end)

Other:NewSlider("射击因子", "调整瞄准机器人的射击因子", 10, 1, function(value)
  Config.AimBot.ShootFactor = value
end)

Other:NewSlider("射击概率", "调整瞄准机器人的射击概率", 1, 0, function(value)
  Config.AimBot.ShootProbability = value
end)

Other:NewSlider("瞄准机器人延迟", "调整瞄准机器人延迟", 10, 0.1, function(value)
  Config.AimBot.Delay = value
end)

Other:NewSlider("初始化距离", "调整瞄准机器人的初始距离", 1000, 100, function(value)
  Config.AimBot.InitDistance = value
end)

Other:NewSlider("射线长度", "调整瞄准机器人的光线长度", 1000, 100, function(value)
  Config.AimBot.RayLength = value
end)

-- LightSpy Loader
Other:NewButton("ESP", "启用ERT透视", function() 
  loadstring(game:HttpGet("https://raw.githubusercontent.com/Mocmscript/esp/main/7.lua"))()
end)

-- Debug mode toggle
Other:NewToggle("开发者模式", "启用/禁用开发者模式打印", function(state)
    Config.Debug = state
    debugPrint("Debug mode set to", state)
    saveConfig(Config)
end)

-- Add a button to manually save the configuration
Other:NewButton("保存配置", "保存当前配置", function()
    saveConfig(Config)
    print("Configuration saved successfully")
end)
