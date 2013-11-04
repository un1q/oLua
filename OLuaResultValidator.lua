------------------------------------------------------------------------------
-- OLuaResultValidator
-- Validator of result type
declare('OLuaResultValidator').inherit('OLuaValidator')

function OLuaResultValidator:constructor(expectedType)
    if type(expectedType) ~= 'string' then 
        error("Wrong argument's type. Expected type: string, was: " + type(expectedType))
    end
    self.expectedType = expectedType
end

function OLuaResultValidator:after(str_typeName, functionName, args, result)
    if self.expectedType ~= nil then
        if not(OLua.isInstanceOf(result, self.expectedType)) then
            self:error(str_typeName, functionName, string.format("Wrong result's type. Expected: %s, was: %s", self.expectedType, type(result)))
        end
    end
end

OLua.addValidator('returns', OLuaResultValidator)

