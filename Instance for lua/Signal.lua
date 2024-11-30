local Signal = {}

Signal.new = function()
    local self = {}
    self.Connections = {}
    function self:Connect(callback)
        table.insert(self.Connections, callback)
    end
    function self:Fire(...)
        for _, callback in ipairs(self.Connections) do
            callback(...)
        end
    end
    return self
end

return Signal