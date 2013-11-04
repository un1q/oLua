------------------------------------------------------------------------------
-- OLuaBeforeValidator
-- Validation before function runs
declare('OLuaBeforeValidator').inherit('OLuaValidator')

function OLuaBeforeValidator:constructor(validationFunction)
    if type(validationFunction) ~= 'function' then 
        error("Wrong argument's type. Expected type: function, was: " + type(validationFunction))
    end
    self.validationFunction = validationFunction
end

function OLuaBeforeValidator:before(...)
    if self.validationFunction ~= nil then
        self.validationFunction(...)
    end
end

OLua.addValidator('before', OLuaBeforeValidator)
