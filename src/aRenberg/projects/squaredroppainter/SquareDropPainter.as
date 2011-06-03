package aRenberg.projects.squaredroppainter
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	
	import aRenberg.bmd.BMDProject;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getTimer;
	
	public class SquareDropPainter extends BMDProject
	{
		
		/*public static const INTENSE:Number = 4800;
		public static const HIGH:Number = 6000;
		public static const MEDIUM:Number = 9000;
		public static const LOW:Number = 12000;*/
		public static const INTENSE:Number = 900;
		public static const HIGH:Number = 600;
		public static const MEDIUM:Number = 300;
		public static const LOW:Number = 150;
		
		public function SquareDropPainter(stage:Stage, source:BitmapData, intensity:Number)
		{
			stage.addChild(this);
			
			this.maxShapeRadius = Math.sqrt((source.width * source.height) / intensity);
			
			this.initWorld(source.width, source.height);
			
			this.startRecord(source.width * source.height * relativeFillArea);
			this.snapshotShapes();
			
			super(source);
			//this.redraw();
		}
		
		
		private const RATIO:Number = 30; 
		
		//private var ticker:Sprite;

		private var world:b2World;
		private var worldWidth:Number;
		private var worldHeight:Number;
		
		public var circleContainer:Sprite;
		
		public var debugSprite:Sprite;
		public var debugText:TextField;
		
		// ----------------------------------------------------------------------
		// 	Adjust these flags to see differences in performance etc
		// ----------------------------------------------------------------------
		
		private const debugDraw:Boolean 	 = false;
		private const circleIsBullet:Boolean = true;
		private const logMementos:Boolean	 = true;
		private const multiFrameLoading:Boolean = !debugDraw;
		private const useContinuousPhysics:Boolean = false; //Did I spell that wrong? It just looks wrong...
		
		private const completePercentage:Number = 1.05;
		
		private const squareAmount:Number = 1.0;
		private const sideBorderHeight:Number = 1.0;
		private const relativeFillArea:Number = 1.0;
		private const framesBetweenBallRelease:int = frameRate / 8; //Ball released every half second
		private var maxShapeRadius:Number = 20;
				
		// ----------------------------------------------------------------------
		
		private function initWorld(width:Number, height:Number):void
		{
			world = new b2World(new b2Vec2(0, 9.8), true);
			
			worldWidth = width;
			worldHeight = height;
			
			circleContainer = new Sprite();
			this.addChild(circleContainer);
			
			var scale:Number = ((stage.stageHeight/stage.stageWidth) > (height/width)) ? (stage.stageWidth/width) : (stage.stageHeight/height);
			circleContainer.scaleX = scale;
			circleContainer.scaleY = scale;
			circleContainer.x = stage.stageWidth / 2 - (width * scale) / 2;
			circleContainer.y = stage.stageHeight / 2 - (height * scale) / 2;
			
			world.SetContinuousPhysics(useContinuousPhysics);
			
			makeBounds(world, width, height, 40);
			
			
			//Cannot add the Sprite to BitmapData, so instead the outside code
			//needs to add it to their containers
			debugSprite = new Sprite();
			this.addChild(debugSprite);

			if (debugDraw)
				{ setupDebugDraw(world, debugSprite); }
			else
				{ setupDebugText(debugSprite); }	
		}
		
		private function setupDebugText(targetSprite:Sprite):void
		{
			debugText = new TextField();
			debugText.textColor = 0xFFFFFF;
			debugText.autoSize = flash.text.TextFieldAutoSize.LEFT;
						
			targetSprite.addChild(debugText);
		}
		
		
		private function makeBounds(world:b2World, width:int, height:int, thickness:Number):void
		{
			var sideBoundsShape:b2PolygonShape = new b2PolygonShape();
			sideBoundsShape.SetAsBox(thickness/2/RATIO, sideBorderHeight*height/2/RATIO);
			
			var sideFix:b2FixtureDef = new b2FixtureDef();
			sideFix.shape = sideBoundsShape;
			sideFix.density = 1;
			sideFix.friction = 1;
			
			
			//LEFT
			var leftBoundsDef:b2BodyDef = new b2BodyDef();
			leftBoundsDef.position.Set(0/RATIO, height/2/RATIO);
			var leftBounds:b2Body = world.CreateBody(leftBoundsDef);
			leftBounds.CreateFixture(sideFix);
			
			//RIGHT
			var rightBoundsDef:b2BodyDef = new b2BodyDef();
			rightBoundsDef.position.Set(width/RATIO, height/2/RATIO);
			var rightBounds:b2Body = world.CreateBody(rightBoundsDef);
			rightBounds.CreateFixture(sideFix);
			
			
			//BOTTOM
			var bottomBoundsShape:b2PolygonShape = new b2PolygonShape();
			bottomBoundsShape.SetAsBox(width/RATIO, thickness/2/RATIO);
			
			var bottomFixture:b2FixtureDef = new b2FixtureDef();
			bottomFixture.shape = bottomBoundsShape;
			
			//Not sure what to set these at, so I used pure guesswork
			bottomFixture.density = 1;
			bottomFixture.friction = 1;
			
			var bottomBoundsDef:b2BodyDef = new b2BodyDef();
			bottomBoundsDef.position.Set(width/2/RATIO, height/RATIO);
			var bottomBounds:b2Body = world.CreateBody(bottomBoundsDef);
			bottomBounds.CreateFixture(bottomFixture);
			
			
		}
		
		
		private function setupDebugDraw(world:b2World, targetSprite:Sprite):Sprite
		{
			var debugDraw:b2DebugDraw = new b2DebugDraw();
			debugDraw.SetSprite(targetSprite);
			debugDraw.SetDrawScale(RATIO);
			debugDraw.SetLineThickness(1.0);
			debugDraw.SetAlpha(1);
			debugDraw.SetFillAlpha(0.4);
			debugDraw.SetFlags(b2DebugDraw.e_shapeBit);
			
			world.SetDebugDraw(debugDraw);
			return targetSprite;
		}
		
		
		private var numShapes:int = 0;
		private var b2bodies:Array = [];
		private var shapeRadiuses:Array = [];
		private var shapeTypes:Array = [];
		//private const MAX_RADIUS:Number = maxShapeRadius;
				
		private function makeCircle(x:Number, radius:Number):Number
		{
			var circleShape:b2CircleShape = new b2CircleShape(radius / RATIO);
			this.createBody(circleShape, x, -(40 + radius));
			
			shapeTypes.push(ShapeShape.CIRCLE);
			shapeRadiuses.push(radius);
			return Math.PI * radius * radius;
		}
		
		private function makeSquare(x:Number, radius:Number):Number
		{
			var squareShape:b2PolygonShape = new b2PolygonShape();
			squareShape.SetAsBox(radius/RATIO, radius/RATIO);
			this.createBody(squareShape, x, -(40 + radius));
			
			shapeTypes.push(ShapeShape.SQUARE);
			shapeRadiuses.push(radius);
			return radius * radius * 4;
		}
			
		private function createBody(shape:b2Shape, x:Number, y:Number):void
		{
			var shapeFix:b2FixtureDef = new b2FixtureDef();
			shapeFix.shape = shape;
			
			//Not sure what to set these at, so I used pure guesswork
			shapeFix.density = 1;
			shapeFix.friction = 0.7;
			shapeFix.restitution = 0.4;
			
			
			var sBodyDef:b2BodyDef = new b2BodyDef();
			sBodyDef.type = b2Body.b2_dynamicBody;
			sBodyDef.bullet = circleIsBullet;
			sBodyDef.position.Set(x / RATIO, y / RATIO);
			
			var cBody:b2Body = world.CreateBody(sBodyDef);
			cBody.CreateFixture(shapeFix);
			
			b2bodies.push(cBody);
			numShapes++;
		}
		
		
		
		private const frameRate:Number = 30;
		private const physicsStep:Number = 1 / frameRate;
		private const maxTotalStepTime:Number = 1000 / frameRate;
		private const framesBetweenRelease:Number = framesBetweenBallRelease;
		
		
		private var frames:Array;
		private var totalFrames:int = 0;
		private var currentFrame:int = 0;
		
		
		private var maxArea:Number = 0;
		private var currentArea:Number = 0;
		private var nextShape:int = 0;
		
		
		private var recording:Boolean = false;
		private function startRecord(maxArea:Number):void
		{
			frames = [];
			
			//The first frame should be completely emtpy
			frames[0] = [];
			
			this.maxArea = maxArea;
			
			this.recording = true;
		}
		
		
		protected override function onEnterFrame():void
		{
			if (this.recording)
			{
				this.recordOnFrameEased();
			}
			else if (this.playing)
			{
				this.playFrame();
			}
			else 
			{
				//Do nothing.
			}
		}
		
		
		
		private var done:Boolean = false;
		private var goalMet:Boolean = false;
		
		//private const startSlowdownOffset:int = frameRate * 5;
		
		private const slowdownMult:Number = 0.95;
		private var currentSpeed:Number = 1;
		private var currentRecordedFrameN:Number = 0;
		
		private function recordOnFrameEased():void
		{
			var stopTime:int = getTimer() + maxTotalStepTime;
			
			//while (getTimer() < stopTime)
			do
			{
				var start:int = getTimer();
				totalFrames++;
				
				
				if (goalMet)
				{
					//Nearing the end, start slowing down
					currentSpeed *= slowdownMult;
					
					if (currentSpeed < 0.05)
						{ done = true; }
				}
				
				currentRecordedFrameN += currentSpeed;
				const MAX_RADIUS:Number = this.maxShapeRadius;
	
				//Check if any new circles need to be released			
				if (nextShape <= int(currentRecordedFrameN))
				{
					if (this.getRandom() > squareAmount)
					{
						currentArea += this.makeCircle(worldWidth * this.getRandom(), this.getRandomBetween(MAX_RADIUS / 2, MAX_RADIUS));
					}
					else
					{
						currentArea += this.makeSquare(worldWidth * this.getRandom(), this.getRandomBetween(MAX_RADIUS / 2, MAX_RADIUS));
					}
					
						
					nextShape += framesBetweenRelease;
					
					if (currentArea > maxArea)
						{ goalMet = true; } //Though still finish all remaining frames
				}
				
				//trace("Before world step", "FRAME", totalFrames);
				//world.ClearForces(); //People keep using this function, but is it really needed in my case??
				world.Step(physicsStep * currentSpeed, 2, 2);
				//trace("After world step");
				
				if (logMementos)
				{
					var currentFrameArray:Array = [];
					for (var i:int = 0; i < numShapes; i++)
					{
						currentFrameArray.push(new ShapeMemento(b2bodies[i], RATIO));
					}
					frames[totalFrames] = currentFrameArray;
				}
			} while ((multiFrameLoading) && (getTimer() < stopTime));
						
			if (debugDraw) 
				{ world.DrawDebugData(); }
			else
				{ debugText.text = "LOADING FRAME " + totalFrames + "\t\t" + String(int(100/completePercentage * currentArea / maxArea) + "%\t\t" + (getTimer() - start) + "ms calculation time"); }
			
			if (done)
			{
				this.stopRecord();
			}
		}

		
		private function stopRecord():void	
		{
			this.recording = false;
			
			if (logMementos)
				{ this.snapshotShapes(); }
			
			if (!debugDraw)
			{
				if (logMementos) 
					{ debugText.text = "DONE. Click to play the animation."; }
				else
					{ debugText.text = "DONE WITH SIMULATION"; }
			}
			
			this.dispatchEvent(new Event(READY));
		}
		public static const READY:String = "ready";
		
		public function get percentRecorded():Number
		{
			return (currentArea > maxArea) ? 1 : (currentArea / maxArea);
		}
		
		
		// -------------------- SNAPSHOT ------------------------------
		
		//public var tempSprite:Sprite = new Sprite();
		
		private var shapeShapes:Array = [];
		private function snapshotShapes():void
		{
			var src:BitmapData = this.source; //Cache for quick access?
			for (var i:int = 0; i < numShapes; i++)
			{
				//Refers to the "flash.display.Shape", not the "b2Shape"
				var shapeShape:ShapeShape = ShapeShape.fromType(src, shapeRadiuses[i], shapeTypes[i], frames[totalFrames][i], frames[0][i]);
				shapeShapes.push(shapeShape);
				
				circleContainer.addChild(shapeShape);
			}
		}
		
		
		// -------------------- SNAPSHOT ------------------------------
		
		private var playing:Boolean = false;
		public function replayFrames():void
		{
			if (this.recording)
			{
				trace("Cancelling recording");
				this.stopRecord();
			}
			if (this.playing)
			{
				//Reset to frame 0 before playing again
				this.donePlaying();
			}
			
			if (logMementos)
			{
				if (!debugDraw) { debugText.text = ""; }
				currentFrame = 0;
				
				this.playing = true;
			}
			else
			{
				trace("Nothing to replay");
			}
		}
		
		private function playFrame():void
		{
			//Play at normal speed
			currentFrame++;
			
			
			if (currentFrame > totalFrames)
			{
				this.donePlaying();
			}
			else
			{
				//trace("playingFrame", currentFrame);
				var currentFrameData:Array = frames[currentFrame];
				for (var i:int = 0; i < numShapes; i++)
				{
					shapeShapes[i].setFromMemento(currentFrameData[i]);
				}
			}
		}
		
		private function donePlaying():void
		{
			this.playing = false;
			this.dispatchEvent(new Event(FINISHED));
			//trace("ENJOY!");
		}
		public static const FINISHED:String = "finished";
		
		public function cancel():void
		{
			this.playing = false;
			this.recording = false;
			trace("Cancelled all actions");
		}
		
		
		//var tr:String;
		/*
		public override function redraw():void
		{
			//world.ClearForces();
			//var t:int = getTimer();
			world.DrawDebugData();
			//tr += "DRAW " + String(getTimer() - t) + "\t";
			
			//this.copyPixels(clear, new Rectangle(clear.width, clear.height), new Point());
			//this.applyFilter(this, new Rectangle(this.width, this.height), new Point(), new BlurFilter(3,3,3));
			
			this.fillRect(this.rect, 0x000000);
			//t = getTimer();
			this.draw(debugSprite, debugSprite.transform.matrix);
			//tr += "RENDER " + String(getTimer() - t) + "\t";
			
			//trace(tr);
		}*/
	}
}