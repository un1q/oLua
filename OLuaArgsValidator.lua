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

function OLuaArgsValidator:before (str_typeName, functionName, arguments)
    if #arguments ~= #self.expectedArgs then
        self:error(str_typeName, functionName, self:errorMessage(arguments))
    end
    if self.expectedArgs ~= nil then
        for i,str_expectedArg in ipairs(self.expectedArgs) do
            if not(OLua.isInstanceOf(arguments[i], str_expectedArg)) then
                self:error(str_typeName, functionName, self:errorMessage(arguments))
            end
        end
    end
end

OLua.addValidator('args', OLuaArgsValidator)
