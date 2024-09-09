--!strict


--> Services ------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------


--> Modules -------------------------------------------------------------------------------------------
local Components = script.Parent
local Squircle = require(Components.Core.Squircle)

local Modules = script.Parent.Parent.Modules
local Component = require(Modules.Component)
local TrackProperty = require(Modules.TrackProperty)
local ForceToState = require(Modules.ForceToState)
local ComputeTransforms = require(Modules.ComputeTransforms)
local TableUtils = require(Modules.TableUtils)
local CombineProps = require(Modules.CombineProps)

local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
type SliderProps = {
  Width: Fusion.UsedAs<UDim>?,
  ProgressPercent: Fusion.UsedAs<number>?,
  Step: Fusion.UsedAs<number>?,
}
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local Children, OnEvent, peek = Fusion.Children, Fusion.OnEvent, Fusion.peek

local _ComputeUDim, ComputeUDim2, ComputeUDim2FromScale = ComputeTransforms.UDim, ComputeTransforms.UDim2, ComputeTransforms.UDim2FromScale

local TableTake = TableUtils.Take

local DraggerSize = 14
-------------------------------------------------------------------------------------------------------


--> Functions -----------------------------------------------------------------------------------------
--[[local function FocusVisual(scope: Component.Scope, isFocusState: Fusion.Value<boolean>)
  local computeSizeOffset = scope:Computed(function(use) return use(isFocusState) and 4 or 8 end)
  local computeSizeUDim = ComputeUDim(scope, 1, computeSizeOffset)

  local computeTransparency = scope:Computed(function(use) return use(isFocusState) and .6 or 1 end)

  return scope:New "ImageLabel" {
    Size = scope:Spring(ComputeUDim2(scope, computeSizeUDim, computeSizeUDim), 20, 1),
    Position = UDim2.fromScale(.5, .5),
    AnchorPoint = Vector2.new(.5, .5),
    Image = "rbxassetid://91473496883985",
    ImageColor3 = ThemeHandlerGet("Accent/Primary"),
    ImageTransparency = computeTransparency,
    BackgroundTransparency = 1,
    Name = "Slider:FocusVisual"
  }
end]]

local function MoveDragger(
  progressPercentState: Fusion.Value<number>, sliderAbsSizeState: Fusion.Value<Vector2>,
  sliderAbsPosState: Fusion.Value<Vector2>, mousePosXState: Fusion.Value<number>
)
  return function(x: number?)
    local peeekdSliderAbsWidth = (peek(sliderAbsSizeState) or Vector2.zero).X
    local peekedSliderAbsPosX = (peek(sliderAbsPosState) or Vector2.zero).X

    -- Gets the relative position along the slider where the dragger should now be.
    local relPosX = math.clamp(
      ((x or peek(mousePosXState)) - peekedSliderAbsPosX) / peeekdSliderAbsWidth,
      0, 1
    )

    progressPercentState:set(relPosX)
  end
end

local function OnDraggerMove(scope: Component.Scope, sliderRef: Fusion.Value<ImageButton>, moveDragger: (x: number?) -> nil)
  return function()
    moveDragger()

    local removeUpdateDraggerPosConn = scope:AddRootEvent("MouseMoved", moveDragger)

    local removeStopDraggingConn: () -> nil, draggerButton1UpConn: RBXScriptConnection, pluginMouseMoveConn: RBXScriptConnection = nil, nil, nil

    local function stopDragging()
      removeStopDraggingConn()
      draggerButton1UpConn:Disconnect()
      pluginMouseMoveConn:Disconnect()
      removeUpdateDraggerPosConn()
    end

    draggerButton1UpConn = peek(sliderRef).MouseButton1Up:Connect(stopDragging)
    removeStopDraggingConn = scope:AddRootEvent("InputEnded", stopDragging)
    pluginMouseMoveConn = scope:GetPlugin():GetMouse().Move:Connect(stopDragging)
  end
end
-------------------------------------------------------------------------------------------------------


return Component(function(scope, props: SliderProps)
  local width, progressPercentState, _stepSize =
    TableTake(props, "Width", UDim.new(1,0)) :: Fusion.UsedAs<UDim>,
    ForceToState(scope, TableTake(props, "ProgressPercent", 0)) :: Fusion.Value<number>,
    TableTake(props, "StepSize") :: Fusion.UsedAs<number>

  local sliderRef = (scope:Value(nil) :: any) :: Fusion.Value<Instance>
  local sliderAbsSizeState, sliderAbsPosState =
    TrackProperty(scope, sliderRef, "AbsoluteSize") :: Fusion.Value<Vector2>, TrackProperty(scope, sliderRef, "AbsolutePosition") :: Fusion.Value<Vector2>

  local mousePosXState = scope:Value(0)

  local moveDragger = MoveDragger(progressPercentState, sliderAbsSizeState, sliderAbsPosState, mousePosXState)

  return sliderRef:set(
    scope:New "ImageButton" (CombineProps({
      Size = ComputeUDim2(scope, width, UDim.new(0, 14)),
      BackgroundTransparency = 1,
      Name = "Slider",

      [OnEvent "MouseButton1Down"] = OnDraggerMove(scope, (sliderRef :: any) :: Fusion.Value<ImageButton>, moveDragger),

      [OnEvent "MouseMoved"] = function(x: number) mousePosXState:set(x) end,
  
      [Children] = {
        Squircle (scope, {
          Size = UDim2.new(1,0, 0,4),
          Position = UDim2.fromScale(0, .5),
          AnchorPoint = Vector2.new(0, .5),
          BackgroundColor3 = scope:GetThemeItem("Accent/Primary"),
          BackgroundTransparency = .65,
          Image = "rbxassetid://104271355998011",
          SliceCenter = Rect.new(8,4,8,4),
          Name = "Slider:Background",
  
          [Children] = Squircle (scope, {
            Size = ComputeUDim2FromScale(scope, progressPercentState, 1),
            BackgroundColor3 = scope:GetThemeItem("Accent/Primary"),
            Image = "rbxassetid://104271355998011",
            SliceCenter = Rect.new(8,4,8,4),
            Name = "Slider:Progress"
          })
        }),

        scope:New "Frame" {
          Size = UDim2.new(1,-DraggerSize, 1,0),
          BackgroundTransparency = 1,
          Name = "Slider:DragBounds",

          [Children] = scope:New "ImageLabel" {
            Size = UDim2.fromOffset(DraggerSize, DraggerSize),
            Position = ComputeUDim2FromScale(scope, progressPercentState, 0),
            Image = "rbxassetid://114187647106547",
            BackgroundTransparency = 1,
            ImageColor3 = scope:GetThemeItem("Accent/Primary"),
            Name = "Dragger",
      
            [Children] = {
              scope:New "ImageLabel" {
                Size = UDim2.fromScale(1, 1),
                Image = "rbxassetid://128086402167912",
                BackgroundTransparency = 1,
                ImageColor3 = scope:GetThemeItem("Background/Primary"),
                Name = "Dragger:Inner",
              },

              scope:New "ImageLabel" {
                Size = UDim2.fromScale(1, 1),
                Image = "rbxassetid://71078180733332",
                BackgroundTransparency = 1,
                Name = "Dragger:Highlight",
              },

              --FocusVisual(scope, scope:Value(true)),
            }
          }
        },
  
  
      }
    }, props))
  )
end)