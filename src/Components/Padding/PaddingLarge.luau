--!strict


--> Modules -------------------------------------------------------------------------------------------
local Modules = script.Parent.Parent.Parent.Modules
local Component = require(Modules.Component)
-------------------------------------------------------------------------------------------------------


return Component(function(scope)
  return scope:New "UIPadding" {
    PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7),
    PaddingTop = UDim.new(0, 7), PaddingBottom = UDim.new(0, 7)
  }
end)