--!strict


--> Modules -------------------------------------------------------------------------------------------
local CoreComponents = script.Parent.Core
local Squircle = require(CoreComponents.Squircle)
local TextLabel = require(CoreComponents.TextLabel)

local Modules = script.Parent.Parent.Modules
local Component = require(Modules.Component)
local ComputeMath = require(Modules.ComputeMath)
local ComputeTransforms = require(Modules.ComputeTransforms)
local TableUtils = require(Modules.TableUtils)

local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
type ProgressBarProps = {
  Width: Fusion.UsedAs<UDim>?,
  ProgressPercent: Fusion.UsedAs<number>?,
  Sections: Fusion.UsedAs<number? | { string }?>?,
}
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local ComputeClamp = ComputeMath.Clamp
local ComputeUDim, ComputeUDim2 = ComputeTransforms.UDim, ComputeTransforms.UDim2

local TableTake = TableUtils.Take

local Children = Fusion.Children
-------------------------------------------------------------------------------------------------------


--> Functions -----------------------------------------------------------------------------------------
local function ForRange(scope: Fusion.Scope<typeof(Fusion)>, range: Fusion.UsedAs<number>, fn: (use: Fusion.Use, idx: number) -> Instance)
  return (scope:Computed(function(use)
    local usedRange = use(range)

    local children = table.create(usedRange)
    for idx = 1, usedRange do children[idx] = fn(use, idx) end

    return children
  end) :: any) :: Instance
end


local function SectionTitle(scope: Component.Scope, idx: number, text: string)
  return TextLabel (scope, {
    Text = text,
    Focus = "Title" :: "Title",
    Weight = Enum.FontWeight.SemiBold,
    Size = UDim2.new(1,0, 0,25),
    AutomaticSize = Enum.AutomaticSize.Y,
    TextXAlignment = Enum.TextXAlignment.Center,
    LayoutOrder = idx,
    Name = "Progress:Title",
  })
end

local function ProgressBar(scope: Component.Scope, idx: number, sections: number, progressPercentState: Fusion.Spring<number>)
  local computeLocalProgressPercent = scope:Computed(function(use)
   return math.clamp((use(progressPercentState) / (1 / sections)) - (idx - 1), 0, 1)
  end)

  return Squircle (scope, {
    Size = UDim2.new(1,0, 0,4),
    BackgroundColor3 = scope:GetThemeItem("Accent/Primary"),
    BackgroundTransparency = .65,
    Image = "rbxassetid://104271355998011",
    SliceCenter = Rect.new(8,4,8,4),
    LayoutOrder = idx,
    Name = "Progress:Bar",

    [Children] = Squircle (scope, {
      Size = ComputeUDim2(scope, ComputeUDim(scope, computeLocalProgressPercent, 0), UDim.new(1, 0)),
      BackgroundColor3 = scope:GetThemeItem("Accent/Primary"),
      Image = "rbxassetid://104271355998011",
      SliceCenter = Rect.new(8,4,8,4),
      Name = "Progress:Bar:Inner"
    })
  })
end


local function ProgressList(scope: Component.Scope, name: string, layoutOrder: number, ...: Fusion.Child)
  return scope:New "Frame" {
    Size = UDim2.fromScale(1, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1,
    LayoutOrder = layoutOrder,

    [Children] = {
      ...,

      scope:New "UIListLayout" {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalFlex = Enum.UIFlexAlignment.Fill,
        Padding = UDim.new(0, 4)
      }
    }
  }
end
-------------------------------------------------------------------------------------------------------


return Component(function(scope, props: ProgressBarProps)
  local width, progressPercentState, sections =
    TableTake(props, "Width", UDim.new(1,0)) :: Fusion.UsedAs<UDim>,
    ComputeClamp(scope, TableTake(props, "ProgressPercent", 1), 0, 1) :: Fusion.Computed<number>,
    TableTake(props, "Sections", 1) :: Fusion.UsedAs<number>


  local computeSectionsLength = scope:Computed(function(use)
    local usedSections = use(sections)
    return math.floor(math.max((typeof(usedSections) == "table" and #usedSections or usedSections) :: number, 1))
  end)

  return scope:New "Frame" {
    Size = ComputeUDim2(scope, width, UDim.new(0, 0)),
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1,
    Name = "Progress",

    [Children] = {
      ProgressList(scope, "Progress:Titles", 0, scope:Computed(function(use)
        local usedSections = use(sections)
        if typeof(usedSections) == "number" then return nil end
        return scope:ForPairs(usedSections, function(use, scope, key, value) return key, SectionTitle(scope, key, value) end) :: any
      end)),

      ProgressList(scope, "Progress:Bars", 1, scope:Computed(function(use)
        local usedSections = use(sections)
    
        if typeof(usedSections) == "number" then
          return ForRange(scope, sections, function(use, idx)
            return ProgressBar(scope, idx, use(computeSectionsLength), scope:Spring(progressPercentState, 25, 1))
          end) :: any
    
        else
          return scope:ForPairs(usedSections, function(use, scope, key, value)
            return key, ProgressBar(scope, key, use(computeSectionsLength), scope:Spring(progressPercentState, 25, 1))
          end) :: any
        end
      end)),

      scope:New "UIListLayout" {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 2)
      }
    }
  }
end)