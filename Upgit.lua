local HttpService = game:GetService("HttpService")
local Utils = script.Utils
local MDify = require(Utils.MDify)

local module = {}
module.__apiUrl = "https://api.github.com/repos/%s/%s/contents/%s"

local config = require(script.Config)

local headers = {
	["Accept"] = "application/vnd.github.v3+json";
	["Authorization"] = config.AuthToken
}

local function fetchFileContent(url : string)
	local status, response = pcall(function()
		return HttpService:GetAsync(url, true, headers)
	end)
	if status then
		return response
	end
end

local function getChangeLogVersions()
	local status, response = pcall(function()
		return HttpService:GetAsync(module.__apiUrl:format(config.Owner, config.Repo, config.Folder), true, headers)
	end)
	
	if not status then
		warn(`Unable to fetch for changelog files: `, response)
		return
	end
	
	local filesJson = HttpService:JSONDecode(response)
	local files = {}
	
	for _, file in filesJson do
		if file.type == "file" then
			local content = fetchFileContent(file.download_url)
			local formattedContent = (content and config.MarkdownFormatted) and MDify.MarkdownToRichText(content) or content
			files[#files+1] = {
				name = file.name;
				content = formattedContent;
			}
		end
	end
	
	return files
end

module.GetVersions = getChangeLogVersions

return module
