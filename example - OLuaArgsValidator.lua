require 'oLua'
require 'ExampleEnum'

declare("Day").inherit("ExampleEnum")
Day.values = {  "Monday",
                "Tuesday",
                "Wednesday",
                "Thursday",
                "Friday",
                "Saturday",
                "Sunday"}

declare("SomeClass")

validate.SomeClass.foo.args(function(arg) return Day.new():contains(arg) end).returns('number')
function SomeClass:foo(arg)
    for i,v in ipairs(Day.values) do
        if v == arg then
            return i
        end
    end
end


---------------------------------------------------------
local A = SomeClass.new()
print("---","---")
print(A:foo("Thursday"),4)
print("---","---")
print("Validation test: (error is expected)")
print(A:foo("Sixday"),"Validation is not working!!!!!!! Error expected!!!!!!!!!")
