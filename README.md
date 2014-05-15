LevelHelper 2 API for Cocos2d-v3
================================



Creating a new LevelHelper 2 Project with Cocos2d-v3
====================================================


1) After installing Cocos2d-v3, open Xcode and choose File -> New Project

<img src="https://raw.githubusercontent.com/vladubogdan/LevelHelper2-Cocos2d-v3/master/readmeFiles/newCocos2dv3Project.png" alt="New Cocos2d v3 Project"/>


2) Open LevelHelper 2 and choose "New Project" from the Welcome screen or from the File menu.

In the new dialogue, set a name for your project (1), choose the location (2), select Cocos2d engine (3), select a preset for the supported devices and if required add additional ones (4) and finally click on the "Create Project" button (5). 
<img src="https://raw.githubusercontent.com/vladubogdan/LevelHelper2-Cocos2d-v3/master/readmeFiles/newLH2Project.png" alt="New LevelHelper 2 Project"/>

If you are asked if you really want to create a project in an non empty folder (you can choose to have a different folder then your Xcode Cocos2d project) choose "Create Project" or choose a different folder.

<img src="https://raw.githubusercontent.com/vladubogdan/LevelHelper2-Cocos2d-v3/master/readmeFiles/newLH2ProjectWarning.png" alt="New LevelHelper 2 Project"/>

3) In the Untitled document window choose "New Optimised Sprite Sheet Image File" from the "Project Navigator" section.

<img src="https://raw.githubusercontent.com/vladubogdan/LevelHelper2-Cocos2d-v3/master/readmeFiles/newSpriteSheetFile.png" alt="New Sprite Sheet File"/>

4) In the new sprite sheet tab drag a couple of images. 

<img src="https://raw.githubusercontent.com/vladubogdan/LevelHelper2-Cocos2d-v3/master/readmeFiles/dragImagesIntoSpriteSheet.png" alt="Drag Image Files"/>

5) Save the sprite sheet file by clicking "Command + S", choose a name and the location of your project. 

<img src="https://raw.githubusercontent.com/vladubogdan/LevelHelper2-Cocos2d-v3/master/readmeFiles/saveSpriteSheets.png" alt="Save Sprite Sheet File"/>


6) Now, when you go back to the level editor, the sprite sheet file will be available in the project navigator. Expand the file in order to see all individual sprites.
Drag a few in the editor in order to create a very basic level.

<img src="https://raw.githubusercontent.com/vladubogdan/LevelHelper2-Cocos2d-v3/master/readmeFiles/dragSprites.png" alt="Drag Sprites In level"/>


7) Lets add physics simulation on the newly added sprites. Go to the "Physics Inspector" tab and enable "Boundaries", in order to restrict our sprites to not fall out the screen.

<img src="https://raw.githubusercontent.com/vladubogdan/LevelHelper2-Cocos2d-v3/master/readmeFiles/boundaries.png" alt="Boundaries"/>

Select all sprites in the level and now choose "Dynamic" as the physics "Type" of the selected sprites.

<img src="https://raw.githubusercontent.com/vladubogdan/LevelHelper2-Cocos2d-v3/master/readmeFiles/dynamicType.png" alt="Dynamic Type"/>


8) Save the level by clicking "Command-S" and then publish to an optimised Cocos2d format that will be loaded by the API found on this repository.

<img src="https://raw.githubusercontent.com/vladubogdan/LevelHelper2-Cocos2d-v3/master/readmeFiles/saveLevel.png" alt="Save Level"/>

<img src="https://raw.githubusercontent.com/vladubogdan/LevelHelper2-Cocos2d-v3/master/readmeFiles/publishLevel.png" alt="Publish Level"/>

9) Add the "levels" folder in your Xcode project using "Create folder references for any added folders" option so that every time we publish a new level Xcode will automatically refresh.

<img src="https://raw.githubusercontent.com/vladubogdan/LevelHelper2-Cocos2d-v3/master/readmeFiles/addLevels.png" alt="Add Levels"/>


10) Add the "LevelHelper-API" folder found in this repository in your Xcode project. This time choose "Create groups for any added folders".

<img src="https://raw.githubusercontent.com/vladubogdan/LevelHelper2-Cocos2d-v3/master/readmeFiles/addLib.png" alt="Add Lib"/>

11) Setup your project to use the library by clicking on your Xcode Project (1), then on your target (2), then on "Build Phases" (3) and finally dragging the "libLevelHelper2API.a" file inside "Link Binary With Libraries" list. 

<img src="https://raw.githubusercontent.com/vladubogdan/LevelHelper2-Cocos2d-v3/master/readmeFiles/setupLib.png" alt="Setup Lib"/>