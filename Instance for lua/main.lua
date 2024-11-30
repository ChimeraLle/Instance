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

    local TextBox = Instance.new("TextBox")
    TextBox.Text = "Change"
    TextBox.TextColor3 = Color3.new(0, 0 ,0)
    TextBox.Size = UDim2.new(0, 200, 0, 200)
    TextBox.Position = UDim2.new(0, 0, 0.5, 50)
    TextBox.ClearTextOnFocus = false
    TextBox.MultiLine = true
    TextBox.TextXAlignment = Enum.TextXAlignment.Left
    TextBox.TextYAlignment = Enum.TextYAlignment.Top

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Text = "Change"
    TextLabel.BackgroundColor3 = Color3.new(0, 0, 1)
    TextLabel.Size = UDim2.new(0, 100, 0, 100)
    TextLabel.Position = UDim2.new(0.5, -50, 0.5, -50)

    local i = 0

    TextBox.Focused:Connect(function()
        i = i + 1
        TextLabel.Text = "Focused " .. i
    end)

    TextBox.FocusLost:Connect(function()
        i = i + 1
        TextLabel.Text = "FocusLost " .. i
    end)

end