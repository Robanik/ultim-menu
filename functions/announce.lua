--[[
	announce.lua
	Creator: robanik
	Created: 2026-01-09 02:20:17 UTC
	
	Roblox Lua function for displaying system announcement messages
]]

local announce = {}

--[[
	DisplayAnnouncement
	
	Displays a system announcement message to a player
	
	@param player (Player) - The player to display the announcement to
	@param message (string) - The announcement message text
	@param duration (number) - Duration in seconds to display the announcement (default: 5)
	@param style (string) - Announcement style: "info", "warning", "success", "error" (default: "info")
	
	@return (boolean) - True if announcement was displayed successfully, false otherwise
]]
function announce:DisplayAnnouncement(player, message, duration, style)
	if not player or not player:FindFirstChild("PlayerGui") then
		warn("Invalid player or PlayerGui not found")
		return false
	end
	
	if not message or type(message) ~= "string" or message == "" then
		warn("Invalid message: message must be a non-empty string")
		return false
	end
	
	duration = duration or 5
	style = style or "info"
	
	if duration <= 0 then
		warn("Invalid duration: must be greater than 0")
		return false
	end
	
	-- Create the announcement GUI
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AnnouncementGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:FindFirstChild("PlayerGui")
	
	-- Create main announcement frame
	local announcementFrame = Instance.new("Frame")
	announcementFrame.Name = "AnnouncementFrame"
	announcementFrame.Size = UDim2.new(0, 400, 0, 80)
	announcementFrame.Position = UDim2.new(0.5, -200, 0.1, 0)
	announcementFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	announcementFrame.BorderSizePixel = 0
	announcementFrame.Parent = screenGui
	
	-- Add corner rounding
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = announcementFrame
	
	-- Add colored accent based on style
	local accentColors = {
		info = Color3.fromRGB(59, 89, 152),
		warning = Color3.fromRGB(255, 193, 7),
		success = Color3.fromRGB(76, 175, 80),
		error = Color3.fromRGB(244, 67, 54)
	}
	
	local accentColor = accentColors[style] or accentColors.info
	
	local accentFrame = Instance.new("Frame")
	accentFrame.Name = "AccentFrame"
	accentFrame.Size = UDim2.new(0, 5, 1, 0)
	accentFrame.BackgroundColor3 = accentColor
	accentFrame.BorderSizePixel = 0
	accentFrame.Parent = announcementFrame
	
	-- Add padding frame for content
	local paddingFrame = Instance.new("Frame")
	paddingFrame.Name = "ContentFrame"
	paddingFrame.Size = UDim2.new(1, -10, 1, 0)
	paddingFrame.Position = UDim2.new(0, 10, 0, 0)
	paddingFrame.BackgroundTransparency = 1
	paddingFrame.Parent = announcementFrame
	
	-- Create creator label
	local creatorLabel = Instance.new("TextLabel")
	creatorLabel.Name = "CreatorLabel"
	creatorLabel.Size = UDim2.new(1, 0, 0, 20)
	creatorLabel.Position = UDim2.new(0, 0, 0, 5)
	creatorLabel.BackgroundTransparency = 1
	creatorLabel.Text = "System Announcement"
	creatorLabel.TextColor3 = accentColor
	creatorLabel.TextSize = 12
	creatorLabel.TextXAlignment = Enum.TextXAlignment.Left
	creatorLabel.Font = Enum.Font.GothamBold
	creatorLabel.Parent = paddingFrame
	
	-- Create message label
	local messageLabel = Instance.new("TextLabel")
	messageLabel.Name = "MessageLabel"
	messageLabel.Size = UDim2.new(1, 0, 0, 35)
	messageLabel.Position = UDim2.new(0, 0, 0, 25)
	messageLabel.BackgroundTransparency = 1
	messageLabel.Text = message
	messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	messageLabel.TextSize = 14
	messageLabel.TextXAlignment = Enum.TextXAlignment.Left
	messageLabel.TextWrapped = true
	messageLabel.Font = Enum.Font.Gotham
	messageLabel.Parent = paddingFrame
	
	-- Fade in animation
	announcementFrame.GroupTransparency = 1
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenIn = game:GetService("TweenService"):Create(announcementFrame, tweenInfo, {GroupTransparency = 0})
	tweenIn:Play()
	
	-- Wait for the specified duration
	task.wait(duration)
	
	-- Fade out animation
	tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local tweenOut = game:GetService("TweenService"):Create(announcementFrame, tweenInfo, {GroupTransparency = 1})
	tweenOut:Play()
	tweenOut.Completed:Connect(function()
		screenGui:Destroy()
	end)
	
	return true
end

--[[
	SystemAnnounce
	
	Displays a system-wide announcement to all players
	
	@param message (string) - The announcement message text
	@param duration (number) - Duration in seconds to display the announcement (default: 5)
	@param style (string) - Announcement style: "info", "warning", "success", "error" (default: "info")
]]
function announce:SystemAnnounce(message, duration, style)
	local players = game:GetService("Players"):GetPlayers()
	
	for _, player in ipairs(players) do
		self:DisplayAnnouncement(player, message, duration, style)
	end
end

return announce