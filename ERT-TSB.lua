
local player = game.Players.LocalPlayer

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({Name = "Strongest Battleground Script", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

local Tab = Window:MakeTab({

	Name = "主要",

	Icon = "rbxassetid://4483345998",

	PremiumOnly = false

})

--[[

Name = <string> - The name of the tab.

Icon = <string> - The icon of the tab.

PremiumOnly = <bool> - Makes the tab accessible to Sirus Premium users only.

]]

local Section = Tab:AddSection({

	Name = "部分"

})

--[[

Name = <string> - The name of the section.

]]

OrionLib:MakeNotification({

	Name = "不忘初心",

	Content = "DD",

	Image = "rbxassetid://4483345998",

	Time = 15

})

--[[

Title = <string> - The title of the notification.

Content = <string> - The content of the notification.

Image = <string> - The icon of the notification.

Time = <number> - The duration of the notfication.

]]

Tab:AddButton({

	Name = "无眩晕",

	Callback = function()

      		function isNumber(str)

  if tonumber(str) ~= nil or str == 'inf' then

    return true

  end

end

local tspeed = 0.3

local hb = game:GetService("RunService").Heartbeat

local tpwalking = true

local player = game:GetService("Players")

local lplr = player.LocalPlayer

local chr = lplr.Character

local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")

while tpwalking and hb:Wait() and chr and hum and hum.Parent do

  if hum.MoveDirection.Magnitude > 0 then

    if tspeed and isNumber(tspeed) then

      chr:TranslateBy(hum.MoveDirection * tonumber(tspeed))

    else

      chr:TranslateBy(hum.MoveDirection)

    end

  end

end

  	end    

})

Tab:AddButton({

	Name = "攻击范围(仅限拳击)",

	Callback = function()

      		print("Reach Value 120")

  	end    

})

Tab:AddButton({

	Name = "防连击",

	Callback = function()

      		print("Anti stuck in combos of others")

  	end    

})

Tab:AddButton({

	Name = "速度(多次点击可叠加)",

	Callback = function()

      		function isNumber(str)

  if tonumber(str) ~= nil or str == 'inf' then

    return true

  end

end

local tspeed = 1

local hb = game:GetService("RunService").Heartbeat

local tpwalking = true

local player = game:GetService("Players")

local lplr = player.LocalPlayer

local chr = lplr.Character

local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")

while tpwalking and hb:Wait() and chr and hum and hum.Parent do

  if hum.MoveDirection.Magnitude > 0 then

    if tspeed and isNumber(tspeed) then

      chr:TranslateBy(hum.MoveDirection * tonumber(tspeed))

    else

      chr:TranslateBy(hum.MoveDirection)

    end

  end

end

  	end    

})

--[[

Name = <string> - The name of the button.

Callback = <function> - The function of the button.

]]

Tab:AddButton({

	Name = "透视",

	Callback = function()

      		local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local function createBox()

    local box = Instance.new("BoxHandleAdornment")

    box.Size = Vector3.new(5, 5, 2)

    box.Color3 = Color3.new(1,0,0)

    box.Transparency = 0.1

    box.ZIndex = 5

    return box

end

local function updateEsp(player, box)

    local character = player.Character

    if character and character:FindFirstChild("HumanoidRootPart") then

        box.Visible = true

        box.Adornee = character.HumanoidRootPart

        box.Parent = character.HumanoidRootPart

    else

        box.Visible = false

        box.Adornee = nil

        box.Parent = nil

    end

end

local function onPlayerAdded(player)

    local box = createBox()

    updateEsp(player, box)

    player.CharacterAdded:Connect(function()

        updateEsp(player, box)

    end)

    player.CharacterRemoving:Connect(function()

        updateEsp(player, box)

    end)

end

for _, player in ipairs(Players:GetPlayers()) do

    onPlayerAdded(player)

end

Players.PlayerAdded:Connect(function(player)

    onPlayerAdded(player)

end)

RunService.RenderStepped:Connect(function()

    for _, player in ipairs(Players:GetPlayers()) do

        updateEsp(player)

    end

end)

  	end    

})

Tab:AddButton({

	Name = "虚空击杀(需要使用饿狼)",

	Callback = function()
    
loadstring(game:HttpGet("https://pastefy.app/afHQ7oyj/raw"))()

    end    

})

--[[

Name = <string> - The name of the button.

Callback = <function> - The function of the button.

]]

local Tab = Window:MakeTab({

	Name = "Concernant",

	Icon = "rbxassetid://4483345998",

	PremiumOnly = false

})

Tab:AddButton({

	Name = "by huh",

	Callback = function()

      		print("button pressed")

  	end    

})

Tab:AddButton({

	Name = "Orion Lib",

	Callback = function()

      		print("button pressed")

  	end    

})

Tab:AddButton({

	Name = "Destruction et I",

	Callback = function()

      		OrionLib:Destroy()

  	end    

})