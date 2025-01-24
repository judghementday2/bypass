local fonts = {};
local httpService = game:GetService('HttpService');

fonts.availableFonts = {};
fonts.fontWeights = {
    light = 100,
    extralight = 200,
    ultralight = 200,
    normal = 300,
    regular = 400,
    semibold = 500,
    bold = 600,
    extrabold = 700,
    heavy = 800
};

function fonts:addFont(directory, fontInfo)
    fontInfo = fontInfo or {};
    fontInfo.weight = fontInfo.weight or "regular";
    fontInfo.style = fontInfo.style or "normal";

    if not fontInfo.link or not fontInfo.name then 
        return;
    end;

    if fonts.blocked then 
        return;
    end;

    local folder = string.format("%s/%s", directory or "", fontInfo.name);
    local weight = fonts.fontWeights[fontInfo.weight] == 400 and "" or fontInfo.weight;
    local style = fontInfo.style:lower() == "normal" and "" or fontInfo.style;
    local fontName = string.format("%s%s%s", fontInfo.name, weight, style);

    if not isfolder(folder) then 
        makefolder(folder);
    end;

    if not isfile(string.format("%s/%s.font", folder, fontName)) then
        writefile(string.format("%s/%s.font", folder, fontName), game:HttpGet(fontInfo.link));
    end;

    if not isfile(string.format("%s/%sData.json", folder, fontInfo.name)) then
        local fontData = {
            name = string.format("%s %s", fontInfo.weight, fontInfo.style),
            weight = fonts.fontWeights[fontInfo.weight] or fonts.fontWeights[fontInfo.weight:gsub("%s+", "")],
            style = fontInfo.style:lower(),
            assetid = getcustomasset(string.format("%s/%s.font", folder, fontName))
        };
        local jsonData = httpService:JSONEncode({ name = fontName, faces = { fontData } });
        writefile(string.format("%s/%sData.json", folder, fontInfo.name), jsonData);
    else
        local isRegistered = false;
        local jsonData = httpService:JSONDecode(readfile(string.format("%s/%sData.json", folder, fontInfo.name)));
        local fontData = {
            name = string.format("%s %s", fontInfo.weight, fontInfo.style),
            weight = fonts.fontWeights[fontInfo.weight] or fonts.fontWeights[fontInfo.weight:gsub("%s+", "")],
            style = fontInfo.style:lower(),
            assetid = getcustomasset(string.format("%s/%s.font", folder, fontName))
        };

        for _, v in ipairs(jsonData.faces) do
            if v.name == fontData.name then 
                isRegistered = true; 
                break; 
            end;
        end;

        if not isRegistered then
            table.insert(jsonData.faces, fontData);
            jsonData = httpService:JSONEncode(jsonData);
            writefile(string.format("%s/%sData.json", folder, fontInfo.name), jsonData);
        end;
    end;

    fonts.availableFonts[fontName] = fonts.availableFonts[fontName] or Font.new(getcustomasset(string.format("%s/%sData.json", folder, fontInfo.name)));
    return fonts.availableFonts[fontName];
end;

return fonts;
