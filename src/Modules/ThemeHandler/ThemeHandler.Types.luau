export type ThemeConfig = {
  Background: {
    Primary: Color3,
    Secondary: Color3,
    Tertiary: Color3,
    Stroke: Color3
  },

  Text: {
    Title: Color3,
    Body: Color3
  },

  Accent: {
    Primary: Color3,
    Secondary: Color3,
    Destructive: Color3
  }
}

export type ThemeFlatConfig = {
  ["Background/Primary"]: Color3,
  ["Background/Secondary"]: Color3,
  ["Background/Tertiary"]: Color3,
  ["Background/Stroke"]: Color3,

  ["Text/Title"]: Color3,
  ["Text/Body"]: Color3,

  ["Accent/Primary"]: Color3,
  ["Accent/Secondary"]: Color3,
  ["Accent/Destructive"]: Color3,
}

export type ThemeItem = "Background/Primary" | "Background/Secondary" | "Background/Tertiary" | "Background/Stroke" | "Text/Title" | "Text/Body" | "Accent/Primary" | "Accent/Secondary" | "Accent/Destructive"

export type MutatorPreset = "Default" | "Hover" | "Focus" | "Highlight"

return nil