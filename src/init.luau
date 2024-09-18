--!strict


--> Services ------------------------------------------------------------------------------------------
local HttpService = game:GetService("HttpService")
-------------------------------------------------------------------------------------------------------


--> Modules -------------------------------------------------------------------------------------------
local Modules = script.Modules
local RootEventHandlersUtils = require(Modules.RootEventHandlersUtils)
local ThemeHandler = require(Modules.ThemeHandler)

local Packages = script.Packages
local Fusion = require(Packages.Fusion)

local Components = script.Components
local CoreComponents = Components.Core
local PaddingComponents = Components.Padding
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local AddRootEvent = RootEventHandlersUtils.AddRootEvent

local GenerateGuid = HttpService.GenerateGUID
-------------------------------------------------------------------------------------------------------


return {
  SetTheme = ThemeHandler.SetThemeForScope,
  GetThemeItem = ThemeHandler.GetThemeItemForScope,

  -- Can't rely on the table itself to be a unique table key as its memory address can change.
  GetGuid = (function()
    local hash = GenerateGuid(HttpService, false)

    return function(scope: Fusion.Scope)
      return hash
    end
  end)(),
  AddRootEvent = AddRootEvent,

  -- Plugins.
  Widget = require(Components.Widget),

  -- Wrappers.
  Accordion = require(Components.Accordion),
  Background = require(Components.Background),
  Container = require(Components.Container),
  EmbeddedContainer = require(Components.EmbeddedContainer),
  ImageBackground = require(Components.ImageBackground),
  Map = require(Components.Map),

  -- ...ables
  Scrollable = require(Components.Scrollable),

  -- Labels.
  TextLabel = require(CoreComponents.TextLabel),
  CodeLabel = require(CoreComponents.CodeLabel),

  -- Inputs.
  TextInput = require(Components.TextInput),

  -- Buttons.
  Button = require(Components.Button),
  Checkbox = require(Components.Checkbox),
  Slider = require(Components.Slider),
  Switch = require(Components.Switch),
  Navigation = require(Components.Navigation),
  Tabs = require(Components.Tabs),

  -- Other
  Progress = require(Components.Progress),

  -- Padding.
  PaddingSmall = require(PaddingComponents.PaddingSmall),
  PaddingLarge = require(PaddingComponents.PaddingLarge)
}