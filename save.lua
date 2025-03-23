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
local gsFold = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.6.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("GameService"):WaitForChild("RF")
local waveFold = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.6.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("WaveService"):WaitForChild("RF")

local setGameMode = gsFold:WaitForChild("Vote")
local autoSkip = waveFold:WaitForChild("ToggleAutoSkip")
local setGameSpeed = waveFold:WaitForChild("SetGameSpeed")
local placeUnit = fold:WaitForChild("PlaceUnit")
local upgradeUnit = fold:WaitForChild("UpgradeUnit")	
local getMultiplier = fold:WaitForChild("GetMultiplier")

local waitTime = 5 -- Time between the InvokeServers (if not passed)
local rec = true
local gameSpeed = 1 -- GameSpeed = 1 + gameSpeed
local gameMode = 1 -- 1 = Easy, 2 = Normal etc.

setGameMode:InvokeServer(gameMode)
autoSkip:InvokeServer()
setGameSpeed:InvokeServer(gameSpeed)

local httpService = game:GetService("HttpService")

local logs = {}

local gui = Instance.new("ScreenGui")
local main = Instance.new("Frame")
local topbar = Instance.new("Frame")
local minimize = Instance.new("TextButton")
local cls = Instance.new("TextButton")
local saveButton = Instance.new("TextButton")
local loadButton = Instance.new("TextButton")
local stopRecording = Instance.new("TextButton")
local saveFileName = Instance.new("TextBox")
local choiceFile = Instance.new("TextButton")
local savedList = Instance.new("ScrollingFrame")
local uiList = Instance.new("UIListLayout")
local uiCorner = Instance.new("UICorner")

local nameToFunc = {
	["PlaceUnit"] = placeUnit,
	["UpgradeUnit"] = upgradeUnit,
	["GetMultiplier"] = getMultiplier
}

local original

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

uiCorner.CornerRadius = UDim.new(0.05, 0.05)
uiCorner.Parent = main

topbar.Name = "topbar"
topbar.Parent = main
topbar.BorderSizePixel = 0
topbar.BackgroundColor3 = Color3.new(0.121569, 0.121569, 0.121569)	
topbar.Size = UDim2.new(1, 0, 0, 18)

minimize.Name = "minimize"
minimize.Parent = gui
minimize.BackgroundColor3 = Color3.new(0, 0.105882, 0.792157)
minimize.BorderSizePixel = 0
minimize.Position = UDim2.new(0.1, 0, 0, 0)
minimize.Size = UDim2.new(0, 18, 0, 18)
minimize.Font = Enum.Font.SourceSans
minimize.Text = ""
minimize.TextColor3 = Color3.new(0, 0, 0)
minimize.TextSize = 14
minimize.MouseButton1Down:Connect(function() 
	main.Visible = not main.Visible
end)
lbc = uiCorner:Clone()
lbc.CornerRadius = UDim.new(0.1, 0.1, 0.1)
lbc.Parent = minimize

cls.Name = "Cls"
cls.Parent = main
cls.Size = UDim2.new(0, 18, 0, 18)
cls.Position = UDim2.new(1, -18, 0, 0)
cls.Font = Enum.Font.SourceSans
cls.BackgroundColor3 = Color3.new(1, 0.12549, 0.141176)
cls.Text = "X"
cls.MouseButton1Down:Connect(function()	gui:Destroy() end)
lbc = uiCorner:Clone()
lbc.CornerRadius = UDim.new(0.1, 0.1, 0.1)
lbc.Parent = cls

saveButton.Position = UDim2.new(0, 0, 0.05, 0)
saveButton.Size = UDim2.new(0.5, 0, 0.1, 0)
saveButton.BackgroundColor3 = Color3.new(0.0941176, 0.0941176, 0.0941176)
saveButton.Text = "Save"
saveButton.TextColor3 = Color3.new(1, 1, 1)
saveButton.TextScaled = true
saveButton.BorderSizePixel = 0
saveButton.Parent = main

loadButton.Position = UDim2.new(0.5, 0, 0.05, 0)
loadButton.Size = UDim2.new(0.5 ,0, 0.1, 0)
loadButton.Text = "Load"
loadButton.TextScaled = true
loadButton.TextColor3 = Color3.new(1, 1, 1)
loadButton.BorderSizePixel = 0
loadButton.BackgroundColor3 = Color3.new(0.0941176, 0.0941176, 0.0941176)
loadButton.Parent = main

saveFileName.Text = "FileName"
saveFileName.TextScaled = true
saveFileName.BorderSizePixel = 0
saveFileName.Size = UDim2.new(0.5, 0, 0.1, 0)
saveFileName.Position = UDim2.new(0, 0, 0.15, 0)
saveFileName.BackgroundColor3 = Color3.new(0.0941176, 0.0941176, 0.0941176)
saveFileName.Font = Enum.Font.SourceSans
saveFileName.TextSize = 20
saveFileName.Parent = main

stopRecording.Text = "Stop recording"
stopRecording.BackgroundColor3 = Color3.new(1, 0, 0)
stopRecording.TextScaled = true
stopRecording.BorderSizePixel = 0
stopRecording.Size = UDim2.new(0.5, 0, 0.1, 0)
stopRecording.Position = UDim2.new(0, 0, 0.25, 0)
stopRecording.Visible = false
stopRecording.Parent = main

savedList.Size = UDim2.new(0.5, 0, 0.8, 0)
savedList.BorderSizePixel = 0
savedList.Position = UDim2.new(0.5, 0, 0.15, 0)
savedList.BackgroundTransparency = 0.7
savedList.Parent = main
lbc = uiCorner:Clone()
lbc.CornerRadius = UDim.new(0.5,0.5)
lbc.Parent = savedList

uiList.Parent = savedList

for i, v in gui:GetDescendants() do
	if v:IsA("Frame") or v:IsA("TextButton") then
		uiCorner:Clone().Parent = v
	end
end

saveButton.MouseButton1Down:Connect(function()
	stopRecording.Visible = true
	rec = true
end)

local function printTable(t, add)
	if not add then
		add = 0
	end
	local tab = ""
	for i = 1, add, 1 do
		tab..='	'
	end
	print(tab..'{')
	for i, v in t do
		if type(v) == "table" then
			print(tab,i)
			printTable(v, add + 1)
		else 
			print(tab,i,v)
		end
	end
	print(tab..'}')
end

local function start(s) 
	local log = httpService:JSONDecode(readfile(s))
	for i, v in log do
		if _G.ver ~= ver then break end
		local t = v[1]
		local func = nameToFunc[t]
		local args = v[2]
		if t == "PlaceUnit" then
			local pos = args[2]["Position"]
			local newpos = Vector3.new(pos["X"], pos["Y"], pos["Z"])
			args[2] = {["Position"] = newpos, ["Rotation"] = args[2].Rotation}
		end
		if not func then continue end
		local success = func:InvokeServer(unpack(args))
		while not success and _G.ver == ver do	
			task.wait(waitTime)
			success = func:InvokeServer(unpack(args))
		end
	end
end

local function clearList()
	for i, v in savedList:GetChildren() do
		if v:IsA("TextButton") then 
			v :Destroy()
		end
	end
end

loadButton.MouseButton1Down:Connect(function()
	clearList()
	for i, v in listfiles("savedTTD") do
		local log = readfile(v)
		local button = Instance.new("TextButton")
		local name = string.sub(v, 10)
		button.Name = name
		button.Text = name
		button.BackgroundColor3 = Color3.new(0.0470588, 0.0705882, 0.403922)
		button.Size = UDim2.new(1, 0, 0.1, 0)
		button.Parent = savedList
		uiCorner:Clone().Parent = button
		button.MouseButton1Down:Connect(function()
			clearList()
			savedList.Visible = false
			start(v)
		end)
	end
end)

stopRecording.MouseButton1Down:Connect(function()
	if not isfile("savedTTD") then
		makefolder("savedTTD")
	end
	rec = false
	stopRecording.Visible = false
	local fileName = saveFileName.Text
	local str = httpService:JSONEncode(logs)
	writefile("savedTTD/"..fileName..".json",str)
end)

local function startRec()
	rec = true
end

function saveRemote(name, args)
	if name == "PlaceUnit" then
		local pos = args[2]["Position"]
		local newpos = {["X"] = pos.X, ["Y"] = pos.Y, ["Z"] = pos.Z}
		args[2]["Position"] = newpos
	end
	logs[#logs + 1] = {
		[1] = name,
		[2] = args
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
				saveRemote(remoteName, args)
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
