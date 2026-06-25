--[[
    VisualClient Watermark v2.0
    Animated watermark with FPS counter, ping, time, and gradient accent
]]

local Theme = require(script.Parent.Parent.Utils.Theme)
local Animate = require(script.Parent.Parent.Utils.Animate)

local Watermark = {
    Enabled = true,
    Position = Vector2.new(10, 10),
    Title = "VisualClient",
    ShowFPS = true,
    ShowPing = true,
    ShowTime = true,
}

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Players = game:GetService("Players")

local Drawings = {}
local fpsSmooth = Animate.SmoothValue(60, 5)
local fpsBuffer = {}
local fpsIndex = 0
local maxSamples = 30

local function CreateDrawings()
    Drawings.Background = Drawing.new("Square")
    Drawings.Background.Color = Theme.Background
    Drawings.Background.Filled = true
    Drawings.Background.Transparency = 0.9
    Drawings.Background.Visible = false

    Drawings.AccentLine = Drawing.new("Square")
    Drawings.AccentLine.Color = Theme.Accent
    Drawings.AccentLine.Filled = true
    Drawings.AccentLine.Visible = false

    Drawings.AccentLine2 = Drawing.new("Square")
    Drawings.AccentLine2.Color = Theme.Secondary
    Drawings.AccentLine2.Filled = true
    Drawings.AccentLine2.Visible = false

    Drawings.BorderBottom = Drawing.new("Line")
    Drawings.BorderBottom.Color = Theme.Border
    Drawings.BorderBottom.Thickness = 1
    Drawings.BorderBottom.Visible = false

    Drawings.Text = Drawing.new("Text")
    Drawings.Text.Color = Theme.Text
    Drawings.Text.Size = Theme.FontSize
    Drawings.Text.Center = false
    Drawings.Text.Outline = true
    Drawings.Text.Font = Drawing.Fonts.Plex
    Drawings.Text.Visible = false
end

function Watermark:Init()
    CreateDrawings()

    RunService.RenderStepped:Connect(function(dt)
        if not Watermark.Enabled then
            for _, v in pairs(Drawings) do v.Visible = false end
            return
        end

        -- FPS calculation (rolling average)
        local fps = 1 / math.max(dt, 0.001)
        fpsIndex = (fpsIndex % maxSamples) + 1
        fpsBuffer[fpsIndex] = fps
        local avgFps = 0
        local count = 0
        for _, v in ipairs(fpsBuffer) do
            avgFps = avgFps + v
            count = count + 1
        end
        avgFps = count > 0 and (avgFps / count) or 60
        fpsSmooth:Set(avgFps)
        local smoothFps = math.floor(fpsSmooth:Update(dt))

        -- Build text
        local parts = {Watermark.Title}
        if Watermark.ShowFPS then
            table.insert(parts, string.format("%d fps", smoothFps))
        end
        if Watermark.ShowPing then
            local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            table.insert(parts, string.format("%dms", ping))
        end
        if Watermark.ShowTime then
            table.insert(parts, os.date("%H:%M:%S"))
        end

        local text = table.concat(parts, "  |  ")
        Drawings.Text.Text = text

        -- Calculate width from text
        local textBounds = Drawings.Text.TextBounds
        local padX = 12
        local padY = 6
        local W = textBounds.X + padX * 2
        local H = textBounds.Y + padY * 2

        local pos = Watermark.Position

        -- Background
        Drawings.Background.Position = pos
        Drawings.Background.Size = Vector2.new(W, H)
        Drawings.Background.Visible = true

        -- Accent line (top, gradient split)
        local halfW = math.floor(W / 2)
        local pulse = Theme.GetPulse(2)
        local col = Theme.LerpColor(Theme.Accent, Theme.AccentBright, pulse * 0.3)

        Drawings.AccentLine.Position = pos
        Drawings.AccentLine.Size = Vector2.new(halfW, 2)
        Drawings.AccentLine.Color = col
        Drawings.AccentLine.Visible = true

        Drawings.AccentLine2.Position = pos + Vector2.new(halfW, 0)
        Drawings.AccentLine2.Size = Vector2.new(W - halfW, 2)
        Drawings.AccentLine2.Color = Theme.LerpColor(col, Theme.Secondary, 0.7)
        Drawings.AccentLine2.Visible = true

        -- Border bottom
        Drawings.BorderBottom.From = pos + Vector2.new(0, H)
        Drawings.BorderBottom.To = pos + Vector2.new(W, H)
        Drawings.BorderBottom.Color = Theme.Border
        Drawings.BorderBottom.Visible = true

        -- Text
        Drawings.Text.Position = pos + Vector2.new(padX, padY)
        Drawings.Text.Visible = true
    end)
end

return Watermark
