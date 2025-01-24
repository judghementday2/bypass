local typeface = {}

do
    typeface.incompatible = function() typeface.denied = true end
    isfile = isfile or typeface.incompatible()
    isfolder = isfolder or typeface.incompatible()
    writefile = writefile or typeface.incompatible()
    makefolder = makefolder or typeface.incompatible()
    getcustomasset = getcustomasset or typeface.incompatible()
end

local http = cloneref and cloneref(game:GetService 'HttpService') or game:GetService 'HttpService'

typeface.typefaces = {}
typeface.weightnum = {
    ["thin"] = 100,
    ["extralight"] = 200,
    ["ultralight"] = 200,
    ["light"] = 300,
    ["normal"] = 400,
    ["regular"] = 400,
    ["medium"] = 500,
    ["semibold"] = 600,
    ["demibold"] = 600,
    ["bold"] = 700,
    ["extrabold"] = 800,
    ["ultrabold"] = 900,
    ["heavy"] = 900
}

function typeface:register(path, asset)
    asset = asset or {}
    asset.weight = asset.weight or "regular"
    asset.style = asset.style or "normal"
    if not asset.link or not asset.name then 
        return
    end
    if typeface.denied then 
        return
    end
    local directory = string.format("%s/%s", path or "", asset.name)
    local weight = typeface.weightnum[asset.weight] == 400 and "" or asset.weight
    local style = string.lower(asset.style) == "normal" and "" or asset.style
    local name = string.format("%s%s%s", asset.name, weight, style)
    if not isfolder(directory) then
        makefolder(directory)
    end
    if not isfile(string.format("%s/%s.font", directory, name)) then
        writefile(string.format("%s/%s.font", directory, name), game:HttpGet(asset.link))
    end
    if not isfile(string.format("%s/%sFamilies.json", directory, asset.name)) then 
        local data = { 
            name = string.format("%s %s", asset.weight, asset.style),
            weight = typeface.weightnum[asset.weight] or typeface.weightnum[asset.weight:gsub("%s+", "")],
            style = string.lower(asset.style),
            assetid = getcustomasset(string.format("%s/%s.font", directory, name))
        }
        local jsonfile = http:JSONEncode({ name = name, faces = { data } })
        writefile(string.format("%s/%sFamilies.json", directory, asset.name), jsonfile)
    else
        local registered = false
        local jsonfile = http:JSONDecode(readfile(string.format("%s/%sFamilies.json", directory, asset.name)))
        local data = { 
            name = string.format("%s %s", asset.weight, asset.style),
            weight = typeface.weightnum[asset.weight] or typeface.weightnum[asset.weight:gsub("%s+", "")],
            style = string.lower(asset.style),
            assetid = getcustomasset(string.format("%s/%s.font", directory, name))
        }
        for _, v in ipairs(jsonfile.faces) do
            if v.name == data.name then 
                registered = true
                break
            end
        end
        if not registered then
            table.insert(jsonfile.faces, data)
            jsonfile = http:JSONEncode(jsonfile)
            writefile(string.format("%s/%sFamilies.json", directory, asset.name), jsonfile)
        end
    end
    typeface.typefaces[name] = typeface.typefaces[name] or Font.new(getcustomasset(string.format("%s/%sFamilies.json", directory, asset.name)))
    return typeface.typefaces[name]
end

return typeface
