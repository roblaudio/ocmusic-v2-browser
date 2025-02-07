local httpr = game:GetService("HttpService")
local socials = game:GetService("SocialService")
local plr = game.Players.LocalPlayer

local obj = {}
function obj:ShareSong(id)
	local rawr = Instance.new("ExperienceInviteOptions")
	rawr.InviteMessageId = "dca635cc-3eb7-2741-aa9f-7e9189adace3"
	rawr.PromptMessage = "Share this song with your friends!"
	rawr.LaunchData = "play="..tostring(id)
	socials:PromptGameInvite(plr, rawr)
end

function obj:InviteFriend()
	local rawr = Instance.new("ExperienceInviteOptions")
	rawr.InviteMessageId = "4a9af983-4f0e-6640-945b-eed8602dcf52"
	rawr.PromptMessage = "Invite your friends!"
	socials:PromptGameInvite(plr, rawr)
end

function obj:GeneratePlayLink(launchdata)
	return `https://www.roblox.com/games/start?placeId=9937132110&launchData={httpr:UrlEncode(launchdata)}`
end

return obj
