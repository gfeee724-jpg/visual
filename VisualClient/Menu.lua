local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Theme = {
    Main = Color3.fromRGB(18, 18, 18),
    Sidebar = Color3.fromRGB(12, 12, 12),
    Card = Color3.fromRGB(24, 24, 24),
    CardHover = Color3.fromRGB(28, 28, 28),
    Stroke = Color3.fromRGB(40, 40, 40),
    StrokeActive = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(140, 140, 140),
    ToggleBg = Color3.fromRGB(35, 35, 35),
    ToggleBgActive = Color3.fromRGB(255, 255, 255),
    ToggleDot = Color3.fromRGB(180, 180, 180),
    ToggleDotActive = Color3.fromRGB(18, 18, 18)
}

local Presets = {
    {Name = "Midnight Default", Main = Color3.fromRGB(18, 18, 18), Sidebar = Color3.fromRGB(12, 12, 12), Card = Color3.fromRGB(24, 24, 24), Stroke = Color3.fromRGB(40, 40, 40)},
    {Name = "Obsidian Black", Main = Color3.fromRGB(10, 10, 10), Sidebar = Color3.fromRGB(6, 6, 6), Card = Color3.fromRGB(16, 16, 16), Stroke = Color3.fromRGB(30, 30, 30)},
    {Name = "Graphite Minimal", Main = Color3.fromRGB(26, 26, 28), Sidebar = Color3.fromRGB(18, 18, 20), Card = Color3.fromRGB(34, 34, 36), Stroke = Color3.fromRGB(50, 50, 55)},
    {Name = "Deep Cyber", Main = Color3.fromRGB(13, 15, 20), Sidebar = Color3.fromRGB(8, 9, 13), Card = Color3.fromRGB(20, 22, 28), Stroke = Color3.fromRGB(35, 38, 48)}
}

local Tabs = {}
local CurrentTab = nil

local Gui = Instance.new("ScreenGui")
Gui.Name = "VisualClient_Menu"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = gethui and gethui() or CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 780, 0, 460)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Theme.Main
Main.BorderSizePixel = 0
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Theme.Stroke
MainStroke.Thickness = 1

local function ApplyTheme(newMain, newSidebar, newCard, newStroke)
    Theme.Main = newMain; Theme.Sidebar = newSidebar; Theme.Card = newCard; Theme.Stroke = newStroke
    Theme.CardHover = Color3.fromRGB(math.min(newCard.R*255+5,255), math.min(newCard.G*255+5,255), math.min(newCard.B*255+5,255))
    local ti = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(Main, ti, {BackgroundColor3 = newMain}):Play()
    TweenService:Create(MainStroke, ti, {Color = newStroke}):Play()
    for _, item in pairs(Main:GetDescendants()) do
        if item.Name == "Sidebar" or item.Name == "SidebarFix" then
            TweenService:Create(item, ti, {BackgroundColor3 = newSidebar}):Play()
        elseif item:GetAttribute("IsCard") then
            TweenService:Create(item, ti, {BackgroundColor3 = newCard}):Play()
        elseif item:IsA("UIStroke") and item.Parent.Name ~= "SearchFrame" then
            TweenService:Create(item, ti, {Color = newStroke}):Play()
        end
    end
end

-- DRAG
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundTransparency = 1
Header.ZIndex = 5
Header.Parent = Main

do
    local dragging, dragStart, startPos
    local resizing, resizeStart, startSize

    local ResizeHandle = Instance.new("TextButton")
    ResizeHandle.Size = UDim2.new(0, 24, 0, 24)
    ResizeHandle.Position = UDim2.new(1, -24, 1, -24)
    ResizeHandle.BackgroundTransparency = 1
    ResizeHandle.Text = ""
    ResizeHandle.ZIndex = 10
    ResizeHandle.Parent = Main

    local ResizeIcon = Instance.new("TextLabel")
    ResizeIcon.Size = UDim2.new(0, 12, 0, 12)
    ResizeIcon.Position = UDim2.new(1, -14, 1, -14)
    ResizeIcon.BackgroundTransparency = 1
    ResizeIcon.Text = "|||"
    ResizeIcon.Font = Enum.Font.GothamBold
    ResizeIcon.TextSize = 9
    ResizeIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    ResizeIcon.TextTransparency = 0.5
    ResizeIcon.Rotation = -45
    ResizeIcon.ZIndex = 9
    ResizeIcon.Parent = ResizeHandle

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not resizing then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not dragging then
            resizing = true
            resizeStart = input.Position
            startSize = Main.Size
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then resizing = false end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging then
                local delta = input.Position - dragStart
                TweenService:Create(Main, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                }):Play()
            elseif resizing then
                local delta = input.Position - resizeStart
                TweenService:Create(Main, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, math.max(640, startSize.X.Offset + delta.X), 0, math.max(400, startSize.Y.Offset + delta.Y))
                }):Play()
            end
        end
    end)
end

-- SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 170, 1, 0)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.ClipsDescendants = true
Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local SidebarFix = Instance.new("Frame")
SidebarFix.Name = "SidebarFix"
SidebarFix.Size = UDim2.new(0, 20, 1, 0)
SidebarFix.Position = UDim2.new(1, -20, 0, 0)
SidebarFix.BackgroundColor3 = Theme.Sidebar
SidebarFix.BorderSizePixel = 0
SidebarFix.Parent = Sidebar

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0, 1, 1, 0)
Divider.Position = UDim2.new(1, 0, 0, 0)
Divider.BackgroundColor3 = Theme.Stroke
Divider.BorderSizePixel = 0
Divider.Parent = Sidebar

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, 0, 0, 30)
Logo.Position = UDim2.new(0, 0, 0, 20)
Logo.BackgroundTransparency = 1
Logo.Text = "Visual"
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 22
Logo.TextColor3 = Theme.Text
Logo.Parent = Sidebar

local Version = Instance.new("TextLabel")
Version.Size = UDim2.new(1, 0, 0, 15)
Version.Position = UDim2.new(0, 0, 0, 48)
Version.BackgroundTransparency = 1
Version.Text = "v1.4.5"
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
HotkeyInfo.TextTransparency = 0.4
HotkeyInfo.Parent = Sidebar

local TabHolder = Instance.new("ScrollingFrame")
TabHolder.Size = UDim2.new(1, -20, 1, -140)
TabHolder.Position = UDim2.new(0, 10, 0, 85)
TabHolder.BackgroundTransparency = 1
TabHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
TabHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabHolder.ScrollBarThickness = 0
TabHolder.Parent = Sidebar

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 6)
TabLayout.Parent = TabHolder

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -170, 1, 0)
Content.Position = UDim2.new(0, 170, 0, 0)
Content.BackgroundTransparency = 1
Content.Parent = Main

-- SEARCH
local SearchFrame = Instance.new("TextButton")
SearchFrame.Name = "SearchFrame"
SearchFrame.Size = UDim2.new(0, 180, 0, 35)
SearchFrame.Position = UDim2.new(1, -200, 0, 20)
SearchFrame.BackgroundColor3 = Theme.Card
SearchFrame.Text = ""
SearchFrame.AutoButtonColor = false
SearchFrame.Parent = Content
SearchFrame:SetAttribute("IsCard", true)
Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0, 6)
local SearchStroke = Instance.new("UIStroke", SearchFrame)
SearchStroke.Color = Theme.Stroke
SearchStroke.Thickness = 1.5

local ActualTextBox = Instance.new("TextBox")
ActualTextBox.Size = UDim2.new(1, -24, 1, 0)
ActualTextBox.Position = UDim2.new(0, 12, 0, 0)
ActualTextBox.BackgroundTransparency = 1
ActualTextBox.Text = ""
ActualTextBox.Font = Enum.Font.Gotham
ActualTextBox.TextSize = 13
ActualTextBox.TextColor3 = Theme.Text
ActualTextBox.TextXAlignment = Enum.TextXAlignment.Left
ActualTextBox.ClearTextOnFocus = false
ActualTextBox.Parent = SearchFrame

local PlaceholderLabel = Instance.new("TextLabel")
PlaceholderLabel.Size = UDim2.new(1, -24, 1, 0)
PlaceholderLabel.Position = UDim2.new(0, 12, 0, 0)
PlaceholderLabel.BackgroundTransparency = 1
PlaceholderLabel.Text = "Search modules..."
PlaceholderLabel.Font = Enum.Font.Gotham
PlaceholderLabel.TextSize = 13
PlaceholderLabel.TextColor3 = Theme.SubText
PlaceholderLabel.TextXAlignment = Enum.TextXAlignment.Left
PlaceholderLabel.Parent = SearchFrame

local function filterModules(searchStr)
    if not CurrentTab then return end
    local query = string.lower(searchStr)
    for _, wrapper in pairs(CurrentTab:GetChildren()) do
        if wrapper:IsA("Frame") and wrapper.Name == "CardWrapper" then
            local card = wrapper:FindFirstChildOfClass("CanvasGroup")
            if card then
                local label = card:FindFirstChildOfClass("TextLabel", true)
                if label then
                    local shouldBeVisible = (query == "") or string.find(string.lower(label.Text), query, 1, true)
                    if shouldBeVisible and not wrapper.Visible then
                        wrapper.Visible = true
                        TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
                    elseif not shouldBeVisible and wrapper.Visible then
                        TweenService:Create(card, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 1}):Play()
                        task.delay(0.2, function() if string.lower(ActualTextBox.Text) == query then wrapper.Visible = false end end)
                    end
                end
            end
        end
    end
end

ActualTextBox.Focused:Connect(function()
    TweenService:Create(PlaceholderLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
    TweenService:Create(SearchFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 230, 0, 35), Position = UDim2.new(1, -250, 0, 20)}):Play()
    TweenService:Create(SearchStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = Theme.StrokeActive}):Play()
end)
ActualTextBox.FocusLost:Connect(function()
    if ActualTextBox.Text == "" then TweenService:Create(PlaceholderLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play() end
    TweenService:Create(SearchFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 180, 0, 35), Position = UDim2.new(1, -200, 0, 20)}):Play()
    TweenService:Create(SearchStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = Theme.Stroke}):Play()
end)
SearchFrame.MouseButton1Click:Connect(function() ActualTextBox:CaptureFocus() end)
ActualTextBox:GetPropertyChangedSignal("Text"):Connect(function() filterModules(ActualTextBox.Text) end)

local function AnimateFog(tabFrame)
    local cards = {}
    for _, wrapper in pairs(tabFrame:GetChildren()) do
        if wrapper:IsA("Frame") and wrapper.Name == "CardWrapper" and wrapper.Visible then
            local card = wrapper:FindFirstChildOfClass("CanvasGroup")
            if card then
                table.insert(cards, card)
                card.GroupTransparency = 1
                card.Position = UDim2.new(0, 0, 0, 12)
            end
        end
    end
    for i, card in ipairs(cards) do
        task.delay((i - 1) * 0.025, function()
            if tabFrame.Visible and card.Parent and card.Parent.Visible then
                TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {GroupTransparency = 0, Position = UDim2.new(0, 0, 0, 0)}):Play()
            end
        end)
    end
end

local function CreateTab(name, isThemeTab)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 36)
    Button.BackgroundColor3 = Theme.Card
    Button.BackgroundTransparency = 1
    Button.Text = "  " .. name
    Button.TextColor3 = Theme.SubText
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 13
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Parent = TabHolder
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
    local BtnStroke = Instance.new("UIStroke", Button)
    BtnStroke.Color = Theme.Stroke
    BtnStroke.Transparency = 1

    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -80)
    ContentFrame.Position = UDim2.new(0, 0, 0, 80)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Visible = false
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentFrame.ScrollBarThickness = 2
    ContentFrame.ScrollBarImageColor3 = Theme.Stroke
    ContentFrame.Parent = Content
    local Padding = Instance.new("UIPadding", ContentFrame)
    Padding.PaddingLeft = UDim.new(0, 20); Padding.PaddingRight = UDim.new(0, 20)
    Padding.PaddingTop = UDim.new(0, 5); Padding.PaddingBottom = UDim.new(0, 20)
    local Grid = Instance.new("UIGridLayout", ContentFrame)
    Grid.CellSize = UDim2.new(0.5, -6, 0, 60)
    Grid.CellPadding = UDim2.new(0, 12, 0, 12)
    Grid.SortOrder = Enum.SortOrder.LayoutOrder

    if not isThemeTab then
        for i = 1, 8 do
            local Enabled = false
            local Wrapper = Instance.new("Frame")
            Wrapper.Name = "CardWrapper"; Wrapper.BackgroundTransparency = 1; Wrapper.LayoutOrder = i; Wrapper.Parent = ContentFrame
            local Card = Instance.new("CanvasGroup")
            Card.Size = UDim2.new(1, 0, 1, 0); Card.BackgroundColor3 = Theme.Card; Card.Parent = Wrapper; Card:SetAttribute("IsCard", true)
            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
            local CardStroke = Instance.new("UIStroke", Card); CardStroke.Color = Theme.Stroke; CardStroke.Thickness = 1.5
            local ClickTrigger = Instance.new("TextButton")
            ClickTrigger.Size = UDim2.new(1, 0, 1, 0); ClickTrigger.BackgroundTransparency = 1; ClickTrigger.Text = ""; ClickTrigger.ZIndex = 5; ClickTrigger.Parent = Card
            local Label = Instance.new("TextLabel")
            Instance.new("UIPadding", Label).PaddingLeft = UDim.new(0, 15)
            Label.Size = UDim2.new(1, -65, 1, 0); Label.BackgroundTransparency = 1; Label.Text = name .. " Toggle " .. i
            Label.Font = Enum.Font.GothamBold; Label.TextSize = 13; Label.TextColor3 = Theme.Text; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Card
            local ToggleTrack = Instance.new("Frame")
            ToggleTrack.Size = UDim2.new(0, 34, 0, 18); ToggleTrack.Position = UDim2.new(1, -49, 0.5, -9)
            ToggleTrack.BackgroundColor3 = Theme.ToggleBg; ToggleTrack.BorderSizePixel = 0; ToggleTrack.Parent = Card
            Instance.new("UICorner", ToggleTrack).CornerRadius = UDim.new(1, 0)
            local ToggleDot = Instance.new("Frame")
            ToggleDot.Size = UDim2.new(0, 12, 0, 12); ToggleDot.Position = UDim2.new(0, 3, 0.5, -6)
            ToggleDot.BackgroundColor3 = Theme.ToggleDot; ToggleDot.BorderSizePixel = 0; ToggleDot.Parent = ToggleTrack
            Instance.new("UICorner", ToggleDot).CornerRadius = UDim.new(1, 0)
            ClickTrigger.MouseButton1Click:Connect(function()
                Enabled = not Enabled
                if Enabled then
                    TweenService:Create(CardStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = Theme.StrokeActive}):Play()
                    TweenService:Create(ToggleTrack, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.ToggleBgActive}):Play()
                    TweenService:Create(ToggleDot, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -15, 0.5, -6), BackgroundColor3 = Theme.ToggleDotActive}):Play()
                else
                    TweenService:Create(CardStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = Theme.Stroke}):Play()
                    TweenService:Create(ToggleTrack, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.ToggleBg}):Play()
                    TweenService:Create(ToggleDot, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 3, 0.5, -6), BackgroundColor3 = Theme.ToggleDot}):Play()
                end
            end)
            ClickTrigger.MouseEnter:Connect(function() TweenService:Create(Card, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.CardHover}):Play() end)
            ClickTrigger.MouseLeave:Connect(function() TweenService:Create(Card, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.Card}):Play() end)
        end
    else
        for i, preset in ipairs(Presets) do
            local Wrapper = Instance.new("Frame")
            Wrapper.Name = "CardWrapper"; Wrapper.BackgroundTransparency = 1; Wrapper.LayoutOrder = i; Wrapper.Parent = ContentFrame
            local Card = Instance.new("CanvasGroup")
            Card.Size = UDim2.new(1, 0, 1, 0); Card.BackgroundColor3 = Theme.Card; Card.Parent = Wrapper; Card:SetAttribute("IsCard", true)
            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
            local CardStroke = Instance.new("UIStroke", Card); CardStroke.Color = Theme.Stroke; CardStroke.Thickness = 1.5
            local ClickTrigger = Instance.new("TextButton")
            ClickTrigger.Size = UDim2.new(1, 0, 1, 0); ClickTrigger.BackgroundTransparency = 1; ClickTrigger.Text = ""; ClickTrigger.ZIndex = 5; ClickTrigger.Parent = Card
            local Label = Instance.new("TextLabel")
            Instance.new("UIPadding", Label).PaddingLeft = UDim.new(0, 15)
            Label.Size = UDim2.new(1, -65, 1, 0); Label.BackgroundTransparency = 1; Label.Text = preset.Name
            Label.Font = Enum.Font.GothamBold; Label.TextSize = 13; Label.TextColor3 = Theme.Text; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Card
            local PreviewDot = Instance.new("Frame")
            PreviewDot.Size = UDim2.new(0, 16, 0, 16); PreviewDot.Position = UDim2.new(1, -35, 0.5, -8)
            PreviewDot.BackgroundColor3 = preset.Main; PreviewDot.Parent = Card
            Instance.new("UICorner", PreviewDot).CornerRadius = UDim.new(1, 0)
            local PreviewStroke = Instance.new("UIStroke", PreviewDot); PreviewStroke.Color = Theme.Text; PreviewStroke.Thickness = 1
            ClickTrigger.MouseButton1Click:Connect(function()
                ApplyTheme(preset.Main, preset.Sidebar, preset.Card, preset.Stroke)
                CardStroke.Color = Theme.StrokeActive
                TweenService:Create(CardStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = Theme.Stroke}):Play()
            end)
            ClickTrigger.MouseEnter:Connect(function() TweenService:Create(Card, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.CardHover}):Play() end)
            ClickTrigger.MouseLeave:Connect(function() TweenService:Create(Card, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.Card}):Play() end)
        end
    end

    Button.MouseEnter:Connect(function() if CurrentTab ~= ContentFrame then TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Theme.Text, BackgroundTransparency = 0.9}):Play() end end)
    Button.MouseLeave:Connect(function() if CurrentTab ~= ContentFrame then TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Theme.SubText, BackgroundTransparency = 1}):Play() end end)
    Button.MouseButton1Click:Connect(function()
        if CurrentTab == ContentFrame then return end
        for _, v in pairs(Tabs) do
            if v.Frame.Visible then
                TweenService:Create(v.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Theme.SubText, BackgroundTransparency = 1}):Play()
                local s = v.Button:FindFirstChildOfClass("UIStroke"); if s then s.Transparency = 1 end
                v.Frame.Visible = false
            end
        end
        CurrentTab = ContentFrame
        ContentFrame.Visible = true
        AnimateFog(ContentFrame)
        TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Theme.Text, BackgroundTransparency = 0}):Play()
        local s = Button:FindFirstChildOfClass("UIStroke"); if s then s.Transparency = 0 end
        ActualTextBox.Text = ""
        filterModules("")
    end)
    table.insert(Tabs, {Button = Button, Frame = ContentFrame})
end

CreateTab("Combat", false)
CreateTab("Movement", false)
CreateTab("Player", false)
CreateTab("Misc", false)

-- VISUAL TAB (fully fixed)
do
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 36)
    Button.BackgroundColor3 = Theme.Card
    Button.BackgroundTransparency = 1
    Button.Text = "  Visual"
    Button.TextColor3 = Theme.SubText
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 13
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Parent = TabHolder
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
    local BtnStroke = Instance.new("UIStroke", Button)
    BtnStroke.Color = Theme.Stroke
    BtnStroke.Transparency = 1

    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -80)
    ContentFrame.Position = UDim2.new(0, 0, 0, 80)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Visible = false
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentFrame.ScrollBarThickness = 2
    ContentFrame.ScrollBarImageColor3 = Theme.Stroke
    ContentFrame.Parent = Content
    local Padding = Instance.new("UIPadding", ContentFrame)
    Padding.PaddingLeft = UDim.new(0, 20); Padding.PaddingRight = UDim.new(0, 20)
    Padding.PaddingTop = UDim.new(0, 5); Padding.PaddingBottom = UDim.new(0, 20)
    local Grid = Instance.new("UIGridLayout", ContentFrame)
    Grid.CellSize = UDim2.new(0.5, -6, 0, 60)
    Grid.CellPadding = UDim2.new(0, 12, 0, 12)
    Grid.SortOrder = Enum.SortOrder.LayoutOrder

    local VisualSettings = {
        ChamsEnabled = false, 
        ChamsMode = "Highlight",
        TargetHudEnabled = false
    }
    local modes = {"Highlight", "PartChams", "Shaders", "Outline", "Box"}
    local currentModeIdx = 1
    local modeLabel = nil -- will be set below

    local function CreateToggleCard(name, order, callback)
        local Wrapper = Instance.new("Frame")
        Wrapper.Name = "CardWrapper"; Wrapper.BackgroundTransparency = 1; Wrapper.LayoutOrder = order; Wrapper.Parent = ContentFrame
        local Card = Instance.new("CanvasGroup")
        Card.Size = UDim2.new(1, 0, 1, 0); Card.BackgroundColor3 = Theme.Card; Card.Parent = Wrapper; Card:SetAttribute("IsCard", true)
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
        local CardStroke = Instance.new("UIStroke", Card); CardStroke.Color = Theme.Stroke; CardStroke.Thickness = 1.5
        local ClickTrigger = Instance.new("TextButton")
        ClickTrigger.Size = UDim2.new(1, 0, 1, 0); ClickTrigger.BackgroundTransparency = 1; ClickTrigger.Text = ""; ClickTrigger.ZIndex = 5; ClickTrigger.Parent = Card
        local Label = Instance.new("TextLabel")
        Instance.new("UIPadding", Label).PaddingLeft = UDim.new(0, 15)
        Label.Size = UDim2.new(1, -65, 1, 0); Label.BackgroundTransparency = 1; Label.Text = name
        Label.Font = Enum.Font.GothamBold; Label.TextSize = 13; Label.TextColor3 = Theme.Text; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Card
        local ToggleTrack = Instance.new("Frame")
        ToggleTrack.Size = UDim2.new(0, 34, 0, 18); ToggleTrack.Position = UDim2.new(1, -49, 0.5, -9)
        ToggleTrack.BackgroundColor3 = Theme.ToggleBg; ToggleTrack.BorderSizePixel = 0; ToggleTrack.Parent = Card
        Instance.new("UICorner", ToggleTrack).CornerRadius = UDim.new(1, 0)
        local ToggleDot = Instance.new("Frame")
        ToggleDot.Size = UDim2.new(0, 12, 0, 12); ToggleDot.Position = UDim2.new(0, 3, 0.5, -6)
        ToggleDot.BackgroundColor3 = Theme.ToggleDot; ToggleDot.BorderSizePixel = 0; ToggleDot.Parent = ToggleTrack
        Instance.new("UICorner", ToggleDot).CornerRadius = UDim.new(1, 0)
        local Enabled = false
        ClickTrigger.MouseButton1Click:Connect(function()
            Enabled = not Enabled
            if Enabled then
                TweenService:Create(CardStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = Theme.StrokeActive}):Play()
                TweenService:Create(ToggleTrack, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.ToggleBgActive}):Play()
                TweenService:Create(ToggleDot, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -15, 0.5, -6), BackgroundColor3 = Theme.ToggleDotActive}):Play()
            else
                TweenService:Create(CardStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = Theme.Stroke}):Play()
                TweenService:Create(ToggleTrack, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.ToggleBg}):Play()
                TweenService:Create(ToggleDot, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 3, 0.5, -6), BackgroundColor3 = Theme.ToggleDot}):Play()
            end
            callback(Enabled)
        end)
        ClickTrigger.MouseEnter:Connect(function() TweenService:Create(Card, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.CardHover}):Play() end)
        ClickTrigger.MouseLeave:Connect(function() TweenService:Create(Card, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.Card}):Play() end)
    end

    local function CreateButtonCard(name, order, callback)
        local Wrapper = Instance.new("Frame")
        Wrapper.Name = "CardWrapper"; Wrapper.BackgroundTransparency = 1; Wrapper.LayoutOrder = order; Wrapper.Parent = ContentFrame
        local Card = Instance.new("CanvasGroup")
        Card.Size = UDim2.new(1, 0, 1, 0); Card.BackgroundColor3 = Theme.Card; Card.Parent = Wrapper; Card:SetAttribute("IsCard", true)
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
        local CardStroke = Instance.new("UIStroke", Card); CardStroke.Color = Theme.Stroke; CardStroke.Thickness = 1.5
        local ClickTrigger = Instance.new("TextButton")
        ClickTrigger.Size = UDim2.new(1, 0, 1, 0); ClickTrigger.BackgroundTransparency = 1; ClickTrigger.Text = ""; ClickTrigger.ZIndex = 5; ClickTrigger.Parent = Card
        local Label = Instance.new("TextLabel")
        Instance.new("UIPadding", Label).PaddingLeft = UDim.new(0, 15)
        Label.Size = UDim2.new(1, -15, 1, 0); Label.BackgroundTransparency = 1; Label.Text = name
        Label.Font = Enum.Font.GothamBold; Label.TextSize = 13; Label.TextColor3 = Theme.Text; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Card
        ClickTrigger.MouseButton1Click:Connect(function()
            CardStroke.Color = Theme.StrokeActive
            TweenService:Create(CardStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = Theme.Stroke}):Play()
            callback(Label)
        end)
        ClickTrigger.MouseEnter:Connect(function() TweenService:Create(Card, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.CardHover}):Play() end)
        ClickTrigger.MouseLeave:Connect(function() TweenService:Create(Card, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.Card}):Play() end)
        return Label
    end

    -- GLOBAL COLOR PICKER MODAL
    local ColorModal = Instance.new("Frame")
    ColorModal.Size = UDim2.new(0, 210, 0, 150)
    ColorModal.Position = UDim2.new(0.5, -105, 0.5, -75)
    ColorModal.BackgroundColor3 = Theme.Card
    ColorModal.Visible = false
    ColorModal.ZIndex = 50
    ColorModal.Parent = Main
    Instance.new("UICorner", ColorModal).CornerRadius = UDim.new(0, 8)
    local ModalStroke = Instance.new("UIStroke", ColorModal)
    ModalStroke.Color = Theme.StrokeActive
    ModalStroke.Thickness = 1.5

    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(1, 0, 1, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = ""
    CloseBtn.ZIndex = 49
    CloseBtn.Parent = Gui
    CloseBtn.Visible = false
    CloseBtn.MouseButton1Click:Connect(function()
        ColorModal.Visible = false
        CloseBtn.Visible = false
    end)

    local activeColorCallback = nil
    local activeColorBox = nil
    local r, g, b = 255, 255, 255

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = "Color Picker"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 13
    Title.TextColor3 = Theme.Text
    Title.ZIndex = 51
    Title.Parent = ColorModal

    local function createSlider(name, yPos)
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0, 20, 0, 20)
        Label.Position = UDim2.new(0, 10, 0, yPos)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 12
        Label.TextColor3 = Theme.Text
        Label.ZIndex = 51
        Label.Parent = ColorModal

        local BG = Instance.new("TextButton")
        BG.Size = UDim2.new(0, 150, 0, 10)
        BG.Position = UDim2.new(0, 35, 0, yPos + 5)
        BG.BackgroundColor3 = Theme.ToggleBg
        BG.Text = ""
        BG.AutoButtonColor = false
        BG.ZIndex = 51
        Instance.new("UICorner", BG).CornerRadius = UDim.new(1, 0)
        BG.Parent = ColorModal

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new(1, 0, 1, 0)
        Fill.BackgroundColor3 = Theme.StrokeActive
        Fill.ZIndex = 52
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
        Fill.Parent = BG

        local isDragging = false
        BG.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = true
                local function update()
                    local pct = math.clamp((UserInputService:GetMouseLocation().X - BG.AbsolutePosition.X) / BG.AbsoluteSize.X, 0, 1)
                    Fill.Size = UDim2.new(pct, 0, 1, 0)
                    if name == "R" then r = pct * 255
                    elseif name == "G" then g = pct * 255
                    elseif name == "B" then b = pct * 255 end
                    
                    local newColor = Color3.fromRGB(r, g, b)
                    Title.TextColor3 = newColor
                    if activeColorBox then activeColorBox.BackgroundColor3 = newColor end
                    if activeColorCallback then activeColorCallback(newColor) end
                end
                update()
                local conn
                conn = UserInputService.InputChanged:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseMovement then update() end
                end)
                local connEnd
                connEnd = UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = false
                        conn:Disconnect()
                        connEnd:Disconnect()
                    end
                end)
            end
        end)
        return Fill
    end

    local fillR = createSlider("R", 40)
    local fillG = createSlider("G", 70)
    local fillB = createSlider("B", 100)

    local function OpenColorPicker(defaultColor, box, callback)
        r, g, b = defaultColor.R * 255, defaultColor.G * 255, defaultColor.B * 255
        fillR.Size = UDim2.new(defaultColor.R, 0, 1, 0)
        fillG.Size = UDim2.new(defaultColor.G, 0, 1, 0)
        fillB.Size = UDim2.new(defaultColor.B, 0, 1, 0)
        Title.TextColor3 = defaultColor
        activeColorCallback = callback
        activeColorBox = box
        ColorModal.Visible = true
        CloseBtn.Visible = true
    end

    local function CreateColorPickerCard(name, order, defaultColor, callback)
        local Wrapper = Instance.new("Frame")
        Wrapper.Name = "CardWrapper"; Wrapper.BackgroundTransparency = 1; Wrapper.LayoutOrder = order; Wrapper.Parent = ContentFrame
        local Card = Instance.new("CanvasGroup")
        Card.Size = UDim2.new(1, 0, 1, 0); Card.BackgroundColor3 = Theme.Card; Card.Parent = Wrapper; Card:SetAttribute("IsCard", true)
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
        local CardStroke = Instance.new("UIStroke", Card); CardStroke.Color = Theme.Stroke; CardStroke.Thickness = 1.5
        local ClickTrigger = Instance.new("TextButton")
        ClickTrigger.Size = UDim2.new(1, 0, 1, 0); ClickTrigger.BackgroundTransparency = 1; ClickTrigger.Text = ""; ClickTrigger.ZIndex = 5; ClickTrigger.Parent = Card
        local Label = Instance.new("TextLabel")
        Instance.new("UIPadding", Label).PaddingLeft = UDim.new(0, 15)
        Label.Size = UDim2.new(1, -65, 1, 0); Label.BackgroundTransparency = 1; Label.Text = name
        Label.Font = Enum.Font.GothamBold; Label.TextSize = 13; Label.TextColor3 = Theme.Text; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Card
        
        local ColorBox = Instance.new("Frame")
        ColorBox.Size = UDim2.new(0, 24, 0, 18); ColorBox.Position = UDim2.new(1, -39, 0.5, -9)
        ColorBox.BackgroundColor3 = defaultColor; ColorBox.Parent = Card
        Instance.new("UICorner", ColorBox).CornerRadius = UDim.new(0, 4)
        local CStroke = Instance.new("UIStroke", ColorBox); CStroke.Color = Color3.fromRGB(0,0,0); CStroke.Thickness = 1
        
        ClickTrigger.MouseButton1Click:Connect(function()
            CardStroke.Color = Theme.StrokeActive
            TweenService:Create(CardStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = Theme.Stroke}):Play()
            OpenColorPicker(ColorBox.BackgroundColor3, ColorBox, callback)
        end)
        ClickTrigger.MouseEnter:Connect(function() TweenService:Create(Card, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.CardHover}):Play() end)
        ClickTrigger.MouseLeave:Connect(function() TweenService:Create(Card, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.Card}):Play() end)
    end

    -- ESP Toggle
    CreateToggleCard("Enable ESP", 1, function(val)
        VisualSettings.EspEnabled = val
        local espUrl = "https://raw.githubusercontent.com/gfeee724-jpg/visual/main/VisualClient/Modules/ESP.lua"
        if val then
            if getgenv().VisualESP then
                getgenv().VisualESP:Toggle(true)
            else
                local ok, err = pcall(function()
                    getgenv().VisualESP = loadstring(game:HttpGet(espUrl))()
                    getgenv().VisualESP:Toggle(true)
                end)
                if not ok then warn("ESP load error: " .. tostring(err)) end
            end
        else
            if getgenv().VisualESP then
                getgenv().VisualESP:Toggle(false)
            end
        end
    end)

    -- Chams Toggle
    CreateToggleCard("Enable Chams", 2, function(val)
        VisualSettings.ChamsEnabled = val
        local chamsUrl = "https://raw.githubusercontent.com/gfeee724-jpg/visual/main/VisualClient/Modules/Chams.lua"
        if val then
            if getgenv().VisualChams then
                getgenv().VisualChams:Toggle(true)
            else
                local ok, err = pcall(function()
                    getgenv().VisualChams = loadstring(game:HttpGet(chamsUrl))()
                    getgenv().VisualChams:Toggle(true)
                end)
                if not ok then warn("Chams load error: " .. tostring(err)) end
            end
        else
            if getgenv().VisualChams then
                getgenv().VisualChams:Toggle(false)
            end
        end
    end)

    -- Chams Mode Button — callback now receives the label directly
    modeLabel = CreateButtonCard("Chams Mode: Highlight", 3, function(lbl)
        currentModeIdx = currentModeIdx % #modes + 1
        VisualSettings.ChamsMode = modes[currentModeIdx]
        lbl.Text = "Chams Mode: " .. VisualSettings.ChamsMode
        if getgenv().VisualChams then
            getgenv().VisualChams:SetMode(VisualSettings.ChamsMode)
        end
    end)

    -- Target HUD Toggle
    CreateToggleCard("Enable Target HUD", 4, function(val)
        VisualSettings.TargetHudEnabled = val
        local hudUrl = "https://raw.githubusercontent.com/gfeee724-jpg/visual/main/VisualClient/Modules/TargetHUD.lua"
        if val then
            if getgenv().VisualTargetHUD then
                getgenv().VisualTargetHUD:Toggle(true)
            else
                local ok, err = pcall(function()
                    getgenv().VisualTargetHUD = loadstring(game:HttpGet(hudUrl))()
                    getgenv().VisualTargetHUD:Toggle(true)
                end)
                if not ok then warn("TargetHUD load error: " .. tostring(err)) end
            end
        else
            if getgenv().VisualTargetHUD then
                getgenv().VisualTargetHUD:Toggle(false)
            end
        end
    end)

    CreateColorPickerCard("ESP Box Color", 5, Color3.fromRGB(255, 255, 255), function(c)
        if getgenv().VisualESP then getgenv().VisualESP:SetColor(c) end
    end)
    CreateColorPickerCard("Chams Fill Color", 6, Color3.fromRGB(170, 0, 255), function(c)
        if getgenv().VisualChams then getgenv().VisualChams:SetColor(c) end
    end)

    Button.MouseEnter:Connect(function() if CurrentTab ~= ContentFrame then TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Theme.Text, BackgroundTransparency = 0.9}):Play() end end)

    Button.MouseLeave:Connect(function() if CurrentTab ~= ContentFrame then TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Theme.SubText, BackgroundTransparency = 1}):Play() end end)
    Button.MouseButton1Click:Connect(function()
        if CurrentTab == ContentFrame then return end
        for _, v in pairs(Tabs) do
            if v.Frame.Visible then
                TweenService:Create(v.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Theme.SubText, BackgroundTransparency = 1}):Play()
                local s = v.Button:FindFirstChildOfClass("UIStroke"); if s then s.Transparency = 1 end
                v.Frame.Visible = false
            end
        end
        CurrentTab = ContentFrame
        ContentFrame.Visible = true
        AnimateFog(ContentFrame)
        TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Theme.Text, BackgroundTransparency = 0}):Play()
        local s = Button:FindFirstChildOfClass("UIStroke"); if s then s.Transparency = 0 end
        ActualTextBox.Text = ""
        filterModules("")
    end)
    table.insert(Tabs, {Button = Button, Frame = ContentFrame})
end

CreateTab("Themes", true)

if #Tabs > 0 then
    Tabs[1].Frame.Visible = true
    Tabs[1].Button.TextColor3 = Theme.Text
    Tabs[1].Button.BackgroundTransparency = 0
    local s = Tabs[1].Button:FindFirstChildOfClass("UIStroke"); if s then s.Transparency = 0 end
    CurrentTab = Tabs[1].Frame
    AnimateFog(Tabs[1].Frame)
end

-- RIGHT SHIFT TOGGLE
local Open = true
Main.ClipsDescendants = true

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Open = not Open
        if Open then
            Main.Visible = true
            TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 780, 0, 460)}):Play()
            if CurrentTab then AnimateFog(CurrentTab) end
        else
            TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 780, 0, 0)}):Play()
            task.delay(0.25, function() if not Open then Main.Visible = false end end)
        end
    end
end)
