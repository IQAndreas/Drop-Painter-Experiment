package
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	
	public class ImageChooser extends Sprite
	{
		public static const IMAGE_CHOSEN:String = "image_chosen";
		
		[Embed (source="./assets/mona-lisa-painting.jpg")]
		private const ML_BMP:Class;
		
		[Embed (source="./assets/dr-gachet.jpg")]
		private const DRG_BMP:Class;
		
		public function ImageChooser(stage:Stage, graphicsOptions:Array)
		{
			super();
			
			stage.addChild(this);
			
			clabel = new Label(this, 0, 0, "Quality");
			clabel.textField.textColor = 0xFFFFFF;
			combo = new ComboBox(this, 0, clabel.height + 5, "", graphicsOptions);
			combo.numVisibleItems = 4;
			combo.selectedIndex = 2;
			
			browseImg = new PushButton(this, 0, combo.y + combo.height + 15, "Browse for image", browse);
			mlImg = new PushButton(this, 0, browseImg.y + browseImg.height + 5, "Mona Lisa", useML);
			drgImg = new PushButton(this, 0, mlImg.y + mlImg.height + 5, "Dr Gachet", useDRG);
			
			this.x = stage.stageWidth / 2 - this.width / 2;
			this.y = stage.stageHeight / 2 - this.height / 2;
		}
		
		private const FILE_TYPES:Array = [new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg; *.jpeg; *.gif; *.png")];
		private var fr:FileReference;
		private function browse(e:Event):void
		{
			fr = new FileReference();
			
			//listen for when they select a file
			fr.addEventListener(Event.SELECT, onFileSelect);
			
			//listen for when then cancel out of the browse dialog
			//fr.addEventListener(Event.CANCEL,onCancel);
			
			//open a native browse dialog that filters for text files
			fr.browse(FILE_TYPES);
		}
		
		private var loader:Loader;
		private function onFileSelect(e:Event):void
		{
			fr.addEventListener(Event.COMPLETE, onFileLoaded);
			fr.load();
		}
		
		private function onFileLoaded(e:Event):void
		{
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onFileComplete);
			loader.loadBytes(fr.data);
			//addChild(loader);
		}
		
		private function onFileComplete(e:Event):void
		{
			var bmp:Bitmap = loader.content as Bitmap;
			this.chosenImage(bmp);
		}
		
		
		private function useML(e:Event):void
		{
			this.chosenImage(new ML_BMP());
		}
		
		private function useDRG(e:Event):void
		{
			this.chosenImage(new DRG_BMP());
		}
		
		
		private var clabel:Label;
		private var combo:ComboBox;
		
		private var browseImg:PushButton;
		private var mlImg:PushButton;
		private var drgImg:PushButton;
		
		
		
		private function chosenImage(bmp:Bitmap):void
		{
			_bitmapData = bmp.bitmapData;
			//_bitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x00000000);
			//_bitmapData.draw(c);
			
			_graphicsMode = combo.selectedItem.data;
			this.dispatchEvent(new Event(ImageChooser.IMAGE_CHOSEN));
		}
		
		
		
		private var _bitmapData:BitmapData;
		public function get bitmapData():BitmapData
		{ return _bitmapData; }
		
		private var _graphicsMode:Number;
		public function get graphicsMode():Number
		{ return _graphicsMode; }
	}
}