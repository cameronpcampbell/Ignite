--!strict


--> Services ------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------


--> Modules -------------------------------------------------------------------------------------------
local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Functions -----------------------------------------------------------------------------------------
local function ComputeMultiply(scope: Fusion.Scope<typeof(Fusion)>, number: Fusion.UsedAs<number>, multiplyBy: Fusion.UsedAs<number>)
  return scope:Computed(function(use) return use(number) :: number * use(multiplyBy) end)
end

local function ComputeDivide(scope: Fusion.Scope<typeof(Fusion)>, number: Fusion.UsedAs<number>, divideBy: Fusion.UsedAs<number>)
  return scope:Computed(function(use) return use(number) :: number / use(divideBy) end)
end

local function ComputeFloorDivide(scope: Fusion.Scope<typeof(Fusion)>, number: Fusion.UsedAs<number>, floorDivideBy: Fusion.UsedAs<number>)
  return scope:Computed(function(use) return use(number) :: number // use(floorDivideBy) end)
end


local function ComputePow(scope: Fusion.Scope<typeof(Fusion)>, number: Fusion.UsedAs<number>, toPower: Fusion.UsedAs<number>)
  return scope:Computed(function(use) return math.pow(use(number), use(toPower)) end)
end


local function ComputeAdd(scope: Fusion.Scope<typeof(Fusion)>, number: Fusion.UsedAs<number>, toAdd: Fusion.UsedAs<number>)
  return scope:Computed(function(use) return use(number) :: number + use(toAdd) end)
end

local function ComputeSubtract(scope: Fusion.Scope<typeof(Fusion)>, number: Fusion.UsedAs<number>, subtractBy: Fusion.UsedAs<number>)
  return scope:Computed(function(use) return use(number) :: number + use(subtractBy) end)
end


local function ComputeMin(scope: Fusion.Scope<typeof(Fusion)>, number: Fusion.UsedAs<number>, min: Fusion.UsedAs<number>)
  return scope:Computed(function(use) return math.min(use(number), use(min)) end)
end

local function ComputeMax(scope: Fusion.Scope<typeof(Fusion)>, number: Fusion.UsedAs<number>, max: Fusion.UsedAs<number>)
  return scope:Computed(function(use) return math.max(use(number), use(max)) end)
end

local function ComputeClamp(scope: Fusion.Scope<typeof(Fusion)>, number: Fusion.UsedAs<number>, min: Fusion.UsedAs<number>, max: Fusion.UsedAs<number>)
  return scope:Computed(function(use) return math.clamp(use(number), use(min), use(max)) end)
end


local function ComputeFloor(scope: Fusion.Scope<typeof(Fusion)>, number: Fusion.UsedAs<number>)
  return scope:Computed(function(use) return math.floor(use(number)) end)
end

local function ComputeCeil(scope: Fusion.Scope<typeof(Fusion)>, number: Fusion.UsedAs<number>)
  return scope:Computed(function(use) return math.ceil(use(number)) end)
end

local function ComputeRound(scope: Fusion.Scope<typeof(Fusion)>, number: Fusion.UsedAs<number>)
  return scope:Computed(function(use) return math.round(use(number)) end)
end
-------------------------------------------------------------------------------------------------------

return {
  Multiply = ComputeMultiply,
  Divide = ComputeDivide,
  FloorDivide = ComputeFloorDivide,

  Pow = ComputePow,

  Add = ComputeAdd,
  Subtract = ComputeSubtract,

  Min = ComputeMin,
  Max = ComputeMax,
  Clamp = ComputeClamp,

  Floor = ComputeFloor,
  Ceil = ComputeCeil,
  Round = ComputeRound
}

