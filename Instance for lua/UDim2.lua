local UDim2 = {}

local UDim = require("UDim")

function UDim2.new(xs, xo, ys, yo)
    return {
        X = UDim.new(xs, xo),
        Y = UDim.new(ys, yo)
    }
end

return UDim2