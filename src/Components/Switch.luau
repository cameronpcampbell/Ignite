--!strict


--> Modules -------------------------------------------------------------------------------------------
local Modules = script.Parent.Parent.Modules
local Component = require(Modules.Component)
local ComputeTransforms = require(Modules.ComputeTransforms)
local ForceToState = require(Modules.ForceToState)
local TableUtils = require(Modules.TableUtils)
local CombineProps = require(Modules.CombineProps)

local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
type SwitchProps = {
  Enabled: Fusion.UsedAs<boolean>?,
  Size: Fusion.UsedAs<"Small" | "Large">?
}
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local ComputeUDim2FromOffset = ComputeTransforms.UDim2FromOffset

local Children, OnEvent, peek = Fusion.Children, Fusion.OnEvent, Fusion.peek

local TableTake = TableUtils.Take


local OUTER_IMAGE_LARGE, OUTER_IMAGE_SMALL = "rbxassetid://108821029442118", "rbxassetid://70799998969729"
local INNER_IMAGE_LARGE, INNER_IMAGE_SMALL = "rbxassetid://133577879822525", "rbxassetid://107631384534110"

local OUTER_HIGHLIGHT_LARGE, OUTER_HIGHLIGHT_SMALL = "rbxassetid://134592438319778", "rbxassetid://86038953565577"

local OUTER_SIZE_LARGE, OUTER_SIZE_SMALL = UDim2.fromOffset(32, 18), UDim2.fromOffset(24, 14)
local INNER_SIZE_LARGE, INNER_SIZE_SMALL = 14, 10
-------------------------------------------------------------------------------------------------------


return Component(function(scope, props: SwitchProps)
  local size = TableTake(props, "Size", "Large") :: Fusion.UsedAs<"Small" | "Large">
  local enabledState = ForceToState(scope, TableTake(props, "Enabled", scope:Value(true))) :: Fusion.Value<boolean>

  local isHover, isFocus = scope:Value(false), scope:Value(false)

  local computeBackgroundColor = scope:GetThemeItem(
    scope:Computed(function(use) return use(enabledState) and "Accent/Primary" or "Text/Body" end) :: any,
    scope:Computed(function(use) return if use(isFocus) then "Focus" elseif use(isHover) then "Hover" else nil :: any end)
  )

  scope:Observer(isHover):onChange(function()
    print(peek(isHover))
  end)

  local computeOuterImage = scope:Computed(function(use) return use(size) == "Large" and OUTER_IMAGE_LARGE or OUTER_IMAGE_SMALL end)
  local computerInnerImage = scope:Computed(function(use) return use(size) == "Large" and INNER_IMAGE_LARGE or INNER_IMAGE_SMALL end)

  local computeHighlightImage = scope:Computed(function(use) return use(size) == "Large" and OUTER_HIGHLIGHT_LARGE or OUTER_HIGHLIGHT_SMALL end)

  local computeOuterSize = scope:Computed(function(use) return use(size) == "Large" and OUTER_SIZE_LARGE or OUTER_SIZE_SMALL end)

  local computeInnerHeight = scope:Computed(function(use) return use(size) == "Large" and INNER_SIZE_LARGE or INNER_SIZE_SMALL end)
  local computeInnerWidth = scope:Computed(function(use) return use(isFocus) and use(computeInnerHeight) * 1.35 or use(computeInnerHeight) end)

  local computeSliceCenter = scope:Computed(function(use)
    local usedComputeInnerHeight = use(computeInnerHeight)
    return Rect.new(usedComputeInnerHeight, usedComputeInnerHeight, usedComputeInnerHeight, usedComputeInnerHeight)
  end)

  local computeInnerPos = scope:Tween(scope:Computed(function(use)
    return use(enabledState) and UDim2.new(1,-use(computeInnerWidth), .5,0) or UDim2.fromScale(0, .5)
  end), TweenInfo.new(.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))

  -- Handles the edge case of the user dragging the cursor off of the switch and then releasing the mouse button.
  scope:AddRootEvent("InputEnded", function() isFocus:set(false) end)

  return scope:New "ImageButton" (CombineProps({
    Size = computeOuterSize,
    Image = computeOuterImage,
    ImageColor3 = computeBackgroundColor,
    BackgroundTransparency = 1,
    Name = "Switch",

    [OnEvent "MouseEnter"] = function() isHover:set(true) end :: any,
    [OnEvent "MouseLeave"] = function() isHover:set(false) end :: any,

    [OnEvent "MouseButton1Down"] = function() isFocus:set(true) end :: any,
    [OnEvent "MouseButton1Up"] = function() isFocus:set(false) end :: any,

    [OnEvent "MouseButton1Click"] = function() enabledState:set(not peek(enabledState)) end,

    [Children] = {
      scope:New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Name = "Switch:MainContent",

        [Children] = {
          scope:New "ImageLabel" {
            Size = scope:Tween(
              ComputeUDim2FromOffset(scope, computeInnerWidth, computeInnerHeight),
              TweenInfo.new(.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            ),
            Image = computerInnerImage,
            Position = computeInnerPos,
            AnchorPoint = Vector2.new(0, .5),
            ImageColor3 = scope:GetThemeItem("Background/Primary"),
            BackgroundTransparency = 1,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = computeSliceCenter,
            Name = "Switch:Inner"
          },
    
          scope:New "UIPadding" { PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2) }
        }
      },

      scope:New "ImageLabel" {
        Size = UDim2.fromScale(1,1),
        Image = computeHighlightImage,
        BackgroundTransparency = 1,
        Name = "Switch:Highlight"
      },
    }
  }, props))

end)