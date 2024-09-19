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


return function<Props>(fn: (scope: Scope, props: BaseProps & Props) -> Instance)
  return function(scope: Scope, ...: Props & BaseProps)
    local combinedProps = CombineProps(...) :: BaseProps & Props
    return fn(scope, combinedProps)
  end
end





