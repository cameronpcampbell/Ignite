--!strict


--> Services ------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------


--> Modules -------------------------------------------------------------------------------------------
local Modules = script.Parent.Parent.Modules
local Component = require(Modules.Component)
local CombineProps = require(Modules.CombineProps)

local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


return Component(function(scope, props: Fusion.PropertyTable)
  return scope:New "Frame" (CombineProps({
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = scope:GetThemeItem("Background/Primary"),
    Name = "Background"
  }, props))
end)

