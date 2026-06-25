-- VisualClient Chams Module v2.0
-- Improved with team colors, rainbow mode, optimized rendering, smooth transitions
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local targetGui = gethui and gethui() or CoreGui

local Chams = {
    Enabled = false,
    Mode = "Highlight",
    FillColor = Color3.fromRGB(170, 0, 255),
    OutlineColor = Color3.fromRGB(255, 255, 255),
    FillTransparency = 0.5,
    OutlineTransparency = 0,
    Rainbow = false,
    TeamCheck = false,
    Folder = nil,
    _connections = {},
    _cache = {},
    _hue = 0,
}

function Chams:Init()
    if self.Folder then pcall(function() self.Folder:Destroy() end) end
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "VC_Chams_" .. tostring(math.random(1000, 9999))
    self.Folder.Parent = targetGui
end
Chams:Init()

local function isAlive(character)
    if not character then return false end
    local hum = character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function isEnemy(player)
    if not Chams.TeamCheck then return true end
    return player.Team ~= LocalPlayer.Team
end

-- ═══════════════════════════════════════════
-- MODE: Highlight (самый классический)
-- ═══════════════════════════════════════════
function Chams:ApplyHighlight(character, player)
    local hl = Instance.new("Highlight")
    hl.Name = "VC_HL_" .. player.Name
    hl.Adornee = character
    hl.FillColor = self.FillColor
    hl.FillTransparency = self.FillTransparency
    hl.OutlineColor = self.OutlineColor
    hl.OutlineTransparency = self.OutlineTransparency
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = self.Folder
    self._cache[player.UserId] = {Type = "Highlight", Objects = {hl}}
end

-- ═══════════════════════════════════════════
-- MODE: PartChams (полупрозрачные боксы на каждой части тела)
-- ═══════════════════════════════════════════
function Chams:ApplyPartChams(character, player)
    local objects = {}
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local adorn = Instance.new("BoxHandleAdornment")
            adorn.Name = "VC_PC_" .. part.Name
            adorn.Adornee = part
            adorn.AlwaysOnTop = true
            adorn.ZIndex = 5
            adorn.Size = part.Size + Vector3.new(0.06, 0.06, 0.06)
            adorn.Transparency = self.FillTransparency
            adorn.Color3 = self.FillColor
            adorn.Parent = self.Folder
            table.insert(objects, adorn)
        end
    end
    self._cache[player.UserId] = {Type = "PartChams", Objects = objects}
end

-- ═══════════════════════════════════════════
-- MODE: Shaders (ForceField материал — свечение)
-- ═══════════════════════════════════════════
function Chams:ApplyShaders(character, player)
    local objects = {}
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local clone = Instance.new("Part")
            clone.Name = "VC_SH_" .. part.Name
            clone.Size = part.Size + Vector3.new(0.08, 0.08, 0.08)
            clone.CFrame = part.CFrame
            clone.Material = Enum.Material.ForceField
            clone.Color = self.FillColor
            clone.CanCollide = false
            clone.Anchored = false
            clone.Transparency = 0.15
            clone.CastShadow = false
            clone.Parent = self.Folder

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = clone
            weld.Part1 = part
            weld.Parent = clone
            table.insert(objects, clone)
        end
    end
    self._cache[player.UserId] = {Type = "Shaders", Objects = objects}
end

-- ═══════════════════════════════════════════
-- MODE: Outline (только контур, без заливки)
-- ═══════════════════════════════════════════
function Chams:ApplyOutline(character, player)
    local hl = Instance.new("Highlight")
    hl.Name = "VC_OL_" .. player.Name
    hl.Adornee = character
    hl.FillTransparency = 1
    hl.OutlineColor = self.FillColor
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = self.Folder
    self._cache[player.UserId] = {Type = "Outline", Objects = {hl}}
end

-- ═══════════════════════════════════════════
-- MODE: Box (3D бокс вокруг всего персонажа)
-- ═══════════════════════════════════════════
function Chams:ApplyBox(character, player)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "VC_BX_" .. player.Name
    box.Adornee = hrp
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Size = Vector3.new(4, 5.5, 2)
    box.Transparency = self.FillTransparency + 0.2
    box.Color3 = self.FillColor
    box.Parent = self.Folder

    -- Внутренний бокс для эффекта глубины
    local innerBox = Instance.new("BoxHandleAdornment")
    innerBox.Name = "VC_BXI_" .. player.Name
    innerBox.Adornee = hrp
    innerBox.AlwaysOnTop = true
    innerBox.ZIndex = 4
    innerBox.Size = Vector3.new(3.8, 5.3, 1.8)
    innerBox.Transparency = self.FillTransparency + 0.4
    innerBox.Color3 = self.OutlineColor
    innerBox.Parent = self.Folder

    self._cache[player.UserId] = {Type = "Box", Objects = {box, innerBox}}
end

-- ═══════════════════════════════════════════
-- CACHE & UPDATE SYSTEM
-- ═══════════════════════════════════════════
function Chams:ClearPlayer(userId)
    local cached = self._cache[userId]
    if cached then
        for _, obj in ipairs(cached.Objects) do
            if obj and obj.Parent then obj:Destroy() end
        end
        self._cache[userId] = nil
    end
end

function Chams:ClearAll()
    for uid, _ in pairs(self._cache) do
        self:ClearPlayer(uid)
    end
    self._cache = {}
    if self.Folder then self.Folder:ClearAllChildren() end
end

function Chams:ApplyToPlayer(player)
    if player == LocalPlayer then return end
    if not player.Character or not isAlive(player.Character) then return end
    if not isEnemy(player) then return end

    self:ClearPlayer(player.UserId)

    local mode = self.Mode
    if mode == "Highlight" then
        self:ApplyHighlight(player.Character, player)
    elseif mode == "PartChams" then
        self:ApplyPartChams(player.Character, player)
    elseif mode == "Shaders" then
        self:ApplyShaders(player.Character, player)
    elseif mode == "Outline" then
        self:ApplyOutline(player.Character, player)
    elseif mode == "Box" then
        self:ApplyBox(player.Character, player)
    end
end

function Chams:Refresh()
    self:ClearAll()
    if not self.Enabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        self:ApplyToPlayer(player)
    end
end

-- ═══════════════════════════════════════════
-- RAINBOW UPDATE (плавная смена цвета)
-- ═══════════════════════════════════════════
function Chams:UpdateRainbow(dt)
    self._hue = (self._hue + dt * 0.15) % 1
    self.FillColor = Color3.fromHSV(self._hue, 0.8, 1)

    for _, cached in pairs(self._cache) do
        for _, obj in ipairs(cached.Objects) do
            if obj and obj.Parent then
                if obj:IsA("Highlight") then
                    if cached.Type == "Outline" then
                        obj.OutlineColor = self.FillColor
                    else
                        obj.FillColor = self.FillColor
                    end
                elseif obj:IsA("BoxHandleAdornment") then
                    obj.Color3 = self.FillColor
                elseif obj:IsA("BasePart") then
                    obj.Color = self.FillColor
                end
            end
        end
    end
end

-- ═══════════════════════════════════════════
-- TOGGLE (Вкл/выкл)
-- ═══════════════════════════════════════════
function Chams:Toggle(state)
    self.Enabled = state

    -- Disconnect old connections
    for _, conn in ipairs(self._connections) do
        if conn.Connected then conn:Disconnect() end
    end
    self._connections = {}

    if not state then
        self:ClearAll()
        return
    end

    -- RenderStepped for rainbow
    table.insert(self._connections, RunService.RenderStepped:Connect(function(dt)
        if self.Rainbow then
            self:UpdateRainbow(dt)
        end

        -- Check for dead players and remove their chams
        for uid, _ in pairs(self._cache) do
            local p = Players:GetPlayerByUserId(uid)
            if not p or not p.Character or not isAlive(p.Character) then
                self:ClearPlayer(uid)
            end
        end
    end))

    -- Watch for new players
    table.insert(self._connections, Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            if self.Enabled then self:ApplyToPlayer(player) end
        end)
    end))

    -- Watch for player removal
    table.insert(self._connections, Players.PlayerRemoving:Connect(function(player)
        self:ClearPlayer(player.UserId)
    end))

    -- Watch existing players' respawns
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(self._connections, player.CharacterAdded:Connect(function()
                task.wait(0.5)
                if self.Enabled then self:ApplyToPlayer(player) end
            end))
        end
    end

    self:Refresh()
end

-- ═══════════════════════════════════════════
-- SET MODE (переключение режима на лету)
-- ═══════════════════════════════════════════
function Chams:SetMode(newMode)
    self.Mode = newMode
    if self.Enabled then
        self:Refresh()
    end
end

function Chams:SetColor(color)
    self.FillColor = color
    self.Rainbow = false
    if self.Enabled then self:Refresh() end
end

function Chams:SetRainbow(state)
    self.Rainbow = state
end

function Chams:Destroy()
    self:Toggle(false)
    if self.Folder then self.Folder:Destroy() end
end

return Chams
