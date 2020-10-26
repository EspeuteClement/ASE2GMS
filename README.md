# Aseprite to Gamemaker Studio 2 exporter

This is a work in progress extension for Aseprite that allows you to export sprites directly into the Gamemaker Studio 2 engine, version 2.3.0.529. 

![](doc/Screenshot01.png?raw=true "ASE2GMS")

**Important notice : This script is very likely to break with Gamemaker Studio 2 versions other than 2.3.0.529. Please use caution**

**This script is in beta and could corrupt your Gamemaker projects. Be sure to ALWAYS have backups of your projects, or use versionning software**

**This script is only compatible with windows**

## Features
* Exports your animation directly into Gamemaker studio 2 in one step
* Set properties like Sprite Origin and Collisions directly inside of Aseprite
* Export all your tags into separate Gamemaker sprites in one step, or choose the one you want to export

## Installation
1. Download ASE2GMS.lua
2. Open Aseprite and go to File > Scripts > Open Scripts Folder
3. Place the ASE2GMS.lua file in there
4. Click the File > Script > Rescan Script Folders
5. You shoud now have File > Scripts > ASE2GMS

## Usage
1. Launch the script
2. Locate the .yyp file of your Gamemaker project (at the root of your gamemaker project)
3. Change the other settings
4. Hit Export

The plugin will create a layer group called __ase2gms that saves your settings for the next export, and has two additional layers that allows you to set a custom origin and/or collision box.

The Origin will be set as the center of the first frame of the Origin layer. A little target will be created automaticaly for you the first time the script is run, or if the Collision layer is missing that first frame. You can move this target and it will change the sprite origin for the next export. If for some reason the origin in Gamemaker is misplaced, check if you have not accidentally added some pixels to the Collision layer. To do this, with any tool, hold the Ctrl key of your keyboard, this should show you the bounding box of the Origin Layer. It should be a 5x5 pixel square

The Collision works in a similar way. The collision of your sprite is calculated using the bounding box of the first frame of the Collision layer. You can edit the bounding box by resizing that frame with the Rectangular Marquee Tool. You can check the bounding box by pressing Ctrl above the sprite, a blue rectangle outline should appear.

