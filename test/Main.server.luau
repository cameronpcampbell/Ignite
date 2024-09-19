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




local MyTable = {}
MyTable.__index = MyTable

function MyTable:FooBar() return true end

table.insert(MyTable, function() return true end)



local CounterState = Scope:Value(0)
local ComputeLabelText = Scope:Computed(function(use) return `Counter is: {use(CounterState)}` end)

Scope:Widget {
  Id = "IgnitePlugin",
  Title = "My First Ignite Plugin 🚀",
  InitDockState = Enum.InitialDockState.Left,
  FloatXSize = 300, FloatYSize = 800,

  [Children] = {
    Scope:Tabs {
      Sections = {
        { Text = "Hello" },
        { Text = "World" }
      }
    },

    Scope:New "UIListLayout" {
      SortOrder = Enum.SortOrder.LayoutOrder,
      Padding = UDim.new(0, 8)
    },

    --[[Scope:New "UIPadding" {
      PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
      PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8)
    }]]
  }
}