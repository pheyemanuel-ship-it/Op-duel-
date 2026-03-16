-- ================= SERVICES =================
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

-- ================= THEME (NineHub Style) =================
local THEME = {
    bg          = Color3.fromRGB(22, 22, 22),
    header      = Color3.fromRGB(28, 28, 28),
    row         = Color3.fromRGB(30, 30, 30),
    toggleOff   = Color3.fromRGB(60, 60, 60),
    toggleBall  = Color3.fromRGB(150, 150, 150),
    input       = Color3.fromRGB(10, 10, 10),
    inputStroke = Color3.fromRGB(70, 70, 70),
    text        = Color3.fromRGB(210, 210, 210),
    primary     = Color3.fromRGB(50, 50, 50),
    secondary   = Color3.fromRGB(80, 80, 80),
    accent      = Color3.fromRGB(255, 180, 0),
    white       = Color3.fromRGB(255, 255, 255),
    black       = Color3.fromRGB(0, 0, 0),
    dotOn       = Color3.fromRGB(100, 220, 100),
    dotOff      = Color3.fromRGB(60, 60, 60),
}

-- ================= SETTINGS =================
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
    Galaxy = false,
    Float = false,
    Dodge = false,
    ESP = true,
    ExtraSpeed = false,
    BatTP = false,
    HitboxExpander = false,
    AutoTPRagdoll = false,
    AutoTPRight = false,
    AutoTPL2 = false,
}

local Values = {
    BoostSpeed = 30.6,
    ExtraSpeedValue = 57.5,
    JumpPower = 28,
    StealingSpeedValue = 30.6,
    STEAL_RADIUS = 7,
    STEAL_DURATION = 0.2,
    L2_RADIUS = 5,
    R2_RADIUS = 5,
    SpeedToL1 = 57.7,
    LifeL1toL2 = 43,
    ReturnSpeedL = 30.6,
}

Values.L1 = Vector3.new(-475.58, -5.40, 93.80)
Values.L2 = Vector3.new(-484.15, -4.42, 95.80)
Values.R1 = Vector3.new(-475.16, -6.52, 27.70)
Values.R2 = Vector3.new(-484.04, -5.09, 25.15)

local LifeTargets = {
    Values.L1,
    Values.L2
}

local RightTargets = {
    Values.R1,
    Values.R2
}

local lifeState = 1
local rightState = 1

local SlapList = {
    {1,"Bat"},
    {2,"Slap"},
    {3,"Iron Slap"},
    {4,"Gold Slap"},
    {5,"Diamond Slap"},
    {6,"Emerald Slap"},
    {7,"Ruby Slap"},
    {8,"Dark Matter Slap"},
    {9,"Flame Slap"},
    {10,"Nuclear Slap"},
    {11,"Galaxy Slap"},
    {12,"Glitched Slap"}
}

local function findBat()
    local char = Player.Character
    if not char then return nil end
    
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            return tool
        end
    end
    
    for _, tool in ipairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            return tool
        end
    end
    
    return nil
end

local function findNearestEnemy(myHRP)
    local nearest = nil
    local nearestDist = math.huge
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - myHRP.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = hrp
                end
            end
        end
    end
    
    return nearest
end

local spinConnection
local spinBody

local function startSpin()
    local char = Player.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    spinBody = Instance.new("BodyAngularVelocity")
    spinBody.MaxTorque = Vector3.new(0, math.huge, 0)
    spinBody.AngularVelocity = Vector3.new(0, 10, 0)
    spinBody.Parent = root
end

local function stopSpin()
    if spinBody then
        spinBody:Destroy()
        spinBody = nil
    end
end

local function makeESP(plr)
    if plr == Player then return end
    if not plr.Character then return end
    
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4,6,2)
    box.Adornee = hrp
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Color3 = Color3.fromRGB(255,0,0)
    box.Parent = hrp
end

local gui = Instance.new("ScreenGui")
gui.Name = "KeeKHub_Duels"
gui.ResetOnSpawn = false
gui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5,-250,0.5,-200)
MainFrame.BackgroundColor3 = THEME.bg
MainFrame.Parent = gui

local function createToggleButton(text, pos, callback)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 0, 40)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = THEME.primary
    btn.TextColor3 = THEME.text
    btn.Parent = MainFrame
    
    local state = false
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
    end)
    
end

RunService.Heartbeat:Connect(function()

    local char = Player.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if Enabled.SpeedBoost then
        hrp.AssemblyLinearVelocity =
            hrp.CFrame.LookVector * Values.BoostSpeed
    end

    if Enabled.ExtraSpeed then
        hrp.AssemblyLinearVelocity =
            hrp.CFrame.LookVector * Values.ExtraSpeedValue
    end

end)

local function stopAll()

    Enabled.Life = false
    Enabled.Right = false
    Enabled.Aimbot = false
    Enabled.SpeedBoost = false
    Enabled.AutoSteal = false
    Enabled.JumpBoost = false
    Enabled.SpinBot = false

end

-- ================= AUTO STEAL SYSTEM =================

local stealConnection
local stealing = false

local function findNearestPrompt()
    local char = Player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local nearestPrompt = nil
    local nearestDistance = Values.STEAL_RADIUS

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local part = obj.Parent
            if part and part:IsA("BasePart") then
                local dist = (part.Position - hrp.Position).Magnitude
                if dist < nearestDistance then
                    nearestDistance = dist
                    nearestPrompt = obj
                end
            end
        end
    end

    return nearestPrompt
end

local function executeSteal(prompt)
    if stealing then return end
    stealing = true

    fireproximityprompt(prompt)

    task.wait(Values.STEAL_DURATION)

    stealing = false
end

local function startAutoSteal()
    if stealConnection then stealConnection:Disconnect() end

    stealConnection = RunService.Heartbeat:Connect(function()
        if not Enabled.AutoSteal then return end

        local prompt = findNearestPrompt()
        if prompt then
            executeSteal(prompt)
        end
    end)
end

local function stopAutoSteal()
    if stealConnection then
        stealConnection:Disconnect()
        stealConnection = nil
    end
end

-- ================= AIMBOT SYSTEM =================

local aimbotConnection

local function startAimbot()

    if aimbotConnection then
        aimbotConnection:Disconnect()
    end

    aimbotConnection = RunService.Heartbeat:Connect(function()

        if not Enabled.Aimbot then return end

        local char = Player.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local enemy = findNearestEnemy(hrp)
        if not enemy then return end

        local dir = (enemy.Position - hrp.Position).Unit

        hrp.AssemblyLinearVelocity = dir * Values.AimbotSpeed

    end)

end

local function stop

-- ================= HITBOX EXPANDER =================

local function expandHitboxes()

    for _,plr in ipairs(Players:GetPlayers()) do

        if plr ~= Player then

            local char = plr.Character
            if char then

                local hrp = char:FindFirstChild("HumanoidRootPart")

                if hrp then

                    hrp.Size = Vector3.new(
                        Values.HitboxSize,
                        Values.HitboxSize,
                        Values.HitboxSize
                    )

                    hrp.Transparency = 0.6
                    hrp.CanCollide = false

                end

            end

        end

    end

    end

    -- ================= FLOAT SYSTEM =================

local floatConnection

local function startFloat()

    if floatConnection then
        floatConnection:Disconnect()
    end

    floatConnection = RunService.Heartbeat:Connect(function()

        if not Enabled.Float then return end

        local char = Player.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        hrp.Velocity = Vector3.new(0,0,0)

        hrp.CFrame = hrp.CFrame + Vector3.new(0,2,0)

    end)

end

local function stopFloat()

    if floatConnection then
        floatConnection:Disconnect()
        floatConnection = nil
    end

    end

-- ================= DODGE SYSTEM =================

local dodgeConnection

local function startDodge()

    if dodgeConnection then
        dodgeConnection:Disconnect()
    end

    dodgeConnection = RunService.Heartbeat:Connect(function()

        if not Enabled.Dodge then return end

        local char = Player.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        hrp.CFrame = hrp.CFrame + Vector3.new(0,1.5,0)

    end)

end

local function stopDodge()

    if dodgeConnection then
        dodgeConnection:Disconnect()
        dodgeConnection = nil
    end

    end

-- ================= ADVANCED ANTI RAGDOLL =================

local antiRagdollConnection

local function removeRagdollConstraints(char)

    for _,v in pairs(char:GetDescendants()) do
        if v:IsA("BallSocketConstraint") then
            v:Destroy()
        end
    end

end

local function forceExitRagdollAdvanced()

    local char = Player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    removeRagdollConstraints(char)

    hum:ChangeState(Enum.HumanoidStateType.GettingUp)

end

local function startAdvancedAntiRagdoll()

    if antiRagdollConnection then
        antiRagdollConnection:Disconnect()
    end

    antiRagdollConnection = RunService.Heartbeat:Connect(function()

        if not Enabled.AntiRagdoll then return end

        local char = Player.Character
        if not char then return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        if hum:GetState() == Enum.HumanoidStateType.Ragdoll
        or hum:GetState() == Enum.HumanoidStateType.Physics then

            forceExitRagdollAdvanced()

        end

    end)

    end

-- ================= RAGDOLL TELEPORT =================

local ragdollConnection

local function startRagdollDetector()

    if ragdollConnection then
        ragdollConnection:Disconnect()
    end

    ragdollConnection = RunService.Heartbeat:Connect(function()

        if not Enabled.AutoTPRagdoll then return end

        local char = Player.Character
        if not char then return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")

        if not hum or not hrp then return end

        if hum:GetState() == Enum.HumanoidStateType.Physics then

            if Enabled.AutoTPRight then
                hrp.CFrame = CFrame.new(Values.R1)
            end

            if Enabled.AutoTPL2 then
                hrp.CFrame = CFrame.new(Values.L2)
            end

        end

    end)

    end

-- ================= LIFE PATH =================

local function runLifePath()

    RunService.Heartbeat:Connect(function()

        if not Enabled.Life then return end

        local char = Player.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local target = LifeTargets[lifeState]

        local distance = (hrp.Position - target).Magnitude

        if distance < 3 then

            lifeState = lifeState + 1

            if lifeState > #LifeTargets then
                lifeState = 1
            end

        end

        local dir = (target - hrp.Position).Unit

        hrp.AssemblyLinearVelocity = dir * Values.SpeedToL1

    end)

    end

-- ================= RIGHT PATH =================

local function runRightPath()

    RunService.Heartbeat:Connect(function()

        if not Enabled.Right then return end

        local char = Player.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local target = RightTargets[rightState]

        local distance = (hrp.Position - target).Magnitude

        if distance < 3 then

            rightState = rightState + 1

            if rightState > #RightTargets then
                rightState = 1
            end

        end

        local dir = (target - hrp.Position).Unit

        hrp.AssemblyLinearVelocity = dir * Values.SpeedToL1

    end)

    end

-- ================= ESP MARKERS =================

local function addESP(position,name,color)

    local part = Instance.new("Part")

    part.Anchored = true
    part.CanCollide = false
    part.Size = Vector3.new(2,2,2)
    part.Position = position
    part.Color = color
    part.Name = name

    part.Parent = Workspace

end

addESP(Values.L1,"L1",Color3.fromRGB(255,0,0))
addESP(Values.L2,"L2",Color3.fromRGB(255,0,0))
addESP(Values.R1,"R1",Color3.fromRGB(0,255,0))
addESP(Values.R2,"R2",Color3.fromRGB(0,255,0))

-- ================= START SYSTEMS =================

startAutoSteal()
startAimbot()
startFloat()
startDodge()
startAdvancedAntiRagdoll()
startRagdollDetector()

runLifePath()
runRightPath()

print("Nine Hub Duels Loaded")
