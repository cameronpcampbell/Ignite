--!strict


--> Modules -------------------------------------------------------------------------------------------
local CoreComponents = script.Parent.Core
local Squircle = require(CoreComponents.Squircle)

local Modules = script.Parent.Parent.Modules
local Component = require( Modules.Component)
local CombineProps = require(Modules.CombineProps)
local TableUtils = require(Modules.TableUtils)

local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
type EmbeddedContainerProps = {
  StrokeTop: Fusion.UsedAs<boolean>?,
  StrokeBottom: Fusion.UsedAs<boolean>?,
  StrokeLeft: Fusion.UsedAs<boolean>?,
  StrokeRight: Fusion.UsedAs<boolean>?,
  ChildrenZIndex: Fusion.UsedAs<number>?
}
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local Children = Fusion.Children

local TableTake = TableUtils.Take

local IMAGE_HOR_LINE, IMAGE_VERT_LINE = "rbxassetid://93679517852836", "rbxassetid://78660200493970"
-------------------------------------------------------------------------------------------------------


--> Functions -----------------------------------------------------------------------------------------
local function StrokeLine(scope: Component.Scope, image: string, rotation: number, isVisible: Fusion.UsedAs<boolean>, name: string): Instance
  return scope:Computed(function(use)
    return if use(isVisible) then Squircle(scope, {
      Size = UDim2.fromScale(1, 1),
      Image = image,
      BackgroundColor3 = scope:GetThemeItem("Background/Stroke"),
      Rotation = rotation,
      ZIndex = 2,
      Name = `EmbeddedContainer:Stroke:{name}`
    }) else nil
  end) :: any
end
-------------------------------------------------------------------------------------------------------


return Component(function(scope, props: EmbeddedContainerProps)
  --local size, automaticSize = (props :: any).Size, (props :: any).AutomaticSize
  local strokeTop, strokeBottom = TableTake(props, "StrokeTop"), TableTake(props, "StrokeBottom")
  local strokeLeft, strokeRight = TableTake(props, "StrokeLeft"), TableTake(props, "StrokeRight")
  local children, childrenZIndex = TableTake(props, Children), TableTake(props, "ChildrenZIndex")

  --local childrenSize = scope:Computed(function(use) return if use(automaticSize) then UDim2.new() else use(size) end)

  return scope:New "Frame" (CombineProps({
    BackgroundColor3 = scope:GetThemeItem("Background/Secondary"),
    Name = "EmbeddedContainer",

    [Children] = {
      StrokeLine(scope, IMAGE_HOR_LINE, 0, strokeTop, "Top"),
      StrokeLine(scope, IMAGE_VERT_LINE, 180, strokeRight, "Right"),
      StrokeLine(scope, IMAGE_HOR_LINE, 180, strokeBottom, "Bottom"),
      StrokeLine(scope, IMAGE_VERT_LINE, 0, strokeLeft, "Left"),

      scope:New "Frame" {
        Size = UDim2.fromScale(1,1),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex=  childrenZIndex,
        Name = "EmbeddedContainer:Children",

        [Children] = {
          children,
          
          scope:New "UIFlexItem" { }
        }
      }
    }
  }, props))
end)

