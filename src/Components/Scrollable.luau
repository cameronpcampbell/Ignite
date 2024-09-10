--!strict


--> Modules -------------------------------------------------------------------------------------------
local Modules = script.Parent.Parent.Modules
local Component = require(Modules.Component)
local CombineProps = require(Modules.CombineProps)
local ForceToState = require(Modules.ForceToState)
local TableUtils = require(Modules.TableUtils)

local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
type ScrollableProps = {
  CanvasPositionY: Fusion.UsedAs<number>?
}
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local Children, OnEvent, peek = Fusion.Children, Fusion.OnEvent, Fusion.peek

local TableTake = TableUtils.Take
-------------------------------------------------------------------------------------------------------


--> Functions -----------------------------------------------------------------------------------------
local function ChildrenContainsInstance(children: { Instance } | Instance, instName: string)
  if type(children) ~= "table" then
    if typeof(children) == "Instance" and children.ClassName == instName then return true end
  else
    for _,child in children do
      if typeof(child) == "Instance" and child.ClassName == instName then return true end
    end
  end

	return false
end
-------------------------------------------------------------------------------------------------------


return Component(function(scope, props: Fusion.PropertyTable)
  local children = TableTake(props, Children)
  local canvasPositionY: Fusion.Value<number> = ForceToState(scope, TableTake(props, "CanvasPositionY", 0)) :: any
  local canvasSize = TableTake(props, "CanvasSize")

  local scrollFrameRef: Fusion.Value<Instance> = scope:Value(nil) :: any
  local scrollBarBackgroundRef: Fusion.Value<Instance> = scope:Value(nil) :: any

  local scrollFrameCanvasPosState = scope:Value(Vector2.zero)

  local function moveScrollCursor()
		local peekedScrollBarBackground: Frame? = peek(scrollBarBackgroundRef) :: Frame
		local peekedScrollFrame: ScrollingFrame? = peek(scrollFrameRef) :: ScrollingFrame

    if peekedScrollBarBackground == nil or peekedScrollFrame == nil then return end

		local scrollBackgroundAbsHeight = peekedScrollBarBackground.AbsoluteSize.Y
		local scrollBackgroundAbsPosY = peekedScrollBarBackground.AbsolutePosition.Y
		local scrollFrameAbsCanvasHeight = peekedScrollFrame.AbsoluteCanvasSize.Y

		local peekedCanvasPositionY = peek(canvasPositionY)
		
		local newScrollPositionPercent = math.clamp((peekedCanvasPositionY - scrollBackgroundAbsPosY) / scrollBackgroundAbsHeight, 0, 1)
		local newScrollPosition = (scrollFrameAbsCanvasHeight * newScrollPositionPercent) - (scrollBackgroundAbsHeight / 2);
		
		scrollFrameCanvasPosState:set(Vector2.new(0, newScrollPosition))
	end

  return scope:New "Frame" (CombineProps({
    ClipsDescendants = true,
		BackgroundTransparency = 1,
    Name = "Scrollable",

    [Children] = {
      scrollBarBackgroundRef:set(scope:New "ImageButton" {
        Size = UDim2.new(0,4, 1,0),
        Position = UDim2.fromScale(1, .5),
				AnchorPoint = Vector2.new(1,.5),
				ImageColor3 = scope:GetThemeItem("Background/Tertiary"),
        BackgroundTransparency = 1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(4, 4, 4, 4),
        Image = "rbxassetid://82161439810808",
				Name = "Scrollable:ScrollBarBackground",

        [OnEvent "MouseButton1Down"] = moveScrollCursor,
				[OnEvent "MouseMoved"] = function(_, y) canvasPositionY:set(y) end,
      }),

      scrollFrameRef:set(scope:New "ScrollingFrame" {
        Size = UDim2.fromScale(1,1),
				ScrollBarThickness = 4,
        TopImage = "rbxassetid://75722704152620",
				MidImage = "rbxassetid://86201773979334",
				BottomImage = "rbxassetid://120208654241752",
        BackgroundTransparency = 1,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = canvasSize or UDim2.fromScale(0,0),
				ScrollBarImageColor3 = scope:GetThemeItem("Background/Stroke", "Highlight"),
				CanvasPosition = scope:Tween(scrollFrameCanvasPosState, TweenInfo.new(.25)),
        Name = "Scrollable:ScrollFrame",

        [Children] = {
          (children and (not ChildrenContainsInstance(children, "UIPadding"))) and
						scope:New "UIPadding" {
							PaddingRight = UDim.new(0, 8)
						} or nil :: any,

          (children and (not ChildrenContainsInstance(children, "UIListLayout"))) and
						scope:New "UIListLayout" {
							FillDirection = Enum.FillDirection.Vertical,
							VerticalAlignment = Enum.VerticalAlignment.Top,
							Padding = UDim.new(0, 4),
							SortOrder = Enum.SortOrder.LayoutOrder
						} or nil :: any,

          children
        }
      })
    }
  }, props))
end)

