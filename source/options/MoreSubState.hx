package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class MoreSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Miscellaneous';
		rpcTitle = 'More Settings Menu'; //for Discord Rich Presence

		//I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Fullscreen', //Name
			'You should already know this.', //Description
			'fullScreen', //Save data variable name
			'bool', //Variable type
			false); //Default value
		option.onChange = onChangeFullScreen;
		addOption(option);

		var option:Option = new Option('Shaders', //Name
			'If unchecked, disables shaders.', //Description
			'shaders', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);
		
		var option:Option = new Option('Disable Character Select',
			"If checked, going into a song on freeplay won't show Character Select.",
			'noCharMenu',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Hide Checkers',
			'If checked, hides checkers.',
			'hideCheckers',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Hide Menu Icons',
			'If checked, hides the menu icons.',
			'hideMenuShowcase',
			'bool',
			false);
		addOption(option);
		
		var option:Option = new Option('Disable Character Select',
			"If checked, going into a song on freeplay won't show Character Select.",
			'noCharMenu',
			'bool',
			false);
	
		var option:Option = new Option('Hide Watermark',
			'If checked, hides the difficulty, song name, and watermark when your playing.',
			'hideWatermark',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Score Text:',
			"Where should the Score Text be?",
			'scoreTxtPos',
			'string',
			'Middle',
			['Middle', 'Left', 'Right', 'Disabled']);
		addOption(option);

		var option:Option = new Option('Icon Bop Style:',
			"How should the Icons bop?",
			'Iconbop',
			'string',
			'Original',
			['Original', 'Noob', 'Golden Apple', 'Vs Dave']);
		addOption(option);

		var option:Option = new Option('Watermark Layout:',
			"How should the difficulty, song name, and watermark be?",
			'watermarkLayout',
			'string',
			'All Together',
			['Side by Side', 'Stacked']);
		addOption(option);

		super();
	}

	function onChangeFullScreen()
	{
			FlxG.fullscreen = ClientPrefs.fullScreen;
	}
}