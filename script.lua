repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- SETTINGS
local Config = {
    SpeedBoostEnabled = false,
    SpeedBoost = 50,

    AntiRagdollEnabled = false,

    SpinbotEnabled = false,
    SpinSpeed = 10,

    SpamBat = false,
    AutoSteal = false,

    StealingBoostEnabled = false,
    StealingBoost = 29,

    Unwalk = false,

    AutoRight = false,
    AutoLeft = false,
}

local HasBrainrotInHand = false

local SpinConnection = nil
local SpamBatConnection = nil
local BrainrotDetectionConnection = nil
local UnwalkConnection = nil

-------------------------------------------------
-- CHARACTER FUNCTIONS
-------------------------------------------------

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local SpeedBoostConnection = nil

local function ApplySpeedBoost(speedValue)

    local char = GetCharacter()
    if not char then return end

    local humanoid = GetHumanoid()
    local rootPart = GetRootPart()

    if not humanoid or not rootPart then return end

    if humanoid.MoveDirection.Magnitude > 0.1 then

        local moveDirectionUnit = humanoid.MoveDirection.Unit

        local calc_X = moveDirectionUnit.X * speedValue
        local calc_Z = moveDirectionUnit.Z * speedValue

        rootPart.AssemblyLinearVelocity =
            Vector3.new(calc_X, rootPart.AssemblyLinearVelocity.Y, calc_Z)

    end
end

local function StartSpeedBoost()

    if SpeedBoostConnection then
        SpeedBoostConnection:Disconnect()
    end

    SpeedBoostConnection = RunService.Heartbeat:Connect(function()

        if not Config.SpeedBoostEnabled then return end
        if HasBrainrotInHand then return end

        ApplySpeedBoost(Config.SpeedBoost)

    end)

end

local StealingBoostConnection = nil

local function StartStealingBoost()

    if StealingBoostConnection then
        StealingBoostConnection:Disconnect()
    end

    StealingBoostConnection = RunService.Heartbeat:Connect(function()

        if not Config.StealingBoostEnabled then return end

        ApplySpeedBoost(Config.StealingBoost)

    end)

end

local function StartSpinbot()

    if SpinConnection then
        SpinConnection:Disconnect()
    end

    SpinConnection = RunService.RenderStepped:Connect(function()

        if not Config.SpinbotEnabled then return end

        local rootPart = GetRootPart()
        local humanoid = GetHumanoid()

        if not rootPart or not humanoid then return end

        rootPart.AssemblyAngularVelocity =
            Vector3.new(0, Config.SpinSpeed * 2, 0)

    end)

end

local function StartSpamBat()

    if SpamBatConnection then
        SpamBatConnection:Disconnect()
    end

    SpamBatConnection = RunService.Heartbeat:Connect(function()

        if not Config.SpamBat then return end

        local char = GetCharacter()
        if not char then return end

        local tool = char:FindFirstChildOfClass("Tool")

        if tool and tool.Name:lower():find("bat") then
            pcall(function()
                tool:Activate()
            end)
        end

    end)

end

local function EnableAntiRagdoll()

    RunService.Heartbeat:Connect(function()

        if not Config.AntiRagdollEnabled then return end

        local hum = GetHumanoid()
        if not hum then return end

        local state = hum:GetState()

        if state == Enum.HumanoidStateType.Ragdoll
        or state == Enum.HumanoidStateType.FallingDown then

            hum:ChangeState(Enum.HumanoidStateType.Running)

        end

    end)

end

local function CheckBrainrotInHand()

    local char = GetCharacter()
    if not char then return false end

    local tool = char:FindFirstChildOfClass("Tool")

    if tool and (
        tool.Name:lower():find("brain") or
        tool.Name:lower():find("rot")
    ) then
        return true
    end

    return false
end

local function SetupBrainrotDetection()

    if BrainrotDetectionConnection then
        BrainrotDetectionConnection:Disconnect()
    end

    BrainrotDetectionConnection =
        RunService.Heartbeat:Connect(function()

        local hasBrainrot = CheckBrainrotInHand()

        if hasBrainrot ~= HasBrainrotInHand then
            HasBrainrotInHand = hasBrainrot
        end

    end)

end

local RIGHT_PATH = {

Vector3.new(-472.56,-6.60,7.78),
Vector3.new(-470.81,-7.00,49.99),
Vector3.new(-470.62,-7.00,69.13),
Vector3.new(-470.37,-7.00,93.93),
Vector3.new(-472.72,-7.00,101.29),
Vector3.new(-473.45,-7.00,100.05),
Vector3.new(-483.25,-5.53,95.78),

}

local LEFT_PATH = {

Vector3.new(-471.75,-5.77,110.12),
Vector3.new(-471.50,-6.00,90.00),
Vector3.new(-471.20,-6.30,70.00),
Vector3.new(-470.90,-6.60,50.00),
Vector3.new(-470.60,-6.90,30.00),
Vector3.new(-470.30,-7.00,20.00),
Vector3.new(-483.20,-5.46,24.32),

}
