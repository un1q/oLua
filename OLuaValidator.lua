------------------------------------------------------------------------------
-- OLuaValidator
-- abstract class for validators
declare('OLuaValidator').abstract()
function OLuaValidator:before(args) end
function OLuaValidator:after(result, args) end
function OLuaValidator:error(errorMessage)
    if errorMessage == nil then
        error('Validation error! ')
    else
        error('Validation error! ' .. errorMessage)
    end
end


------------------------------------------------------------------------------
-- OLuaArgsValidator
-- Validator of arguments types
declare('OLuaArgsValidator').inherit('OLuaValidator')

function OLuaArgsValidator:constructor(...)
    self.expectedArgs = {...}
    table.insert(self.expectedArgs, 1, 'table') --we expect self as first argument
end

function OLuaArgsValidator:errorMessage (arguments)
    local str_expectedArgs = table.concat(self.expectedArgs, ",")
    local str_args = ""
    for j,v in ipairs(arguments) do 
        if j>1 then str_args = str_args .. "," end
        str_args = str_args .. type(v)
    end
    return string.format("Wrong arguments' types. Expected: %s, was:%s",str_expectedArgs, str_args)
end

function OLuaArgsValidator:before (...)
    local arguments = {...}
    if #arguments ~= #self.expectedArgs then
        self:error(self:errorMessage(arguments))
    end
    if self.expectedArgs ~= nil then
        for i,str_expectedArg in ipairs(self.expectedArgs) do
            if not(OLua.isInstanceOf(arguments[i], str_expectedArg)) then
                self:error(self:errorMessage(arguments))
            end
        end
    end
end

OLua.addValidator('args', OLuaArgsValidator)

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

function OLuaResultValidator:after(result, ...)
    if self.expectedType ~= nil then
        if not(OLua.isInstanceOf(result, self.expectedType)) then
            self:error(string.format("Wrong result's type. Expected: %s, was: %s", self.expectedType, type(result)))
        end
    end
end

OLua.addValidator('result', OLuaResultValidator)

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
