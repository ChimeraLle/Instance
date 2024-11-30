local Instance, wait = unpack(require("Instance"))
local UDim = require("UDim")
local Vector2 = require("Vector2")
local UDim2 = require("UDim2")
local Color3 = require("Color3")
local Enum = require("Enum")

-- use wait like this `wait(<seconds>, <callback>)`

function love.load()

    -- Code Here
    -- Example

    local Frame = Instance.new("Frame")
    Frame.BackgroundColor3 = Color3.new(1, 0, 0)
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.Position = UDim2.new(0, 0, 0, 0)

end