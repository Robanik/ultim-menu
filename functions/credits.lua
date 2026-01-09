--[[
	Credits Module
	===============
	Author: robanik
	Purpose: Display an animated credits/author card showcasing the creator information
	
	This module provides functionality to display a beautiful, animated credits card
	that highlights the creator (robanik) with smooth animations and visual effects.
	
	Usage:
		local Credits = require(script.Parent:WaitForChild("credits"))
		Credits:ShowCredits()
		-- or
		Credits:ShowCredits(duration, targetFrame)
]]

local Credits = {}
Credits.__index = Credits

-- Configuration
local CONFIG = {
	cardDuration = 5, -- Duration to show the credits card (seconds)
	fadeDuration = 0.5, -- Duration for fade animations (seconds)
	slideDuration = 0.75, -- Duration for slide animations (seconds)
	cardColor = Color3.fromRGB(20, 20, 30), -- Dark blue background
	accentColor = Color3.fromRGB(100, 200, 255), -- Cyan accent
	textColor = Color3.fromRGB(255, 255, 255), -- White text
	creatorColor = Color3.fromRGB(100, 200, 255), -- Cyan for creator name
}

--[[
	@function ShowCredits
	@param {number?} duration - Optional custom duration to show credits (default: 5 seconds)
	@param {Instance?} targetFrame - Optional target GUI frame to parent the credits card
	@return {Instance} The created credits frame
	
	Description: Creates and displays an animated credits card for the creator robanik.
	The card appears with a fade-in animation, stays visible for the specified duration,
	and then fades out and is cleaned up.
]]
function Credits:ShowCredits(duration, targetFrame)
	duration = duration or CONFIG.cardDuration
	targetFrame = targetFrame or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	
	-- Create main container
	local creditsContainer = Instance.new("ScreenGui")
	creditsContainer.Name = "CreditsContainer"
	creditsContainer.ResetOnSpawn = false
	creditsContainer.Enabled = true
	creditsContainer.Parent = targetFrame
	
	-- Create background card
	local card = Instance.new("Frame")
	card.Name = "CreditsCard"
	card.BackgroundColor3 = CONFIG.cardColor
	card.BorderSizePixel = 0
	card.Size = UDim2.new(0, 400, 0, 300)
	card.Position = UDim2.new(0.5, -200, 0.5, -150)
	card.BackgroundTransparency = 1 -- Start transparent for fade-in
	card.Parent = creditsContainer
	
	-- Add rounded corners using UICorner
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 12)
	uiCorner.Parent = card
	
	-- Add border effect
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = CONFIG.accentColor
	uiStroke.Thickness = 2
	uiStroke.Transparency = 0.3
	uiStroke.Parent = card
	
	-- Title text: "Credits"
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Text = "CREDITS"
	titleLabel.TextSize = 32
	titleLabel.TextColor3 = CONFIG.accentColor
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Size = UDim2.new(1, -20, 0, 50)
	titleLabel.Position = UDim2.new(0, 10, 0, 15)
	titleLabel.Parent = card
	
	-- Creator label
	local creatorLabel = Instance.new("TextLabel")
	creatorLabel.Name = "CreatorLabel"
	creatorLabel.Text = "Creator"
	creatorLabel.TextSize = 14
	creatorLabel.TextColor3 = CONFIG.textColor
	creatorLabel.BackgroundTransparency = 1
	creatorLabel.Font = Enum.Font.Gotham
	creatorLabel.Size = UDim2.new(1, -40, 0, 30)
	creatorLabel.Position = UDim2.new(0, 20, 0, 75)
	creatorLabel.TextTransparency = 1 -- Start transparent
	creatorLabel.Parent = card
	
	-- Creator name: robanik
	local creatorName = Instance.new("TextLabel")
	creatorName.Name = "CreatorName"
	creatorName.Text = "robanik"
	creatorName.TextSize = 28
	creatorName.TextColor3 = CONFIG.creatorColor
	creatorName.BackgroundTransparency = 1
	creatorName.Font = Enum.Font.GothamBold
	creatorName.Size = UDim2.new(1, -40, 0, 40)
	creatorName.Position = UDim2.new(0, 20, 0, 105)
	creatorName.TextTransparency = 1 -- Start transparent
	creatorName.Parent = card
	
	-- Separator line
	local separatorLine = Instance.new("Frame")
	separatorLine.Name = "Separator"
	separatorLine.BackgroundColor3 = CONFIG.accentColor
	separatorLine.BorderSizePixel = 0
	separatorLine.Size = UDim2.new(0, 360, 0, 2)
	separatorLine.Position = UDim2.new(0, 20, 0, 160)
	separatorLine.BackgroundTransparency = 0.5
	separatorLine.Parent = card
	
	-- Description text
	local descriptionLabel = Instance.new("TextLabel")
	descriptionLabel.Name = "Description"
	descriptionLabel.Text = "Menu System Creator\nRoblox Developer"
	descriptionLabel.TextSize = 14
	descriptionLabel.TextColor3 = CONFIG.textColor
	descriptionLabel.BackgroundTransparency = 1
	descriptionLabel.Font = Enum.Font.Gotham
	descriptionLabel.Size = UDim2.new(1, -40, 0, 80)
	descriptionLabel.Position = UDim2.new(0, 20, 0, 175)
	descriptionLabel.TextWrapped = true
	descriptionLabel.TextXAlignment = Enum.TextXAlignment.Center
	descriptionLabel.TextYAlignment = Enum.TextYAlignment.Top
	descriptionLabel.TextTransparency = 1 -- Start transparent
	descriptionLabel.Parent = card
	
	-- Animation: Fade in background
	local fadeInTween = game:GetService("TweenService"):Create(
		card,
		TweenInfo.new(CONFIG.fadeDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundTransparency = 0.2}
	)
	fadeInTween:Play()
	
	-- Animation: Slide in from bottom and fade in text
	local slideInTween = game:GetService("TweenService"):Create(
		creatorLabel,
		TweenInfo.new(CONFIG.slideDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{TextTransparency = 0.3}
	)
	slideInTween:Play()
	
	local nameSlideInTween = game:GetService("TweenService"):Create(
		creatorName,
		TweenInfo.new(CONFIG.slideDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{TextTransparency = 0}
	)
	nameSlideInTween:Play()
	
	local descSlideInTween = game:GetService("TweenService"):Create(
		descriptionLabel,
		TweenInfo.new(CONFIG.slideDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{TextTransparency = 0.4}
	)
	descSlideInTween:Play()
	
	-- Wait for specified duration
	task.wait(duration)
	
	-- Animation: Fade out
	local fadeOutTween = game:GetService("TweenService"):Create(
		card,
		TweenInfo.new(CONFIG.fadeDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{BackgroundTransparency = 1}
	)
	fadeOutTween:Play()
	fadeOutTween.Completed:Connect(function()
		creditsContainer:Destroy()
	end)
	
	return card
end

--[[
	@function HideCredits
	@param {Instance} creditsContainer - The credits GUI container to hide
	
	Description: Immediately hides and removes the credits card with a fade-out animation.
]]
function Credits:HideCredits(creditsContainer)
	if not creditsContainer or not creditsContainer:FindFirstChild("CreditsCard") then
		return
	end
	
	local card = creditsContainer:FindFirstChild("CreditsCard")
	local fadeOutTween = game:GetService("TweenService"):Create(
		card,
		TweenInfo.new(CONFIG.fadeDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{BackgroundTransparency = 1}
	)
	fadeOutTween:Play()
	fadeOutTween.Completed:Connect(function()
		creditsContainer:Destroy()
	end)
end

--[[
	@function UpdateConfig
	@param {table} newConfig - Table containing configuration values to update
	
	Description: Updates the module configuration with custom values.
	
	Example:
		Credits:UpdateConfig({
			cardDuration = 8,
			fadeDuration = 1,
			cardColor = Color3.fromRGB(30, 30, 40)
		})
]]
function Credits:UpdateConfig(newConfig)
	for key, value in pairs(newConfig) do
		if CONFIG[key] ~= nil then
			CONFIG[key] = value
		end
	end
end

return Credits
