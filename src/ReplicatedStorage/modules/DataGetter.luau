type OCMAClothing = {
	id: number,
	itemType: string,
	assetType: number,
	name: string,
	description: string,
	productId: number,
	genres: {string},
	itemStatus: {any},
	itemRestrictions: {any},
	creatorHasVerifiedBadge: boolean,
	creatorType: string,
	creatorTargetId: number,
	creatorName: string,
	price: number,
	favoriteCount: number,
	offSaleDeadline: any
}
type OCMAAuditLog = {
	user: {
		id: number,
		name: string,
		displayname: string,
		role: string
	},
	asset: {
		id: number,
		name: string,
		when: string
	}
}
type OCMAAudio = {
	id: number,
	name: string,
	log: OCMAAuditLog?,
	index: number,
}
type OCMALeaderboardEntry = {}
type OCMATemplateMod = {
	report: {
		suspended: boolean,
		lastReport: number,
		reports: number
	},
	track: {
		tosLast: any,
		alt: boolean,
		changelog: any
	},
	ban: {
		expires: number,
		created: number,
		moderator: "",
		reason: ""
	},
	settings: {},
	history: {},
	favorites: {},
	dataMigrated: boolean
}

local self = {}

function self:GetDonateTab(): ({ clothing: {OCMAClothing}, funds: number })
	return game.ReplicatedStorage.events.tabs.donate.GetClothing:InvokeServer()
end
function self:GetBrowserTab(query, filter, sort, creator, page): ({OCMAAudio})
	return game.ReplicatedStorage.events.tabs.audio.Pagination:InvokeServer(query, filter, sort, creator, page)
end
function self:GetLeaderboardTab(category, page): ({OCMALeaderboardEntry})
	return game.ReplicatedStorage.events.tabs.leaderboard.Pagination:InvokeServer(category, page)
end

function self:MakeTemplateData(): (OCMATemplateMod)
	return {
		report = {
			suspended = false,
			lastReport = 0,
			reports = 0
		},
		track = {
			tosLast = false,
			alt = false,
			changelog = false,
		},
		ban = {
			expires = 0,
			created = 0,
			moderator = "",
			reason = ""
		},
		settings = require(game.ReplicatedStorage.modules.settings),
		history = {},
		favorites = {},
		dataMigrated = false
	}
end

return self
