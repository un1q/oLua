require 'oLua'

declare("SomeClass")
declare("SomeClass2").inherit("SomeClass")
SomeClass.staticFoo=0
SomeClass.staticBar=0

function SomeClass:constructor()
	self.varFoo = 0
	self.varBar = 0
end

SomeClass.validate.foo.args("number", "number")
SomeClass.validate.foo.result("number")
function SomeClass:foo(arg1, arg2)
	self.varFoo = self.varFoo + 1
	SomeClass.staticFoo = SomeClass.staticFoo + 1
	return arg1+arg2
end

SomeClass.validate.bar.args("number", "number").result("number")
function SomeClass:bar(arg1, arg2)
	self.varBar = self.varBar + 1
	SomeClass.staticBar = SomeClass.staticBar + 1
	return arg1-arg2
end

function SomeClass:getFooCount()
	return self.varFoo
end

function SomeClass:getBarCount()
	return self.varBar
end

SomeClass.validate.resultValidation.args("string").result("number")
function SomeClass:resultValidation()
	return "123"
end

declare("Test")
Test.validate.test.args("SomeClass", "SomeClass").result("number")
function Test:test(obj1, obj2)
	return obj1:getFooCount()+obj2:getFooCount()
end

---------------------------------------------------------
declare('SomeSmallClass', SomeClass).enum({"ONE", "TWO"})
function SomeClass.SomeSmallClass:foo(bar)
	if bar == 1 then 
		return SomeClass.SomeSmallClass.ONE
	end
	if bar == 2 then 
		return SomeClass.SomeSmallClass.TWO
	end
	return nil
end

SomeClass.declare('SomeSmallClass2').enum({"ONE", "TWO"})
function SomeClass.SomeSmallClass2:foo(bar)
	if bar == 1 then 
		return SomeClass.SomeSmallClass.ONE
	end
	if bar == 2 then 
		return SomeClass.SomeSmallClass.TWO
	end
	return nil
end

SomeClass.someStaticEnum = enum({"ONE", "TWO"})
---------------------------------------------------------
local A = SomeClass.new()
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
print(SomeClass.staticFoo,3)
print(SomeClass.staticBar,1)
print("---","---")
print(SomeClass.SomeSmallClass.ONE,'ONE')
print(SomeClass.someStaticEnum.ONE,'ONE')
local C = SomeClass.SomeSmallClass.new()
print(C:foo(1),'ONE')
local D = SomeClass.SomeSmallClass2.new()
print(D:foo(2),'TWO')
print("---","---")
print(A.__type)
print(B.__type)
print(C.__type)
print("---","---")
local test = Test.new()
print(test:test(A,B), 3)
print("---","---","Validation test: ")
print(B:resultValidation("test"))
print("---","---","If this text is visible, validation sucks.")