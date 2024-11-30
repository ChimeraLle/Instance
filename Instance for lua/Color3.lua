local Color3 = {}

function Color3.new(r, g, b)
    return {r, g, b}
end

function Color3.fromRGB(r, g, b)
    return Color3.new(r / 255, g / 255, b / 255)
end

return Color3