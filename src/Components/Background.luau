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
  local background = scope:New "ImageButton" (CombineProps({
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = scope:GetThemeItem("Background/Primary"),
  }, props)) :: ImageButton

  return background :: Instance
end)

