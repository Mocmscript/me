local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Tcap hub", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

local Tab = Window:MakeTab({
	Name = "公告",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

Tab:AddLabel("by huh")
Tab:AddLabel("此脚本完全免费")
Tab:AddLabel("开放源码")
Tab:AddLabel("之后的脚本会加密")
Tab:AddLabel("不定时更新")
Tab:AddLabel("部分脚本是由Spy脚本抓取而制作")
Tab:AddLabel("包括外国脚本")




end
OrionLib:Init()