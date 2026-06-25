local ESP = {}
ESP.Enabled = false

function ESP:Toggle(state)
    self.Enabled = state
    if state then
        print("ESP Enabled")
        -- Add ESP logic
    else
        print("ESP Disabled")
        -- Remove ESP logic
    end
end

return ESP
