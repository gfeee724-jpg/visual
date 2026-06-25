local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local targetGui = gethui and gethui() or CoreGui

local Chams = {
    Enabled = false,
    Mode = "Highlight", -- Highlight, PartChams, Shaders, Outline, Box
    Color = Color3.fromRGB(255, 0, 0),
    Transparency = 0.5,
    Folder = Instance.new("Folder"),
    Connections = {}
}

Chams.Folder.Name = "VisualClient_Chams"
Chams.Folder.Parent = targetGui

function Chams:Clear()
    self.Folder:ClearAllChildren()
end

function Chams:ApplyHighlight(character, player)
    local hl = Instance.new("Highlight")
    hl.Name = player.Name
    hl.Parent = self.Folder
    hl.Adornee = character
    hl.FillColor = self.Color
    hl.FillTransparency = self.Transparency
    hl.OutlineColor = Color3.new(1, 1, 1)
    hl.OutlineTransparency = 0
end

function Chams:ApplyOutline(character, player)
    local hl = Instance.new("Highlight")
    hl.Name = player.Name
    hl.Parent = self.Folder
    hl.Adornee = character
    hl.FillTransparency = 1
    hl.OutlineColor = self.Color
    hl.OutlineTransparency = 0
end

function Chams:ApplyPartChams(character, player)
    local model = Instance.new("Model")
    model.Name = player.Name
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local clone = Instance.new("BoxHandleAdornment")
            clone.Name = part.Name
            clone.Adornee = part
            clone.AlwaysOnTop = true
            clone.ZIndex = 5
            clone.Size = part.Size
            clone.Transparency = self.Transparency
            clone.Color3 = self.Color
            clone.Parent = model
        end
    end
    model.Parent = self.Folder
end

function Chams:ApplyShaders(character, player)
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local clone = Instance.new("Part")
            clone.Name = part.Name
            clone.Size = part.Size + Vector3.new(0.05, 0.05, 0.05)
            clone.CFrame = part.CFrame
            clone.Material = Enum.Material.ForceField
            clone.Color = self.Color
            clone.CanCollide = false
            clone.Anchored = true
            clone.Transparency = 0.1
            clone.Parent = self.Folder
            
            -- Weld
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = clone
            weld.Part1 = part
            weld.Parent = clone
            clone.Anchored = false
        end
    end
end

function Chams:ApplyBox(character, player)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = player.Name
        box.Adornee = hrp
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Size = Vector3.new(4, 5, 1)
        box.Transparency = self.Transparency
        box.Color3 = self.Color
        box.Parent = self.Folder
    end
end

function Chams:Update()
    self:Clear()
    if not self.Enabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character then
            if self.Mode == "Highlight" then
                self:ApplyHighlight(player.Character, player)
            elseif self.Mode == "PartChams" then
                self:ApplyPartChams(player.Character, player)
            elseif self.Mode == "Shaders" then
                self:ApplyShaders(player.Character, player)
            elseif self.Mode == "Outline" then
                self:ApplyOutline(player.Character, player)
            elseif self.Mode == "Box" then
                self:ApplyBox(player.Character, player)
            end
        end
    end
end

function Chams:Toggle(state)
    self.Enabled = state
    
    if state then
        table.insert(self.Connections, RunService.RenderStepped:Connect(function()
            if self.Mode == "PartChams" or self.Mode == "Shaders" or self.Mode == "Box" then
                -- Could optimize, but for simplicity we recreate/update per character basis
                -- For Highlight and Outline, Adornee handles it automatically, but we just call Update to be safe.
            end
        end))
        
        table.insert(self.Connections, Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                task.wait(1)
                self:Update()
            end)
        end))
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                p.CharacterAdded:Connect(function()
                    task.wait(1)
                    self:Update()
                end)
            end
        end
        
        self:Update()
    else
        for _, conn in ipairs(self.Connections) do
            conn:Disconnect()
        end
        self.Connections = {}
        self:Clear()
    end
end

function Chams:SetMode(newMode)
    self.Mode = newMode
    self:Update()
end

return Chams
