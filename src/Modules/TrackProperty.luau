--!strict


--> Modules -------------------------------------------------------------------------------------------
local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local peek = Fusion.peek
-------------------------------------------------------------------------------------------------------


--> Private Functions ---------------------------------------------------------------------------------
local function Track(inst: Instance, propName: string, trackedProp: Fusion.Value<any>): RBXScriptConnection?
	if not inst then return end
	
	trackedProp:set((inst :: any)[propName])
	
	return inst:GetPropertyChangedSignal(propName):Connect(function()
		trackedProp:set((inst :: any)[propName])
	end)
end
-------------------------------------------------------------------------------------------------------


return function(scope: Fusion.Scope<typeof(Fusion)>, inst: Instance? | Fusion.Value<Instance>, propName: string | Fusion.Value<string>): Fusion.Value<any>
	local trackedProp = scope:Value((inst :: any)[propName])
	
	if typeof(inst) == "Instance" then
		Track(inst, peek(propName), trackedProp)
		
	else
		local instIsState = type(inst) == "table" and inst.dependentSet
		local propNameIsState = type(propName) == "table" and propName.dependentSet

		local event: RBXScriptConnection? = nil

		if instIsState then
			scope:Observer(inst :: Fusion.Value<Instance>):onChange(function()
				if event then event:Disconnect() end
				event = Track(peek(inst), peek(propName), trackedProp)
			end)
		end

		if propNameIsState then
			scope:Observer(propName :: Fusion.Value<string>):onChange(function()
				if event then event:Disconnect() end
				event = Track(peek(inst), peek(propName), trackedProp)
			end)
		end
	end
		
	return trackedProp
end