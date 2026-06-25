--[[
    VisualClient Animation Utilities v2.0
    Provides smooth easing, spring physics, and tween helpers
]]

local Animate = {}

-- ══════════════════════════════════════════════════════
-- EASING FUNCTIONS
-- ══════════════════════════════════════════════════════

function Animate.EaseOutQuad(t)
    return 1 - (1 - t) * (1 - t)
end

function Animate.EaseInOutQuad(t)
    if t < 0.5 then
        return 2 * t * t
    else
        return 1 - (-2 * t + 2) ^ 2 / 2
    end
end

function Animate.EaseOutCubic(t)
    return 1 - (1 - t) ^ 3
end

function Animate.EaseOutBack(t)
    local c1 = 1.70158
    local c3 = c1 + 1
    return 1 + c3 * (t - 1) ^ 3 + c1 * (t - 1) ^ 2
end

function Animate.EaseOutElastic(t)
    if t == 0 or t == 1 then return t end
    local c4 = (2 * math.pi) / 3
    return 2 ^ (-10 * t) * math.sin((t * 10 - 0.75) * c4) + 1
end

function Animate.EaseOutBounce(t)
    local n1 = 7.5625
    local d1 = 2.75
    if t < 1 / d1 then
        return n1 * t * t
    elseif t < 2 / d1 then
        t = t - 1.5 / d1
        return n1 * t * t + 0.75
    elseif t < 2.5 / d1 then
        t = t - 2.25 / d1
        return n1 * t * t + 0.9375
    else
        t = t - 2.625 / d1
        return n1 * t * t + 0.984375
    end
end

-- ══════════════════════════════════════════════════════
-- SPRING PHYSICS
-- ══════════════════════════════════════════════════════

local Spring = {}
Spring.__index = Spring

function Animate.Spring(initial, stiffness, damping)
    local self = setmetatable({}, Spring)
    self.Position = initial or 0
    self.Velocity = 0
    self.Target = initial or 0
    self.Stiffness = stiffness or 180
    self.Damping = damping or 12
    return self
end

function Spring:Update(dt)
    local displacement = self.Position - self.Target
    local springForce = -self.Stiffness * displacement
    local dampingForce = -self.Damping * self.Velocity
    local acceleration = springForce + dampingForce
    
    self.Velocity = self.Velocity + acceleration * dt
    self.Position = self.Position + self.Velocity * dt
    return self.Position
end

function Spring:SetTarget(target)
    self.Target = target
end

function Spring:IsSettled(threshold)
    threshold = threshold or 0.01
    return math.abs(self.Position - self.Target) < threshold and math.abs(self.Velocity) < threshold
end

-- ══════════════════════════════════════════════════════
-- SMOOTH VALUE TRACKER
-- ══════════════════════════════════════════════════════

local SmoothValue = {}
SmoothValue.__index = SmoothValue

function Animate.SmoothValue(initial, speed)
    local self = setmetatable({}, SmoothValue)
    self.Current = initial or 0
    self.Target = initial or 0
    self.Speed = speed or 10
    return self
end

function SmoothValue:Update(dt)
    self.Current = self.Current + (self.Target - self.Current) * math.min(1, dt * self.Speed)
    return self.Current
end

function SmoothValue:Set(value)
    self.Target = value
end

function SmoothValue:SetInstant(value)
    self.Current = value
    self.Target = value
end

function SmoothValue:Get()
    return self.Current
end

-- ══════════════════════════════════════════════════════
-- SMOOTH COLOR TRACKER
-- ══════════════════════════════════════════════════════

local SmoothColor = {}
SmoothColor.__index = SmoothColor

function Animate.SmoothColor(initial, speed)
    local self = setmetatable({}, SmoothColor)
    initial = initial or Color3.new(1, 1, 1)
    self.R = Animate.SmoothValue(initial.R, speed)
    self.G = Animate.SmoothValue(initial.G, speed)
    self.B = Animate.SmoothValue(initial.B, speed)
    return self
end

function SmoothColor:Update(dt)
    return Color3.new(
        self.R:Update(dt),
        self.G:Update(dt),
        self.B:Update(dt)
    )
end

function SmoothColor:Set(color)
    self.R:Set(color.R)
    self.G:Set(color.G)
    self.B:Set(color.B)
end

function SmoothColor:Get()
    return Color3.new(self.R:Get(), self.G:Get(), self.B:Get())
end

-- ══════════════════════════════════════════════════════
-- SMOOTH VECTOR2 TRACKER
-- ══════════════════════════════════════════════════════

local SmoothVector2 = {}
SmoothVector2.__index = SmoothVector2

function Animate.SmoothVector2(initial, speed)
    local self = setmetatable({}, SmoothVector2)
    initial = initial or Vector2.new(0, 0)
    self.X = Animate.SmoothValue(initial.X, speed)
    self.Y = Animate.SmoothValue(initial.Y, speed)
    return self
end

function SmoothVector2:Update(dt)
    return Vector2.new(
        self.X:Update(dt),
        self.Y:Update(dt)
    )
end

function SmoothVector2:Set(vec)
    self.X:Set(vec.X)
    self.Y:Set(vec.Y)
end

function SmoothVector2:Get()
    return Vector2.new(self.X:Get(), self.Y:Get())
end

return Animate
