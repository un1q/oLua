require 'oLua'

decare('Test')

Test.validate.test.args(EnumValidator.new('one','two','three')).returns('number')
function Test:test(gate)
	if gate == 'one' then return 1 end
	if gate == 'two' then return 1 end
	if gate == 'three' then return 1 end
end

local test = Test.new()
print (test:test())