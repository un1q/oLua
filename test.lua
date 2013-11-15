require 'oLua'

declare('Test')

function Test.print(value)
    if type(value) == 'table' then
        local result = "{"
        local first = true
        for _,v in pairs(value) do
            if not(first) then
                result = result .. ","
            end
            result = result .. Test.print(v)
            first = false
        end
        return result .. "}"
    else
        return tostring(value)
    end

end

function Test.equals(v1, v2)
    if v1 == v2 then
        print('ok')
    else
        error('Expected: '.. Test.print(v1) .. ', was: ' .. Test.print(v2))
    end
end

function Test.isTrue(v)
    if v then
        print('ok')
    else
        error('Expected: true, was: ' .. Test.print(v))
    end
end

function Test.isFalse(v)
    if not(v) then
        print('ok')
    else
        error('Expected: false, was: ' .. Test.print(v))
        error()
    end
end

declare("SomeClass1")
declare("SomeClass2").inherit("SomeClass1")
SomeClass1.staticFoo=0
SomeClass1.staticBar=0

function SomeClass1:constructor()
	self.varFoo = 0
	self.varBar = 0
end

validate.SomeClass1.foo.args("number", "number")
validate.SomeClass1.foo.returns("number")
function SomeClass1:foo(arg1, arg2)
	self.varFoo = self.varFoo + 1
	SomeClass1.staticFoo = SomeClass1.staticFoo + 1
	return arg1+arg2
end

validate.SomeClass1.bar.args("number", "number").returns("number")
function SomeClass1:bar(arg1, arg2)
	self.varBar = self.varBar + 1
	SomeClass1.staticBar = SomeClass1.staticBar + 1
	return arg1-arg2
end

function SomeClass1:getFooCount()
	return self.varFoo
end

function SomeClass1:getBarCount()
	return self.varBar
end

validate.SomeClass1.resultValidation.args("string").returns("number")
function SomeClass1:resultValidation()
	return "123"
end

declare("SomeClass3")
validate.SomeClass3.test.args("SomeClass1", "SomeClass1").returns("number")
function SomeClass3:test(obj1, obj2)
	return obj1:getFooCount()+obj2:getFooCount()
end

---------------------------------------------------------
declare('SomeSmallClass1', SomeClass1)
function SomeClass1.SomeSmallClass1:foo(bar)
	return 'foo'
end

SomeClass1.declare('SomeSmallClass2')
function SomeClass1.SomeSmallClass2:foo(bar)
	return 'foo'
end
---------------------------------------------------------
local A = SomeClass1.new()
local B = SomeClass2.new()
print('----------------------------')
print('--DEFINITION AND VALIDATION-')
print('----------------------------')
Test.equals(A:foo(1,1),2)
Test.equals(A:foo(2,3),5)
Test.equals(B:foo(3,3),6)
Test.equals(B:bar(4,4),0)
----------------------------
Test.equals(A:getFooCount(),2)
Test.equals(A:getBarCount(),0)
Test.equals(B:getFooCount(),1)
Test.equals(B:getBarCount(),1)
print('----------------------------')
print('-------STATICS--------------')
print('----------------------------')
Test.equals(SomeClass1.staticFoo,3)
Test.equals(SomeClass1.staticBar,1)
----------------------------
local C = SomeClass1.SomeSmallClass1.new()
local D = SomeClass1.SomeSmallClass2.new()
print('----------------------------')
print('--TYPES AND INNER CLASSES---')
print('----------------------------')
Test.equals(A.__type, 'SomeClass1')
Test.equals(B.__type, 'SomeClass2')
Test.equals(C.__type, 'SomeClass1.SomeSmallClass1')
Test.equals(D.__type, 'SomeClass1.SomeSmallClass2')
----------------------------
local E = SomeClass3.new()
Test.equals(E:test(A,B), 3)
----------------------------
Test.isFalse(pcall(function() B:resultValidation("test") end))
print('----------------------------')
print('------PROMOTION-------------')
print('----------------------------')
local justTable = {x = 'X'}
function justTable:getX()
    return self.x
end
local F = OLua.promote(justTable, SomeClass1)
Test.equals(F:foo(1,1),2)
Test.equals(F.x,'X')
Test.equals(F:getX(),'X')
