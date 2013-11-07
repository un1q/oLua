require 'oLua'

declare("Enum").abstract()
Enum.values = {}
Enum.value = nil

function Enum:constructor(value) 
    if self.values == nil then
        error ("Enum class should have values defined. Use ClassName.values = {...} before first object creation.")
    end
    if #self.values == 0 then
        error ("Enum class should have at least one value.")
    end
    if value == nil then
        self:setValue(self.values[1])
    else
        self:setValue(value)
    end
end

validate.Enum.validate.args('string')
function Enum:validate(value)
    if not(self:contains(value)) then
        error(value .. " is not proper for this Enum")
    end
end

validate.Enum.contains.args('string')
function Enum:contains(value)
    for _,v in ipairs(self.values) do
        if v == value then
            return true
        end
    end
    return false
end

validate.Enum.setValue.args('string') 
function Enum:setValue(value)
    self:validate(value)
    self.value = value
end

function Enum:getValue()
    return self.value
end
