--!strict


--> Services ------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------


--> Modules -------------------------------------------------------------------------------------------
local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Functions -----------------------------------------------------------------------------------------
local function ComputeUDim(scope: Fusion.Scope<typeof(Fusion)>, scale: Fusion.UsedAs<number>, offset: Fusion.UsedAs<number>)
  return scope:Computed(function(use) return UDim.new(use(scale), use(offset)) end)
end

local function ComputeUDim2(scope: Fusion.Scope<typeof(Fusion)>, width: Fusion.UsedAs<UDim>, height: Fusion.UsedAs<UDim>)
  return scope:Computed(function(use)
    local usedWidth, usedHeight = use(width) or UDim.new(0,0), use(height) or UDim.new(0,0)
    return UDim2.new(usedWidth, usedHeight)
  end)
end

local function ComputeUDim2FromScale(scope: Fusion.Scope<typeof(Fusion)>, scaleWidth: Fusion.UsedAs<number>, scaleHeight: Fusion.UsedAs<number>)
  return scope:Computed(function(use)
    local usedScaleWidth, usedScaleHeight = use(scaleWidth), use(scaleHeight)
    return UDim2.fromScale(usedScaleWidth, usedScaleHeight)
  end)
end

local function ComputeUDim2FromOffset(scope: Fusion.Scope<typeof(Fusion)>, offsetWidth: Fusion.UsedAs<number>, offsetHeight: Fusion.UsedAs<number>)
  return scope:Computed(function(use)
    local usedScaleWidth, usedScaleHeight = use(offsetWidth), use(offsetHeight)
    return UDim2.fromOffset(usedScaleWidth, usedScaleHeight)
  end)
end


local function ComputeTweenInfo(
  scope: Fusion.Scope<typeof(Fusion)>, time: Fusion.UsedAs<number>,
  easingStyle: Fusion.UsedAs<Enum.EasingStyle>?, easingDirection: Fusion.UsedAs<Enum.EasingDirection>?,
  repeatCount: Fusion.UsedAs<number>?, reverses: Fusion.UsedAs<number>?, delayTime: Fusion.UsedAs<number>?
)
  return scope:Computed(function(use)
   return TweenInfo.new(
    use(time),
    use(easingStyle) or Enum.EasingStyle.Linear,
    use(easingDirection) or Enum.EasingDirection.In,
    use(repeatCount) or 0,
    use(reverses) or false,
    use(delayTime) or 0
  )
  end)
end
-------------------------------------------------------------------------------------------------------


return {
  UDim = ComputeUDim,

  UDim2 = ComputeUDim2,
  UDim2FromScale = ComputeUDim2FromScale,
  UDim2FromOffset = ComputeUDim2FromOffset,

  TweenInfo = ComputeTweenInfo
}

