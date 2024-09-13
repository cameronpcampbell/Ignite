--!strict


--> Services ------------------------------------------------------------------------------------------
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
-------------------------------------------------------------------------------------------------------


--> Modules -------------------------------------------------------------------------------------------
local Components = script.Parent
local CoreComponents = Components.Core
local Squircle = require(CoreComponents.Squircle)
local TextLabel = require(CoreComponents.TextLabel)

local Modules = script.Parent.Parent.Modules
local Component = require(Modules.Component)
local ComputeTransforms = require(Modules.ComputeTransforms)
local TableUtils = require(Modules.TableUtils)
local ForceToState = require(Modules.ForceToState)

local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
type ValidationProps = {
  Pattern: Fusion.UsedAs<string>,
  Mode: Fusion.UsedAs<"Restrict" | "ErrorVisual" | nil>
}

type Variant = Fusion.UsedAs<"Primary" | "Secondary" | nil>

type TextInputProps = {
  Width: Fusion.UsedAs<UDim>?,
  Placeholder: Fusion.UsedAs<string?>,
  Value: Fusion.UsedAs<string?>,
  Variant: Variant?,
  Keybind: Fusion.UsedAs<{ Enum.KeyCode }>?,
  Validation: ValidationProps?,
}
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local ComputeUDim2, ComputeUDim = ComputeTransforms.UDim2, ComputeTransforms.UDim

local TableTake = TableUtils.Take

local Children, OnEvent, OnChange, peek = Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.peek

local IS_WINDOWS: boolean = GuiService.IsWindows
-------------------------------------------------------------------------------------------------------


--> Private Functions ---------------------------------------------------------------------------------
local function MakePatternLocal(pattern: string)
  pattern = string.gsub(pattern, "^\^+", "")
  pattern = string.gsub(pattern, "\$+$", "")
  return pattern
end

local function TextBoxValidation(
  scope: Component.Scope, rawValue: Fusion.Value<string>, value: Fusion.Value<string>, textBoxRef: Fusion.Value<Instance>,
  computeParsedPattern: Fusion.Computed<string>, validationMode: Fusion.UsedAs<"Restrict" | "ErrorVisual" | nil>
)
  -- Makes sure `rawValue` is up to date if `value` changes.
  local updateRawValue = true
  scope:Observer(value):onChange(function()
    if not updateRawValue then return end
    rawValue:set(peek(value))
  end)
  
  return function(useOrPeek: <T>(T) -> any)
    local usedParsedPattern = useOrPeek(computeParsedPattern)
    if not usedParsedPattern then return false end
    local usedRawValue = useOrPeek(rawValue)

    if (useOrPeek(validationMode) or "ErrorVisual") == "ErrorVisual" then
      updateRawValue = false
      value:set(usedRawValue)
      updateRawValue = true
      return string.match(usedRawValue, usedParsedPattern) and true or false

    -- Since the validation mode is `Restrict` we need to get
    -- the first match and set the TextBox's text to it.
    else
      local matches = string.gmatch(usedRawValue, usedParsedPattern)
      
      local match
      for m in matches do match = m; break end
      if match == nil then match = "" end

      local usedTextBoxRef: TextBox = useOrPeek(textBoxRef) :: any

      updateRawValue = false
      value:set(match)
      updateRawValue = true
      if usedTextBoxRef then usedTextBoxRef.Text = match end  -- Make sure the text has updated.
      return true
    end
  end
end

local function KeyCodeEnumToLabel(scope: Component.Scope, enum: Enum.KeyCode, isWindows: boolean, textColor: Fusion.UsedAs<Color3>): any
  if not isWindows and enum == Enum.KeyCode.LeftControl then
    return scope:New "ImageLabel" {
      Size = UDim2.fromOffset(8, 8),
      BackgroundTransparency = 1,
      Image = "rbxassetid://80547592081199",
      ImageColor3 = textColor
    }
  end

  local text = (
    if enum == Enum.KeyCode.LeftControl then "LCNTRL"
    elseif enum == Enum.KeyCode.RightControl then "RCNTRL"
    elseif enum == Enum.KeyCode.LeftShift then "LSHFT"
    elseif enum == Enum.KeyCode.RightShift then "RSHFT"
    elseif enum == Enum.KeyCode.LeftAlt then "LALT"
    elseif enum == Enum.KeyCode.RightAlt then "RALT"
    else enum.Name
  )

  return TextLabel(scope, { Text = text, TextColor3 = textColor })
end

local function KeybindPrompt(scope: Component.Scope, keybind: Fusion.UsedAs<{ Enum.KeyCode }>)
  local textColor = scope:GetThemeItem("Text/Body", function(self) return self:Lerp(Color3.new(1,1,1), .05) end, false)

  return Squircle(scope, {
    Size = UDim2.new(0,0, 0,15),
    AutomaticSize = Enum.AutomaticSize.X,
    Image = "rbxassetid://77469521389584",
    BackgroundColor3 = scope:GetThemeItem("Background/Secondary", function(self) return self:Lerp(Color3.new(1,1,1), .05) end, false),
    SliceCenter = Rect.new(15, 15, 15, 15),
    LayoutOrder = 1,

    [Children] = {
      Squircle(scope, {
        Size = UDim2.fromScale(1, 1),
        Image = "rbxassetid://101010257373189",
        BackgroundColor3 = scope:GetThemeItem("Background/Stroke", function(self) return self:Lerp(Color3.new(1,1,1), .05) end, false),
        SliceCenter = Rect.new(15, 15, 15, 15),
      }),

      scope:New "Frame" {
        Size = UDim2.new(0,0, 0,15),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,

        [Children] = {
          scope:ForPairs(keybind, function(use, scope, idx, enum)
            return idx, KeyCodeEnumToLabel(scope, enum, IS_WINDOWS, textColor)
          end) :: any,

          scope:New "UIListLayout" {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = ComputeUDim(scope, 0, 3)
          },

          scope:New "UIPadding" {
            PaddingLeft = UDim.new(0,5), PaddingRight = UDim.new(0,5)
          }
        }
      },
    }
  })
end

local function KeybindIsPressed(pressedKeys: { Enum.KeyCode }, keybind: { Enum.KeyCode }?)
  if not keybind then return false end
  local pressed = 0

  for _,pressedKey in pressedKeys do
    for _,key in keybind do
      if pressedKey == key then pressed += 1 end
    end
  end

  return if pressed == #keybind then true else false
end

local function FocusVisual(
  scope: Component.Scope, isFocusState: Fusion.Value<boolean>,
  computeStrokeThemeItem: Fusion.Computed<"Accent/Primary" | "Accent/Destructive" | "Background/Stroke">
)
  local computeSizeOffset = scope:Computed(function(use) return use(isFocusState) and 4 or 8 end)
  local computeSizeUDim = ComputeUDim(scope, 1, computeSizeOffset)

  local computeTransparency = scope:Computed(function(use) return use(isFocusState) and .6 or 1 end)

  return Squircle (scope, {
    Size = scope:Spring(ComputeUDim2(scope, computeSizeUDim, computeSizeUDim), 20, 1),
    Position = UDim2.fromScale(.5, .5),
    AnchorPoint = Vector2.new(.5, .5),
    Image = "rbxassetid://129606470741282",
    BackgroundColor3 = scope:GetThemeItem(computeStrokeThemeItem),
    Transparency = computeTransparency,
    Name = "TextInput:FocusVisual"
  })
end
-------------------------------------------------------------------------------------------------------


return Component(function(scope, props: TextInputProps)
  local width: Fusion.UsedAs<UDim>, variant: Variant? = TableTake(props, "Width", UDim.new(1,0)), TableTake(props, "Variant")
  local placeholder, value = TableTake(props, "Placeholder", "Text Input"), ForceToState(scope, TableTake(props, "Value", ""))
  local validation: ValidationProps? = TableTake(props, "Validation", "ErrorVisual")
  local validationPattern, validationMode: Fusion.UsedAs<"Restrict" | "ErrorVisual" | nil> =
    validation and validation.Pattern, validation and validation.Mode
  local keybind: Fusion.UsedAs<{ Enum.KeyCode }>? = TableTake(props, "Keybind")

  local isHoverState, isFocusState = scope:Value(false), scope:Value(false)
  local textBoxRef: Fusion.Value<Instance> = scope:Value(nil :: any)

  local computeParsedPattern = scope:Computed(function(use)
    local pattern = MakePatternLocal(use(validationPattern))
    return 
      if (use(validationMode) or "ErrorVisual") == "ErrorVisual" then `^{pattern}$`
      else pattern
  end)

  -- When the text box is changed this state will be updated, then when `computeIsValidated` runs
  -- the actual `value` state will be updated with the (parsed) text.
  -- If there is no validation then `rawValue` will just be `value`.
  local rawValue: Fusion.Value<string> = validation and scope:Value(peek(value)) or value

  local isValidated: Fusion.UsedAs<boolean> = true
  if validation then
    local textBoxValidation = TextBoxValidation(scope, rawValue, value, textBoxRef, computeParsedPattern, validationMode)
    textBoxValidation(peek)
    isValidated = scope:Computed(function(use) return textBoxValidation(use) end)
  end

  local computeBackgroundColor = scope:GetThemeItem(scope:Computed(function(use)
    return `Background/{use(variant) == "Secondary" and "Tertiary" or "Secondary"}` :: any
  end))

  local computeStrokeThemeItem = scope:Computed(function(use): any
    if use(isValidated) == false then return "Accent/Destructive" end
    if use(isFocusState) then return "Accent/Primary" end
    return "Background/Stroke"
  end)

  local computeStrokeFeedbackMode = scope:Computed(function(use) return (use(isHoverState) and "Highlight" or nil) :: any end)

  local selectedKeys = {}
  local function InputBegan(key: InputObject)
    table.insert(selectedKeys, key.KeyCode)

    if not KeybindIsPressed(selectedKeys, peek(keybind)) then return end;
    (peek(textBoxRef) :: TextBox):CaptureFocus()
    table.clear(selectedKeys)
  end

  local function InputEnded(key: InputObject)
    table.remove(selectedKeys, table.find(selectedKeys, key.KeyCode))
  end

  scope:AddRootEvent("InputBegan", InputBegan)
  scope:AddRootEvent("InputEnded", InputEnded)
  local inputBeganConn = UserInputService.InputBegan:Connect(InputBegan)
  local inputEndedConn = UserInputService.InputEnded:Connect(InputEnded)

  table.insert(scope, function()
    inputBeganConn:Disconnect()
    inputEndedConn:Disconnect()
  end)

  return Squircle (scope, {
    As = "ImageButton" :: "ImageButton",
    Size = ComputeUDim2(scope, width, UDim.new(0, 25)),
    Image = "rbxassetid://116342589966879",
    BackgroundColor3 = computeBackgroundColor,
    Name = "TextInput",

    [Children] = {
      Squircle (scope, {
        Size = UDim2.fromScale(1, 1),
        Image = "rbxassetid://72425541434885",
        BackgroundColor3 = scope:GetThemeItem(computeStrokeThemeItem, computeStrokeFeedbackMode),
        Name = "TextInput:Stroke"
      }),

      FocusVisual(scope, isFocusState, computeStrokeThemeItem),

      scope:New "Frame" {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Name = "TextInput:Content",

        [Children] = {
          textBoxRef:set(scope:New "TextBox" {
            Size = UDim2.new(1,0, 1,0),
            BackgroundTransparency = 1,
            TextSize = 14,
            Text = value,
            PlaceholderText = placeholder,
            PlaceholderColor3 = scope:GetThemeItem("Text/Body"),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.fromId(16658221428, Enum.FontWeight.Medium),
            TextColor3 = scope:GetThemeItem("Text/Title"),
            ClipsDescendants = true,
            LayoutOrder = 0,
    
            [OnEvent "Focused"] = function() isFocusState:set(true) end,
            [OnEvent "FocusLost"] = function() isFocusState:set(false) end,
    
            [OnEvent "MouseEnter"] = function() isHoverState:set(true) end,
            [OnEvent "MouseLeave"] = function() isHoverState:set(false) end,
    
            [OnChange "Text"] = function(newText) rawValue:set(newText) end,

            [Children] = scope:New "UIFlexItem" {
              FlexMode = Enum.UIFlexMode.Fill
            }
          }),
    
          scope:Computed(function(use)
            local usedKeybind = use(keybind)
            return if usedKeybind then KeybindPrompt(scope, usedKeybind) else nil
          end) :: any,

          scope:New "UIListLayout" {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 5)
          },

          scope:New "UIPadding" {
            PaddingRight = ComputeUDim(scope, 0, scope:Computed(function(use) return use(keybind) and 5 or 7 end)),
            PaddingLeft = UDim.new(0, 7)
          }
        }
      }
      
    }
  }, props :: any)
end)

