local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Safe CoreGui integration
local targetGui = gethui and gethui() or CoreGui

local IS_DEV = false
local GITHUB_URL = "https://raw.githubusercontent.com/gfeee724-jpg/visual/main/VisualClient/"

local Main = {}
Main.Modules = {}

function Main:LoadModules()
    local function loadModule(name)
        if IS_DEV then
            local path = "VisualClient/Modules/" .. name .. ".lua"
            if isfile and isfile(path) then
                return loadstring(readfile(path))()
            else
                warn("Cannot find local module: " .. path)
                return {
                    Enabled = false,
                    Toggle = function(self, state) 
                        self.Enabled = state
                        print("Mock", name, state) 
                    end
                }
            end
        else
            local url = GITHUB_URL .. "Modules/" .. name .. ".lua"
            local response = game:HttpGet(url)
            return loadstring(response)()
        end
    end
    
    self.Modules.ESP = loadModule("ESP")
    self.Modules.Chams = loadModule("Chams")
    self.Modules.Watermark = loadModule("Watermark")
    self.Modules.TargetHUD = loadModule("TargetHUD")
end

function Main:Initialize()
    -- Create the Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = HttpService:GenerateGUID(false)
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = targetGui
    
    -- Window Frame
    local Window = Instance.new("Frame")
    Window.Name = "Window"
    Window.Parent = ScreenGui
    Window.AnchorPoint = Vector2.new(0.5, 0.5)
    Window.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Window.Position = UDim2.new(0.5, 0, 0.5, 0)
    Window.Size = UDim2.new(0, 450, 0, 300)
    Window.ClipsDescendants = false
    
    local WindowCorner = Instance.new("UICorner")
    WindowCorner.CornerRadius = UDim.new(0, 8)
    WindowCorner.Parent = Window
    
    local WindowStroke = Instance.new("UIStroke")
    WindowStroke.Color = Color3.fromRGB(40, 40, 40)
    WindowStroke.Parent = Window
    
    -- Titlebar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = Window
    TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BorderSizePixel = 0
    
    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 8)
    TitleBarCorner.Parent = TitleBar
    
    -- Square off bottom corners of TitleBar for a seamless look
    local TitleBarFix = Instance.new("Frame")
    TitleBarFix.Parent = TitleBar
    TitleBarFix.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TitleBarFix.BorderSizePixel = 0
    TitleBarFix.Position = UDim2.new(0, 0, 1, -8)
    TitleBarFix.Size = UDim2.new(1, 0, 0, 8)
    
    -- Accent Line under Titlebar
    local Line = Instance.new("Frame")
    Line.Parent = TitleBar
    Line.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
    Line.BorderSizePixel = 0
    Line.Position = UDim2.new(0, 0, 1, 0)
    Line.Size = UDim2.new(1, 0, 0, 2)
    
    -- Title Text
    local TitleText = Instance.new("TextLabel")
    TitleText.Parent = TitleBar
    TitleText.BackgroundTransparency = 1
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.Size = UDim2.new(1, -15, 1, 0)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.Text = "VisualClient"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextSize = 16
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Draggable Window Logic
    local dragging, dragStart, dragInput, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Scrolling Frame for features
    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Parent = Window
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.Position = UDim2.new(0, 0, 0, 42)
    ScrollingFrame.Size = UDim2.new(1, 0, 1, -42)
    ScrollingFrame.ScrollBarThickness = 2
    ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 120, 255)
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollingFrame.BorderSizePixel = 0
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = ScrollingFrame
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local UIPadding = Instance.new("UIPadding")
    UIPadding.Parent = ScrollingFrame
    UIPadding.PaddingTop = UDim.new(0, 12)
    UIPadding.PaddingLeft = UDim.new(0, 15)
    UIPadding.PaddingRight = UDim.new(0, 15)
    UIPadding.PaddingBottom = UDim.new(0, 12)
    
    -- Helper to build Toggles
    local function CreateToggle(name, defaultState, callback)
        local ToggleContainer = Instance.new("Frame")
        ToggleContainer.Name = name
        ToggleContainer.Parent = ScrollingFrame
        ToggleContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ToggleContainer.Size = UDim2.new(1, 0, 0, 48)
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = ToggleContainer
        
        local Label = Instance.new("TextLabel")
        Label.Parent = ToggleContainer
        Label.BackgroundTransparency = 1
        Label.Position = UDim2.new(0, 15, 0, 0)
        Label.Size = UDim2.new(1, -70, 1, 0)
        Label.Font = Enum.Font.GothamMedium
        Label.Text = name
        Label.TextColor3 = Color3.fromRGB(220, 220, 220)
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        local ToggleBg = Instance.new("Frame")
        ToggleBg.Parent = ToggleContainer
        ToggleBg.AnchorPoint = Vector2.new(1, 0.5)
        ToggleBg.Position = UDim2.new(1, -15, 0.5, 0)
        ToggleBg.Size = UDim2.new(0, 44, 0, 22)
        ToggleBg.BackgroundColor3 = defaultState and Color3.fromRGB(80, 120, 255) or Color3.fromRGB(50, 50, 50)
        
        local ToggleBgCorner = Instance.new("UICorner")
        ToggleBgCorner.CornerRadius = UDim.new(1, 0)
        ToggleBgCorner.Parent = ToggleBg
        
        local Indicator = Instance.new("Frame")
        Indicator.Parent = ToggleBg
        Indicator.AnchorPoint = Vector2.new(0, 0.5)
        Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Indicator.Position = defaultState and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
        Indicator.Size = UDim2.new(0, 16, 0, 16)
        
        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(1, 0)
        IndicatorCorner.Parent = Indicator
        
        local Button = Instance.new("TextButton")
        Button.Parent = ToggleContainer
        Button.BackgroundTransparency = 1
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.Text = ""
        
        local toggled = defaultState
        local tInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        Button.MouseButton1Click:Connect(function()
            toggled = not toggled
            
            TweenService:Create(Indicator, tInfo, {
                Position = toggled and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
            }):Play()
            
            TweenService:Create(ToggleBg, tInfo, {
                BackgroundColor3 = toggled and Color3.fromRGB(80, 120, 255) or Color3.fromRGB(50, 50, 50)
            }):Play()
            
            callback(toggled)
        end)
        
        -- Update CanvasSize on new item
        UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 24)
        end)
    end
    
    -- Populate GUI
    CreateToggle("Enable ESP", false, function(st) self.Modules.ESP:Toggle(st) end)
    CreateToggle("Enable Chams", false, function(st) self.Modules.Chams:Toggle(st) end)
    CreateToggle("Enable Watermark", false, function(st) self.Modules.Watermark:Toggle(st) end)
    CreateToggle("Target HUD", false, function(st) print("[VisualClient] TargetHUD:", st) end)
    
    print("[VisualClient] Main GUI Initialized")
end

Main:LoadModules()
Main:Initialize()

return Main
