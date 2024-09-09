--!strict


--> Modules -------------------------------------------------------------------------------------------
local Components = script.Parent
local CoreComponents = Components.Core
local Squircle = require(CoreComponents.Squircle)
local TextLabel = require(CoreComponents.TextLabel)
local Arrow = require(CoreComponents.Arrow)

local Modules = script.Parent.Parent.Modules
local Component = require(Modules.Component)
local ComputeTransforms = require(Modules.ComputeTransforms)
local TrackProperty = require(Modules.TrackProperty)
local ForceToState = require(Modules.ForceToState)
local TableUtils = require(Modules.TableUtils)

local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
type HeaderProps = {
  Text: Fusion.UsedAs<string>,
  IsExpanded: Fusion.UsedAs<boolean>?,
  Content: Fusion.UsedAs<Fusion.Child>?,
  Disabled: Fusion.UsedAs<boolean>?
}

type ContainerProps = {
  Width: Fusion.UsedAs<UDim>?,
  Header: HeaderProps?
}
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local ComputeUDim, ComputeUDim2, ComputeTweenInfo = ComputeTransforms.UDim, ComputeTransforms.UDim2, ComputeTransforms.TweenInfo

local TableTake = TableUtils.Take

local Children, OnEvent, peek = Fusion.Children, Fusion.OnEvent, Fusion.peek
-------------------------------------------------------------------------------------------------------


--> Functions -----------------------------------------------------------------------------------------
local function ApplyDefaultIsNil(x: unknown, default)
  return if x == nil then default else x
end

local function RecalculateContainerTweenSpeed(peekedComputeSize: UDim2, peekedContentRefAbsSize: Vector2, tweenSpeedState: Fusion.Value<number>)
  if not peekedComputeSize then return end
  if not peekedContentRefAbsSize then return end

  tweenSpeedState:set((peekedComputeSize.Y.Offset == 25 + peekedContentRefAbsSize.Y) and 0 or .2)
end

local function ContainerHeader(
  scope: Component.Scope, isExpandedState: Fusion.Value<boolean | nil>, computeIsExpanded: Fusion.Computed<boolean | nil>,
  tweenSpeedState: Fusion.Value<number>, headerText: Fusion.UsedAs<string>, headerContent: Fusion.UsedAs<Fusion.Child>
)
  return Squircle (scope, {
    Size = UDim2.new(1,0, 0,25),
    Image = "rbxassetid://93713962247299",
    BackgroundColor3 = scope:GetThemeItem("Background/Tertiary"),
    Name = "Container:Header",

    [Children] = {
      scope:New "Frame" {
        Size = UDim2.fromScale(0, 1),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Name = "Container:Header:Left",

        [Children] = {
          Arrow (scope, {
            IsExpanded = computeIsExpanded,
            CollapsedRotation = -90,
            ExpandedRotation = 0,
            LayoutOrder = 0,
            Name = "Container:Header:Arrow",
    
            [OnEvent "MouseButton1Click"] = function()
              tweenSpeedState:set(.2) -- Makes the containers' height change gradually when collapsing / expanding.
              isExpandedState:set(not peek(isExpandedState))
            end
          }),
    
          TextLabel (scope, {
            Text = headerText or "Container Header",
            Focus = "Title" :: "Title",
            Weight = Enum.FontWeight.SemiBold,
            Size = UDim2.fromScale(0, 1),
            AutomaticSize = Enum.AutomaticSize.X,
            LayoutOrder = 1,
            Name = "Container:Header:Title"
          }),

          scope:New "UIListLayout" {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 7),
          },
        }
      },

      scope:New "Frame" {
        Size = UDim2.fromScale(0, 1),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Name = "Container:Header:Left",

        [Children] = {
          headerContent,

          scope:New "UIListLayout" {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 5),
          },
        }
      },

      scope:New "UIListLayout" {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 7),
      },

      scope:New "UIPadding" {
        PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7),
      }
    }
  })
end
-------------------------------------------------------------------------------------------------------


return Component(function(scope, props: ContainerProps)
  local width, children = TableTake(props, "Width", UDim.new(1, 0)), TableTake(props, Children)
  local backgroundColor3 = TableTake(props, "BackgroundColor3", scope:GetThemeItem("Background/Secondary")) :: Fusion.UsedAs<Color3>

  local header = TableTake(props, "Header") :: HeaderProps?
  local headerDisabled = if header then header.Disabled else false
  local headerText = header and header.Text
  local headerContent = header and header.Content
  local isExpandedState = ForceToState(scope, if header then ApplyDefaultIsNil(header.IsExpanded, true) else true) :: Fusion.Value<boolean | nil>

  local computeHeaderDisabled = scope:Computed(function(use) return if not header then true else use(headerDisabled) end)
  local computeIsExpanded = scope:Computed(function(use) return if use(computeHeaderDisabled) then true else use(isExpandedState) end)

  local tweenSpeedState = scope:Value(if peek(computeHeaderDisabled) or peek(computeIsExpanded) then 0 else .2)

  local contentRef = (scope:Value(nil) :: any) :: Fusion.Value<Instance>
  local contentRefAbsSize = TrackProperty(scope, contentRef, "AbsoluteSize")

  -- When the container is expanded the height should be the header height (25px) plus the height of its children.
  -- When the container is collapsed the height should only be the header height.
  local computeHeight = scope:Computed(function(use)
    local heightOffset = if use(computeHeaderDisabled) then 0 else 25
    if not use(computeIsExpanded) then return heightOffset end

    local usedContentRefAbsSize = use(contentRefAbsSize)
    if not usedContentRefAbsSize then return heightOffset end

    return heightOffset + usedContentRefAbsSize.Y
  end)

  local computeSize = scope:Tween(
    ComputeUDim2(scope, width, ComputeUDim(scope, 0, computeHeight)),
    ComputeTweenInfo(scope, tweenSpeedState, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
  )

  -- If the container has a header then the content wrapper's image should not be rounded on the top (rbxassetid://131049749520663).
  local computeContentWrapperImage = scope:Computed(function(use)
    return use(computeHeaderDisabled) and "rbxassetid://116342589966879" or "rbxassetid://131049749520663"
  end)

  -- Recalculates the container's tween speed (when necessary) so that when it is expanded its size updates instantly.
  if header then
    scope:Observer(computeHeaderDisabled):onChange(function()
      RecalculateContainerTweenSpeed(peek(computeSize), peek(contentRefAbsSize), tweenSpeedState)
    end)

    scope:Observer(computeSize):onChange(function()
      if peek(computeHeaderDisabled) then return tweenSpeedState:set(0) end
      RecalculateContainerTweenSpeed(peek(computeSize), peek(contentRefAbsSize), tweenSpeedState)
    end)
  end

  return Squircle (scope, {
    As = "ImageButton" :: "ImageButton",
    Size = computeSize,
    Image = "rbxassetid://116342589966879",
    BackgroundColor3 = scope:GetThemeItem("Background/Stroke"),
    ClipsDescendants = true,
    Name = "Container",

    [Children] = {
      -- Only shows the header if specified to do so.
      scope:Computed(function(use)
        return not use(computeHeaderDisabled) and ContainerHeader(
          scope, isExpandedState, computeIsExpanded, tweenSpeedState,
          headerText :: Fusion.UsedAs<string>, headerContent :: Fusion.UsedAs<Fusion.Child>
        ) or nil
      end) :: any,

      Squircle (scope, {
        BackgroundColor3 = backgroundColor3,
        Size = scope:Computed(function(use) return if use(computeHeaderDisabled) then UDim2.new(1,0, 1,0) else UDim2.new(1,0, 1,-25) end),
        Position = scope:Computed(function(use) return if use(computeHeaderDisabled) then UDim2.fromScale(0, 0) else UDim2.fromOffset(0, 25) end),
        Image = computeContentWrapperImage,
        Name = "Container:ContentWrapper",

        [Children] = contentRef:set(scope:New "Frame" {
          Size = UDim2.fromScale(1, 0),
          AutomaticSize = Enum.AutomaticSize.Y,
          BackgroundTransparency = 1,
          Name = "Container:Content",
          [Children] = children
        })
      }),

      Squircle (scope, {
        Size = UDim2.fromScale(1, 1),
        Image = "rbxassetid://80646129149756",
        BackgroundColor3 = scope:GetThemeItem("Background/Primary"),
        Name = "Container:Occluder"
      }),

      Squircle (scope, {
        Size = UDim2.fromScale(1, 1),
        Image = "rbxassetid://72425541434885",
        BackgroundColor3 = scope:GetThemeItem("Background/Stroke"),
        Name = "Container:Stroke"
      }),
    }
  }, props :: any)
end)