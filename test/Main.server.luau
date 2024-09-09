--!strict
 
 
--> Modules -------------------------------------------------------------------------------------------
local Packages = script.Parent.Packages
local Fusion = require(Packages.Fusion)
local Ignite = require(Packages.Ignite)
-------------------------------------------------------------------------------------------------------
 
--> Variables -----------------------------------------------------------------------------------------
local Scope = Fusion.scoped(Fusion, Ignite)
local Children, OnEvent, peek = Fusion.Children, Fusion.OnEvent, Fusion.peek
-------------------------------------------------------------------------------------------------------
 
 
-- We need to pass the plugin to the scope as it can
-- only be obtained in the plugin's root (this) script.
Scope:SetPlugin(plugin)
 
local CounterState = Scope:Value(0)
local ComputeLabelText = Scope:Computed(function(use) return `Counter is: {use(CounterState)}` end)

Scope:SetTheme("Dark")

Scope:Widget {
  Id = "IgnitePlugin",
  Title = "My First Ignite Plugin 🚀",
  InitDockState = Enum.InitialDockState.Left,
  FloatXSize = 300, FloatYSize = 800,
 
  [Children] = {
    Scope:TextLabel {
      Text = ComputeLabelText,
      LayoutOrder = 0
    },
 
    Scope:Button {
      Text = "Increment Counter!",
      LayoutOrder = 1,
 
      [OnEvent "MouseButton1Click"] = function()
        CounterState:set(peek(CounterState) + 1)
      end
    },
 
    Scope:New "UIListLayout" {
      SortOrder = Enum.SortOrder.LayoutOrder,
      Padding = UDim.new(0, 8)
    },
 
    Scope:New "UIPadding" {
      PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
      PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8)
    }
  }
}