--!strict


--> Modules -------------------------------------------------------------------------------------------
local Components = script.Parent
local Container = require(Components.Container)
local TextInput = require(Components.TextInput)

local CoreComponents = Components.Core
local TextLabel = require(CoreComponents.TextLabel)
local Squircle = require(CoreComponents.Squircle)

local Modules = script.Parent.Parent.Modules
local Component = require(Modules.Component)
local TrackProperty = require(Modules.TrackProperty)
local ForceToState = require(Modules.ForceToState)
local TableUtils = require(Modules.TableUtils)

local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
type OnItemUpdateFn = (itemName: string, itemIdx: number, newValue: unknown, oldValue: unknown) -> ()

type MapValueProps =
  Fusion.UsedAs<string>--[[ | Fusion.UsedAs<boolean> | Fusion.UsedAs<EnumItem>]] |
  {
    Text: Fusion.UsedAs<string>?,
    Placeholder: Fusion.UsedAs<string>?,
    Validation: TextInput.ValidationProps?
  }

type MapProps = {
  Header: Container.HeaderProps?,
  Sections: {{ Key: string, Value: MapValueProps }},

  ["@OnItemUpdate"]: OnItemUpdateFn?
}
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local Children, OnEvent, peek = Fusion.Children, Fusion.OnEvent, Fusion.peek

local TableTake = TableUtils.Take

local IMAGE_KEY_BOTTOM, IMAGE_KEY_TOP, IMAGE_KEY_SOLO =
  "rbxassetid://130737618977026", "rbxassetid://90426745217576", "rbxassetid://132086360563600"
local IMAGE_KEY_BOTTOM_STROKE, IMAGE_KEY_TOP_STROKE, IMAGE_KEY_SOLO_STROKE =
  "rbxassetid://95022398903594", "rbxassetid://94720840277798", "rbxassetid://136153743765334"

local IMAGE_VALUE_BOTTOM, IMAGE_VALUE_TOP, IMAGE_VALUE_SOLO =
  "rbxassetid://133800092992868", "rbxassetid://123833703714055", "rbxassetid://95895141756049"
local IMAGE_VALUE_BOTTOM_STROKE, IMAGE_VALUE_TOP_STROKE, IMAGE_VALUE_SOLO_STROKE =
  "rbxassetid://123891250075098", "rbxassetid://125766254710634", "rbxassetid://94176076719291"
local IMAGE_VALUE_BOTTOM_FOCUS, IMAGE_VALUE_TOP_FOCUS, IMAGE_VALUE_SOLO_FOCUS =
  "rbxassetid://80207168749216", "rbxassetid://108901529727203", "rbxassetid://108367553025401"

local IMAGE_MID_FOCUS = "rbxassetid://113349926010177"
local IMAGE_MID, IMAGE_MID_STROKE = "rbxassetid://71155288687975", "rbxassetid://112998806065140"
-------------------------------------------------------------------------------------------------------


--> Functions -----------------------------------------------------------------------------------------
local function MapKey(
  scope: Component.Scope, key: string, isFocusState: Fusion.Value<boolean>,
  computeSectionsLength: Fusion.Computed<number>, computeAdjustedIdx: Fusion.Computed<number>, headerDisabled: Fusion.UsedAs<boolean>?
)
  local image = scope:Computed(function(use)
    local usedAdjIdx, usedItemsLength = use(computeAdjustedIdx), use(computeSectionsLength)
    return
      if usedItemsLength == 1 then IMAGE_KEY_SOLO
      elseif usedAdjIdx == 1 then IMAGE_KEY_TOP
      elseif usedAdjIdx == usedItemsLength then IMAGE_KEY_BOTTOM
      else IMAGE_MID
  end)

  local strokeImage = scope:Computed(function(use)
    local usedAdjIdx, usedItemsLength = use(computeAdjustedIdx), use(computeSectionsLength)
    return
      if usedItemsLength == 1 then IMAGE_KEY_SOLO_STROKE
      elseif usedAdjIdx == 1 then IMAGE_KEY_TOP_STROKE
      elseif usedAdjIdx == usedItemsLength then IMAGE_KEY_BOTTOM_STROKE
      else IMAGE_MID_STROKE
  end)

  return scope:New "Frame" {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,

    [Children] = {
      Squircle(scope, {
        Size = UDim2.new(1,2, 0,25),
        Position = UDim2.fromScale(.5, .5),
        AnchorPoint = Vector2.new(.5, .5),
        BackgroundColor3 = scope:GetThemeItem("Background/Secondary"),
        ClipsDescendants = true,
        Image = image,
    
        [Children] = {
          Squircle(scope, {
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = scope:GetThemeItem("Background/Stroke"),
            Image = strokeImage,
          }),

          scope:New "Frame" {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,

            [Children] = {
              TextLabel(scope, {
                Size = UDim2.fromScale(1, 1),
                Text = key,
            
                [Children] = {
                  scope:New "UIPadding" { PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 8) }
                }
              })
            }
          }
        }
      }),

      scope:New "UIFlexItem" { FlexMode = Enum.UIFlexMode.Fill },
    }
  }
end

local function MapValue(
  scope: Component.Scope, key: string, value: MapValueProps, isHoverState: Fusion.Value<boolean>, isFocusState: Fusion.Value<boolean>,
  computeSectionsLength: Fusion.Computed<number>, idx: number, computeAdjustedIdx: Fusion.Computed<number>, headerDisabled: Fusion.UsedAs<boolean>?,
  onItemUpdateFn: OnItemUpdateFn?
)
  local valueIsPropsArray = type(value) == "table" and not (value :: any).kind
  local valueText: Fusion.Value<string> = if valueIsPropsArray then (value :: any).Text else value
  local valuePlaceholder = valueIsPropsArray and (value :: any).Placeholder or nil
  local valueValidation = valueIsPropsArray and (value :: any).Validation or nil

  local image = scope:Computed(function(use)
    local usedAdjIdx, usedItemsLength = use(computeAdjustedIdx), use(computeSectionsLength)
    return
      if usedItemsLength == 1 then IMAGE_VALUE_SOLO
      elseif usedAdjIdx == 1 then IMAGE_VALUE_TOP
      elseif usedAdjIdx == usedItemsLength then IMAGE_VALUE_BOTTOM
      else IMAGE_MID
  end)

  local strokeImage = scope:Computed(function(use)
    local usedAdjIdx, usedItemsLength = use(computeAdjustedIdx), use(computeSectionsLength)
    return
      if usedItemsLength == 1 then IMAGE_VALUE_SOLO_STROKE
      elseif usedAdjIdx == 1 then IMAGE_VALUE_TOP_STROKE
      elseif usedAdjIdx == usedItemsLength then IMAGE_VALUE_BOTTOM_STROKE
      else IMAGE_MID_STROKE
  end)

  local focusImage = scope:Computed(function(use)
    local usedAdjIdx, usedItemsLength = use(computeAdjustedIdx), use(computeSectionsLength)
    return
      if usedItemsLength == 1 then IMAGE_VALUE_SOLO_FOCUS
      elseif usedAdjIdx == 1 then IMAGE_VALUE_TOP_FOCUS
      elseif usedAdjIdx == usedItemsLength then IMAGE_VALUE_BOTTOM_FOCUS
      else IMAGE_MID_FOCUS
  end)

  local lastValue = peek(value)

  return scope:New "Frame" {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,

    [Children] = {
      Squircle(scope, {
        Size = UDim2.new(1,2, 0,25),
        Position = UDim2.fromScale(.5, .5),
        AnchorPoint = Vector2.new(.5, .5),
        BackgroundColor3 = scope:GetThemeItem("Background/Secondary"),
        Image = image,
    
        [Children] = {
          scope:New "Frame" {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,

            [Children] = {
              (TextInput(scope, {
                Size = UDim2.fromScale(1, 1),
                Value = valueText,
                BackgroundTransparency = 0,
                IsHover = isHoverState,
                IsFocus = isFocusState,
                StrokeImage = strokeImage,
                FocusImage = focusImage,
                Placeholder = valuePlaceholder,
                Validation = valueValidation,

                [OnEvent "FocusLost"] = onItemUpdateFn and function()
                  local peekedValue = peek(value)
                  if lastValue == peekedValue then return end
                  onItemUpdateFn(key, idx, peekedValue, lastValue)
                  
                  lastValue = peekedValue
                end or nil
              }))
            }
          }
        }
      }),

      scope:New "UIFlexItem" { FlexMode = Enum.UIFlexMode.Fill },
    }
  }
end

local function MapPair(
  scope: Component.Scope, key: string, value: MapValueProps, computeSectionsLength: Fusion.Computed<number>,
  idx: number, headerDisabled: Fusion.UsedAs<boolean>?, onItemUpdateFn: OnItemUpdateFn?
)
  local isHoverState, isFocusState = scope:Value(false), scope:Value(false)
  local computeAdjustedIdx = scope:Computed(function(use) return use(headerDisabled) and idx or idx + 1 end)

  return scope:New "Frame" {
    ZIndex = scope:Computed(function(use) return if use(isFocusState) then 999 elseif use(isHoverState) then 998 else 0 end),
    Size = UDim2.new(1,0, 0,23),
    BackgroundTransparency = 1,
    Name = "Map:Pair",

    [Children] = {
      MapKey(scope, key, isFocusState, computeSectionsLength, computeAdjustedIdx, headerDisabled),
      MapValue(scope, key, value, isHoverState, isFocusState, computeSectionsLength, idx, computeAdjustedIdx, headerDisabled, onItemUpdateFn),

      scope:New "UIListLayout" {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 1)
      }
    }
  }
end
-------------------------------------------------------------------------------------------------------

return Component(function(scope, props: MapProps)
  local header: Container.HeaderProps?, sections = TableTake(props, "Header"), TableTake(props, "Sections", {})
  local onItemUpdateFn: OnItemUpdateFn? = TableTake(props, "@OnItemUpdate")

  local headerDisabled = if header then header.Disabled else true

  local computeSectionsLength = scope:Computed(function(use)
    return use(headerDisabled) and #use(sections) or #use(sections) + 1
  end)

  local containerRef: Fusion.Value<Instance> = scope:Value(nil :: any)
  local computeContainerAbsSize = TrackProperty(scope, containerRef, "AbsoluteSize")

  local computeIsOpen = scope:Computed(function(use)
    local usedContainerAbsSize: Vector2 = use(computeContainerAbsSize)
    if not usedContainerAbsSize then return true end
    local containerAbsHeight = usedContainerAbsSize.Y

    local usedItemsLength = use(computeSectionsLength)
    return containerAbsHeight == (25 * usedItemsLength) - (usedItemsLength - 1)
  end)

  -- We need to force all of the `Value` properties of each section to be state objects.
  for _,data in sections do
    local dataValue = data.Value
    if type(dataValue) == "table" and not dataValue.kind then
      dataValue.Text = ForceToState(scope, dataValue.Text)
    else
      data.Value = ForceToState(scope, dataValue)
    end
  end

  return containerRef:set(Container(scope, {
    Header = header,
    BackgroundColor3 = scope:GetThemeItem("Background/Stroke"),
    ChildrenZIndex = 1000,
    ClipsDescendants = scope:Computed(function(use) return if use(computeIsOpen) then false else true end),
    OccluderZIndex = scope:Computed(function(use) return if use(computeIsOpen) then 999 else 1001 end),

    [Children] = {
      scope:ForPairs(sections, function(use, scope, idx, data)
        return idx, MapPair(scope, data.Key, data.Value, computeSectionsLength, idx, headerDisabled, onItemUpdateFn)
      end) :: Fusion.Child,

      scope:New "UIListLayout" {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 1)
      },

      scope:New "UIPadding" {
        PaddingLeft = UDim.new(0, 1), PaddingRight = UDim.new(0, 1),
        PaddingTop = scope:Computed(function(use) return UDim.new(0, use(headerDisabled) and 1 or 0) end), PaddingBottom = UDim.new(0, 1)
      }
    }
  }, props :: any))
end)