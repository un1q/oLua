function __changeToEnum(class, tab_table)
	class.__enum = {}
	for k,v in pairs(tab_table) do
		if type(k) == 'number' then
			class[v] = v
			class.__enum[v] = v
		else
			class[k] = v
			class.__enum[k] = v
		end
	end
	return class
end

function enum(tab_table)
	return __changeToEnum({}, tab_table)
end

function declare(str_newClassName, parentClass)
	local str_typeName = str_newClassName
	if parentClass == nil then
		parentClass = _G
	else
		str_typeName = parentClass.__type .. '.' .. str_newClassName
	end
	-- body of the class
	local definition = {
		declare = function(str_subclassName)
			return declare(str_subclassName, parentClass[str_newClassName])
		end,
		-- default constructor
		constructor = function() end ,
		-- function used to create new object of the class
		new = function(...)
			local object = {
			}
			setmetatable(object, {__index = parentClass[str_newClassName]})
			object.constructor(object, ...)
			return object
		end ,
		-- this table will be used to create new validators
		-- for example:
		-- SomeClass.validate.someFunction.args(numeric, string, SomeClass)
		-- SomeClass.validate.someFunction.returns(numeric)
		-- function SomeClass:someFunction(arg1, arg2, arg3) ... end
		validate = {},
		-- list of functions validators
		__definedValidators = {},
		__type = str_typeName
	}
	rawset(parentClass, str_newClassName, definition)
	setmetatable(definition.validate, {__index = 
		function (dvTable,str_functionName)
			if type(definition[str_functionName]) ~= "nil" then
				error("Validator should be defined before method's definition")
			end
			local validators = {}
			validators.args = function (...)
				local arg = {...}
				local __definedValidators = parentClass[str_newClassName].__definedValidators
				if __definedValidators[str_functionName] == nil then 
					__definedValidators[str_functionName] = {}
				end
				-- we expect "self" as first parameter, so:
				table.insert(arg, 1, "table")
				__definedValidators[str_functionName].args = arg
				return validators
			end
			validators.result = function (str_expectedResultType)
				local __definedValidators = parentClass[str_newClassName].__definedValidators
				if __definedValidators[str_functionName] == nil then 
					__definedValidators[str_functionName] = {}
				end
				__definedValidators[str_functionName].result = str_expectedResultType
				return validators
			end
			rawset(dvTable,str_functionName,validators)
			return validators
		end
	})
	-- sometimes we need to wrap function definition with some validations
	setmetatable(definition, {__newindex = 
		function (dvTable, key, value)
			if type(value) == "function" and definition.__definedValidators[key] ~= nil then
				local validators = definition.__definedValidators[key]
				validators.fun_originalFunction = value
				local validateFunction = function(...)
					local args = {...}
					local expectedArgs = validators.args
					if expectedArgs ~= nil then
						for i,str_expectedArg in ipairs(expectedArgs) do
							if type(args[i]) ~= str_expectedArg then
								local str_expectedArgs = table.concat(expectedArgs, ",")
								local str_args = ""
								for j,v in ipairs(args) do 
									if j>1 then str_args = str_args .. "," end
									str_args = str_args .. type(v)
								end
								local errorMessage = string.format("Validation error, expected: %s:%s(%s), was:%s:%s(%s)",str_newClassName, key, str_expectedArgs, str_newClassName, key, str_args)
								error(errorMessage)
							end
						end
					end
					local result = validators.fun_originalFunction(...)
					local expectedResult = validators.result
					if expectedResult ~= nil then
						if type(result)~=expectedResult then
							error(string.format("Wrong type of %s:%s result: expected %s, was %s", str_newClassName, key, expectedResult, type(result)))
						end
					end
					return result
				end
				rawset(dvTable, key, validateFunction)
			else
				rawset(dvTable, key, value)
			end
		end
	})
	-- in case, somebody want to use this kind of syntax:
	-- declare(SomeClassName).inherit(SomeOtherClass)
	return {
		inherit = function (str_base)
			parentClass[str_newClassName].__super = parentClass[str_base]
			parentClass[str_newClassName].constructor = function(self, ...)
				self.__super:constructor(...)
			end
			setmetatable(parentClass[str_newClassName], {__index = parentClass[str_base]})
		end,
		enum = function(tab_table)
			local class = parentClass[str_newClassName]
			__changeToEnum(class, tab_table)
		end
	}
end

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