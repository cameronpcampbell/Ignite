--!strict


--> Modules -------------------------------------------------------------------------------------------
local CoreComponents = script.Parent
local TextLabel = require(CoreComponents.TextLabel)

local Modules = script.Parent.Parent.Parent.Modules
local Component = require(Modules.Component)

local Packages = script.Parent.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
local Highlighter = require(Packages.Highlighter)
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
type CodeLabelProps = {
  Text: Fusion.UsedAs<string>?,
  Weight: Fusion.UsedAs<Enum.FontWeight>?,
  Style: Fusion.UsedAs<Enum.FontStyle>?,
  FontId: Fusion.UsedAs<number>?
}
-------------------------------------------------------------------------------------------------------


return Component(function(scope, props: CodeLabelProps)
  local textLabel = TextLabel (scope, { FontId = 16658246179, TextSize = 13 }, props :: any)

  task.spawn(function()
    Highlighter.matchStudioSettings()
    local cleanUp = Highlighter.highlight { textObject = textLabel :: TextLabel }
    table.insert(scope, cleanUp)
  end)

  return textLabel
end)