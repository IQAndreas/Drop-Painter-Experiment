package
{
	import aRenberg.bmd.BMDProject;
	import aRenberg.projects.squaredroppainter.*;
	
	import com.bit101.components.PushButton;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	[SWF ( width = '800', height = '600', backgroundColor = '#333333', frameRate = '30' ) ] 
	//[SWF ( width = '386', height = '600', backgroundColor = '#333333', frameRate = '30' ) ] 
	//[SWF ( width = '685', height = '843', backgroundColor = '#333333', frameRate = '30' ) ] 
	
	public class MonaLisaPainter extends Sprite
	{
		
		//[Embed (source="./assets/mona-lisa-painting.jpg")]
		//[Embed (source="./assets/dr-gachet.jpg")]
		
		//private const PaintingBMP:Class;
		//private var paintingBMD:BitmapData; // = Bitmap(new PaintingBMP()).bitmapData;
		
		private const CurrentFilter:Class = SquareDropPainter;
		
		//private var bmp:Bitmap;
		//private var currentFilter:BMDFilter;
		private var chooser:ImageChooser;
		//private var currentProject:BMDProject;
		
		private var currentProject:SquareDropPainter;
		
		public function MonaLisaPainter()
		{
			this.reset();
		}
		
		private function reset(e:Event = null):void
		{
			if (currentProject)
			{
				stage.removeChild(currentProject);
				
				stage.removeChild(mainBtn);
				stage.removeChild(secondBtn);
			}
			
			
			var options:Array = [ 
				{label:"Low", data:SquareDropPainter.LOW},
				{label:"Medium", data:SquareDropPainter.MEDIUM},
				{label:"High", data:SquareDropPainter.HIGH},
				{label:"Intense", data:SquareDropPainter.INTENSE}
				];
			
			chooser = new ImageChooser(stage, options);
			chooser.addEventListener(ImageChooser.IMAGE_CHOSEN, chosen);
		}
		
		private function chosen(e:Event):void
		{
			stage.removeChild(chooser);
			this.initDrawing(chooser.bitmapData, chooser.graphicsMode);
		}
		
		private function initDrawing(bmd:BitmapData, intensity:Number):void
		{
			currentProject = new CurrentFilter(stage, bmd, intensity );
			currentProject.addEventListener(SquareDropPainter.READY, onReady);
			currentProject.addEventListener(SquareDropPainter.FINISHED, onFinished);
			//stage.addChild(currentProject);
			
			this.initTF();
		}
		
		private var mainBtn:PushButton;
		private var secondBtn:PushButton;
		
		private function onReady(e:Event):void
		{
			mainBtn.label = "PLAY";
			mainBtn.enabled = true;
			mainBtn.visible = true;
		}
		
		private function onFinished(e:Event):void
		{
			mainBtn.label = "REPLAY";
			mainBtn.enabled = true;
			mainBtn.visible = true;
			
			secondBtn.visible = true;
		}
		
		private function initTF():void
		{
			
			mainBtn = new PushButton(stage, 0, 0, "Loading...", playFrames);
			mainBtn.enabled = false;
			mainBtn.x = stage.stageWidth / 2 - mainBtn.width / 2;
			mainBtn.y = stage.stageHeight / 2 - mainBtn.height / 2;
			
			secondBtn = new PushButton(stage, mainBtn.x, mainBtn.y + mainBtn.height + 20, "RESET", reset);
			secondBtn.visible = false;
			
			//Contact me text
			var tf:TextField = new TextField();
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.wordWrap = false;
			
			var format:TextFormat = new TextFormat();
			format.align = flash.text.TextFormatAlign.CENTER;
			format.color = 0xFFFFFF;
			tf.defaultTextFormat = format;
			//tf.textColor = 0xFFFFFF;
			
			tf.selectable = false;
			//tf.text = "Imagineered by Andreas Renberg using Box2D for Flash\n";
			//tf.appendText("Image Copyright ©1506 Leonardo da Vinci\n");
			//tf.appendText("http://iqandreas.blogspot.com/");
			
			const padding:Number = 4;
			var tfSprite:Sprite = new Sprite();
			var tfHitArea:Sprite = new Sprite();
			
			tfHitArea.graphics.beginFill(0);
			tfHitArea.graphics.drawRect(-padding, -padding, tf.width + (padding*2), tf.height + (padding*2));
			tfHitArea.graphics.endFill();
			
			tfSprite.addChild(tf);
			tfSprite.addChild(tfHitArea);
			tfSprite.hitArea = tfHitArea;
			tfHitArea.visible = false;
			
			//tfSprite.x = stage.stageWidth - (tfHitArea.width + padding);
			//tfSprite.y = stage.stageHeight - (tfHitArea.height + padding);
			tfSprite.x = stage.stageWidth/2 - (tfHitArea.width + padding)/2;
			tfSprite.y = stage.stageHeight - (tfHitArea.height + padding);
			this.addChild(tfSprite);
			
			//tfSprite.useHandCursor = true;
			//tfSprite.buttonMode = true;
			//tfSprite.mouseChildren = false;
			//tfSprite.addEventListener(MouseEvent.CLICK, gotoBlog);
		}
		
		private function gotoBlog(ev:MouseEvent):void
		{
			ev.stopPropagation();
			navigateToURL(new URLRequest("http://iqandreas.blogspot.com/"), "_blank");
		}
		
		private function playFrames(e:Event):void
		{
			mainBtn.visible = false;
			secondBtn.visible = false;
			
			var b2dc:SquareDropPainter = currentProject as SquareDropPainter;
			if (b2dc)
			{
				b2dc.replayFrames();
				return;
			}
		}
		
		/*
		private function redrawProject(e:Event = null):void
		{
			//currentFilter.redraw();
			
			var b2dc:SquareDropPainter = currentProject as SquareDropPainter;
			if (b2dc)
			{
				b2dc.replayFrames();
				return;
			}
			
			//else
			if (currentProject)
			{
				this.removeChild(currentProject);
			}
			else
			{
				//
			}
			
			//bmp.bitmapData = new CurrentFilter(paintingBMD);
			
			//if(this.contains(f.debugSprite))
			// 	{ this.removeChild(f.debugSprite); }
			
			//f.replayFrames();
		}*/
	}
}