local TargetHUD = {}
TargetHUD.Target = nil

function TargetHUD:SetTarget(player)
    self.Target = player
    print("Target set to: ", player and player.Name or "None")
end

function TargetHUD:Update()
    if not self.Target then return end
    -- Update HUD with target health, distance, etc.
end

return TargetHUD
