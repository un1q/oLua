require 'oLua'
require 'Enum'

declare("Day").inherit("Enum")
Day.values = {  "Monday",
                "Tuesday",
                "Wednesday",
                "Thursday",
                "Friday",
                "Saturday",
                "Sunday"}

declare("SomeClass")

validate.SomeClass.foo.args('string').returns('number').before(function(str_typeName, functionName, args) Day.new():validate(args[2]) end)
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
print(A:foo("Thursday"),2)
print("---","---")
print(A:foo("Sixday"),"Validation is not working!!!!!!! Error expected!!!!!!!!!")
