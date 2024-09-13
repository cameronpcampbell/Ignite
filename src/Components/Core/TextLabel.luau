--!strict


--> Modules -------------------------------------------------------------------------------------------
local Modules = script.Parent.Parent.Parent.Modules
local Component = require(Modules.Component)
local ComputeTransforms = require(Modules.ComputeTransforms)
local TableUtils = require(Modules.TableUtils)
local CombineProps = require(Modules.CombineProps)

local Packages = script.Parent.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
type TextLabelProps = {
  Text: Fusion.UsedAs<string>?,
  Focus: Fusion.UsedAs<"Title" | "Body">?,
  Weight: Fusion.UsedAs<Enum.FontWeight>?,
  Style: Fusion.UsedAs<Enum.FontStyle>?,
  FontId: Fusion.UsedAs<number>?,
  TextSize: Fusion.UsedAs<number>?
}
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local ComputeUDim, ComputeUDim2 = ComputeTransforms.UDim, ComputeTransforms.UDim2

local TableTake = TableUtils.Take
-------------------------------------------------------------------------------------------------------


--> Functions -----------------------------------------------------------------------------------------
local function ComputeFontFromId(
  scope: Fusion.Scope<typeof(Fusion)>, id: Fusion.UsedAs<number>, weight: Fusion.UsedAs<Enum.FontWeight>?, style: Fusion.UsedAs<Enum.FontStyle>?
)
  return scope:Computed(function(use)
    return Font.fromId(use(id) or 16658221428, use(weight) or Enum.FontWeight.Medium, use(style) or Enum.FontStyle.Normal)
  end)
end
-------------------------------------------------------------------------------------------------------


return Component(function(scope, props: TextLabelProps)
  local focus = TableTake(props, "Focus", "Body") :: Fusion.UsedAs<"Title" | "Body">
  local weight = TableTake(props, "Weight", Enum.FontWeight.Medium) :: Fusion.UsedAs<Enum.FontWeight>
  local style = TableTake(props, "Style", Enum.FontStyle.Normal) :: Fusion.UsedAs<Enum.FontStyle>
  local fontId = TableTake(props, "FontId", 16658221428) :: Fusion.UsedAs<number>
  local textSize = TableTake(props, "TextSize", 14) :: Fusion.UsedAs<number>

  local computeColor = scope:GetThemeItem(scope:Computed(function(use) return `Text/{use(focus) or "Body"}` :: any end))

  return scope:New "TextLabel" (CombineProps({
    Size = ComputeUDim2(scope, UDim.new(0,0), ComputeUDim(scope, 0, textSize)),
    AutomaticSize = Enum.AutomaticSize.XY,
    FontFace = ComputeFontFromId(scope, fontId, weight, style),
    TextColor3 = computeColor,
    BackgroundTransparency = 1,
    TextSize = textSize,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center
  }, props))
end)