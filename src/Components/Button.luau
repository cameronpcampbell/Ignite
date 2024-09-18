--!strict


--> Services ------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------


--> Modules -------------------------------------------------------------------------------------------
local Modules = script.Parent.Parent.Modules
local Component = require(Modules.Component)
local ComputeTransforms = require(Modules.ComputeTransforms)
local TableUtils = require(Modules.TableUtils)

local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)

local Components = Modules.Parent.Components
local CoreComponents = Components.Core
local Squircle = require(CoreComponents.Squircle)
local TextLabel = require(CoreComponents.TextLabel)
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
type ButtonProps = {
  Width: Fusion.UsedAs<UDim | "Auto">?,
  Content: Fusion.UsedAs<{ string } | string>?,
  Variant: ("Primary" | "Secondary" | "Destructive")?
}
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local ComputeUDim2 = ComputeTransforms.UDim2

local TableTake = TableUtils.Take

local Children, OnEvent = Fusion.Children, Fusion.OnEvent
-------------------------------------------------------------------------------------------------------


--> Private Functions ---------------------------------------------------------------------------------
local function ParseContentItem(scope: Component.Scope, item: string)
  local imageId = string.match(item, "rbxassetid://%d+")
  
  if imageId then
    return scope:New "ImageLabel" {
      Size = UDim2.fromOffset(9, 9),
      BackgroundTransparency = 1,
      ImageColor3 = scope:GetThemeItem("Text/Title"),
      Image = imageId
    }
  end

  return TextLabel (scope, {
    Text = item,
    Focus = "Title" :: "Title",
    Weight = Enum.FontWeight.SemiBold,
    Size = UDim2.fromScale(0, 1),
    AutomaticSize = Enum.AutomaticSize.X,
    TextXAlignment = Enum.TextXAlignment.Center
  })
end
-------------------------------------------------------------------------------------------------------


return Component(function(scope, props: ButtonProps)
  local width = TableTake(props, "Width", UDim.new(1,0)) :: Fusion.UsedAs<UDim>
  local content = TableTake(props, "Content", "Button") :: Fusion.UsedAs<{ string } | string>
  local variant = TableTake(props, "Variant", "Primary") :: Fusion.UsedAs<"Primary" | "Secondary" | "Destructive">

  local isHoverState, isFocusState = scope:Value(false), scope:Value(false)

  -- We need to ensure that `content` is an array so it can be used with `ForPairs`
  local computeContentArray = scope:Computed(function(use)
    local usedContent = use(content)
    return if type(usedContent) == "table" then usedContent else { usedContent }
  end)

  -- Width may be "Auto" therefore we need to make the width of the button `UDim.new()` when this is the case.
  local computeUDimWidth = scope:Computed(function(use)
    local usedWidth = use(width)
    return if usedWidth == "Auto" then UDim.new() else usedWidth
  end)

  local computeAutoSize = scope:Computed(function(use)
    return if use(width) == "Auto" then Enum.AutomaticSize.X else Enum.AutomaticSize.None
  end)

  local computeBackgroundColor = scope:GetThemeItem(
    scope:Computed(function(use) return `Accent/{use(variant) or "Primary"}` :: any end),
    scope:Computed(function(use) return if use(isFocusState) then "Focus" elseif use(isHoverState) then "Hover" else nil :: any end)
  )

  -- Handles the edge case of the user dragging the cursor off of the button and then releasing the mouse button.
  scope:AddRootEvent("InputEnded", function() isFocusState:set(false) end)

  return Squircle (scope, {
    As = "ImageButton" :: "ImageButton",
    Size = ComputeUDim2(scope, computeUDimWidth, UDim.new(0, 25)),
    AutomaticSize = computeAutoSize,
    BackgroundColor3 = computeBackgroundColor,
    ClipsDescendants = true,
    Name = "Button",

    [OnEvent "MouseEnter"] = function() isHoverState:set(true) end :: any,
    [OnEvent "MouseLeave"] = function() isHoverState:set(false) end :: any,

    [OnEvent "MouseButton1Down"] = function() isFocusState:set(true) end :: any,
    [OnEvent "MouseButton1Up"] = function() isFocusState:set(false) end :: any,

    [Children] = {
      Squircle (scope, {
        Size = UDim2.fromScale(1, 1),
        Image = "rbxassetid://108824901287727",
        Name = "Button:Highlight"
      }),

      scope:New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Name = "Button:ContentWrapper",

        [Children] = {
          scope:ForPairs(computeContentArray, function(use, scope, idx, item)
            return idx, ParseContentItem(scope, item)
          end) :: any,

          scope:New "UIListLayout" {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8)
          },
    
          scope:New "UIPadding" { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) },
        }
      }
    }
  }, props :: any)
end)