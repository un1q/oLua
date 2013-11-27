------------------------------------------------------------------------------
-- OLuaReturnsValidator
-- Validator of result's type
declare('OLuaReturnsValidator').inherit('OLuaValidator')

function OLuaReturnsValidator:constructor(expectedType)
    if type(expectedType) ~= 'string' then 
        error("Wrong argument's type. Expected type: string, was: " .. type(expectedType))
    end
    self.expectedType = expectedType
end

function OLuaReturnsValidator:after(str_typeName, functionName, args, returns)
    if self.expectedType ~= nil then
        if not(OLua.isInstanceOf(returns, self.expectedType)) then
            self:error(str_typeName, functionName, string.format("Wrong result's type. Expected: %s, was: %s", self.expectedType, type(returns)))
        end
    end
end

OLua.addValidator('returns', OLuaReturnsValidator)

