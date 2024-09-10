--!strict


--> Modules -------------------------------------------------------------------------------------------
local Types = require(script["ThemeHandler.Types"])
local DefaultThemes = require(script.DefaultThemes)

local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Functions -----------------------------------------------------------------------------------------
local function FlattenThemeConfig(theme: Types.ThemeConfig): Types.ThemeFlatConfig
  local backgroud, text, accent = theme.Background, theme.Text, theme.Accent

  return {
    ["Background/Primary"] = backgroud.Primary,
    ["Background/Secondary"] = backgroud.Secondary,
    ["Background/Tertiary"] = backgroud.Tertiary,
    ["Background/Stroke"] = backgroud.Stroke,

    ["Text/Title"] = text.Title,
    ["Text/Body"] = text.Body,

    ["Accent/Primary"] = accent.Primary,
    ["Accent/Secondary"] = accent.Secondary,
    ["Accent/Destructive"] = accent.Destructive,
  }
end
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local ThemeForScopes: { [Fusion.Scope]: Fusion.Value<Types.ThemeFlatConfig> } = {}
local DefaultDarkTheme = FlattenThemeConfig(DefaultThemes.Dark)

local peek = Fusion.peek
-------------------------------------------------------------------------------------------------------


--> Functions -----------------------------------------------------------------------------------------
local function GetThemeForScope(scope: Fusion.Scope, useOrPeek: Fusion.Use)
  return useOrPeek(ThemeForScopes[scope]) or DefaultDarkTheme
end

local function ApplyHoverFeedbackMode(scope: Fusion.Scope, color: Color3)
  local theme = GetThemeForScope(scope, peek)

  return color:Lerp(theme["Background/Primary"], .25)
end

local function ApplyFocusFeedbackMode(scope: Fusion.Scope, color: Color3)
  local theme = GetThemeForScope(scope, peek)

  return color:Lerp(theme["Background/Primary"], .35)
end

local function ApplyHighlightFeedbackMode(scope: Fusion.Scope, color: Color3)
  return color:Lerp(Color3.new(1,1,1), .1)
end

local function SetThemeForScope(scope: Fusion.Scope, theme: Types.ThemeConfig | DefaultThemes.DefaultTheme)
  local flatTheme =
    if theme == "Dark" then DefaultDarkTheme
    else FlattenThemeConfig(theme)

  -- Makes sure the theme is cleaned up when the scope is destroyed.
  if not ThemeForScopes[scope] then
    table.insert(scope, function() ThemeForScopes[scope] = nil end)

    ThemeForScopes[scope] = scope:Value(flatTheme)
  end

  ThemeForScopes[scope]:set(flatTheme)
end

local function GetThemeItemForScope(
  scope: Fusion.Scope, item: Fusion.UsedAs<Types.ThemeItem>, feedbackMode: Fusion.UsedAs<Types.FeedbackMode?>?, twInfo: Fusion.UsedAs<TweenInfo?>? | false
)
  if twInfo == nil then twInfo = TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) end

  return scope:Tween(scope:Computed(function(use)
    local usedItem = use(item)
    local color = if typeof(usedItem) == "Color3" then usedItem else GetThemeForScope(scope, use)[usedItem]

    local usedFeebackMode = use(feedbackMode)
    if (not usedFeebackMode) or usedFeebackMode == "Default" then return color end

    return
      if usedFeebackMode == "Hover" then ApplyHoverFeedbackMode(scope, color)
      elseif usedFeebackMode == "Highlight" then ApplyHighlightFeedbackMode(scope, color)
      else ApplyFocusFeedbackMode(scope, color)
  end), if twInfo == false then nil else twInfo :: Fusion.UsedAs<TweenInfo>?)
end
-------------------------------------------------------------------------------------------------------


return {
  SetThemeForScope = SetThemeForScope,
  GetThemeItemForScope = GetThemeItemForScope
}