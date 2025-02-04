package ;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import openfl.display.Bitmap;
import openfl.events.KeyboardEvent;
import openfl.geom.Point;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import flixel.tweens.motion.Motion;
import flixel.FlxG;
import flixel.FlxCamera;
import motion.Actuate;
import away3d.utils.Cast;
import away3d.textures.BitmapTexture;
import away3d.containers.View3D;
// import away3d.primitives.CubeGeometry;


@:bitmap("star.png") 
class MyBitmapData extends BitmapData { }

enum Paddle {
	paddle1;
	paddle2;
}

enum GameState {
	Paused;
	Playing;
}

enum Player {
	Human;
	AI;
}

class Main extends Sprite 
{
	static inline private var paddle_pos = 200;
	static inline private var wdt:Int = 500;
	static inline private var cor:Int = 5;
	static inline private var pwidth:Int = 15;
	static inline private var centerX:Int = 225;
	static inline private var centerY:Int = 250;
	static inline private var mid:Int = 250;
	static inline private var pdl:Int = 100;
	static inline private var diameter:Int = 10;
	static inline private var bkl:Int = 50;
	static inline private var bkh:Int = 20;
	static inline private var strwd:Int = 50;
	static inline private var strht:Int = 37;
		
	var inited:Bool;
	
	private var starList = new Array<Bitmap>();
	private var i:Float;
	private var platform1:Platform;
	private var platform2:Platform;
	private var block1:Block;
	private var obs1:Obstacle;
	private var obs2:Obstacle;
	private var ball:Ball;
	private var MyStar:Bitmap;
	
	private var scorePlayer:Int;
	private var scoreAI:Int;
	private var scoreField:TextField;
	private var messageField:TextField;
	private var currentGameState:GameState;
	private var pd:Paddle;
	private var MySprite:Sprite;
	private var arrowKeyUp:Bool;
	private var arrowKeyDown:Bool;
	private var platformSpeed:Int;
	private var blockSpeed:Int;
	private var ballMovement:Point;
	private var ballSpeed:Int;
	private var blockMovement:Point;
	private var direction:Int = 1;
	/* ENTRY POINT */
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init() 
	{
		if (inited) return;
		inited = true;
		
		platform1 = new Platform();
		platform1.y = cor;
		platform1.x = paddle_pos;
		this.addChild(platform1);
		
		platform2 = new Platform();
		platform2.x = paddle_pos;
		platform2.y = wdt-pwidth-cor;
		this.addChild(platform2);
		
		block1 = new Block();
		block1.x = centerX;
		block1.y = centerY;
		this.addChild(block1);
		
		obs1 = new Obstacle();
		obs1.x = 100;
		obs1.y = 400;
		this.addChild(obs1);
		
		obs2 = new Obstacle();
		obs2.x = 400;
		obs2.y = 100;
		this.addChild(obs2);
		
		ball = new Ball();
		ball.x = mid;
		ball.y = mid;
		this.addChild(ball);
		var i = 0;
		for (i in 0...5) {
			//a.push(i);
			starList.insert(i, new Bitmap(new MyBitmapData(0, 0)));
			//a[i] = new Bitmap(new MyBitmapData(0, 0));
			starList[i].x = Math.random() *300;
			starList[i].y = Math.random()*300;
			this.addChild(starList[i]);
		}
			
		var scoreFormat:TextFormat = new TextFormat("Verdana", 24, 0xbbbbbb, true);
		scoreFormat.align = TextFormatAlign.CENTER;
		
		scoreField = new TextField();
		addChild(scoreField);
		scoreField.width = wdt;
		scoreField.y = 30;
		scoreField.defaultTextFormat = scoreFormat;
		scoreField.selectable = false;
		
		var messageFormat:TextFormat = new TextFormat("Verdana", 18, 0xbbbbbb, true);
		messageFormat.align = TextFormatAlign.CENTER;
		
		messageField = new TextField();
		addChild(messageField);
		messageField.width = wdt;
		messageField.y = 400;
		messageField.defaultTextFormat = messageFormat;
		messageField.selectable = false;
		messageField.text = "Press SPACE to start\nUse ARROW KEYS to move your platform";
		
		scorePlayer = 0;
		scoreAI = 0;
		arrowKeyUp = false;
		arrowKeyDown = false;
		platformSpeed = 7;
		ballSpeed = 7;
		blockSpeed = 7;
		blockMovement = new Point(centerX,centerY);
		ballMovement = new Point(0, 0);
		setGameState(Paused);
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		this.addEventListener(Event.ENTER_FRAME, everyFrame);
	}
	
	private function setGameState(state:GameState):Void {
		currentGameState = state;
		updateScore();
		if (state == Paused) {
			messageField.alpha = 1;
		}else {
			messageField.alpha = 0;
			platform1.x = paddle_pos;
			platform2.x = paddle_pos;
			block1.x = centerX;
			block1.y = centerY;
			ball.y = mid;
			ball.x = mid;
			var direction:Int = (Math.random() > .5)?(1):( -1);
			var randomAngle:Float = (Math.random() * Math.PI / 2) - 45;
			ballMovement.y = direction * Math.cos(randomAngle) * ballSpeed;
			ballMovement.x = Math.sin(randomAngle) * ballSpeed;
			/* blockMovement.x = direction * blockSpeed; */
		}
	}
	
	private function keyDown(event:KeyboardEvent):Void {
		if (currentGameState == Paused && event.keyCode == 32) { // Space
			setGameState(Playing);
		}else if (event.keyCode == 37) { // Left
			arrowKeyUp = true;
		}else if (event.keyCode == 39) { // Right
			arrowKeyDown = true;
		}
	}
	
	private function keyUp(event:KeyboardEvent):Void {
		if (event.keyCode == 37) { // Left
			arrowKeyUp = false;
		}else if (event.keyCode == 39) { // Right
			arrowKeyDown = false;
		}
	}
	
	private function starAppear(MyStar:Bitmap):Void {
		MyStar.x = Math.random() * 500;
		MyStar.y = Math.random() * 500;
	}
	
	
	private function reAppearStar(star:Bitmap):Void
	{
		star.x = Math.random() * 300;
		star.y = Math.random() * 400;
		Actuate.tween (star, 1, { alpha: 1 } ); // fade out
	}
	
	private function everyFrame(event:Event):Void {
		if (currentGameState == Playing) {
			
			// player platform movement
			if (arrowKeyUp) {
				platform1.x -= platformSpeed;
			}
			if (arrowKeyDown) {
				platform1.x += platformSpeed;
			}
			// AI platform movement
			if (ball.y > 300 && ball.x > platform2.x + 70) {
				platform2.x += platformSpeed;
			}
			if (ball.y > 300 && ball.x < platform2.x + 30) {
				platform2.x -= platformSpeed;
			}
			// player platform limits
			if (platform1.x < cor) platform1.x = cor;
			if (platform1.x > wdt-pdl-cor) platform1.x = wdt-pdl-cor;
			// AI platform limits
			if (platform2.x < cor) platform2.x = cor;
			if (platform2.x > wdt-pdl-cor) platform2.x = wdt-pdl-cor;
			// ball movement
			ball.y += ballMovement.y;
			ball.x += ballMovement.x;
			
			// obs1 bounce
				if (ball.x >= obs1.x && ball.x <= obs1.x +30 && ball.y >= obs1.y && ball.y <= obs1.y +30) 
				{
					bounceBall();
					
				}
			// obs2 bounce	
				if (ball.x >= obs2.x && ball.x <= obs2.x +30 && ball.y >= obs2.y && ball.y <= obs2.y +30) 
				{
					bounceBall();
					
				}
				
			// Block bounce
				if (ball.x >= block1.x && ball.x <= block1.x + 50 && ball.y >= block1.y && ball.y <= block1.y +20) {
					bounceBall();
				}
				
			// star overlap
			//for (i in 0...5) {
				//if(starList[i] == block1.x || starList[i] == block1.
			//}
			
			//haxe.Log.trace("Direction:: " + direction + "  X Postion:: " + block1.x);
				
				if (direction == 1 && block1.x <= 455)
				{
					//move to right
					block1.x += blockSpeed * direction;
				}
				if (block1.x >= 448 || block1.x >= 455)
				{
					//Log.trace("Changing direction to -1");
					direction = -1;
				}
				
				if (direction == -1 && block1.x >= 5)
				{
					// Log.trace("Moving backwards....." + block1.x);
					//move to left
					block1.x += blockSpeed * direction;
					//Log.trace("Moved too... " + block1.x);
				}
				
				if (direction == -1 && block1.x <= 5)
				{
					//Log.trace("Changing direction to ONE");
					direction = 1;
				}
			 
			// ball platform bounce
			if (ballMovement.y < 0 && ball.y < (diameter+pwidth+cor) && ball.x >= platform1.x && ball.x <= platform1.x + pdl) {
				bounceBall();
				ball.y = diameter + pwidth + cor;
				pd = paddle1;
				
			}
			if (ballMovement.y > 0 && ball.y > (wdt-(diameter+pwidth+cor)) && ball.x >= platform2.x && ball.x <= platform2.x + pdl) {
				bounceBall();
				ball.y = (wdt - (diameter + pwidth + cor));
				pd = paddle2;
			}
			
			// star1
			var paramArray = new Array();
			
			
			i = 0;
			
			for (i in 0...5)
			{
				if (ball.x >= starList[i].x && ball.x <= starList[i].x + strwd && ball.y >= starList[i].y && ball.y <= starList[i].y + strht) {	
					var starTween = Actuate.tween (starList[i], 1, { alpha: 0 } ); // fade out
					paramArray[i] = starTween;
					starTween.onComplete(function() { reAppearStar(starList[i]); } );
					if (pd == paddle1) {
						scorePlayer++;
						updateScore();
					} else {
						scoreAI++;
						updateScore();
					}
					
				}
			}			
			
			// ball edge bounce
			if (ball.x < cor || ball.x > (wdt-cor)) ballMovement.x *= -1;
			// ball goal
			if (ball.y < cor) winGame(AI);
			if (ball.y > wdt-cor) winGame(Human);
		}
	}
	
	private function construct ():Void {
 
		var creationDelay:Float;
 
		for (i in 0...60) {
 
			creationDelay = Math.random () * 10;
			Actuate.timer (creationDelay).onComplete (MyStar);
 
		}
 
	}
 
	private function bounceBall():Void {
		var direction:Int = (ballMovement.y > 0)?( -1):(1);
		var randomAngle:Float = (Math.random() * Math.PI / 2) - 45;
		ballMovement.y = direction * Math.cos(randomAngle) * ballSpeed;
		ballMovement.x = Math.sin(randomAngle) * ballSpeed;
	}
	
	private function winGame(player:Player):Void {
		if (player == Human) {
			scorePlayer++;
		} else {
			scoreAI++;
		}
		setGameState(Paused);
	}
	
	private function updateScore():Void {
		scoreField.text = scorePlayer + ":" + scoreAI;
	}

	/* SETUP */

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		/*var img = new Bitmap( new MyBitmapData(0, 0) );
		Lib.current.addChild(img);*/
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
		//
	}
}

