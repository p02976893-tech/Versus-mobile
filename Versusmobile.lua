-- ============================================================
--  NEXUS CHEAT v7.1 — Mobile Edition
--  UI: большие кнопки, тач-бинды, масштабируемое меню
--  Особенности мобильной версии:
--   • Кнопка открытия меню — плавающая кнопка справа сверху
--   • Все элементы увеличены под палец
--   • Aimbot активируется зажатием иконки-кнопки на экране
--   • Масштаб меню меняется ползунком
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local GUI_PARENT
do
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then
        local writable = pcall(function()
            local t = Instance.new("Folder"); t.Parent = cg; t:Destroy()
        end)
        GUI_PARENT = writable and cg or LocalPlayer:WaitForChild("PlayerGui")
    else
        GUI_PARENT = LocalPlayer:WaitForChild("PlayerGui")
    end
end

-- ==================== КОНФИГ ====================
local Config = {
    Game = nil,

    MenuScale = 1.0,      -- масштаб меню (мобильный)
    MenuOpen = true,      -- открыто ли меню
    AimButtonVisible = true, -- кнопка Aimbot на экране

    ESP = false,
    ESP_Box = true,
    ESP_Name = true,
    ESP_Health = true,
    ESP_Distance = true,
    ESP_Highlight = true,
    ESP_TeamCheck = false,
    ESP_Bots = true,
    ESP_BotColor = Color3.fromRGB(255, 150, 0),
    ESP_MaxDistance = 500,
    ESP_Color = Color3.fromRGB(0, 170, 255),

    Tracers = false,
    TracersColor = Color3.fromRGB(255, 0, 0),
    TracersThickness = 2,

    MM2ESP = false,
    MM2_InnocentColor = Color3.fromRGB(0, 255, 100),
    MM2_SheriffColor = Color3.fromRGB(0, 150, 255),
    MM2_MurdererColor = Color3.fromRGB(255, 40, 40),

    Aimbot = false,
    Aimbot_Bots = true,
    AimbotKey = Enum.UserInputType.MouseButton2,
    AimbotKeyName = "ПКМ",
    AimbotMode = "Зажать",
    AimbotFOV = 150,
    AimbotSmooth = 15,
    AimbotWallbang = true,
    AimbotTeamCheck = true,
    AimbotPart = "Head",
    AimbotDrawFOV = true,
    AimbotPrediction = false,
    AimbotAutoShootMurderer = false,
    AimbotAutoShootRange = 500,
    AimbotAutoShootDelay = 0.15,

    AutoShootBots = false,
    AutoShootBotsFOV = 250,
    AutoShootBotsDelay = 0.1,

    Radar = false,
    RadarSize = 120,
    RadarRange = 300,

    FootstepESP = false,
    FootstepColor = Color3.fromRGB(255, 255, 0),

    DamageNumbers = false,
    DamageNumbersDuration = 1.0,

    HitMarker = false,
    HitMarkerColor = Color3.fromRGB(255, 255, 255),

    Wallbang = false,
    WallbangKey = Enum.UserInputType.MouseButton1,
    WallbangDelay = 0.1,
    WallbangRange = 1500,

    TriggerBot = false,
    TriggerBotDelay = 0.05,

    Fly = false,
    FlySpeed = 60,
    Speed = false,
    SpeedValue = 60,
    Noclip = false,
    InfiniteJump = false,
    HighJump = false,
    HighJumpPower = 300,

    ThirdPerson = false,
    ThirdPersonKey = Enum.KeyCode.V,
    ThirdPersonKeyName = "V",
    ThirdPersonMode = "Переключить",
    ThirdPersonDistance = 10,

    CharSpin = false,
    CharSpinSpeed = 15,
    CharSpinOnlyWhenMoving = false,

    BunnyHop = false,
    BunnyHopBaseSpeed = 30,
    BunnyHopMaxSpeed = 200,
    BunnyHopAccel = 5,

    SilentAim = false,
    SilentAimFOV = 200,
    SilentAimTargetPart = "Head",

    NoRecoil = false,
    RapidFire = false,
    ScopeAnywhere = false,
    ScopeKey = Enum.KeyCode.C,
    ScopeKeyName = "C",
    ScopeFOV = 40,
    InfiniteAmmo = false,

    GhostMode = false,
    GhostTransparency = 1,

    SelectedPlayer = nil,
    TeleportOffset = 3,
    FlingSpeed = 500,
    AntiFling = false,
    Spin = false,
    SpinSpeed = 15,
    SpinOnlyWhenMoving = false,
    KillAura = false,
    KillAuraTarget = "Ближайший",
    KillAuraDelay = 0.5,
    GodMode = false,
    AutoPickupGun = false,

    CheckpointTP = false,
    CheckpointTPKey = Enum.KeyCode.T,
    CheckpointTPKeyName = "T",
    SpeedrunTimer = false,

    MacroKey = Enum.KeyCode.M,

    AutoFarm = false,
    AutoFarmTargetStage = 5,
    AutoFarmUseFly = true,
    AutoFarmUseNoclip = true,
    AutoFarmUseSpeed = true,
    AutoFarmSpeedValue = 100,
    AutoFarmFlySpeed = 100,
    AutoFarmCollectRadius = 200,
    AutoFarmScanInterval = 0.3,
    AutoFarmMoveInterval = 0.1,
    AutoFarmNextStageDelay = 2,

    AntiAfk = true,
}

-- ==================== УТИЛИТЫ ====================
local function create(cls, props, children)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do o[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = o end
    return o
end

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
    return c
end

local function stroke(p, color, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(60, 60, 70)
    s.Thickness = thick or 1
    s.Transparency = trans or 0.3
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

-- ==================== КЭШ БОТОВ ====================
local botCache = {}
local botCacheLastUpdate = 0
local BOT_CACHE_INTERVAL = 1.0

local function refreshBotCache()
    if tick() - botCacheLastUpdate < BOT_CACHE_INTERVAL then return end
    botCacheLastUpdate = tick()
    for bot, _ in pairs(botCache) do
        if not bot.Parent then botCache[bot] = nil end
    end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if hum and not Players:GetPlayerFromCharacter(obj) and obj ~= LocalPlayer.Character then
                botCache[obj] = true
            end
        elseif obj:IsA("Folder") then
            for _, sub in ipairs(obj:GetChildren()) do
                if sub:IsA("Model") then
                    local hum = sub:FindFirstChildOfClass("Humanoid")
                    if hum and not Players:GetPlayerFromCharacter(sub) and sub ~= LocalPlayer.Character then
                        botCache[sub] = true
                    end
                end
            end
        end
    end
end

local function isBot(model)
    if not model or not model:IsA("Model") then return false end
    if not model:IsDescendantOf(workspace) then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    if model == LocalPlayer.Character then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return true
end

local function getBotsList()
    refreshBotCache()
    return botCache
end

local function getFOVCenter()
    local cam = Camera.ViewportSize
    return Vector2.new(cam.X / 2, cam.Y / 2)
end

-- ==================== МОБИЛЬНЫЙ GUI ====================
local ScreenGui = create("ScreenGui", {
    Name = "NexusCheat",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    DisplayOrder = 9999,
    Parent = GUI_PARENT,
})

local TracersGui = create("ScreenGui", {
    Name = "TracersGui",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 9997,
    Parent = GUI_PARENT,
})

local RadarGui = create("ScreenGui", {
    Name = "RadarGui",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 9996,
    Parent = GUI_PARENT,
})

local HitMarkerGui = create("ScreenGui", {
    Name = "HitMarkerGui",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 9999,
    Parent = GUI_PARENT,
})

-- ==================== ПЛАВАЮЩАЯ КНОПКА ОТКРЫТИЯ ====================
local OpenBtn = create("TextButton", {
    Name = "OpenBtn",
    Size = UDim2.new(0, 60, 0, 60),
    Position = UDim2.new(1, -80, 0, 100),
    BackgroundColor3 = Color3.fromRGB(0, 170, 255),
    Text = "⚡",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 28,
    BorderSizePixel = 0,
    Active = true,
    Draggable = true,
    Parent = ScreenGui,
})
corner(OpenBtn, 30)
stroke(OpenBtn, Color3.fromRGB(255, 255, 255), 2, 0.3)

-- ==================== КНОПКА AIMBOT НА ЭКРАНЕ ====================
local AimBtn = create("TextButton", {
    Name = "AimBtn",
    Size = UDim2.new(0, 70, 0, 70),
    Position = UDim2.new(1, -90, 0, 180),
    BackgroundColor3 = Color3.fromRGB(200, 50, 60),
    Text = "🎯",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 32,
    BorderSizePixel = 0,
    Active = true,
    Draggable = true,
    Visible = true,
    Parent = ScreenGui,
})
corner(AimBtn, 35)
stroke(AimBtn, Color3.fromRGB(255, 255, 255), 2, 0.3)

-- ==================== ГЛАВНОЕ ОКНО ====================
local Main = create("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 500, 0, 450),
    Position = UDim2.new(0.5, -250, 0.5, -225),
    BackgroundColor3 = Color3.fromRGB(18, 18, 22),
    BorderSizePixel = 0,
    Active = true,
    Draggable = true,
    Parent = ScreenGui,
})
corner(Main, 12)
stroke(Main, Color3.fromRGB(0, 170, 255), 2, 0.2)

local Header = create("Frame", {
    Size = UDim2.new(1, 0, 0, 46),
    BackgroundColor3 = Color3.fromRGB(24, 24, 30),
    BorderSizePixel = 0,
    Parent = Main,
})
corner(Header, 12)
create("Frame", {
    Size = UDim2.new(1, 0, 0, 12),
    Position = UDim2.new(0, 0, 1, -12),
    BackgroundColor3 = Color3.fromRGB(24, 24, 30),
    BorderSizePixel = 0,
    Parent = Header,
})

create("TextLabel", {
    Size = UDim2.new(1, -200, 1, 0),
    Position = UDim2.new(0, 16, 0, 0),
    BackgroundTransparency = 1,
    Text = "⚡  NEXUS CHEAT MOBILE  v7.1",
    TextColor3 = Color3.fromRGB(240, 240, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Header,
})

local GameIndicator = create("TextLabel", {
    Size = UDim2.new(0, 140, 0, 26),
    Position = UDim2.new(1, -210, 0.5, -13),
    BackgroundColor3 = Color3.fromRGB(0, 170, 255),
    Text = "Игра не выбрана",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    BorderSizePixel = 0,
    Parent = Header,
})
corner(GameIndicator, 6)

-- Кнопка закрытия (большая)
local CloseBtn = create("TextButton", {
    Size = UDim2.new(0, 40, 0, 40),
    Position = UDim2.new(1, -50, 0, 3),
    BackgroundColor3 = Color3.fromRGB(200, 50, 60),
    Text = "✕",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    BorderSizePixel = 0,
    Parent = Header,
})
corner(CloseBtn, 8)
CloseBtn.MouseButton1Click:Connect(function()
    Config.MenuOpen = false
    Main.Visible = false
end)

-- ==================== ВКЛАДКИ (большие) ====================
local TabsFrame = create("Frame", {
    Size = UDim2.new(0, 130, 1, -60),
    Position = UDim2.new(0, 12, 0, 56),
    BackgroundTransparency = 1,
    Parent = Main,
})
create("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = TabsFrame,
})

local ContentFrame = create("Frame", {
    Size = UDim2.new(1, -160, 1, -70),
    Position = UDim2.new(0, 150, 0, 58),
    BackgroundColor3 = Color3.fromRGB(22, 22, 28),
    BorderSizePixel = 0,
    Parent = Main,
})
corner(ContentFrame, 10)
stroke(ContentFrame, Color3.fromRGB(50, 50, 60), 1, 0.5)

local TabButtons = {}
local Pages = {}

local function createTabButton(name, icon)
    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Color3.fromRGB(28, 28, 34),
        Text = "  " .. icon .. "  " .. name,
        TextColor3 = Color3.fromRGB(200, 200, 220),
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = TabsFrame,
    })
    corner(btn, 8)
    local s = stroke(btn, Color3.fromRGB(60, 60, 75), 1, 0.5)

    local page = create("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = ContentFrame,
    })
    create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page,
    })
    create("UIPadding", { PaddingRight = UDim.new(0, 8), Parent = page })

    local tabData = { btn = btn, stroke = s, name = name, page = page }
    table.insert(TabButtons, tabData)
    Pages[name] = page

    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(TabButtons) do
            t.page.Visible = false
            t.btn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
            t.btn.TextColor3 = Color3.fromRGB(200, 200, 220)
            t.stroke.Color = Color3.fromRGB(60, 60, 75)
        end
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        s.Color = Color3.fromRGB(0, 200, 255)
    end)

    return page, tabData
end

local function showTab(name)
    for _, t in ipairs(TabButtons) do
        if t.name == name then
            for _, t2 in ipairs(TabButtons) do
                t2.page.Visible = false
                t2.btn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
                t2.btn.TextColor3 = Color3.fromRGB(200, 200, 220)
                t2.stroke.Color = Color3.fromRGB(60, 60, 75)
            end
            t.page.Visible = true
            t.btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            t.btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            t.stroke.Color = Color3.fromRGB(0, 200, 255)
            return
        end
    end
end

local stopSpin, stopFling, stopKillAura, stopAutoShoot, stopAutoPickup, stopGodMode, stopAutoFarm, stopHighJump
local stopCharSpin, stopBunnyHop, stopThirdPerson, stopSilentAim, stopGhostMode, stopAutoShootBots

local function clearNonMainTabs()
    if Config.Spin and stopSpin then Config.Spin = false; stopSpin() end
    if Config.CharSpin and stopCharSpin then Config.CharSpin = false; stopCharSpin() end
    if Config.BunnyHop and stopBunnyHop then Config.BunnyHop = false; stopBunnyHop() end
    if Config.ThirdPerson and stopThirdPerson then Config.ThirdPerson = false; stopThirdPerson() end
    if Config.SilentAim and stopSilentAim then Config.SilentAim = false; stopSilentAim() end
    if Config.GhostMode and stopGhostMode then Config.GhostMode = false; stopGhostMode() end
    if Config.AutoShootBots and stopAutoShootBots then Config.AutoShootBots = false; stopAutoShootBots() end
    if Config.KillAura and stopKillAura then Config.KillAura = false; stopKillAura() end
    if Config.AimbotAutoShootMurderer and stopAutoShoot then Config.AimbotAutoShootMurderer = false; stopAutoShoot() end
    if Config.AutoPickupGun and stopAutoPickup then Config.AutoPickupGun = false; stopAutoPickup() end
    if Config.GodMode and stopGodMode then Config.GodMode = false; stopGodMode() end
    if Config.AutoFarm and stopAutoFarm then Config.AutoFarm = false; stopAutoFarm() end
    if stopHighJump then stopHighJump() end
    if stopFling then stopFling() end
    for i = #TabButtons, 1, -1 do
        local t = TabButtons[i]
        if t.name ~= "Главная" then
            t.btn:Destroy()
            t.page:Destroy()
            Pages[t.name] = nil
            table.remove(TabButtons, i)
        end
    end
end

-- ==================== UI ЭЛЕМЕНТЫ (большие под палец) ====================
local function sectionLabel(parent, text)
    return create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(0, 170, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = parent,
    })
end

local function toggle(parent, text, default, callback)
    local state = default or false
    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Color3.fromRGB(28, 28, 34),
        BorderSizePixel = 0,
        Parent = parent,
    })
    corner(frame, 8)
    stroke(frame, Color3.fromRGB(55, 55, 65), 1, 0.5)

    create("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(220, 220, 235),
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    local switch = create("Frame", {
        Size = UDim2.new(0, 52, 0, 28),
        Position = UDim2.new(1, -64, 0.5, -14),
        BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 60),
        BorderSizePixel = 0,
        Parent = frame,
    })
    corner(switch, 14)

    local knob = create("Frame", {
        Size = UDim2.new(0, 22, 0, 22),
        Position = state and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent = switch,
    })
    corner(knob, 11)

    local clickArea = create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = frame,
    })

    local function update(v)
        state = v
        if callback then callback(v) end
        switch.BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 60)
        knob.Position = state and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
    end

    clickArea.MouseButton1Click:Connect(function() update(not state) end)
    return { set = update, get = function() return state end }
end

local function slider(parent, text, min, max, default, callback)
    local value = default or min
    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = Color3.fromRGB(28, 28, 34),
        BorderSizePixel = 0,
        Parent = parent,
    })
    corner(frame, 8)
    stroke(frame, Color3.fromRGB(55, 55, 65), 1, 0.5)

    create("TextLabel", {
        Size = UDim2.new(1, -100, 0, 20),
        Position = UDim2.new(0, 12, 0, 6),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(220, 220, 235),
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    local valLbl = create("TextLabel", {
        Size = UDim2.new(0, 80, 0, 20),
        Position = UDim2.new(1, -92, 0, 6),
        BackgroundTransparency = 1,
        Text = tostring(value),
        TextColor3 = Color3.fromRGB(0, 170, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = frame,
    })

    local barBg = create("Frame", {
        Size = UDim2.new(1, -24, 0, 12),
        Position = UDim2.new(0, 12, 1, -22),
        BackgroundColor3 = Color3.fromRGB(45, 45, 55),
        BorderSizePixel = 0,
        Parent = frame,
    })
    corner(barBg, 6)

    local fill = create("Frame", {
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 170, 255),
        BorderSizePixel = 0,
        Parent = barBg,
    })
    corner(fill, 6)

    local knob = create("Frame", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new((value - min) / (max - min), 0, 0.5, -10),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent = barBg,
    })
    corner(knob, 10)

    local dragging = false
    local function setFromX(x)
        local rel = math.clamp((x - barBg.AbsolutePosition.X) / math.max(barBg.AbsoluteSize.X, 1), 0, 1)
        value = math.floor(min + (max - min) * rel)
        valLbl.Text = tostring(value)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, -10)
        if callback then callback(value) end
    end

    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = barBg,
    })
    btn.MouseButton1Down:Connect(function() dragging = true; setFromX(Mouse.X) end)
    btn.MouseButton1Up:Connect(function() dragging = false end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    return { set = function(v)
        value = v
        local rel = (v - min) / (max - min)
        valLbl.Text = tostring(v)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, -10)
    end, get = function() return value end }
end

local function dropdown(parent, text, options, default, callback)
    local current = default or options[1]
    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Color3.fromRGB(28, 28, 34),
        BorderSizePixel = 0,
        ClipsDescendants = false,
        ZIndex = 100,
        Parent = parent,
    })
    corner(frame, 8)
    stroke(frame, Color3.fromRGB(55, 55, 65), 1, 0.5)

    create("TextLabel", {
        Size = UDim2.new(0.45, 0, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(220, 220, 235),
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 101,
        Parent = frame,
    })

    local btn = create("TextButton", {
        Size = UDim2.new(0.5, 0, 0, 32),
        Position = UDim2.new(1, -12, 0.5, -16),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Color3.fromRGB(40, 40, 50),
        Text = current .. "  ▾",
        TextColor3 = Color3.fromRGB(220, 220, 235),
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        BorderSizePixel = 0,
        ZIndex = 101,
        Parent = frame,
    })
    corner(btn, 6)

    local list = create("Frame", {
        Size = UDim2.new(1, 0, 0, math.min(#options, 6) * 34 + 8),
        Position = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = Color3.fromRGB(28, 28, 34),
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 999,
        Parent = frame,
    })
    corner(list, 8)
    stroke(list, Color3.fromRGB(0, 170, 255), 1, 0.3)
    create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = list,
    })
    create("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        Parent = list,
    })

    local function refresh(opts)
        for _, c in ipairs(list:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        list.Size = UDim2.new(1, 0, 0, math.min(#opts, 6) * 34 + 8)
        for _, opt in ipairs(opts) do
            local ob = create("TextButton", {
                Size = UDim2.new(1, -8, 0, 32),
                BackgroundColor3 = Color3.fromRGB(40, 40, 50),
                Text = opt,
                TextColor3 = Color3.fromRGB(220, 220, 235),
                Font = Enum.Font.Gotham,
                TextSize = 13,
                BorderSizePixel = 0,
                ZIndex = 1000,
                Parent = list,
            })
            corner(ob, 6)
            ob.MouseButton1Click:Connect(function()
                current = opt
                btn.Text = current .. "  ▾"
                list.Visible = false
                if callback then callback(opt) end
            end)
        end
    end

    refresh(options)

    btn.MouseButton1Click:Connect(function()
        list.Visible = not list.Visible
        if list.Visible then
            list.ZIndex = 999
            for _, c in ipairs(list:GetChildren()) do
                c.ZIndex = 1000
            end
        end
    end)

    return { get = function() return current end, refresh = refresh }
end

local function button(parent, text, callback, color)
    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = color or Color3.fromRGB(40, 100, 180),
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Parent = parent,
    })
    corner(btn, 8)
    stroke(btn, Color3.fromRGB(0, 170, 255), 1, 0.3)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function keyBinder(parent, text, defaultName, callback)
    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Color3.fromRGB(28, 28, 34),
        BorderSizePixel = 0,
        Parent = parent,
    })
    corner(frame, 8)
    stroke(frame, Color3.fromRGB(55, 55, 65), 1, 0.5)

    create("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(220, 220, 235),
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    local btn = create("TextButton", {
        Size = UDim2.new(0.45, 0, 0, 32),
        Position = UDim2.new(1, -12, 0.5, -16),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Color3.fromRGB(40, 40, 50),
        Text = defaultName or "Назначить",
        TextColor3 = Color3.fromRGB(220, 220, 235),
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        BorderSizePixel = 0,
        Parent = frame,
    })
    corner(btn, 6)
    stroke(btn, Color3.fromRGB(0, 170, 255), 1, 0.5)

    local listening = false

    btn.MouseButton1Click:Connect(function()
        listening = true
        btn.Text = "Нажми клавишу..."
        btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not listening then return end
        if gpe then return end

        local newKey, name
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            newKey = Enum.UserInputType.MouseButton1; name = "ЛКМ"
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            newKey = Enum.UserInputType.MouseButton2; name = "ПКМ"
        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
            newKey = Enum.UserInputType.MouseButton3; name = "СКМ"
        elseif input.UserInputType == Enum.UserInputType.Touch then
            newKey = Enum.UserInputType.Touch; name = "Касание"
        elseif input.UserInputType == Enum.UserInputType.Keyboard then
            newKey = input.KeyCode; name = input.KeyCode.Name
        else
            return
        end

        listening = false
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        if callback then callback(newKey, name) end
    end)
end

-- ==================== ПЛАВАЮЩИЕ КНОПКИ (мобильная фича) ====================
OpenBtn.MouseButton1Click:Connect(function()
    Config.MenuOpen = not Config.MenuOpen
    Main.Visible = Config.MenuOpen
end)

-- При перетаскивании OpenBtn — обновляем позицию
OpenBtn.MouseButton1Down:Connect(function()
    -- Roblox сам обрабатывает Draggable
end)

-- Кнопка Aimbot — активация удержанием
local aimBtnHeld = false

AimBtn.MouseButton1Down:Connect(function()
    aimBtnHeld = true
    AimBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
end)

AimBtn.MouseButton1Up:Connect(function()
    aimBtnHeld = false
    AimBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 60)
end)

-- Также обрабатываем касания (touch)
AimBtn.TouchLongPress:Connect(function()
    aimBtnHeld = true
    AimBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
end)

UserInputService.TouchEnded:Connect(function(input)
    if aimBtnHeld then
        aimBtnHeld = false
        AimBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 60)
    end
end)

-- ==================== ТРЕТЬЕ ЛИЦО ====================
local thirdPersonActive = false
local thirdPersonConn = nil

local function enableThirdPerson()
    if thirdPersonActive then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myHum = myChar:FindFirstChildOfClass("Humanoid")
    if not myHum then return end

    pcall(function() LocalPlayer.CameraMode = Enum.CameraMode.Classic end)
    pcall(function() LocalPlayer.CameraMaxZoomDistance = 128 end)
    pcall(function() LocalPlayer.CameraMinZoomDistance = 0.5 end)
    pcall(function() Camera.CameraType = Enum.CameraType.Custom end)
    pcall(function() Camera.CameraSubject = myHum end)

    thirdPersonActive = true

    if thirdPersonConn then thirdPersonConn:Disconnect() end
    thirdPersonConn = RunService.RenderStepped:Connect(function()
        if not thirdPersonActive then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    part.LocalTransparencyModifier = 0
                    if part.Transparency == 1 then part.Transparency = 0 end
                end)
            elseif part:IsA("Decal") then
                pcall(function()
                    if part.Transparency == 1 then part.Transparency = 0 end
                end)
            end
        end

        if Camera.CameraSubject ~= hum then
            pcall(function() Camera.CameraSubject = hum end)
        end
        if LocalPlayer.CameraMode ~= Enum.CameraMode.Classic then
            pcall(function() LocalPlayer.CameraMode = Enum.CameraMode.Classic end)
        end

        local camDist = (Camera.CFrame.Position - hrp.Position).Magnitude
        if camDist < 4 then
            local currentLook = Camera.CFrame.LookVector
            local targetPos = hrp.Position - currentLook * Config.ThirdPersonDistance + Vector3.new(0, 2, 0)
            local lookAt = hrp.Position + Vector3.new(0, 1, 0)
            pcall(function()
                Camera.CFrame = CFrame.lookAt(targetPos, lookAt)
            end)
        end
    end)
end

function disableThirdPerson()
    if not thirdPersonActive then return end
    if thirdPersonConn then
        thirdPersonConn:Disconnect()
        thirdPersonConn = nil
    end
    pcall(function()
        LocalPlayer.CameraMaxZoomDistance = 128
        LocalPlayer.CameraMinZoomDistance = 0.5
    end)
    thirdPersonActive = false
end

stopThirdPerson = function() disableThirdPerson() end

-- ==================== TRACERS ====================
local tracersList = {}

local function clearTracers()
    for key, t in pairs(tracersList) do
        if t.line and t.line.Parent then t.line:Destroy() end
        if t.dot and t.dot.Parent then t.dot:Destroy() end
    end
    tracersList = {}
end

local function updateTracers()
    if not Config.Tracers then
        if next(tracersList) then clearTracers() end
        return
    end

    local topY = 0
    local activeKeys = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local head = char:FindFirstChild("Head")
            if hum and hum.Health > 0 and head then
                local isTeam = Config.ESP_TeamCheck and LocalPlayer.Team and player.Team == LocalPlayer.Team
                if not isTeam then
                    local sp, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen and sp.Z > 0 then
                        local key = "p_" .. player.Name
                        activeKeys[key] = true
                        if not tracersList[key] then
                            local line = create("Frame", {
                                BackgroundColor3 = Config.TracersColor,
                                BorderSizePixel = 0,
                                ZIndex = 2,
                                Parent = TracersGui,
                            })
                            local dot = create("Frame", {
                                Size = UDim2.new(0, 10, 0, 10),
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundColor3 = Config.TracersColor,
                                BorderSizePixel = 0,
                                ZIndex = 3,
                                Parent = TracersGui,
                            })
                            corner(dot, 5)
                            tracersList[key] = { line = line, dot = dot }
                        end
                        local t = tracersList[key]
                        t.line.Visible = true
                        t.dot.Visible = true
                        t.line.Position = UDim2.new(0, sp.X, 0, topY)
                        t.line.Size = UDim2.new(0, Config.TracersThickness, 0, math.abs(sp.Y - topY))
                        t.line.BackgroundColor3 = Config.TracersColor
                        t.dot.Position = UDim2.new(0, sp.X, 0, sp.Y)
                        t.dot.BackgroundColor3 = Config.TracersColor
                    end
                end
            end
        end
    end

    for key, t in pairs(tracersList) do
        if not activeKeys[key] then
            if t.line and t.line.Parent then t.line:Destroy() end
            if t.dot and t.dot.Parent then t.dot:Destroy() end
            tracersList[key] = nil
        end
    end
end

-- ==================== RADAR ====================
local RadarFrame = nil
local RadarDots = {}

local function createRadar()
    if RadarFrame then RadarFrame:Destroy() end
    RadarFrame = create("Frame", {
        Size = UDim2.new(0, Config.RadarSize, 0, Config.RadarSize),
        Position = UDim2.new(0, 15, 0, 200),
        BackgroundColor3 = Color3.fromRGB(15, 15, 20),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 10,
        Parent = RadarGui,
    })
    corner(RadarFrame, Config.RadarSize / 2)
    stroke(RadarFrame, Color3.fromRGB(0, 170, 255), 2, 0)

    create("Frame", {
        Size = UDim2.new(0, 8, 0, 8),
        Position = UDim2.new(0.5, -4, 0.5, -4),
        BackgroundColor3 = Color3.fromRGB(0, 255, 0),
        BorderSizePixel = 0,
        ZIndex = 11,
        Parent = RadarFrame,
    })
    corner(RadarFrame:FindFirstChildOfClass("Frame") or RadarFrame, 4)

    RadarDots = {}
end

local function updateRadar()
    if not Config.Radar then
        if RadarFrame then RadarFrame.Visible = false end
        return
    end
    if not RadarFrame then createRadar() end
    RadarFrame.Visible = true
    RadarFrame.Size = UDim2.new(0, Config.RadarSize, 0, Config.RadarSize)

    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local myPos = myRoot.Position
    local range = Config.RadarRange

    for name, dot in pairs(RadarDots) do
        if dot and dot.Parent then dot:Destroy() end
        RadarDots[name] = nil
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and root then
                local diff = root.Position - myPos
                local dist = math.sqrt(diff.X * diff.X + diff.Z * diff.Z)
                if dist <= range then
                    local px = (diff.X / range) * (Config.RadarSize / 2)
                    local py = (diff.Z / range) * (Config.RadarSize / 2)
                    local isTeam = Config.ESP_TeamCheck and LocalPlayer.Team and player.Team == LocalPlayer.Team
                    local color = isTeam and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
                    local dot = create("Frame", {
                        Size = UDim2.new(0, 6, 0, 6),
                        Position = UDim2.new(0.5, px - 3, 0.5, py - 3),
                        BackgroundColor3 = color,
                        BorderSizePixel = 0,
                        ZIndex = 12,
                        Parent = RadarFrame,
                    })
                    corner(dot, 3)
                    RadarDots[player.Name] = dot
                end
            end
        end
    end
end

-- ==================== FOOTSTEP ESP ====================
local footstepIndicators = {}
local footstepConn = nil

local function startFootstepESP()
    if footstepConn then return end
    footstepConn = RunService.RenderStepped:Connect(function()
        if not Config.FootstepESP then
            for _, ind in pairs(footstepIndicators) do
                if ind and ind.Parent then ind:Destroy() end
            end
            footstepIndicators = {}
            return
        end

        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        local viewport = Camera.ViewportSize
        local cx = viewport.X / 2
        local cy = viewport.Y / 2
        local foundSounds = {}

        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Sound") and obj.IsPlaying then
                local n = obj.Name:lower()
                if n:find("step") or n:find("walk") or n:find("foot") then
                    table.insert(foundSounds, obj)
                end
            end
        end

        for i, sound in ipairs(foundSounds) do
            local parent = sound.Parent
            if parent and parent:IsA("BasePart") then
                local diff = parent.Position - myRoot.Position
                local angle = math.atan2(diff.X, diff.Z) - math.atan2(Camera.CFrame.LookVector.X, Camera.CFrame.LookVector.Z)
                local radius = 150
                local px = cx + math.sin(angle) * radius
                local py = cy - math.cos(angle) * radius

                if not footstepIndicators[sound] then
                    local ind = create("Frame", {
                        Size = UDim2.new(0, 40, 0, 40),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Config.FootstepColor,
                        BackgroundTransparency = 0.5,
                        BorderSizePixel = 0,
                        Parent = ScreenGui,
                    })
                    corner(ind, 20)
                    footstepIndicators[sound] = ind
                end
                local ind = footstepIndicators[sound]
                if ind then ind.Position = UDim2.new(0, px, 0, py) end
            end
        end

        for sound, ind in pairs(footstepIndicators) do
            local stillPlaying = false
            for _, s in ipairs(foundSounds) do
                if s == sound then stillPlaying = true; break end
            end
            if not stillPlaying then
                if ind and ind.Parent then ind:Destroy() end
                footstepIndicators[sound] = nil
            end
        end
    end)
end

-- ==================== DAMAGE NUMBERS ====================
local function showDamageNumber(position, amount, color)
    if not Config.DamageNumbers then return end
    local sp, onScreen = Camera:WorldToViewportPoint(position)
    if not onScreen then return end

    local label = create("TextLabel", {
        Size = UDim2.new(0, 100, 0, 30),
        Position = UDim2.new(0, sp.X - 50, 0, sp.Y - 30),
        BackgroundTransparency = 1,
        Text = tostring(amount),
        TextColor3 = color or Color3.fromRGB(255, 50, 50),
        TextStrokeTransparency = 0,
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        ZIndex = 100,
        Parent = ScreenGui,
    })

    task.spawn(function()
        local st = tick()
        while tick() - st < Config.DamageNumbersDuration do
            if label and label.Parent then
                local e = tick() - st
                label.Position = label.Position - UDim2.new(0, 0, 0, 1)
                label.TextTransparency = e / Config.DamageNumbersDuration
                label.TextStrokeTransparency = e / Config.DamageNumbersDuration
            end
            task.wait(0.03)
        end
        if label then label:Destroy() end
    end)
end

-- ==================== HIT MARKER ====================
local function showHitMarker()
    if not Config.HitMarker then return end
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y / 2

    for i = 0, 3 do
        local angle = i * 90 + 45
        local rad = math.rad(angle)
        local marker = create("Frame", {
            Size = UDim2.new(0, 3, 0, 16),
            Position = UDim2.new(0, cx + math.cos(rad) * 20, 0, cy + math.sin(rad) * 20),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Rotation = angle + 90,
            BackgroundColor3 = Config.HitMarkerColor,
            BorderSizePixel = 0,
            Parent = HitMarkerGui,
        })
        task.spawn(function()
            task.wait(0.15)
            if marker then marker:Destroy() end
        end)
    end
end

-- ==================== AUTO-SHOOT BOTS ====================
local autoShootBotsConn = nil
local lastAutoShootBots = 0

local function findClosestBotForAutoShoot()
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local center = getFOVCenter()
    local best, bestDist = nil, Config.AutoShootBotsFOV
    local botsList = getBotsList()

    for bot, _ in pairs(botsList) do
        if isBot(bot) then
            local hum = bot:FindFirstChildOfClass("Humanoid")
            local head = bot:FindFirstChild("Head")
            if hum and hum.Health > 0 and head then
                local sp, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen and sp.Z > 0 then
                    local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if dist < bestDist then
                        best = { bot = bot, hum = hum, part = head, char = bot }
                        bestDist = dist
                    end
                end
            end
        end
    end
    return best
end

function startAutoShootBots()
    if autoShootBotsConn then return end
    autoShootBotsConn = RunService.Heartbeat:Connect(function()
        if not Config.AutoShootBots then return end
        if tick() - lastAutoShootBots < Config.AutoShootBotsDelay then return end
        local target = findClosestBotForAutoShoot()
        if not target then return end
        lastAutoShootBots = tick()
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.part.Position)
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then pcall(function() tool:Activate() end) end
        if mouse1click then pcall(mouse1click) end
    end)
end

stopAutoShootBots = function()
    if autoShootBotsConn then autoShootBotsConn:Disconnect(); autoShootBotsConn = nil end
end

-- ==================== CHECKPOINT TP ====================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Config.CheckpointTPKey and Config.CheckpointTP then
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        local bestAbove, bestDist = nil, math.huge
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local n = obj.Name:lower()
                if n:find("checkpoint") or n:find("чек") or n:find("finish") or n:find("top") then
                    local pos = obj:IsA("BasePart") and obj.Position or (obj.PrimaryPart and obj.PrimaryPart.Position)
                    if pos and pos.Y > myRoot.Position.Y + 5 then
                        local dist = (myRoot.Position - pos).Magnitude
                        if dist < bestDist then bestAbove = pos; bestDist = dist end
                    end
                end
            end
        end

        if bestAbove then
            pcall(function()
                myRoot.CFrame = CFrame.new(bestAbove + Vector3.new(0, 3, 0))
                myRoot.AssemblyLinearVelocity = Vector3.zero
            end)
        end
    end
end)

-- ==================== SPEEDRUN TIMER ====================
local SRTimerGui = nil
local SRStartTime = 0
local SRActive = false

task.spawn(function()
    while task.wait(0.05) do
        if Config.SpeedrunTimer then
            if not SRTimerGui then
                SRTimerGui = create("Frame", {
                    Size = UDim2.new(0, 220, 0, 46),
                    Position = UDim2.new(0.5, -110, 0, 10),
                    BackgroundColor3 = Color3.fromRGB(15, 15, 20),
                    BackgroundTransparency = 0.3,
                    BorderSizePixel = 0,
                    ZIndex = 10,
                    Parent = ScreenGui,
                })
                corner(SRTimerGui, 8)
                stroke(SRTimerGui, Color3.fromRGB(0, 170, 255), 2, 0)
                create("TextLabel", {
                    Name = "T",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "00:00.00",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Font = Enum.Font.GothamBold,
                    TextSize = 22,
                    Parent = SRTimerGui,
                })
            end
            SRTimerGui.Visible = true
            if not SRActive then SRStartTime = tick(); SRActive = true end
            local e = tick() - SRStartTime
            local m = math.floor(e / 60)
            local s = math.floor(e % 60)
            local ms = math.floor((e * 100) % 100)
            local lbl = SRTimerGui:FindFirstChild("T")
            if lbl then lbl.Text = string.format("%02d:%02d.%02d", m, s, ms) end
        else
            if SRTimerGui then SRTimerGui.Visible = false end
            SRActive = false
        end
    end
end)

-- ==================== MACRO RECORDER ====================
local macroEvents = {}
local macroRecording = false
local macroStartTime = 0

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Config.MacroKey then
        if not macroRecording then
            macroRecording = true
            macroEvents = {}
            macroStartTime = tick()
        else
            macroRecording = false
            if #macroEvents > 0 then
                task.spawn(function()
                    for _, ev in ipairs(macroEvents) do
                        task.wait(ev.delay)
                        if ev.key then
                            pcall(function()
                                game:GetService("VirtualInputManager"):SendKeyEvent(true, ev.key, false, game)
                                task.wait(0.05)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false, ev.key, false, game)
                            end)
                        end
                    end
                end)
            end
        end
    elseif macroRecording and input.UserInputType == Enum.UserInputType.Keyboard then
        table.insert(macroEvents, { key = input.KeyCode, delay = tick() - macroStartTime })
    end
end)

-- ==================== КРУТИЛКА / BUNNY HOP ====================
local charSpinConn
local charSpinAngle = 0

function startCharSpin()
    if charSpinConn then return end
    charSpinConn = RunService.RenderStepped:Connect(function(dt)
        if not Config.CharSpin then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        if Config.CharSpinOnlyWhenMoving and hum.MoveDirection.Magnitude < 0.05 then return end
        charSpinAngle = charSpinAngle + math.rad(Config.CharSpinSpeed) * dt * 60
        if charSpinAngle > math.pi * 2 then charSpinAngle = charSpinAngle - math.pi * 2 end
        local pos = hrp.Position
        local look = Vector3.new(math.sin(charSpinAngle), 0, math.cos(charSpinAngle))
        hrp.CFrame = CFrame.new(pos, pos + look)
    end)
end

stopCharSpin = function()
    if charSpinConn then charSpinConn:Disconnect(); charSpinConn = nil end
    charSpinAngle = 0
end

local bunnyHopConn
local bunnyHopLastJump = 0
local bunnyHopSpeedBonus = 0

function startBunnyHop()
    if bunnyHopConn then return end
    bunnyHopSpeedBonus = 0
    bunnyHopConn = RunService.Heartbeat:Connect(function()
        if not Config.BunnyHop then return end
        if tick() - bunnyHopLastJump < 0.05 then return end
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myHum = myChar:FindFirstChildOfClass("Humanoid")
        local hrp = myChar:FindFirstChild("HumanoidRootPart")
        if not myHum or not hrp then return end
        local state = myHum:GetState()
        local moveDir = myHum.MoveDirection
        if moveDir.Magnitude < 0.1 then bunnyHopSpeedBonus = 0; return end
        if state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.RunningNoPhysics or state == Enum.HumanoidStateType.Landed then
            bunnyHopLastJump = tick()
            bunnyHopSpeedBonus = math.min(bunnyHopSpeedBonus + Config.BunnyHopAccel, Config.BunnyHopMaxSpeed - Config.BunnyHopBaseSpeed)
            pcall(function() myHum:ChangeState(Enum.HumanoidStateType.Jumping) end)
            local cs = Config.BunnyHopBaseSpeed + bunnyHopSpeedBonus
            pcall(function()
                hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * cs, math.max(hrp.AssemblyLinearVelocity.Y, 30), moveDir.Z * cs)
            end)
        end
        if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
            local cs = Config.BunnyHopBaseSpeed + bunnyHopSpeedBonus
            pcall(function()
                hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * cs, hrp.AssemblyLinearVelocity.Y, moveDir.Z * cs)
            end)
        end
    end)
end

stopBunnyHop = function()
    if bunnyHopConn then bunnyHopConn:Disconnect(); bunnyHopConn = nil end
    bunnyHopSpeedBonus = 0
end

-- ==================== GOD MODE ====================
local godModeHPConn, godModeMaxHealthConn, godHookInstalled = nil, nil, false

local function installGodHook()
    if godHookInstalled then return end
    godHookInstalled = true
    if getrawmetatable and setreadonly and hookmetamethod and newcclosure then
        local mt = getrawmetatable(game)
        if mt then
            local oldNamecall = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if Config.GodMode and self and typeof(self) == "Instance" and self:IsA("Humanoid") then
                    if self.Parent == LocalPlayer.Character then
                        if method == "TakeDamage" then return end
                        if method == "BreakJoints" then return end
                        if method == "ChangeState" then
                            local state = ...
                            if state == Enum.HumanoidStateType.Dead then return end
                            if state == Enum.HumanoidStateType.Physics then return end
                        end
                    end
                end
                return oldNamecall(self, ...)
            end)
            setreadonly(mt, true)
        end
    end
end

local function bindGodChar(char)
    if godModeHPConn then godModeHPConn:Disconnect(); godModeHPConn = nil end
    if godModeMaxHealthConn then godModeMaxHealthConn:Disconnect(); godModeMaxHealthConn = nil end
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    pcall(function() hum.Health = hum.MaxHealth end)
    pcall(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    end)
    if hum.MaxHealth < 100 then pcall(function() hum.MaxHealth = 100 end) end
    godModeHPConn = hum.HealthChanged:Connect(function()
        if Config.GodMode and hum.Health > 0 and hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
        if Config.GodMode and hum.Health <= 0 then pcall(function() hum.Health = hum.MaxHealth end) end
    end)
    godModeMaxHealthConn = hum:GetPropertyChangedSignal("MaxHealth"):Connect(function()
        if Config.GodMode and hum.Health > 0 then hum.Health = hum.MaxHealth end
    end)
    pcall(function()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp:SetNetworkOwner(LocalPlayer) end
    end)
end

task.spawn(function()
    while task.wait(0.05) do
        if Config.GodMode then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    if hum.Health < hum.MaxHealth then pcall(function() hum.Health = hum.MaxHealth end) end
                    if hum.Health <= 0 then pcall(function() hum.Health = hum.MaxHealth; hum:ChangeState(Enum.HumanoidStateType.Running) end) end
                end
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    if Config.GodMode then installGodHook(); bindGodChar(char) end
end)

function startGodMode()
    Config.GodMode = true
    installGodHook()
    local char = LocalPlayer.Character
    if char then bindGodChar(char) end
end

stopGodMode = function()
    if godModeHPConn then godModeHPConn:Disconnect(); godModeHPConn = nil end
    if godModeMaxHealthConn then godModeMaxHealthConn:Disconnect(); godModeMaxHealthConn = nil end
end

-- ==================== AUTO-PICKUP ====================
local autoPickupThread = nil
local autoPickupBusy = false
local autoPickupLastScan = 0

local function iHaveGun()
    local char = LocalPlayer.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return false end
    local n = tool.Name:lower()
    return n:find("gun") or n:find("sheriff") or n:find("revolver") or n:find("пистолет")
end

local function isGunName(name)
    if not name then return false end
    local n = name:lower()
    return n:find("gun") or n:find("sheriff") or n:find("revolver") or n:find("пистолет")
end

local function findAllDroppedGuns()
    local result = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Tool") and isGunName(obj.Name) then
            table.insert(result, obj)
        elseif obj:IsA("Model") or obj:IsA("Folder") then
            for _, sub in ipairs(obj:GetChildren()) do
                if sub:IsA("Tool") and isGunName(sub.Name) then
                    local parent = sub.Parent
                    if parent and not parent:IsA("Backpack") then
                        local isInChar = false
                        local p = parent
                        local depth = 0
                        while p and depth < 5 do
                            if p:IsA("Model") and Players:GetPlayerFromCharacter(p) then isInChar = true; break end
                            p = p.Parent
                            depth = depth + 1
                        end
                        if not isInChar then table.insert(result, sub) end
                    end
                end
            end
        end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local bp = plr:FindFirstChild("Backpack")
            if bp then
                for _, item in ipairs(bp:GetChildren()) do
                    if item:IsA("Tool") and isGunName(item.Name) then
                        local ownerHum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
                        if not ownerHum or ownerHum.Health <= 0 then table.insert(result, item) end
                    end
                end
            end
        end
    end
    return result
end

local function tryPickup(gun)
    if not gun or not gun.Parent then return false end
    local myChar = LocalPlayer.Character
    if not myChar then return false end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return false end
    local handle = gun:FindFirstChild("Handle") or gun:FindFirstChildWhichIsA("BasePart")
    if firetouchinterest and handle then
        pcall(function()
            firetouchinterest(myRoot, handle, 0)
            task.wait(0.01)
            firetouchinterest(myRoot, handle, 1)
        end)
    end
    if fireclickdetector then
        local cd = gun:FindFirstChildOfClass("ClickDetector")
        if cd then pcall(function() fireclickdetector(cd) end) end
    end
    if mouse1click then pcall(mouse1click) end
    if handle then
        pcall(function()
            for _, d in ipairs(gun:GetDescendants()) do
                if d:IsA("RemoteEvent") then d:FireServer(); d:FireServer(myRoot); d:FireServer(handle) end
            end
        end)
    end
    task.wait(0.05)
    local myTool = myChar:FindFirstChildOfClass("Tool")
    if myTool and isGunName(myTool.Name) then return true end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") and isGunName(item.Name) then return true end
        end
    end
    return false
end

local function performAutoPickup()
    if autoPickupBusy then return end
    if iHaveGun() then return end
    if tick() - autoPickupLastScan < 0.3 then return end
    autoPickupLastScan = tick()
    local guns = findAllDroppedGuns()
    if #guns == 0 then return end
    autoPickupBusy = true
    local myChar = LocalPlayer.Character
    if not myChar then autoPickupBusy = false return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then autoPickupBusy = false return end
    local savedCF = myRoot.CFrame
    local savedV = myRoot.AssemblyLinearVelocity
    for _, gun in ipairs(guns) do
        if iHaveGun() then break end
        if gun and gun.Parent then
            local handle = gun:FindFirstChild("Handle") or gun:FindFirstChildWhichIsA("BasePart")
            if handle then
                pcall(function()
                    myRoot.CFrame = CFrame.new(handle.Position + Vector3.new(0, 1, 0))
                    myRoot.AssemblyLinearVelocity = Vector3.zero
                end)
                task.wait(0.05)
                tryPickup(gun)
                task.wait(0.04)
            end
        end
    end
    pcall(function()
        myRoot.CFrame = savedCF
        myRoot.AssemblyLinearVelocity = savedV
    end)
    autoPickupBusy = false
end

function startAutoPickup()
    if autoPickupThread then return end
    autoPickupLastScan = 0
    autoPickupThread = task.spawn(function()
        while task.wait(0.4) do
            if not Config.AutoPickupGun then autoPickupThread = nil; return end
            if Config.Game ~= "MM2" then autoPickupThread = nil; return end
            if autoPickupBusy then continue end
            if iHaveGun() then continue end
            performAutoPickup()
        end
    end)
end

stopAutoPickup = function()
    autoPickupThread = nil
    autoPickupBusy = false
end

-- ==================== ESP ====================
local espObjects = {}
local espBots = {}

local function createESP(player)
    if player == LocalPlayer or espObjects[player] then return end

    local highlight = create("Highlight", {
        FillColor = Config.ESP_Color,
        OutlineColor = Color3.fromRGB(255, 255, 255),
        FillTransparency = 0.6,
        OutlineTransparency = 0,
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
        Parent = ScreenGui,
    })

    local bb = create("BillboardGui", {
        Size = UDim2.new(0, 220, 0, 60),
        StudsOffset = Vector3.new(0, 2.5, 0),
        AlwaysOnTop = true,
        LightInfluence = 0,
        Parent = ScreenGui,
    })

    local nameLbl = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextStrokeTransparency = 0,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Parent = bb,
    })

    local hpLbl = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 18),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(0, 255, 100),
        TextStrokeTransparency = 0,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Parent = bb,
    })

    local distLbl = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 32),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(180, 180, 255),
        TextStrokeTransparency = 0,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        Parent = bb,
    })

    local box = create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        Parent = ScreenGui,
    })
    stroke(box, Config.ESP_Color, 1.5, 0)

    espObjects[player] = { highlight = highlight, bb = bb, nameLbl = nameLbl, hpLbl = hpLbl, distLbl = distLbl, box = box, role = "Unknown" }
end

local function createBotESP(botModel)
    if espBots[botModel] then return end
    local highlight = create("Highlight", {
        FillColor = Config.ESP_BotColor,
        OutlineColor = Color3.fromRGB(255, 255, 255),
        FillTransparency = 0.6,
        OutlineTransparency = 0,
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
        Parent = ScreenGui,
    })
    local bb = create("BillboardGui", {
        Size = UDim2.new(0, 220, 0, 60),
        StudsOffset = Vector3.new(0, 2.5, 0),
        AlwaysOnTop = true,
        LightInfluence = 0,
        Parent = ScreenGui,
    })
    local nameLbl = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = "🤖 BOT",
        TextColor3 = Config.ESP_BotColor,
        TextStrokeTransparency = 0,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Parent = bb,
    })
    local hpLbl = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 18),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(0, 255, 100),
        TextStrokeTransparency = 0,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Parent = bb,
    })
    local distLbl = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 32),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(180, 180, 255),
        TextStrokeTransparency = 0,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        Parent = bb,
    })
    local box = create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        Parent = ScreenGui,
    })
    stroke(box, Config.ESP_BotColor, 1.5, 0)
    espBots[botModel] = { highlight = highlight, bb = bb, nameLbl = nameLbl, hpLbl = hpLbl, distLbl = distLbl, box = box }
end

local function removeESP(player)
    local d = espObjects[player]
    if not d then return end
    for _, o in pairs(d) do if typeof(o) == "Instance" then o:Destroy() end end
    espObjects[player] = nil
end

local function removeBotESP(botModel)
    local d = espBots[botModel]
    if not d then return end
    for _, o in pairs(d) do if typeof(o) == "Instance" then o:Destroy() end end
    espBots[botModel] = nil
end

local function getBox(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not hrp or not head then return nil end
    local hp, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local rp = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
    if not onScreen or rp.Z < 0 then return nil end
    local h = math.abs(hp.Y - rp.Y)
    local w = h * 0.55
    return { x = hp.X - w / 2, y = hp.Y, w = w, h = h }
end

local function detectMM2Role(player)
    local char = player.Character
    if not char then return "Unknown" end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local n = tool.Name:lower()
            if n:find("knife") or n:find("murder") or n:find("нож") then return "Murderer" end
            if n:find("gun") or n:find("sheriff") or n:find("revolver") then return "Sheriff" end
        end
    end
    if char:GetAttribute("Role") then
        local r = char:GetAttribute("Role")
        if r == "Murderer" or r == "Sheriff" or r == "Innocent" then return r end
    end
    return "Innocent"
end

local function getMM2Color(role)
    if role == "Murderer" then return Config.MM2_MurdererColor end
    if role == "Sheriff" then return Config.MM2_SheriffColor end
    if role == "Innocent" then return Config.MM2_InnocentColor end
    return Config.ESP_Color
end

local function updatePlayerESP(player, d)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head"))
    local isTeam = Config.ESP_TeamCheck and LocalPlayer.Team and player.Team == LocalPlayer.Team
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tooFar = false
    if myRoot and hrp then tooFar = (myRoot.Position - hrp.Position).Magnitude > Config.ESP_MaxDistance end

    if char and hum and hum.Health > 0 and hrp and not isTeam and not tooFar then
        local color = Config.ESP_Color
        local roleText = ""
        if Config.MM2ESP and Config.Game == "MM2" then
            local role = detectMM2Role(player)
            d.role = role
            color = getMM2Color(role)
            roleText = " [" .. role .. "]"
        end
        d.highlight.Adornee = Config.ESP_Highlight and char or nil
        d.highlight.FillColor = color
        d.highlight.OutlineColor = color
        d.bb.Adornee = hrp
        d.bb.Enabled = Config.ESP_Name or Config.ESP_Health or Config.ESP_Distance
        d.nameLbl.Visible = Config.ESP_Name
        d.nameLbl.Text = player.Name .. roleText
        d.nameLbl.TextColor3 = color
        d.hpLbl.Visible = Config.ESP_Health
        d.hpLbl.Text = "❤ " .. math.floor(hum.Health)
        local ratio = hum.Health / math.max(hum.MaxHealth, 1)
        if not (Config.MM2ESP and Config.Game == "MM2") then
            d.hpLbl.TextColor3 = Color3.fromRGB(255 * (1 - ratio), 255 * ratio, 60)
        else
            d.hpLbl.TextColor3 = color
        end
        d.distLbl.Visible = Config.ESP_Distance
        if myRoot then
            local dist = (myRoot.Position - hrp.Position).Magnitude
            d.distLbl.Text = math.floor(dist) .. " studs"
        end
        if Config.ESP_Box then
            local b = getBox(char)
            if b then
                d.box.Visible = true
                d.box.Position = UDim2.new(0, b.x, 0, b.y)
                d.box.Size = UDim2.new(0, b.w, 0, b.h)
                d.box:FindFirstChildOfClass("UIStroke").Color = color
            else d.box.Visible = false end
        else d.box.Visible = false end
    else
        d.highlight.Adornee = nil
        d.bb.Adornee = nil
        d.box.Visible = false
    end
end

local function updateBotESP(botModel, d)
    local hum = botModel:FindFirstChildOfClass("Humanoid")
    local hrp = botModel:FindFirstChild("HumanoidRootPart") or botModel:FindFirstChild("Head")
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tooFar = false
    if myRoot and hrp then tooFar = (myRoot.Position - hrp.Position).Magnitude > Config.ESP_MaxDistance end
    if hum and hum.Health > 0 and hrp and not tooFar then
        local color = Config.ESP_BotColor
        d.highlight.Adornee = Config.ESP_Highlight and botModel or nil
        d.highlight.FillColor = color
        d.highlight.OutlineColor = color
        d.bb.Adornee = hrp
        d.bb.Enabled = Config.ESP_Name or Config.ESP_Health or Config.ESP_Distance
        d.nameLbl.Visible = Config.ESP_Name
        d.nameLbl.Text = "🤖 " .. botModel.Name
        d.nameLbl.TextColor3 = color
        d.hpLbl.Visible = Config.ESP_Health
        d.hpLbl.Text = "❤ " .. math.floor(hum.Health)
        local ratio = hum.Health / math.max(hum.MaxHealth, 1)
        d.hpLbl.TextColor3 = Color3.fromRGB(255 * (1 - ratio), 255 * ratio, 60)
        d.distLbl.Visible = Config.ESP_Distance
        if myRoot then
            local dist = (myRoot.Position - hrp.Position).Magnitude
            d.distLbl.Text = math.floor(dist) .. " studs"
        end
        if Config.ESP_Box then
            local b = getBox(botModel)
            if b then
                d.box.Visible = true
                d.box.Position = UDim2.new(0, b.x, 0, b.y)
                d.box.Size = UDim2.new(0, b.w, 0, b.h)
                d.box:FindFirstChildOfClass("UIStroke").Color = color
            else d.box.Visible = false end
        else d.box.Visible = false end
    else
        d.highlight.Adornee = nil
        d.bb.Adornee = nil
        d.box.Visible = false
    end
end

local function updateESP()
    for player, d in pairs(espObjects) do updatePlayerESP(player, d) end
    if Config.ESP_Bots then
        local botsList = getBotsList()
        for bot, _ in pairs(botsList) do
            if not espBots[bot] then createBotESP(bot) end
        end
        for bot, _ in pairs(espBots) do
            if not bot.Parent then removeBotESP(bot) end
        end
        for botModel, d in pairs(espBots) do
            if botModel.Parent then updateBotESP(botModel, d) end
        end
    else
        for botModel, _ in pairs(espBots) do removeBotESP(botModel) end
    end
end

-- ==================== AIMBOT ====================
local FOVCircle = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 5,
    Parent = ScreenGui,
})
corner(FOVCircle, 9999)
local FovStroke = stroke(FOVCircle, Config.ESP_Color, 1.5, 0.3)

local function isVisible(part)
    local origin = Camera.CFrame.Position
    local dir = part.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    local ignore = { Camera }
    if LocalPlayer.Character then table.insert(ignore, LocalPlayer.Character) end
    local targetChar = part.Parent
    if targetChar then for _, d in ipairs(targetChar:GetDescendants()) do table.insert(ignore, d) end end
    params.FilterDescendantsInstances = ignore
    local result = workspace:Raycast(origin, dir, params)
    if not result then return true end
    return result.Instance:IsDescendantOf(targetChar)
end

local function getClosestTarget()
    local closest, closestDist = nil, Config.AimbotFOV
    local myTeam = LocalPlayer.Team
    local center = getFOVCenter()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local part = char:FindFirstChild(Config.AimbotPart)
            if not part and Config.AimbotPart ~= "Head" then part = char:FindFirstChild("Head") end
            if hum and hum.Health > 0 and part then
                local teamOk = not (Config.AimbotTeamCheck and myTeam and player.Team == myTeam)
                if teamOk then
                    local tp = part.Position
                    if Config.AimbotPrediction and part.AssemblyLinearVelocity then
                        tp = tp + part.AssemblyLinearVelocity * 0.12
                    end
                    local sp, onScreen = Camera:WorldToViewportPoint(tp)
                    if onScreen and sp.Z > 0 then
                        local distC = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if distC < closestDist then
                            if Config.AimbotWallbang or isVisible(part) then
                                closest = part
                                closestDist = distC
                            end
                        end
                    end
                end
            end
        end
    end

    if Config.Aimbot_Bots then
        local botsList = getBotsList()
        for obj, _ in pairs(botsList) do
            if isBot(obj) then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local part = obj:FindFirstChild(Config.AimbotPart)
                if not part and Config.AimbotPart ~= "Head" then part = obj:FindFirstChild("Head") end
                if hum and hum.Health > 0 and part then
                    local tp = part.Position
                    if Config.AimbotPrediction and part.AssemblyLinearVelocity then
                        tp = tp + part.AssemblyLinearVelocity * 0.12
                    end
                    local sp, onScreen = Camera:WorldToViewportPoint(tp)
                    if onScreen and sp.Z > 0 then
                        local distC = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if distC < closestDist then
                            if Config.AimbotWallbang or isVisible(part) then
                                closest = part
                                closestDist = distC
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

local aimbotKeyActive = false
local aimbotKeyHeld = false

local function isAimbotTriggered()
    -- Мобильная версия: aimBtnHeld ИЛИ клавиша
    if aimBtnHeld then return true end
    if Config.AimbotMode == "Зажать" then return aimbotKeyHeld else return aimbotKeyActive end
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Config.AimbotKey or input.KeyCode == Config.AimbotKey then
        if Config.AimbotMode == "Зажать" then aimbotKeyHeld = true else aimbotKeyActive = not aimbotKeyActive end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Config.AimbotKey or input.KeyCode == Config.AimbotKey then
        if Config.AimbotMode == "Зажать" then aimbotKeyHeld = false end
    end
end)

-- ==================== AUTO-SHOOT MURDERER (MM2) ====================
local autoShootConn = nil
local lastAutoShoot = 0

local function hasGun(player)
    local char = player.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return false end
    local n = tool.Name:lower()
    return n:find("gun") or n:find("sheriff") or n:find("revolver")
end

local function hasKnife(player)
    local char = player.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return false end
    local n = tool.Name:lower()
    return n:find("knife") or n:find("murder") or n:find("нож")
end

local function findMurdererInView()
    local best, bestDist = nil, math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local center = getFOVCenter()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local head = char:FindFirstChild("Head")
            if hum and hum.Health > 0 and head and hasKnife(player) then
                local dist3D = (myRoot.Position - head.Position).Magnitude
                if dist3D <= Config.AimbotAutoShootRange then
                    local sp, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen and sp.Z > 0 then
                        local distC = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if distC < 500 then
                            if isVisible(head) then
                                if distC < bestDist then
                                    best = { player = player, part = head, root = char:FindFirstChild("HumanoidRootPart"), char = char, hum = hum }
                                    bestDist = distC
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

local function teleportStabShoot(m)
    if not m or not m.root or not m.hum then return false end
    local myChar = LocalPlayer.Character
    if not myChar then return false end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return false end
    local tool = myChar:FindFirstChildOfClass("Tool")
    if not tool then return false end
    local savedCF = myRoot.CFrame
    local savedV = myRoot.AssemblyLinearVelocity
    pcall(function()
        myRoot.CFrame = m.root.CFrame * CFrame.new(0, 0, 2)
        myRoot.AssemblyLinearVelocity = Vector3.zero
    end)
    pcall(function() Camera.CFrame = CFrame.lookAt(myRoot.Position, m.part.Position) end)
    task.wait(0.03)
    pcall(function() tool:Activate() end)
    task.wait(0.02)
    pcall(function() if mouse1click then mouse1click() end end)
    task.wait(0.05)
    pcall(function()
        myRoot.CFrame = savedCF
        myRoot.AssemblyLinearVelocity = savedV
    end)
    return true
end

local function performAutoShoot()
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myHum = myChar:FindFirstChildOfClass("Humanoid")
    if not myHum or myHum.Health <= 0 then return end
    if not hasGun(LocalPlayer) then return end
    if tick() - lastAutoShoot < Config.AimbotAutoShootDelay then return end
    local m = findMurdererInView()
    if not m then return end
    lastAutoShoot = tick()
    teleportStabShoot(m)
end

function startAutoShoot()
    if autoShootConn then return end
    autoShootConn = RunService.RenderStepped:Connect(function()
        if not Config.AimbotAutoShootMurderer then return end
        if Config.Game ~= "MM2" then return end
        performAutoShoot()
    end)
end

stopAutoShoot = function()
    if autoShootConn then autoShootConn:Disconnect(); autoShootConn = nil end
end

-- ==================== WALLBANG ====================
local wallbangActive = false
local lastWallbang = 0

local function isAttackableModel(model)
    if not model or not model:IsA("Model") then return false end
    if not model:IsDescendantOf(workspace) then return false end
    if model == LocalPlayer.Character then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return true
end

local function findTargetByRaycast()
    local center = getFOVCenter()
    local ray = Camera:ViewportPointToRay(center.X, center.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    local ignore = { Camera }
    if LocalPlayer.Character then table.insert(ignore, LocalPlayer.Character) end
    params.FilterDescendantsInstances = ignore
    local result = workspace:Raycast(ray.Origin, ray.Direction * 5000, params)
    if not result then return nil end
    local hit = result.Instance
    local model = hit:FindFirstAncestorOfClass("Model")
    if model and isAttackableModel(model) then
        return { char = model, hum = model:FindFirstChildOfClass("Humanoid"), root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head"), part = hit }
    end
    return nil
end

local function performWallbang()
    if not Config.Wallbang then return end
    if tick() - lastWallbang < Config.WallbangDelay then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local tool = myChar:FindFirstChildOfClass("Tool")
    if not tool then return end
    local target = findTargetByRaycast()
    if not target then return end
    lastWallbang = tick()
    local savedCF = myRoot.CFrame
    pcall(function()
        if target.root then myRoot.CFrame = target.root.CFrame * CFrame.new(0, 0, 3)
        else myRoot.CFrame = CFrame.new(target.part.Position + Vector3.new(0, 2, 0)) end
        myRoot.AssemblyLinearVelocity = Vector3.zero
    end)
    pcall(function() Camera.CFrame = CFrame.lookAt(myRoot.Position, target.part.Position) end)
    task.wait(0.02)
    pcall(function() tool:Activate() end)
    task.wait(0.02)
    pcall(function() if mouse1click then mouse1click() end end)
    task.wait(0.05)
    pcall(function() myRoot.CFrame = savedCF; myRoot.AssemblyLinearVelocity = Vector3.zero end)
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Config.WallbangKey and Config.Wallbang then
        wallbangActive = true
        performWallbang()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Config.WallbangKey then wallbangActive = false end
end)

-- ==================== TRIGGERBOT ====================
local lastTrigger = 0
local function runTriggerBot()
    if not Config.TriggerBot then return end
    if tick() - lastTrigger < Config.TriggerBotDelay then return end
    local center = getFOVCenter()
    local ray = Camera:ViewportPointToRay(center.X, center.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
    local result = workspace:Raycast(ray.Origin, ray.Direction * 500, params)
    if result and result.Instance then
        local model = result.Instance:FindFirstAncestorOfClass("Model")
        if model then
            local plr = Players:GetPlayerFromCharacter(model)
            local isB = isBot(model)
            if (plr and plr ~= LocalPlayer) or (isB and Config.Aimbot_Bots) then
                if plr and Config.AimbotTeamCheck and LocalPlayer.Team and plr.Team == LocalPlayer.Team then return end
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    lastTrigger = tick()
                    if mouse1click then mouse1click() end
                end
            end
        end
    end
end

-- ==================== FLY ====================
local flyBodyVel, flyBodyGyro

function enableFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    disableFly()
    flyBodyVel = Instance.new("BodyVelocity")
    flyBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBodyVel.Velocity = Vector3.zero
    flyBodyVel.Parent = hrp
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.P = 1000
    flyBodyGyro.D = 50
    flyBodyGyro.CFrame = hrp.CFrame
    flyBodyGyro.Parent = hrp
end

function disableFly()
    if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
    if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
end

local function updateFly()
    if not Config.Fly or not flyBodyVel then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dir = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
    flyBodyVel.Velocity = dir.Magnitude > 0 and dir.Unit * Config.FlySpeed or Vector3.zero
    flyBodyGyro.CFrame = Camera.CFrame
end

-- ==================== SPEED ====================
local speedBoostConn

local function applySpeedNow()
    if not Config.Speed then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.WalkSpeed ~= Config.SpeedValue then pcall(function() hum.WalkSpeed = Config.SpeedValue end) end
end

task.spawn(function()
    while task.wait(0.05) do
        if Config.Speed and Config.SpeedValue > 1000 then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hum and hrp then
                    local dir = hum.MoveDirection
                    if dir.Magnitude > 0.1 then
                        if not speedBoostConn or not speedBoostConn.Parent then
                            speedBoostConn = Instance.new("BodyVelocity")
                            speedBoostConn.MaxForce = Vector3.new(9e9, 0, 9e9)
                            speedBoostConn.Parent = hrp
                        end
                        speedBoostConn.Velocity = dir.Unit * Config.SpeedValue
                    else
                        if speedBoostConn then speedBoostConn.Velocity = Vector3.zero end
                    end
                end
            end
        else
            if speedBoostConn then speedBoostConn:Destroy(); speedBoostConn = nil end
        end
    end
end)

RunService.Heartbeat:Connect(applySpeedNow)

local speedPropConn
local function bindSpeedChar(char)
    if speedPropConn then speedPropConn:Disconnect(); speedPropConn = nil end
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    applySpeedNow()
    speedPropConn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if Config.Speed and hum.WalkSpeed ~= Config.SpeedValue then hum.WalkSpeed = Config.SpeedValue end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char) task.wait(0.2); bindSpeedChar(char) end)
if LocalPlayer.Character then bindSpeedChar(LocalPlayer.Character) end

-- ==================== HIGH JUMP ====================
local highJumpConn

local function applyHighJump()
    if not Config.HighJump then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    pcall(function() hum.JumpPower = Config.HighJumpPower end)
    pcall(function() hum.JumpHeight = Config.HighJumpPower / 7.5 end)
    pcall(function() hum.UseJumpPower = true end)
end

function startHighJump()
    if highJumpConn then return end
    highJumpConn = RunService.Heartbeat:Connect(applyHighJump)
end

stopHighJump = function()
    if highJumpConn then highJumpConn:Disconnect(); highJumpConn = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.JumpPower = 50 end) end
    end
end

-- ==================== NOCLIP ====================
local noclipConn
function startNoclip()
    if noclipConn then return end
    noclipConn = RunService.Stepped:Connect(function()
        if not Config.Noclip then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    end)
end

function stopNoclip()
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
end

-- ==================== INFINITE JUMP ====================
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

-- ==================== TELEPORT ====================
local function findPlayerByRole(role)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if role == "Murderer" and hasKnife(player) then return player
                elseif role == "Sheriff" and hasGun(player) then return player end
            end
        end
    end
    return nil
end

local function teleportToPlayer(tp, offset)
    if not tp or not tp.Character then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local tgtRoot = tp.Character:FindFirstChild("HumanoidRootPart")
    if myRoot and tgtRoot then
        offset = offset or Config.TeleportOffset
        myRoot.CFrame = tgtRoot.CFrame + tgtRoot.CFrame.LookVector * offset
        myRoot.AssemblyLinearVelocity = Vector3.zero
    end
end

local function teleportPlayerToMe(tp)
    if not tp or not tp.Character then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local tgtRoot = tp.Character:FindFirstChild("HumanoidRootPart")
    if myRoot and tgtRoot then
        tgtRoot.CFrame = myRoot.CFrame + myRoot.CFrame.LookVector * 3
        tgtRoot.AssemblyLinearVelocity = Vector3.zero
    end
end

local function teleportAllToMe()
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local offset = 5
    local i = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local tgtRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if tgtRoot then
                local angle = (i / 8) * math.pi * 2
                tgtRoot.CFrame = myRoot.CFrame * CFrame.new(math.cos(angle) * offset, 0, math.sin(angle) * offset)
                tgtRoot.AssemblyLinearVelocity = Vector3.zero
                i = i + 1
            end
        end
    end
end

-- ==================== FLING ====================
local flingConn, flingParts, flingSavedCFrame = nil, {}, nil

local function getSelectedOrFirst()
    if Config.SelectedPlayer and Config.SelectedPlayer.Parent and Config.SelectedPlayer.Character then return Config.SelectedPlayer end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then return p end
    end
    return nil
end

local function clearFlingParts()
    for _, part in ipairs(flingParts) do pcall(function() part:Destroy() end) end
    flingParts = {}
end

local function makeMover(class, parent, props, name)
    local existing = parent:FindFirstChild(name)
    if existing then
        for k, v in pairs(props) do existing[k] = v end
        if not table.find(flingParts, existing) then table.insert(flingParts, existing) end
        return existing
    end
    local m = Instance.new(class)
    m.Name = name
    for k, v in pairs(props) do m[k] = v end
    m.Parent = parent
    table.insert(flingParts, m)
    return m
end

function startFling()
    if flingConn then return end
    local myChar = LocalPlayer.Character
    if myChar then
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if myRoot then flingSavedCFrame = myRoot.CFrame end
    end
    flingConn = RunService.Heartbeat:Connect(function()
        local target = getSelectedOrFirst()
        if not target then return end
        local tgtChar = target.Character
        if not tgtChar then return end
        local tgtRoot = tgtChar:FindFirstChild("HumanoidRootPart")
        if not tgtRoot then return end
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local myHum = myChar:FindFirstChildOfClass("Humanoid")
        if myHum then myHum.PlatformStand = true end
        local tgtHum = tgtChar:FindFirstChildOfClass("Humanoid")
        if tgtHum then pcall(function() tgtHum.PlatformStand = true end) end
        myRoot.CanCollide = true
        myRoot.Massless = false
        tgtRoot.CanCollide = true
        tgtRoot.Massless = false
        if tgtRoot.Anchored then tgtRoot.Anchored = false end
        pcall(function() tgtRoot:SetNetworkOwner(LocalPlayer) end)
        local ox, oy, oz = (math.random() - 0.5) * 2, (math.random() - 0.5) * 2, (math.random() - 0.5) * 2
        myRoot.CFrame = CFrame.new(tgtRoot.Position + Vector3.new(ox, oy, oz)) * CFrame.Angles(math.random() * math.pi * 2, math.random() * math.pi * 2, math.random() * math.pi * 2)
        makeMover("BodyAngularVelocity", myRoot, { MaxTorque = Vector3.new(9e9, 9e9, 9e9), P = 9e9, AngularVelocity = Vector3.new(Config.FlingSpeed * 2, Config.FlingSpeed * 2, Config.FlingSpeed * 2) }, "FlingSelfAngular")
        makeMover("BodyVelocity", myRoot, { MaxForce = Vector3.new(9e9, 9e9, 9e9), Velocity = Vector3.new((math.random() - 0.5) * Config.FlingSpeed * 8, Config.FlingSpeed * 4, (math.random() - 0.5) * Config.FlingSpeed * 8) }, "FlingSelfVelocity")
        makeMover("BodyAngularVelocity", tgtRoot, { MaxTorque = Vector3.new(9e9, 9e9, 9e9), P = 9e9, AngularVelocity = Vector3.new(Config.FlingSpeed * 3, Config.FlingSpeed * 3, Config.FlingSpeed * 3) }, "FlingTgtAngular")
        makeMover("BodyVelocity", tgtRoot, { MaxForce = Vector3.new(9e9, 9e9, 9e9), Velocity = Vector3.new((math.random() - 0.5) * Config.FlingSpeed * 10, Config.FlingSpeed * 5, (math.random() - 0.5) * Config.FlingSpeed * 10) }, "FlingTgtVelocity")
    end)
end

function stopFling()
    if flingConn then flingConn:Disconnect(); flingConn = nil end
    clearFlingParts()
    local myChar = LocalPlayer.Character
    if myChar then
        local myHum = myChar:FindFirstChildOfClass("Humanoid")
        if myHum then myHum.PlatformStand = false end
    end
    if flingSavedCFrame then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = flingSavedCFrame
                hrp.AssemblyLinearVelocity = Vector3.zero
                for _, name in ipairs({ "FlingSelfAngular", "FlingSelfVelocity" }) do
                    local m = hrp:FindFirstChild(name)
                    if m then m:Destroy() end
                end
            end
        end
        flingSavedCFrame = nil
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum.PlatformStand = false end) end
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if root then
                for _, name in ipairs({ "FlingTgtAngular", "FlingTgtVelocity" }) do
                    local m = root:FindFirstChild(name)
                    if m then m:Destroy() end
                end
            end
        end
    end
end

-- ==================== KILL AURA ====================
local killAuraConn, lastKill = nil, 0

local function iAmMurderer()
    local myChar = LocalPlayer.Character
    if not myChar then return false end
    local tool = myChar:FindFirstChildOfClass("Tool")
    if not tool then return false end
    local n = tool.Name:lower()
    return n:find("knife") or n:find("murder") or n:find("нож")
end

local function getClosestVictim()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local closest, cd = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and root then
                local d = (myRoot.Position - root.Position).Magnitude
                if d < cd then closest, cd = { player = p, hum = hum, root = root, char = p.Character }, d end
            end
        end
    end
    return closest
end

local function teleportStabKill(v)
    if not v or not v.root or not v.hum then return false end
    local myChar = LocalPlayer.Character
    if not myChar then return false end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return false end
    local tool = myChar:FindFirstChildOfClass("Tool")
    if not tool then return false end
    local savedCF = myRoot.CFrame
    pcall(function()
        myRoot.CFrame = v.root.CFrame * CFrame.new(0, 0, 1.5)
        myRoot.AssemblyLinearVelocity = Vector3.zero
    end)
    task.wait(0.03)
    pcall(function() tool:Activate() end)
    task.wait(0.02)
    pcall(function() if mouse1click then mouse1click() end end)
    task.wait(0.05)
    pcall(function() myRoot.CFrame = savedCF; myRoot.AssemblyLinearVelocity = Vector3.zero end)
    return true
end

function startKillAura()
    if killAuraConn then return end
    killAuraConn = RunService.Heartbeat:Connect(function()
        if not Config.KillAura then return end
        if Config.Game ~= "MM2" then return end
        if tick() - lastKill < Config.KillAuraDelay then return end
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myHum = myChar:FindFirstChildOfClass("Humanoid")
        if not myHum or myHum.Health <= 0 then return end
        if not iAmMurderer() then return end
        -- Мобильная версия: aimBtnHeld ИЛИ ЛКМ
        local trigger = aimBtnHeld or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        if not trigger then return end
        local v = getClosestVictim()
        if not v or v.player == LocalPlayer then return end
        lastKill = tick()
        teleportStabKill(v)
    end)
end

stopKillAura = function()
    if killAuraConn then killAuraConn:Disconnect(); killAuraConn = nil end
end

-- ==================== SPIN ====================
local spinConn, spinAngle = nil, 0

function startSpin()
    if spinConn then return end
    spinConn = RunService.RenderStepped:Connect(function(dt)
        if not Config.Spin then return end
        if Config.Game ~= "MM2" then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        if Config.SpinOnlyWhenMoving and hum.MoveDirection.Magnitude < 0.05 then return end
        spinAngle = spinAngle + math.rad(Config.SpinSpeed) * dt * 60
        if spinAngle > math.pi * 2 then spinAngle = spinAngle - math.pi * 2 end
        local pos = hrp.Position
        local look = Vector3.new(math.sin(spinAngle), 0, math.cos(spinAngle))
        hrp.CFrame = CFrame.new(pos, pos + look)
    end)
end

stopSpin = function()
    if spinConn then spinConn:Disconnect(); spinConn = nil end
    spinAngle = 0
end

-- ==================== GHOST MODE ====================
local ghostModeConn, ghostSavedTransparency = nil, {}

function startGhostMode()
    if ghostModeConn then return end
    ghostSavedTransparency = {}
    ghostModeConn = RunService.Heartbeat:Connect(function()
        if not Config.GhostMode then return end
        local myChar = LocalPlayer.Character
        if not myChar then return end
        for _, part in ipairs(myChar:GetDescendants()) do
            if part:IsA("BasePart") then
                if not ghostSavedTransparency[part] then ghostSavedTransparency[part] = part.Transparency end
                pcall(function()
                    part.Transparency = Config.GhostTransparency
                    part.LocalTransparencyModifier = Config.GhostTransparency
                end)
            end
        end
    end)
end

stopGhostMode = function()
    if ghostModeConn then ghostModeConn:Disconnect(); ghostModeConn = nil end
    for part, t in pairs(ghostSavedTransparency) do
        if part and part.Parent then
            pcall(function() part.Transparency = t; part.LocalTransparencyModifier = 0 end)
        end
    end
    ghostSavedTransparency = {}
end

-- ==================== ANTI-FLING ====================
local antiFlingConn
function startAntiFling()
    if antiFlingConn then return end
    antiFlingConn = RunService.Heartbeat:Connect(function()
        if not Config.AntiFling then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local speed = hrp.AssemblyLinearVelocity.Magnitude
        local angSpeed = hrp.AssemblyAngularVelocity.Magnitude
        if not Config.Fly and not flingConn then
            if speed > 150 then hrp.AssemblyLinearVelocity = Vector3.zero; hrp.CFrame = CFrame.new(hrp.Position) end
            if angSpeed > 50 then hrp.AssemblyAngularVelocity = Vector3.zero end
        end
    end)
end

function stopAntiFling()
    if antiFlingConn then antiFlingConn:Disconnect(); antiFlingConn = nil end
end

-- ==================== NO RECOIL ====================
local noRecoilConn, savedCameraCFrame = nil, nil

function startNoRecoil()
    if noRecoilConn then return end
    noRecoilConn = RunService.RenderStepped:Connect(function()
        if not Config.NoRecoil then return end
        if savedCameraCFrame then
            local cl = Camera.CFrame.LookVector
            local sl = savedCameraCFrame.LookVector
            local b = (cl + sl * 0.5).Unit
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + b)
        end
        savedCameraCFrame = Camera.CFrame
    end)
end

-- ==================== SCOPE ====================
local scopeActive, originalFOV = false, 70
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Config.ScopeKey and Config.ScopeAnywhere then
        if not scopeActive then originalFOV = Camera.FieldOfView; scopeActive = true; Camera.FieldOfView = Config.ScopeFOV end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Config.ScopeKey and scopeActive then
        Camera.FieldOfView = originalFOV; scopeActive = false
    end
end)

-- ==================== INFINITE AMMO ====================
local infiniteAmmoConn = nil
function startInfiniteAmmo()
    if infiniteAmmoConn then return end
    infiniteAmmoConn = RunService.Heartbeat:Connect(function()
        if not Config.InfiniteAmmo then return end
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local tool = myChar:FindFirstChildOfClass("Tool")
        if not tool then return end
        for _, obj in ipairs(tool:GetDescendants()) do
            if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                local n = obj.Name:lower()
                if n:find("ammo") or n:find("clip") or n:find("bullet") or n:find("mag") then
                    pcall(function() if obj.Value < 999 then obj.Value = 999 end end)
                end
            end
        end
    end)
end

stopInfiniteAmmo = function()
    if infiniteAmmoConn then infiniteAmmoConn:Disconnect(); infiniteAmmoConn = nil end
end

-- ==================== ANTI-AFK ====================
task.spawn(function()
    while task.wait(60) do
        if Config.AntiAfk and VirtualUser then
            pcall(function() VirtualUser:CaptureController() end)
            pcall(function() VirtualUser:ClickButton2(Vector2.new()) end)
        end
    end
end)

-- ==================== ГЛАВНЫЙ ЦИКЛ ====================
local lastESPUpdate = 0
local ESP_UPDATE_INTERVAL = 0.05

RunService.RenderStepped:Connect(function()
    if tick() - lastESPUpdate > ESP_UPDATE_INTERVAL then
        lastESPUpdate = tick()
        if Config.ESP or (Config.MM2ESP and Config.Game == "MM2") or Config.ESP_Bots then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and not espObjects[p] then createESP(p) end
            end
            updateESP()
        else
            for p, _ in pairs(espObjects) do removeESP(p) end
            for bot, _ in pairs(espBots) do removeBotESP(bot) end
        end
    end

    updateTracers()

    if not _G.__nexRadarLast or tick() - _G.__nexRadarLast > 0.1 then
        _G.__nexRadarLast = tick()
        updateRadar()
    end

    if Config.AimbotDrawFOV and Config.Aimbot then
        FOVCircle.Visible = true
        FOVCircle.Size = UDim2.new(0, Config.AimbotFOV * 2, 0, Config.AimbotFOV * 2)
        FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
        FovStroke.Color = Config.ESP_Color
    else
        FOVCircle.Visible = false
    end

    if Config.Aimbot and isAimbotTriggered() then
        local target = getClosestTarget()
        if target then
            local tc = CFrame.new(Camera.CFrame.Position, target.Position)
            local sm = 1 - (Config.AimbotSmooth / 100)
            if sm >= 0.99 then Camera.CFrame = tc else Camera.CFrame = Camera.CFrame:Lerp(tc, sm) end
        end
    end

    if Config.Wallbang and wallbangActive then performWallbang() end
    updateFly()
    runTriggerBot()
end)

startFootstepESP()

Players.PlayerAdded:Connect(function(p)
    if Config.ESP or (Config.MM2ESP and Config.Game == "MM2") then createESP(p) end
end)
Players.PlayerRemoving:Connect(function(p)
    removeESP(p)
    if Config.SelectedPlayer == p then Config.SelectedPlayer = nil end
end)

-- ==================== UI ВКЛАДОК (урезанные для мобилы) ====================
local MainPage = createTabButton("Главная", "🏠")

sectionLabel(MainPage, "🎮 ВЫБОР ИГРЫ")

local currentGameLabel = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(28, 28, 34),
    Text = "Игра: не выбрана",
    TextColor3 = Color3.fromRGB(220, 220, 235),
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    BorderSizePixel = 0,
    Parent = MainPage,
})
corner(currentGameLabel, 8)
stroke(currentGameLabel, Color3.fromRGB(0, 170, 255), 1.5, 0.3)

-- НАСТРОЙКИ МЕНЮ (мобильные)
sectionLabel(MainPage, "📱 НАСТРОЙКИ МЕНЮ")
slider(MainPage, "Масштаб меню %", 60, 150, math.floor(Config.MenuScale * 100), function(v)
    Config.MenuScale = v / 100
    Main.Size = UDim2.new(0, 500 * Config.MenuScale, 0, 450 * Config.MenuScale)
end)

toggle(MainPage, "Показывать кнопку Aimbot 🎯", Config.AimButtonVisible, function(v)
    Config.AimButtonVisible = v
    AimBtn.Visible = v
end)

-- ПЕРЕСБОРКА
local function rebuildTabsForGame(game)
    clearNonMainTabs()
    showTab("Главная")

    if game == "Rivals" or game == "FPS Flick" then
        local EspP = createTabButton("ESP", "👁")
        local VisP = createTabButton("Визуал", "🎨")
        local AimP = createTabButton("Aimbot", "🎯")
        local ShotP = createTabButton("Точность", "🔫")
        local MoveP = createTabButton("Движение", "🚀")
        local GodP = createTabButton("God", "🛡")
        local MiscP = createTabButton("Разное", "⚙")

        sectionLabel(EspP, "ОСНОВНОЕ")
        toggle(EspP, "Включить ESP", Config.ESP, function(v) Config.ESP = v end)
        toggle(EspP, "Подсветка", Config.ESP_Highlight, function(v) Config.ESP_Highlight = v end)
        toggle(EspP, "Рамка", Config.ESP_Box, function(v) Config.ESP_Box = v end)
        toggle(EspP, "Имя", Config.ESP_Name, function(v) Config.ESP_Name = v end)
        toggle(EspP, "HP", Config.ESP_Health, function(v) Config.ESP_Health = v end)
        toggle(EspP, "Дистанция", Config.ESP_Distance, function(v) Config.ESP_Distance = v end)
        toggle(EspP, "Скрывать союзников", Config.ESP_TeamCheck, function(v) Config.ESP_TeamCheck = v end)
        sectionLabel(EspP, "🤖 БОТЫ")
        toggle(EspP, "ESP для ботов", Config.ESP_Bots, function(v) Config.ESP_Bots = v end)

        sectionLabel(VisP, "📏 TRACERS")
        toggle(VisP, "Включить Tracers", Config.Tracers, function(v) Config.Tracers = v end)
        slider(VisP, "Толщина", 1, 5, Config.TracersThickness, function(v) Config.TracersThickness = v end)
        sectionLabel(VisP, "🎯 RADAR")
        toggle(VisP, "Включить Radar", Config.Radar, function(v) Config.Radar = v; if v then createRadar() end end)
        slider(VisP, "Размер", 80, 300, Config.RadarSize, function(v) Config.RadarSize = v end)
        sectionLabel(VisP, "💥 HIT MARKER")
        toggle(VisP, "Включить Hit Marker", Config.HitMarker, function(v) Config.HitMarker = v end)

        sectionLabel(AimP, "ОСНОВНОЕ")
        toggle(AimP, "Включить Aimbot", Config.Aimbot, function(v) Config.Aimbot = v end)
        toggle(AimP, "Рисовать FOV", Config.AimbotDrawFOV, function(v) Config.AimbotDrawFOV = v end)
        toggle(AimP, "Наводка через стены", Config.AimbotWallbang, function(v) Config.AimbotWallbang = v end)
        toggle(AimP, "Игнорировать союзников", Config.AimbotTeamCheck, function(v) Config.AimbotTeamCheck = v end)
        toggle(AimP, "🎯 Наводиться на ботов", Config.Aimbot_Bots, function(v) Config.Aimbot_Bots = v end)
        keyBinder(AimP, "Клавиша активации", Config.AimbotKeyName, function(k, n) Config.AimbotKey = k; Config.AimbotKeyName = n end)
        dropdown(AimP, "Режим", { "Зажать", "Переключить" }, Config.AimbotMode, function(v) Config.AimbotMode = v end)
        slider(AimP, "FOV", 20, 600, Config.AimbotFOV, function(v) Config.AimbotFOV = v end)
        slider(AimP, "Скорость наведения", 0, 100, Config.AimbotSmooth, function(v) Config.AimbotSmooth = v end)
        dropdown(AimP, "Часть тела", { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" }, Config.AimbotPart, function(v) Config.AimbotPart = v end)

        if game == "FPS Flick" then
            sectionLabel(AimP, "🔫 AUTO-SHOOT BOTS")
            toggle(AimP, "Включить Auto-Shoot Bots", Config.AutoShootBots, function(v)
                Config.AutoShootBots = v
                if v then startAutoShootBots() else stopAutoShootBots() end
            end)
        end

        sectionLabel(ShotP, "🔫 ТОЧНОСТЬ")
        toggle(ShotP, "No Recoil", Config.NoRecoil, function(v)
            Config.NoRecoil = v
            if v then startNoRecoil() else if noRecoilConn then noRecoilConn:Disconnect(); noRecoilConn = nil end end
        end)
        toggle(ShotP, "Infinite Ammo", Config.InfiniteAmmo, function(v)
            Config.InfiniteAmmo = v
            if v then startInfiniteAmmo() else stopInfiniteAmmo() end
        end)
        sectionLabel(ShotP, "🔭 ПРИЦЕЛ")
        toggle(ShotP, "Scope Anywhere", Config.ScopeAnywhere, function(v) Config.ScopeAnywhere = v end)

        sectionLabel(MoveP, "ПОЛЁТ / БЕГ")
        toggle(MoveP, "Fly", Config.Fly, function(v) Config.Fly = v; if v then enableFly() else disableFly() end end)
        slider(MoveP, "Скорость полёта", 10, 10000, Config.FlySpeed, function(v) Config.FlySpeed = v end)
        toggle(MoveP, "Speed Hack", Config.Speed, function(v) Config.Speed = v end)
        slider(MoveP, "Скорость бега", 16, 10000, Config.SpeedValue, function(v) Config.SpeedValue = v end)
        toggle(MoveP, "High Jump", Config.HighJump, function(v) Config.HighJump = v; if v then startHighJump() else stopHighJump() end end)
        slider(MoveP, "Сила прыжка", 50, 10000, Config.HighJumpPower, function(v) Config.HighJumpPower = v end)
        toggle(MoveP, "Noclip", Config.Noclip, function(v) Config.Noclip = v; if v then startNoclip() else stopNoclip() end end)
        toggle(MoveP, "Infinite Jump", Config.InfiniteJump, function(v) Config.InfiniteJump = v end)

        sectionLabel(GodP, "🛡 РЕЖИМ БОГА")
        toggle(GodP, "Включить God Mode", Config.GodMode, function(v) Config.GodMode = v; if v then startGodMode() else stopGodMode() end end)

        sectionLabel(MiscP, "🔄 КРУТИЛКА")
        toggle(MiscP, "Включить крутилку", Config.CharSpin, function(v)
            Config.CharSpin = v
            if v then startCharSpin() else stopCharSpin() end
        end)
        slider(MiscP, "Скорость", 1, 100, Config.CharSpinSpeed, function(v) Config.CharSpinSpeed = v end)
        sectionLabel(MiscP, "👤 ТРЕТЬЕ ЛИЦО")
        toggle(MiscP, "Включить", Config.ThirdPerson, function(v)
            Config.ThirdPerson = v
            if v then enableThirdPerson() else disableThirdPerson() end
        end)
        sectionLabel(MiscP, "🐰 BUNNY HOP")
        toggle(MiscP, "Включить Bunny Hop", Config.BunnyHop, function(v)
            Config.BunnyHop = v
            if v then startBunnyHop() else stopBunnyHop() end
        end)
        sectionLabel(MiscP, "ПРОЧЕЕ")
        toggle(MiscP, "Anti-AFK", Config.AntiAfk, function(v) Config.AntiAfk = v end)

    elseif game == "MM2" then
        local EspP = createTabButton("ESP", "👁")
        local AimP = createTabButton("Aimbot", "🎯")
        local MoveP = createTabButton("Движение", "🚀")
        local TrollP = createTabButton("Троллинг", "😈")
        local GodP = createTabButton("God", "🛡")
        local MiscP = createTabButton("Разное", "⚙")

        sectionLabel(EspP, "ОСНОВНОЕ")
        toggle(EspP, "Включить ESP", Config.ESP, function(v) Config.ESP = v end)
        toggle(EspP, "Подсветка", Config.ESP_Highlight, function(v) Config.ESP_Highlight = v end)
        toggle(EspP, "Рамка", Config.ESP_Box, function(v) Config.ESP_Box = v end)
        toggle(EspP, "Имя", Config.ESP_Name, function(v) Config.ESP_Name = v end)
        toggle(EspP, "HP", Config.ESP_Health, function(v) Config.ESP_Health = v end)
        toggle(EspP, "Дистанция", Config.ESP_Distance, function(v) Config.ESP_Distance = v end)
        sectionLabel(EspP, "MM2 РЕЖИМ")
        toggle(EspP, "MM2 ESP (роли цветом)", Config.MM2ESP, function(v) Config.MM2ESP = v end)
        sectionLabel(EspP, "🤖 БОТЫ")
        toggle(EspP, "ESP для ботов", Config.ESP_Bots, function(v) Config.ESP_Bots = v end)

        sectionLabel(AimP, "ОСНОВНОЕ")
        toggle(AimP, "Включить Aimbot", Config.Aimbot, function(v) Config.Aimbot = v end)
        toggle(AimP, "Рисовать FOV", Config.AimbotDrawFOV, function(v) Config.AimbotDrawFOV = v end)
        toggle(AimP, "Наводка через стены", Config.AimbotWallbang, function(v) Config.AimbotWallbang = v end)
        toggle(AimP, "Игнорировать союзников", Config.AimbotTeamCheck, function(v) Config.AimbotTeamCheck = v end)
        toggle(AimP, "🎯 Наводиться на ботов", Config.Aimbot_Bots, function(v) Config.Aimbot_Bots = v end)
        slider(AimP, "FOV", 20, 600, Config.AimbotFOV, function(v) Config.AimbotFOV = v end)
        slider(AimP, "Скорость наведения", 0, 100, Config.AimbotSmooth, function(v) Config.AimbotSmooth = v end)
        sectionLabel(AimP, "🔫 AUTO-SHOOT MURDERER")
        toggle(AimP, "Включить Auto-Shoot", Config.AimbotAutoShootMurderer, function(v)
            Config.AimbotAutoShootMurderer = v
            if v then startAutoShoot() else stopAutoShoot() end
        end)

        sectionLabel(MoveP, "ПОЛЁТ / БЕГ")
        toggle(MoveP, "Fly", Config.Fly, function(v) Config.Fly = v; if v then enableFly() else disableFly() end end)
        slider(MoveP, "Скорость полёта", 10, 10000, Config.FlySpeed, function(v) Config.FlySpeed = v end)
        toggle(MoveP, "Speed Hack", Config.Speed, function(v) Config.Speed = v end)
        slider(MoveP, "Скорость бега", 16, 10000, Config.SpeedValue, function(v) Config.SpeedValue = v end)
        toggle(MoveP, "Noclip", Config.Noclip, function(v) Config.Noclip = v; if v then startNoclip() else stopNoclip() end end)

        sectionLabel(TrollP, "📍 ТЕЛЕПОРТ")
        local playerDropdown
        local function getPlayerNames()
            local l = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then table.insert(l, p.Name) end
            end
            if #l == 0 then l = { "Нет игроков" } end
            return l
        end
        playerDropdown = dropdown(TrollP, "Цель", getPlayerNames(), nil, function(name)
            Config.SelectedPlayer = Players:FindFirstChild(name)
        end)
        task.spawn(function()
            while task.wait(2) do
                if playerDropdown and Config.Game == "MM2" then playerDropdown.refresh(getPlayerNames()) end
            end
        end)
        button(TrollP, "🔪 Телепорт к Murderer", function()
            local m = findPlayerByRole("Murderer")
            if m then teleportToPlayer(m) end
        end, Color3.fromRGB(180, 40, 40))
        button(TrollP, "🔵 Телепорт к Sheriff", function()
            local s = findPlayerByRole("Sheriff")
            if s then teleportToPlayer(s) end
        end, Color3.fromRGB(40, 120, 200))
        button(TrollP, "🎯 Телепорт к выбранному", function()
            local t = Config.SelectedPlayer
            if not t or not t.Parent then
                for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then t = p; break end end
            end
            if t then teleportToPlayer(t) end
        end, Color3.fromRGB(40, 160, 80))
        button(TrollP, "⬅ Телепорт игрока к себе", function()
            if Config.SelectedPlayer then teleportPlayerToMe(Config.SelectedPlayer) end
        end, Color3.fromRGB(120, 80, 180))
        button(TrollP, "🌐 Телепорт ВСЕХ к себе", function() teleportAllToMe() end, Color3.fromRGB(200, 120, 40))

        sectionLabel(TrollP, "ФЛИНГ")
        toggle(TrollP, "Включить Fling", false, function(v) if v then startFling() else stopFling() end end)
        slider(TrollP, "Скорость", 100, 3000, Config.FlingSpeed, function(v) Config.FlingSpeed = v end)

        sectionLabel(TrollP, "💀 KILL AURA")
        toggle(TrollP, "Включить Kill Aura", Config.KillAura, function(v)
            Config.KillAura = v
            if v then startKillAura() else stopKillAura() end
        end)

        sectionLabel(TrollP, "🌀 КРУТИЛКА")
        toggle(TrollP, "Включить Крутилку", Config.Spin, function(v)
            Config.Spin = v
            if v then startSpin() else stopSpin() end
        end)
        slider(TrollP, "Скорость", 1, 100, Config.SpinSpeed, function(v) Config.SpinSpeed = v end)

        sectionLabel(TrollP, "👻 GHOST MODE")
        toggle(TrollP, "Включить Ghost", Config.GhostMode, function(v)
            Config.GhostMode = v
            if v then startGhostMode() else stopGhostMode() end
        end)

        sectionLabel(TrollP, "ЗАЩИТА")
        toggle(TrollP, "Anti-Fling", Config.AntiFling, function(v)
            Config.AntiFling = v
            if v then startAntiFling() else stopAntiFling() end
        end)

        sectionLabel(GodP, "🛡 РЕЖИМ БОГА")
        toggle(GodP, "Включить God Mode", Config.GodMode, function(v)
            Config.GodMode = v
            if v then startGodMode() else stopGodMode() end
        end)

        sectionLabel(MiscP, "🔫 AUTO-PICKUP")
        toggle(MiscP, "Включить Auto-Pickup", Config.AutoPickupGun, function(v)
            Config.AutoPickupGun = v
            if v then startAutoPickup() else stopAutoPickup() end
        end)
        sectionLabel(MiscP, "ПРОЧЕЕ")
        toggle(MiscP, "Anti-AFK", Config.AntiAfk, function(v) Config.AntiAfk = v end)

    elseif game == "Tower of Hell" then
        local MoveP = createTabButton("Движение", "🚀")
        local ToHP = createTabButton("ToH", "🗼")
        local GodP = createTabButton("God", "🛡")
        local MiscP = createTabButton("Разное", "⚙")

        sectionLabel(MoveP, "ОСНОВНОЕ")
        toggle(MoveP, "Infinite Jump", Config.InfiniteJump, function(v) Config.InfiniteJump = v end)
        toggle(MoveP, "Fly", Config.Fly, function(v) Config.Fly = v; if v then enableFly() else disableFly() end end)
        slider(MoveP, "Скорость полёта", 10, 10000, Config.FlySpeed, function(v) Config.FlySpeed = v end)
        toggle(MoveP, "High Jump", Config.HighJump, function(v) Config.HighJump = v; if v then startHighJump() else stopHighJump() end end)
        slider(MoveP, "Сила прыжка", 50, 10000, Config.HighJumpPower, function(v) Config.HighJumpPower = v end)
        toggle(MoveP, "Speed Hack", Config.Speed, function(v) Config.Speed = v end)
        slider(MoveP, "Скорость бега", 16, 10000, Config.SpeedValue, function(v) Config.SpeedValue = v end)
        toggle(MoveP, "Noclip", Config.Noclip, function(v) Config.Noclip = v; if v then startNoclip() else stopNoclip() end end)

        sectionLabel(ToHP, "🗼 CHECKPOINT TP")
        toggle(ToHP, "Включить Checkpoint TP", Config.CheckpointTP, function(v) Config.CheckpointTP = v end)
        keyBinder(ToHP, "Клавиша", Config.CheckpointTPKeyName, function(k, n) Config.CheckpointTPKey = k; Config.CheckpointTPKeyName = n end)
        sectionLabel(ToHP, "⏱ TIMER")
        toggle(ToHP, "Speedrun Timer", Config.SpeedrunTimer, function(v) Config.SpeedrunTimer = v end)

        sectionLabel(GodP, "🛡 РЕЖИМ БОГА")
        toggle(GodP, "Включить God Mode", Config.GodMode, function(v) Config.GodMode = v; if v then startGodMode() else stopGodMode() end end)

        sectionLabel(MiscP, "ПРОЧЕЕ")
        toggle(MiscP, "Anti-AFK", Config.AntiAfk, function(v) Config.AntiAfk = v end)

    elseif game == "Клавиатура" then
        local MoveP = createTabButton("Движение", "🚀")
        local MacroP = createTabButton("Макросы", "🎬")
        local GodP = createTabButton("God", "🛡")
        local MiscP = createTabButton("Разное", "⚙")

        sectionLabel(MoveP, "ОСНОВНОЕ")
        toggle(MoveP, "Speed Hack", Config.Speed, function(v) Config.Speed = v end)
        slider(MoveP, "Скорость бега", 16, 10000, Config.SpeedValue, function(v) Config.SpeedValue = v end)
        toggle(MoveP, "Fly", Config.Fly, function(v) Config.Fly = v; if v then enableFly() else disableFly() end end)
        slider(MoveP, "Скорость полёта", 10, 10000, Config.FlySpeed, function(v) Config.FlySpeed = v end)
        toggle(MoveP, "Noclip", Config.Noclip, function(v) Config.Noclip = v; if v then startNoclip() else stopNoclip() end end)

        sectionLabel(MacroP, "🎬 MACRO RECORDER")
        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 70),
            BackgroundColor3 = Color3.fromRGB(28, 28, 34),
            Text = "  Нажми M чтобы начать запись,\n  нажми M снова чтобы воспроизвести.",
            TextColor3 = Color3.fromRGB(180, 180, 200),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            BorderSizePixel = 0,
            Parent = MacroP,
        })

        sectionLabel(GodP, "🛡 РЕЖИМ БОГА")
        toggle(GodP, "Включить God Mode", Config.GodMode, function(v) Config.GodMode = v; if v then startGodMode() else stopGodMode() end end)

        sectionLabel(MiscP, "ПРОЧЕЕ")
        toggle(MiscP, "Anti-AFK", Config.AntiAfk, function(v) Config.AntiAfk = v end)
    end
end

-- ==================== AUTO-FARM ====================
local autoFarmThread, autoFarmLastScan = nil, 0
local autoFarmCachedCollectibles = {}
local COLLECT_KEYWORDS = { "cup", "trophy", "coin", "gem", "star", "orb", "collectible", "pickup", "chest", "reward", "prize", "point", "куб", "монет", "сундук", "награ" }
local FINISH_KEYWORDS = { "finish", "goal", "end", "port", "portal", "next", "stage", "checkpoint", "финиш" }

local function nm(n, k)
    if not n then return false end
    n = n:lower()
    for _, kw in ipairs(k) do if n:find(kw) then return true end end
    return false
end

local function isCollectible(o)
    if not o or not (o:IsA("BasePart") or o:IsA("Model") or o:IsA("Tool")) then return false end
    return nm(o.Name, COLLECT_KEYWORDS)
end

local function isFinishObject(o)
    if not o or not (o:IsA("BasePart") or o:IsA("Model")) then return false end
    return nm(o.Name, FINISH_KEYWORDS)
end

local function findCollectibles()
    if tick() - autoFarmLastScan < Config.AutoFarmScanInterval then return autoFarmCachedCollectibles end
    autoFarmLastScan = tick()
    local myChar = LocalPlayer.Character
    if not myChar then return {} end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return {} end
    local found = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        if isCollectible(obj) then
            local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
            if part then
                local d = (myRoot.Position - part.Position).Magnitude
                if d <= Config.AutoFarmCollectRadius then table.insert(found, { part = part, dist = d }) end
            end
        end
    end
    table.sort(found, function(a, b) return a.dist < b.dist end)
    autoFarmCachedCollectibles = found
    return found
end

local function getCurrentStage()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        for _, v in ipairs(ls:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                local n = v.Name:lower()
                if n:find("stage") or n:find("level") or n:find("этаж") then return tonumber(v.Value) or 0 end
            end
        end
    end
    local myChar = LocalPlayer.Character
    if myChar then
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if myRoot then return math.floor(math.max(0, myRoot.Position.Y / 10)) end
    end
    return 0
end

function startAutoFarm()
    if autoFarmThread then return end
    if Config.Game ~= "Клавиатура" then return end
    local stage = getCurrentStage()
    if Config.AutoFarmUseNoclip then Config.Noclip = true; startNoclip() end
    if Config.AutoFarmUseFly then Config.Fly = true; Config.FlySpeed = Config.AutoFarmFlySpeed; enableFly() end
    print("[Auto-Farm] СТАРТ")
    autoFarmThread = task.spawn(function()
        while task.wait(Config.AutoFarmMoveInterval) do
            if not Config.AutoFarm then autoFarmThread = nil; return end
            local cur = getCurrentStage()
            if cur >= Config.AutoFarmTargetStage then
                print("[Auto-Farm] ЦЕЛЬ!", cur)
                Config.AutoFarm = false
                autoFarmThread = nil
                return
            end
            local coll = findCollectibles()
            if #coll > 0 then
                local myChar = LocalPlayer.Character
                if myChar then
                    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                    if myRoot then
                        pcall(function()
                            myRoot.CFrame = CFrame.new(coll[1].part.Position + Vector3.new(0, 2, 0))
                            myRoot.AssemblyLinearVelocity = Vector3.zero
                        end)
                    end
                end
            end
        end
    end)
end

stopAutoFarm = function() autoFarmThread = nil end

-- ==================== КНОПКИ ИГР ====================
local function makeGameButton(gameName, icon, color)
    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = color,
        Text = "  " .. icon .. "  " .. gameName,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        Parent = MainPage,
    })
    corner(btn, 10)
    stroke(btn, Color3.fromRGB(255, 255, 255), 1, 0.6)
    btn.MouseButton1Click:Connect(function()
        Config.Game = gameName
        GameIndicator.Text = "Игра: " .. gameName
        currentGameLabel.Text = "✅ Выбрано: " .. gameName
        currentGameLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        rebuildTabsForGame(gameName)
    end)
end

makeGameButton("Rivals", "🎯", Color3.fromRGB(180, 60, 60))
makeGameButton("FPS Flick", "🔫", Color3.fromRGB(200, 120, 40))
makeGameButton("MM2", "🔪", Color3.fromRGB(150, 40, 150))
makeGameButton("Tower of Hell", "🗼", Color3.fromRGB(60, 130, 180))
makeGameButton("Клавиатура", "⌨", Color3.fromRGB(80, 140, 90))

-- ==================== ХОТКЕЙ МЕНЮ ====================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        Config.MenuOpen = not Config.MenuOpen
        Main.Visible = Config.MenuOpen
    end
end)

showTab("Главная")

-- Начальное положение меню (закрыто)
Main.Visible = false
Config.MenuOpen = false

print("[Nexus Cheat v7.1 MOBILE] Загружено. Открой меню кнопкой ⚡ справа сверху.")
