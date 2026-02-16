--============================
-- 🔐 SISTEMA DE KEY (MULTI KEY)
--============================

local VALID_KEYS = {
	["dev1090"] = true,
	["Gutovoador"] = true
}

local authenticated = false

local keyGui = Instance.new("ScreenGui")
keyGui.ResetOnSpawn = false
keyGui.Parent = player:WaitForChild("PlayerGui")

local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0,320,0,180)
keyFrame.Position = UDim2.new(0.5,-160,0.5,-90)
keyFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
keyFrame.Parent = keyGui
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0,15)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "🔐 SISTEMA DE KEY"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = keyFrame

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(0.8,0,0,40)
keyBox.Position = UDim2.new(0.1,0,0.4,0)
keyBox.PlaceholderText = "Digite a Key"
keyBox.Text = ""
keyBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
keyBox.TextColor3 = Color3.new(1,1,1)
keyBox.Parent = keyFrame
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0,8)

local verify = Instance.new("TextButton")
verify.Size = UDim2.new(0.8,0,0,40)
verify.Position = UDim2.new(0.1,0,0.7,0)
verify.Text = "VERIFICAR"
verify.BackgroundColor3 = Color3.fromRGB(0,170,255)
verify.TextColor3 = Color3.new(1,1,1)
verify.Font = Enum.Font.GothamBold
verify.TextSize = 14
verify.Parent = keyFrame
Instance.new("UICorner", verify).CornerRadius = UDim.new(0,8)

verify.MouseButton1Click:Connect(function()
	if VALID_KEYS[keyBox.Text] then
		authenticated = true
		keyGui:Destroy()
	else
		keyBox.Text = "Key incorreta!"
		task.wait(1)
		keyBox.Text = ""
	end
end)

repeat task.wait() until authenticated
