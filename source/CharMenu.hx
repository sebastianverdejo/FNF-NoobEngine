// This is completely re-typed out, I did this so I didn't just copy and paste so that HOPEFULLY it works better and doesn't need that many changes.
package;

import Section.SwagSection;

// These may be swapped depending on what may need it. Some older ones may need a different one based on the 'Song' TypeDef
import Song.SwagSong; // Usually Used One
// import Song.SongData; // What my version of Kade engine is apparently using

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import flixel.FlxCamera;
import flixel.addons.display.FlxBackdrop;
import haxe.Json;
import Boyfriend.Boyfriend;
import Character.Character;
import HealthIcon.HealthIcon;
import flixel.ui.FlxBar;

import StringTools;
import FreeplayState;

class CharMenu extends MusicBeatState{
    // Selectable Character Variables
    var selectableCharacters:Array<String> = ['dad', 'dad', 'bf', 'bf-christmas', 'bf-pixel', 'bf-holding-gf', 'pico-player', 'tankman-player']; // Currently Selectable characters
    var selectableCharactersNames:Array<String> = ['Default Character', 'Play as the Opponent', 'Boyfriend', 'Boyfriend but Christmas', 'Boyfriend but Pixel', 'Boyfriend holding Girlfriend', 'Pico', 'Tankman']; // Characters names

    var unlockableChars:Array<String> = ['tankman-player']; // Unlockable Characters
    var unlockableCharsNames:Array<String> = ['UGH']; // Names of unlockable Characters
    
    // This is the characters that actually appear on the menu
    var unlockedCharacters:Array<String> = [];
    var unlockedCharactersNames:Array<String> = [];

    // Folder locations
    var fontFolder:String = 'assets/fonts/'; // Please don't change unless font folder changes, leads to the fonts folder
    var sharedFolder:String = 'shared'; // Please don't change, leads to the shared folder

    // Variables for what is shown on screen
    var curSelected:Int = 0; // Which character is selected
    var icon:HealthIcon; // The healthicon of the selected character
    var menuBG:FlxSprite; // The background
    var colorTween:FlxTween;
    private var imageArray:Array<Boyfriend> = []; // Array of all the selectable characters
    var selectedCharName:FlxText; // Name of selected character

    // Additional Variables
    var alreadySelected:Bool = false; // If the character is already selected
    var ifCharsAreUnlocked:Array<Bool> = FlxG.save.data.daUnlockedChars;

    // Animated Arrows Variables
    var newArrows:FlxSprite;
    var backdrops:FlxBackdrop = new FlxBackdrop(Paths.image('backdrop'), #if (flixel < "5.0.0") 0, 0, true, true #else XY #end);

    override function create()
    {
        FlxG.sound.playMusic(Paths.music('charsomethin'));

        // Useless for now
        if (ifCharsAreUnlocked == null) 
        {
            ifCharsAreUnlocked = [false];
            FlxG.save.data.daUnlockedChars = [false];
        }
        // If the unlocked chars are empty, fill it with defaults
        if (unlockedCharacters == null) 
        {
            unlockedCharacters = selectableCharacters;
            unlockedCharacters[0] = PlayState.SONG.player1;
        } 
        // If names are empty, fill it with defaults
        if (unlockedCharactersNames == null) 
        {
            unlockedCharactersNames = selectableCharactersNames;
        }

        unlockedCharacters[0] = PlayState.SONG.player1;
        unlockedCharacters[1] = PlayState.SONG.player2;

        unlockedCharsCheck();

        // Making sure the background is added first to be in the back and then adding the character names and character images afterwords
        menuBG = new FlxSprite().loadGraphic(Paths.image('menuBGMagenta'));
        menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
        menuBG.updateHitbox();
        menuBG.screenCenter();
        menuBG.antialiasing = true;
        add(menuBG);

        if(ClientPrefs.hideCheckers == false)
			add(backdrops);
		else
			menuBG.screenCenter();
			
		backdrops.scrollFactor.set(0, 0.07);

		#if (flixel < "5.0.0")
        backdrops.angle = 45;
        #end

        // Adds the chars to the selection
        for (i in 0...unlockedCharacters.length)
        {
            var characterImage:Boyfriend = new Boyfriend(0, 0, unlockedCharacters[i]);
            if (StringTools.endsWith(unlockedCharacters[i], '-pixel'))
                characterImage.scale.set(5.5, 5.5);
            else
                characterImage.scale.set(0.8, 0.8);

            characterImage.screenCenter(XY);
            imageArray.push(characterImage);
            add(characterImage);
        }

        // Character select text at the top of the screen
        var selectionHeader:Alphabet = new Alphabet(0, 50, 'Character Select', true);
        selectionHeader.screenCenter(X);
        add(selectionHeader);

        // Old arrows
        // The left and right arrows on screen
        /*
        var arrows:FlxSprite = new FlxSprite().loadGraphic(Paths.image('charselect/arrowSelection'));
        arrows.setGraphicSize(Std.int(arrows.width * 1.1));
        arrows.screenCenter();
        arrows.antialiasing = true;
        add(arrows);
        */

        // Not centered Correctly, need to figure out how to do that
        // New Animated Arrows
        newArrows = new FlxSprite();
        newArrows.frames = Paths.getSparrowAtlas('charselect/newArrows');
        newArrows.animation.addByPrefix('idle', 'static', 24, false);
        newArrows.animation.addByPrefix('left', 'leftPress', 24, false);
        newArrows.animation.addByPrefix('right', 'rightPress', 24, false);
        newArrows.antialiasing = true;
        newArrows.screenCenter(XY);
        newArrows.animation.play('idle');
        add(newArrows);

        // The currently selected character's name top right
        selectedCharName = new FlxText(FlxG.width * 0.7, 0, 0, "", 32);
        selectedCharName.setFormat(fontFolder + 'vcr.ttf', 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        selectedCharName.alpha = 1;
        add(selectedCharName);

        var somethin:FlxText = new FlxText(12, FlxG.height - 24, 0, "If you dont see the character, or if the position, size, or animation of the character looks weird, it will not be present when your actually playing the game.", 12);
		somethin.scrollFactor.set();
		somethin.setFormat("VCR OSD Mono", 13, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(somethin);

        changeSelection();
        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
        super.create();
    }

    override function update(elapsed:Float)
    {
        // Code for adding arrow offset when an animation is being played
        // Ended up just being test code
        /*
        if (newArrows.animation.curAnim.name != 'idle')
        {
            switch (newArrows.animation.curAnim.name)
            {
                case 'left':
                    newArrows.offset.set(25, 5);
                case 'right':
                    newArrows.offset.set(-5, 5);
            }
        }
        else
        {
            newArrows.offset.set(-3, -45);
        }
        */

        backdrops.x +=90* elapsed;
		backdrops.y +=90* elapsed;

        selectedCharName.text = unlockedCharactersNames[curSelected].toUpperCase();
        selectedCharName.x = FlxG.width - (selectedCharName.width + 10);
        if (selectedCharName.text == '')
        {
            trace('');
            selectedCharName.text = '';
        }

        // Must be changed depending on how an engine uses its own controls
        var leftPress = controls.UI_LEFT_P; // Psych
        // var leftPress = controls.LEFT_P; // Kade
        var rightPress = controls.UI_RIGHT_P; // Psych
        // var rightPress = controls.RIGHT_P; // Kade
        var accepted = controls.ACCEPT; // Should be Universal
        var goBack = controls.BACK; // Should be Universal

        // Testing only DO NOT USE
        var unlockTest = FlxG.keys.justPressed.U;
        
        if (!alreadySelected)
        {
            if (leftPress)
            {
                newArrows.offset.set(33, 3);
                newArrows.animation.play('left', true);
                FlxG.sound.play(Paths.sound('scrollMenu'), 0.5);
                changeSelection(-1);
            }
            if (rightPress)
            {
                newArrows.offset.set(0, 4);
                newArrows.animation.play('right', true);
                FlxG.sound.play(Paths.sound('scrollMenu'), 0.5);
                changeSelection(1);
            }
            if (accepted)
            {
                alreadySelected = true;
                var daSelected:String = unlockedCharacters[curSelected];
                if (unlockedCharacters[curSelected] != PlayState.SONG.player1)
                    PlayState.SONG.player1 = daSelected;

                FlxFlicker.flicker(imageArray[curSelected], 0);

                // This is to make the audio stop when leaving to PlayState
                FlxG.sound.music.volume = 0;
                FlxG.sound.play(Paths.sound('confirmMenu'));

                // This is used in Psych for playing music by pressing space, but the line below stops it once the PlayState is entered
				FreeplayState.destroyFreeplayVocals();

                new FlxTimer().start(0.75, function(tmr:FlxTimer)
                {
                    persistentUpdate = false;
			        if(colorTween != null) {
				    colorTween.cancel();
			        }
                    // LoadingState.loadAndSwitchState(new PlayState()); // Usual way
                    FlxG.switchState(new PlayState()); // Gonna try this for Psych
                });
            }
            if (goBack)
            {
                persistentUpdate = false;
			    if(colorTween != null) {
				colorTween.cancel();
			    }
                // LoadingState.loadAndSwitchState(new FreeplayState());
                FlxG.sound.playMusic(Paths.music('freakyMenu'));
                FlxG.switchState(new FreeplayState());
            }
            if (unlockTest)
                {
                    FlxG.save.data.daUnlockedChars[0] = !FlxG.save.data.daUnlockedChars[0];
                    if (FlxG.save.data.daUnlockedChars[0] == true)
                        trace("Unlocked Secret");
                    else
                        trace("Locked Secret");
                }
    
            for (i in 0...imageArray.length)
            {
                imageArray[i].dance();
            }

            // Code to replay arrow Idle anim when finished
            if (newArrows.animation.finished == true)
            {
                newArrows.offset.set(0, -45);
                newArrows.animation.play('idle');
            }

            super.update(elapsed);
        }
    }

    // Changes the currently selected character
    function changeSelection(changeAmount:Int = 0):Void
    {
        // This just ensures you don't go over the intended amount
        curSelected += changeAmount;
        if (curSelected < 0)
            curSelected = unlockedCharacters.length - 1;
        if (curSelected >= unlockedCharacters.length)
            curSelected = 0;
        
        for (i in 0...imageArray.length)
        {
            // Sets the unselected characters to a more transparent form
            imageArray[i].alpha = 0.6;

            // These adjustments for Pixel characters may break for different ones, but eh, I am just making it for bf-pixel anyway
            if (StringTools.endsWith(imageArray[i].curCharacter, '-pixel'))
            {
                imageArray[i].x = (FlxG.width / 2) + ((i - curSelected - 1) * 400) + 325;
                imageArray[i].y = (FlxG.height / 2) - 60;
            }
            else
            {
                imageArray[i].x = (FlxG.width / 2) + ((i - curSelected - 1) * 400) + 150;
                imageArray[i].y = (FlxG.height / 2) - (imageArray[i].height / 2);
            }
        }

        // Makes sure the character you ave selected is indeed visible
        imageArray[curSelected].alpha = 1;
        
        charCheck();
    }

    // Checks for what char is selected and creates an icon for it
    function charCheck()
    {
        remove(icon);

        var barBG:FlxSprite = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar', sharedFolder));
        barBG.screenCenter(X);
        barBG.scrollFactor.set();
        barBG.visible = false;
        add(barBG);

        var bar:FlxBar = new FlxBar(barBG.x + 4, barBG.y + 4, RIGHT_TO_LEFT, Std.int(barBG.width - 8), Std.int(barBG.height - 8), this, 'health', 0, 2);
        bar.scrollFactor.set();
        bar.createFilledBar(0xFFFF0000, 0xFF66FF33);
        bar.visible = false;
        add(bar);

        icon = new HealthIcon(unlockedCharacters[curSelected], true);

        // This code is for Psych but if necessary can be use on other engines too
        if (unlockedCharacters[curSelected] == 'bf-car' || unlockedCharacters[curSelected] == 'bf-christmas' || unlockedCharacters[curSelected] == 'bf-holding-gf')
            icon.changeIcon('bf');
        if (unlockedCharacters[curSelected] == 'pico-player')
            icon.changeIcon('pico');
        if (unlockedCharacters[curSelected] == 'tankman-player')
            icon.changeIcon('tankman');

        icon.screenCenter(X);
        icon.setGraphicSize(-4);
        icon.y = (bar.y - (icon.height / 2)) - 20;
        //add(icon);
    }
    
    function unlockedCharsCheck()
    {
        // Resets all values to ensure that nothing is broken
        resetCharacterSelectionVars();

        // Makes this universal value equal the save data
        ifCharsAreUnlocked = FlxG.save.data.daUnlockedChars;

        // If you have managed to unlock a character, set it as unlocked here
        for (i in 0...ifCharsAreUnlocked.length)
        {
            if (ifCharsAreUnlocked[i] == true)
            {
                unlockedCharacters.push(unlockableChars[i]);
                unlockedCharactersNames.push(unlockableCharsNames[i]);
            }
        }
    }

    function resetCharacterSelectionVars() 
    {
        // Just resets all things to defaults
        ifCharsAreUnlocked = [false];

        // Ensures the characters are reset and that the first one is the default character
        unlockedCharacters = selectableCharacters;
        unlockedCharacters[0] = PlayState.SONG.player1; 
        unlockedCharacters[1] = PlayState.SONG.player2; 

        // Grabs default character names
        unlockedCharactersNames = selectableCharactersNames;

        // Grabs default backgrounds
    }
}