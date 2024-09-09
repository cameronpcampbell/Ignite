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
local CombineProps = require(Modules.CombineProps)

local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
type AccordionProps = {
  Width: Fusion.UsedAs<UDim>?,
  Sections: {{
    Title: string,
    Content: string
  }},
  ExpandedSection: Fusion.UsedAs<number?>?
}
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local ComputeUDim, ComputeUDim2 = ComputeTransforms.UDim, ComputeTransforms.UDim2

local Children, OnEvent, peek = Fusion.Children, Fusion.OnEvent, Fusion.peek

local TableTake = TableUtils.Take
-------------------------------------------------------------------------------------------------------


--> Functions -----------------------------------------------------------------------------------------
local function AccordionHeader(
  scope: Component.Scope, idx: number, title: string, expandedSectionState: Fusion.Value<number?>, computeIsExpanded: Fusion.Computed<boolean>
)
  return scope:New "ImageButton" {
    Size = ComputeUDim2(scope, UDim.new(1,0), UDim.new(0, 25)),
    BackgroundTransparency = 1,
    LayoutOrder = 0,
    Name = "Accordion:Header",

    [OnEvent "MouseButton1Click"] = function() expandedSectionState:set(not peek(computeIsExpanded) and idx or nil) end,

    [Children] = {
      TextLabel (scope, {
        Text = title,
        Focus = "Title" :: "Title",
        Weight = Enum.FontWeight.SemiBold,
        Size = UDim2.fromScale(0, 1),
        AutomaticSize = Enum.AutomaticSize.X,
        LayoutOrder = 0
      }),

      Arrow (scope, { IsExpanded = computeIsExpanded, Name = "Accordion:Header:Arrow:Image" }),

      scope:New "UIPadding" { PaddingRight = UDim.new(0, 1) },

      scope:New "UIListLayout" {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
        SortOrder = Enum.SortOrder.LayoutOrder
      },
    }
  }
end


local function AccordionItem(
  scope: Component.Scope, idx: number, title: string, content: string | Fusion.Child, expandedSectionState: Fusion.Value<number?>
)
  local computeIsExpanded = scope:Computed(function(use) return use(expandedSectionState) == idx end)

  local contentRef = (scope:Value(nil) :: any) :: Fusion.Value<Instance>
  local contentRefAbsSize = TrackProperty(scope, contentRef, "AbsoluteSize")

  local computeHeight = scope:Computed(function(use)
    if not use(computeIsExpanded) then return 25 end
    local usedContentRefAbsSize = use(contentRefAbsSize)
    if usedContentRefAbsSize then return 25 + usedContentRefAbsSize.Y else return 25 end
  end)

  local computeSize = scope:Tween(
    ComputeUDim2(scope, UDim.new(1,0), ComputeUDim(scope, 0, computeHeight)),
    TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
  )

  -- If accordion item is already expanded when component is created then this workaround prevents it from tweening open.
  local count = 1
  local computeAutoSize = scope:Computed(function(use): Enum.AutomaticSize
    if count > 2 then return Enum.AutomaticSize.None end
    count += 1

    if not use(computeIsExpanded) then count = 3; return Enum.AutomaticSize.None end
    if use(contentRefAbsSize).Y == 8 then return Enum.AutomaticSize.None end

    return Enum.AutomaticSize.Y
  end)

  return Squircle (scope, {
    Size = computeSize,
    AutomaticSize = computeAutoSize,
    Image = "rbxassetid://119543602015658",
    SliceCenter = Rect.new(25, 25, 25, 25),
    SliceScale = .5,
    BackgroundColor3 = scope:GetThemeItem("Background/Stroke", "Highlight"),
    ClipsDescendants = true,
    Name = "Accordion:Item",

    [Children] = {
      AccordionHeader(scope, idx, title, expandedSectionState, computeIsExpanded),

      contentRef:set(
        scope:New "Frame" {
          Size = UDim2.fromScale(1, 0),
          AutomaticSize = Enum.AutomaticSize.Y,
          BackgroundTransparency = 1,
          LayoutOrder = 1,
          Name = "Accordion:Item:Content",
  
          [Children] = {
            TextLabel (scope, {
              Text = content :: string,
              Focus = "Body" :: "Body",
              Size = UDim2.fromScale(1, 0),
              AutomaticSize = Enum.AutomaticSize.Y,
              TextYAlignment = Enum.TextYAlignment.Top,
              LineHeight = 1.1,
              TextWrapped = true,
            }),

            -- AutomaticSize of a child element is clamped if it is larger than the parent's
            -- size unless a UILayout with SpaceBetween is applied to said parent.
            -- (The parent in question here is `Accordion:Item:Content`).
            scope:New "UIListLayout" {
              VerticalFlex = Enum.UIFlexAlignment.SpaceBetween,
              SortOrder = Enum.SortOrder.LayoutOrder
            },
    
            scope:New "UIPadding" { PaddingBottom = UDim.new(0, 7) }
          }
        }
      ),

      scope:New "UIPadding" { PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2) },

      scope:New "UIListLayout" { SortOrder = Enum.SortOrder.LayoutOrder },
    }
  })
end
-------------------------------------------------------------------------------------------------------


return Component(function(scope, props: AccordionProps)
  local width, sections = TableTake(props, "Width", UDim.new(1,0)), TableTake(props, "Sections")
  local expandedSectionState = ForceToState(scope, TableTake(props, "ExpandedSection", scope:Value(false))) :: Fusion.Value<number?>

  return scope:New "Frame" (CombineProps({
    Size = ComputeUDim2(scope, width, UDim.new(0,0)),
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1,
    Name = "Accordion",

    [Children] = {
      (scope:ForPairs(sections, function(use, scope, idx, value)
        return idx, AccordionItem(scope, idx, value.Title, value.Content, expandedSectionState)
      end) :: any) :: Instance,

      scope:New "UIListLayout" {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, -1)
      },
    }
  }, props))
end)