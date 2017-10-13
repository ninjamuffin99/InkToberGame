package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.plugin.screengrab.FlxScreenGrab;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	
	private var _bg:FlxSprite;
	private var _bgClone:FlxSprite;
	private var _bgUndo:FlxSprite;
	private var _bgRedo:FlxSprite;
	
	private var _frame:FlxSprite;
	
	private var _player:FlxSprite;
	
	private var _NGRadio:FlxSound;
	private var _screenGrab:FlxButton;
	
	private var _title:FlxText;
	
	private var _timer:Float = 0.05;
	
	override public function create():Void
	{
		
		createRadio();
		
		_title = new FlxText(0, -135, 0, "Title Here\nControls:\nWASD = Move\nSpacebar= Draw", 25);
		_title.color = FlxColor.BLACK;
		add(_title);
		
		_bg = new FlxSprite(0, 0);
		_bg.makeGraphic(FlxG.width * 2, FlxG.height * 2);
		
		_frame = new FlxSprite(_bg.x - 10, _bg.y - 10);
		_frame.makeGraphic(Std.int(_bg.width + 20), Std.int(_bg.height + 20), FlxColor.BLACK);
		
		_bgClone = new FlxSprite(0, 0);
		_bgClone = _bg.clone();
		_bg.stamp(_bgClone, 0, 0);
		
		_bgUndo = new FlxSprite(0, 0);
		_bgUndo = _bg.clone();
		
		_bgRedo = new FlxSprite(0, 0);
		_bgRedo = _bg.clone();
		
		_player = new Player(100, 100);
		
		add(_frame);
		add(_bg);
		add(_player);
		
		FlxScreenGrab.defineCaptureRegion(0, 0, Std.int(_bg.width), Std.int(_bg.height));
		_screenGrab = new FlxButton(20, 20, "Screenshot", 
		function()
		{
			FlxScreenGrab.grab(null, true, true);
		});
		
		//add(_screenGrab);
		
		FlxG.camera.follow(_player);
		FlxG.camera.followLead.x = FlxG.camera.followLead.y = 20;
		FlxG.camera.bgColor = FlxColor.WHITE;
		
		super.create();
	}
	
	private function createRadio():Void
	{
		_NGRadio = new FlxSound();
		
		_NGRadio.play();
		
		_NGRadio.loadStream("http://radio-stream01.ungrounded.net/easylistening", false, false);
		
		_NGRadio.play();
	}

	override public function update(elapsed:Float):Void
	{
		_NGRadio.volume = FlxG.sound.volume;
		
		var velX:Float = _player.velocity.x;
		var velY:Float = _player.velocity.y;
		
		if (velX < 0)
		{
			velX * -1;
		}
		if (velY < 0)
		{
			velY * -1;
		}
		
		FlxG.watch.addQuick("VELY", velY);
		FlxG.watch.addQuick("VELX", velX);
		
		_player.scale.x = _player.scale.y = (FlxMath.remapToRange(velY, 0, 160, 0, 6) + FlxMath.remapToRange(velX, 0, 160, 0, 6));
		
		if (FlxG.keys.pressed.SPACE || FlxG.mouse.pressed)
		{
			if (_timer <= 0)
			{
				_bg.stamp(_player, Std.int(_player.x), Std.int(_player.y));
			}
			else
			{
				_timer -= FlxG.elapsed;
			}
			
		}
		else
		{
			_timer = 0.05;
		}
		
		if (FlxG.keys.anyJustPressed([DELETE, BACKSPACE]))
		{
			_bg.stamp(_bgClone, 0, 0);
		}
		
		if (FlxG.keys.anyPressed([UP, DOWN]))
		{
			var ZOOM_FACTOR:Int = 35;
			
			if (FlxG.keys.pressed.DOWN)
			{
				FlxG.camera.zoom += 1 / ZOOM_FACTOR;
			}
			if (FlxG.keys.pressed.UP)
			{
				FlxG.camera.zoom -= 1 / ZOOM_FACTOR;
			}
		}
		
		undo();
		
		super.update(elapsed);
	}
	
	private function undo():Void
	{
		if (FlxG.keys.pressed.Z)
		{
			_bg.stamp(_bgUndo);
		}
		
		if (FlxG.keys.pressed.X)
		{
			_bg.stamp(_bgRedo);
		}
		
		if (FlxG.keys.justPressed.SPACE)
		{
			_bgUndo.stamp(_bg);
		}
		
		if (FlxG.keys.justReleased.SPACE)
		{
			_bgRedo.stamp(_bg);
		}
		
	}
}