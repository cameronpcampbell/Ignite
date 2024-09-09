--!strict


--> Modules -------------------------------------------------------------------------------------------
local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


return function<T>(
	scope: Fusion.Scope<typeof(Fusion)>, maybeState: T | Fusion.Value<T>, ignoreIfNil: boolean?
): Fusion.Value<T>?
	if ignoreIfNil and maybeState == nil then return nil end

	return ((typeof(maybeState) == "table" and maybeState["type"] == "State") and maybeState or scope:Value(maybeState)) :: Fusion.Value<T>
end