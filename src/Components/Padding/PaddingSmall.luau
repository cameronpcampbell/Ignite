--!strict


--> Modules -------------------------------------------------------------------------------------------
local Modules = script.Parent.Parent.Parent.Modules
local Component = require(Modules.Component)
-------------------------------------------------------------------------------------------------------


return Component(function(scope)
  return scope:New "UIPadding" {
    PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
    PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4)
  }
end)