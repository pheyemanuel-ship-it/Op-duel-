-- [[ Owned by Gorrexxsz ]] --

-- // [1] SERVICES //

local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local Stats            = game:GetService("Stats")
local StarterGui       = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

-- // [2] CONFIGURATION //

local CONFIG = {

    Names = {
    MainGui = "KeekDuel",
    HudGui = "KeekDuelHUD",
    DuelGui = "KeekDuelUI",
    MainFrame = "MainFrame",
    HudFrame = "HudFrame",
    DuelFrame = "DuelFrame",
    OpenButton = "OpenButton",
    TabBar = "TabBar",
    Content = "ContentFrame",
    }

    Colors = {
        Gold          = Color3.new(1, 0.866667, 0),
        GoldDim       = Color3.fromRGB(180, 170, 100),
        Background    = Color3.new(1, 1, 1),
        FrameDark     = Color3.new(0.0392157, 0.0392157, 0.0392157),
        FrameMid      = Color3.new(0.0588235, 0.0588235, 0.0784314),
        FrameLight    = Color3.new(0.117647, 0.117647, 0.117647),
        ButtonDark    = Color3.new(0.0980392, 0.0980392, 0.0980392),
        ButtonOff     = Color3.new(0.0980392, 0.0980392, 0.0980392),
        ButtonOn      = Color3.new(1, 0.866667, 0),
        ButtonOnText  = Color3.new(0, 0, 0),
        ButtonOffText = Color3.new(0.470588, 0.431373, 0.235294),
        White         = Color3.new(1, 1, 1),
        Divider       = Color3.new(1, 1, 1),
        SliderTrack   = Color3.new(0.117647, 0.117647, 0.117647),
        SliderFill    = Color3.new(1, 0.866667, 0),
        PlotZone      = Color3.new(0, 0, 0),
    },
  Sizes = {
        MainFrame  = UDim2.new(0, 260, 0, 330),
        HudFrame   = UDim2.new(0, 180, 0, 52),
        DuelFrame  = UDim2.new(0, 200, 0, 135),
        OpenButton = UDim2.new(0, 48, 0, 48),
    },

    Positions = {
        MainFrame = UDim2.new(0.5, 0, 0.5, 0),
        HudFrame   = UDim2.new(0.5, -90, 0, 5),
        DuelFrame  = UDim2.new(0.5, -100, 0.28, 0),
        OpenButton = UDim2.new(0.01, 0, 0.18, 0),
    },

    Fonts = {
        Title  = Enum.Font.GothamBlack,
        Body   = Enum.Font.Gotham,
        Bold   = Enum.Font.GothamBold,
    },

    Keys = {
        ToggleGui  = Enum.KeyCode.U,
        BatLock    = Enum.KeyCode.X,
        Speed      = Enum.KeyCode.V,
        InfJump    = Enum.KeyCode.J,
        Fling      = Enum.KeyCode.F,
        AutoDuel   = Enum.KeyCode.G,
    },

  Defaults = {
        HeliSpeed   = 10,
        BatLockSpeed= 55,
        GrabRadius  = 7,
        FOV         = 70,
    },

    Tabs = {"Combat", "Protect", "Visual", "Settings"},

    CombatToggles = {
        { label = "Bat Lock UI",          default = false },
        { label = "Fling",                default = false },
        { label = "Float",                default = false },
        { label = "Speed Custom",         default = false },
        { label = "Inf Jump",             default = false },
        { label = "Auto Duel",            default = false },
        { label = "Auto R / L",           default = false },
        { label = "Auto Grab",            default = false },
        { label = "Auto Correct Lag",     default = false },
        { label = "Anti-Ragdoll",         default = false },
        { label = "Visual Player",        default = true  },
        { label = "Auto disable on plot", default = false },
    },

  ProtectToggles = {
        { label = "Anti Effect",  default = false },
        { label = "Xray Base",   default = false },
        { label = "Unwalk",       default = false },
        { label = "Player ESP",   default = false },
    },

    VisualToggles = {
        { label = "Helicopter", default = false, hasSlider = true },
    },

}
-- // [3] OBJECT REFERENCES //

local MainGui    = nil
local HudGui     = nil
local DuelGui    = nil

-- Main window
local MainFrame  = nil
local OpenButton = nil
local TitleBar   = nil
local CloseBtn   = nil
local TabBar     = nil
local ContentFrame = nil

-- HUD elements
local HudFrame      = nil
local HudTitle      = nil
local HudDivider    = nil
local HudStatsLabel = nil
local HudPlatLabel  = nil
local HudProgressOuter = nil
local HudProgressFill  = nil
local HudProgressThumb = nil
local HudSpeedBox   = nil

-- Duel window
local DuelFrame     = nil
local DuelTitleBar  = nil
local DuelContent   = nil
local DuelAutoRBtn  = nil
local DuelAutoLBtn  = nil
local DuelStopBtn   = nil
local DuelStatusLbl = nil

-- Stroke gradient on HUD
local HudStrokeGradient = nil

-- Runtime state

local CurrentTab      = "Combat"
local TabButtons      = {}
local ScrollFrames    = {}
local ToggleStates    = {}
local BoundKeys       = {}

local HeliSpeed       = CONFIG.Defaults.HeliSpeed
local BatLockSpeed    = CONFIG.Defaults.BatLockSpeed
local GrabRadius      = CONFIG.Defaults.GrabRadius
local CurrentFOV      = CONFIG.Defaults.FOV

local GradientAngle   = 0

local PlotZonePart    = nil
local PlotZoneBox     = nil

-- // [4] UTILITY FUNCTIONS //

local function getHRP()
    local char = LocalPlayer.Character
    if not char then return nil end

    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("UpperTorso")
end

local function getHumanoid()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

local function getCamera()
    return workspace.CurrentCamera
end
-- Smooth tween helper

local function tween(obj, props, duration, style, direction)

    style     = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out

    local info = TweenInfo.new(duration or 0.3, style, direction)

    return TweenService:Create(obj, info, props)
end
-- Inf Jump

local function startInfJump()

    UserInputService.JumpRequest:Connect(function()

        if not ToggleStates["Combat_5"] then return end

        local hrp = getHRP()

        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(
                hrp.AssemblyLinearVelocity.X,
                50,
                hrp.AssemblyLinearVelocity.Z
            )
        end
    end)

end
-- Godmode

local function startGodmode()

    RunService.Heartbeat:Connect(function()

        local hum = getHumanoid()

        if hum and hum.MaxHealth > 0 then
            hum.MaxHealth = math.huge
            hum.Health    = math.huge
        end

    end)

end
-- // [7] INITIALIZATION //

local function init()

    createHUD()
    createMainGUI()
    createDuelUI()
    createPlotZone()

    connectMainButtons()
    connectDuelButtons()
    connectKeybinds()
    connectDestroyCleanup()

    startHUDGradientSpin()
    startHUDStats()
    startInfJump()
    startGodmode()

    switchTab("Combat")

    LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

    if LocalPlayer.Character then
        onCharacterAdded(LocalPlayer.Character)
    end

    print("KeeK Duel Loaded!")
end

init()
