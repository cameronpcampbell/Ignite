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

export type RootConnectionsForScopes = { [Fusion.Scope]: { RBXScriptConnection } }
export type RootHandlerFunctionsForScopes = { [Fusion.Scope]: RootHandlerFunctions }

export type EventType =
  "InputBegan" | "InputEnded" | "InputChanged" |
  "MouseEnter" | "MouseLeave" | "MouseMoved"
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local RootConnectionsForScopes: RootConnectionsForScopes = {}
local RootHandlerFunctionsForScopes: { [Fusion.Scope]: RootHandlerFunctions } = {}

local EVENT_TYPES = table.freeze {
  InputBegan = 1, InputEnded = 2, InputChanged = 3,
  MouseEnter = 4, MouseLeave = 5, MouseMoved = 6,
  MouseWheelBackward = 7, MouseWheelForward = 8
}
-------------------------------------------------------------------------------------------------------


--> Functions -----------------------------------------------------------------------------------------
local function GetRootConnectionsForScope(scope: Fusion.Scope)
  local rootConnections = RootConnectionsForScopes[scope]
  if rootConnections then return rootConnections end

  rootConnections = table.create(8)
  RootConnectionsForScopes[scope] = rootConnections

  return (rootConnections :: any) :: RootConnections
end

local function GetRootHandlerFunctionsForScope(scope: Fusion.Scope)
  local rootHandlerFunctions = RootHandlerFunctionsForScopes[scope]
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
  RootHandlerFunctionsForScopes[scope] = rootHandlerFunctions

  return (rootHandlerFunctions :: any) :: RootHandlerFunctions
end

local function RootOnEvent(root: Instance, eventType: EventType, rootHandlerFunctions: RootHandlerFunctions)
  return ((root :: any)[eventType] :: RBXScriptSignal):Connect(function(...)
    for _,handlerFn in rootHandlerFunctions do (handlerFn :: any)(...) end
  end)
end

local function CleanUpRootEventHandlers(scope: Fusion.Scope, rootConnections: RootConnections, rootHandlerFunctions: RootHandlerFunctions)
  return function()
    if rootConnections then
      for _,conn in rootConnections do conn:Disconnect() end
      RootConnectionsForScopes[scope] = nil :: any
    end

    if rootHandlerFunctions then
      RootHandlerFunctionsForScopes[scope] = nil
    end
  end
end

local function AddRootToHandler(scope: Fusion.Scope, root: Instance)
  local rootConnections = GetRootConnectionsForScope(scope)
  local rootHandlerFunctions = GetRootHandlerFunctionsForScope(scope)

  for eventType, idx in EVENT_TYPES do
    rootConnections[idx :: number] = RootOnEvent(root, eventType :: EventType, rootHandlerFunctions[eventType])
  end

  return CleanUpRootEventHandlers(scope, rootConnections, rootHandlerFunctions)
end


local function AddRootEvent(scope: Fusion.Scope, eventType: EventType, handlerFn: HandlerFunction)
  local rootHandlerFunctions = GetRootHandlerFunctionsForScope(scope)

  local rootHandlerFunctionsForEventType = rootHandlerFunctions[eventType]
  table.insert(rootHandlerFunctionsForEventType, handlerFn)

  return function()
    table.remove(rootHandlerFunctionsForEventType, table.find(rootHandlerFunctionsForEventType, handlerFn))
  end
end
-------------------------------------------------------------------------------------------------------


return {
  GetRootConnectionsForScope = GetRootConnectionsForScope,
  GetRootHandlerFunctionsForScope = GetRootHandlerFunctionsForScope,

  AddRootToHandler = AddRootToHandler,

  AddRootEvent = AddRootEvent
}