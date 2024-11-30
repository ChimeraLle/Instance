local Instance = {}

local UDim2 = require("UDim2")
local Color3 = require("Color3")
local Vector2 = require("Vector2")
local Enum = require("Enum")
local Signal = require("Signal")
local UDim = require("UDim")
local guiobjects = {}

local function ScaleToOffsetX(udim, parent)
    return udim.Scale * (parent and parent.AbsoluteSize.X or love.graphics.getWidth()) + udim.Offset
end

local function ScaleToOffsetY(udim, parent)
    return udim.Scale * (parent and parent.AbsoluteSize.Y or love.graphics.getHeight()) + udim.Offset
end

local function GetChildren(obj)
    local children = {}
    for _, object in ipairs(guiobjects) do
        if object.Parent == obj then
            table.insert(children, object)
        end
    end
    return children
end

local editingtextbox = nil

local function HowManyLineInString(str)
    local lines = 1
    local latestline = ""
    for i = 1, #str do
        if str:sub(i, i) == "\n" then
            lines = lines + 1
            latestline = ""
        else
            latestline = latestline .. str:sub(i, i)
        end
    end
    return lines, latestline
end

local function GetLineString(str, num)
    local lines = str:split("\n")
    return lines[num]
end

function love.draw()
    love.keyboard.setKeyRepeat(true)
    for _, object in ipairs(guiobjects) do
        if object.ClassName ~= "UICorner" then
            local Parent = object.Parent
            local PosX = ScaleToOffsetX(object.Position.X, Parent)
            local PosY = ScaleToOffsetY(object.Position.Y, Parent)
            local SizeX = ScaleToOffsetX(object.Size.X, Parent)
            local SizeY = ScaleToOffsetY(object.Size.Y, Parent)
            if Parent then
                PosX = PosX + Parent.AbsolutePosition.X
                PosY = PosY + Parent.AbsolutePosition.Y
                love.graphics.setColor(object.BackgroundColor3)
                love.graphics.rectangle("fill", PosX, PosY, SizeX, SizeY)
            else
                local UICorner = nil
                for _, child in ipairs(object:GetChildren()) do
                    if child.ClassName == "UICorner" then
                        UICorner = child
                        break
                    end
                end
                love.graphics.setColor(object.BackgroundColor3)
                if UICorner then
                    local radiusX = ScaleToOffsetX(UICorner.CornerRadius, object)
                    local radiusY = ScaleToOffsetY(UICorner.CornerRadius, object)
                    love.graphics.rectangle("fill", PosX + (radiusX / 2) , PosY, SizeX - radiusX, SizeY)
                    love.graphics.rectangle("fill", PosX, PosY + (radiusY / 2), radiusX / 2, SizeY - radiusY)
                    love.graphics.rectangle("fill", PosX + SizeX - (radiusX / 2), PosY + (radiusY / 2), radiusX / 2, SizeY - radiusY)
                    love.graphics.arc("fill", PosX + (radiusX / 2), PosY + (radiusY / 2), radiusX / 2, math.pi, 1.5 * math.pi, 100)
                    love.graphics.arc("fill", PosX + SizeX - (radiusX / 2), PosY + (radiusY / 2), radiusX / 2, 1.5 * math.pi, 2 * math.pi, 100)
                    love.graphics.arc("fill", PosX + SizeX - (radiusX / 2), PosY + SizeY - (radiusY / 2), radiusX / 2, 0, 0.5 * math.pi, 100)
                    love.graphics.arc("fill", PosX + (radiusX / 2), PosY + SizeY - (radiusY / 2), radiusX / 2, 0.5 * math.pi, math.pi, 100)
                else
                    love.graphics.rectangle("fill", PosX, PosY, SizeX, SizeY)
                end 
            end
            if object.ClassName == "TextLabel" or object.ClassName == "TextButton" or object.ClassName == "TextBox" then
                love.graphics.setColor(object.TextColor3)
                love.graphics.setFont(love.graphics.newFont(object.TextSize))
                if object.TextScaled then
                    love.graphics.setFont(love.graphics.newFont(SizeX / 7.5))
                else
                    love.graphics.setFont(love.graphics.newFont(object.TextSize))
                end
                local function GetTextX()
                    if object.TextXAlignment == Enum.TextXAlignment.Center then
                        return PosX + (SizeX / 2) - (love.graphics.getFont():getWidth(object.Text) / 2)
                    elseif object.TextXAlignment == Enum.TextXAlignment.Left then
                        return PosX
                    elseif object.TextXAlignment == Enum.TextXAlignment.Right then
                        return PosX + SizeX - love.graphics.getFont():getWidth(object.Text)
                    end
                end
                local function GetTextY()
                    if object.TextYAlignment == Enum.TextYAlignment.Center then
                        return PosY + (SizeY / 2) - (love.graphics.getFont():getHeight() / 2)
                    elseif object.TextYAlignment == Enum.TextYAlignment.Top then
                        return PosY
                    elseif object.TextYAlignment == Enum.TextYAlignment.Bottom then
                        return PosY + SizeY - love.graphics.getFont():getHeight()
                    end
                end
                love.graphics.print(object.Text, GetTextX(), GetTextY())
                if object.ClassName == "TextButton" then
                    if love.mouse.isDown(1) and not object.isDown then
                        if love.mouse.getX() > PosX and love.mouse.getX() < PosX + SizeX and love.mouse.getY() > PosY and love.mouse.getY() < PosY + SizeY then
                            object.isDown = true
                            object.MouseButton1Down:Fire()
                            object.MouseButton1Click:Fire()
                        end
                    elseif not love.mouse.isDown(1) and object.isDown then
                        object.isDown = false
                        if love.mouse.getX() > PosX and love.mouse.getX() < PosX + SizeX and love.mouse.getY() > PosY and love.mouse.getY() < PosY + SizeY then
                            object.MouseButton1Up:Fire()
                        end
                    end
                    if love.mouse.getX() > PosX and love.mouse.getX() < PosX + SizeX and love.mouse.getY() > PosY and love.mouse.getY() < PosY + SizeY then
                        local MousePosX = love.mouse.getX()
                        local MousePosY = love.mouse.getY()
                        if MousePosX ~= object.LatestMousePos.X or MousePosY ~= object.LatestMousePos.Y then
                            object.LatestMousePos = Vector2.new(MousePosX, MousePosY)
                            object.MouseMoved:Fire(MousePosX, MousePosY)
                        end
                    end
                elseif object.ClassName == "TextBox" then
                    if love.mouse.isDown(1) and not object.IsDown then
                        object.IsDown = true
                        if love.mouse.getX() > PosX and love.mouse.getX() < PosX + SizeX and love.mouse.getY() > PosY and love.mouse.getY() < PosY + SizeY then
                            if not editingtextbox then
                                object.Focused:Fire()
                                if object.ClearTextOnFocus then
                                    object.Text = ""
                                end
                                editingtextbox = object
                            end
                        else
                            if editingtextbox == object then
                                object.FocusLost:Fire()
                                editingtextbox = nil
                            end
                        end
                    elseif not love.mouse.isDown(1) and object.IsDown then
                        object.IsDown = false
                    end
                    if editingtextbox == object then
                        local FontSizeY = love.graphics.getFont():getHeight()
                        local hmlines, latestline = HowManyLineInString(object.Text:sub(1, object.CursorPosition))
                        local cursorX = love.graphics.getFont():getWidth(latestline)
                        local cursorY = FontSizeY * hmlines
                        love.graphics.line(
                            PosX + GetTextX() + cursorX, 
                            PosY + GetTextY() - object.AbsolutePosition.Y + (cursorY - FontSizeY), 
                            PosX + GetTextX() + cursorX, 
                            PosY + GetTextY() - object.AbsolutePosition.Y + cursorY
                        )
                    end
                end
            end 
        end
    end
end

function love.textinput(t)
    if editingtextbox then
        local beforeCursor = editingtextbox.Text:sub(1, editingtextbox.CursorPosition)
        local afterCursor = editingtextbox.Text:sub(editingtextbox.CursorPosition + 1)
        editingtextbox.Text = beforeCursor .. t .. afterCursor
        editingtextbox.CursorPosition = editingtextbox.CursorPosition + 1
    end
end

function love.keypressed(key)
    if editingtextbox then
        if key == "backspace" and editingtextbox.CursorPosition > 0 then
            local beforeCursor = editingtextbox.Text:sub(1, editingtextbox.CursorPosition - 1)
            local afterCursor = editingtextbox.Text:sub(editingtextbox.CursorPosition + 1)
            editingtextbox.Text = beforeCursor .. afterCursor
            editingtextbox.CursorPosition = editingtextbox.CursorPosition - 1
        elseif key == "left" and editingtextbox.CursorPosition > 0 then
            editingtextbox.CursorPosition = editingtextbox.CursorPosition - 1
        elseif key == "right" and editingtextbox.CursorPosition < #editingtextbox.Text then
            editingtextbox.CursorPosition = editingtextbox.CursorPosition + 1
        elseif key == "return" then
            if editingtextbox.MultiLine then
                local beforeCursor = editingtextbox.Text:sub(1, editingtextbox.CursorPosition)
                local afterCursor = editingtextbox.Text:sub(editingtextbox.CursorPosition + 1)
                editingtextbox.Text = beforeCursor .. "\n" .. afterCursor
                editingtextbox.CursorPosition = editingtextbox.CursorPosition + 1
            else
                editingtextbox.FocusLost:Fire()
                editingtextbox = nil
            end
        end
    end
end

local waiting = {}

function love.update(dt)
    for _, object in ipairs(waiting) do
        if love.timer.getTime() - object.Start >= object.Seconds then
            if object.Callback then
                object.Callback()
            end
            table.remove(waiting, i)
        end
    end
    for _, object in ipairs(guiobjects) do
        if object.ClassName ~= "UICorner" then
            local Parent = object.Parent
            local SizeX = ScaleToOffsetX(object.Size.X, Parent)
            local SizeY = ScaleToOffsetY(object.Size.Y, Parent)
            local PosX = ScaleToOffsetX(object.Position.X, Parent)
            local PosY = ScaleToOffsetY(object.Position.Y, Parent)
            local AbsPosX = PosX + (Parent and Parent.AbsolutePosition.X or 0)
            local AbsPosY = PosY + (Parent and Parent.AbsolutePosition.Y or 0)
            object.AbsoluteSize = Vector2.new(SizeX, SizeY)
            object.AbsolutePosition = Vector2.new(AbsPosX, AbsPosY)
        end
    end
end

function Instance.new(class, parent)
    local Main = {
        Parent = parent,
        ClassName = class,
    }
    function Main:GetChildren()
        return GetChildren(Main)
    end
    if class == "Frame" then
        Main.Size = UDim2.new(0, 100, 0, 100)
        Main.Position = UDim2.new(0, 0, 0, 0)
        Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Main.AbsoluteSize = Vector2.new(100, 100)
        Main.AbsolutePosition = Vector2.new(0, 0)
        table.insert(guiobjects, Main)
        return Main
    elseif class == "TextLabel" then
        Main.Size = UDim2.new(0, 100, 0, 100)
        Main.Position = UDim2.new(0, 0, 0, 0)
        Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Main.AbsoluteSize = Vector2.new(100, 100)
        Main.AbsolutePosition = Vector2.new(0, 0)
        Main.Text = ""
        Main.TextColor3 = Color3.new(1, 1, 1)
        Main.TextSize = 16
        Main.TextXAlignment = Enum.TextXAlignment.Center
        Main.TextYAlignment = Enum.TextYAlignment.Center
        Main.TextScaled = false
        table.insert(guiobjects, Main)
        return Main
    elseif class == "TextButton" then
        Main.Size = UDim2.new(0, 100, 0, 100)
        Main.Position = UDim2.new(0, 0, 0, 0)
        Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Main.AbsoluteSize = Vector2.new(100, 100)
        Main.AbsolutePosition = Vector2.new(0, 0)
        Main.Text = ""
        Main.TextColor3 = Color3.new(1, 1, 1)
        Main.TextSize = 16
        Main.TextXAlignment = Enum.TextXAlignment.Center
        Main.TextYAlignment = Enum.TextYAlignment.Center
        Main.MouseButton1Click = Signal.new()
        Main.MouseButton1Down = Signal.new()
        Main.MouseButton1Up = Signal.new()
        Main.MouseMoved = Signal.new()
        Main.LatestMousePos = Vector2.new(0, 0)
        Main.isDown = false
        Main.TextScaled = false
        table.insert(guiobjects, Main)
        return Main
    elseif class == "UICorner" then
        Main.CornerRadius = UDim.new(0, 8)
        table.insert(guiobjects, Main)
        return Main
    elseif class == "TextBox" then
        Main.Size = UDim2.new(0, 100, 0, 100)
        Main.Position = UDim2.new(0, 0, 0, 0)
        Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Main.AbsoluteSize = Vector2.new(100, 100)
        Main.AbsolutePosition = Vector2.new(0, 0)
        Main.Text = ""
        Main.TextColor3 = Color3.new(1, 1, 1)
        Main.TextSize = 16
        Main.TextXAlignment = Enum.TextXAlignment.Center
        Main.TextYAlignment = Enum.TextYAlignment.Center
        Main.TextScaled = false
        Main.CursorPosition = 1
        Main.IsDown = false
        Main.Focused = Signal.new()
        Main.FocusLost = Signal.new()
        Main.ClearTextOnFocus = true
        Main.MultiLine = false
        table.insert(guiobjects, Main)
        return Main
    end
end

local function wait(seconds, callback)
    table.insert(waiting, {
        Start = love.timer.getTime(),
        Seconds = seconds,
        Callback = callback
    })
end

return {Instance, wait}