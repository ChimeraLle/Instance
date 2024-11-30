local UDim = {}

function UDim.new(xs, xo)
    return {
        Scale = xs,
        Offset = xo
    }
end

return UDim