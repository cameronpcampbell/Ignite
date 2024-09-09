--!strict


--> Modules -------------------------------------------------------------------------------------------
local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local Plugins = {}
-------------------------------------------------------------------------------------------------------


return {
	GetPlugin = function(scope: Fusion.Scope) return Plugins[scope] end,

	SetPlugin = function(scope: Fusion.Scope, _plugin: Plugin)
		_plugin:Activate(true)
		Plugins[scope] = _plugin
	end
}