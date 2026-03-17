-- Keek Duel GUI (Red Outline)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Remove existing GUI if exists
local existing = game:GetService("CoreGui"):FindFirstChild("KeekDuel")
if existing then
    existing:Destroy()
end

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KeekDuel"
screenGui.Parent = game:GetService("CoreGui")

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Parent = screenGui

-- Red Outline
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 0, 0)
stroke.Thickness = 3
stroke.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Keek Duel"
title.TextColor3 = Color3.fromRGB(255, 0, 0)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- Button Example
local button = Instance.new("TextButton")
button.Size = UDim2.new(0.8, 0, 0, 40)
button.Position = UDim2.new(0.1, 0, 0.5, -20)
button.Text = "Click Me"
button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
button.TextColor3 = Color3.fromRGB(255, 0, 0)
button.Parent = frame

local buttonStroke = Instance.new("UIStroke")
buttonStroke.Color = Color3.fromRGB(255, 0, 0)
buttonStroke.Thickness = 2
buttonStroke.Parent = button

print("Keek Duel GUI Loaded!")
