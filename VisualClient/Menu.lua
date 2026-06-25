local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Расширенная тема с акцентами
local Theme = {
    Main = Color3.fromRGB(18, 18, 18),
    Sidebar = Color3.fromRGB(12, 12, 12),
    Card = Color3.fromRGB(24, 24, 24),
    CardHover = Color3.fromRGB(28, 28, 28),
    Stroke = Color3.fromRGB(40, 40, 40),
    StrokeActive = Color3.fromRGB(90, 120, 255),
    Accent = Color3.fromRGB(90, 120, 255),

    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(140, 140, 140),
    
    ToggleBg = Color3.fromRGB(35, 35, 35),
    ToggleBgActive = Color3.fromRGB(90, 120, 255),
    ToggleDot = Color3.fromRGB(180, 180, 180),
    ToggleDotActive = Color3.fromRGB(255, 255, 255)
}

local Presets = {
    {Name = "Midnight Blue", Main = Color3.fromRGB(15, 15, 18), Sidebar = Color3.fromRGB(10, 10, 12), Card = Color3.fromRGB(22, 22, 28), Stroke = Color3.fromRGB(40, 40, 55), Accent = Color3.fromRGB(80, 140, 255)},
    {Name = "Obsidian Black", Main = Color3.fromRGB(10, 10, 10), Sidebar = Color3.fromRGB(6, 6, 6), Card = Color3.fromRGB(16, 16, 16), Stroke = Color3.fromRGB(30, 30, 30), Accent = Color3.fromRGB(200, 200, 200)},
    {Name = "Ruby Dark", Main = Color3.fromRGB(20, 15, 15), Sidebar = Color3.fromRGB(14, 10, 10), Card = Color3.fromRGB(28, 20, 20), Stroke = Color3.fromRGB(55, 35, 35), Accent = Color3.fromRGB(255, 80, 80)},
    {Name = "Cyber Glow", Main = Color3.fromRGB(13, 15, 20), Sidebar = Color3.fromRGB(8, 9, 13), Card = Color3.fromRGB(20, 22, 28), Stroke = Color3.fromRGB(35, 38, 48), Accent = Color3.fromRGB(60, 220, 255)}
}

local Tabs = {}
local CurrentTab = nil

-- GUI ROOT
local Gui = Instance.new("ScreenGui")
Gui.Name = "VisualClient_PremiumGUI"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = gethui and gethui() or CoreGui

-- MAIN LAYER FOR SCALE ANIMATIONS
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, 0, 1, 0)
Container.BackgroundTransparency = 1
Container.Parent = Gui

-- MAIN FRAME
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 780, 0, 480)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Theme.Main
Main.BorderSizePixel = 0
Main.Parent = Container

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Theme.Stroke
MainStroke.Thickness = 1

-- GLOW/SHADOW (Hack via ImageLabel)
local Glow = Instance.new("ImageLabel")
Glow.Name = "Shadow"
Glow.BackgroundTransparency = 1
Glow.Position = UDim2.new(0, -30, 0, -30)
Glow.Size = UDim2.new(1, 60, 1, 60)
Glow.ZIndex = -1
Glow.Image = "rbxassetid://5028857084"
Glow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Glow.ImageTransparency = 0.5
Glow.ScaleType = Enum.ScaleType.Slice
Glow.SliceCenter = Rect.new(24, 24, 276, 276)
Glow.Parent = Main

-- ACCENT LINE TOP
local TopAccent = Instance.new("Frame")
TopAccent.Size = UDim2.new(1, 0, 0, 2)
TopAccent.Position = UDim2.new(0, 0, 0, 0)
TopAccent.BackgroundColor3 = Theme.Accent
TopAccent.BorderSizePixel = 0
TopAccent.ZIndex = 2
TopAccent.Parent = Main
Instance.new("UICorner", TopAccent).CornerRadius = UDim.new(0, 10)

local function ApplyTheme(newTheme)
    Theme.Main = newTheme.Main
    Theme.Sidebar = newTheme.Sidebar
    Theme.Card = newTheme.Card
    Theme.Stroke = newTheme.Stroke
    Theme.Accent = newTheme.Accent
    Theme.CardHover = Color3.fromRGB(math.min(newTheme.Card.R*255 + 5, 255), math.min(newTheme.Card.G*255 + 5, 255), math.min(newTheme.Card.B*255 + 5, 255))
    Theme.StrokeActive = newTheme.Accent
    Theme.ToggleBgActive = newTheme.Accent

    local ti = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    TweenService:Create(Main, ti, {BackgroundColor3 = Theme.Main}):Play()
    TweenService:Create(MainStroke, ti, {Color = Theme.Stroke}):Play()
    TweenService:Create(TopAccent, ti, {BackgroundColor3 = Theme.Accent}):Play()
    
    for _, item in pairs(Main:GetDescendants()) do
        if item.Name == "Sidebar" or item.Name == "SidebarFix" then
            TweenService:Create(item, ti, {BackgroundColor3 = Theme.Sidebar}):Play()
        elseif item:GetAttribute("IsCard") then
            TweenService:Create(item, ti, {BackgroundColor3 = Theme.Card}):Play()
            local stroke = item:FindFirstChildOfClass("UIStroke")
            if stroke and not stroke:GetAttribute("IsActiveStroke") then
                TweenService:Create(stroke, ti, {Color = Theme.Stroke}):Play()
            end
        elseif item:GetAttribute("IsActiveStroke") then
            TweenService:Create(item, ti, {Color = Theme.StrokeActive}):Play()
        elseif item:GetAttribute("IsAccent") then
            TweenService:Create(item, ti, {BackgroundColor3 = Theme.Accent}):Play()
        end
    end
end

-- DRAG SYSTEM
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundTransparency = 1
Header.ZIndex = 5
Header.Parent = Main

local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        TweenService:Create(Main, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }):Play()
    end
end)

-- SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 190, 1, 0)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.ClipsDescendants = true
Sidebar.Parent = Main

local SidebarCorner = Instance.new("UICorner", Sidebar)
SidebarCorner.CornerRadius = UDim.new(0, 10)

local SidebarFix = Instance.new("Frame")
SidebarFix.Name = "SidebarFix"
SidebarFix.Size = UDim2.new(0, 20, 1, 0)
SidebarFix.Position = UDim2.new(1, -20, 0, 0)
SidebarFix.BackgroundColor3 = Theme.Sidebar
SidebarFix.BorderSizePixel = 0
SidebarFix.Parent = Sidebar

-- LOGO
local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, 0, 0, 30)
Logo.Position = UDim2.new(0, 0, 0, 25)
Logo.BackgroundTransparency = 1
Logo.Text = "VisualClient"
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 22
Logo.TextColor3 = Theme.Text
Logo.Parent = Sidebar

local Version = Instance.new("TextLabel")
Version.Size = UDim2.new(1, 0, 0, 15)
Version.Position = UDim2.new(0, 0, 0, 52)
Version.BackgroundTransparency = 1
Version.Text = "Premium Edition v2.0"
Version.Font = Enum.Font.GothamMedium
Version.TextSize = 11
Version.TextColor3 = Theme.SubText
Version.Parent = Sidebar

local HotkeyInfo = Instance.new("TextLabel")
HotkeyInfo.Size = UDim2.new(1, 0, 0, 20)
HotkeyInfo.Position = UDim2.new(0, 0, 1, -30)
HotkeyInfo.BackgroundTransparency = 1
HotkeyInfo.Text = "[RShift] Toggle Menu"
HotkeyInfo.Font = Enum.Font.GothamMedium
HotkeyInfo.TextSize = 11
HotkeyInfo.TextColor3 = Theme.SubText
HotkeyInfo.TextTransparency = 0.5
HotkeyInfo.Parent = Sidebar

-- TAB HOLDER
local TabHolder = Instance.new("ScrollingFrame")
TabHolder.Size = UDim2.new(1, -20, 1, -150)
TabHolder.Position = UDim2.new(0, 10, 0, 95)
TabHolder.BackgroundTransparency = 1
TabHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
TabHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabHolder.ScrollBarThickness = 0
TabHolder.Parent = Sidebar

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 8)
TabLayout.Parent = TabHolder

-- CONTENT HOLDER
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -190, 1, 0)
Content.Position = UDim2.new(0, 190, 0, 0)
Content.BackgroundTransparency = 1
Content.Parent = Main

local function CreateToggleComponent(parent, name, desc)
    local Wrapper = Instance.new("Frame")
    Wrapper.Name = "CardWrapper"
    Wrapper.BackgroundTransparency = 1
    Wrapper.Size = UDim2.new(0, 0, 0, 75)
    Wrapper.Parent = parent
    
    local Card = Instance.new("CanvasGroup")
    Card.Size = UDim2.new(1, 0, 1, 0)
    Card.BackgroundColor3 = Theme.Card
    Card.Parent = Wrapper
    Card:SetAttribute("IsCard", true)
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
    
    local CardStroke = Instance.new("UIStroke", Card)
    CardStroke.Color = Theme.Stroke
    CardStroke.Thickness = 1.2
    
    local ClickTrigger = Instance.new("TextButton")
    ClickTrigger.Size = UDim2.new(1, 0, 1, 0)
    ClickTrigger.BackgroundTransparency = 1
    ClickTrigger.Text = ""
    ClickTrigger.ZIndex = 5
    ClickTrigger.Parent = Card
    
    local Label = Instance.new("TextLabel")
    Instance.new("UIPadding", Label).PaddingLeft = UDim.new(0, 16)
    Label.Size = UDim2.new(1, -70, 0, 45)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 14
    Label.TextColor3 = Theme.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Card
    
    local SubLabel = Instance.new("TextLabel")
    Instance.new("UIPadding", SubLabel).PaddingLeft = UDim.new(0, 16)
    SubLabel.Size = UDim2.new(1, -10, 0, 25)
    SubLabel.Position = UDim2.new(0, 0, 0, 35)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text = desc or "Enable this feature"
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.TextSize = 11
    SubLabel.TextColor3 = Theme.SubText
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.TextWrapped = true
    SubLabel.Parent = Card

    local ToggleTrack = Instance.new("Frame")
    ToggleTrack.Size = UDim2.new(0, 38, 0, 20)
    ToggleTrack.Position = UDim2.new(1, -55, 0, 15)
    ToggleTrack.BackgroundColor3 = Theme.ToggleBg
    ToggleTrack.BorderSizePixel = 0
    ToggleTrack.Parent = Card
    Instance.new("UICorner", ToggleTrack).CornerRadius = UDim.new(1, 0)

    local ToggleDot = Instance.new("Frame")
    ToggleDot.Size = UDim2.new(0, 14, 0, 14)
    ToggleDot.Position = UDim2.new(0, 3, 0.5, -7)
    ToggleDot.BackgroundColor3 = Theme.ToggleDot
    ToggleDot.BorderSizePixel = 0
    ToggleDot.Parent = ToggleTrack
    Instance.new("UICorner", ToggleDot).CornerRadius = UDim.new(1, 0)

    local Enabled = false
    ClickTrigger.MouseButton1Click:Connect(function()
        Enabled = not Enabled
        local ti = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        if Enabled then
            CardStroke:SetAttribute("IsActiveStroke", true)
            ToggleTrack:SetAttribute("IsAccent", true)
            TweenService:Create(CardStroke, ti, {Color = Theme.StrokeActive}):Play()
            TweenService:Create(ToggleTrack, ti, {BackgroundColor3 = Theme.ToggleBgActive}):Play()
            TweenService:Create(ToggleDot, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -17, 0.5, -7), BackgroundColor3 = Theme.ToggleDotActive}):Play()
        else
            CardStroke:SetAttribute("IsActiveStroke", nil)
            ToggleTrack:SetAttribute("IsAccent", nil)
            TweenService:Create(CardStroke, ti, {Color = Theme.Stroke}):Play()
            TweenService:Create(ToggleTrack, ti, {BackgroundColor3 = Theme.ToggleBg}):Play()
            TweenService:Create(ToggleDot, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Theme.ToggleDot}):Play()
        end
    end)
    ClickTrigger.MouseEnter:Connect(function() TweenService:Create(Card, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.CardHover}):Play() end)
    ClickTrigger.MouseLeave:Connect(function() TweenService:Create(Card, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.Card}):Play() end)
end

local function CreateSliderComponent(parent, name, min, max, default)
    local Wrapper = Instance.new("Frame")
    Wrapper.Name = "CardWrapper"
    Wrapper.BackgroundTransparency = 1
    Wrapper.Size = UDim2.new(0, 0, 0, 75)
    Wrapper.Parent = parent
    
    local Card = Instance.new("CanvasGroup")
    Card.Size = UDim2.new(1, 0, 1, 0)
    Card.BackgroundColor3 = Theme.Card
    Card.Parent = Wrapper
    Card:SetAttribute("IsCard", true)
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
    
    local CardStroke = Instance.new("UIStroke", Card)
    CardStroke.Color = Theme.Stroke
    CardStroke.Thickness = 1.2
    
    local Label = Instance.new("TextLabel")
    Instance.new("UIPadding", Label).PaddingLeft = UDim.new(0, 16)
    Label.Size = UDim2.new(1, -60, 0, 35)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextColor3 = Theme.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Card
    
    local ValueLabel = Instance.new("TextLabel")
    Instance.new("UIPadding", ValueLabel).PaddingRight = UDim.new(0, 16)
    ValueLabel.Size = UDim2.new(0, 60, 0, 35)
    ValueLabel.Position = UDim2.new(1, -60, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 13
    ValueLabel.TextColor3 = Theme.Accent
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Card
    ValueLabel:SetAttribute("IsTextAccent", true)

    local SliderTrack = Instance.new("TextButton")
    SliderTrack.Size = UDim2.new(1, -32, 0, 4)
    SliderTrack.Position = UDim2.new(0, 16, 0, 50)
    SliderTrack.BackgroundColor3 = Theme.ToggleBg
    SliderTrack.Text = ""
    SliderTrack.AutoButtonColor = false
    SliderTrack.Parent = Card
    Instance.new("UICorner", SliderTrack).CornerRadius = UDim.new(1, 0)

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(math.clamp((default-min)/(max-min), 0, 1), 0, 1, 0)
    SliderFill.BackgroundColor3 = Theme.Accent
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderTrack
    SliderFill:SetAttribute("IsAccent", true)
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
    
    local SliderKnob = Instance.new("Frame")
    SliderKnob.Size = UDim2.new(0, 14, 0, 14)
    SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    SliderKnob.Position = UDim2.new(1, 0, 0.5, 0)
    SliderKnob.BackgroundColor3 = Color3.new(1,1,1)
    SliderKnob.Parent = SliderFill
    Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + ((max - min) * pos))
        ValueLabel.Text = tostring(val)
        TweenService:Create(SliderFill, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
    end
    
    SliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
    end)
end

local function AnimateFog(tabFrame)
    for _, wrapper in pairs(tabFrame:GetChildren()) do
        if wrapper:IsA("Frame") and wrapper.Name == "CardWrapper" then
            local card = wrapper:FindFirstChildOfClass("CanvasGroup")
            if card then
                card.GroupTransparency = 1
                card.Position = UDim2.new(0, 0, 0, 15)
                task.delay(wrapper.LayoutOrder * 0.04, function()
                    if tabFrame.Visible then
                        TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {GroupTransparency = 0, Position = UDim2.new(0, 0, 0, 0)}):Play()
                    end
                end)
            end
        end
    end
end

local function CreateTab(name, isThemeTab)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 38)
    Button.BackgroundColor3 = Theme.Card
    Button.BackgroundTransparency = 1
    Button.Text = "   " .. name
    Button.TextColor3 = Theme.SubText
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 14
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Parent = TabHolder
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 3, 0, 16)
    Indicator.Position = UDim2.new(0, 0, 0.5, -8)
    Indicator.BackgroundColor3 = Theme.Accent
    Indicator.BorderSizePixel = 0
    Indicator.BackgroundTransparency = 1
    Indicator.Parent = Button
    Indicator:SetAttribute("IsAccent", true)
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -95)
    ContentFrame.Position = UDim2.new(0, 0, 0, 95)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Visible = false
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentFrame.ScrollBarThickness = 2
    ContentFrame.ScrollBarImageColor3 = Theme.Stroke
    ContentFrame.Parent = Content
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 0, 40)
    Title.Position = UDim2.new(0, 20, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = name
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 28
    Title.TextColor3 = Theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Content
    Title.Visible = false

    local Padding = Instance.new("UIPadding", ContentFrame)
    Padding.PaddingLeft = UDim.new(0, 25)
    Padding.PaddingRight = UDim.new(0, 25)
    Padding.PaddingTop = UDim.new(0, 10)
    Padding.PaddingBottom = UDim.new(0, 25)

    local Grid = Instance.new("UIGridLayout", ContentFrame)
    Grid.CellSize = UDim2.new(0.5, -8, 0, 75)
    Grid.CellPadding = UDim2.new(0, 16, 0, 16)
    Grid.SortOrder = Enum.SortOrder.LayoutOrder

    Button.MouseButton1Click:Connect(function()
        if CurrentTab == ContentFrame then return end
        for _, v in pairs(Tabs) do
            if v.Frame.Visible then
                TweenService:Create(v.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Theme.SubText, BackgroundTransparency = 1}):Play()
                TweenService:Create(v.Indicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1, Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 0, 0.5, 0)}):Play()
                v.Frame.Visible = false
                v.Title.Visible = false
            end
        end
        CurrentTab = ContentFrame
        ContentFrame.Visible = true
        Title.Visible = true
        AnimateFog(ContentFrame)
        TweenService:Create(Button, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextColor3 = Theme.Text, BackgroundTransparency = 0.8}):Play()
        TweenService:Create(Indicator, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0, Size = UDim2.new(0, 3, 0, 16), Position = UDim2.new(0, 0, 0.5, -8)}):Play()
    end)

    table.insert(Tabs, {Button = Button, Frame = ContentFrame, Indicator = Indicator, Title = Title})
    return ContentFrame, Title
end

-- POPULATE TABS
local CombatTab = CreateTab("Combat", false)
CreateToggleComponent(CombatTab, "KillAura", "Automatically attacks entities around you based on range.")
CreateToggleComponent(CombatTab, "AutoClicker", "Simulates rapid clicking when holding mouse.")
CreateSliderComponent(CombatTab, "Aura Range", 1, 15, 10)
CreateSliderComponent(CombatTab, "Hit Chance", 1, 100, 95)

local VisualTab = CreateTab("Visual", false)
CreateToggleComponent(VisualTab, "Premium ESP", "Highlights players with rich corner boxes and health visualization.")
CreateToggleComponent(VisualTab, "TargetHUD", "Shows an advanced widget tracking your current target.")
CreateToggleComponent(VisualTab, "Watermark", "Displays the client name, fps, and ping.")
CreateSliderComponent(VisualTab, "FOV Circle", 10, 500, 100)

local MiscTab = CreateTab("Misc", false)
CreateToggleComponent(MiscTab, "Auto Sprint", "Forces your humanoid to always run.")
CreateToggleComponent(MiscTab, "No Fall", "Prevents fall damage.")

local ThemeTab = CreateTab("Themes", true)
for i, preset in ipairs(Presets) do
    local Wrapper = Instance.new("Frame")
    Wrapper.Name = "CardWrapper"
    Wrapper.BackgroundTransparency = 1
    Wrapper.LayoutOrder = i
    Wrapper.Parent = ThemeTab
    local Card = Instance.new("CanvasGroup")
    Card.Size = UDim2.new(1, 0, 1, 0)
    Card.BackgroundColor3 = Theme.Card
    Card.Parent = Wrapper
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
    local CardStroke = Instance.new("UIStroke", Card)
    CardStroke.Color = Theme.Stroke
    local Trigger = Instance.new("TextButton")
    Trigger.Size = UDim2.new(1,0,1,0)
    Trigger.BackgroundTransparency = 1
    Trigger.Text = ""
    Trigger.Parent = Card
    local Lbl = Instance.new("TextLabel")
    Lbl.Position = UDim2.new(0, 15, 0, 0)
    Lbl.Size = UDim2.new(1, -15, 1, 0)
    Lbl.Text = preset.Name
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextColor3 = Theme.Text
    Lbl.TextSize = 14
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.BackgroundTransparency = 1
    Lbl.Parent = Card
    local Prv = Instance.new("Frame")
    Prv.Size = UDim2.new(0, 16, 0, 16)
    Prv.Position = UDim2.new(1, -35, 0.5, -8)
    Prv.BackgroundColor3 = preset.Accent
    Prv.Parent = Card
    Instance.new("UICorner", Prv).CornerRadius = UDim.new(1,0)
    Trigger.MouseButton1Click:Connect(function() ApplyTheme(preset) end)
end

-- INIT FIRST TAB
Tabs[1].Frame.Visible = true
Tabs[1].Title.Visible = true
Tabs[1].Button.TextColor3 = Theme.Text
Tabs[1].Button.BackgroundTransparency = 0.8
Tabs[1].Indicator.BackgroundTransparency = 0
CurrentTab = Tabs[1].Frame

-- TOGGLE LOGIC
local Open = true
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightShift then
        Open = not Open
        if Open then
            Main.Visible = true
            -- Scale pop up animation
            Main.Size = UDim2.new(0, 750, 0, 460)
            TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 780, 0, 480)}):Play()
            if CurrentTab then AnimateFog(CurrentTab) end
        else
            TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 750, 0, 450)}):Play()
            task.delay(0.25, function() if not Open then Main.Visible = false end end)
        end
    end
end)
