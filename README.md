# Ignite

Ignite is a UI library for developing Roblox plugins. It includes 10+ goregeous high-dpi compatible components.


## Getting Started

1. Install Ignite via [Wally](https://wally.run/package/cameronpcampbell/ignite?version=1.0.0) or via [github releases](https://github.com/cameronpcampbell/Ignite/releases).
```
ignite = "mightypart/ignite@1.0.0"
```

2. Setup your `default.project.json` (if using rojo).
```json
{
  "name": "my_ignite_plugin",
  "tree": {
    "$className": "DataModel",

    "ServerStorage": {
      "Plugin": {
        "$path": "src", // replace with the path to your plugin's source.

        "Packages": { "$path": "Packages" }
      }
    }
  }
}
```

3. Setup the root script of your plugin.
```lua
--!strict


--> Modules -------------------------------------------------------------------------------------------
local Packages = -- Path to Packages.
local Fusion = require(Packages.Fusion)
local Ignite = require(Packages.Ignite)
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local Scope = Fusion.scoped(Fusion, Ignite)
-------------------------------------------------------------------------------------------------------


-- We need to pass the plugin to the scope as it can
-- only be obtained in the plugin's root (this) script.
Scope:SetPlugin(plugin)
```


3. Example Ignite project.
```lua
--!strict


--> Modules -------------------------------------------------------------------------------------------
local Packages = -- Path to Packages.
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
```