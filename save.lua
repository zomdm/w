if not _G.ver then
	_G.ver = 1
else
	_G.ver+=1
end
print()
local ver = _G.ver
print("Version: " , ver)
local player = game.Players.LocalPlayer
local char = player.Character
local humRP = char:WaitForChild("HumanoidRootPart")

local fold = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.6.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("UnitService"):WaitForChild("RF")

local placeUnit = fold:WaitForChild("PlaceUnit")
local upgradeUnit = fold:WaitForChild("UpgradeUnit")
local getMultiplier = fold:WaitForChild("GetMultiplier")

local rec = true
local original

local logs = {}

local gui = Instance.new("ScreenGui")
local main = Instance.new("Frame")
local topbar = Instance.new("Frame")
local minimize = Instance.new("TextButton")
local cls = Instance.new("TextButton")
local saveButton = Instance.new("TextButton")
local loadButton = Instance.new("TextButton")

gui.ResetOnSpawn = false
gui.DisplayOrder = 999999999
gui.Parent = player:WaitForChild("PlayerGui")
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

main.Name = "Main"	
main.Parent = gui
main.Position = UDim2.new(0.1, 0, 0, 0)
main.BorderSizePixel = 0
main.BackgroundColor3 = Color3.new(0.219608, 0.219608, 0.219608)
main.Size = UDim2.new(0.5,0,0.5,0)

topbar.Name = "topbar"
topbar.Parent = main
topbar.BorderSizePixel = 0
topbar.BackgroundColor3 = Color3.new(0.121569, 0.121569, 0.121569)	
topbar.Size = UDim2.new(1, 0, 0, 18)

minimize.Name = "minimize"
minimize.Parent = topbar
minimize.BackgroundColor3 = Color3.new(0, 0.105882, 0.792157)
minimize.BorderSizePixel = 0
minimize.Position = UDim2.new(0, 0, 0, 0)
minimize.Size = UDim2.new(0, 18, 0, 18)
minimize.Font = Enum.Font.SourceSans
minimize.Text = ""
minimize.TextColor3 = Color3.new(0, 0, 0)
minimize.TextSize = 14
minimize.MouseButton1Down:Connect(function() 
	for i, v in gui:GetDescendants() do 
		v.Visible = not v.Visible 
	end 
	main.Visible = true
	main.BackgroundTransparency = 1 - main.BackgroundTransparency
	minimize.Visible = true 
end)

cls.Name = "Cls"
cls.Parent = main
cls.Size = UDim2.new(0, 18, 0, 18)
cls.Position = UDim2.new(1, -18, 0, 0)
cls.Font = Enum.Font.SourceSans
cls.BackgroundColor3 = Color3.new(1, 0.12549, 0.141176)
cls.MouseButton1Down:Connect(function()	gui:Destroy() end)

saveButton.Position = UDim2.new(0, 0, 0.1, 0)
saveButton.Size = UDim2.new(0.5, 0, 0.2, 0)
saveButton.BackgroundColor3 = Color3.new(0.203922, 1, 0.270588)
saveButton.Text = "Save"
saveButton.TextScaled = true
saveButton.Parent = main

loadButton.Position = UDim2.new(0.5, 0, 0.1, 0)
loadButton.Size = UDim2.new(0.5 ,0, 0.2, 0)
loadButton.Text = "Load"
loadButton.TextScaled = true
loadButton.BackgroundColor3 = Color3.new(1, 0.129412, 0.145098)
loadButton.Parent = main


local nameToFunc = {
	["PlaceUnit"] = placeUnit,
	["UpgradeUnit"] = upgradeUnit,
	["GetMultiplier"] = getMultiplier
}

local function start() 
	for i, v in logs do
		if _G.ver ~= ver then break end
		local t = v[1]
		local func = nameToFunc[t]
		local args = v[2]
		if not func then continue end
		local success = func:InvokeServer(unpack(args))
		while not success and _G.ver == ver do
			task.wait(1)
			success = func:InvokeServer(unpack(args))
		end
	end
end

local function startRec()
	rec = true
end

function saveRemote(name, ...)
	local args = { ... }
	logs[#logs + 1] = {
		[1] = name,
		[2] = table.unpack(args)
	}
end
local newnamecall = newcclosure(function(remote, ...)
	if typeof(remote) == "Instance" and rec and _G.ver == ver then
		local args = { ... }
		local methodName = getnamecallmethod()
		local validInstance, remoteName = pcall(function()
			return remote.Name
		end)
		if validInstance and (methodName == "InvokeServer" or methodName == "invokeServer") and remoteName == "PlaceUnit" or remoteName == "UpgradeUnit" then
			local funcInfo = {}
			local calling
			funcInfo = debug.getinfo(3) or funcInfo
			calling = false and getcallingscript() or nil 	
			local namecallThread = coroutine.running()
			local args = { ... }
			task.defer(function()
				local returnValue
				setnamecallmethod(methodName)
				returnValue = { original(remote, unpack(args)) }
				if remoteName == "UpgradeUnit" and next(returnValue) ~= nil and returnValue[1] == false then return end
				saveRemote(remoteName, table.unpack(args))
			end)
		end
	end
	return original(remote, ...)
end, original)
local oldNamecall = hookmetamethod(game, "__namecall", newnamecall)
original = original or function(...)
	return oldNamecall(...)
end

task.spawn(function()
	while task.wait(10) do
		if _G.ver ~= ver then gui:Destroy() break end
		if next(logs) == nil or _G.ver ~= ver then continue end
		for i, v in logs do
			print(i, v)
		end
	end
end)
