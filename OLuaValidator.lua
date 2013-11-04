------------------------------------------------------------------------------
-- OLuaValidator
-- abstract class for validators
declare('OLuaValidator').abstract()
function OLuaValidator:before(str_typeName, functionName, args) end
function OLuaValidator:after(str_typeName, functionName, args, result) end
function OLuaValidator:error(str_typeName, functionName, errorMessage)
    if errorMessage == nil then
        error('Validation error! ')
    else
        error(string.format('Validation error in function %s:%s(...)! %s', str_typeName, functionName, errorMessage))
    end
end

