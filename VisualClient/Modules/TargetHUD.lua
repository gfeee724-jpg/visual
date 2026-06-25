-- VisualClient Target HUD Module v1.0
-- Beautiful gradient target info panel with health bar, distance, avatar
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local targetGui = gethui and gethui() or CoreGui

local TargetHUD = {
    Enabled = false,
    Target = nil,
    MaxDistance = 200,
    _connections = {},
    _gui = nil,
    _elements = {},
}

-- Gradient colors (violet → cyan → magenta)
local GradientColor1 = Color3.fromRGB(130, 80, 255)   -- Violet
local GradientColor2 = Color3.fromRGB(80, 200, 255)    -- Cyan  
local GradientColor3 = Color3.fromRGB(255, 80, 180)    -- Magenta

function TargetHUD:GetClosestPlayer()
    local closest = nil
    local minDist = self.MaxDistance

    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
                local dist = (myHRP.Position - hrp.Position).Magnitude
                if dist < minDist then
                    closest = player
                    minDist = dist
                end
            end
        end
    end
    return closest
end

function TargetHUD:CreateGUI()
    if self._gui then pcall(function() self._gui:Destroy() end) end

    local gui = Instance.new("ScreenGui")
    gui.Name = "VC_TargetHUD_" .. math.random(1000, 9999)
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = targetGui
    self._gui = gui

    -- Main container
    local container = Instance.new("CanvasGroup")
    container.Name = "Container"
    container.Size = UDim2.new(0, 280, 0, 90)
    container.Position = UDim2.new(0.5, 0, 0.2, 0)
    container.AnchorPoint = Vector2.new(0.5, 0)
    container.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    container.GroupTransparency = 1
    container.Parent = gui
    self._elements.Container = container

    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", container)
    stroke.Color = Color3.fromRGB(50, 50, 60)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3

    -- Gradient accent bar (top)
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 3)
    topBar.Position = UDim2.new(0, 0, 0, 0)
    topBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    topBar.BorderSizePixel = 0
    topBar.Parent = container

    local topBarCorner = Instance.new("UICorner", topBar)
    topBarCorner.CornerRadius = UDim.new(0, 12)

    local topGradient = Instance.new("UIGradient", topBar)
    topGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, GradientColor1),
        ColorSequenceKeypoint.new(0.5, GradientColor2),
        ColorSequenceKeypoint.new(1, GradientColor3),
    })
    self._elements.TopGradient = topGradient

    -- Fix rounded corners at bottom of accent bar
    local topBarFix = Instance.new("Frame")
    topBarFix.Size = UDim2.new(1, 0, 0, 2)
    topBarFix.Position = UDim2.new(0, 0, 1, -2)
    topBarFix.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    topBarFix.BorderSizePixel = 0
    topBarFix.Parent = topBar
    local topBarFixGrad = Instance.new("UIGradient", topBarFix)
    topBarFixGrad.Color = topGradient.Color

    -- Avatar frame
    local avatarFrame = Instance.new("ImageLabel")
    avatarFrame.Name = "Avatar"
    avatarFrame.Size = UDim2.new(0, 52, 0, 52)
    avatarFrame.Position = UDim2.new(0, 14, 0, 20)
    avatarFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    avatarFrame.Image = ""
    avatarFrame.Parent = container
    self._elements.Avatar = avatarFrame

    Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(0, 10)

    local avatarStroke = Instance.new("UIStroke", avatarFrame)
    avatarStroke.Color = GradientColor1
    avatarStroke.Thickness = 1.5
    avatarStroke.Transparency = 0.4

    -- Player name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "PlayerName"
    nameLabel.Size = UDim2.new(0, 170, 0, 20)
    nameLabel.Position = UDim2.new(0, 78, 0, 18)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "No Target"
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = container
    self._elements.Name = nameLabel

    -- Distance label
    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "Distance"
    distLabel.Size = UDim2.new(0, 80, 0, 14)
    distLabel.Position = UDim2.new(0, 78, 0, 38)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.Font = Enum.Font.GothamMedium
    distLabel.TextSize = 11
    distLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
    distLabel.TextXAlignment = Enum.TextXAlignment.Left
    distLabel.Parent = container
    self._elements.Distance = distLabel

    -- Health text  
    local healthText = Instance.new("TextLabel")
    healthText.Name = "HealthText"
    healthText.Size = UDim2.new(0, 60, 0, 14)
    healthText.Position = UDim2.new(1, -74, 0, 38)
    healthText.BackgroundTransparency = 1
    healthText.Text = "100 HP"
    healthText.Font = Enum.Font.GothamBold
    healthText.TextSize = 11
    healthText.TextColor3 = GradientColor2
    healthText.TextXAlignment = Enum.TextXAlignment.Right
    healthText.Parent = container
    self._elements.HealthText = healthText

    -- Health bar background
    local hpBarBg = Instance.new("Frame")
    hpBarBg.Name = "HealthBarBg"
    hpBarBg.Size = UDim2.new(0, 190, 0, 6)
    hpBarBg.Position = UDim2.new(0, 78, 0, 62)
    hpBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    hpBarBg.BorderSizePixel = 0
    hpBarBg.Parent = container
    Instance.new("UICorner", hpBarBg).CornerRadius = UDim.new(1, 0)

    -- Health bar fill with gradient
    local hpBarFill = Instance.new("Frame")
    hpBarFill.Name = "HealthBarFill"
    hpBarFill.Size = UDim2.new(1, 0, 1, 0)
    hpBarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hpBarFill.BorderSizePixel = 0
    hpBarFill.Parent = hpBarBg
    Instance.new("UICorner", hpBarFill).CornerRadius = UDim.new(1, 0)
    self._elements.HealthBar = hpBarFill

    local hpGradient = Instance.new("UIGradient", hpBarFill)
    hpGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, GradientColor1),
        ColorSequenceKeypoint.new(0.5, GradientColor2),
        ColorSequenceKeypoint.new(1, GradientColor3),
    })
    self._elements.HealthGradient = hpGradient

    -- Glow effect under health bar
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 4, 0, 8)
    glow.Position = UDim2.new(0, -2, 0.5, -4)
    glow.BackgroundColor3 = GradientColor2
    glow.BackgroundTransparency = 0.7
    glow.BorderSizePixel = 0
    glow.Parent = hpBarFill
    Instance.new("UICorner", glow).CornerRadius = UDim.new(1, 0)

    return gui
end

function TargetHUD:Show()
    if not self._elements.Container then return end
    TweenService:Create(self._elements.Container, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        GroupTransparency = 0,
        Position = UDim2.new(0.5, 0, 0.2, 0)
    }):Play()
end

function TargetHUD:Hide()
    if not self._elements.Container then return end
    TweenService:Create(self._elements.Container, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        GroupTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.18, 0)
    }):Play()
end

function TargetHUD:UpdateTarget(player)
    if not player or not player.Character then
        if self.Target then
            self.Target = nil
            self:Hide()
        end
        return
    end

    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not hrp then
        if self.Target then
            self.Target = nil
            self:Hide()
        end
        return
    end

    local wasNil = (self.Target == nil)
    self.Target = player

    -- Update avatar
    local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150&format=png"
    if self._elements.Avatar then
        self._elements.Avatar.Image = avatarUrl
    end

    -- Update name
    if self._elements.Name then
        local displayName = player.DisplayName
        if displayName ~= player.Name then
            self._elements.Name.Text = displayName .. " (" .. player.Name .. ")"
        else
            self._elements.Name.Text = player.Name
        end
    end

    -- Update health
    local hp = math.floor(hum.Health)
    local maxHp = math.floor(hum.MaxHealth)
    local ratio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)

    if self._elements.HealthText then
        self._elements.HealthText.Text = hp .. " HP"
        -- Color health text based on ratio
        if ratio > 0.6 then
            self._elements.HealthText.TextColor3 = GradientColor2
        elseif ratio > 0.3 then
            self._elements.HealthText.TextColor3 = Color3.fromRGB(255, 200, 80)
        else
            self._elements.HealthText.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
    end

    -- Smooth health bar
    if self._elements.HealthBar then
        TweenService:Create(self._elements.HealthBar, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(ratio, 0, 1, 0)
        }):Play()
    end

    -- Update distance
    local myChar = LocalPlayer.Character
    if myChar and myChar:FindFirstChild("HumanoidRootPart") and self._elements.Distance then
        local dist = math.floor((myChar.HumanoidRootPart.Position - hrp.Position).Magnitude)
        self._elements.Distance.Text = dist .. "m away"
    end

    if wasNil then
        self:Show()
    end
end

function TargetHUD:Toggle(state)
    self.Enabled = state

    for _, conn in ipairs(self._connections) do
        if conn.Connected then conn:Disconnect() end
    end
    self._connections = {}

    if not state then
        self.Target = nil
        self:Hide()
        task.delay(0.3, function()
            if not self.Enabled and self._gui then
                self._gui:Destroy()
                self._gui = nil
                self._elements = {}
            end
        end)
        return
    end

    self:CreateGUI()

    -- Gradient animation (slowly shifts the gradient offset for a living feel)
    local gradOffset = 0
    table.insert(self._connections, RunService.RenderStepped:Connect(function(dt)
        gradOffset = (gradOffset + dt * 0.2) % 1

        if self._elements.TopGradient then
            self._elements.TopGradient.Offset = Vector2.new(math.sin(gradOffset * math.pi * 2) * 0.3, 0)
        end
        if self._elements.HealthGradient then
            self._elements.HealthGradient.Offset = Vector2.new(math.sin(gradOffset * math.pi * 2) * 0.2, 0)
        end

        -- Auto-find closest target
        local closest = self:GetClosestPlayer()
        self:UpdateTarget(closest)
    end))

    -- Cleanup on player leave
    table.insert(self._connections, Players.PlayerRemoving:Connect(function(player)
        if self.Target == player then
            self.Target = nil
            self:Hide()
        end
    end))
end

function TargetHUD:Destroy()
    self:Toggle(false)
    if self._gui then self._gui:Destroy() end
end

return TargetHUD
