--!strict


--> Services ------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------


--> Modules -------------------------------------------------------------------------------------------
local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
export type RootConnections = { RBXScriptConnection }
export type RootHandlerFunctions = {
  InputBegan: { (InputObject) -> () },
  InputEnded:  { (InputObject) -> () },
  InputChanged:  { (InputObject) -> () },

  MouseButton1Click: { () -> () },
  MouseButton1Down: { () -> () },
  MouseButton1Up: { () -> () },

  MouseButton2Click: { () -> () },
  MouseButton2Down: { () -> () },
  MouseButton2Up: { () -> () },

  MouseEnter: { (number, number) -> () },
  MouseLeave: { (number, number) -> () },
  MouseMoved: { (number, number) -> () },

  MouseWheelBackward: { (number, number) -> () },
  MouseWheelForward: { (number, number) -> () },
}
export type HandlerFunction = (InputObject) -> () | () -> () | (number, number) -> ()

export type RootConnectionsForScopes = { [string]: { RBXScriptConnection } }
export type RootHandlerFunctionsForScopes = { [string]: RootHandlerFunctions }

export type EventType =
  "InputBegan" | "InputEnded" | "InputChanged" |
  "MouseEnter" | "MouseLeave" | "MouseMoved"
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local RootConnectionsForScopes: RootConnectionsForScopes = {}
local RootHandlerFunctionsForScopes: RootHandlerFunctionsForScopes = {}

local EVENT_TYPES = table.freeze {
  InputBegan = 1, InputEnded = 2, InputChanged = 3,
  MouseEnter = 4, MouseLeave = 5, MouseMoved = 6,
  MouseWheelBackward = 7, MouseWheelForward = 8
}
-------------------------------------------------------------------------------------------------------


--> Functions -----------------------------------------------------------------------------------------
local function GetRootConnectionsForScope(scopeGuid: string)
  local rootConnections = RootConnectionsForScopes[scopeGuid]
  if rootConnections then return rootConnections end

  rootConnections = table.create(8)
  RootConnectionsForScopes[scopeGuid] = rootConnections

  return (rootConnections :: any) :: RootConnections
end


local function GetRootHandlerFunctionsForScope(scopeGuid: string)
  local rootHandlerFunctions = RootHandlerFunctionsForScopes[scopeGuid]
  if rootHandlerFunctions then return rootHandlerFunctions end

  rootHandlerFunctions = {
    InputBegan = {},
    InputEnded = {},
    InputChanged = {},
  
    MouseButton1Click = {},
    MouseButton1Down = {},
    MouseButton1Up = {},
  
    MouseButton2Click = {},
    MouseButton2Down = {},
    MouseButton2Up = {},
  
    MouseEnter = {},
    MouseLeave = {},
    MouseMoved = {},
  
    MouseWheelBackward = {},
    MouseWheelForward = {},
  }
  RootHandlerFunctionsForScopes[scopeGuid] = rootHandlerFunctions

  return (rootHandlerFunctions :: any) :: RootHandlerFunctions
end

local function RootOnEvent(root: Instance, eventType: EventType, rootHandlerFunctions: RootHandlerFunctions)
  return ((root :: any)[eventType] :: RBXScriptSignal):Connect(function(...)
    for _,handlerFn in rootHandlerFunctions do (handlerFn :: any)(...) end
  end)
end

local function CleanUpRootEventHandlers(scopeGuid: string, rootConnections: RootConnections, rootHandlerFunctions: RootHandlerFunctions)
  return function()
    if rootConnections then
      for _,conn in rootConnections do conn:Disconnect() end
      RootConnectionsForScopes[scopeGuid] = nil :: any
    end

    if rootHandlerFunctions then
      RootHandlerFunctionsForScopes[scopeGuid] = nil
    end
  end
end

local function AddRootToHandler(scope: Fusion.Scope & { GetGuid: (scope: Fusion.Scope) -> string }, root: Instance)
  local scopeGuid = scope:GetGuid()
  local rootConnections = GetRootConnectionsForScope(scopeGuid)
  local rootHandlerFunctions = GetRootHandlerFunctionsForScope(scopeGuid)

  for eventType, idx in EVENT_TYPES do
    rootConnections[idx :: number] = RootOnEvent(root, eventType :: EventType, rootHandlerFunctions[eventType])
  end

  return CleanUpRootEventHandlers(scopeGuid, rootConnections, rootHandlerFunctions)
end


local function AddRootEvent(scope: Fusion.Scope & { GetGuid: (scope: Fusion.Scope) -> string }, eventType: EventType, handlerFn: HandlerFunction)
  local scopeGuid = scope:GetGuid()
  local rootHandlerFunctions = GetRootHandlerFunctionsForScope(scopeGuid)

  local rootHandlerFunctionsForEventType = rootHandlerFunctions[eventType]
  table.insert(rootHandlerFunctionsForEventType, handlerFn)

  local function remove()
     table.remove(rootHandlerFunctionsForEventType, table.find(rootHandlerFunctionsForEventType, handlerFn))
  end

  table.insert(scope, remove)
  return remove
end
-------------------------------------------------------------------------------------------------------


return {
  GetRootConnectionsForScope = GetRootConnectionsForScope,
  GetRootHandlerFunctionsForScope = GetRootHandlerFunctionsForScope,

  AddRootToHandler = AddRootToHandler,

  AddRootEvent = AddRootEvent
}