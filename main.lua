--// SERVIÇOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local debrisFolder = workspace:WaitForChild("Debris")

--============================
-- CONFIG
--============================

local MAX_DISTANCE = 400

local espSettings = {
	Enemy = false,
	Item = false,
	Trap = false
}

local fullbrightEnabled = false
local tracked = {}

-- SALVAR LIGHT ORIGINAL
local originalLighting = {
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	FogStart = Lighting.FogStart,
	FogEnd = Lighting.FogEnd,
	GlobalShadows = Lighting.GlobalShadows,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient
}

--============================
-- GUI
--============================

local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local toggleMain = Instance.new("TextButton")
toggleMain.Size = UDim2.new(0,140,0,45)
toggleMain.Position = UDim2.new(0.75,0,0.05,0)
toggleMain.BackgroundColor3 = Color3.fromRGB(20,20,20)
toggleMain.Text = "⚡ ESP HUB"
toggleMain.TextColor3 = Color3.new(1,1,1)
toggleMain.Font = Enum.Font.GothamBold
toggleMain.TextSize = 14
toggleMain.Parent = gui
Instance.new("UICorner", toggleMain).CornerRadius = UDim.new(0,12)

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0,230,0,250)
mainFrame.Position = UDim2.new(0.7,0,0.13,0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15,15,15)
mainFrame.Visible = false
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,16)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(0,170,255)
stroke.Thickness = 1.5

local layout = Instance.new("UIListLayout", mainFrame)
layout.Padding = UDim.new(0,10)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center

--============================
-- DRAG
--============================

local dragging, dragInput, dragStart, startPos

local function enableDrag(frame)
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

enableDrag(mainFrame)
enableDrag(toggleMain)

--============================
-- BOTÕES
--============================

local function createToggle(name, typeName, color, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0,190,0,40)
	button.BackgroundColor3 = Color3.fromRGB(30,30,30)
	button.TextColor3 = Color3.new(1,1,1)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 13
	button.Text = name.." : OFF"
	button.Parent = mainFrame
	Instance.new("UICorner", button).CornerRadius = UDim.new(0,10)

	button.MouseButton1Click:Connect(function()

		if callback then
			fullbrightEnabled = not fullbrightEnabled
			callback(fullbrightEnabled)
			button.Text = name.." : "..(fullbrightEnabled and "ON" or "OFF")
			button.BackgroundColor3 = fullbrightEnabled and color or Color3.fromRGB(30,30,30)
		else
			espSettings[typeName] = not espSettings[typeName]
			button.Text = name.." : "..(espSettings[typeName] and "ON" or "OFF")
			button.BackgroundColor3 = espSettings[typeName] and color or Color3.fromRGB(30,30,30)
		end

	end)
end

createToggle("👹 ESP INIMIGOS","Enemy",Color3.fromRGB(200,0,0))
createToggle("📦 ESP ITENS","Item",Color3.fromRGB(0,120,255))
createToggle("⚠ ESP ARMADILHAS","Trap",Color3.fromRGB(255,140,0))

-- FULLBRIGHT + NOFOG
createToggle("💡 FULLBRIGHT + NOFOG",nil,Color3.fromRGB(255,200,0),function(state)
	if state then
		Lighting.Brightness = 5
		Lighting.ClockTime = 14
		Lighting.GlobalShadows = false
		Lighting.Ambient = Color3.new(1,1,1)
		Lighting.OutdoorAmbient = Color3.new(1,1,1)
		Lighting.FogStart = 0
		Lighting.FogEnd = 1000000
	else
		for prop,value in pairs(originalLighting) do
			Lighting[prop] = value
		end
	end
end)

toggleMain.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

--============================
-- REMOVER EFEITOS VISUAIS
--============================

local function removeEffects()
	for _,v in pairs(Lighting:GetChildren()) do
		if v:IsA("Atmosphere")
		or v:IsA("BloomEffect")
		or v:IsA("ColorCorrectionEffect")
		or v:IsA("SunRaysEffect")
		or v:IsA("BlurEffect")
		or v:IsA("DepthOfFieldEffect") then
			v:Destroy()
		end
	end
end

-- FORÇA CONTÍNUA
RunService.RenderStepped:Connect(function()
	if fullbrightEnabled then
		Lighting.FogStart = 0
		Lighting.FogEnd = 1000000
		removeEffects()
	end
end)

--============================
-- ESP
--============================

local function getType(obj)
	if obj:FindFirstChild("Humanoid") then
		return "Enemy"
	end

	local name = string.lower(obj.Name)
	if string.find(name,"trap") or string.find(name,"armadilha") or string.find(name,"spike") then
		return "Trap"
	end

	return "Item"
end

local function inDistance(obj)
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then
		return false
	end

	local root = char.HumanoidRootPart
	local part = obj:FindFirstChild("HumanoidRootPart")
		or obj:FindFirstChild("Head")
		or obj:FindFirstChildWhichIsA("BasePart")

	if not part then return false end

	return (root.Position - part.Position).Magnitude <= MAX_DISTANCE
end

local function createESP(obj)
	if tracked[obj] then return end

	local typeName = getType(obj)
	local color = typeName=="Enemy" and Color3.fromRGB(255,0,0)
		or typeName=="Item" and Color3.fromRGB(0,170,255)
		or Color3.fromRGB(255,140,0)

	local highlight = Instance.new("Highlight")
	highlight.FillColor = color
	highlight.FillTransparency = 0.5
	highlight.OutlineColor = Color3.new(1,1,1)
	highlight.Parent = obj

	local part = obj:FindFirstChild("Head") or obj:FindFirstChildWhichIsA("BasePart")
	if not part then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0,180,0,40)
	billboard.StudsOffset = Vector3.new(0,3,0)
	billboard.AlwaysOnTop = true
	billboard.Parent = part

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1,0,1,0)
	text.BackgroundTransparency = 1
	text.TextColor3 = color
	text.Font = Enum.Font.GothamBold
	text.TextSize = 13
	text.TextStrokeTransparency = 0.5
	text.TextStrokeColor3 = Color3.new(0,0,0)
	text.Parent = billboard

	if typeName=="Enemy" then
		local humanoid = obj:FindFirstChild("Humanoid")
		local function update()
			text.Text = obj.Name.." | HP: "..math.floor(humanoid.Health)
		end
		update()
		humanoid.HealthChanged:Connect(update)
	else
		text.Text = obj.Name
	end

	tracked[obj] = {highlight,billboard}
end

local function removeESP(obj)
	if tracked[obj] then
		for _,v in pairs(tracked[obj]) do
			v:Destroy()
		end
		tracked[obj] = nil
	end
end

RunService.Heartbeat:Connect(function()
	for _,obj in pairs(debrisFolder:GetChildren()) do
		local typeName = getType(obj)
		if espSettings[typeName] and inDistance(obj) then
			createESP(obj)
		else
			removeESP(obj)
		end
	end
end)
