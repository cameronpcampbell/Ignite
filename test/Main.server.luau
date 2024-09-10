--!strict
 
 
--> Modules -------------------------------------------------------------------------------------------
local Packages = script.Parent.Packages
local Fusion = require(Packages.Fusion)
local Ignite = require(Packages.Ignite)
-------------------------------------------------------------------------------------------------------
 
--> Variables -----------------------------------------------------------------------------------------
local Scope = Fusion.scoped(Fusion, Ignite)
local Children = Fusion.Children
-------------------------------------------------------------------------------------------------------
 
 
-- We need to pass the plugin to the scope as it can
-- only be obtained in the plugin's root (this) script.
Scope:SetPlugin(plugin)
 
Scope:Widget {
  Id = "IgnitePlugin",
  Title = "My First Ignite Plugin 🚀",
  InitDockState = Enum.InitialDockState.Left,
  FloatXSize = 300, FloatYSize = 800,
 
  [Children] = {
    Scope:Button {
      Text = "Click Me!",
      Variant = "Primary" :: "Primary"
    },
 
    Scope:New "UIListLayout" {
      SortOrder = Enum.SortOrder.LayoutOrder,
      Padding = UDim.new(0, 25)
    },
 
    Scope:New "UIPadding" {
      PaddingLeft = UDim.new(0, 25), PaddingRight = UDim.new(0, 25),
      PaddingTop = UDim.new(0, 25), PaddingBottom = UDim.new(0, 25)
    }
  }
}