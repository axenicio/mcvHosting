
    --#region Setup
    --#endregion

    --#region Settings 
    local ENABLE_PLAYER_DATA = true

    local Players = game:GetService("Players")
    local Teams = game:GetService("Teams")
    local CoreGui = game:GetService("CoreGui")
    local Lighting = game:GetService("Lighting")

    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local HttpService = game:GetService("HttpService")

    local ReplicatedFirst = game:GetService("ReplicatedFirst")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local Marketplace = game:GetService('MarketplaceService')
    --#endregion

    --#region Instances
    local LocalPlayer = Players.LocalPlayer
    local Mouse = LocalPlayer:GetMouse()
    local CurrentCamera = workspace.CurrentCamera
    --#endregion

    --#region Tables
    local ListOfConnections = {}
    local PlayerData = {}
    local Connection = {}
    local Library = {}
    --#endregion


    --#region Meta tables 
    local PlayerMeta = {}
    PlayerMeta.__index = PlayerMeta
    --#endregion


    --#region Values
    local LocalName = LocalPlayer.Name
    local LocalId = LocalPlayer.UserId

    local IsTyping = false

    local PlaceId = game.PlaceId
    local GameId = game.GameId
    local JobId = game.JobId
    --#endregion

    
    --#region Connection functions
    function Connection:Disconnect(Name : string)
        if not ListOfConnections[Name] then
            return
        end

        ListOfConnections[Name]:Disconnect()
        ListOfConnections[Name] = nil
    end
    function Connection:Create(Name : string, Event : event, Callback)
        Connection:Disconnect(Name)

        ListOfConnections[Name] = Event:Connect(Callback)

        return ListOfConnections[Name]
    end
    function Connection:Disable()
        for Name, _ in pairs(ListOfConnections) do
            Connection:Disconnect(Name)
        end
    end
    local function OnInputEnded(Input, Typing)
        IsTyping = Typing
    end
    local function instance(className,properties,children,funcs)
        local object = Instance.new(className)
        
        for i,v in pairs(properties or {}) do
            object[i] = v
        end
        for i, self in pairs(children or {}) do
            self.Parent = object
        end
        for i,func in pairs(funcs or {}) do
            func(object)
        end
        return object
    end
    local function udim2(x1,x2,y1,y2)
        local t = tonumber
        return UDim2.new(t(x1), t(x2), t(y1), t(y2))
    end
    local function rgb(r,g,b) 
        return Color3.fromRGB(r,g,b)
    end
    local function fixInt(int) 
        return tonumber(string.format('%.02f', int)) 
    end
    local function round(exact, quantum)
        local quant, frac = math.modf(exact/quantum)
        return FixInt(quantum * (quant + (frac > 0.5 and 1 or 0)))
    end
    local function ts(object,tweenInfo,properties)
        if tweenInfo[2] and typeof(tweenInfo[2]) == 'string' then
            tweenInfo[2] = Enum.EasingStyle[ tweenInfo[2] ]
        end
        game:service('TweenService'):create(object, TweenInfo.new(unpack(tweenInfo)), properties):Play()
    end
    local function scale(unscaled, minAllowed, maxAllowed, min, max)
        return (maxAllowed - minAllowed) * (unscaled - min) / (max - min) + minAllowed
    end
    --#endregion


    -- --#region PlayerMeta functions
    function PlayerMeta.OnPlayerAdded(Player : Instance)
        local self = setmetatable({}, PlayerMeta)
        local PlayerName = Player.Name

        --#region Self assign 
        self.Player = Player
        self.Character = self.Player.Character or nil

        self.Humanoid = self.Character and self.Character:FindFirstChild("Humanoid") or nil
        self.HumanoidRootPart = self.Character and self.Character:FindFirstChild("HumanoidRootPart") or nil
        --#endregion

        --#region Functions 
        local function OnChildAdded(Child : Instance)
            local ChildName = Child.Name
            if ChildName == "HumanoidRootPart" then
                self.HumanoidRootPart = Child
            elseif ChildName == "Humanoid" then
                self.Humanoid = Child
            end
        end
        local function OnChildRemoved(Child : Instance)
            local ChildName = Child.Name
            if ChildName == "HumanoidRootPart" then
                self.HumanoidRootPart = nil
            elseif ChildName == "Humanoid" then
                self.Humanoid = nil
            end
        end
        local function OnCharacterAdded(Character : Model)
            self.Character = Character

            Connection:Create(PlayerName .. "-ChilAdded", Character.ChildAdded, OnChildAdded)
            Connection:Create(PlayerName .. "-ChildRemoved", Character.ChildRemoved, OnChildRemoved)
        end
        local function OnCharacterRemoving(Character : Model)
            self.Character = nil
            self.Humanoid = nil
            self.HumanoidRootPart = nil
        end
        --#endregion

        --#region Connections 
        Connection:Create(PlayerName .. "-CharacterAdded", Player.CharacterAdded, OnCharacterAdded)
        Connection:Create(PlayerName .. "-CharacterRemoving", Player.CharacterRemoving, OnCharacterRemoving)
        --#endregion

        --#region Setup 
        if self.Character then
            OnCharacterAdded(self.Character)
        end

        PlayerData[PlayerName] = self
        --#endregion
        
        return self
    end
    function PlayerMeta.OnPlayerRemoving(Player : Instance)
        local PlayerName = Player.Name
        if not PlayerData[PlayerName] then return end

        PlayerData[PlayerName] = nil
    end
    function PlayerMeta:GetCFrame()
        local HumanoidRootPart = self.HumanoidRootPart
        if not HumanoidRootPart then return end
        return HumanoidRootPart.CFrame
    end
    function PlayerMeta:GetEquiptTool()
        local Character = self.Character
        if not Character then return end
        return Character:FindFirstChildWhichIsA("Tool")
    end
    function PlayerMeta:GetTracks()
        local Humanoid = self.Humanoid
        if not Humanoid then return end
        return Humanoid:GetPlayingAnimationTracks()
    end
    function PlayerMeta:GetMagnitude(Position : Vector3)
        local HumanoidRootPart = self.HumanoidRootPart
        if not HumanoidRootPart then return end
        return (HumanoidRootPart.Position - Position).Magnitude
    end
    --#endregion


    --#region Lib setup 
    if not blurModule then
        if game.PlaceId ~= 6678877691 then
            getgenv().blurModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/axenicio/mcvHosting/main/assets/blurmodule.lua"))()
        else
            local blurModule = {}
            function blurModule:BindFrame()

            end
            getgenv().blurModule = blurModule
        end
    end

    if game.PlaceId ~= 6678877691 then
        print('adding blur')
        if not game:service('Lighting'):FindFirstChild('mcv_blur') then
            instance('DepthOfFieldEffect', {
                Parent = game:service('Lighting'),
                FarIntensity = 0,
                Name = 'mcv_blur',
                FocusDistance = 51.5,
                InFocusRadius = 50,
                NearIntensity = 1,
                Enabled = true
            })
        end
    end
    local UiConfig = {
        CloseNotification = true,
        ClassicClose = true,
        ShowUiBind = 'LeftControl',
        ShowMouseCursor = false,
        TotalExecutions = 0
    }

    --#region Luraph functions
    if not LPH_OBFUSCATED then
        LPH_JIT_MAX = function(...) return (...) end
        LPH_NO_VIRTUALIZE = function(...) return (...) end
    end
    --#endregion


    --#region Notifications
    local function instance(className,properties,children,funcs)
        local object = Instance.new(className)
        
        for i,v in pairs(properties or {}) do
            object[i] = v
        end
        for i, self in pairs(children or {}) do
            self.Parent = object
        end
        for i,func in pairs(funcs or {}) do
            func(object)
        end
        return object
    end
    
    local function ts(object,tweenInfo,properties)
        if tweenInfo[2] and typeof(tweenInfo[2]) == 'string' then
            tweenInfo[2] = Enum.EasingStyle[ tweenInfo[2] ]
        end
        game:service('TweenService'):create(object, TweenInfo.new(unpack(tweenInfo)), properties):Play()
    end
    
    local function udim2(x1,x2,y1,y2)
        local t = tonumber
        return UDim2.new(t(x1), t(x2), t(y1), t(y2))
    end
    
    local function rgb(r,g,b) 
        return Color3.fromRGB(r,g,b)
    end
    
    local function fixInt(int) 
        return tonumber(string.format('%.02f', int)) 
    end
    
    local function round(exact, quantum)
        local quant, frac = math.modf(exact/quantum)
        return fixInt(quantum * (quant + (frac > 0.5 and 1 or 0)))
    end
    
    local function scale(unscaled, minAllowed, maxAllowed, min, max)
        return (maxAllowed - minAllowed) * (unscaled - min) / (max - min) + minAllowed
    end
    
    local function glow(frame, radius, step, color)
        local instances = {}
    
        local folder = instance('Folder', {
            Parent = frame,
            Name = 'glow'
        })
        
        local function newInstance(thick)
            local new = instance('Frame', {
                Parent = folder,
                BackgroundTransparency = 1,
                Size = udim2(1, 0, 1, 0)
            }, {
                (function()
                    local d, c = nil, frame:FindFirstChildWhichIsA('UICorner')
                    if c then
                        d = instance('UICorner', {
                            CornerRadius = c.CornerRadius
                        })
    
                        c:GetPropertyChangedSignal('CornerRadius'):Connect(function()
                            d.CornerRadius = c.CornerRadius
                        end)
                    end
                    return d
                end)(),
                instance('UIStroke', {
                    Transparency = 0.95,
                    Thickness = thick,
                    Color = typeof(color) == 'Color3' and color or Color3.new(0, 0, 0)
                })
            })
            
            table.insert(instances, new.UIStroke)
        end
    
        for a=1,radius,step do
            newInstance(a)
        end
    
        local function change(func)
            for a,v in next, instances do
                func(v)
            end
        end
    
        return {
            setColor = function(c)
                change(function(v)
                    ts(v, {0.3, 'Exponential'}, {
                        Color = c
                    })
                end)
            end,
            hide = function()
                change(function(v)
                    ts(v, {0.2, 'Exponential'}, {
                        Transparency = 1
                    })
                end)
            end,
            show = function()
                change(function(v)
                    ts(v, {0.2, 'Exponential'}, {
                        Transparency = 0.95
                    })
                end)
            end
        }
    end
    
    local function corner(a, b)
        return instance('UICorner', {
            CornerRadius = UDim.new(a, b)
        })
    end
    
    
    local core = game:service('CoreGui')
    local tservice = game:service('TextService')
    
    
    pcall(function()
        core['mcv_notif']:Destroy()
    end)
    
    local sgui = instance('ScreenGui', {
        Name = 'mcv_notif',
        Parent = core,
    }, {
        instance('Frame', {
            Name = 'main',
            Position = udim2(0, 40, 0, 0),
            Size = udim2(0, 0, 1, -40),
            BackgroundTransparency = 1
        }, {
            instance('UIListLayout', {
                Padding = UDim.new(0, 10),
                HorizontalAlignment = 'Left',
                VerticalAlignment = 'Bottom',
            })
        })
    })
    
    local function notify(data)
        data.Title = typeof(data.Title) == 'string' and data.Title or '[empty]'
        data.Text = typeof(data.Text) == 'string' and data.Text or nil
        data.Options = typeof(data.Options) == 'table' and data.Options or nil
        data.Callback = typeof(data.Callback) == 'function' and data.Callback or function() end
        data.Duration = typeof(data.Duration) == 'number' and data.Duration or nil
        data.Image = typeof(data.Image) == 'string' and data.Image or nil
    
        if data.CloseOnCallback ~= false then
            data.CloseOnCallback = true
        end
    
        local finalX = tservice:GetTextSize((data.Text and #data.Title > #data.Text and data.Title or data.Text) or data.Title, (data.Text and #data.Title > #data.Text and 14 or 13), 'Ubuntu', Vector2.new(math.huge, math.huge)).X + (data.Image and 80 or 40)
        local finalY = data.Text and 60 or (data.Image and 60 or 30)
        local mainGlow
        local notifFrame
        local close
    
        if data.Duration then
            finalX = finalX + 12
        end
    
        if data.Options then
            finalX = finalX + 24
        end
    
        local function extend()
            local line = instance('Frame', {
                Parent = notifFrame,
                Size = udim2(0, 1, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = rgb(255, 255, 255),
                BackgroundTransparency = 1,
                Position = udim2(0, notifFrame.AbsoluteSize.X, 0, 0),
            })
    
            local optionFrame = instance('Frame', {
                Parent = notifFrame,
                BackgroundTransparency = 1,
                Position = udim2(0, notifFrame.AbsoluteSize.X + 15, 0, 0),
                Size = udim2(1, -(notifFrame.AbsoluteSize.X + 15), 1, 0)
            }, {
                instance('UIListLayout', {
                    Padding = UDim.new(0, 8),
                    FillDirection = 'Horizontal',
                    HorizontalAlignment = 'Left',
                    VerticalAlignment = 'Center'
                })
            })
    
            local fX = (data.Duration and 30 or 22)
            local c = 0
    
            for a,v in next, data.Options do
                local nX = tservice:GetTextSize(v, 14, 'Ubuntu', Vector2.new(math.huge, math.huge)).X + 10
                fX = fX + nX + 8
    
                local button = instance('TextButton', {
                    Text = v,
                    Font = 'Ubuntu',
                    TextSize = 14,
                    BackgroundColor3 = rgb(255, 255, 255),
                    BackgroundTransparency = 1,
                    TextColor3 = rgb(200, 200, 200),
                    Size = udim2(0, nX, 1, (data.Text and -30 or -10)),
                    BorderSizePixel = 0,
                    Parent = optionFrame,
                    TextTransparency = 1,
                    AutoButtonColor = false
                }, {corner(0, (data.Text and 6 or 8))}, {
                    function(self)
                        delay(c * 0.1, function()
                            ts(self, {0.3, 'Exponential'}, {
                                TextTransparency = 0
                            })
                        end)
    
                        self.MouseEnter:Connect(function()
                            ts(self, {0.3, 'Exponential'}, {
                                BackgroundTransparency = 0.8
                            })
                        end)
    
                        self.MouseLeave:Connect(function()
                            ts(self, {0.3, 'Exponential'}, {
                                BackgroundTransparency = 1
                            })
                        end)
    
                        self.MouseButton1Up:Connect(function()
                            ts(self, {0.3, 'Exponential'}, {
                                BackgroundColor3 = rgb(150, 150, 255),
                                TextColor3 = rgb(150, 150, 255)
                            })
    
                            delay(0.5, function()
                                ts(self, {0.3, 'Exponential'}, {
                                    BackgroundColor3 = rgb(255, 255, 255),
                                    TextColor3 = rgb(200, 200, 200)
                                })
                            end)
    
                            data.Callback(v)
    
                            if data.CloseOnCallback then
                                delay(0.4, function()
                                    close()
                                end)
                            end
                        end)
                    end
                })
    
                c = c + 1
            end
    
            ts(line, {0.3, 'Exponential'}, {
                BackgroundTransparency = 0.7
            })
    
            ts(notifFrame, {0.3, 'Exponential'}, {
                Size = udim2(0, notifFrame.AbsoluteSize.X + fX, 0, notifFrame.AbsoluteSize.Y)
            })
        end
    
        notifFrame = instance('Frame', {
            Parent = sgui.main,
            Size = udim2(0, 0, 0, 0),
            BackgroundColor3 = rgb(30, 30, 30),
            ClipsDescendants = true,
            BorderSizePixel = 0
        }, {
            corner(0, 12),
            instance('ImageLabel', {
                Size = udim2(0, (data.Image and 48 or 0), 0, (data.Text and 48 or 24)),
                Position = udim2(0, 7, 0.5, (data.Text and -23 or -12)),
                BackgroundTransparency = 1,
                Image = ('rbxassetid://%s'):format(data.Image or '')
            }, {
                instance('TextLabel', {
                    Position = udim2(1, 9, 0, 0),
                    Size = udim2(0, 4, (data.Text and 0.5 or 1), 0),
                    TextXAlignment = 'Left',
                    BackgroundTransparency = 1,
                    TextColor3 = rgb(255, 255, 255),
                    Font = 'Ubuntu',
                    RichText = true,
                    Text = data.Title,
                    TextSize = 14
                }),
                instance('TextLabel', {
                    Position = udim2(1, 9, 0.5, 0),
                    Size = udim2(0, 4, 0.45, 0),
                    BackgroundTransparency = 1,
                    Text = (data.Text or ''),
                    Font = 'Ubuntu',
                    RichText = true,
                    TextColor3 = rgb(210, 210, 210),
                    TextXAlignment = 'Left',
                    TextSize = 13
                })
            }),
            instance('TextLabel', {
                Size = udim2(0, 10, 0, 18),
                Position = udim2(1, -18, 0, 0),
                TextYAlignment = 'Bottom',
                Font = 'Ubuntu',
                TextSize = 10,
                TextColor3 = rgb(190, 190, 250),
                BackgroundTransparency = 1,
                RichText = true,
                Text = data.Duration and '<b>' .. tostring(data.Duration) .. '</b>' or '',
                Name = 'duration'
            }),
            instance('ImageButton', {
                Position = udim2(1, -35, 0.5, -10),
                Size = udim2(0, 20, 0, 20),
                Image = 'rbxassetid://10872983349',
                BackgroundColor3 = rgb(12, 12, 12),
                BackgroundTransparency = 1,
                Visible = data.Options and true or false,
                Name = 'extend'
            }, {corner(0, 9)}, {
                function(self)
                    self.MouseEnter:Connect(function()
                        ts(self, {0.3, 'Exponential'}, {
                            BackgroundTransparency = 0
                        })
                    end)
    
                    self.MouseLeave:Connect(function()
                        ts(self, {0.3, 'Exponential'}, {
                            BackgroundTransparency = 1
                        })
                    end)
    
                    self.MouseButton1Down:Connect(function()
                        ts(self, {0.3, 'Exponential'}, {
                            Position = udim2(1, -25, 0.5, 0),
                            Size = udim2(0, 0, 0, 0)
                        })
                        
                        delay(0.3, function()
                            self:Destroy()
                        end)
    
                        extend()
                    end)
                end
            })
        })
    
        close = function()
            notifFrame.ClipsDescendants = true
            mainGlow.hide()
            
            ts(notifFrame, {0.3, 'Exponential'}, {
                Size = udim2(0, 0, 0, finalY)
            })
    
            delay(0.3, function()
                ts(notifFrame, {0.3, 'Exponential'}, {
                    Size = udim2(0, 0, 0, 0)
                })
    
                delay(0.3, function()
                    notifFrame:Destroy()
                end)
            end)
        end
    
        mainGlow = glow(notifFrame, 3, 1)
    
        ts(notifFrame, {0.3, 'Exponential'}, {
            Size = udim2(0, finalX, 0, finalY)
        })
    
        delay(0.3, function()
            notifFrame.ClipsDescendants = false
        end)
    
        if data.Duration then
            spawn(function()
                local n = data.Duration
                while wait(1) do
                    n = n - 1
    
                    if n <= 0 then
                        break
                    end
    
                    notifFrame.duration.Text = '<b>' .. tostring(n) .. '</b>'
                end
            end)
    
            delay(data.Duration, close)
        end
    
        local d = {}
    
        function d:Close()
            close()
        end
    
        return d
    end
    
    
    _G.notify = notify

    local function notify(data)
        return _G.notify(data)
    end
    --#endregion


    --#region UI library
    local function instance(className,properties,children,funcs)
        local object = Instance.new(className)
        
        for i,v in pairs(properties or {}) do
            object[i] = v
        end
        for i, self in pairs(children or {}) do
            self.Parent = object
        end
        for i,func in pairs(funcs or {}) do
            func(object)
        end
        return object
    end
    
    local function ts(object,tweenInfo,properties)
        if tweenInfo[2] and typeof(tweenInfo[2]) == 'string' then
            tweenInfo[2] = Enum.EasingStyle[ tweenInfo[2] ]
        end
        game:service('TweenService'):create(object, TweenInfo.new(unpack(tweenInfo)), properties):Play()
    end
    
    local function udim2(x1,x2,y1,y2)
        local t = tonumber
        return UDim2.new(t(x1), t(x2), t(y1), t(y2))
    end
    
    local function rgb(r,g,b) 
        return Color3.fromRGB(r,g,b)
    end
    
    local function fixInt(int) 
        return tonumber(string.format('%.02f', int)) 
    end
    
    local function round(exact, quantum)
        local quant, frac = math.modf(exact/quantum)
        return fixInt(quantum * (quant + (frac > 0.5 and 1 or 0)))
    end
    
    local function scale(unscaled, minAllowed, maxAllowed, min, max)
        return (maxAllowed - minAllowed) * (unscaled - min) / (max - min) + minAllowed
    end
    
    local function glow(frame, radius, step, color)
        local instances = {}
    
        local folder = instance('Folder', {
            Parent = frame,
            Name = 'glow'
        })
        
        local function newInstance(thick)
            local new = instance('Frame', {
                Parent = folder,
                BackgroundTransparency = 1,
                Size = udim2(1, 0, 1, 0)
            }, {
                (function()
                    local d, c = nil, frame:FindFirstChildWhichIsA('UICorner')
                    if c then
                        d = instance('UICorner', {
                            CornerRadius = c.CornerRadius
                        })
    
                        c:GetPropertyChangedSignal('CornerRadius'):Connect(function()
                            d.CornerRadius = c.CornerRadius
                        end)
                    end
                    return d
                end)(),
                instance('UIStroke', {
                    Transparency = 0.95,
                    Thickness = thick,
                    Color = typeof(color) == 'Color3' and color or Color3.new(0, 0, 0)
                })
            })
            
            table.insert(instances, new.UIStroke)
        end
    
        for a=1,radius,step do
            newInstance(a)
        end
    
        local function change(func)
            for a,v in next, instances do
                func(v)
            end
        end
    
        return {
            setColor = function(c)
                change(function(v)
                    ts(v, {0.3, 'Exponential'}, {
                        Color = c
                    })
                end)
            end,
            hide = function()
                change(function(v)
                    ts(v, {0.2, 'Exponential'}, {
                        Transparency = 1
                    })
                end)
            end,
            show = function()
                change(function(v)
                    ts(v, {0.2, 'Exponential'}, {
                        Transparency = 0.95
                    })
                end)
            end
        }
    end
    
    local mouse = game:service('Players').LocalPlayer:GetMouse()
    
    local function checkPos(obj)
        local x, y = mouse.X, mouse.Y
        local abs, abp = obj.AbsoluteSize, obj.AbsolutePosition
    
        if x > abp.X and x < (abp.X + abs.X) and y > abp.Y and y < (abp.Y + abs.Y) then
            return true
        end
        return nil
    end
    
    local function dragify(frame) 
        local connection, move, kill
        local function connect()
            connection = frame.InputBegan:Connect(function(inp) 
                pcall(function() 
                    if (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) then 
                        local mx, my = mouse.X, mouse.Y 
                        move = mouse.Move:Connect(function() 
                            local nmx, nmy = mouse.X, mouse.Y 
                            local dx, dy = nmx - mx, nmy - my 
                            frame.Position = frame.Position + UDim2.fromOffset(dx, dy)
                            mx, my = nmx, nmy 
                        end) 
                        kill = frame.InputEnded:Connect(function(inputType) 
                            if inputType.UserInputType == Enum.UserInputType.MouseButton1 then 
                                move:Disconnect() 
                                kill:Disconnect() 
                            end 
                        end) 
                    end 
                end) 
            end) 
        end
        connect()
        return {
            disconnect = function()
                connection:Disconnect()
            end,
            reconnect = connect,
            killConnection = function()
                move:Disconnect()
                kill:Disconnect()
            end
        }
    end
    
    local function getRel(object)
        return {
            X = (mouse.X - object.AbsolutePosition.X),
            Y = (mouse.Y - object.AbsolutePosition.Y)
        }
    end
    
    local function makeBetter(obj, maxSize)
        local drag = dragify(obj)
    
        local button = instance('TextButton', {
            Parent = obj,
            Size = udim2(0, 10, 0, 10),
            BackgroundTransparency = 1,
            Text = '',
            Position = udim2(1, -10, 1, -10)
        })
    
        local holding = false
        button.MouseButton1Down:Connect(function()
            holding = true
            drag.disconnect()
    
            spawn(function()
                repeat
                    local sX, sY = (getRel(obj).X - obj.AbsoluteSize.X), (getRel(obj).Y - obj.AbsoluteSize.Y)
                    wait()
                    ts(obj, {0.5, 'Exponential'}, {
                        Size = udim2(0, (obj.AbsoluteSize.X + sX > maxSize.X and obj.AbsoluteSize.X + sX or maxSize.X), 0, (obj.AbsoluteSize.Y + sY > maxSize.Y and obj.AbsoluteSize.Y + sY or maxSize.Y))
                    })
                until not holding
            end)
        end)
    
        local function unhold()
            if holding then
                holding = false
                drag.reconnect()
            end
        end
    
        button.MouseButton1Up:Connect(unhold)
        mouse.Button1Up:Connect(unhold)
    end
    
    local function corner(r, r2)
        return instance('UICorner', {
            CornerRadius = UDim.new(r, r2)
        })
    end
    
    local uis = game:service('UserInputService')
    
    local function addBind(key, callback)
        local key2 = key
    
        uis.InputBegan:Connect(function(k, t)
            if t then
                return
            end
    
            pcall(function()
                if k.KeyCode == Enum.KeyCode[key2] then
                    callback()
                end
            end)
        end)
    
        return {
            setKey = function(s)
                key2 = s
            end
        }
    end        
    
    local create = {
        button = function(obj, data)
            data.Text = typeof(data.Text) == 'string' and data.Text or '[empty button name]'
            data.Callback = typeof(data.Callback) == 'function' and data.Callback or function() end
            
            local buttonGlow
    
            local main = instance('Frame', {
                Parent = obj,
                Size = udim2(1, 0, 0, 28),
                BackgroundColor3 = rgb(60, 60, 60),
                Name = '!_button'
            }, {
                corner(0, 10),
                instance('ImageLabel', {
                    Size = udim2(0, 16, 0, 16),
                    Position = udim2(1, -22, 0.5, -8),
                    Image = 'rbxassetid://11243256070',
                    BackgroundTransparency = 1,
                    ImageColor3 = rgb(255, 255, 255)
                }),
                instance('TextButton', {
                    Size = udim2(1, -10, 1, 0),
                    Position = udim2(0, 10, 0, 0),
                    Font = 'Ubuntu',
                    RichText = true,
                    TextSize = 13,
                    TextColor3 = rgb(220, 220, 220),
                    Text = data.Text,
                    BackgroundColor3 = rgb(60, 60, 60),
                    BackgroundTransparency = 1,
                    AutoButtonColor = false,
                    TextXAlignment = 'Left'
                }, {corner(0, 10)}, {
                    function(self)
                        self.MouseEnter:Connect(function()
                            ts(self.Parent, {0.3, 'Exponential'}, {
                                BackgroundColor3 = rgb(80, 80, 80)
                            })
                            buttonGlow.show()
                        end)
    
                        self.MouseLeave:Connect(function()
                            ts(self.Parent, {0.3, 'Exponential'}, {
                                BackgroundColor3 = rgb(60, 60, 60)
                            })
                            buttonGlow.hide()
                        end)
    
                        self.MouseButton1Down:Connect(function()
                            ts(self.Parent, {0.1, 'Exponential'}, {
                                BackgroundColor3 = rgb(150, 150, 150)
                            })
                            delay(0.1, function()
                                ts(self.Parent, {0.1, 'Exponential'}, {
                                    BackgroundColor3 = rgb(80, 80, 80)
                                })
                            end)
    
                            if data.Pcall then
                                pcall(data.Callback)
                            else
                                data.Callback()
                            end
                        end)
                    end
                })
            })
    
            buttonGlow = glow(main, 3, 1)
            buttonGlow.hide()
        end,
        toggle = function(obj, data)
            data.Text = typeof(data.Text) == 'string' and data.Text or '[empty toogle name]'
            data.State = typeof(data.State) == 'boolean' and data.State or false
            data.Callback = typeof(data.Callback) == 'function' and data.Callback or function() end
    
            local toggleGlow
            local toggled = data.State
            local toggleBody
    
            local function toggleToggle(s)
                ts(toggleBody.toggle, {0.3, 'Exponential'}, {
                    Position = s and udim2(1, -14, 0.5, -7) or udim2(0, 0, 0.5, -7),
                    BackgroundColor3 = s and rgb(255, 255, 255) or rgb(150, 150, 150)
                })
            end
    
            local main = instance('Frame', {
                Parent = obj,
                Size = udim2(1, 0, 0, 26),
                BackgroundColor3 = rgb(50, 50, 50),
                Name = '!_toggle',
            }, {
                corner(0, 10),
                instance('Frame', {
                    Size = udim2(0, 20, 0, 10),
                    Position = udim2(1, -30, 0.5, -5),
                    BackgroundColor3 = rgb(30, 30, 30),
                    Name = 'toggleBody'
                }, {
                    corner(1, 0),
                    instance('Frame', {
                        Size = udim2(0, 14, 0, 14),
                        Position = toggled and udim2(1, -14, 0.5, -7) or udim2(0, 0, 0.5, -7),
                        Name = 'toggle',
                        BackgroundColor3 = toggled and rgb(255, 255, 255) or rgb(150, 150, 150)
                    }, {corner(1, 0)})
                }, {
                    function(self)
                        toggleBody = self
    
                        glow(toggleBody.toggle, 3, 1)
                    end
                }),
                instance('TextButton', {
                    Size = udim2(1, -10, 1, 0),
                    BackgroundTransparency = 1,
                    Position = udim2(0, 10, 0, 0),
                    Font = 'Ubuntu',
                    RichText = true,
                    Text = data.Text,
                    TextSize = 13,
                    TextColor3 = rgb(220, 220, 220),
                    TextXAlignment = 'Left'
                }, {}, {
                    function(self)
                        self.MouseEnter:Connect(function()
                            toggleGlow.show()
                        end)
    
                        self.MouseLeave:Connect(function()
                            toggleGlow.hide()
                        end)
    
                        self.MouseButton1Down:Connect(function()
                            toggled = not toggled
    
                            toggleGlow.setColor(rgb(255, 255, 255))
    
                            delay(0.1, function()
                                toggleGlow.setColor(rgb(0, 0, 0))
                            end)
    
                            toggleToggle(toggled)
    
                            if data.Pcall then
                                pcall(function()
                                    data.Callback(toggled)
                                end)
                            else
                                data.Callback(toggled)
                            end
                        end)
                    end
                }),
            })
    
            toggleGlow = glow(main, 3, 1)
            toggleGlow.hide()
        end,
        keybind = function(obj, data)
            data.Text = typeof(data.Text) == 'string' and data.Text or '[empty keybind name]'
            data.Key = typeof(data.Key) == 'string' and Enum.KeyCode[data.Key] or nil
            data.Callback = typeof(data.Callback) == 'function' and data.Callback or function() end
            data.NewCallback = typeof(data.NewCallback) == 'function' and data.NewCallback or function() end
    
            local tss = game:service('TextService')
            local uis = game:service('UserInputService')
    
            local keybindGlow, frameGlow
            local key = data.Key
            local keyStr = key and tostring(key):split('.')[3] or 'Unbinded'
            local listening = false
    
            uis.InputBegan:Connect(function(k, t)
                if t or listening then
                    return
                end
    
                if k.KeyCode == key then
                    if data.Pcall then
                        pcall(data.Callback)
                    else
                        data.Callback()
                    end
                end
            end)
    
            local function getSize(str)
                if not str then
                    keyStr = key and tostring(key):split('.')[3] or 'Unbinded'
                    return tss:GetTextSize(keyStr, 11, 'Ubuntu', Vector2.new(math.huge, math.huge)).X
                end
    
                return tss:GetTextSize(str, 11, 'Ubuntu', Vector2.new(math.huge, math.huge)).X
            end
    
            local function listen()
                local newKey = 'Unbinded'
                local canContinue = false
                listening = true
                
                local bind;bind = uis.InputBegan:Connect(function(k, t)
                    if k.UserInputType ~= Enum.UserInputType.MouseButton1 and k.UserInputType ~= Enum.UserInputType.MouseButton2 then
                        newKey = k.KeyCode
                        canContinue = true
                        bind:Disconnect()
                    else
                        canContinue = true
                        bind:Disconnect()
                    end
                end)
    
                repeat
                    wait()
                until canContinue
    
                listening = false
                return newKey
            end
    
            local main = instance('Frame', {
                Parent = obj,
                Size = udim2(1, 0, 0, 28),
                BackgroundColor3 = rgb(50, 50, 50),
                Name = '!_keybind',
            }, {
                corner(0, 10),
                instance('TextLabel', {
                    Size = udim2(0, getSize() + 10, 0, 18),
                    Position = udim2(1, -(getSize() + 14), 0.5, -9),
                    Font = 'Ubuntu',
                    TextSize = 11,
                    TextColor3 = rgb(200, 200, 200),
                    BackgroundColor3 = rgb(30, 30, 30),
                    Text = keyStr,
                    Name = 'key'
                }, {corner(0, 7)}),
                instance('TextButton', {
                    Position = udim2(0, 10, 0, 0),
                    Size = udim2(1, -10, 1, 0),
                    TextXAlignment = 'Left',
                    BackgroundTransparency = 1,
                    Text = data.Text,
                    Font = 'Ubuntu',
                    RichText = true,
                    TextColor3 = rgb(220, 220, 220),
                    TextSize = 13,
                }, {}, {
                    function(self)
                        self.MouseEnter:Connect(function()
                            keybindGlow.show()
                        end)
    
                        self.MouseLeave:Connect(function()
                            keybindGlow.hide()
                        end)
    
                        local listening = false
                        self.MouseButton1Up:Connect(function()
                            if listening then
                                return
                            end
                            listening = true
                            frameGlow.show()
                            
                            self.Parent.key.Text = '...'
                            ts(self.Parent.key, {0.3, 'Exponential'}, {
                                Size = udim2(0, getSize('...') + 10, 0, 18),
                                Position = udim2(1, -(getSize('...') + 14), 0.5, -9)
                            })
    
                            local newKey = listen()
    
                            repeat
                                wait()
                            until newKey
    
                            listening = false
                            frameGlow.hide()
    
                            key = newKey
                            local new = newKey ~= 'Unbinded' and tostring(newKey):split('.')[3] or newKey
    
                            data.newCallback(new == 'Unbinded' and nil or new)
    
                            self.Parent.key.Text = new
                            ts(self.Parent.key, {0.3, 'Exponential'}, {
                                Size = udim2(0, getSize(new) + 10, 0, 18),
                                Position = udim2(1, -(getSize(new) + 14), 0.5, -9)
                            })                    
                        end)
                    end
                })
            })
    
            keybindGlow = glow(main, 3, 1)
            keybindGlow.hide()
    
            frameGlow = glow(main.key, 8, 1)
            frameGlow.setColor(rgb(97, 121, 255))
            frameGlow.hide()
        end,
        togglebind = function(obj, data)
            data.Text = typeof(data.Text) == 'string' and data.Text or '[empty togglebind name]'
            data.State = typeof(data.State) == 'boolean' and data.State or false
            data.Key = typeof(data.Key) == 'string' and Enum.KeyCode[data.Key] or nil
            data.Callback = typeof(data.Callback) == 'function' and data.Callback or function() end
            data.NewCallback = typeof(data.NewCallback) == 'function' and data.NewCallback or function() end
    
            local tss = game:service('TextService')
            local uis = game:service('UserInputService')
    
            local keybindGlow, frameGlow
            local key = data.Key
            local keyStr = key and tostring(key):split('.')[3] or 'Unbinded'
            local listening = false
    
            local function getSize(str)
                if not str then
                    keyStr = key and tostring(key):split('.')[3] or 'Unbinded'
                    return tss:GetTextSize(keyStr, 11, 'Ubuntu', Vector2.new(math.huge, math.huge)).X
                end
    
                return tss:GetTextSize(str, 11, 'Ubuntu', Vector2.new(math.huge, math.huge)).X
            end
    
            local function listen()
                local newKey = 'Unbinded'
                local canContinue = false
                listening = true
                
                local bind;bind = uis.InputBegan:Connect(function(k, t)
                    if k.UserInputType ~= Enum.UserInputType.MouseButton1 and k.UserInputType ~= Enum.UserInputType.MouseButton2 then
                        newKey = k.KeyCode
                        canContinue = true
                        bind:Disconnect()
                    else
                        canContinue = true
                        bind:Disconnect()
                    end
                end)
    
                repeat
                    wait()
                until canContinue
    
                listening = false
                return newKey
            end
    
            local toggleGlow
            local toggled = data.State
            local toggleBody
            local mainGlow, frameGlow
    
            local function toggleToggle(s)
                ts(toggleBody.toggle, {0.3, 'Exponential'}, {
                    Position = s and udim2(1, -14, 0.5, -7) or udim2(0, 0, 0.5, -7),
                    BackgroundColor3 = s and rgb(255, 255, 255) or rgb(150, 150, 150)
                })
            end
    
            local function toggle()
                toggled = not toggled
    
                mainGlow.setColor(rgb(255, 255, 255))
    
                delay(0.1, function()
                    mainGlow.setColor(rgb(0, 0, 0))
                end)
    
                toggleToggle(toggled)
    
                if data.Pcall then
                    pcall(function()
                        data.Callback(toggled)
                    end)
                else
                    data.Callback(toggled)
                end
            end
    
            uis.InputBegan:Connect(function(k, t)
                if t or listening then
                    return
                end
    
                if k.KeyCode == key then
                    toggle()
                end
            end)
    
            local main = instance('Frame', {
                Name = '!_togglebind',
                Size = udim2(1, 0, 0, 28),
                BackgroundColor3 = rgb(50, 50, 50),
                Parent = obj
            }, {
                corner(0, 10),
                instance('Frame', {
                    Size = udim2(0, 20, 0, 10),
                    Position = udim2(1, -30, 0.5, -5),
                    BackgroundColor3 = rgb(30, 30, 30),
                    Name = 'toggleBody'
                }, {
                    corner(1, 0),
                    instance('Frame', {
                        Size = udim2(0, 14, 0, 14),
                        Position = toggled and udim2(1, -14, 0.5, -7) or udim2(0, 0, 0.5, -7),
                        Name = 'toggle',
                        BackgroundColor3 = toggled and rgb(255, 255, 255) or rgb(150, 150, 150)
                    }, {corner(1, 0)})
                }, {
                    function(self)
                        toggleBody = self
    
                        glow(toggleBody.toggle, 3, 1)
                    end
                }),
                instance('TextButton', {
                    RichText = true,
                    Text = data.Text,
                    Position = udim2(0, 10, 0, 0),
                    Size = udim2(1, -10, 1, 0),
                    TextXAlignment = 'Left',
                    BackgroundTransparency = 1,
                    TextColor3 = rgb(220, 220, 220),
                    Font = 'Ubuntu',
                    TextSize = 13
                }, {}, {
                    function(self)
                        self.MouseEnter:Connect(function()
                            mainGlow.show()
                        end)
    
                        self.MouseLeave:Connect(function()
                            mainGlow.hide()
                        end)
    
                        self.MouseButton1Down:Connect(function()
                            toggle()
                        end)
                    end
                }),
                instance('TextButton', {
                    Size = udim2(0, getSize() + 10, 0, 18),
                    Position = udim2(1, -(getSize() + 48), 0.5, -9),
                    Font = 'Ubuntu',
                    TextSize = 11,
                    TextColor3 = rgb(200, 200, 200),
                    BackgroundColor3 = rgb(30, 30, 30),
                    Text = keyStr,
                    Name = 'key'
                }, {
                    corner(0, 7)
                }, {
                    function(self)
                        local listening = false
                        self.MouseButton1Up:Connect(function()
                            if listening then
                                return
                            end
                            listening = true
                            frameGlow.show()
                            
                            self.Text = '...'
                            ts(self, {0.3, 'Exponential'}, {
                                Size = udim2(0, getSize('...') + 10, 0, 18),
                                Position = udim2(1, -(getSize('...') + 48), 0.5, -9)
                            })
    
                            local newKey = listen()
    
                            repeat
                                wait()
                            until newKey
    
                            listening = false
                            frameGlow.hide()
    
                            key = newKey
                            local new = newKey ~= 'Unbinded' and tostring(newKey):split('.')[3] or newKey
    
                            data.NewCallback(new == 'Unbinded' and nil or new)
    
                            self.Text = new
                            ts(self, {0.3, 'Exponential'}, {
                                Size = udim2(0, getSize(new) + 10, 0, 18),
                                Position = udim2(1, -(getSize(new) + 48), 0.5, -9)
                            })                    
                        end)
                    end
                }),
            })
    
            mainGlow = glow(main, 3, 1)
            mainGlow.hide()
    
            frameGlow = glow(main.key, 8, 1)
            frameGlow.setColor(rgb(97, 121, 255))
            frameGlow.hide()
        end,
        textbox = function(obj, data)
            data.Text = typeof(data.Text) == 'string' and data.Text or '[empty textbox name]'
            data.Placeholder = typeof(data.Placeholder) == 'string' and data.Placeholder or 'Type here'
            data.NumberOnly = typeof(data.NumberOnly) == 'boolean' and data.NumberOnly or false
            data.Callback = typeof(data.Callback) == 'function' and data.Callback or function() end
            data.FillFunction = typeof(data.FillFunction) == 'function' and data.FillFunction or function() return {} end
    
            if data.Clear == nil then
                data.Clear = true
            end
            
    
            local text = data.Placeholder
            local main, mainGlow, box, boxGlow;
            local tss = game:service('TextService')
    
            local function getSize(str)
                return tss:GetTextSize(str, 11, 'Ubuntu', Vector2.new(math.huge, math.huge)).X
            end
    
            local function extract(str)
                local n = {}
                for a in string.gmatch(str, '%d+') do
                    table.insert(n, a)
                end
                return table.concat(n)
            end
    
            local full = false
    
            local function toggle(s)
                full = not s
                main.ClipsDescendants = not s
                ts(main.button, {0.3, 'Exponential'}, {
                    Position = s and udim2(0, 10, 0, 0) or udim2(-1, 0, 0, 0)
                })
                ts(main.TextBox, {0.3, 'Exponential'}, {
                    Position = s and udim2(1, -(getSize(text) + 15), 0.5, -10) or udim2(0, 3, 0, 3),
                    Size = s and udim2(0, getSize(text) + 10, 0, 20) or udim2(1, -6, 1, -6),
                    TextSize = s and 11 or 13
                })
            end
    
    
            main = instance('Frame', {
                Parent = obj,
                BackgroundColor3 = rgb(51, 51, 51),
                Size = udim2(1, 0, 0, 30),
                Name = '!_textbox',
            }, {
                corner(0, 9),
                instance('TextButton', {
                    Position = udim2(0, 10, 0, 0),
                    Size = udim2(1, -10, 1, 0),
                    BackgroundTransparency = 1,
                    TextXAlignment = 'Left',
                    Text = data.Text,
                    TextColor3 = rgb(220, 220, 220),
                    Font = 'Ubuntu',
                    TextSize = 13,
                    RichText = true,
                    Name = 'button'
                }, {}, {
                    function(self)
                        self.MouseEnter:Connect(function()
                            mainGlow.show()
                        end)
    
                        self.MouseLeave:Connect(function()
                            mainGlow.hide()
                        end)
    
                        self.MouseButton1Down:Connect(function()
                            toggle(false)
                            boxGlow.show()
                            box:CaptureFocus()
                        end)
                    end
                }),
                instance('TextBox', {
                    Text = '',
                    PlaceholderText = data.Placeholder,
                    Size = udim2(0, getSize(data.Placeholder) + 10, 0, 20),
                    Position = udim2(1, -(getSize(data.Placeholder) + 15), 0.5, -10),
                    BackgroundColor3 = rgb(30, 30, 30),
                    PlaceholderColor3 = rgb(150, 150, 150),
                    TextColor3 = rgb(220, 220, 220),
                    TextSize = 11,
                    Font = 'Ubuntu',
                    ClearTextOnFocus = data.Clear
                }, {
                    corner(0, 6),
                    instance('TextLabel', {
                        Text = '',
                        TextColor3 = rgb(220, 220, 220),
                        TextTransparency = 1,
                        TextSize = 11,
                        Font = 'Ubuntu',
                        BackgroundTransparency = 1,
                        Name = 'autofill',
                        Size = udim2(0, 10, 1, 0),
                        TextXAlignment = 'Left'
                    })
                }, {
                    function(self)
                        local mouseOn
                        self.MouseEnter:Connect(function()
                            mouseOn = true
                            boxGlow.show()
                        end)
    
                        self.MouseLeave:Connect(function()
                            mouseOn = false
                            boxGlow.hide()
                        end)
    
                        self.Focused:Connect(function()
                            boxGlow.setColor(rgb(97, 121, 255))
    
                            if mouseOn then
                                ts(box, {0.3, 'Exponential'}, {
                                    Position = udim2(1, -(getSize(data.Placeholder) + 15), 0.5, -10),
                                    Size = udim2(0, getSize(data.Placeholder) + 10, 0, 20)
                                })
                            end
                        end)
    
                        local AutoFind
    
                        self:GetPropertyChangedSignal('Text'):Connect(function()
                            if not full then
                                ts(box, {0.3, 'Exponential'}, {
                                    Position = udim2(1, -(getSize(self.Text:gsub(' ', '') ~= '' and self.Text or data.Placeholder) + 15), 0.5, -10),
                                    Size = udim2(0, getSize(self.Text:gsub(' ', '') ~= '' and self.Text or data.Placeholder) + 10, 0, 20)
                                })
                            end
    
                            local options = data.FillFunction()
    
                            if self.Text:gsub(' ', '') ~= '' and self:IsFocused() then
                                for a,v in next, options do
                                    if v:sub(1, #self.Text) == self.Text then
                                        ts(self.autofill, {0.3, 'Exponential'}, {
                                            TextTransparency = 0.7,
                                            Position = udim2(0.5, -math.round(self.TextBounds.X / 2), 0, 0)
                                        })
                                        self.autofill.Text = v
                                        AutoFind = v
                                        break
                                    else
                                        ts(self.autofill, {0.3, 'Exponential'}, {
                                            TextTransparency = 1
                                        })
                                        AutoFind = nil
                                    end
                                end
                            else
                                ts(self.autofill, {0.3, 'Exponential'}, {
                                    TextTransparency = 1
                                })
                                AutoFind = nil
                            end
    
                            if data.NumberOnly then
                                self.Text = extract(self.Text)
                            end
                        end)
    
                        self.FocusLost:Connect(function(EnterPressed)
                            boxGlow.setColor(rgb(0, 0, 0))
                            text = self.Text:gsub(' ', '') ~= '' and self.Text or data.Placeholder
                            toggle(true)
    
                            ts(self.autofill, {0.3, 'Exponential'}, {
                                TextTransparency = 1
                            })
    
                            if EnterPressed and AutoFind ~= nil then
                                self.Text = AutoFind
                            end
    
                            if data.Pcall then
                                pcall(function()
                                    data.Callback(self.Text)
                                end)
                            else
                                data.Callback(self.Text)
                            end
                        end)
                    end
                })
            })
    
            mainGlow = glow(main, 3, 1)
            mainGlow.hide()
    
            box = main.TextBox
            boxGlow = glow(main.TextBox, 5, 1)
            boxGlow.hide()
    
            return main
        end,
        dropdown = function(obj, data)
            data.Text = typeof(data.Text) == 'string' and data.Text or '[empty dropdown name]'
            data.Options = typeof(data.Options) == 'table' and data.Options or {}
            data.Default = typeof(data.Default) == 'string' and table.find(data.Options, data.Default) and data.Default or 'Unselected'
            data.Callback = typeof(data.Callback) == 'function' and data.Callback or function() end
    
            local canShow = true
            local mainGlow, main, hidden = nil,nil,false
            local frameGlow
            local tts = game:service('TextService')
            local option = data.Default
    
            local function getSize(str)
                return tts:GetTextSize(str, 11, 'Ubuntu', Vector2.new(math.huge, math.huge)).X
            end
    
            local function toggle(s)
                if s then
                    canShow = false
                    mainGlow.hide()
                    for a,v in next, main:GetDescendants() do
                        pcall(function()
                            v.ZIndex = 10
                        end)
                    end
                else
                    canShow = true
                    for a,v in next, main:GetDescendants() do
                        pcall(function()
                            v.ZIndex = 1
                        end)
                    end
                end
    
                if s then frameGlow.show() else frameGlow.hide() end
    
                ts(main.body, {0.3, 'Exponential'}, {
                    Position = s and udim2(1, -160, 0.5, -10) or udim2(1, -(getSize(option) + 15), 0.5, -10),
                    Size = s and udim2(0, 155, 0, (26 * #data.Options) + 8) or udim2(0, getSize(option) + 10, 0, 20),
                    BackgroundColor3 = s and rgb(35, 35, 35) or rgb(30, 30, 30)
                })
    
                ts(main.TextButton, {0.3, 'Exponential'}, {
                    Size = s and udim2(1, -160, 1, 0) or udim2(1, -10, 1, 0)
                })
    
                main.body.container.Visible = s
                main.body.selected.Text = option
    
                ts(main.body.selected, {0.3, 'Exponential'}, {
                    TextTransparency = s and 1 or 0
                })
            end
    
            main = instance('Frame', {
                Parent = obj,
                Size = udim2(1, 0, 0, 28),
                BackgroundColor3 = rgb(50, 50, 50),
            }, {
                corner(0, 10),
                instance('Frame', {
                    Name = 'body',
                    Size = udim2(0, getSize(data.Default) + 10, 0, 20),
                    Position = udim2(1, -(getSize(data.Default) + 15), 0.5, -10),
                    BackgroundColor3 = rgb(30, 30, 30)
                }, {
                    corner(0, 6),
                    instance('TextLabel', {
                        Name = 'selected',
                        Size = udim2(1, 0, 1, 0),
                        Font = 'Ubuntu',
                        TextSize = 11,
                        TextColor3 = rgb(200, 200, 200),
                        BackgroundTransparency = 1,
                        Text = data.Default
                    }),
                    instance('Frame', {
                        Position = udim2(0, 4, 0, 4),
                        Size = udim2(1, -8, 1, -8),
                        BackgroundColor3 = rgb(30, 30, 30),
                        Name = 'container',
                        Visible = false
                    }, {
                        corner(0, 4),
                        instance('UIListLayout', { 
                            SortOrder = 'LayoutOrder',
                            Padding = UDim.new(0, 0)
                        })
                    })
                }),
                instance('TextButton', {
                    TextSize = 13, 
                    Font = 'Ubuntu',
                    TextColor3 = rgb(220, 220, 220),
                    TextXAlignment = 'Left',
                    Size = udim2(1, -10, 1, 0),
                    Position = udim2(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = data.Text
                }, {}, {
                    function(self)
                        self.MouseEnter:Connect(function()
                            if not canShow then
                                return
                            end
    
                            mainGlow.show()
                        end)
    
                        self.MouseLeave:Connect(function()
                            if not canShow then
                                return
                            end
                            
                            mainGlow.hide()
                        end)
    
                        self.MouseButton1Down:Connect(function()
                            toggle(true)
                        end)
                    end
                })
            })
    
            local function addOptions()
                for a,v in next, data.Options do
                    local button = instance('TextButton', {
                        Parent = main.body.container,
                        Size = udim2(1, 0, 0, 26),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = rgb(55,55,55),
                        TextColor3 = rgb(220, 220, 220),
                        Text = v,
                        Font = 'Ubuntu',
                        TextSize = 11,
                        AutoButtonColor = false
                    }, {corner(0, 4)}, {
                        function(self)
                            self.MouseEnter:Connect(function()
                                ts(self, {0.3, 'Exponential'}, {
                                    BackgroundTransparency = 0
                                })
                            end)
    
                            self.MouseLeave:Connect(function()
                                ts(self, {0.3, 'Exponential'}, {
                                    BackgroundTransparency = 1
                                })
                            end)
    
                            self.MouseButton1Down:Connect(function()
                                option = v
    
                                if data.Pcall then
                                    pcall(function()
                                        data.Callback(v)
                                    end)
                                else
                                    data.Callback(v)
                                end
    
                                toggle(false)
                            end)
                        end
                    })
                end
            end
            addOptions()
    
            mainGlow = glow(main, 3, 1)
            mainGlow.hide()
    
            frameGlow = glow(main.body, 5, 1)
            frameGlow.hide()
    
            local d = {}
    
            function d:UpdateOptions(s)
                data.Options = s
    
                for a,v in next, main.body.container:GetChildren() do
                    if v:IsA('TextButton') then
                        v:Destroy()
                    end
                end
    
                addOptions()
            end
    
            return d
        end,
        slider = function(obj, data)
            data.Text = typeof(data.Text) == 'string' and data.Text or '[empty slider name]'
            data.Min = typeof(data.Min) == 'number' and data.Min or 0
            data.Max = typeof(data.Max) == 'number' and data.Max or 100
            data.Float = typeof(data.Float) == 'number' and data.Float or 1
            data.Value = typeof(data.Value) == 'number' and data.Value or data.Min
            data.Callback = typeof(data.Callback) == 'function' and data.Callback or function() end
            if data.BlockMax == nil then data.BlockMax = true end
    
            local current = scale(data.Value, 0, 1, data.Min, data.Max)
    
            local mainGlow, frameGlow, main
            local function listen()
                frameGlow.show()
    
                local con;con = game:service('RunService').Stepped:Connect(function()
                    local newScale = scale(mouse.X, 0, 1, main.AbsolutePosition.X + 10, (main.AbsolutePosition.X + 10) + (main.AbsoluteSize.X - 20))
                    if newScale < 0 then newScale = 0 end if newScale > 1 then newScale = 1 end
                    if newScale < 0.02 then frameGlow.hide() else frameGlow.show() end
    
                    local intScale = scale(newScale, data.Min, data.Max, 0, 1)
                    intScale = round(intScale, data.Float)
                    local sizeScale = scale(intScale, 0, 1, data.Min, data.Max)
                    main.TextBox.Text = intScale
    
                    if data.Pcall then
                        pcall(function()
                            data.Callback(intScale)
                        end)
                    else
                        data.Callback(intScale)
                    end
    
                    ts(main.sliderBody.slider, {0.3, 'Exponential'}, {
                        Size = udim2(sizeScale, -2, 1, -2),
                        BackgroundTransparency = sizeScale < 0.02 and 1 or 0
                    })
                end)
    
                game:service('UserInputService').InputEnded:Connect(function(k)
                    if k.UserInputType == Enum.UserInputType.MouseButton1 then
                        con:Disconnect()
                        frameGlow.hide()
                    end
                end)
            end
    
            main = instance('Frame', {
                Parent = obj,
                Size = udim2(1, 0, 0, 45),
                BackgroundColor3 = rgb(52, 52, 52)
            }, {
                corner(0, 10),
                instance('TextButton', {
                    Position = udim2(0, 10, 0, 10),
                    Size = udim2(1, -10, 1, -10),
                    TextYAlignment = 'Top',
                    TextXAlignment = 'Left',
                    BackgroundTransparency = 1,
                    Font = 'Ubuntu',
                    Text = data.Text,
                    TextColor3 = rgb(220, 220, 220),
                    TextSize = 13,
                    RichText = true
                }, {}, {
                    function(self)
                        self.MouseEnter:Connect(function()
                            mainGlow.show()
                        end)
    
                        self.MouseLeave:Connect(function()
                            mainGlow.hide()
                        end)
    
                        self.MouseButton1Down:Connect(function()
                            listen()
                        end)
                    end
                }),
                instance('TextBox', {
                    Size = udim2(0, 50, 0, 18),
                    Position = udim2(1, -55, 0, 5), 
                    BackgroundColor3 = rgb(30, 30, 30),
                    PlaceholderText = '0',
                    Text = data.Value,
                    TextColor3 = rgb(220, 220, 220),
                    Font = 'Ubuntu',
                    TextSize = 11,
                    ClipsDescendants = true
                }, {corner(0, 6)}, {
                    function(self)
                        self.FocusLost:Connect(function()
                            local t = tonumber(self.Text)
                            if not t then t = data.Min end
                            local newScale = scale(t, 0, 1, data.Min, data.Max)
                            if newScale > 1 then newScale = 1 end
                            if newScale < 0 then newScale = 0 end
    
                            local intScale = round(scale(newScale, data.Min, data.Max, 0, 1), data.Float)
                            self.Text = intScale
    
                            if data.Pcall then
                                pcall(function()
                                    data.Callback(intScale)
                                end)
                            else
                                data.Callback(intScale)
                            end
                            
                            ts(main.sliderBody.slider, {0.3, 'Exponential'}, {
                                Size = udim2(newScale, -2, 1, -2),
                                BackgroundTransparency = newScale < 0.02 and 1 or 0
                            })
                        end)
                    end
                }),
                instance('Frame', {
                    Position = udim2(0, 10, 1, -14),
                    Size = udim2(1, -20, 0, 6),
                    BackgroundColor3 = rgb(30, 30, 30),
                    Name = 'sliderBody'
                }, {
                    corner(1, 0),
                    instance('Frame', {
                        BackgroundColor3 = rgb(97, 121, 255),
                        Size = udim2(current, -2, 1, -2),
                        Position = udim2(0, 1, 0, 1),
                        Name = 'slider',
                    }, {corner(1, 0)})
                })
            })
    
            frameGlow = glow(main.sliderBody.slider, 4, 1)
            frameGlow.setColor(rgb(97, 121, 255))
            frameGlow.hide()
    
            mainGlow = glow(main, 3, 1)
            mainGlow.hide()
        end,
        textlabel = function(obj, data)
            data.Text = typeof(data.Text) == 'string' and data.Text or '[empty textlabel text]'
            data.Alignment = typeof(data.Alignment) == 'string' and data.Alignment or 'Center'
    
            local main = instance('Frame', {
                Size = udim2(1, 0, 0, 26),
                BackgroundTransparency = 1,
                Parent = obj
            }, {
                instance('TextLabel', {
                    RichText = true,
                    Text = data.Text,
                    Position = udim2(0, 10, 0, 0),
                    Size = udim2(1, -20, 1, 0),
                    TextXAlignment = data.Alignment,
                    Font = 'Ubuntu',
                    TextSize = 13, 
                    TextColor3 = rgb(220, 220, 220),
                    BackgroundTransparency = 1,
                })
            })
    
            local d = {}
            function d:SetText(str)
                main.TextLabel.Text = tostring(str)
            end
            
            return d
        end,
        colorpicker = function(obj, data, gui)
            data.Text = typeof(data.Text) == 'string' and data.Text or '[empty colorpicker name]'
            data.Color = typeof(data.Color) == 'table' and Color3.fromRGB(data.Color[1], data.Color[2], data.Color[3]) or typeof(data.Color) == 'Color3' and data.Color or Color3.new(1, 1, 1)
            data.Callback = typeof(data.Callback) == 'function' and data.Callback or function() end
    
            local h,s,v = data.Color:ToHSV()
            local mainGlow
            local colorFrame
            local main
    
            local listening = false
            local function startListening()
                if listening then
                    return
                end
                listening = true
    
                local listenFrame
                local dot, bar, box1
                
                local function stopListening()
                    ts(listenFrame, {0.4, 'Exponential'}, {
                        Position = udim2(0, listenFrame.AbsolutePosition.X, 1, 100)
                    })
    
                    delay(0.4, function()
                        listening = false
                        listenFrame:Destroy()
                    end)
                end
    
                local f = 1
    
                local csk = ColorSequenceKeypoint.new
                local function hsv(h1,s1,v1)
                    return Color3.fromHSV(h1, s1, v1)
                end
    
                local drag
    
                listenFrame = instance('Frame', {
                    Parent = gui,
                    Size = udim2(0, 0, 0, 220), --270
                    Position = udim2(0, (main.AbsolutePosition.X + main.AbsoluteSize.X), 0, main.AbsolutePosition.Y),
                    BackgroundColor3 = rgb(30, 30, 30),
                    ClipsDescendants = true
                }, {
                    corner(0, 10),
                    instance('TextLabel', {
                        RichText = true,
                        Name = 'title',
                        Position = udim2(0, 10, 0, 0),
                        Size = udim2(1, -10, 0, 33),
                        BackgroundTransparency = 1,
                        Text = ('%s<font color="rgb(100,100,100)"> • </font><font color="rgb(97,121,255)"><b>Color</b></font>'):format(data.Text),
                        Font = 'Ubuntu',
                        TextSize = 12,
                        TextColor3 = rgb(220, 220, 220),
                        TextXAlignment = 'Left',
                    }, {
                        instance('TextButton', {
                            Text = '<b>X</b>',
                            Font = 'Ubuntu',
                            TextSize = 13,
                            RichText = true,
                            AutoButtonColor = false,
                            BackgroundColor3 = rgb(255, 150, 150),
                            BackgroundTransparency = 0.9,
                            TextColor3 = rgb(255, 150, 150),
                            Position = udim2(1, -27, 0.5, -10),
                            Size = udim2(0, 20, 0, 20)
                        }, {corner(1, 0)}, {
                            function(self)
                                self.MouseEnter:Connect(function()
                                    ts(self, {0.2, 'Exponential'}, {
                                        BackgroundTransparency = 0.6
                                    })
                                end)
    
                                self.MouseLeave:Connect(function()
                                    ts(self, {0.2, 'Exponential'}, {
                                        BackgroundTransparency = 0.9
                                    })
                                end)
    
                                self.MouseButton1Down:Connect(function()
                                    stopListening()
    
                                    ts(self, {0.1, 'Exponential'}, {
                                        BackgroundTransparency = 0.2
                                    })
    
                                    delay(0.1, function()
                                        ts(self, {0.1, 'Exponential'}, {
                                            BackgroundTransparency = 0.6
                                        })
                                    end)
                                end)
                            end
                        })
                    }),
                    instance('Frame', {
                        Name = 'box1',
                        Position = udim2(0, 6, 0, 33),
                        Size = udim2(1, -12, 1, -70),
                        BackgroundColor3 = rgb(255, 255, 255),
                        BackgroundTransparency = 0.2
                    }, {
                        corner(0, 6),
                        instance('UIGradient', {
                            Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                                ColorSequenceKeypoint.new(1, Color3.fromHSV(h, 1, 1))
                            })
                        })
                    }, {
                        function(self)
                            box1 = self
                        end
                    }),
                    instance('Frame', {
                        Name = 'box2',
                        Position = udim2(0, 6, 0, 33),
                        Size = udim2(1, -12, 1, -70),
                        BackgroundColor3 = rgb(255, 255, 255),
                        BackgroundTransparency = 0.2
                    }, {
                        corner(0, 6),
                        instance('UIGradient', {
                            Rotation = 90,
                            Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, rgb(255, 255, 255)),
                                ColorSequenceKeypoint.new(1, rgb(0, 0, 0))
                            }),
                            Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 1),
                                NumberSequenceKeypoint.new(1, 0)
                            })
                        }),
                        instance('UIStroke', {
                            Thickness = 1,
                            Color = rgb(15, 15, 15)
                        }),
                        instance('Frame', {
                            BackgroundColor3 = rgb(0, 0, 0),
                            Position = udim2(scale(scale(s, 0, 1, 0, 270), 1, 0, 0, 1), -3, scale(v, 0, 1, 0, 220), -3),
                            Size = udim2(0, 6, 0, 6)
                        }, {
                            corner(1, 0),
                            instance('Frame', {
                                BackgroundColor3 = rgb(255, 255, 255),
                                Position = udim2(0, 2, 0, 2),
                                Size = udim2(1, -4, 1, -4)
                            }, {corner(1, 0)})
                        }, {
                            function(self)
                                dot = self
                            end
                        }),
                        instance('TextButton', {
                            Size = udim2(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            Text = '',
                        }, {}, {
                            function(self)
                                self.MouseButton1Down:Connect(function()
                                    local unlisten
                                    local con;con = game:service('RunService').Stepped:Connect(function()
                                        local apx,asx,apy,asy = self.AbsolutePosition.X, self.AbsoluteSize.X, self.AbsolutePosition.Y, self.AbsoluteSize.Y
                                        local sx = scale(mouse.X, 0, 1, apx, apx + asx)
                                        if sx > 1 then sx = 1 end; if sx < 0 then sx = 0 end
    
                                        local sy = scale(mouse.Y, 0, 1, apy, apy + asy)
                                        sy = scale(sy, 1, 0, 0, 1)
                                        if sy > 1 then sy = 1 end; if sy < 0 then sy = 0 end
    
                                        ts(colorFrame, {0.3, 'Exponential'}, {
                                            BackgroundColor3 = hsv(h, sx, sy)
                                        })
    
                                        ts(dot, {0.3, 'Exponential'}, {
                                            Position = udim2(sx, -3, scale(sy, 1, 0, 0, 1), -3)
                                        })
    
                                        s = sx
                                        v = sy
    
                                        if data.Pcall then
                                            pcall(function()
                                                data.Callback(hsv(h, sx, sy))
                                            end)
                                        else
                                            data.Callback(hsv(h, sx, sy))
                                        end
                                    end)
    
                                    unlisten = game:service('UserInputService').InputEnded:Connect(function(k)
                                        if k.UserInputType == Enum.UserInputType.MouseButton1 then
                                            con:Disconnect()
                                        end
                                    end)
                                end)
                            end
                        })
                    }),
                    instance('Frame', {
                        Position = udim2(0, 6, 1, -31),
                        Size = udim2(1, -12, 0, 25),
                        BackgroundColor3 = rgb(255, 255, 255)
                    }, {
                        corner(0, 6),
                        instance('UIStroke', {
                            Thickness = 1,
                            Color = rgb(15, 15, 15)
                        }),
                        instance('UIGradient', {
                            Color = ColorSequence.new({
                                csk(0.0, hsv(scale(36 * 0, 0, 1, 0, 360), 1, 1)),
                                csk(0.1, hsv(scale(36 * 1, 0, 1, 0, 360), 1, 1)),
                                csk(0.2, hsv(scale(36 * 2, 0, 1, 0, 360), 1, 1)),
                                csk(0.3, hsv(scale(36 * 3, 0, 1, 0, 360), 1, 1)),
                                csk(0.4, hsv(scale(36 * 4, 0, 1, 0, 360), 1, 1)),
                                csk(0.5, hsv(scale(36 * 5, 0, 1, 0, 360), 1, 1)),
                                csk(0.6, hsv(scale(36 * 6, 0, 1, 0, 360), 1, 1)),
                                csk(0.7, hsv(scale(36 * 7, 0, 1, 0, 360), 1, 1)),
                                csk(0.8, hsv(scale(36 * 8, 0, 1, 0, 360), 1, 1)),
                                csk(0.9, hsv(scale(36 * 9, 0, 1, 0, 360), 1, 1)),
                                csk(1.0, hsv(scale(36 * 10, 0, 1, 0, 360), 1, 1)),
                            })
                        }),
                        instance('Frame', {
                            Size = udim2(0, 6, 1, -6),
                            Position = udim2(scale(h, 0, 1, 0, 258), -3, 0, 3),
                            BackgroundColor3 = rgb(0, 0, 0)
                        }, {
                            corner(1, 0),
                            instance('Frame', {
                                Position = udim2(0, 2, 0, 2),
                                BackgroundColor3 = rgb(255, 255, 255),
                                Size = udim2(1, -4, 1, -4)
                            }, {corner(1, 0)})
                        }, {
                            function(self)
                                bar = self
                            end
                        }),
                        instance('TextButton', {
                            Size = udim2(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            Text = ''
                        }, {}, {
                            function(self)
                                self.MouseButton1Down:Connect(function()
                                    local con;con = game:service('RunService').Stepped:Connect(function()
                                        local apx, asx = self.AbsolutePosition.X, self.AbsoluteSize.X
                                        local sx = scale(mouse.X, 0, 1, apx, apx + asx)
                                        if sx > 1 then sx = 1 end; if sx < 0 then sx = 0 end
    
                                        h = sx
    
                                        ts(bar, {0.3, 'Exponential'}, {
                                            Position = udim2(sx, -3, 0, 3)
                                        })
    
                                        ts(colorFrame, {0.3, 'Exponential'}, {
                                            BackgroundColor3 = hsv(h, s, v)
                                        })
    
                                        box1.UIGradient.Color = ColorSequence.new({
                                            ColorSequenceKeypoint.new(0, rgb(255, 255, 255)),
                                            ColorSequenceKeypoint.new(1, hsv(h, 1, 1))
                                        })
    
                                        if data.Pcall then
                                            pcall(function()
                                                data.Callback(hsv(h, s, v))
                                            end)
                                        else
                                            data.Callback(hsv(h, s, v))
                                        end
                                    end)
    
                                    game:service('UserInputService').InputEnded:Connect(function(k)
                                        if k.UserInputType == Enum.UserInputType.MouseButton1 then
                                            con:Disconnect()
                                        end
                                    end)    
                                end)
                            end
                        })
                    })
                })
    
                glow(listenFrame, 3, 1)
                drag = dragify(listenFrame)
    
                delay(0.3, function()
                    listenFrame.ClipsDescendants = false
                end)
    
                ts(listenFrame, {0.3, 'Exponential'}, {
                    Size = udim2(0, 270, 0, 220),
                    Position = udim2(0, (main.AbsolutePosition.X + main.AbsoluteSize.X + 30), 0, main.AbsolutePosition.Y),
                })
            end
    
            main = instance('Frame', {
                Parent = obj,
                Size = udim2(1, 0, 0, 30),
                BackgroundColor3 = rgb(53, 53, 53),
                Name = '!_colorpicker'
            }, {
                corner(0, 10),
                instance('Frame', {
                    Position = udim2(1, -45, 0, 5),
                    Size = udim2(0, 40, 1, -10),
                    BackgroundColor3 = data.Color,
                }, {
                    corner(0, 6),
                }, {
                    function(self)
                        colorFrame = self
    
                        local selfGlow = glow(self, 3, 1)
                        selfGlow.setColor(Color3.fromHSV(h, s, v - 0.2))
    
                        self:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
                            local H,S,V = self.BackgroundColor3:ToHSV()
                            selfGlow.setColor(Color3.fromHSV(H, S, V))
                        end)
                    end
                }),
                instance('TextButton', {
                    Position = udim2(0, 10, 0, 0),
                    Size = udim2(1, -10, 1, 0),
                    Text = data.Text,
                    BackgroundTransparency = 1,
                    RichText = true,
                    Font = 'Ubuntu',
                    TextSize = 13,
                    TextColor3 = rgb(220, 220, 220),
                    TextXAlignment = 'Left',
                }, {}, {
                    function(self)
                        self.MouseEnter:Connect(function()
                            mainGlow.show()
                        end)
    
                        self.MouseLeave:Connect(function()
                            mainGlow.hide()
                        end)
    
                        self.MouseButton1Down:Connect(function()
                            startListening()
                        end)
                    end
                })
            })
    
            mainGlow = glow(main, 3, 1)
            mainGlow.hide()
        end,
        locked = function(obj, data)
            data.Text = typeof(data.Text) == 'string' and data.Text or '[empty locked name]'

            data.Text = typeof(data.Text) == 'string' and data.Text or '[empty button name]'
            data.Callback = typeof(data.Callback) == 'function' and data.Callback or function() end
                
            local main = instance('Frame', {
                Parent = obj,
                Size = udim2(1, 0, 0, 28),
                BackgroundColor3 = rgb(40, 40, 40),
                Name = '!_locked'
            }, {
                corner(0, 10),
                instance('ImageLabel', {
                    Size = udim2(0, 12, 0, 12),
                    Position = udim2(1, -20, 0.5, -6),
                    Image = 'rbxassetid://6114012068',
                    BackgroundTransparency = 1,
                    ImageColor3 = rgb(150, 150, 150)
                }),
                instance('TextButton', {
                    Size = udim2(1, -10, 1, 0),
                    Position = udim2(0, 10, 0, 0),
                    Font = 'Ubuntu',
                    RichText = true,
                    TextSize = 13,
                    TextColor3 = rgb(150, 150, 150),
                    Text = data.Text,
                    BackgroundColor3 = rgb(60, 60, 60),
                    BackgroundTransparency = 1,
                    AutoButtonColor = false,
                    TextXAlignment = 'Left'
                }, {corner(0, 10)}, {
                    function(self)
                        self.MouseEnter:Connect(function()
                            ts(self, {0.2, 'Exponential'}, {
                                TextTransparency = 1
                            })
                            delay(0.2, function()
                                self.Text = 'Premium only feature.'

                                ts(self, {0.2, 'Exponential'}, {
                                    TextTransparency = 0
                                })
                            end)
                        end)

                        self.MouseLeave:Connect(function()
                            ts(self, {0.2, 'Exponential'}, {
                                TextTransparency = 1
                            })
                            delay(0.2, function()
                                self.Text = data.Text

                                ts(self, {0.2, 'Exponential'}, {
                                    TextTransparency = 0
                                })
                            end)
                        end)
                    end
                })
            })
        end
    }
    
    
    
    
    
    
    
    
    
    local library = {}
    
    function library:New(data)
        pcall(function()
            game:service('CoreGui')['ui_v7']:Destroy()
        end)
    
        local lib = {}
    
        --LOCALS
        local selectedTab
        local lastTab
    
        local sgui = instance('ScreenGui', {
            Name = 'ui_v7'
        })
 
        local dCount = 0
        local function createDetachment(italic, name, detatchedStuff, rCallback1, rCallback2)
            dCount = dCount + 1
        
            local main = instance('Frame', {
                Name = 'detachment_' .. dCount,
                Size = udim2(0, 300, 0, 300),
                Position = udim2(0.5, -150, 0.5, -150),
                BackgroundColor3 = rgb(0, 0, 0),
                BackgroundTransparency = 0.5,
                Parent = sgui
            }, {
                corner(0, 12),
                instance('Frame', {
                    Position = udim2(0, 9, 0, 9),
                    Size = udim2(1, -18, 1, -18),
                    BackgroundTransparency = 1,
                    Name = 'blur'
                }),
                instance('Frame', {
                    Position = udim2(0, 6, 0, 30),
                    Size = udim2(1, -12, 1, -36),
                    BackgroundColor3 = rgb(0, 0, 0),
                    BackgroundTransparency = 0.5,
                    Name = 'body',
                    ClipsDescendants = true
                }, {
                    corner(0, 9),
                    instance('ScrollingFrame', {
                        Name = 'container',
                        Position = udim2(0, 8, 0, 8),
                        Size = udim2(1, -16, 1, -16),
                        BackgroundTransparency = 1,
                        ScrollBarThickness = 0,
                        BorderSizePixel = 0,
                        AutomaticCanvasSize = 'Y',
                        CanvasSize = udim2(0, 0, 0, 0),
                        ClipsDescendants = false
                    })
                }),
                instance('TextLabel', {
                    Position = udim2(0, 10, 0, 1),
                    Size = udim2(1, -10, 0, 29),
                    TextXAlignment = 'Left',
                    RichText = true,
                    Text = italic and ('<i>%s</i>'):format(name) or ('<b>%s</b>'):format(name),
                    TextColor3 = rgb(255, 255, 255),
                    Font = 'Ubuntu',
                    TextSize = 14,
                    BackgroundTransparency = 1,
                }, {
                    instance('TextButton', {
                        Size = udim2(0, 20, 0, 20),
                        Position = udim2(1, -30, 0.5, -10),
                        BackgroundTransparency = 1,
                        Text = '<b>X</b>',
                        Font = 'Ubuntu',
                        RichText = true,
                        TextSize = 12,
                        TextColor3 = rgb(200, 200, 200)
                    }, {}, {
                        function(self)
                            self.MouseEnter:Connect(function()
                                ts(self, {0.3, 'Exponential'}, {
                                    TextColor3 = rgb(255, 150, 150)
                                })
                            end)
    
                            self.MouseLeave:Connect(function()
                                ts(self, {0.3, 'Exponential'}, {
                                    TextColor3 = rgb(200, 200, 200)
                                })
                            end)
    
                            self.MouseButton1Down:Connect(function()
                                rCallback2()
                                
                                for a,v in next, self.Parent.Parent.body.container:GetChildren() do
                                    rCallback1(v)
                                end
                            end)
                        end
                    })
                })
            })
    
            makeBetter(main, {
                X = 200,
                Y = 150,
            })
    
            blurModule:BindFrame(main.blur, {
                Material = 'Glass',
                Color = rgb(255, 255, 255),
                Transparency = 0.999
            })
        
            return main 
        end

        sgui.Parent = game:service('CoreGui')
    
        local mainFrame = instance('Frame', {
            Parent = sgui,
            Size = udim2(0, 0, 0, 0),
            Position = udim2(0.5, 0, 0.5, 0),
            BackgroundColor3 = rgb(22, 22, 22),
        }, {
            corner(1, 0),
            instance('Frame', {
                Size = udim2(0, 0, 0, 0),
                Position = udim2(0.5, 0, 0.5, 0),
                BackgroundColor3 = rgb(145, 139, 255),
                BackgroundTransparency = 0.8,
                Name = 'back',
                ZIndex = 10,
            }, {
                corner(1, 0)
            }),
            instance('ImageLabel', {
                Name = 'logo',
                Position = udim2(0.5, 0, 0.5, 0),
                Size = udim2(0, 0, 0, 0),
                BackgroundTransparency = 1,
                Image = 'rbxassetid://12133038644',
                ImageColor3 = rgb(145, 139, 255),
                ZIndex = 10,
            })
        })
    
        local mainGlow = glow(mainFrame, 5, 1)
        makeBetter(mainFrame, {X = 350, Y = 250})
    
        local oldX, oldY = 450, 380
        local function toggleBody(s)
            if not s then
                mainFrame.TextButton.Visible = false
                mainFrame.logo.Size = udim2(1, -10, 1, -10)
                mainFrame.logo.Position = udim2(0.5, -13, 0.5, -13)
                mainGlow.hide()
                oldX = mainFrame.Size.X.Offset
                oldY = mainFrame.Size.Y.Offset
                mainFrame.ClipsDescendants = true
                mainFrame.title.minimize.Text = '<b>+</b>'
            else
                delay(0.35, function()
                    mainFrame.TextButton.Visible = true
                    mainFrame.logo.Size = udim2(0, 0, 0, 0)
                    mainFrame.logo.Position = udim2(0.5, 0, 0.5, 0)
                    mainFrame.ClipsDescendants = false
                    mainFrame.title.minimize.Text = '<b>-</b>'
                    mainGlow.show()
                end)
            end
    
            ts(mainFrame.body, {0.3, 'Exponential'}, {
                Position = not s and udim2(2, 0, 1, 0) or udim2(0, 0, 0, 36),
                Size = not s and udim2(1, 0, 1, 0) or udim2(1, 0, 1, -36)
            })
            ts(mainFrame.title.close, {0.35, 'Exponential'}, {
                Position = not s and udim2(1, 0, 0, 0) or udim2(1, -30, 0.5, -12)
            })
            ts(mainFrame.title.minimize, {0.35, 'Exponential'}, {
                Position = not s and udim2(0.5, -12, 0.5, -12) or udim2(1, -60, 0.5, -12)
            })
            ts(mainFrame.title, {0.35, 'Exponential'}, {
                TextTransparency = not s and 1 or 0,
                Position = not s and udim2(0, 0, 0, 0) or udim2(0, 10, 0, 0),
                Size = not s and udim2(1, 0, 1, 0) or udim2(1, -10, 0, 36)
            })
            ts(mainFrame, {0.35, 'Exponential'}, {
                Size = not s and udim2(0, 36, 0, 36) or udim2(0, oldX, 0, oldY)
            })
            ts(mainFrame.UICorner, {not s and 1.5 or 0.35, 'Exponential'}, {
                CornerRadius = not s and UDim.new(1, 0) or UDim.new(0, 10)
            })
        end
    
        local savedPos, hidden, hideCooldown = nil, false, false
        local function hideUi(s)
            if hideCooldown then
                return
            end
            hideCooldown = true
            delay(0.7, function()
                hideCooldown = false
            end)
    
            hidden = s
    
            if s then
                savedPos = mainFrame.Position
    
                ts(mainFrame, {0.6, 'Bounce'}, {
                    Position = udim2(0, mainFrame.AbsolutePosition.X, 2, 0)
                })
            else
                ts(mainFrame, {0.6, 'Exponential'}, {
                    Position = savedPos
                })
            end
        end
    
        local showBind = addBind(UiConfig.ShowUiBind, function()
            if UiConfig.ClassicClose then
               hideUi(not hidden)

               return
            end
            
            if hidden then 
                hideUi(false)
            end
        end)
    
        spawn(function()
            while wait(0.5) do
                showBind.setKey(UiConfig.ShowUiBind)
            end
        end)
    
        ts(mainFrame, {0.8, 'Exponential'}, {
            Size = udim2(0, 150, 0, 150),
            Position = udim2(0.5, -75, 0.5, -75)
        })
    
        delay(0.35, function() --launch animation
            mainGlow.show()
    
            ts(mainFrame.logo, {0.5, 'Exponential'}, {
                Position = udim2(0.5, -50, 0.5, -50),
                Size = udim2(0, 100, 0, 100),
            })
    
            delay(0.12, function()
                ts(mainFrame.back, {0.4, 'Exponential'}, {
                    Position = udim2(0, 6, 0, 6),
                    Size = udim2(1, -12, 1, -12),
                })
            end)
    
            delay(2, function()
                ts(mainFrame.logo, {0.5, 'Exponential'}, {
                    ImageColor3 = rgb(255, 255, 255)
                })
        
                delay(1, function()
                    ts(mainFrame.logo, {0.3, 'Exponential'}, {
                        ImageTransparency = 1,
                        Size = udim2(0, 0, 0, 0),
                        Position = udim2(0.5, 0, 0.5, 0)
                    })
    
                    delay(0.25, function()
                        ts(mainFrame.back, {0.5, 'Exponential'}, {
                            BackgroundTransparency = 1
                        })
                        delay(0.51, function()
                            mainFrame.back:Destroy()
                        end)
                    end)
                end)
    
                ts(mainFrame.back, {0.4, 'Exponential'}, {
                    Position = udim2(0, 2, 0, 2),
                    Size = udim2(1, -4, 1, -4),
                    BackgroundTransparency = 0,
                    BackgroundColor3 = rgb(50, 50, 50)
                })
    
                ts(mainFrame.back.UICorner, {0.4, 'Exponential'}, {
                    CornerRadius = UDim.new(0, 8)
                })
    
                ts(mainFrame, {0.4, 'Exponential'}, {
                    Size = udim2(0, 450, 0, 380),
                    Position = udim2(0.5, -450/2, 0.5, -380/2)
                })
    
                ts(mainFrame.UICorner, {0.4, 'Exponential'}, {
                    CornerRadius = UDim.new(0, 10)
                })
            end)
        end)
    
        wait(2.6)
    
        local title = instance('TextLabel', {
            Parent = mainFrame,
            Name = 'title',
            Position = udim2(0, 10, 0, 0),
            Size = udim2(1, -10, 0, 36),
            BackgroundTransparency = 1,
            Font = 'Ubuntu',
            RichText = true,
            TextSize = 14,
            TextXAlignment = 'Left',
            Text = ('<b>%s  </b><font color="rgb(200,200,200)" size="12">|  <i>%s</i></font>'):format(data.Title, data.SubTitle or 'Universals'),
            TextColor3 = rgb(255, 255, 255),
        }, {
            instance('TextButton', {
                Position = udim2(1, -60, 0.5, -12),
                Size = udim2(0, 24, 0, 24),
                BackgroundTransparency = 0.8,
                BackgroundColor3 = rgb(255, 255, 150),
                TextColor3 = rgb(255, 255, 150),
                RichText = true,
                Text = '<b>-</b>',
                Font = 'Ubuntu',
                TextSize = 14,
                Name = 'minimize'
            }, {
                corner(1, 0)
            }, {
                function(self)
                    local toggled = true
    
                    self.MouseButton1Down:Connect(function()
                        toggled = not toggled
                        toggleBody(toggled)
                    end)
    
                    self.MouseEnter:Connect(function()
                        if not toggled then
                            ts(mainFrame.logo, {0.3, 'Exponential'}, {
                                ImageTransparency = 1
                            })
                            ts(self, {0.3, 'Exponential'}, {
                                BackgroundTransparency = 0.8,
                                TextTransparency = 0
                            })
                        end
                    end)
    
                    self.MouseLeave:Connect(function()
                        if not toggled then
                            ts(mainFrame.logo, {0.3, 'Exponential'}, {
                                ImageTransparency = 0
                            })
                            ts(self, {0.3, 'Exponential'}, {
                                BackgroundTransparency = 1,
                                TextTransparency = 1
                            })
                        end
                    end)
                end
            }),
            instance('TextButton', {
                Position = udim2(1, -30, 0.5, -12),
                Size = udim2(0, 24, 0, 24),
                Name = 'close',
                Text = '<b>X</b>',
                RichText = true,
                Font = 'Ubuntu',
                TextSize = 11,
                TextColor3 = rgb(255, 150, 150),
                BackgroundColor3 = rgb(255, 150, 150),
                BackgroundTransparency = 0.8
            }, {
                corner(1, 0)
            }, {
                function(self)
                    self.MouseButton1Down:Connect(function()
                        hideUi(true)
    
                        if UiConfig.CloseNotification then
                            local a;a = notify({
                                Title = 'Multi-Core V',
                                Text = ('UI is hidden. Press %s to show'):format(UiConfig.ShowUiBind),
                                Options = {
                                    'Show UI',
                                    'Close',
                                },
                                Image = '11335634088',
                                Duration = 5,
                                Callback = function(s)
                                    if s == 'Show UI' then
                                        hideUi(false)
                                    else
                                        a:Close()
                                    end
                                end
                            })
                        end
                    end)
                end
            })
        })
    
        local body = instance('Frame', {
            Parent = mainFrame,
            Position = udim2(0, 0, 0, 36),
            Size = udim2(1, 0, 1, -36),
            BackgroundTransparency = 1,
            Name = 'body'
        }, {
            instance('Frame', {
                Name = 'tabs',
                Position = udim2(0, 10, 0, 0),
                Size = udim2(0, 120, 1, -10),
                BackgroundColor3 = rgb(35, 35, 35)
            }, {
                corner(0, 8),
                instance('Frame', {
                    Name = 'container',
                    Position = udim2(0, 6, 0, 6),
                    Size = udim2(1, -12, 1, -12),
                    BackgroundTransparency = 1,
                }, {
                    instance('UIListLayout', {
                        Padding = UDim.new(0, 6)
                    })
                })
            }, {
                function(self)
                    glow(self, 3, 1)
                end
            }),
            instance('Frame', {
                Name = 'container',
                Position = udim2(0, 140, 0, 0),
                Size = udim2(1, -150, 1, -10),
                BackgroundColor3 = rgb(30, 30, 30),
                ClipsDescendants = true
            }, {
                corner(0, 8)
            }, {
                function(self)
                    glow(self, 3, 1)
                end
            })
        })
    
        local tabCount = 0
    
        function lib:Tab(tabData)
            local tabLib = {}
            local tabWindow,tabButton
            local categories = {}
            
            tabCount = tabCount + 1
    
            local function reattach()
    
            end
    
            local tabDetached = false
            local function detachTab()
                if tabDetached then
                    return
                end
                tabDetached = true
    
                local det;det = createDetachment(false, tabData.Name, {}, function(v)
                    v.Parent = tabWindow
                    
                    if v:IsA('Frame') then
                        if v.Name == 'category' then
                            v.BackgroundTransparency = 0
                            v.BackgroundColor3 = rgb(42, 42, 42)
                        end
    
                        local oldSize = v.Size
                        v.Size = udim2(1, 0, 0, 0)
    
                        local newd = 0
                        delay(0.1, function()
                            newd = newd + 0.1
                            ts(v, {0.5, 'Exponential'}, {
                                Size = oldSize
                            })
                        end)
                    end
                end, function()
                    tabDetached = false
                    tabWindow.detachedStatus.Visible = false
                    tabWindow.detachedStatus.TextTransparency = 1
    
                    ts(det, {2, 'Exponential'}, {
                        Position = udim2(0, det.AbsolutePosition.X, 2, 0)
                    })
    
                    delay(0.3, function()
                        det:Destroy()
                    end)
                end)
    
                det.Position = udim2(0.5, -150, 1, 0)
    
                for a,v in next, tabWindow:GetChildren() do
                    if v.Name ~= 'detachedStatus' then
                        v.Parent = det.body.container
                        
                        if v:IsA('Frame') and v.Name == 'category' then
                            v.BackgroundTransparency = 0.95
                            v.BackgroundColor3 = rgb(255, 255, 255)
                        end
                    end
                end
    
                tabWindow.detachedStatus.Visible = true
                ts(tabWindow.detachedStatus, {0.3, 'Exponential'}, {
                    TextTransparency = 0
                })
    
                ts(det, {0.3, 'Exponential'}, {
                    Position = udim2(0.5, -150, 0.5, -150)
                })
            end
    
            --detachTab()
    
            tabButton = instance('Frame', {
                Parent = mainFrame.body.tabs.container,
                Size = udim2(1, 0, 0, 26),
                BackgroundColor3 = rgb(70, 70, 70),
                BackgroundTransparency = 1,
                Name = 'tab_' .. tabCount .. '_' .. tabData.Name
            }, {
                corner(0, 6),
                instance('ImageLabel', {
                    Name = 'icon',
                    Position = udim2(0, (tabData.Icon ~= nil and 3 or 0), 0.5, -10),
                    Size = udim2(0, (tabData.Icon ~= nil and 20 or 0), 0, 20),
                    BackgroundTransparency = 1,
                    Image = tabData.Icon,
                    ImageColor3 = rgb(150, 150, 150)
                }, {
                    instance('TextLabel', {
                        Position = udim2(0, (tabData.Icon ~= nil and 24 or 6), 0, 1),
                        Size = udim2(0, 30, 1, -2),
                        TextXAlignment = 'Left',
                        BackgroundTransparency = 1,
                        Font = 'Ubuntu',
                        TextSize = 11,
                        RichText = true,
                        Text = ('<b>%s</b>'):format(tabData.Name),
                        TextColor3 = rgb(150, 150, 150),
                    })
                }),
                instance('TextButton', {
                    Size = udim2(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = ''
                }),
                instance('ImageButton', {
                    Size = udim2(0, 16, 0, 14),
                    Position = udim2(1, -22, 0.5, -7),
                    Image = 'rbxassetid://12131634551',
                    ImageTransparency = 1,
                    Name = 'detach',
                    ImageColor3 = rgb(150, 150, 150),
                    BackgroundTransparency = 1,
                    BackgroundColor3 = rgb(0, 0, 0)
                }, {corner(0, 4)}, {
                    function(self)
                        self.MouseEnter:Connect(function()
                            ts(self, {0.3, 'Exponential'}, {
                                BackgroundTransparency = 0.5
                            })
                        end)
    
                        self.MouseLeave:Connect(function()
                            ts(self, {0.3, 'Exponential'}, {
                                BackgroundTransparency = 1
                            })
                        end)
    
                        self.MouseButton1Down:Connect(function()
                            detachTab()
                        end)
                    end
                })
            }, {
                function(self)
                    local buttonGlow = glow(self, 3, 1)
                    buttonGlow.hide()
    
                    self.MouseEnter:Connect(function()
                        ts(self, {0.3, 'Exponential'}, {
                            BackgroundTransparency = 0.6
                        })
    
                        ts(self.detach, {0.3, 'Exponential'}, {
                            ImageTransparency = 0
                        })
                    end)
    
                    self.MouseLeave:Connect(function()
                        if selectedTab ~= tabWindow then
                            ts(self, {0.3, 'Exponential'}, {
                                BackgroundTransparency = 1
                            })
    
                            ts(self.detach, {0.3, 'Exponential'}, {
                                ImageTransparency = 1
                            })
                        end
                    end)
    
                    self.TextButton.MouseButton1Down:Connect(function()
                        lastTab = selectedTab
    
                        if lastTab then
                            ts(lastTab, {0.3, 'Exponential'}, {
                                Position = udim2(-1, 0, 0, 8)
                            })
    
                            delay(0.3, function()
                                lastTab.Position = udim2(1, 0, 0, 8)
                            end)
                        end
    
                        selectedTab = tabWindow
    
                        spawn(function()
                            buttonGlow.show()
                            ts(self.icon, {0.3, 'Exponential'}, {
                                ImageColor3 = rgb(255, 255, 255)
                            })
                            ts(self.icon.TextLabel, {0.3, 'Exponential'}, {
                                TextColor3 = rgb(255, 255, 255)
                            })
    
                            repeat
                                wait()
                            until selectedTab ~= tabWindow
    
                            buttonGlow.hide()
    
                            ts(self, {0.3, 'Exponential'}, {
                                BackgroundTransparency = 1
                            })
                            ts(self.detach, {0.3, 'Exponential'}, {
                                ImageTransparency = 1
                            })
                            ts(self.icon, {0.3, 'Exponential'}, {
                                ImageColor3 = rgb(150, 150, 150)
                            })
                            ts(self.icon.TextLabel, {0.3, 'Exponential'}, {
                                TextColor3 = rgb(150, 150, 150)
                            })
                            buttonGlow.hide()
                        end)
    
                        delay(0.2, function()
                            ts(selectedTab, {0.3, 'Exponential'}, {
                                Position = udim2(0, 8, 0, 8)
                            })
                        end)
                    end)
                end
            })
    
            tabWindow = instance('ScrollingFrame', {
                Parent = body.container,
                Position = udim2(1, 0, 0, 8),
                Size = udim2(1, -16, 1, -16),
                ClipsDescendants = false,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 0,
                AutomaticCanvasSize = 'Y',
                CanvasSize = udim2(0, 0, 0, 0)
            }, {
                instance('UIListLayout', {
                    Padding = UDim.new(0, 6),
                    SortOrder = 'LayoutOrder',
                }),
                instance('TextLabel', {
                    Text = '<i>The tab has been detached\ninto a separate window.</i>',
                    RichText = true,
                    TextSize = 14,
                    Font = 'Ubuntu',
                    TextColor3 = rgb(200, 200, 200),
                    Size = udim2(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    TextTransparency = 1,
                    Visible = false,
                    Name = 'detachedStatus'
                })
            })
    
            function tabLib:Category(categoryData)
                local categoryLib = {}
                categoryData.Closed = typeof(categoryData.Closed) == 'boolean' and categoryData.Closed or true
    
                local sizeData = {
                    ['button'] = 30,
                    ['toggle'] = 26,
                }
                local realCategorySize = 30
                local categoryBody
                local toggleCategory, categoryToggled = nil,  not categoryData.Closed
    
                local categoryDetached = false
                local function detachCategory()
                    if categoryDetached then
                        return
                    end
                    categoryDetached = true
    
                    categoryBody.title.Text = ('<s><i>%s</i></s>'):format(categoryData.Name)
    
                    local det;det = createDetachment(true, categoryData.Name, {}, function(v)
                        v.Parent = categoryBody.container
                    end, function()
                        categoryDetached = false
    
                        categoryBody.title.Text = ('<i>%s</i>'):format(categoryData.Name)
    
                        ts(det, {1, 'Exponential'}, {
                            Position = udim2(0, det.AbsolutePosition.X, 2, 0)
                        })
    
                        delay(1, function()
                            det:Destroy()
                        end)
    
                        ts(categoryBody.detachStatus, {0.3, 'Exponential'}, {
                            TextTransparency = 1
                        })
    
                        delay(0.3, function()
                            categoryBody.detachStatus.Visible = false
                        end)
                    end)
    
                    for a,v in next, categoryBody.container:GetChildren() do
                        v.Parent = det.body.container
                    end
    
                    categoryBody.detachStatus.Visible = true
                    ts(categoryBody.detachStatus, {0.3, 'Exponential'}, {
                        TextTransparency = 0
                    })
    
                    det.Position = udim2(0.5, -150, 2, 0)
    
                    ts(det, {0.3, 'Exponential'}, {
                        Position = udim2(0.5, -150, 0.5, -150)
                    })
                end
    
                categoryBody = instance('Frame', {
                    Parent = tabWindow,
                    Size = udim2(1, 0, 0, 30),
                    BackgroundColor3 = rgb(40, 40, 40),
                    Name = 'category',
                    ClipsDescendants = categoryData.Closed and true or false
                }, {
                    corner(0, 10),
                    instance('TextButton', {
                        Size = udim2(1, -10, 0, 30),
                        BackgroundTransparency = 1,
                        Text = '<i>' .. categoryData.Name .. '</i>',
                        TextXAlignment = 'Left',
                        TextColor3 = rgb(200, 200, 200),
                        Position = udim2(0, 10, 0, 0),
                        Font = 'Ubuntu',
                        RichText = true,
                        TextSize = 12,
                        Name = 'title'
                    }, {
                        instance('ImageButton', {
                            Size = udim2(0, 16, 0, 14),
                            Position = udim2(1, -22, 0.5, -7),
                            Image = 'rbxassetid://12131634551',
                            ImageTransparency = 0,
                            Name = 'detach',
                            ImageColor3 = rgb(150, 150, 150),
                            BackgroundTransparency = 1,
                            BackgroundColor3 = rgb(0, 0, 0)
                        }, {corner(0, 4)}, {
                            function(self)
                                self.MouseEnter:Connect(function()
                                    ts(self, {0.3, 'Exponential'}, {
                                        BackgroundTransparency = 0.5
                                    })
                                end)
            
                                self.MouseLeave:Connect(function()
                                    ts(self, {0.3, 'Exponential'}, {
                                        BackgroundTransparency = 1
                                    })
                                end)
            
                                self.MouseButton1Down:Connect(function()
                                    detachCategory()
                                end)
                            end
                        })
                    }, {
                        function(self)
                            self.MouseButton1Down:Connect(function()
                                categoryToggled = not categoryToggled
                                toggleCategory(categoryToggled)
                            end)
                        end
                    }),
                    instance('TextLabel', {
                        Position = udim2(0, 0, 0, 30),
                        Size = udim2(1, 0, 1, -30),
                        TextTransparency = 1,
                        ClipsDescendants = true,
                        Visible = false,
                        Text = '<i>Category has been detached\ninto a separate window.</i>',
                        RichText = true,
                        Font = 'Ubuntu',
                        TextSize = 12,
                        Name = 'detachStatus',
                        TextColor3 = rgb(255, 255, 255),
                        BackgroundTransparency = 1
                    }),
                    instance('Frame', {
                        Name = 'container', 
                        Size = not categoryData.Closed and udim2(1, -12, 1, -36) or udim2(1, -12, 1, 0),
                        Position = not categoryData.Closed and udim2(0, 6, 0, 30) or udim2(0, 6, 1, 0),
                        BackgroundTransparency = 1,
                    }, {
                        instance('UIListLayout', {
                            Padding = UDim.new(0, 6),
                            SortOrder = 'LayoutOrder'
                        })
                    })
                })
    
                local categoryGlow = glow(categoryBody, 3, 1)
                categoryGlow.hide()
    
                toggleCategory = function(s)
                    ts(categoryBody, {0.3, 'Exponential'}, {
                        Size = s and udim2(1, 0, 0, realCategorySize) or udim2(1, 0, 0, 30)
                    })
    
                    categoryBody.ClipsDescendants = not s
    
                    ts(categoryBody.container, {0.3, 'Exponential'}, {
                        Size = s and udim2(1, -12, 1, -36) or udim2(1, -12, 1, 0),
                        Position = s and udim2(0, 6, 0, 30) or udim2(0, 6, 1, 0)
                    })
    
                    if s then categoryGlow.show() else categoryGlow.hide() end
                end
    
                if not categoryData.Closed then
                    categoryGlow.show()
                    categoryBody.Size = udim2(1, 0, 0, realCategorySize)
                end
    
                function categoryLib:Button(data)
                    realCategorySize = realCategorySize + (28 + 6)
                    create.button(categoryBody.container, data)
                end
    
                function categoryLib:Toggle(data)
                    realCategorySize = realCategorySize + (26 + 6)
                    create.toggle(categoryBody.container, data)
                end
    
                function categoryLib:Keybind(data)
                    realCategorySize = realCategorySize + (28 + 6)
                    create.keybind(categoryBody.container, data)
                end
    
                function categoryLib:ToggleBind(data)
                    realCategorySize = realCategorySize + (28 + 6)
                    create.togglebind(categoryBody.container, data)
                end
    
                function categoryLib:Textbox(data)
                    realCategorySize = realCategorySize + (30 + 6)
                    create.textbox(categoryBody.container, data)
                end
    
                function categoryLib:Dropdown(data)
                    realCategorySize = realCategorySize + (28 + 6)
                    return create.dropdown(categoryBody.container, data)
                end
    
                function categoryLib:Slider(data)
                    realCategorySize = realCategorySize + (45 + 6)
                    create.slider(categoryBody.container, data)
                end
    
                function categoryLib:Textlabel(data)
                    realCategorySize = realCategorySize + (26 + 6)
                    return create.textlabel(categoryBody.container, data)
                end
    
                function categoryLib:Colorpicker(data)
                    realCategorySize = realCategorySize + (30 + 6)
                    create.colorpicker(categoryBody.container, data, sgui)
                end

                function categoryLib:Locked(data)
                    realCategorySize = realCategorySize + (28 + 6)
                    create.locked(categoryBody.container, data)
                end
    
                return categoryLib
            end
    
            function tabLib:Button(data)
                create.button(tabWindow, data)
            end
    
            function tabLib:Toggle(data)
                create.toggle(tabWindow, data)
            end
    
            function tabLib:Keybind(data)
                create.keybind(tabWindow, data)
            end
    
            function tabLib:ToggleBind(data)
                create.togglebind(tabWindow, data)
            end
    
            function tabLib:Textbox(data)
                create.textbox(tabWindow, data)
            end
    
            function tabLib:Dropdown(data)
                return create.dropdown(tabWindow, data)
            end
    
            function tabLib:Slider(data)
                create.slider(tabWindow, data)
            end
    
            function tabLib:Textlabel(data)
                return create.textlabel(tabWindow, data)
            end
    
            function tabLib:Colorpicker(data)
                create.colorpicker(tabWindow, data, sgui)
            end

            function tabLib:Locked(data)
                create.locked(tabWindow, data)
            end
    
            return tabLib
        end
    
    
        return lib
    end
    
    _G.library = library
    return library
