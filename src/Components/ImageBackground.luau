--!strict


--> Modules -------------------------------------------------------------------------------------------
local Modules = script.Parent.Parent.Modules
local Component = require(Modules.Component)
local CombineProps = require(Modules.CombineProps)
local TableUtils = require(Modules.TableUtils)

local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
type ImageBackgroundProps = {
  ImageSource: string | EditableImage,
  ImageSourceSize: Fusion.UsedAs<Vector3>
}
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local Children = Fusion.Children

local TableTake = TableUtils.Take
-------------------------------------------------------------------------------------------------------


--> Functions -----------------------------------------------------------------------------------------
local function CreateImageLabelFromId(scope: Component.Scope, source: string)
  return function(props: Fusion.PropertyTable)
    return scope:New "ImageLabel" (CombineProps({ Image = source }, props))
  end
end

local function CreateImageLabelFromEditableImage(scope: Component.Scope, source: EditableImage)
  return function(props: Fusion.PropertyTable)
    return scope:New "ImageLabel" (CombineProps({ [Children] = source:Clone() }, props))
  end
end
-------------------------------------------------------------------------------------------------------


return Component(function(scope, props: ImageBackgroundProps)
  local source: EditableImage | string, sourceSize = TableTake(props, "ImageSource"), TableTake(props, "ImageSourceSize")

  local createImageLabel: (Fusion.PropertyTable) -> Instance =
    type(source) == "string" and CreateImageLabelFromId(scope, source) or CreateImageLabelFromEditableImage(scope, source :: EditableImage)

  local computeAspectRatio = scope:Computed(function(use)
    local usedSourceSize = use(sourceSize)
    return usedSourceSize.X / usedSourceSize.Z
  end)

  return createImageLabel (CombineProps({
    ImageTransparency = .9,
    BackgroundTransparency = 1,

    [Children] = {
      createImageLabel {
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromScale(.5, .5),
        AnchorPoint = Vector2.new(.5, .5),
        BackgroundTransparency = 1,

        [Children] = {
          scope:New "UIAspectRatioConstraint" {
            AspectRatio = computeAspectRatio,
          }
        }
      }
    }
  }, props))
end)

