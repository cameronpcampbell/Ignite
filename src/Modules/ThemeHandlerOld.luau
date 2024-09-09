--!strict


--> Services ------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------


--> Modules -------------------------------------------------------------------------------------------
local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
type ColorTheme = {
	["Background/Primary"]: Color3,
	["Background/Secondary"]: Color3,
	["Background/Tertiary"]: Color3,
	["Background/Stroke"]: Color3,
	["Background/StrokeHighlight"]: Color3,
	["Background/Contrast"]: Color3,

	["Text/Title"]: Color3,
	["Text/Body"]: Color3,
	["Text/Accent"]: Color3,

	["Accent/Primary"]: Color3,
	["Accent/Secondary"]: Color3,
	["Accent/Destructive"]: Color3,
}

type ColorVariant = "Background/Primary" | "Background/Secondary" | "Background/Tertiary" | "Background/Stroke" | "Background/StrokeHighlight" | "Background/Contrast" | "Text/Title" | "Text/Body" | "Text/Accent" | "Accent/Primary" | "Accent/Secondary" | "Accent/Destructive"
-------------------------------------------------------------------------------------------------------


--> Variables -----------------------------------------------------------------------------------------
local Scope = Fusion.scoped({ Value = Fusion.Value, Computed = Fusion.Computed, Tween = Fusion.Tween })

local DarkTheme: ColorTheme = {
	["Background/Primary"] = Color3.fromHex "#171717",
	["Background/Secondary"] = Color3.fromHex "#252525",
	["Background/Tertiary"] = Color3.fromHex "#2D2D2D",
	["Background/Stroke"] = Color3.fromHex "#323232",
	["Background/StrokeHighlight"] = Color3.fromHex("#323232"):Lerp(Color3.new(1,1,1), .1),
	["Background/Contrast"] = Color3.fromHex "#292929",

	["Text/Title"] = Color3.fromHex "#E1E3E6",
	["Text/Body"] = Color3.fromHex "#ABABAB",
	["Text/Accent"] = Color3.fromHex "#E1E3E6",

	["Accent/Primary"] = Color3.fromHex "#0865C3",
	["Accent/Secondary"] = Color3.fromHex "#6E7276",
	["Accent/Destructive"] = Color3.fromHex "#A01E45",
}

local LightTheme: ColorTheme = {
	["Background/Primary"] = Color3.fromHex "#ECEDEC",
	["Background/Secondary"] = Color3.fromHex "#F9FBFA",
	["Background/Tertiary"] = Color3.fromHex "#D9D9D9",
	["Background/Stroke"] = Color3.fromHex "#CFCDCD",
	["Background/StrokeHighlight"] = Color3.fromHex("#CFCDCD"):Lerp(Color3.new(0,0,0), .1),
	["Background/Contrast"] = Color3.fromHex "#000",

	["Text/Title"] = Color3.fromHex "#353D3E",
	["Text/Body"] = Color3.fromHex "#748795",
	["Text/Accent"] = Color3.fromHex "#E1E3E6",

	["Accent/Primary"] = Color3.fromHex "#0865C3",
	["Accent/Secondary"] = Color3.fromHex "#6E7276",
	["Accent/Destructive"] = Color3.fromHex "#A01E45",
}


local CurrentColorTheme: Fusion.Value<ColorTheme> = Scope:Value(DarkTheme)
-------------------------------------------------------------------------------------------------------


--> Private Functions ---------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------


return {
	Set = function(themeVariant: "Dark" | "Light")
		CurrentColorTheme:set(themeVariant == "Light" and LightTheme or DarkTheme)
	end,

	Get = function(
		colorVariant: ColorVariant | Fusion.Value<ColorVariant> | Fusion.Computed<ColorVariant>,
		twInfo: (TweenInfo | number | false)?
	)
		local twInfo = (twInfo ~= false and (
			twInfo == nil and TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) or
				type(twInfo) == "number" and TweenInfo.new(twInfo, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) or
				twInfo
			) or nil) :: TweenInfo?

		return Scope:Tween(Scope:Computed(function(use)
			local usedColorVariant = use(colorVariant)
			if typeof(usedColorVariant) == "Color3" then return usedColorVariant end
			
			return use(CurrentColorTheme)[usedColorVariant]
		end), twInfo) :: any
	end
}