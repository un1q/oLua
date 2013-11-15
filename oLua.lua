------------------------------------------------------------------------------
-- validate
-- usage: validate.someClass.someFunction[.args('type','type',...)][.returns('type')][.override()]...
validate = {
}
setmetatable(validate, {__index = 
    function (validate, className)
        local classValidators = {}
        validate[className] = classValidators
        setmetatable(classValidators, {__index = 
            function (classValidators, functionName)
                local functionValidators = {}
                classValidators[functionName] = functionValidators
                setmetatable(functionValidators, {__index =
                    function(functionValidators, validatorName)
                        local validator = OLua.getValidator(validatorName)
                        if validator == nil then
                            error('Unknown validator: ' .. validatorName)
                        end
                        return function(...)
                            rawset(functionValidators, validatorName, validator.new(...))
                            return functionValidators
                        end
                    end
                })
                return functionValidators
            end
        })
        return classValidators
    end
})

------------------------------------------------------------------------------
-- OLua
-- static functions used by OLua library
OLua = {
    validators = {}
}

function OLua.shalowCopy(object)
    if object ~= 'table' then
        return object
    end
    local copy = {}
    for k,v in pairs(object) do
        copy[k]=v
    end
    return copy
end

function OLua.require(className)
    if rawget(_G,className) == nil then
        require(className)
    end
end

--check if object is instance of class or type
function OLua.isInstanceOf(object, str_expectedType)
    local str_objectType = type(object);
    if str_objectType == str_expectedType then
        return true;
    end;
    if (str_expectedType == 'nil'
        or str_expectedType == 'boolean'
        or str_expectedType == 'number' 
        or str_expectedType == 'string' 
        or str_expectedType == 'userdata' 
        or str_expectedType == 'function' 
        or str_expectedType == 'thread' 
        or str_expectedType == 'table')
    then 
        return false;
    end
    if (str_objectType ~= 'table')
    then 
        return false;
    end
    if object.__type == str_expectedType then
        return true;
    end;
    while object.__super do
        object = object.__super
        if object.__type == str_expectedType then
            return true;
        end;
    end;
    return false;
end

function OLua.addValidator(name, validatorClass)
    if OLua.validators[name] ~= nil then
        error('Validator already exists: ' .. name)
    end
    OLua.validators[name] = validatorClass
end

function OLua.getValidator(name)
    return OLua.validators[name]
end

function OLua.getFunctionValidators(className, functionName)
    local classValidators = rawget(validate, className)
    if classValidators == nil then return nil end
    return rawget(classValidators, functionName)
end

------------------------------------------------------------------------------
-- Promote table to an object of some class
-- Arguments:
--  object - mandatory - some table
--  class - mandatory - class, object will be promoted to
-- Returns:
--  object
function OLua.promote(object, class)
    return class.__promote(object) 
end
------------------------------------------------------------------------------
-- Declare a new class
-- Arguments:
--  str_newClassName - mandatory - name of new class (string)
--  upperClass - optional - table that contain the class (nil or table) - default: _G
-- Returns:
--  .inherit(class)
function declare(str_newClassName, upperClass)
    local str_typeName = str_newClassName
    if upperClass == nil then
        upperClass = _G
    else
        str_typeName = upperClass.__type .. '.' .. str_newClassName
    end
    -- a body of the class:
    local definition = {
        declare = function(str_subclassName)
            return declare(str_subclassName, upperClass[str_newClassName])
        end,
        -- default constructor
        constructor = function() end ,
        -- create new object of the class
        new = function(...)
            local object = {}
            setmetatable(object, {__index = upperClass[str_newClassName]})
            object:constructor(...)
            return object
        end ,
        __promote = function(baseTable, ...)
            local object = baseTable
            setmetatable(object, {__index = upperClass[str_newClassName]})
            object:constructor(...)
            return object
        end ,
        __type = str_typeName
    }
    rawset(upperClass, str_newClassName, definition)
    -- sometimes we need to wrap functions with some validations
    setmetatable(definition, {__newindex = 
        function (definition, key, value)
            if type(value) == "function" then
                local validators = OLua.getFunctionValidators(str_typeName, key)
                if validators == nil then
                    rawset(definition, key, value)
                else
                    local validateFunction = function (...)
                        local validators = OLua.getFunctionValidators(str_typeName, key)
                        for _,validator in pairs(validators) do
                            validator:before(str_typeName, key, {...})
                        end
                        local result = value(...)
                        for _,validator in pairs(validators) do
                            validator:after(str_typeName, key, {...}, result)
                            return result
                        end
                    end
                    rawset(definition, key, validateFunction)
                end
            else
                rawset(definition, key, value)
            end
        end
    })
    -- in case, somebody want to use this kind of syntax:
    -- declare(SomeClassName).inherit(SomeOtherClass)
    -- declare(SomeClassName).abstract()
    local classModificators = {}
    function classModificators.inherit(str_base)
        upperClass[str_newClassName].__super = upperClass[str_base]
        upperClass[str_newClassName].constructor = function(self, ...)
            self.__super.constructor(self,...)
        end
        setmetatable(upperClass[str_newClassName], {__index = upperClass[str_base]})
        return classModificators
    end
    function classModificators.abstract()
        rawset(upperClass[str_newClassName], 'new', function(...) error('You cannot create object of abstract class ' .. upperClass[str_newClassName]) end )
        return classModificators
    end
    return classModificators
end
--from now on, only classes can be global
setmetatable(_G, {
    --from now on, only classes can be global
    __newindex = function(_, className)
        error("Globals are disabled. Only class definitions can be global. Expected: declare(" .. className .."), was:" .. className)
    end,
    --from now on, only classes can be global
    __index = function(_, className)
        error("This global variable (class definition?) is not declared: " .. className)
    end
})
------------------------

OLua.require('OLuaValidator')
OLua.require('OLuaArgsValidator')
OLua.require('OLuaReturnsValidator')
OLua.require('OLuaBeforeValidator')
OLua.require('OLuaAfterValidator')
OLua.require('OLuaArgsTypesValidator')