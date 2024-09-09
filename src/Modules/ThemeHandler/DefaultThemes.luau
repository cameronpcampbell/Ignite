--> Modules -------------------------------------------------------------------------------------------
local Types = require(script.Parent["ThemeHandler.Types"])
-------------------------------------------------------------------------------------------------------


--> Types ---------------------------------------------------------------------------------------------
export type DefaultTheme = "Dark" | "Light"-- | "StudioDark" | "StudioLight" <-- Coming soon.
-------------------------------------------------------------------------------------------------------


local Dark: Types.ThemeConfig = {
	Background = {
		Primary = Color3.fromHex "#171717",
		Secondary = Color3.fromHex "#252525",
		Tertiary = Color3.fromHex "#2D2D2D",
		Stroke = Color3.fromHex "#323232"
	},

	Text = {
		Title = Color3.fromHex "#E1E3E6",
		Body = Color3.fromHex "#ABABAB",
	},

	Accent = {
		Primary = Color3.fromHex "#0865C3",
		Secondary = Color3.fromHex "#6E7276",
		Destructive = Color3.fromHex "#A01E45"
	}
}

local Light: Types.ThemeConfig = {
	Background = {
		Primary = Color3.fromHex "#ECEDEC",
		Secondary = Color3.fromHex "#F9FBFA",
		Tertiary = Color3.fromHex "#D9D9D9",
		Stroke = Color3.fromHex "#CFCDCD"
	},

	Text = {
		Title = Color3.fromHex "#353D3E",
		Body = Color3.fromHex "#748795",
	},

	Accent = {
		Primary = Color3.fromHex "#0865C3",
		Secondary = Color3.fromHex "#6E7276",
		Destructive = Color3.fromHex "#A01E45"
	}
}

return {
	Dark = Dark,
	Light = Light
}