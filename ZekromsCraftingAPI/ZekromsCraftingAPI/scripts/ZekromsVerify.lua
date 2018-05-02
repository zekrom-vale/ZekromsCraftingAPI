require"/scripts/ZekromsContainerUtil.lua"
require"/scripts/ZekromsUtil.lua"
Zverify={}
function Zverify.verify()
	local self=self
	if #self.input>2 or #self.output>2 then
		Zutil.API()
		sb.logInfo("Input/output array is not 2 elements for: "..Zutil.sbName()..".  Ignoring the other ones")
	end
	local size=world.containerSize(entity.id())
	self.input={Zverify.fixIO(self.input[1],size)or 1,Zverify.fixIO(self.input[2],size)or size}
	self.output={Zverify.fixIO(self.output[1],size)or 1,Zverify.fixIO(self.output[2],size)or size}
	size=nil

	local str="put values swapped, use [small,large] for: "
	if self.input[1]>self.input[2]then
		self.input=Zutil.swap2(self.input)
		Zutil.API()
		sb.logInfo("In"..str..Zutil.sbName())
	end
	if self.output[1]>self.output[2]then
		self.output=Zutil.swap2(self.output)
		Zutil.API()
		sb.logInfo("Out"..str..Zutil.sbName())
	end
	str=nil
	Zverify.verifyIn()
	if not next(self.recipes)then
		Zutil.API()
		sb.logError("No recipe file defined for: "..Zutil.sbName())
	end
end

function Zverify.fixIO(item,size)
	if not item or type(item)~="number"then
		Zutil.API()
		sb.logWarn("Input/output array is not 2 elements for: "..Zutil.sbName()..".  Trying to compensate")
	elseif item%1~=0 or item>size or item<=0 then
		Zutil.API()
		sb.logWarn("Input/output invalid: "..Zutil.sbName()..".  Trying to compensate")
	else
		return item
	end
end

function Zverify.verifyIn()
	local self=self
	local function act(value,key)
		sb.logInfo(sb.printJson(value,1))
		table.remove(self.recipes,key)
		return key-1
	end
	for key,value in pairs(self.recipes)do
		--[[if (value.level or 1)>self.level then 
			table.remove(self.recipes,key)
			key=key-1
			goto testEnd
		else]]if not(value.input and value.output)then
			Zutil.API(); sb.logWarn("Input/output missing for: "..Zutil.sbName())
			key=act(value,key)
			goto testEnd
		elseif #value.input>self.input[2]-self.input[1]+1 then
			Zutil.API(); sb.logWarn("Input overflow in: "..Zutil.sbName())
			key=act(value,key)
			goto testEnd
		elseif #value.output>self.output[2]-self.output[1]+1 then
			Zutil.API(); sb.logInfo("Possible output overflow in: "..Zutil.sbName())
			sb.logInfo(sb.printJson(value,1))
		end
		if value.delay and value.delay%1~=0 then
			Zutil.API(); sb.logInfo("Dellay is not an 'int' in: "..Zutil.sbName())
			sb.logInfo(sb.printJson(value,1))
			value.delay=math.floor(value.delay)
		end
		for _,out in pairs(value.output)do
			if out.pool and not root.isTreasurePool(out.pool)then
				Zutil.API()
				sb.logWarn("Invalid pool in: "..Zutil.sbName())
				key=act(value,key)
				break
			end
		end
		::testEnd::
	end
end