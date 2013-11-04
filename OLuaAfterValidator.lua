------------------------------------------------------------------------------
-- OLuaAfterValidator
-- Validation after function runs
declare('OLuaAfterValidator').inherit('OLuaValidator')

function OLuaAfterValidator:constructor(validationFunction)
    if type(validationFunction) ~= 'function' then 
        error("Wrong argument's type. Expected type: function, was: " + type(validationFunction))
    end
    self.validationFunction = validationFunction
end

function OLuaAfterValidator:after(...)
    if self.validationFunction ~= nil then
        self.validationFunction(...)
    end
end

OLua.addValidator('after', OLuaAfterValidator)

