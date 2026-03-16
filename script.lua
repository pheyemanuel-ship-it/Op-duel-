repeat task.wait() until game:IsLoaded()

-- ================= SERVICES =================
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

-- ================= THEME =================
local THEME = {
    bg = Color3.fromRGB(22,22,22),
    header = Color3.fromRGB(28,28,28),
    row = Color3.fromRGB(30,30,30),
    toggleOff = Color3.fromRGB(60,60,60),
    toggleBall = Color3.fromRGB(150,150,150),
    text = Color3.fromRGB(210,210,210),
    primary = Color3.fromRGB(50,50,50),
    secondary = Color3.fromRGB(80,80,80),
    accent = Color3.fromRGB(255,180,0)
}

-- ================= ENABLED FEATURES =================
local Enabled = {
    Life = false,
    Right = false,
    Aimbot = false,
    SpeedBoost = false,
    AutoSteal = false,
    JumpBoost = false,
    SpinBot = false,
    AntiRagdoll = false,
    Unwalk = false,
    ESP = true,
    ExtraSpeed = false,
}

-- ================= VALUES =================
local Values = {
    BoostSpeed = 30.6,
    ExtraSpeedValue = 57.5,
    JumpPower = 28,
    AimbotSpeed = 56,
    AimbotRadius = 120,
    SpinSpeed = 10,
    HitboxSize = 8,

    L1 = Vector3.new(-475.58,-5.40,93.80),
    L2 = Vector3.new(-484.15,-4.42,95.80),
    R1 = Vector3.new(-475.16,-6.52,27.70),
    R2 = Vector3.new(-484.04,-5.09,25.15)
}

-- ================= PLAYER =================
local HRP
local Humanoid

local function updateCharacter()
    local char = Player.Character
    if char then
        HRP = char:FindFirstChild("HumanoidRootPart")
        Humanoid = char:FindFirstChildOfClass("Humanoid")
    end
end

updateCharacter()
Player.CharacterAdded:Connect(updateCharacter)

-- ================= AIMBOT =================
local function findNearestEnemy()
    if not HRP then return end

    local nearest
    local dist = math.huge

    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - HRP.Position).Magnitude
                if d < dist and d < Values.AimbotRadius then
                    dist = d
                    nearest = hrp
                end
            end
        end
    end

    return nearest
end

RunService.Heartbeat:Connect(function()
    if Enabled.Aimbot and HRP then
        local target = findNearestEnemy()
        if target then
            local dir = (target.Position - HRP.Position).Unit
            HRP.AssemblyLinearVelocity = dir * Values.AimbotSpeed
        end
    end
end)

-- ================= SPEED BOOST =================
RunService.Heartbeat:Connect(function()

    if Enabled.SpeedBoost and HRP and Humanoid then
        local moveDir = Humanoid.MoveDirection

        if moveDir.Magnitude > 0 then
            HRP.AssemblyLinearVelocity =
                Vector3.new(
                    moveDir.X * Values.BoostSpeed,
                    HRP.AssemblyLinearVelocity.Y,
                    moveDir.Z * Values.BoostSpeed
                )
        end
    end

end)

-- ================= SPIN BOT =================
local spin

local function startSpin()

    if not HRP then return end

    spin = Instance.new("BodyAngularVelocity")
    spin.MaxTorque = Vector3.new(0,math.huge,0)
    spin.AngularVelocity = Vector3.new(0,Values.SpinSpeed,0)
    spin.Parent = HRP

end

local function stopSpin()

    if spin then
        spin:Destroy()
        spin = nil
    end

end

-- ================= ESP =================
local function makeESP(plr)

    if plr == Player then return end
    if not plr.Character then return end

    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4,6,2)
    box.Color3 = Color3.fromRGB(60,135,255)
    box.Transparency = 0.6
    box.AlwaysOnTop = true
    box.Adornee = hrp
    box.Parent = plr.Character

end

for _,p in ipairs(Players:GetPlayers()) do
    if p ~= Player then
        p.CharacterAdded:Connect(function()
            task.wait(1)
            if Enabled.ESP then
                makeESP(p)
            end
        end)
    end
end

-- ================= GUI =================
local gui = Instance.new("ScreenGui")
gui.Name = "KeekDuelHub"
gui.ResetOnSpawn = false
gui.Parent = Player:WaitForChild("PlayerGui")

-- MAIN FRAME
local main = Instance.new("Frame")
main.Size = UDim2.new(0,260,0,300)
main.Position = UDim2.new(0.5,-130,0.5,-150)
main.BackgroundColor3 = THEME.bg
main.Active = true
main.Draggable = true
main.Parent = gui

Instance.new("UICorner",main)

-- TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.Text = "KEEK DUEL HUB"
title.BackgroundColor3 = THEME.header
title.TextColor3 = THEME.accent
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = main

-- ================= BUTTON CREATOR =================
local function createButton(name,pos,callback)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,220,0,30)
    btn.Position = pos
    btn.Text = name
    btn.BackgroundColor3 = THEME.row
    btn.TextColor3 = THEME.text
    btn.Parent = main

    btn.MouseButton1Click:Connect(callback)

end

-- ================= BUTTONS =================
createButton("AIMBOT",UDim2.new(0,20,0,50),function()
    Enabled.Aimbot = not Enabled.Aimbot
end)

createButton("SPEED BOOST",UDim2.new(0,20,0,90),function()
    Enabled.SpeedBoost = not Enabled.SpeedBoost
end)

createButton("SPIN BOT",UDim2.new(0,20,0,130),function()

    Enabled.SpinBot = not Enabled.SpinBot

    if Enabled.SpinBot then
        startSpin()
    else
        stopSpin()
    end

end)

createButton("STOP ALL",UDim2.new(0,20,0,170),function()

    for k in pairs(Enabled) do
        Enabled[k] = false
    end

    stopSpin()

end)

print("✅ Keek Duel Hub Loaded")
