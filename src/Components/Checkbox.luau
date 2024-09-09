--!strict


--> Modules -------------------------------------------------------------------------------------------
local Components = script.Parent
local CoreComponents = Components.Core
local Squircle = require(CoreComponents.Squircle)

local Modules = script.Parent.Parent.Modules
local Component = require(Modules.Component)
local ForceToState = require(Modules.ForceToState)
local TableUtils = require(Modules.TableUtils)

local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
type CheckboxProps = {
  Enabled: Fusion.UsedAs<boolean?>?
}
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local TableTake = TableUtils.Take

local Children, OnEvent, peek = Fusion.Children, Fusion.OnEvent, Fusion.peek
-------------------------------------------------------------------------------------------------------


--> Functions -----------------------------------------------------------------------------------------
local function ToggleCheckboxState(enabledState: Fusion.Value<boolean | nil>)
  local peekedEnabledState = peek(enabledState)
  if peekedEnabledState == nil then return enabledState:set(false) end
  return enabledState:set(not peekedEnabledState)
end
-------------------------------------------------------------------------------------------------------


return Component(function(scope, props: CheckboxProps)
  local enabledState = ForceToState(scope, TableTake(props, "Enabled")) :: Fusion.Value<boolean | nil>

  local isHover, isFocus = scope:Value(false), scope:Value(false)

  local computeBackgroundColor = scope:GetThemeItem(
    scope:Computed(function(use) return use(enabledState) and "Accent/Primary" or "Text/Title" :: any end),
    scope:Computed(function(use) return if use(isFocus) then "Focus" elseif use(isHover) then "Hover" else nil :: any end)
  )

  local computeBackgroundImage = scope:Computed(function(use)
    return use(enabledState) and "rbxassetid://111856568778648" or "rbxassetid://99112086620798"
  end)

  local computeHighlightTransparency = scope:Computed(function(use)
    return use(enabledState) and 0 or 1
  end)

  local computeIconImage = scope:Computed(function(use)
    local usedEnabledState = use(enabledState)
    if usedEnabledState then return "rbxassetid://127602172649231" end
    if usedEnabledState == nil then return "rbxassetid://122746041789674" end
    return ""
  end)

  return Squircle (scope, {
    Image = computeBackgroundImage,
    BackgroundColor3 = computeBackgroundColor,
    As = "ImageButton" :: "ImageButton",
    Size = UDim2.fromOffset(14, 14),
    SliceCenter = Rect.new(13,13,13,13),
    Name = "Checkbox",

    [OnEvent "MouseEnter"] = function() isHover:set(true) end :: any,
    [OnEvent "MouseLeave"] = function() isHover:set(false) end :: any,

    [OnEvent "MouseButton1Down"] = function() isFocus:set(true) end :: any,
    [OnEvent "MouseButton1Up"] = function() isFocus:set(false) end :: any,

    [OnEvent "MouseButton1Click"] = function() ToggleCheckboxState(enabledState) end,

    [Children] = {
      Squircle (scope, {
        BackgroundTransparency = computeHighlightTransparency,
        Size = UDim2.fromScale(1, 1),
        SliceCenter = Rect.new(13,13,13,13),
        Image = "rbxassetid://122683221801312",
        Name = "Checkbox:Highlight"
      }),

      scope:New "ImageLabel" {
        Image = computeIconImage,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Name = "Checkbox:Icon"
      }
    } :: any
  })
end)