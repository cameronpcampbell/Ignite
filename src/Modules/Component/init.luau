--!strict

--> Modules -------------------------------------------------------------------------------------------
local ComponentTypes = require(script["Component.Types"])

local Modules = script.Parent
local CombineProps = require(Modules.CombineProps)

local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------

--> Types ---------------------------------------------------------------------------------------------
type BaseProps = {
  [string | Fusion.SpecialKey]: unknown?
}

export type Scope = ComponentTypes.Scope

export type DynamicSection = string | Fusion.Child
-------------------------------------------------------------------------------------------------------


--> Functions -----------------------------------------------------------------------------------------
local function Component<Props>(fn: (scope: Scope, props: Props) -> Instance)
  return function(scope: Scope, ...: Props & BaseProps)
    local combinedProps = CombineProps(...) :: BaseProps & Props
    return fn(scope, combinedProps)
  end
end
-------------------------------------------------------------------------------------------------------


return Component






