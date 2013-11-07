------------------------------------------------------------------------------
-- OLuaArgsTypesValidator
-- Validator of arguments types
declare('OLuaArgsTypesValidator').inherit('OLuaValidator')

function OLuaArgsTypesValidator:constructor(...)
    self.expectedArgs = {...}
    table.insert(self.expectedArgs, 1, 'table') --we expect self as first argument
end

function OLuaArgsTypesValidator:errorMessage (arguments, argNumber)
    local str_expectedArgs = ""
    for j,v in ipairs(self.expectedArgs) do 
        if j>1 then str_expectedArgs = str_expectedArgs .. "," end
        if type(v) == 'string' then
            str_expectedArgs = str_expectedArgs .. v
        elseif type(v) == 'table' then
            str_expectedArgs = str_expectedArgs .. '[ table validator: {'..table.concat(v,',')..'}]'
        else
            error('Unexpected type')
        end
    end
    local str_args = ""
    for j,v in ipairs(arguments) do 
        if j>1 then str_args = str_args .. "," end
        if type(v) == "string" then
            str_args = str_args .. '"'.. v ..'"'
        else
            str_args = str_args .. type(v)
        end
    end
    if argNumber == nil then
        return string.format("Wrong arguments. Expected: %s, was:%s",str_expectedArgs, str_args)
    else
        return string.format("Wrong %s argument's type. Expected: %s, was:%s",argNumber, str_expectedArgs, str_args)
    end
end

function OLuaArgsTypesValidator:isInstanceOfOneOfTable(value, t)
    for _,v in ipairs(t) do
        if OLua.isInstanceOf(value,v) then
            return true
        end
    end
    return false
end

function OLuaArgsTypesValidator:before (str_typeName, functionName, arguments)
    if #arguments > #self.expectedArgs then
        self:error(str_typeName, functionName, self:errorMessage(arguments, #expectedArgs+1))
    end
    if self.expectedArgs ~= nil then
        for i,expectedArg in ipairs(self.expectedArgs) do
            local validatorType = type(expectedArg)
            if validatorType == "string" then
                if not(OLua.isInstanceOf(arguments[i], expectedArg)) then
                    self:error(str_typeName, functionName, self:errorMessage(arguments,i))
                end
            elseif validatorType == "table" then
                if not(OLuaArgsTypesValidator:isInstanceOfOneOfTable(arguments[i], expectedArg)) then
                    self:error(str_typeName, functionName, self:errorMessage(arguments,i))
                end
            else
                error("Wrong OLuaArgsTypesValidator argument type: " .. validatorType .. " (use string or table)")
            end
        end
    end
end

OLua.addValidator('argsTypes', OLuaArgsTypesValidator)
