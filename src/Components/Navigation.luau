--!strict


--> Modules -------------------------------------------------------------------------------------------
local Components = script.Parent
local CoreComponents = Components.Core
local Squircle = require(CoreComponents.Squircle)

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
type NavigationProps = {
  Sections: { Component.DynamicSection },
  ActiveSection: Fusion.UsedAs<number>?,
  DefaultActiveSection: Fusion.UsedAs<number?>?,
  FillDirection: Fusion.UsedAs<Enum.FillDirection>?
}
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local ComputeTweenInfo = ComputeTransforms.TweenInfo

local TableTake = TableUtils.Take

local Children, OnEvent, peek = Fusion.Children, Fusion.OnEvent, Fusion.peek
-------------------------------------------------------------------------------------------------------


--> Functions -----------------------------------------------------------------------------------------
local function HandleNavigationSectionContentSize(
  scope: Component.Scope, contentSizeState: Fusion.Value<UDim2>,
  contentAutoSizeState: Fusion.Value<Enum.AutomaticSize>, content: Fusion.UsedAs<GuiObject>
)
  local peekedContent = peek(content)
  if peekedContent then
    contentSizeState:set(peekedContent.Size)
    contentAutoSizeState:set(peekedContent.AutomaticSize)
    peekedContent.Size = UDim2.fromScale(1, 1)
  end
  peekedContent = nil :: any

  if typeof(content) == "table" and content.kind == "Value" then
    scope:Observer(content):onChange(function()
      local peekedContent = peek(content)
      contentSizeState:set(peekedContent.Size)
      contentAutoSizeState:set(peekedContent.AutomaticSize)
      peekedContent.Size = UDim2.fromScale(1, 1)
    end)
  end
end

local function NavigationSection(
  scope: Component.Scope, idx: number, activeSectionState: Fusion.Value<number?>, defaultActiveSection: Fusion.UsedAs<number?>,
  hoveredSectionState: Fusion.Value<number?>, isHoverState: Fusion.Value<boolean>, isFirstHoverState: Fusion.Value<boolean>, content: string
)
  local computeIsActive = scope:Computed(function(use): boolean? return use(activeSectionState) == idx end)

  local computeTransparency = scope:Tween(
    scope:Computed(function(use) return use(computeIsActive) and .78 or 1 end),
    TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
  )

  if typeof(peek(content)) == "string" then
    content = scope:New "TextLabel" {
      Size = UDim2.new(0,0, 0,25),
      AutomaticSize = Enum.AutomaticSize.X,
      FontFace = Font.fromId(16658221428, Enum.FontWeight.Medium),
      Text = content,
      TextSize = 14,
      TextColor3 = scope:GetThemeItem("Text/Title"),
      BackgroundTransparency = 1,
  
      [Children] = {
        scope:New "UIPadding" {
          PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7)
        }
      }
    } :: any
  end

  -- Wrapping the content element with another UI element may mess up its Size so we need to propagate the size and AutomaticSize properties
  -- to the wrapper element and then set the size of the content element to `UDim2.fromScale(1,1)` so that it fills the wrapper element. 
  local contentSizeState, contentAutoSizeState = scope:Value(UDim2.new()), scope:Value(Enum.AutomaticSize.None)
  HandleNavigationSectionContentSize(scope, contentSizeState, contentAutoSizeState, (content :: any) :: Fusion.UsedAs<GuiObject>)

  return Squircle (scope, {
    As = "ImageButton" :: "ImageButton",
    Size = contentSizeState,
    AutomaticSize = contentAutoSizeState,
    BackgroundColor3 = scope:GetThemeItem("Text/Title"),
    BackgroundTransparency = computeTransparency,
    Name = "Navigation:Section",

    [OnEvent "MouseButton1Click"] = function()
      local peekedActiveSection = peek(activeSectionState)

      -- Deselecting.
      if peekedActiveSection == idx then
        local peekedDefaultActiveSection = peek(defaultActiveSection)
        if peekedDefaultActiveSection and peekedActiveSection == peekedDefaultActiveSection and idx == peekedDefaultActiveSection then return end
        activeSectionState:set(peekedDefaultActiveSection or nil)
        isHoverState:set(true)
        isFirstHoverState:set(false)
        hoveredSectionState:set(idx)

      -- Selecting.
      else
        activeSectionState:set(idx)
        isHoverState:set(false)
        isFirstHoverState:set(true)
      end
     
    end :: any,

    [OnEvent "MouseEnter"] = function()
      if peek(computeIsActive) then
        isHoverState:set(false)
        isFirstHoverState:set(true)
      else
        isHoverState:set(true)
        hoveredSectionState:set(idx)
        isFirstHoverState:set(false)
      end
    end :: any,

    [Children] = {
      Squircle (scope, {
        Size = UDim2.fromScale(1, 1),
        Image = "rbxassetid://108824901287727",
        BackgroundTransparency = computeTransparency,
        Name = "Navigation:Section:Highlight"
      }),

      content :: any
    }
  })
end
-------------------------------------------------------------------------------------------------------


return Component(function(scope, props: NavigationProps)
  local sections, defaultActiveSection: Fusion.UsedAs<number?>, fillDirection: Fusion.UsedAs<Enum.FillDirection> =
    TableTake(props, "Sections"), TableTake(props, "DefaultActiveSection"), TableTake(props, "FillDirection", Enum.FillDirection.Horizontal)
  local activeSectionState: Fusion.Value<number?> = ForceToState(scope, TableTake(props, "ActiveSection", peek(defaultActiveSection) or false)) :: any

  local navigationRef: Fusion.Value<Instance> = scope:Value(nil :: any)

  local hoveredSectionState: Fusion.Value<number?> = scope:Value(nil)
  local isFirstHoverState: Fusion.Value<boolean> = scope:Value(true)
  local isHoverState = scope:Value(false)

  local sectionInstances = scope:ForPairs(sections, function(use, scope, idx, content)
    return idx, NavigationSection(scope, idx, activeSectionState, defaultActiveSection, hoveredSectionState, isHoverState, isFirstHoverState, content)
  end)

  local tweenSpeed = scope:Computed(function(use) return (use(isFirstHoverState) and 0) or (use(isHoverState) and .2 or 0) end)
  local computeTransformsTweenInfo = ComputeTweenInfo(scope, tweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

  local computeHoverSize = scope:Tween(scope:Computed(function(use): UDim2
    local usedHoveredSectionIdx = use(hoveredSectionState)
    if not usedHoveredSectionIdx then return UDim2.new() end

    local hoverSizeAbs = (use(sectionInstances)[usedHoveredSectionIdx] :: GuiBase2d).AbsoluteSize
    return UDim2.fromOffset(hoverSizeAbs.X, hoverSizeAbs.Y)
  end), computeTransformsTweenInfo)

  local computeHoverPos = scope:Tween(scope:Computed(function(use): UDim2
    local usedHoveredSectionIdx = use(hoveredSectionState)
    if not usedHoveredSectionIdx then return UDim2.new() end

    local usedNavigationRef = (use(navigationRef) :: any) :: Frame?
    if not usedNavigationRef then return UDim2.new() end
    local usedNavigationRefAbsPos = usedNavigationRef.AbsolutePosition
    
    local hoverPosAbs = (use(sectionInstances)[usedHoveredSectionIdx] :: GuiBase2d).AbsolutePosition
    return UDim2.fromOffset(hoverPosAbs.X - usedNavigationRefAbsPos.X, hoverPosAbs.Y - usedNavigationRefAbsPos.Y)
  end), computeTransformsTweenInfo)

  local computeHoverTransparency = scope:Tween(
    scope:Computed(function(use) return use(isHoverState) and .92 or 1 end),
    TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
  )

  return navigationRef:set(scope:New "Frame" (CombineProps({
    AutomaticSize = Enum.AutomaticSize.XY,
    BackgroundTransparency = 1,

    [OnEvent "MouseLeave"] = function()
      isHoverState:set(false)
      isFirstHoverState:set(true)
    end,

    [Children] = {
      Squircle (scope, {
        Size = computeHoverSize,
        Position = computeHoverPos,
        Transparency = computeHoverTransparency,
        BackgroundColor3 = scope:GetThemeItem("Text/Title"),
        ZIndex = 0,
        Name = "Navigation:Hover"
      }),

      scope:New "Frame" {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        ZIndex = 1,
        Name = "Navigation:Items",
    
        [Children] = {
          sectionInstances :: any,

          scope:New "UIListLayout" {
            FillDirection = fillDirection,
            HorizontalFlex = scope:Computed(function(use)
              return use(fillDirection) == Enum.FillDirection.Horizontal and Enum.UIFlexAlignment.Fill or Enum.UIFlexAlignment.None
            end),
          }
        }
      }
    }
  }, props)))
end)