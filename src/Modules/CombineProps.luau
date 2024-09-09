--!strict


--> Modules -------------------------------------------------------------------------------------------
local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local Children = Fusion.Children
-------------------------------------------------------------------------------------------------------


return function(...: Fusion.PropertyTable): Fusion.PropertyTable
	local propTablesLength = select("#", ...)
	if propTablesLength == 1 then return ... end

	local combinedProps: Fusion.PropertyTable = {}
	local combinedChildren: { Instance } = {}

	for i = 1, propTablesLength do
		local propTble = select(i, ...)

		for propName,propValue in propTble do

			if propName == Children then
				if typeof(propValue) == "table" and not propValue.kind then
					for _,child in propValue do table.insert(combinedChildren, child) end
				else
					table.insert(combinedChildren, propValue)
				end
				continue
			end

			combinedProps[propName] = propValue
		end
	end

	if #combinedChildren then
		combinedProps[Children] = combinedChildren
	end

	return combinedProps
end