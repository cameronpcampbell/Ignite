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
local RootHandlerFunctions: RootHandlerFunctions = {
  InputBegan = { },
  InputEnded = { },
  InputChanged = { },

  MouseButton1Click = { },
  MouseButton1Down = { },
  MouseButton1Up = { },

  MouseButton2Click = { },
  MouseButton2Down = { },
  MouseButton2Up = { },

  MouseEnter = { },
  MouseLeave = { },
  MouseMoved = { },

  MouseWheelBackward = { },
  MouseWheelForward = { }
}

local EVENT_TYPES = table.freeze {
  "InputBegan", "InputEnded", "InputChanged",
  "MouseEnter", "MouseLeave", "MouseMoved",
  "MouseWheelBackward", "MouseWheelForward"
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

local function RootOnEvent(root: Instance, eventType: EventType)
  return ((root :: any)[eventType] :: RBXScriptSignal):Connect(function(...)
    for _,handlerFn in RootHandlerFunctions[eventType] do (handlerFn :: any)(...) end
  end)
end

local function CleanUpRootConnections(scope: Fusion.Scope, rootConnections: RootConnections)
  return function()
    if rootConnections then
      for _,conn in rootConnections do conn:Disconnect() end
      RootConnectionsForScopes[scope] = nil :: any
    end
  end
end

local function AddRootToHandler(scope: Fusion.Scope, root: Instance)
  local rootConnections = GetRootConnectionsForScope(scope)

  for idx, eventType in EVENT_TYPES do
    rootConnections[idx :: number] = RootOnEvent(root, eventType :: EventType)
  end

  return CleanUpRootConnections(scope, rootConnections)
end


local function AddRootEvent(scope: Fusion.Scope, eventType: EventType, handlerFn: HandlerFunction)
  local rootHandlerFunctionsForEventType = RootHandlerFunctions[eventType]
  table.insert(rootHandlerFunctionsForEventType, handlerFn)

  local function remove()
     table.remove(rootHandlerFunctionsForEventType, table.find(rootHandlerFunctionsForEventType, handlerFn))
  end

  table.insert(scope, remove)
  return remove
end
-------------------------------------------------------------------------------------------------------


return {
  AddRootToHandler = AddRootToHandler,
  AddRootEvent = AddRootEvent
}