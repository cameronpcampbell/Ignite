--> Modules -------------------------------------------------------------------------------------------
local Modules = script.Parent.Parent
local PluginHandler = require(Modules.PluginHandler)
local RootEventHandlersUtils = require(Modules.RootEventHandlersUtils)
local ThemeHandler = require(Modules.ThemeHandler)

local Packages = script.Parent.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
type CustomScope = {
  AddRootEvent: typeof(RootEventHandlersUtils.AddRootEvent),
  GetPlugin: typeof(PluginHandler.GetPlugin),

  SetTheme: typeof(ThemeHandler.SetThemeForScope),
  GetThemeItem: typeof(ThemeHandler.GetThemeItemForScope),
}

export type Scope = Fusion.Scope<CustomScope & typeof(Fusion)>
-------------------------------------------------------------------------------------------------------


return nil