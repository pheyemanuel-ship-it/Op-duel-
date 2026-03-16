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
    AutoTPRagdoll = false, -- هذا سيتحكم في المراقبة العامة
    AutoTPRight = false,    -- جديد: تفعيل TP رايت
    AutoTPL2 = false,       -- جديد: تفعيل TP L2
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
    TransitionLtoR = 30.6,
    SpeedToR1 = 57.5,
    RightR1toR2 = 30.6,
    ReturnSpeedR = 30.6,
    TransitionRtoL = 30.6,
    AimbotSpeed = 56,
    AimbotRadius = 120,
    SpinSpeed = 10,
    IJF = 40,
    IJC = 50,
    GalaxyGravity = 80,
    GalaxyGravityPercent = 70,
    HOP_POWER = 30,
    HOP_COOLDOWN = 0.09,
    L1 = Vector3.new(-475.58, -5.40, 93.80),
    L2 = Vector3.new(-484.15, -4.42, 95.80),
    R1 = Vector3.new(-475.16, -6.52, 27.70),
    R2 = Vector3.new(-484.04, -5.09, 25.15),
    DEFAULT_GRAVITY = 196.2,
    FloatHeight = 8,
    DodgeHeight = 1,
    HitboxSize = 8,
    -- إحداثيات TP
    TpCheckA   = Vector3.new(-472.60, -7.00, 57.52),
    TpCheckLeft = Vector3.new(-472.65, -7.00, 95.69),
    TpCheckRight = Vector3.new(-471.76, -7.00, 26.22),
    TpFinalLeft = Vector3.new(-483.59, -5.04, 104.24),
    TpFinalRight = Vector3.new(-483.51, -5.10, 18.89),
}

-- قائمة أدوات الضرب
local SlapList = {
    {1,"Bat"},{2,"Slap"},{3,"Iron Slap"},{4,"Gold Slap"},{5,"Diamond Slap"},
    {6,"Emerald Slap"},{7,"Ruby Slap"},{8,"Dark Matter Slap"},{9,"Flame Slap"},
    {10,"Nuclear Slap"},{11,"Galaxy Slap"},{12,"Glitched Slap"}
}

-- ================= إعدادات Auto steal =================
-- ... (الكود كما هو، لم يتم تغييره) ...
local isStealing = false
local stealStartTime = nil
local progressConnection = nil
local StealData = {}
local ProgressBarFill, ProgressLabel, ProgressPercentLabel

local function isMyPlotByName(pn)
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(pn)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then
            return yb.Enabled == true
        end
    end
    return false
end

local function findNearestPrompt()
    local h = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not h then return nil end
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local np, nd, nn = nil, math.huge, nil
    for _, plot in ipairs(plots:GetChildren()) do
        if isMyPlotByName(plot.Name) then continue end
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if not podiums then continue end
        for _, pod in ipairs(podiums:GetChildren()) do
            pcall(function()
                local base = pod:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then
                    local dist = (spawn.Position - h.Position).Magnitude
                    if dist < nd and dist <= Values.STEAL_RADIUS then
                        local att = spawn:FindFirstChild("PromptAttachment")
                        if att then
                            for _, ch in ipairs(att:GetChildren()) do
                                if ch:IsA("ProximityPrompt") then
                                    np, nd, nn = ch, dist, pod.Name
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
    return np, nd, nn
end

local function ResetProgressBar()
    if ProgressLabel then ProgressLabel.Text = "READY" end
    if ProgressPercentLabel then ProgressPercentLabel.Text = "" end
    if ProgressBarFill then ProgressBarFill.Size = UDim2.new(0, 0, 1, 0) end
end

local function executeSteal(prompt, name)
    if isStealing then return end
    if not StealData[prompt] then
        StealData[prompt] = {hold = {}, trigger = {}, ready = true}
        pcall(function()
            if getconnections then
                for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                    if c.Function then table.insert(StealData[prompt].hold, c.Function) end
                end
                for _, c in ipairs(getconnections(prompt.Triggered)) do
                    if c.Function then table.insert(StealData[prompt].trigger, c.Function) end
                end
            end
        end)
    end
    local data = StealData[prompt]
    if not data.ready then return end
    data.ready = false
    isStealing = true
    stealStartTime = tick()
    if ProgressLabel then ProgressLabel.Text = name or "STEALING..." end
    if progressConnection then progressConnection:Disconnect() end
    progressConnection = RunService.Heartbeat:Connect(function()
        if not isStealing then progressConnection:Disconnect() return end
        local prog = math.clamp((tick() - stealStartTime) / Values.STEAL_DURATION, 0, 1)
        if ProgressBarFill then ProgressBarFill.Size = UDim2.new(prog, 0, 1, 0) end
        if ProgressPercentLabel then
            local percent = math.floor(prog * 100)
            ProgressPercentLabel.Text = percent .. "%"
        end
    end)
    task.spawn(function()
        for _, f in ipairs(data.hold) do task.spawn(f) end
        task.wait(Values.STEAL_DURATION)
        for _, f in ipairs(data.trigger) do task.spawn(f) end
        if progressConnection then progressConnection:Disconnect() end
        ResetProgressBar()
        data.ready = true
        isStealing = false
    end)
end

local stealLoopConnection = nil

local function startAutoSteal()
    if stealLoopConnection then return end
    stealLoopConnection = RunService.Heartbeat:Connect(function()
        if not Enabled.AutoSteal or isStealing then return end
        local p, _, n = findNearestPrompt()
        if p then executeSteal(p, n) end
    end)
end

local function stopAutoSteal()
    if stealLoopConnection then stealLoopConnection:Disconnect(); stealLoopConnection = nil end
    isStealing = false
    ResetProgressBar()
end

-- ================= PLAYER =================
local HRP, Humanoid

local function updateCharacter()
    local char = Player.Character
    if char then
        HRP = char:FindFirstChild("HumanoidRootPart")
        Humanoid = char:FindFirstChildOfClass("Humanoid")
    end
end

updateCharacter()
Player.CharacterAdded:Connect(updateCharacter)

-- ================= STATE للمسارات =================
local lifeState = 0
local rightState = 0
local autoStealActiveForPaths = false
local galaxyActive = false
local spaceHeld = false
local lastVel = Vector3.new()
local waitAtTarget = false
local waitStartTime = 0
local WAIT_DURATION = 0.1
local waitingForSteal = false
local LifeTargets = {Values.L1, Values.L2, Values.L1, Values.R1, Values.R2, Values.R1}
local RightTargets = {Values.R1, Values.R2, Values.R1, Values.L1, Values.L2, Values.L1}

-- ================= متغيرات الاتصالات =================
local Connections = {}
local spinBAV = nil
local unwalkConn = nil
local galaxyBV = nil
local floatConn = nil
local dodgeConn = nil
local espConns = {}
local speedBB = nil
local extraSpeedConnection = nil
local batTPConnection = nil
local hitboxExpanderConn = nil
local originalHRPSizes = {}

-- ================= دوال Aimbot المتطورة =================
local function findBat()
    local c = Player.Character; if not c then return nil end
    local bp = Player:FindFirstChildOfClass("Backpack")
    for _, ch in ipairs(c:GetChildren()) do
        if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
    end
    if bp then
        for _, ch in ipairs(bp:GetChildren()) do
            if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
        end
    end
    for _, i in ipairs(SlapList) do
        local t = c:FindFirstChild(i[2]) or (bp and bp:FindFirstChild(i[2]))
        if t then return t end
    end
end

local function findNearestEnemy(myHRP)
    local nearest, nearestDist, nearestTorso = nil, math.huge, nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local targetHrp = p.Character:FindFirstChild("HumanoidRootPart")
            local torso = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if targetHrp and hum and hum.Health > 0 then
                local d = (targetHrp.Position - myHRP.Position).Magnitude
                if d < Values.AimbotRadius and d < nearestDist then
                    nearestDist = d
                    nearest = targetHrp
                    nearestTorso = torso or targetHrp
                end
            end
        end
    end
    return nearest, nearestDist, nearestTorso
end

local function startAimbot()
    if Connections.aimbot then return end
    Connections.aimbot = RunService.Heartbeat:Connect(function()
        if not Enabled.Aimbot then return end
        local c = Player.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        local bat = findBat()
        if bat and bat.Parent ~= c then
            hum:EquipTool(bat)
        end
        local target, _, torso = findNearestEnemy(h)
        if target and torso then
            local PredictedPos = torso.Position + (torso.AssemblyLinearVelocity * 0.13)
            local dir = PredictedPos - h.Position
            if Vector3.new(dir.X, 0, dir.Z).Magnitude > 0 then
                hum.AutoRotate = true
            end
            if dir.Magnitude > 1.5 then
                h.AssemblyLinearVelocity = dir.Unit * Values.AimbotSpeed
            else
                h.AssemblyLinearVelocity = target.AssemblyLinearVelocity
            end
        end
    end)
end

local function stopAimbot()
    if Connections.aimbot then Connections.aimbot:Disconnect(); Connections.aimbot = nil end
end

-- ================= دوال TP =================
local ragdollDetectorConn = nil
local lastTpSide = "none"
local ragdollWasActive = false

local function tpMove(pos)
    local char = Player.Character; if not char then return end
    char:PivotTo(CFrame.new(pos))
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0,0,0) end
end

-- دوال النقل المباشر
local function doTPRight()
    tpMove(Values.TpCheckA); task.wait(0.1)
    tpMove(Values.TpCheckRight); task.wait(0.1)
    tpMove(Values.TpFinalRight)
    lastTpSide = "right"
end

local function doTPL2()
    tpMove(Values.TpCheckA); task.wait(0.1)
    tpMove(Values.TpCheckLeft); task.wait(0.1)
    tpMove(Values.L2) -- النقل المباشر إلى L2
    lastTpSide = "l2"
end

-- دالة مراقبة الرجدول (معدلة)
local function startRagdollDetector()
    if ragdollDetectorConn then ragdollDetectorConn:Disconnect() end
    ragdollDetectorConn = RunService.Heartbeat:Connect(function()
        -- نتحقق إذا كان أي من زر TP مفعلًا
        if not Enabled.AutoTPRight and not Enabled.AutoTPL2 then return end
        local char = Player.Character; if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local state = hum:GetState()
        local nowRagdolled = (state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown)
        if nowRagdolled and not ragdollWasActive then
    ragdollWasActive = true
    task.spawn(function()
        task.wait(0.15)

        -- run action depending on last TP button used
        if lastTpSide == "right" and Enabled.AutoTPRight then
            doTPRight()
            task.wait(0.2)

            if Enabled.Right then
                autoStealActiveForPaths = true
                rightState = 0
                lifeState = 0
                waitAtTarget = false
            end

        elseif lastTpSide == "l2" and Enabled.AutoTPL2 then
            doTPL2()
            task.wait(0.2)

            if Enabled.Life then
                autoStealActiveForPaths = true
                lifeState = 0
                rightState = 0
                waitAtTarget = false
            end
        end
    end)

elseif not nowRagdolled then
    ragdollWasActive = false
end
end)
end

local function stopRagdollDetector()
    if ragdollDetectorConn then
        ragdollDetectorConn:Disconnect()
        ragdollDetectorConn = nil
    end
    ragdollWasActive = false
end

-- ================= ADVANCED ANTI RAGDOLL =================
local antiRagdollMode = nil
local antiRagdollConnections = {}
local antiRagdollCachedData = {}

local function cacheCharacterData()
    local char = Player.Character
    if not char then return false end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    if not hum or not root then return false end

    antiRagdollCachedData.humanoid = hum
    antiRagdollCachedData.root = root

    return true
end

local function disconnectAllAntiRagdoll()
    for _, conn in ipairs(antiRagdollConnections) do
        if typeof(conn) == "RBXScriptConnection" then
            pcall(function()
                conn:Disconnect()
            end)
        end
    end
    antiRagdollConnections = {}
end

local function isRagdolledAdvanced()
    if not antiRagdollCachedData.humanoid then return false end

    local hum = antiRagdollCachedData.humanoid
    local state = hum:GetState()

    if state == Enum.HumanoidStateType.Physics
    or state == Enum.HumanoidStateType.Ragdoll
    or state == Enum.HumanoidStateType.FallingDown then
        return true
    end

    local endTime = Player:GetAttribute("RagdollEndTime")
    if endTime then
        local now = workspace:GetServerTimeNow()
        if (endTime - now) > 0 then
            return true
        end
    end

    return false
end

local function removeRagdollConstraints()
    if not antiRagdollCachedData.character then return end

    for _, d in ipairs(antiRagdollCachedData.character:GetDescendants()) do
        if d:IsA("BallSocketConstraint")
        or (d:IsA("Attachment") and d.Name:find("RagdollAttachment")) then
            pcall(function()
                d:Destroy()
            end)
        end
    end
end

local function forceExitRagdollAdvanced()
    if not antiRagdollCachedData.humanoid then return end
    if not antiRagdollCachedData.root then return end

    local hum = antiRagdollCachedData.humanoid
    local root = antiRagdollCachedData.root

    pcall(function()
        local now = workspace:GetServerTimeNow()
        Player:SetAttribute("RagdollEndTime", now)
    end)

    if hum.Health > 0 then
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end

    root.Anchored = false
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end

local function antiRagdollLoop()
    while antiRagdollMode do
        task.wait()

        if isRagdolledAdvanced() then
            removeRagdollConstraints()
            forceExitRagdollAdvanced()
        end

        local cam = workspace.CurrentCamera
        if cam and antiRagdollCachedData.humanoid then
            if cam.CameraSubject ~= antiRagdollCachedData.humanoid then
                cam.CameraSubject = antiRagdollCachedData.humanoid
            end
        end
    end
end

local function startAdvancedAntiRagdoll()
    if antiRagdollMode then return end

    disconnectAllAntiRagdoll()

    if not cacheCharacterData() then return end

    antiRagdollMode = "v2"

    local charConn = Player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if antiRagdollMode then
            cacheCharacterData()
        end
    end)

    table.insert(antiRagdollConnections, charConn)

    task.spawn(antiRagdollLoop)
end

local function stopAdvancedAntiRagdoll()
    antiRagdollMode = nil
    disconnectAllAntiRagdoll()
    antiRagdollCachedData = {}
end
-- ================= SPINBOT =================
local function startSpinBot()
    if spinBAV then return end
    if not HRP then return end

    spinBAV = Instance.new("BodyAngularVelocity")
    spinBAV.MaxTorque = Vector3.new(0, math.huge, 0)
    spinBAV.AngularVelocity = Vector3.new(0, Values.SpinSpeed, 0)
    spinBAV.Parent = HRP
end

local function stopSpinBot()
    if spinBAV then
        spinBAV:Destroy()
        spinBAV = nil
    end
end


-- ================= INFINITE JUMP =================
local function startInfiniteJump()
    Connections.infjump = UserInputService.JumpRequest:Connect(function()
        if Enabled.JumpBoost and Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function stopInfiniteJump()
    if Connections.infjump then
        Connections.infjump:Disconnect()
        Connections.infjump = nil
    end
end


-- ================= JUMP BOOST =================
local function applyJumpBoost()
    if Humanoid then
        Humanoid.JumpPower = Values.JumpPower
    end
end

local function resetJumpBoost()
    if Humanoid then
        Humanoid.JumpPower = 50
    end
end


-- ================= FLOAT =================
local function startFloat()
    if floatConn then return end

    floatConn = RunService.Heartbeat:Connect(function()
        if not Enabled.Float then return end
        if HRP then
            HRP.Velocity = Vector3.new(0, 0, 0)
            HRP.CFrame = HRP.CFrame + Vector3.new(0, Values.FloatHeight * 0.01, 0)
        end
    end)
end

local function stopFloat()
    if floatConn then
        floatConn:Disconnect()
        floatConn = nil
    end
end


-- ================= DODGE =================
local function startDodge()
    if dodgeConn then return end

    dodgeConn = RunService.Heartbeat:Connect(function()
        if not Enabled.Dodge then return end
        if HRP then
            HRP.CFrame = HRP.CFrame + Vector3.new(0, Values.DodgeHeight * 0.02, 0)
        end
    end)
end

local function stopDodge()
    if dodgeConn then
        dodgeConn:Disconnect()
        dodgeConn = nil
    end
end


-- ================= UNWALK =================
local function startUnwalk()
    if unwalkConn then return end

    unwalkConn = RunService.Heartbeat:Connect(function()
        if not Enabled.Unwalk then return end
        if HRP then
            HRP.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

local function stopUnwalk()
    if unwalkConn then
        unwalkConn:Disconnect()
        unwalkConn = nil
    end
end
-- ================= GALAXY GRAVITY =================
local function startGalaxy()
    if galaxyBV then return end
    galaxyActive = true

    Workspace.Gravity = Values.GalaxyGravity
end

local function stopGalaxy()
    galaxyActive = false
    Workspace.Gravity = Values.DEFAULT_GRAVITY
end


-- ================= EXTRA SPEED =================
local function startExtraSpeed()
    if extraSpeedConnection then return end

    extraSpeedConnection = RunService.Heartbeat:Connect(function()
        if not Enabled.ExtraSpeed then return end
        if HRP then
            HRP.AssemblyLinearVelocity =
                HRP.CFrame.LookVector * Values.ExtraSpeedValue
        end
    end)
end

local function stopExtraSpeed()
    if extraSpeedConnection then
        extraSpeedConnection:Disconnect()
        extraSpeedConnection = nil
    end
end


-- ================= BAT TP =================
local function startBatTP()
    if batTPConnection then return end

    batTPConnection = RunService.Heartbeat:Connect(function()
        if not Enabled.BatTP then return end

        local myHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local target, dist = findNearestEnemy(myHRP)

        if target and dist < 15 then
            myHRP.CFrame = target.CFrame * CFrame.new(0, 0, -2)
        end
    end)
end

local function stopBatTP()
    if batTPConnection then
        batTPConnection:Disconnect()
        batTPConnection = nil
    end
end


-- ================= HITBOX EXPANDER =================
local function startHitboxExpander()
    if hitboxExpanderConn then return end

    hitboxExpanderConn = RunService.Heartbeat:Connect(function()
        if not Enabled.HitboxExpander then return end

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if not originalHRPSizes[player] then
                        originalHRPSizes[player] = hrp.Size
                    end

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
    end)
end

local function stopHitboxExpander()
    if hitboxExpanderConn then
        hitboxExpanderConn:Disconnect()
        hitboxExpanderConn = nil
    end

    for player, size in pairs(originalHRPSizes) do
        if player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = size
                hrp.Transparency = 1
            end
        end
    end
end


-- ================= ESP SYSTEM =================
local function createESP(player)
    if player == Player then return end

    local function applyESP(char)
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Color3.fromRGB(255,0,0)
        highlight.OutlineColor = Color3.fromRGB(255,255,255)
        highlight.FillTransparency = 0.5
        highlight.Parent = char
    end

    if player.Character then
        applyESP(player.Character)
    end

    player.CharacterAdded:Connect(function(char)
        applyESP(char)
    end)
end


local function startESP()
    for _, p in ipairs(Players:GetPlayers()) do
        createESP(p)
    end

    espConns.playerAdded = Players.PlayerAdded:Connect(function(p)
        createESP(p)
    end)
end


local function stopESP()
    if espConns.playerAdded then
        espConns.playerAdded:Disconnect()
        espConns.playerAdded = nil
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            for _, obj in ipairs(p.Character:GetChildren()) do
                if obj:IsA("Highlight") then
                    obj:Destroy()
                end
            end
        end
    end
end
-- ================= KEEK DUEL GUI (2 TABS + SCROLL) =================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KeekDuelGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,360,0,420)
Main.Position = UDim2.new(0.5,-180,0.5,-210)
Main.BackgroundColor3 = THEME.bg
Main.Parent = ScreenGui

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255,0,0)
Stroke.Thickness = 2
Stroke.Parent = Main

-- HEADER
local Top = Instance.new("Frame")
Top.Size = UDim2.new(1,0,0,40)
Top.BackgroundColor3 = THEME.header
Top.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,1,0)
Title.BackgroundTransparency = 1
Title.Text = "KEEK DUEL"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = THEME.text
Title.Parent = Top

-- TAB BAR
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1,0,0,32)
TabBar.Position = UDim2.new(0,0,0,40)
TabBar.BackgroundColor3 = THEME.header
TabBar.Parent = Main

local CombatTabBtn = Instance.new("TextButton")
CombatTabBtn.Size = UDim2.new(0.5,0,1,0)
CombatTabBtn.Text = "Combat"
CombatTabBtn.Font = Enum.Font.Gotham
CombatTabBtn.TextSize = 14
CombatTabBtn.TextColor3 = THEME.text
CombatTabBtn.BackgroundColor3 = THEME.primary
CombatTabBtn.Parent = TabBar

local MoveTabBtn = Instance.new("TextButton")
MoveTabBtn.Size = UDim2.new(0.5,0,1,0)
MoveTabBtn.Position = UDim2.new(0.5,0,0,0)
MoveTabBtn.Text = "Movement"
MoveTabBtn.Font = Enum.Font.Gotham
MoveTabBtn.TextSize = 14
MoveTabBtn.TextColor3 = THEME.text
MoveTabBtn.BackgroundColor3 = THEME.secondary
MoveTabBtn.Parent = TabBar

-- PAGES
local CombatPage = Instance.new("ScrollingFrame")
CombatPage.Size = UDim2.new(1,-10,1,-80)
CombatPage.Position = UDim2.new(0,5,0,75)
CombatPage.CanvasSize = UDim2.new(0,0,0,700)
CombatPage.ScrollBarThickness = 4
CombatPage.BackgroundTransparency = 1
CombatPage.Parent = Main

local MovePage = CombatPage:Clone()
MovePage.Visible = false
MovePage.Parent = Main

-- LAYOUTS
local function createLayout(parent)
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,6)
layout.Parent = parent
end

createLayout(CombatPage)
createLayout(MovePage)

-- TAB SWITCHING
CombatTabBtn.MouseButton1Click:Connect(function()
CombatPage.Visible = true
MovePage.Visible = false
CombatTabBtn.BackgroundColor3 = THEME.primary
MoveTabBtn.BackgroundColor3 = THEME.secondary
end)

MoveTabBtn.MouseButton1Click:Connect(function()
CombatPage.Visible = false
MovePage.Visible = true
MoveTabBtn.BackgroundColor3 = THEME.primary
CombatTabBtn.BackgroundColor3 = THEME.secondary
end)

-- TOGGLE CREATOR
local function createToggle(parent,name,callback)

local Row = Instance.new("Frame")
Row.Size = UDim2.new(1,0,0,32)
Row.BackgroundColor3 = THEME.row
Row.Parent = parent

local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(0.7,0,1,0)
Label.Position = UDim2.new(0,10,0,0)
Label.BackgroundTransparency = 1
Label.Text = name
Label.Font = Enum.Font.Gotham
Label.TextSize = 14
Label.TextColor3 = THEME.text
Label.TextXAlignment = Enum.TextXAlignment.Left
Label.Parent = Row

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0,50,0,20)
Toggle.Position = UDim2.new(1,-60,0.5,-10)
Toggle.Text = ""
Toggle.BackgroundColor3 = THEME.toggleOff
Toggle.Parent = Row

local Dot = Instance.new("Frame")
Dot.Size = UDim2.new(0,16,0,16)
Dot.Position = UDim2.new(0,2,0.5,-8)
Dot.BackgroundColor3 = THEME.dotOff
Dot.Parent = Toggle

local state = false

Toggle.MouseButton1Click:Connect(function()

    state = not state

    if state then
        Dot.Position = UDim2.new(1,-18,0.5,-8)
        Dot.BackgroundColor3 = THEME.dotOn
    else
        Dot.Position = UDim2.new(0,2,0.5,-8)
        Dot.BackgroundColor3 = THEME.dotOff
    end

    callback(state)

end)

end

-- COMBAT TAB
createToggle(CombatPage,"Aimbot",function(v)
Enabled.Aimbot=v
if v then startAimbot() else stopAimbot() end
end)

createToggle(CombatPage,"Auto Steal",function(v)
Enabled.AutoSteal=v
if v then startAutoSteal() else stopAutoSteal() end
end)

createToggle(CombatPage,"SpinBot",function(v)
Enabled.SpinBot=v
if v then startSpinBot() else stopSpinBot() end
end)

createToggle(CombatPage,"Hitbox Expander",function(v)
Enabled.HitboxExpander=v
if v then startHitboxExpander() else stopHitboxExpander() end
end)

createToggle(CombatPage,"ESP",function(v)
Enabled.ESP=v
if v then startESP() else stopESP() end
end)

-- MOVEMENT TAB
createToggle(MovePage,"Jump Boost",function(v)
Enabled.JumpBoost=v
if v then applyJumpBoost() else resetJumpBoost() end
end)

createToggle(MovePage,"Float",function(v)
Enabled.Float=v
if v then startFloat() else stopFloat() end
end)

createToggle(MovePage,"Dodge",function(v)
Enabled.Dodge=v
if v then startDodge() else stopDodge() end
end)

createToggle(MovePage,"Unwalk",function(v)
Enabled.Unwalk=v
if v then startUnwalk() else stopUnwalk() end
end)

createToggle(MovePage,"Extra Speed",function(v)
Enabled.ExtraSpeed=v
if v then startExtraSpeed() else stopExtraSpeed() end
end)

-- DRAGGING
local dragging,dragInput,dragStart,startPos

local function update(input)
local delta=input.Position-dragStart
Main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
end

Top.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 then
dragging=true
dragStart=input.Position
startPos=Main.Position
input.Changed:Connect(function()
if input.UserInputState==Enum.UserInputState.End then
dragging=false
end
end)
end
end)

Top.InputChanged:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseMovement then
dragInput=input
end
end)

UserInputService.InputChanged:Connect(function(input)
if input==dragInput and dragging then
update(input)
end
end)
