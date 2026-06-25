--[[
    VisualClient Theme System v2.0
    Premium dark theme with gradient support and animation tokens
]]

local Theme = {}

-- ══════════════════════════════════════════════════════
-- CORE COLORS
-- ══════════════════════════════════════════════════════
Theme.Background       = Color3.fromRGB(10, 10, 14)
Theme.BackgroundAlt    = Color3.fromRGB(16, 16, 22)
Theme.Surface          = Color3.fromRGB(22, 22, 30)
Theme.SurfaceHover     = Color3.fromRGB(30, 30, 40)
Theme.SurfaceActive    = Color3.fromRGB(38, 38, 50)
Theme.Border           = Color3.fromRGB(40, 40, 55)
Theme.BorderFocus      = Color3.fromRGB(80, 130, 255)

-- ══════════════════════════════════════════════════════
-- ACCENT COLORS
-- ══════════════════════════════════════════════════════
Theme.Accent           = Color3.fromRGB(90, 120, 255)
Theme.AccentBright     = Color3.fromRGB(120, 150, 255)
Theme.AccentMuted      = Color3.fromRGB(50, 70, 160)
Theme.AccentDark       = Color3.fromRGB(30, 40, 100)
Theme.AccentGlow       = Color3.fromRGB(90, 120, 255)

-- Secondary accent (purple tones for gradients)
Theme.Secondary        = Color3.fromRGB(160, 80, 255)
Theme.SecondaryBright  = Color3.fromRGB(190, 120, 255)
Theme.SecondaryMuted   = Color3.fromRGB(100, 50, 160)

-- ══════════════════════════════════════════════════════
-- TEXT COLORS
-- ══════════════════════════════════════════════════════
Theme.Text             = Color3.fromRGB(235, 235, 245)
Theme.TextSecondary    = Color3.fromRGB(180, 180, 200)
Theme.TextMuted        = Color3.fromRGB(120, 120, 140)
Theme.TextDisabled     = Color3.fromRGB(70, 70, 85)
Theme.TextAccent       = Color3.fromRGB(130, 160, 255)

-- ══════════════════════════════════════════════════════
-- STATUS COLORS
-- ══════════════════════════════════════════════════════
Theme.Safe             = Color3.fromRGB(40, 220, 100)
Theme.SafeGlow         = Color3.fromRGB(40, 255, 110)
Theme.Warning          = Color3.fromRGB(255, 180, 40)
Theme.WarningGlow      = Color3.fromRGB(255, 200, 60)
Theme.Danger           = Color3.fromRGB(255, 50, 50)
Theme.DangerGlow       = Color3.fromRGB(255, 80, 80)
Theme.Info             = Color3.fromRGB(60, 180, 255)

-- ══════════════════════════════════════════════════════
-- ANIMATION TOKENS
-- ══════════════════════════════════════════════════════
Theme.AnimSpeed        = 0.08   -- General lerp alpha per frame
Theme.AnimSpeedFast    = 0.15   -- Fast transitions
Theme.AnimSpeedSlow    = 0.04   -- Slow, smooth transitions
Theme.FadeSpeed        = 0.12   -- Fade in/out alpha
Theme.PulseSpeed       = 2.5    -- Pulse cycles per second

-- ══════════════════════════════════════════════════════
-- SIZES & LAYOUT
-- ══════════════════════════════════════════════════════
Theme.CornerRadius     = 6
Theme.Padding          = 8
Theme.PaddingLarge     = 16
Theme.FontSize         = 13
Theme.FontSizeSmall    = 11
Theme.FontSizeLarge    = 16
Theme.FontSizeTitle    = 20
Theme.FontSizeHeader   = 24
Theme.HeaderHeight     = 32
Theme.ToggleWidth      = 36
Theme.ToggleHeight     = 18
Theme.SliderHeight     = 4
Theme.SliderKnobSize   = 12

-- ══════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ══════════════════════════════════════════════════════

-- Lerp between two colors with clamping
function Theme.LerpColor(colorA, colorB, alpha)
    alpha = math.clamp(alpha, 0, 1)
    return Color3.new(
        colorA.R + (colorB.R - colorA.R) * alpha,
        colorA.G + (colorB.G - colorA.G) * alpha,
        colorA.B + (colorB.B - colorA.B) * alpha
    )
end

-- Get health color with smooth gradient: red -> yellow -> green
function Theme.GetHealthColor(healthPercent)
    healthPercent = math.clamp(healthPercent, 0, 1)
    if healthPercent > 0.5 then
        return Theme.LerpColor(Theme.Warning, Theme.Safe, (healthPercent - 0.5) * 2)
    else
        return Theme.LerpColor(Theme.Danger, Theme.Warning, healthPercent * 2)
    end
end

-- Get a pulsing alpha value
function Theme.GetPulse(speed)
    speed = speed or Theme.PulseSpeed
    return (math.sin(tick() * speed * math.pi) + 1) / 2
end

-- Smooth lerp number
function Theme.SmoothLerp(current, target, alpha)
    alpha = alpha or Theme.AnimSpeed
    if math.abs(current - target) < 0.001 then return target end
    return current + (target - current) * alpha
end

-- Smooth approach with delta time
function Theme.Approach(current, target, dt, speed)
    speed = speed or 10
    local diff = target - current
    return current + diff * math.min(1, dt * speed)
end

return Theme
