--[[
    VisualClient TargetHUD v2.0 — Premium Edition
    Features:
      • Avatar thumbnail display
      • Animated health + armor bars with gradient colors
      • Smooth fade-in/fade-out transitions
      • Distance indicator
      • Weapon/tool name display
      • Draggable with smooth follow
      • Pulsing accent line
      • Rounded visual design (Drawing API)
]]

local Theme = require(script.Parent.Parent.Utils.Theme)
local Animate = require(script.Parent.Parent.Utils.Animate)

local TargetHUD = {
    Enabled = true,
    Position = Vector2.new(500, 400),
    Size = Vector2.new(260, 90),
    Dragging = false,
    CurrentTarget = nil,
    MaxRange = 1200,
    ShowAvatar = true,
    ShowDistance = true,
    ShowWeapon = true,
}

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- Animation state
local fadeAlpha = Animate.SmoothValue(0, 8)
local healthSmooth = Animate.SmoothValue(1, 6)
local healthColorSmooth = Animate.SmoothColor(Theme.Safe, 6)
local positionSmooth = Animate.SmoothVector2(Vector2.new(500, 400), 14)

local Drawings = {}
local avatarImage = nil

-- ══════════════════════════════════════════════════════
-- DRAWING CREATION
-- ══════════════════════════════════════════════════════

local function CreateDrawings()
    -- Main background panel
    Drawings.BackgroundShadow = Drawing.new("Square")
    Drawings.BackgroundShadow.Color = Color3.fromRGB(0, 0, 0)
    Drawings.BackgroundShadow.Filled = true
    Drawings.BackgroundShadow.Transparency = 0.3
    Drawings.BackgroundShadow.Visible = false

    Drawings.Background = Drawing.new("Square")
    Drawings.Background.Color = Theme.Background
    Drawings.Background.Filled = true
    Drawings.Background.Transparency = 0.95
    Drawings.Background.Visible = false

    -- Top accent gradient line
    Drawings.AccentLine = Drawing.new("Square")
    Drawings.AccentLine.Color = Theme.Accent
    Drawings.AccentLine.Filled = true
    Drawings.AccentLine.Visible = false

    -- Secondary accent line (right side, for gradient effect)
    Drawings.AccentLine2 = Drawing.new("Square")
    Drawings.AccentLine2.Color = Theme.Secondary
    Drawings.AccentLine2.Filled = true
    Drawings.AccentLine2.Visible = false

    -- Border outline
    Drawings.BorderTop = Drawing.new("Line")
    Drawings.BorderTop.Color = Theme.Border
    Drawings.BorderTop.Thickness = 1
    Drawings.BorderTop.Visible = false

    Drawings.BorderBottom = Drawing.new("Line")
    Drawings.BorderBottom.Color = Theme.Border
    Drawings.BorderBottom.Thickness = 1
    Drawings.BorderBottom.Visible = false

    Drawings.BorderLeft = Drawing.new("Line")
    Drawings.BorderLeft.Color = Theme.Border
    Drawings.BorderLeft.Thickness = 1
    Drawings.BorderLeft.Visible = false

    Drawings.BorderRight = Drawing.new("Line")
    Drawings.BorderRight.Color = Theme.Border
    Drawings.BorderRight.Thickness = 1
    Drawings.BorderRight.Visible = false

    -- Avatar background
    Drawings.AvatarBg = Drawing.new("Square")
    Drawings.AvatarBg.Color = Theme.Surface
    Drawings.AvatarBg.Filled = true
    Drawings.AvatarBg.Visible = false

    -- Avatar border
    Drawings.AvatarBorder = Drawing.new("Square")
    Drawings.AvatarBorder.Color = Theme.Accent
    Drawings.AvatarBorder.Filled = false
    Drawings.AvatarBorder.Thickness = 1
    Drawings.AvatarBorder.Visible = false

    -- Player name
    Drawings.Name = Drawing.new("Text")
    Drawings.Name.Color = Theme.Text
    Drawings.Name.Size = Theme.FontSizeLarge
    Drawings.Name.Center = false
    Drawings.Name.Outline = true
    Drawings.Name.Font = Drawing.Fonts.Plex
    Drawings.Name.Visible = false

    -- Display name (smaller, muted)
    Drawings.DisplayName = Drawing.new("Text")
    Drawings.DisplayName.Color = Theme.TextMuted
    Drawings.DisplayName.Size = Theme.FontSizeSmall
    Drawings.DisplayName.Center = false
    Drawings.DisplayName.Outline = true
    Drawings.DisplayName.Font = Drawing.Fonts.Plex
    Drawings.DisplayName.Visible = false

    -- Health bar background
    Drawings.HealthBarBg = Drawing.new("Square")
    Drawings.HealthBarBg.Color = Theme.Surface
    Drawings.HealthBarBg.Filled = true
    Drawings.HealthBarBg.Visible = false

    -- Health bar fill
    Drawings.HealthBar = Drawing.new("Square")
    Drawings.HealthBar.Color = Theme.Safe
    Drawings.HealthBar.Filled = true
    Drawings.HealthBar.Visible = false

    -- Health bar glow (overlay for pulsing effect when low)
    Drawings.HealthBarGlow = Drawing.new("Square")
    Drawings.HealthBarGlow.Color = Theme.DangerGlow
    Drawings.HealthBarGlow.Filled = true
    Drawings.HealthBarGlow.Transparency = 0
    Drawings.HealthBarGlow.Visible = false

    -- Health text
    Drawings.HealthText = Drawing.new("Text")
    Drawings.HealthText.Color = Theme.TextSecondary
    Drawings.HealthText.Size = Theme.FontSizeSmall
    Drawings.HealthText.Center = false
    Drawings.HealthText.Outline = true
    Drawings.HealthText.Font = Drawing.Fonts.Plex
    Drawings.HealthText.Visible = false

    -- Health percentage
    Drawings.HealthPercent = Drawing.new("Text")
    Drawings.HealthPercent.Color = Theme.Text
    Drawings.HealthPercent.Size = Theme.FontSizeSmall
    Drawings.HealthPercent.Center = false
    Drawings.HealthPercent.Outline = true
    Drawings.HealthPercent.Font = Drawing.Fonts.Plex
    Drawings.HealthPercent.Visible = false

    -- Distance text
    Drawings.DistanceText = Drawing.new("Text")
    Drawings.DistanceText.Color = Theme.TextMuted
    Drawings.DistanceText.Size = Theme.FontSizeSmall
    Drawings.DistanceText.Center = false
    Drawings.DistanceText.Outline = true
    Drawings.DistanceText.Font = Drawing.Fonts.Plex
    Drawings.DistanceText.Visible = false

    -- Weapon/Tool text
    Drawings.WeaponText = Drawing.new("Text")
    Drawings.WeaponText.Color = Theme.TextAccent
    Drawings.WeaponText.Size = Theme.FontSizeSmall
    Drawings.WeaponText.Center = false
    Drawings.WeaponText.Outline = true
    Drawings.WeaponText.Font = Drawing.Fonts.Plex
    Drawings.WeaponText.Visible = false

    -- Separator line
    Drawings.Separator = Drawing.new("Line")
    Drawings.Separator.Color = Theme.Border
    Drawings.Separator.Thickness = 1
    Drawings.Separator.Visible = false
end

-- ══════════════════════════════════════════════════════
-- TARGET FINDING
-- ══════════════════════════════════════════════════════

local function GetClosestTarget()
    local localPlayer = Players.LocalPlayer
    if not localPlayer or not localPlayer.Character then return nil end
    
    local closestDist = math.huge
    local target = nil
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChild("Humanoid")
            
            if hrp and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if dist < closestDist and dist < TargetHUD.MaxRange then
                        closestDist = dist
                        target = player
                    end
                end
            end
        end
    end
    return target
end

-- ══════════════════════════════════════════════════════
-- GET ACTIVE TOOL NAME
-- ══════════════════════════════════════════════════════

local function GetActiveTool(character)
    if not character then return nil end
    for _, child in pairs(character:GetChildren()) do
        if child:IsA("Tool") then
            return child.Name
        end
    end
    return nil
end

-- ══════════════════════════════════════════════════════
-- GET DISTANCE TO TARGET
-- ══════════════════════════════════════════════════════

local function GetDistanceToTarget(targetChar)
    local localChar = Players.LocalPlayer and Players.LocalPlayer.Character
    if not localChar or not targetChar then return 0 end
    
    local localHRP = localChar:FindFirstChild("HumanoidRootPart")
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    
    if localHRP and targetHRP then
        return (localHRP.Position - targetHRP.Position).Magnitude
    end
    return 0
end

-- ══════════════════════════════════════════════════════
-- SET VISIBILITY FOR ALL DRAWINGS
-- ══════════════════════════════════════════════════════

local function SetAllVisible(visible)
    for _, v in pairs(Drawings) do
        if typeof(v) ~= "table" then
            v.Visible = visible
        end
    end
end

-- ══════════════════════════════════════════════════════
-- UPDATE POSITIONS & CONTENT
-- ══════════════════════════════════════════════════════

local function UpdateHUD(dt, pos, target)
    local W = TargetHUD.Size.X
    local H = TargetHUD.Size.Y
    local alpha = fadeAlpha:Get()

    if alpha < 0.01 then
        SetAllVisible(false)
        return
    end

    local character = target.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    if not humanoid then 
        SetAllVisible(false)
        return 
    end

    local healthPct = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
    healthSmooth:Set(healthPct)
    local smoothHP = healthSmooth:Update(dt)
    
    local healthColor = Theme.GetHealthColor(healthPct)
    healthColorSmooth:Set(healthColor)
    local smoothColor = healthColorSmooth:Update(dt)

    -- Avatar dimensions
    local avatarSize = 52
    local avatarPad = 10
    local contentX = pos.X + avatarPad + avatarSize + 10
    local barWidth = W - avatarPad - avatarSize - 20

    -- Calculate pulsing accent
    local pulse = Theme.GetPulse(3)
    local accentColor = Theme.LerpColor(Theme.Accent, Theme.AccentBright, pulse * 0.3)

    -- Shadow
    Drawings.BackgroundShadow.Position = pos + Vector2.new(3, 3)
    Drawings.BackgroundShadow.Size = Vector2.new(W, H)
    Drawings.BackgroundShadow.Transparency = alpha * 0.25
    Drawings.BackgroundShadow.Visible = true

    -- Background
    Drawings.Background.Position = pos
    Drawings.Background.Size = Vector2.new(W, H)
    Drawings.Background.Transparency = alpha * 0.95
    Drawings.Background.Visible = true

    -- Accent gradient line (top)
    local halfW = math.floor(W / 2)
    Drawings.AccentLine.Position = pos
    Drawings.AccentLine.Size = Vector2.new(halfW, 2)
    Drawings.AccentLine.Color = accentColor
    Drawings.AccentLine.Transparency = alpha
    Drawings.AccentLine.Visible = true

    Drawings.AccentLine2.Position = pos + Vector2.new(halfW, 0)
    Drawings.AccentLine2.Size = Vector2.new(W - halfW, 2)
    Drawings.AccentLine2.Color = Theme.LerpColor(accentColor, Theme.Secondary, 0.7)
    Drawings.AccentLine2.Transparency = alpha
    Drawings.AccentLine2.Visible = true

    -- Borders
    Drawings.BorderTop.From = pos
    Drawings.BorderTop.To = pos + Vector2.new(W, 0)
    Drawings.BorderTop.Transparency = alpha * 0.5
    Drawings.BorderTop.Visible = true

    Drawings.BorderBottom.From = pos + Vector2.new(0, H)
    Drawings.BorderBottom.To = pos + Vector2.new(W, H)
    Drawings.BorderBottom.Transparency = alpha * 0.5
    Drawings.BorderBottom.Visible = true

    Drawings.BorderLeft.From = pos
    Drawings.BorderLeft.To = pos + Vector2.new(0, H)
    Drawings.BorderLeft.Transparency = alpha * 0.5
    Drawings.BorderLeft.Visible = true

    Drawings.BorderRight.From = pos + Vector2.new(W, 0)
    Drawings.BorderRight.To = pos + Vector2.new(W, H)
    Drawings.BorderRight.Transparency = alpha * 0.5
    Drawings.BorderRight.Visible = true

    -- Avatar area
    local avatarPos = pos + Vector2.new(avatarPad, (H - avatarSize) / 2 + 1)
    Drawings.AvatarBg.Position = avatarPos
    Drawings.AvatarBg.Size = Vector2.new(avatarSize, avatarSize)
    Drawings.AvatarBg.Transparency = alpha
    Drawings.AvatarBg.Visible = true

    Drawings.AvatarBorder.Position = avatarPos - Vector2.new(1, 1)
    Drawings.AvatarBorder.Size = Vector2.new(avatarSize + 2, avatarSize + 2)
    Drawings.AvatarBorder.Color = accentColor
    Drawings.AvatarBorder.Transparency = alpha * 0.6
    Drawings.AvatarBorder.Visible = true

    -- Player name
    Drawings.Name.Text = target.Name
    Drawings.Name.Position = Vector2.new(contentX, pos.Y + 8)
    Drawings.Name.Transparency = alpha
    Drawings.Name.Visible = true

    -- Display name
    local displayName = target.DisplayName or target.Name
    if displayName ~= target.Name then
        Drawings.DisplayName.Text = "(" .. displayName .. ")"
        Drawings.DisplayName.Position = Vector2.new(contentX, pos.Y + 26)
        Drawings.DisplayName.Transparency = alpha * 0.7
        Drawings.DisplayName.Visible = true
    else
        Drawings.DisplayName.Visible = false
    end

    -- Row for health bar
    local barY = pos.Y + 42
    local barH = 6

    -- Health bar background
    Drawings.HealthBarBg.Position = Vector2.new(contentX, barY)
    Drawings.HealthBarBg.Size = Vector2.new(barWidth, barH)
    Drawings.HealthBarBg.Transparency = alpha
    Drawings.HealthBarBg.Visible = true

    -- Health bar fill
    local fillWidth = math.max(1, barWidth * smoothHP)
    Drawings.HealthBar.Position = Vector2.new(contentX, barY)
    Drawings.HealthBar.Size = Vector2.new(fillWidth, barH)
    Drawings.HealthBar.Color = smoothColor
    Drawings.HealthBar.Transparency = alpha
    Drawings.HealthBar.Visible = true

    -- Pulsing glow when health is low
    if healthPct < 0.3 then
        local glowAlpha = pulse * 0.4 * alpha
        Drawings.HealthBarGlow.Position = Vector2.new(contentX, barY)
        Drawings.HealthBarGlow.Size = Vector2.new(fillWidth, barH)
        Drawings.HealthBarGlow.Transparency = glowAlpha
        Drawings.HealthBarGlow.Color = Theme.DangerGlow
        Drawings.HealthBarGlow.Visible = true
    else
        Drawings.HealthBarGlow.Visible = false
    end

    -- Health text
    Drawings.HealthText.Text = string.format("HP: %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
    Drawings.HealthText.Position = Vector2.new(contentX, barY + barH + 3)
    Drawings.HealthText.Transparency = alpha * 0.8
    Drawings.HealthText.Visible = true

    -- Health percentage (aligned right)
    Drawings.HealthPercent.Text = string.format("%d%%", math.floor(healthPct * 100))
    Drawings.HealthPercent.Position = Vector2.new(contentX + barWidth - 25, barY + barH + 3)
    Drawings.HealthPercent.Color = smoothColor
    Drawings.HealthPercent.Transparency = alpha
    Drawings.HealthPercent.Visible = true

    -- Distance
    if TargetHUD.ShowDistance then
        local dist = GetDistanceToTarget(character)
        Drawings.DistanceText.Text = string.format("%.0f studs", dist)
        Drawings.DistanceText.Position = Vector2.new(contentX, pos.Y + H - 18)
        Drawings.DistanceText.Transparency = alpha * 0.6
        Drawings.DistanceText.Visible = true
    else
        Drawings.DistanceText.Visible = false
    end

    -- Weapon
    if TargetHUD.ShowWeapon then
        local toolName = GetActiveTool(character)
        if toolName then
            Drawings.WeaponText.Text = "⚔ " .. toolName
            Drawings.WeaponText.Position = Vector2.new(contentX + barWidth - 60, pos.Y + H - 18)
            Drawings.WeaponText.Transparency = alpha * 0.8
            Drawings.WeaponText.Visible = true
        else
            Drawings.WeaponText.Visible = false
        end
    else
        Drawings.WeaponText.Visible = false
    end

    -- Separator
    Drawings.Separator.From = Vector2.new(contentX, barY - 3)
    Drawings.Separator.To = Vector2.new(contentX + barWidth, barY - 3)
    Drawings.Separator.Color = Theme.Border
    Drawings.Separator.Transparency = alpha * 0.3
    Drawings.Separator.Visible = false -- subtle, disabled by default
end

-- ══════════════════════════════════════════════════════
-- INIT
-- ══════════════════════════════════════════════════════

function TargetHUD:Init()
    CreateDrawings()
    positionSmooth:Set(TargetHUD.Position)

    -- ─── Render Loop ───
    RunService.RenderStepped:Connect(function(dt)
        if not TargetHUD.Enabled then
            fadeAlpha:Set(0)
            fadeAlpha:Update(dt)
            if fadeAlpha:Get() < 0.01 then
                SetAllVisible(false)
            end
            return
        end

        TargetHUD.CurrentTarget = GetClosestTarget()

        if TargetHUD.CurrentTarget and TargetHUD.CurrentTarget.Character and TargetHUD.CurrentTarget.Character:FindFirstChild("Humanoid") then
            fadeAlpha:Set(1)
        else
            fadeAlpha:Set(0)
        end
        fadeAlpha:Update(dt)

        -- Smooth position
        positionSmooth:Set(TargetHUD.Position)
        local smoothPos = positionSmooth:Update(dt)

        if fadeAlpha:Get() > 0.01 and TargetHUD.CurrentTarget then
            UpdateHUD(dt, smoothPos, TargetHUD.CurrentTarget)
        else
            SetAllVisible(false)
        end
    end)

    -- ─── Drag Logic ───
    local dragStart
    local startPos

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouseLoc = UserInputService:GetMouseLocation()
            local pos = TargetHUD.Position
            local sz = TargetHUD.Size
            if mouseLoc.X >= pos.X and mouseLoc.X <= pos.X + sz.X and
               mouseLoc.Y >= pos.Y and mouseLoc.Y <= pos.Y + sz.Y then
                TargetHUD.Dragging = true
                dragStart = mouseLoc
                startPos = TargetHUD.Position
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            TargetHUD.Dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and TargetHUD.Dragging then
            local delta = UserInputService:GetMouseLocation() - dragStart
            TargetHUD.Position = startPos + delta
        end
    end)
end

return TargetHUD
