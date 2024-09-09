--!strict


--> Services ------------------------------------------------------------------------------------------
local StarterGui = game:GetService("StarterGui")
-------------------------------------------------------------------------------------------------------


--> Modules -------------------------------------------------------------------------------------------
local Modules = script.Parent.Parent.Modules
local RootEventHandlersUtils = require(Modules.RootEventHandlersUtils)
local Component = require( Modules.Component)

local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)

local Components = script.Parent.Parent.Components
local Background = require(Components.Background)
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
type WindowSettingsProps = {
	Id: string,
  Title: (string | Fusion.Value<string> | Fusion.Computed<string>)?,
	InitDockState: Enum.InitialDockState?,
	InitEnabled: boolean?,
	OverrideEnabledRestore: boolean?,
	FloatXSize: number?,
	FloatYSize: number?,
	MinWidth: number?,
	MinHeight: number?,
	DebugMode: boolean?
}
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local AddRootToHandler = RootEventHandlersUtils.AddRootToHandler

local Children = Fusion.Children
-------------------------------------------------------------------------------------------------------


return Component(function(scope, props: WindowSettingsProps)
  local id, title, initDockState, initEnabled, overrideEnabledRestore, floatXSize, floatYSize, minWidth, minHeight, debugMode = 
	  props.Id, props.Title, props.InitDockState, props.InitEnabled, props.OverrideEnabledRestore,
    props.FloatXSize, props.FloatYSize, props.MinWidth, props.MinHeight, props.DebugMode

  local widget = scope:GetPlugin():CreateDockWidgetPluginGui(id, DockWidgetPluginGuiInfo.new(
    initDockState or Enum.InitialDockState.Float, initEnabled or true, overrideEnabledRestore or true,
    floatXSize or 0, floatYSize or 0,
    minWidth or floatXSize or 0, minHeight or floatYSize or 0
  ))

  widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

  local root = scope:New "Frame" {
    Size = UDim2.fromScale(1, 1),
    ZIndex = 999,
    BackgroundTransparency = 1,
    Active = false,
    Selectable = false,
    Name = "Widget:Root"
  }

  local content = Background (scope, {
    [Children] = {
      root,

      scope:New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Name = "Widget:Content",
    
        [Children] = props[Children]
      }
    }
  })

  local debugGuiName = `UI_KIT_DEBUG[{id}]`
  local found = StarterGui:FindFirstChild(debugGuiName)
  if found then found:Destroy() end

  if debugMode then
    scope:New "ScreenGui" {
      Parent = StarterGui,
      Name = debugGuiName,
      [Children] = content:Clone()
    }
  end

  table.insert(scope, AddRootToHandler(scope, root))

  return scope:Hydrate(widget) {
    Title = title or id,
    [Children] = content,
  }
end)