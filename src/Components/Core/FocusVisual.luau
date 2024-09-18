--!strict


--> Services ------------------------------------------------------------------------------------------
local GuiService = game:GetService("GuiService")
-------------------------------------------------------------------------------------------------------


--> Modules -------------------------------------------------------------------------------------------
local Components = script.Parent.Parent
local CoreComponents = Components.Core
local Squircle = require(CoreComponents.Squircle)

local Modules = script.Parent.Parent.Parent.Modules
local Component = require(Modules.Component)
local ComputeTransforms = require(Modules.ComputeTransforms)
local TableUtils = require(Modules.TableUtils)

local Packages = script.Parent.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
type ValidationProps = {
  Pattern: Fusion.UsedAs<string>,
  Mode: Fusion.UsedAs<"Restrict" | "ErrorVisual" | nil>
}

type Variant = Fusion.UsedAs<"Primary" | "Secondary" | nil>

type TextInputProps = {
  Width: Fusion.UsedAs<UDim>?,
  Placeholder: Fusion.UsedAs<string?>,
  Value: Fusion.UsedAs<string?>,
  Variant: Variant?,
  Keybind: Fusion.UsedAs<{ Enum.KeyCode }>?,
  Validation: ValidationProps?,
  Embedded: Fusion.UsedAs<boolean>?,
  IsFocus: Fusion.UsedAs<boolean>?
}
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local ComputeUDim2, ComputeUDim = ComputeTransforms.UDim2, ComputeTransforms.UDim
-------------------------------------------------------------------------------------------------------

return function(
  scope: Component.Scope, isFocusState: Fusion.Value<boolean>,
  computeStrokeThemeItem: Fusion.UsedAs<"Accent/Primary" | "Accent/Destructive" | "Background/Stroke">,
  image: Fusion.UsedAs<string>?
)
  local computeSizeOffset = scope:Computed(function(use) return use(isFocusState) and 4 or 8 end)
  local computeSizeUDim = ComputeUDim(scope, 1, computeSizeOffset)

  local computeTransparency = scope:Computed(function(use) return use(isFocusState) and .6 or 1 end)

  return Squircle (scope, {
    Size = scope:Spring(ComputeUDim2(scope, computeSizeUDim, computeSizeUDim), 20, 1),
    Position = UDim2.fromScale(.5, .5),
    AnchorPoint = Vector2.new(.5, .5),
    Image = image or "rbxassetid://129606470741282",
    BackgroundColor3 = scope:GetThemeItem(computeStrokeThemeItem),
    Transparency = computeTransparency,
    ZIndex = 999,
    Name = "TextInput:FocusVisual"
  })
end