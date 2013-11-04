require 'oLua'

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

declare("Test")
validate.Test.test.args("SomeClass1", "SomeClass1").returns("number")
function Test:test(obj1, obj2)
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
print(A:foo(1,1),2)
print(A:foo(2,3),5)
print(B:foo(3,3),6)
print(B:bar(4,4),0)
print("---","---")
print(A:getFooCount(),2)
print(A:getBarCount(),0)
print(B:getFooCount(),1)
print(B:getBarCount(),1)
print("---","---")
print(SomeClass1.staticFoo,3)
print(SomeClass1.staticBar,1)
print("---","---")
local C = SomeClass1.SomeSmallClass1.new()
local D = SomeClass1.SomeSmallClass2.new()
print("---","---")
print(A.__type, 'SomeClass1')
print(B.__type, 'SomeClass2')
print(C.__type, 'SomeClass1.SomeSmallClass1')
print(D.__type, 'SomeClass1.SomeSmallClass2')
print("---","---")
local test = Test.new()
print(test:test(A,B), 3)
print("---","---")
print("Validation test: (error is expected) ")
print(B:resultValidation("test"))
print("Something gone wrong!!!!!!!")