local Instance = {}

local UDim2 = require("UDim2")
local Color3 = require("Color3")
local Vector2 = require("Vector2")
local Enum = require("Enum")
local Signal = require("Signal")

local guiobjects = {}

local function ScaleToOffsetX(udim, parent)
    return udim.Scale * (parent and parent.AbsoluteSize.X or love.graphics.getWidth()) + udim.Offset
end

local function ScaleToOffsetY(udim, parent)
    return udim.Scale * (parent and parent.AbsoluteSize.Y or love.graphics.getHeight()) + udim.Offset
end

function love.draw()
    for _, object in ipairs(guiobjects) do
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
            love.graphics.setColor(object.BackgroundColor3)
            love.graphics.rectangle("fill", PosX, PosY, SizeX, SizeY)
        end
        if object.ClassName == "TextLabel" or object.ClassName == "TextButton" then
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
                        object.MouseButton1Click:Fire()
                    end
                elseif not love.mouse.isDown(1) and object.isDown then
                    object.isDown = false
                end
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

function Instance.new(class, parent)
    local Main = {
        Size = UDim2.new(0, 100, 0, 100),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        AbsoluteSize = Vector2.new(100, 100),
        AbsolutePosition = Vector2.new(0, 0),
        Parent = parent,
        ClassName = class,
        TextScaled = false
    }
    if class == "Frame" then
        table.insert(guiobjects, Main)
        return Main
    elseif class == "TextLabel" then
        Main.Text = ""
        Main.TextColor3 = Color3.new(1, 1, 1)
        Main.TextSize = 16
        Main.TextXAlignment = Enum.TextXAlignment.Center
        Main.TextYAlignment = Enum.TextYAlignment.Center
        table.insert(guiobjects, Main)
        return Main
    elseif class == "TextButton" then
        Main.Text = ""
        Main.TextColor3 = Color3.new(1, 1, 1)
        Main.TextSize = 16
        Main.TextXAlignment = Enum.TextXAlignment.Center
        Main.TextYAlignment = Enum.TextYAlignment.Center
        Main.MouseButton1Click = Signal.new()
        Main.isDown = false
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