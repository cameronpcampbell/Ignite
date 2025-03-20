--!strict

--> Services ------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

--> Modules -------------------------------------------------------------------------------------------
local Modules = script.Parent.Parent.Modules
local Component = require(Modules.Component)
local ComputeTransforms = require(Modules.ComputeTransforms)
local TableUtils = require(Modules.TableUtils)

local Packages = script.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
local Peek = Fusion.peek

local Components = Modules.Parent.Components
local CoreComponents = Components.Core
local Squircle = require(CoreComponents.Squircle)
local TextLabel = require(CoreComponents.TextLabel)
-------------------------------------------------------------------------------------------------------

--> Types ---------------------------------------------------------------------------------------------

type IconProperties = Fusion.UsedAs<{
	AnchorPoint: Vector2?,
	Image: string?,
	Size: UDim2?,
	Position: UDim2?,
	ImageColor3: Color3?,
	ImageTransparency: number?,
	ImageRectOffset: Vector2?,
	ImageRectSize: Vector2?,
	ScaleType: Enum.ScaleType?,
	ResampleMode: Enum.ResamplerMode?,
}>?

type ButtonProps = {
	Width: Fusion.UsedAs<UDim | "Auto">?,
	Content: Fusion.UsedAs<{ string } | string>?,
	Variant: ("Primary" | "Secondary" | "Destructive")?,
	IconProperties: IconProperties,
}
-------------------------------------------------------------------------------------------------------

--> Variables -----------------------------------------------------------------------------------------
local ComputeUDim2 = ComputeTransforms.UDim2

local TableTake = TableUtils.Take

local Children, OnEvent = Fusion.Children, Fusion.OnEvent
-------------------------------------------------------------------------------------------------------

--> Private Functions ---------------------------------------------------------------------------------

local function setProperty_unsafe(instance: Instance, property: string, value: unknown)
	(instance :: any)[property] = value
end

local function ParseContentItem(scope: Component.Scope, item: string, IconProperties: IconProperties)
	local imageId = string.match(item, "rbxassetid://%d+")

	local peekProperties = Peek(IconProperties)

	if not peekProperties then
		peekProperties = {} :: {}
	end

	local amount = 0

	for _, value in peekProperties do
		amount += 1
	end

	if amount ~= 0 or imageId then
		if not peekProperties.Image and not imageId then
			imageId = nil
		end

		local imageLabel = scope:New("ImageLabel")({
			BackgroundTransparency = 1,
			ImageColor3 = scope:GetThemeItem("Text/Title"),
			Size = UDim2.fromOffset(9, 9),
			Image = imageId,
		})

		if peekProperties == {} then
			return imageLabel
		end

		for Key, Property in peekProperties do
			local success, err = pcall(function()
				setProperty_unsafe(imageLabel, Key, Property)
			end)

			if success then
				continue
			end
			warn(err)
		end

		return imageLabel
	end

	return TextLabel(scope, {
		Text = item,
		Focus = "Title" :: "Title",
		Weight = Enum.FontWeight.SemiBold,
		Size = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		TextXAlignment = Enum.TextXAlignment.Center,
	}) :: any
end
-------------------------------------------------------------------------------------------------------

return Component(function(scope, props: ButtonProps)
	local width = TableTake(props, "Width", UDim.new(1, 0)) :: Fusion.UsedAs<UDim>
	local content = TableTake(props, "Content", "Button") :: Fusion.UsedAs<{ string } | string>
	local variant = TableTake(props, "Variant", "Primary") :: Fusion.UsedAs<"Primary" | "Secondary" | "Destructive">
	local iconProperties = TableTake(props, "IconProperties", {}) :: IconProperties

	local isHoverState = scope:Value(false)
	local isFocusState = scope:Value(false)

	-- We need to ensure that `content` is an array so it can be used with `ForPairs`

	local computeContentArray = scope:Computed(function(use)
		local usedContent = use(content)
		return if type(usedContent) == "table" then usedContent else { usedContent }
	end)

	-- Width may be "Auto" therefore we need to make the width of the button `UDim.new()` when this is the case.
	local computeUDimWidth = scope:Computed(function(use)
		local usedWidth = use(width)
		return if usedWidth == "Auto" then UDim.new() else usedWidth
	end)

	local computeAutoSize = scope:Computed(function(use)
		return if use(width) == "Auto" then Enum.AutomaticSize.X else Enum.AutomaticSize.None
	end)

	local computeProperties = scope:Computed(function(use)
		return use(iconProperties) or {}
	end)

	local computeBackgroundColor = scope:GetThemeItem(
		scope:Computed(function(use)
			return `Accent/{use(variant) or "Primary"}` :: any
		end),
		scope:Computed(function(use)
			return if use(isFocusState) then "Focus" elseif use(isHoverState) then "Hover" else nil :: any
		end)
	)

	local computeChildren = scope:Computed(function(Use)
		local text = ""
		local image = ""

		local children = {}

		for _, content in Use(computeContentArray) do
			if not string.find(content, "rbxassetid://") then
				text = content
			else
				image = content
			end
		end

		if image or computeProperties["Image"] then
			table.insert(children, ParseContentItem(scope, image :: string, computeProperties))
		end

		table.insert(children, ParseContentItem(scope, text, {}))

		return children
	end)

	-- Handles the edge case of the user dragging the cursor off of the button and then releasing the mouse button.
	scope:AddRootEvent("InputEnded", function()
		isFocusState:set(false)
	end)

	return Squircle(scope, {
		As = "ImageButton" :: "ImageButton",
		Size = ComputeUDim2(scope, computeUDimWidth, UDim.new(0, 25)),
		AutomaticSize = computeAutoSize,
		BackgroundColor3 = computeBackgroundColor,
		ClipsDescendants = true,
		Name = "Button",

		[OnEvent("MouseEnter")] = function()
			isHoverState:set(true)
		end :: any,
		[OnEvent("MouseLeave")] = function()
			isHoverState:set(false)
		end :: any,

		[OnEvent("MouseButton1Down")] = function()
			isFocusState:set(true)
		end :: any,
		[OnEvent("MouseButton1Up")] = function()
			isFocusState:set(false)
		end :: any,

		[Children] = {
			Squircle(scope, {
				Size = UDim2.fromScale(1, 1),
				Image = "rbxassetid://108824901287727",
				Name = "Button:Highlight",
			}),

			scope:New("Frame")({
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Name = "Button:ContentWrapper",

				[Children] = {
					computeChildren,

					scope:New("UIListLayout")({
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = UDim.new(0, 8),
					}),

					scope:New("UIPadding")({ PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
				},
			}),
		},
	}, props :: any)
end)
