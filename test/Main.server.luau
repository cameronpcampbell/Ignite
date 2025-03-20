--!strict

--> Modules -------------------------------------------------------------------------------------------
local Packages = script.Parent.Packages
local Fusion = require(Packages.Fusion) :: any
local Ignite = require(Packages.Ignite) :: any
-------------------------------------------------------------------------------------------------------

--> Variables -----------------------------------------------------------------------------------------
local Scope = Fusion.scoped(Fusion, Ignite)
local Children = Fusion.Children

-------------------------------------------------------------------------------------------------------

local MyTable = {}
MyTable.__index = MyTable

function MyTable:FooBar()
	return true
end

table.insert(MyTable, function()
	return true
end)

Scope:Widget({
	Id = "IgnitePlugin",
	Title = "My First Ignite Plugin 🚀",
	InitDockState = Enum.InitialDockState.Left,
	FloatXSize = 300,
	FloatYSize = 800,

	[Children] = {
		Scope:Tabs({
			Sections = {
				{ Text = "Hello" },
				{ Text = "World" },
			},
		}),

		Scope:New("UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
		}),

		Scope:Button({

			Content = { "Test Button!" },

			IconProperties = {
				BackgroundTransparency = 0,
				Size = UDim2.fromOffset(4, 4),
			},
		}),

		--[[Scope:New "UIPadding" {
      PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
      PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8)
    }]]
	},
})
