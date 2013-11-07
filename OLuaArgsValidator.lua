------------------------------------------------------------------------------
-- OLuaArgsValidator
-- Validator of arguments
declare('OLuaArgsValidator').inherit('OLuaValidator')

function OLuaArgsValidator:constructor(...)
    self.expectedArgs = {...}
    table.insert(self.expectedArgs, 1, 'table') --we expect self as first argument
end

function OLuaArgsValidator:tableToString(t)
    local result = {}
    for _,v in ipairs(t) do
        if type(v) == 'string' or type(v) == 'number' then
            table.insert(result, '"'..tostring(v)..'"')
        else
            table.insert(result, type(v))
        end
    end
    return table.concat(result, ',')
end

function OLuaArgsValidator:errorMessage (arguments, argNumber)
    --local str_expectedArgs = table.concat(self.expectedArgs, ",")
    local str_expectedArgs = ""
    for j,v in ipairs(self.expectedArgs) do 
        if j>1 then str_expectedArgs = str_expectedArgs .. "," end
        if type(v) == 'string' then
            str_expectedArgs = str_expectedArgs .. v
        elseif type(v) == 'table' then
            str_expectedArgs = str_expectedArgs .. '[ table validator: {'..OLuaArgsValidator:tableToString(v)..'}]'
        else
            str_expectedArgs = str_expectedArgs .. '[ ' .. type(v) .. ' validator]'
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
        return string.format("Wrong arguments (argument number: %s). Expected: %s, was:%s",argNumber, str_expectedArgs, str_args)
    end
end

function OLuaArgsValidator:tableContain(t,value)
    for _,v in ipairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

function OLuaArgsValidator:before (str_typeName, functionName, arguments)
    if #arguments ~= #self.expectedArgs then
        self:error(str_typeName, functionName, self:errorMessage(arguments))
    end
    if self.expectedArgs ~= nil then
        for i,expectedArg in ipairs(self.expectedArgs) do
            local validatorType = type(expectedArg)
            if validatorType == "string" then
                if not(OLua.isInstanceOf(arguments[i], expectedArg)) then
                    self:error(str_typeName, functionName, self:errorMessage(arguments,i))
                end
            elseif validatorType == "table" then
                if not(OLuaArgsValidator:tableContain(expectedArg, arguments[i])) then
                    self:error(str_typeName, functionName, self:errorMessage(arguments,i))
                end
            elseif validatorType == "function" then
                if not(expectedArg(arguments[i])) then
                    self:error(str_typeName, functionName, self:errorMessage(arguments,i))
                end
            else
                error("Wrong OLuaArgsValidator argument type: " .. validatorType .. " (use string, table or function)")
            end
        end
    end
end

OLua.addValidator('args', OLuaArgsValidator)
