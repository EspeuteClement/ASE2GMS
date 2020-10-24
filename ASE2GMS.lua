-- Exports Sprite to Gamemaker
-- Author : Clément Espeute (@valdenthoranar)

-- Constants
local popupName = "GMS Exporter (Beta)"
local metaDataLayerName = "_GmsExport"

local cantOpenYYPMsg = "Couldn't open project at path %s."
local cantOpenSpriteYYMsg = "Couldn't open Gamemaker sprite file at path %s."
local cantParseMsg = "Couldn't parse GameMakerProject. Maybe the file is corrupted ?"


-- Empty GMS .yy file

local emptyGMSyy = [[{
  "bboxMode": 0,
  "collisionKind": 1,
  "type": 0,
  "origin": 0,
  "preMultiplyAlpha": false,
  "edgeFiltering": false,
  "collisionTolerance": 0,
  "swfPrecision": 2.525,
  "bbox_left": 12,
  "bbox_right": 113,
  "bbox_top": 14,
  "bbox_bottom": 127,
  "HTile": false,
  "VTile": false,
  "For3D": false,
  "width": 128,
  "height": 128,
  "textureGroupId": {
    "name": "Default",
    "path": "texturegroups/Default",
  },
  "swatchColours": null,
  "gridX": 0,
  "gridY": 0,
  "frames": [

  ],
  "sequence": {
    "spriteId": {"name":"<<spritename>>","path":"sprites/<<spritename>>/<<spritename>>.yy",},
    "timeUnits": 1,
    "playback": 1,
    "playbackSpeed": 30.0,
    "playbackSpeedType": 0,
    "autoRecord": true,
    "volume": 1.0,
    "length": <<sequencelenght>>,
    "events": {"Keyframes":[],"resourceVersion":"1.0","resourceType":"KeyframeStore<MessageEventKeyframe>",},
    "moments": {"Keyframes":[],"resourceVersion":"1.0","resourceType":"KeyframeStore<MomentsEventKeyframe>",},
    "tracks": [
      {"name":"frames","spriteId":null,"keyframes":{"Keyframes":[

          ],"resourceVersion":"1.0","resourceType":"KeyframeStore<SpriteFrameKeyframe>",},"trackColour":0,"inheritsTrackColour":true,"builtinName":0,"traits":0,"interpolation":1,"tracks":[],"events":[],"modifiers":[],"isCreationTrack":false,"resourceVersion":"1.0","tags":[],"resourceType":"GMSpriteFramesTrack",},
    ],
    "visibleRange": null,
    "lockOrigin": false,
    "showBackdrop": true,
    "showBackdropImage": false,
    "backdropImagePath": "",
    "backdropImageOpacity": 0.5,
    "backdropWidth": 1366,
    "backdropHeight": 768,
    "backdropXOffset": 0.0,
    "backdropYOffset": 0.0,
    "xorigin": 0,
    "yorigin": 0,
    "eventToFunction": {},
    "eventStubScript": null,
    "parent": {"name":"<<spritename>>","path":"sprites/<<spritename>>/<<spritename>>.yy",},
    "resourceVersion": "1.3",
    "name": "<<spritename>>",
    "tags": [],
    "resourceType": "GMSequence",
  },
  "layers": [
    {"visible":true,"isLocked":false,"blendMode":0,"opacity":100.0,"displayName":"default","resourceVersion":"1.0","name":"<<layerid>>","tags":[],"resourceType":"GMImageLayer",},
  ],
  "parent": {
    "name": "Sprites",
    "path": "folders/Sprites.yy",
  },
  "resourceVersion": "1.0",
  "name": "<<spritename>>",
  "tags": [],
  "resourceType": "GMSprite",
}]]

local emptyFrameData = [[
    {"compositeImage":{"FrameId":{"name":"<<spriteguid>>","path":"sprites/<<spritename>>/<<spritename>>.yy",},"LayerId":null,"resourceVersion":"1.0","name":"","tags":[],"resourceType":"GMSpriteBitmap",},"images":[
        {"FrameId":{"name":"<<spriteguid>>","path":"sprites/<<spritename>>/<<spritename>>.yy",},"LayerId":{"name":"<<layerguid>>","path":"sprites/<<spritename>>/<<spritename>>.yy",},"resourceVersion":"1.0","name":"","tags":[],"resourceType":"GMSpriteBitmap",},
      ],"parent":{"name":"<<spritename>>","path":"sprites/<<spritename>>/<<spritename>>.yy",},"resourceVersion":"1.0","name":"<<spriteguid>>","tags":[],"resourceType":"GMSpriteFrame",},
]]

local emptyKeyframeData = [[
            {"id":"<<keyframeid>>","Key":<<keyid>>,"Length":<<keylength>>,"Stretch":false,"Disabled":false,"IsCreationKey":false,"Channels":{"0":{"Id":{"name":"<<spriteid>>","path":"sprites/<<spritename>>/<<spritename>>.yy",},"resourceVersion":"1.0","resourceType":"SpriteFrameKeyframe",},},"resourceVersion":"1.0","resourceType":"Keyframe<SpriteFrameKeyframe>",},
]]


-- Script
math.randomseed( os.time() )

local spr = app.activeSprite

if not spr then
	return
end

-- Check or create metadata layer
local metaLayer = nil

for _, layer in ipairs(spr.layers) do
	if layer.name == metaDataLayerName then
		metaLayer = layer
		app.activeLayer = metaLayer
		break;
	end
end

if not metaLayer then
	metaLayer = spr:newLayer()
	metaLayer.name = metaDataLayerName
end

metaLayer.color = Color{r = 0x03, g = 0x9d, b = 0x5b};
metaLayer.stackIndex = 9998
metaLayer.isEditable = false
metaLayer.isVisible = false


-- Open filedialog
local exportProjectPath, exportSpriteName = string.match(metaLayer.data or "", "(.*);(.*)");

if not exportSpriteName then
	exportSpriteName = spr.filename:match('\\([^\\]*)%..*');
end

local dlg = Dialog(popupName)

local chosenButton = "cancel"

function onExportClicked()
	chosenButton = "export"
	dlg:close();
end

function onCancelClicked()
	dlg:close();
end

dlg:file{	
			id="exportProjectPath",
			label="GMS Project", 
			open = true, 
			filename=exportProjectPath, 
			filetypes={"yyp"},
			entry=true,
			focus=true
		}

dlg:entry{
	id="exportSpriteName",
	label="Sprite Name",
	text=exportSpriteName
}

dlg:separator{}

dlg:button{
	text = "Export",
	onclick = onExportClicked
}:button{
	text = "Cancel",
	onclick = onCancelClicked
}

dlg:show{wait = true}

exportProjectPath = dlg.data.exportProjectPath
exportSpriteName = dlg.data.exportSpriteName

if chosenButton ~= "export" then
	return
end

-- Write files to disk

metaLayer.data = exportProjectPath .. ";" .. exportSpriteName

-- Open .yyp
do
	yoyoProject = io.open(exportProjectPath, "r");
	if not yoyoProject then
		local errMsg = string.format(cantOpenYYPMsg, exportProjectPath)
		app.alert{title=popupName, text = errMsg}
		return
	end

	local data = yoyoProject:read("*all");
	yoyoProject:close();

	local searchString = '"resources":%s*%[(%s*)'

	local _,searchIndex = string.find(data, searchString);
	local indent = string.match(data, searchString);

	if not searchIndex then
		local errMsg = cantParseMsg
		app.alert{title=popupName, text = errMsg}
		return
	end

	local exists = string.find(data, exportSpriteName .. ".yy")

	if not exists then
		local toInsert = '{"id":{"name":"%s","path":"sprites/%s/%s.yy",},"order":0,},'
		local toInsertFormated = string.format(toInsert, exportSpriteName,exportSpriteName,exportSpriteName);

		testFile = io.open(exportProjectPath, "w+");

		local outText = string.sub(data, 1, searchIndex) .. toInsertFormated .. indent .. string.sub(data, searchIndex+1, -1);
		testFile:write(outText);

		testFile:close();
	end
end


function MatchClosingBracket(str, start)
	local depth = 0;
	local len = str:len()
	local posInString = start

	while posInString <= len do
		local token = str:sub(posInString, posInString)

		if token == '[' then
			depth = depth + 1;
		elseif token == ']' then
			depth = depth - 1;
			if (depth == 0) then
				break;
			end
		end

		posInString = posInString + 1
	end

	return posInString;
end

function FormatTable(str, t)
	return str:gsub("<<(%a*)>>", 
		function(s)
			return t[s]
		end
		)
end

local random = math.random
local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

-- Create directory structure
do
	local gmsRootDir = string.gsub(exportProjectPath, '\\[^\\]*%.yyp', "")
	local dirPath = gmsRootDir .. "\\sprites\\" .. exportSpriteName;

	local spriteFilepath = dirPath .. "\\" .. exportSpriteName .. ".yy"

	local spriteFile = io.open(spriteFilepath, "r")
	local originalSpriteContent = "";

	local layerUuid = uuid();

	local sprCopy = Sprite(spr)
	sprCopy:flatten()

	if false and spriteFile then
		originalSpriteContent = spriteFile:read("*all");
		spriteFile:close();
		spriteFile = nil;
	else
		originalSpriteContent = FormatTable(emptyGMSyy,{
			spritename = exportSpriteName,
			layerid = layerUuid,
			sequencelenght = #sprCopy.cels
		}
		)
	end

	os.execute("rmdir /s /q " .. WindowsPathEscape(dirPath));
	os.execute("mkdir " .. WindowsPathEscape(dirPath));

	local _, frameRangeStart = string.find(originalSpriteContent, '"frames":%s*%[')
	local frameRangeEnd = MatchClosingBracket(originalSpriteContent, frameRangeStart)

	newSpriteContent = originalSpriteContent:sub(1, frameRangeStart) .. "\n"

	-- Copy current sprite and save each frame as a independent frame



	local spritestring = ""
	local keyframestring = ""


	for i=1,#sprCopy.cels do
		local cel = sprCopy.cels[i]
		local image = cel.image

		local curSpriteUuid = uuid();
		local curSpriteOutPath = dirPath .. "\\" .. curSpriteUuid .. ".png"
		local layerOutDir = dirPath .. "\\layers\\" .. curSpriteUuid
		local layerOutName = layerOutDir .. "\\" .. layerUuid .. ".png"
		image:saveAs(curSpriteOutPath)

		os.execute("mkdir " .. WindowsPathEscape(layerOutDir));
		os.execute("copy /Y " .. WindowsPathEscape(curSpriteOutPath) .. " " .. WindowsPathEscape(layerOutName));

		local data = {spriteguid = curSpriteUuid, spritename = exportSpriteName, layerguid = layerUuid}
		spritestring = spritestring .. FormatTable(emptyFrameData, data)

		local keyframedata = {keyframeid = uuid(),
			spriteid = curSpriteUuid, 
			spritename = exportSpriteName, 
			keyid = string.format("%.1f", i-1), 
			keylength = string.format("%.1f", 1)
		}

		keyframestring = keyframestring .. FormatTable(emptyKeyframeData, keyframedata)
	end

	sprCopy:close();

	newSpriteContent = newSpriteContent .. spritestring .. originalSpriteContent:sub(frameRangeEnd, -1)

	originalSpriteContent = newSpriteContent;

	_, tracksStart = originalSpriteContent:find('"tracks"%s*:%s*%[')
	_, keyframesStart = originalSpriteContent:find('"Keyframes"%s*:%s*%[', tracksStart)
	keyframesEnd = MatchClosingBracket(originalSpriteContent, keyframesStart)


	newSpriteContent = originalSpriteContent:sub(1, keyframesStart) .. "\n" .. keyframestring .. originalSpriteContent:sub(keyframesEnd, -1)

	spriteFile = io.open(spriteFilepath, "w+")
	if not spriteFile then
		local errMsg = string.format(cantOpenSpriteYYMsg, spriteFilepath)
		app.alert{title=popupName, text = errMsg}
		return
	end

	spriteFile:write(newSpriteContent);

	spriteFile:close()
end

app.alert{title=popupName, text = "Export done !"}