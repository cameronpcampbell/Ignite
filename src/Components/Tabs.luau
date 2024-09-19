--!strict


--> Services ------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------


--> Modules -------------------------------------------------------------------------------------------
local Components = script.Parent
local EmbeddedContainer = require(Components.EmbeddedContainer)
local TextLabel = require(Components.Core.TextLabel)

local Modules = script.Parent.Parent.Modules
local Component = require( Modules.Component)
local ForceToState = require(Modules.ForceToState)
local ComputeTransforms = require(Modules.ComputeTransforms)
local TableUtils = require(Modules.TableUtils)

local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
type TabSection = { Text: Fusion.UsedAs<string>, Icon: Fusion.UsedAs<string>?, Dismissable: Fusion.UsedAs<boolean>? }

type TabsProps = {
  Sections: { TabSection },
  ActiveSection: Fusion.UsedAs<number>?,
  SectionSizing: Fusion.UsedAs<"Fit" | "Fill">?,
  DefaultActiveSection: Fusion.UsedAs<number?>?,
  RightContent: Fusion.Child?
}
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local TableTake = TableUtils.Take
local ComputeUDim2 = ComputeTransforms.UDim2

local Children, OnEvent, peek = Fusion.Children, Fusion.OnEvent, Fusion.peek
-------------------------------------------------------------------------------------------------------


--> Functions -----------------------------------------------------------------------------------------
local function Tab(
  scope: Component.Scope, idx: number, section: TabSection,
  activeSectionState: Fusion.Value<number>, defaultActiveSectionState: Fusion.Value<number>,
  sectionSizing: Fusion.Value<"Fit" | "Fill">
) 
  local isHoverState, isFocusState = scope:Value(false), scope:Value(false)

  local computeIsActive = scope:Computed(function(use) return use(activeSectionState) == idx end)

  local computeBackgroundColor = scope:GetThemeItem(
    scope:Computed(function(use) return use(computeIsActive) and "Background/Primary" or "Background/Secondary" :: any end),
    scope:Computed(function(use) return if use(isFocusState) then "Focus" elseif use(isHoverState) then "Hover" else nil :: any end)
  )

  local computeHeight = scope:Computed(function(use)
    return use(computeIsActive) and UDim.new(1,0) or UDim.new(1,-1)
  end)

  local computePaddingTop = scope:Computed(function(use)
    return use(computeIsActive) and UDim.new(0,0) or UDim.new(0,1)
  end)

  local computeWidth = scope:Computed(function(use)
    return use(sectionSizing) == "Fill" and UDim.new(1,0) or UDim.new(0,0)
  end)

  local computeAutoSize = scope:Computed(function(use)
    return use(sectionSizing) == "Fill" and Enum.AutomaticSize.None or Enum.AutomaticSize.X
  end)

  local computeTextColorItem = scope:Computed(function(use) return use(computeIsActive) and "Title" or "Body" end)

  -- Handles the edge case of the user dragging the cursor off of the tab and then releasing the mouse button.
  scope:AddRootEvent("InputEnded", function() isFocusState:set(false) end)

  return scope:New "ImageButton" {
    Size = ComputeUDim2(scope, computeWidth, computeHeight),
    AutomaticSize = computeAutoSize,
    BackgroundColor3 = computeBackgroundColor,
    ClipsDescendants = true,
    Name = "Tab:Section",

    [OnEvent "MouseButton1Down"] = function() isFocusState:set(true) end,
    [OnEvent "MouseButton1Up"] = function()
      isFocusState:set(false)
      activeSectionState:set(idx)
    end,

    [OnEvent "MouseEnter"] = function() isHoverState:set(true) end,
    [OnEvent "MouseLeave"] = function() isHoverState:set(false) end,

    [Children] = {
      TextLabel(scope, { Text = section.Text, Focus = computeTextColorItem :: any }),

      scope:New "UIPadding" {
        PaddingTop = computePaddingTop,
        PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)
      },

      scope:New "UIListLayout" {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Center
      },
    }
  }
end
-------------------------------------------------------------------------------------------------------


return Component(function(scope, props: TabsProps)
  local width = TableTake(props, "Width", UDim.new(1, 0))
  local sections: { TabSection }, sectionSizing = TableTake(props, "Sections", {}), TableTake(props, "SectionSizing", "Fill")
  local defaultActiveSectionState = TableTake(props, "DefaultActiveSection", 1)
  local activeSectionState = ForceToState(
    scope, TableTake(props, "ActiveSection") or peek(defaultActiveSectionState)
  )
  local rightContent = TableTake(props, "RightContent")

  local computePaddingRight = scope:Computed(function(use)
    return if (use(sectionSizing) == "Fill" and not use(rightContent)) then UDim.new() else UDim.new(0, 1)
  end)

  return EmbeddedContainer(scope, {
    Size = ComputeUDim2(scope, width, UDim.new(0, 25)),
    StrokeBottom = true,
    ChildrenZIndex = 3,
    Name = "Tabs",

    [Children] = {
      scope:New "Frame" {
        BackgroundColor3 = scope:GetThemeItem("Background/Stroke"),
        Size = UDim2.fromScale(1, 1),
        Name = "Tabs:Sections",

        [Children] = {
          scope:ForPairs(sections, function(use, scope, idx, section)
            return idx, Tab(scope, idx, section, activeSectionState, defaultActiveSectionState, sectionSizing)
          end) :: any,
    
          scope:New "UIListLayout" {
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 1)
          },

          scope:New "UIPadding" { PaddingRight = computePaddingRight },

          scope:New "UIFlexItem" { FlexMode = Enum.UIFlexMode.Shrink }
        }
      },

      scope:Computed(function(use)
        return if use(rightContent) then scope:New "Frame" {
          BackgroundTransparency = 1,
          Size = UDim2.fromScale(0, 1),
          AutomaticSize = Enum.AutomaticSize.X,
          Name = "Tabs:RightContent",
  
          [Children] = {
            rightContent,
      
            scope:New "UIListLayout" {
              SortOrder = Enum.SortOrder.LayoutOrder,
              FillDirection = Enum.FillDirection.Horizontal,
              VerticalAlignment = Enum.VerticalAlignment.Center,
              Padding = UDim.new(0, 8)
            },
  
            scope:New "UIPadding" { PaddingRight = UDim.new(0, 8) },
  
            scope:New "UIFlexItem" {  }
          }
        } else nil
      end) :: any,

      scope:New "UIListLayout" {
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
        Padding = UDim.new(0, 8)
      },
    }
  }, props :: any)
end)