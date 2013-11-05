------------------------------------------------------------------------------
-- OLuaArgsValidator
-- Validator of arguments types
declare('OLuaArgsValidator').inherit('OLuaValidator')

function OLuaArgsValidator:constructor(...)
    self.expectedArgs = {...}
    table.insert(self.expectedArgs, 1, 'table') --we expect self as first argument
end

function OLuaArgsValidator:errorMessage (arguments)
    --local str_expectedArgs = table.concat(self.expectedArgs, ",")
    local str_expectedArgs = ""
    for j,v in ipairs(self.expectedArgs) do 
        if j>1 then str_expectedArgs = str_expectedArgs .. "," end
        if type(v) == 'string' then
            str_expectedArgs = str_expectedArgs .. v
        else
            str_expectedArgs = str_expectedArgs .. '[ ' .. type(v) .. ' validator]'
        end
    end
    local str_args = ""
    for j,v in ipairs(arguments) do 
        if j>1 then str_args = str_args .. "," end
        str_args = str_args .. type(v)
        if type(v) == "string" then
            str_args = str_args .. '["'.. v ..'"]'
        end
    end
    return string.format("Wrong arguments' types. Expected: %s, was:%s",str_expectedArgs, str_args)
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
                    self:error(str_typeName, functionName, self:errorMessage(arguments))
                end
            elseif validatorType == "table" then
                if not(OLuaArgsValidator.tableContain(expectedArg, arguments[i])) then
                    self:error(str_typeName, functionName, self:errorMessage(arguments))
                end
            elseif validatorType == "function" then
                if not(expectedArg(arguments[i])) then
                    self:error(str_typeName, functionName, self:errorMessage(arguments))
                end
            else
                error("Wrong OLuaArgsValidator argument type: " .. validatorType .. " (use string, table or function)")
            end
        end
    end
end

OLua.addValidator('args', OLuaArgsValidator)
