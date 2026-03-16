-- ================= SERVICES =================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local lp = Players.LocalPlayer

-- ================= MOVEMENT VALUES =================

local Values = {

    -- LEFT SIDE
    L1 = Vector3.new(-475.58, -5.40, 93.80),
    L2 = Vector3.new(-484.15, -4.42, 95.80),

    -- RIGHT SIDE
    R1 = Vector3.new(-475.16, -6.52, 27.70),
    R2 = Vector3.new(-484.04, -5.09, 25.15),

    -- SPEEDS
    SpeedToL1 = 57,
    LifeL1toL2 = 43,
    ReturnSpeedL = 29,

    SpeedToR1 = 57,
    RightR1toR2 = 43,
    ReturnSpeedR = 29,
}

-- ================= GET CHARACTER =================

local function getHRP()
    local char = lp.Character
    if not char then return end
    return char:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local char = lp.Character
    if not char then return end
    return char:FindFirstChildOfClass("Humanoid")
end

-- ================= AUTO LIFE =================

local autoLifeConnection

local function startAutoLife()

    if autoLifeConnection then
        autoLifeConnection:Disconnect()
    end

    autoLifeConnection = RunService.Heartbeat:Connect(function()

        local hrp = getHRP()
        local hum = getHum()
        if not hrp or not hum then return end

        local target = Values.L1
        local dir = (target - hrp.Position)

        if dir.Magnitude > 3 then

            hum.WalkSpeed = Values.SpeedToL1
            hrp.AssemblyLinearVelocity = dir.Unit * Values.SpeedToL1

        else

            local dir2 = (Values.L2 - hrp.Position)

            if dir2.Magnitude > 3 then

                hum.WalkSpeed = Values.LifeL1toL2
                hrp.AssemblyLinearVelocity = dir2.Unit * Values.LifeL1toL2

            else

                hum.WalkSpeed = Values.ReturnSpeedL
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, -Values.ReturnSpeedL)

            end
        end

    end)

end

local function stopAutoLife()
    if autoLifeConnection then
        autoLifeConnection:Disconnect()
        autoLifeConnection = nil
    end
end

-- ================= AUTO RIGHT =================

local autoRightConnection

local function startAutoRight()

    if autoRightConnection then
        autoRightConnection:Disconnect()
    end

    autoRightConnection = RunService.Heartbeat:Connect(function()

        local hrp = getHRP()
        local hum = getHum()
        if not hrp or not hum then return end

        local target = Values.R1
        local dir = (target - hrp.Position)

        if dir.Magnitude > 3 then

            hum.WalkSpeed = Values.SpeedToR1
            hrp.AssemblyLinearVelocity = dir.Unit * Values.SpeedToR1

        else

            local dir2 = (Values.R2 - hrp.Position)

            if dir2.Magnitude > 3 then

                hum.WalkSpeed = Values.RightR1toR2
                hrp.AssemblyLinearVelocity = dir2.Unit * Values.RightR1toR2

            else

                hum.WalkSpeed = Values.ReturnSpeedR
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, Values.ReturnSpeedR)

            end
        end

    end)

end

local function stopAutoRight()
    if autoRightConnection then
        autoRightConnection:Disconnect()
        autoRightConnection = nil
    end
end

-- ================= GUI =================

local PlayerGui = lp:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "keek duel"
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,250,0,300)
Main.Position = UDim2.new(0.5,-125,0.5,-150)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundColor3 = Color3.fromRGB(40,40,40)
Title.Text = "keek duel"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 18
Title.Parent = Main

-- ================= DRAG =================

local dragging
local dragInput
local dragStart
local startPos

Title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = Main.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

Title.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		Main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- ================= SCROLL FRAME =================

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1,0,1,-30)
Scroll.Position = UDim2.new(0,0,0,30)
Scroll.CanvasSize = UDim2.new(0,0,0,400)
Scroll.ScrollBarThickness = 6
Scroll.BackgroundTransparency = 1
Scroll.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0,5)
Layout.Parent = Scroll

-- ================= BUTTON FUNCTION =================

local function createButton(text,callback)

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1,-10,0,40)
	Button.BackgroundColor3 = Color3.fromRGB(60,60,60)
	Button.Text = text
	Button.TextColor3 = Color3.new(1,1,1)
	Button.TextSize = 16
	Button.Parent = Scroll

	Button.MouseButton1Click:Connect(callback)

end

-- ================= BUTTONS =================

createButton("Auto Life", function()
	startAutoLife()
end)

createButton("Stop Auto Life", function()
	stopAutoLife()
end)

createButton("Auto Right", function()
	startAutoRight()
end)

createButton("Stop Auto Right", function()
	stopAutoRight()
end)
