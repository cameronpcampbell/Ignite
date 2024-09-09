--!strict


--> Services ------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------


--> Modules -------------------------------------------------------------------------------------------
local Modules = script.Parent.Parent.Parent.Modules
local Component = require(Modules.Component)
local TableUtils = require(Modules.TableUtils)
local CombineProps = require(Modules.CombineProps)

local Packages = script.Parent.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
type ArrowProps = {
  isExpanded: Fusion.UsedAs<boolean>?,
  ExpandedRotation: Fusion.UsedAs<number>?,
  CollapsedRotation: Fusion.UsedAs<number>?
}
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local TableTake, TableHasItems = TableUtils.Take, TableUtils.HasItems

local Children = Fusion.Children
-------------------------------------------------------------------------------------------------------


--> Private Functions ---------------------------------------------------------------------------------
local function GetEventsFromProps(props)
  local events = {}

  for key,value in props do
    if typeof(key) ~= "table" then continue end
    if key.kind ~= "OnEvent" then continue end
    events[key] = TableTake(props, key)
  end

  return events
end
-------------------------------------------------------------------------------------------------------


return Component(function(scope, props: ArrowProps)
  local isExpanded = TableTake(props, "IsExpanded", false) :: Fusion.Value<boolean>
  local expandedRotation = TableTake(props, "ExpandedRotation", 180) :: Fusion.UsedAs<number>
  local collapsedRotation = TableTake(props, "CollapsedRotation", 0) :: Fusion.UsedAs<number>
  local events = GetEventsFromProps(props)

  local computeRotation = scope:Tween(
    scope:Computed(function(use) return use(isExpanded) and use(expandedRotation) or use(collapsedRotation) end),
    TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
  )

  return scope:New "Frame" {
    Size = UDim2.fromOffset(9, 9),
    BackgroundTransparency = 1,
    LayoutOrder = 1,
    Name = "Arrow",

    [Children] = {
      -- The `Rotation` property has no effect when the GUI object (in this case an ImageLabel) is
      -- influenced by a UI Layout therefore we use this workaround of wrapping it in a frame.  
      scope:New "ImageLabel" {
        Size = UDim2.fromOffset(9, 9),
        Image = "rbxassetid://96759643132846",
        ImageColor3 = scope:GetThemeItem("Text/Title"),
        BackgroundTransparency = 1,
        Rotation = computeRotation,
        Name = "Arrow:Image"
      },

      TableHasItems(events) and scope:New "ImageButton" (CombineProps({
        Size = UDim2.fromOffset(25, 25),
        Position = UDim2.fromScale(.5, .5),
        AnchorPoint = Vector2.new(.5, .5),
        BackgroundTransparency = 1,
        Name = "Arrow:Hitbox"
      }, events)) or nil :: any
    }
  }
end)