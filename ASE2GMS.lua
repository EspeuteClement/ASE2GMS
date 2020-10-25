-- Exports Sprite to Gamemaker
-- Author : Clément Espeute (@valdenthoranar)

-- Constants
local popupName = "GMS Exporter (Beta)"
local metaDataLayerName = "__ase2gms"
local hitboxLayerName = "Collision"
local pivotLayerName = "Origin"

local layersColor = Color{r = 0x03, g = 0x9d, b = 0x5b};
local sublayersColor = Color{r = 0x03, g = 0x9d, b = 0x5b, a = 127};


local cantOpenYYPMsg = "Couldn't open project at path %s."
local cantOpenSpriteYYMsg = "Couldn't open Gamemaker sprite file at path %s."
local cantParseMsg = "Couldn't parse GameMakerProject. Maybe the file is corrupted ?"

local origins = {
	"Top Left",
	"Top Center",
	"Top Right",
	"Middle Left",
	"Middle Centre",
	"Middle Right",
	"Bottom Left",
	"Bottom Centre",
	"Bottom Right",
	"Custom"
}

-- Empty GMS .yy file

local emptyGMSyy = [[{
  "bboxMode": 2,
  "collisionKind": 1,
  "type": 0,
  "origin": <<exportorigin>>,
  "preMultiplyAlpha": false,
  "edgeFiltering": false,
  "collisionTolerance": 0,
  "swfPrecision": 2.525,
  "bbox_left": <<bboxleft>>,
  "bbox_right": <<bboxright>>,
  "bbox_top": <<bboxtop>>,
  "bbox_bottom": <<bboxbottom>>,
  "HTile": false,
  "VTile": false,
  "For3D": false,
  "width": <<sprwidth>>,
  "height": <<sprheigth>>,
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
    "xorigin": <<xorigin>>,
    "yorigin": <<yorigin>>,
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

function StringToSettings(str, t)
	str:gsub("([^;]*)=([^;]*)", function(k,v)
		t[k] = v
	end
	)
	return t
end

function SettingsToString(settings)
	local s = ""
	for k, v in pairs(settings) do
		s = s .. k .."="..v..";"
	end
	return s
end

-- Script
math.randomseed( os.time() )

local spr = app.activeSprite

if not spr then
	return
end

-- Check or create metadata layer
local metaLayer = nil

for _, layer in ipairs(spr.layers) do
	if layer and layer.name == metaDataLayerName then
		if not layer.isGroup then
			spr:deleteLayer(layer)
		else
			metaLayer = layer
		end
		break;
	end
end

local wasMetaLayerCreated = false
if not metaLayer then
	metaLayer = spr:newGroup()
	metaLayer.name = metaDataLayerName
	wasMetaLayerCreated = true
end

metaLayer.color = layersColor
metaLayer.stackIndex = 9998
--metaLayer.isEditable = false
--metaLayer.isVisible = false

local pivotLayer, hitboxLayer = nil, nil

for _, layer in ipairs(metaLayer.layers) do
	if layer.name == hitboxLayerName then
		hitboxLayer = layer
	end

	if (layer.name == pivotLayerName) then
		pivotLayer = layer
	end
end

if not hitboxLayer then
	hitboxLayer = spr:newLayer()
	hitboxLayer.name = hitboxLayerName
	hitboxLayer.parent = metaLayer
	hitboxLayer.isContinuous = true
	hitboxLayer.opacity = 127
	hitboxLayer.color = sublayersColor
end

local hitboxCel = hitboxLayer:cel(1)
if not hitboxCel then
	hitboxCel = spr:newCel(hitboxLayer, 1)

	-- Fill cell with black (full hitbox)
	for it in hitboxCel.image:pixels() do
		it(app.pixelColor.rgba(0,0,0))
	end
end


if not pivotLayer then
	pivotLayer = spr:newLayer()
	pivotLayer.name = pivotLayerName
	pivotLayer.parent = metaLayer
	pivotLayer.isContinuous = true
	pivotLayer.opacity = 127
	pivotLayer.color = sublayersColor

end

local pivotCel = pivotLayer:cel(1)
if not pivotCel then
	pivotCel = spr:newCel(pivotLayer, 1, Image(5,5, spr.colorMode), Point(-2,-2))

	-- Draw small cross
	local color = app.pixelColor.rgba(255,0,0)
	local img = pivotCel.image;

	img:drawPixel(0,2,color)
	img:drawPixel(1,2,color)
	img:drawPixel(3,2,color)
	img:drawPixel(4,2,color)

	img:drawPixel(1,1,color)
	img:drawPixel(1,3,color)
	img:drawPixel(3,1,color)
	img:drawPixel(3,3,color)

	img:drawPixel(2,0,color)
	img:drawPixel(2,1,color)
	img:drawPixel(2,3,color)
	img:drawPixel(2,4,color)
end


function GetCellCenter(cel)
	return Point(math.floor(cel.bounds.x + cel.bounds.width/2), math.floor(cel.bounds.y + cel.bounds.width/2));
end

-- Find pivot based on origin layer position
local pivotPoint = GetCellCenter(pivotCel);
local spriteCenter = GetCellCenter(spr);
local pivotId = 0;

if (pivotPoint.x == 0) then
	pivotId = pivotId + 0
elseif (pivotPoint.x == spriteCenter) then
	pivotId = pivotId + 1
elseif (pivotPoint.x == spr.bounds.width) then
	pivotId = pivotId + 2
else
	-- Pivot is custom
	pivotId = 9
end

if (pivotPoint.y == 0) then
	pivotId = pivotId + 0
elseif (pivotPoint.y == spriteCenter) then
	pivotId = pivotId + 3
elseif (pivotPoint.y == spr.bounds.height) then
	pivotId = pivotId + 6
else
	-- Pivot is custom
	pivotId = 9
end

if pivotId >= 9 then
	pivotId = 9
end

app.refresh()

-- Open filedialog
local settings = {
	exportProjectPath = nil,
	exportSpriteName = app.fs.fileTitle(spr.filename),
	exportOrigin = "0"
}
settings = StringToSettings(metaLayer.data, settings);

local dlg = Dialog(popupName)

local chosenButton = "cancel"

function onExportClicked()
	chosenButton = "export"
	dlg:close();
end

function onSaveClicked()
	chosenButton = "save"
	dlg:close();
end

function onCancelClicked()
	dlg:close();
end

function onDebugClicked()
	local cel = pivotLayer:cel(1)
	if cel then
		print(string.format("x:%d y:%d w:%d h:%d", cel.bounds.x, cel.bounds.y, cel.bounds.width, cel.bounds.height))
	end
	dlg:close();
end

dlg:file{	
			id="exportProjectPath",
			label="GMS Project", 
			open = true, 
			filename=settings.exportProjectPath, 
			filetypes={"yyp"},
			entry=false,
			focus=true
		}

dlg:entry{
	id="exportSpriteName",
	label="Sprite Name",
	text=settings.exportSpriteName
}

dlg:combobox{
	id="origin",
	label="Origin",
	option=origins[pivotId+1],
	options=origins
}

dlg:separator{}

dlg:button{
	text = "Export",
	onclick = onExportClicked
}:button{
	text = "Save",
	onclick = onSaveClicked
}:button{
	text = "Cancel",
	onclick = onCancelClicked
}

dlg:show{wait = true}

if chosenButton == "cancel" then
	if (wasMetaLayerCreated) then
		spr:deleteLayer(metaLayer)
	end
	return
end

settings.exportProjectPath = dlg.data.exportProjectPath
settings.exportSpriteName = dlg.data.exportSpriteName

for k,v in ipairs(origins) do
	if v == dlg.data.origin then
		pivotId = k - 1
		break;
	end
end

local width = spr.width;
local height = spr.height;

local xorigin, yorigin = 0, 0

if (pivotId < 9) then
	if pivotId % 3 == 0 then
		xorigin = 0
	elseif pivotId % 3 == 1 then
		xorigin = math.floor(width/2)
	else
		xorigin = width
	end

	if math.floor(pivotId/3) == 0 then
		yorigin = 0
	elseif math.floor(pivotId/3) == 1 then
		yorigin = math.floor(height/2)
	else
		yorigin = height
	end

	pivotCel.position = Point(xorigin - math.floor(pivotCel.bounds.width/2), yorigin - math.floor(pivotCel.bounds.height/2));
end


if chosenButton == "save" then
	return
end

-- Write files to disk

metaLayer.data = SettingsToString(settings)

local wasHitboxLayerVisible, wasPivotLayerVisible = hitboxLayer.isVisible, pivotLayer.isVisible
hitboxLayer.isVisible, pivotLayer.isVisible = false, false


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

local commands = ""

function QueueCommand(cmd)
	if commands:len() > 0 then
		commands = commands .. " & "
	end
	commands = commands .. cmd
end

function WindowsPathEscape(str)
	return str:gsub("/","\\");
end

-- Create directory structure
function ExportTag(spriteToExport, from, to, exportName)
	
	-- Security to avoid creating an empty path for dirPath
	if not exportName or exportName:len() < 1 then
		return
	end

	local gmsRootDir = string.gsub(settings.exportProjectPath, '\\[^\\]*%.yyp', "")
	local dirPath = gmsRootDir .. "\\sprites\\" .. exportName;

	local spriteFilepath = dirPath .. "\\" .. exportName .. ".yy"

	local spriteFile = io.open(spriteFilepath, "r")
	local originalSpriteContent = "";

	local layerUuid = uuid();

	local center = GetCellCenter(pivotCel)
	local bbox = hitboxCel.bounds

	if false and spriteFile then
		originalSpriteContent = spriteFile:read("*all");
		spriteFile:close();
		spriteFile = nil;
	else
		originalSpriteContent = FormatTable(emptyGMSyy,{
			spritename = exportName,
			layerid = layerUuid,
			sequencelenght = to-from+1,
			sprwidth = width,
			sprheigth = height,
			exportorigin = pivotId,
			xorigin = center.x,
			yorigin = center.y,
			bboxleft = bbox.x,
			bboxright = bbox.x + bbox.width-1,
			bboxtop = bbox.y,
			bboxbottom = bbox.y + bbox.height-1,
		}
		)
	end

	assert(dirPath:len() > 10, "Fatal error, dirPath was too short, aborting to avoid wiping your computer")
	os.execute("rmdir /s /q " .. WindowsPathEscape(dirPath));
	os.execute("mkdir " .. WindowsPathEscape(dirPath));

	local _, frameRangeStart = string.find(originalSpriteContent, '"frames":%s*%[')
	local frameRangeEnd = MatchClosingBracket(originalSpriteContent, frameRangeStart)

	newSpriteContent = originalSpriteContent:sub(1, frameRangeStart) .. "\n"

	-- Copy current sprite and save each frame as a independent frame

	local spritestring = ""
	local keyframestring = ""

	local image = Image(spriteToExport);

	local count = to-from+1
	for i=1,count do
		image:clear()
		image:drawSprite(spriteToExport, from+i-1);

		local curSpriteUuid = uuid();
		local curSpriteOutPath = dirPath .. "\\" .. curSpriteUuid .. ".png"
		local layerOutDir = dirPath .. "\\layers\\" .. curSpriteUuid
		local layerOutName = layerOutDir .. "\\" .. layerUuid .. ".png"
		image:saveAs(curSpriteOutPath)

		QueueCommand("mkdir " .. WindowsPathEscape(layerOutDir));
		QueueCommand("copy /Y " .. WindowsPathEscape(curSpriteOutPath) .. " " .. WindowsPathEscape(layerOutName));

		local data = {spriteguid = curSpriteUuid, spritename = exportName, layerguid = layerUuid}
		spritestring = spritestring .. FormatTable(emptyFrameData, data)

		local keyframedata = {keyframeid = uuid(),
			spriteid = curSpriteUuid, 
			spritename = exportName, 
			keyid = string.format("%.1f", i-1), 
			keylength = string.format("%.1f", 1),
		}

		keyframestring = keyframestring .. FormatTable(emptyKeyframeData, keyframedata)
	end

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

yoyoProject = io.open(settings.exportProjectPath, "r");
if not yoyoProject then
	local errMsg = string.format(cantOpenYYPMsg, settings.exportProjectPath)
	app.alert{title=popupName, text = errMsg}
	return
end

local yoyoProjectText = yoyoProject:read("*all");
yoyoProject:close();

local filesString = ""

function sanitize(str)
	return str:gsub("[^%w%-]", "_");
end


if #spr.tags > 0 then
	for i, tag in ipairs(spr.tags) do
		dlg.data.progressBar = i
		local tagName = sanitize(tag.name);
		local exportTagName = settings.exportSpriteName .. tagName
		
		ExportTag(spr, tag.fromFrame.frameNumber, tag.toFrame.frameNumber, exportTagName)

		local exists = string.find(yoyoProjectText, exportTagName .. ".yy")

		if not exists then
			local toInsert = '\n    {"id":{"name":"%s","path":"sprites/%s/%s.yy",},"order":0,},'
			local toInsertFormated = string.format(toInsert, exportTagName,exportTagName,exportTagName);
			filesString = filesString .. toInsertFormated
		end
	end
else
	print("can't do file without tags at the moment")
	return
end

os.execute(commands)

-- Open .yyp
do
	local searchString = '"resources":%s*%['

	local _,searchIndex = string.find(yoyoProjectText, searchString);

	if not searchIndex then
		local errMsg = cantParseMsg
		app.alert{title=popupName, text = errMsg}
		return
	end

	local exists = string.find(yoyoProjectText, settings.exportSpriteName .. ".yy")

	if filesString:len() > 0 then
		testFile = io.open(settings.exportProjectPath, "w+");

		local outText = string.sub(yoyoProjectText, 1, searchIndex) .. filesString .. string.sub(yoyoProjectText, searchIndex+1, -1);
		testFile:write(outText);

		testFile:close();
	end
end

hitboxLayer.isVisible, pivotLayer.isVisible = wasHitboxLayerVisible, wasPivotLayerVisible 

app.alert{title=popupName, text = "Export done !"}

