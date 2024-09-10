--!strict


--> Services ------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------


--> Modules -------------------------------------------------------------------------------------------
local Modules = script.Parent.Parent.Modules
local Component = require(Modules.Component)
local ComputeTransforms = require(Modules.ComputeTransforms)
local TableUtils = require(Modules.TableUtils)

local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)

local Components = Modules.Parent.Components
local CoreComponents = Components.Core
local Squircle = require(CoreComponents.Squircle)
local TextLabel = require(CoreComponents.TextLabel)
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
type ButtonProps = {
  Width: Fusion.UsedAs<UDim>?,
  Text: Fusion.UsedAs<string>?,
  Variant: ("Primary" | "Secondary" | "Destructive")?
}
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local ComputeUDim2 = ComputeTransforms.UDim2

local TableTake = TableUtils.Take

local Children, OnEvent = Fusion.Children, Fusion.OnEvent
-------------------------------------------------------------------------------------------------------


--> Private Functions ---------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------


return Component(function(scope, props: ButtonProps)
  local width = TableTake(props, "Width", UDim.new(1,0)) :: Fusion.UsedAs<UDim>
  local text = TableTake(props, "Text", "Button") :: Fusion.UsedAs<string>
  local variant = TableTake(props, "Variant", "Primary") :: Fusion.UsedAs<"Primary" | "Secondary" | "Destructive">

  local isHover, isFocus = scope:Value(false), scope:Value(false)

  local computeBackgroundColor = scope:GetThemeItem(
    scope:Computed(function(use) return `Accent/{use(variant) or "Primary"}` :: any end),
    scope:Computed(function(use) return if use(isFocus) then "Focus" elseif use(isHover) then "Hover" else nil :: any end))

  -- Handles the edge case of the user dragging the cursor off of the button and then releasing the mouse button.
  scope:AddRootEvent("InputEnded", function() isFocus:set(false) end)

  return Squircle (scope, {
    As = "ImageButton" :: "ImageButton",
    Size = ComputeUDim2(scope, width, UDim.new(0, 25)),
    AutomaticSize = Enum.AutomaticSize.X,
    BackgroundColor3 = computeBackgroundColor,
    Name = "Button",

    [OnEvent "MouseEnter"] = function() isHover:set(true) end :: any,
    [OnEvent "MouseLeave"] = function() isHover:set(false) end :: any,

    [OnEvent "MouseButton1Down"] = function() isFocus:set(true) end :: any,
    [OnEvent "MouseButton1Up"] = function() isFocus:set(false) end :: any,

    [Children] = {
      Squircle (scope, {
        Size = UDim2.fromScale(1, 1),
        Image = "rbxassetid://108824901287727",
        Name = "Button:Highlight"
      }),

      scope:New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Name = "Button:ContentWrapper",

        [Children] = {
          TextLabel (scope, {
            Text = text,
            Focus = "Title" :: "Title",
            Weight = Enum.FontWeight.SemiBold,
            Size = UDim2.fromScale(1, 1),
            TextXAlignment = Enum.TextXAlignment.Center
          }),
    
          scope:New "UIPadding" { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) },
        }
      }
    }
  }, props :: any)
end)