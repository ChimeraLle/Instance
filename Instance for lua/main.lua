local Instance, wait = unpack(require("Instance"))
local UDim2 = require("UDim2")
local Color3 = require("Color3")
local Enum = require("Enum")

function love.load()

    local Frame = Instance.new("ImageLabel")
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Frame.Size = UDim2.new(0, 100, 0, 100) 
    Frame.Image = "rbxassetid://15011943540"


end