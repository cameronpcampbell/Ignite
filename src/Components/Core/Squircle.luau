--!strict


--> Services ------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------


--> Modules -------------------------------------------------------------------------------------------
local Modules = script.Parent.Parent.Parent.Modules
local Component = require(Modules.Component)
local TableUtils = require(Modules.TableUtils)
local CombineProps = require(Modules.CombineProps)
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
type SquircleProps = {
  As: ("ImageLabel" | "ImageButton")?,
}
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local TableTake = TableUtils.Take
-------------------------------------------------------------------------------------------------------


--> Private Functions ---------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

return Component(function(scope, props: SquircleProps)
  local as = TableTake(props, "As", "ImageLabel") :: "ImageLabel" | "ImageButton"
  local backgroundColor3 = TableTake(props, "BackgroundColor3")
  local backgroundTransparency = TableTake(props, "BackgroundTransparency")
  local transparency = TableTake(props, "Transparency")

  return scope:New (as) (CombineProps({
    ImageColor3 = backgroundColor3,
    ImageTransparency = backgroundTransparency or transparency,
    BackgroundTransparency = 1,
    Image = "rbxassetid://95025174368716",
    ScaleType = Enum.ScaleType.Slice,
    SliceScale = .5,
    SliceCenter = Rect.new(25, 25, 25, 25),
    Active = false,
  }, props))
end)