package aRenberg.projects.squaredroppainter
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class ShapeShape extends Shape
	{
		
		public static const CIRCLE:int = 1;
		public static const SQUARE:int = 2;
		
		private static const matrixRotationMult:Number = -Math.PI / 180;
		
		public static function fromType(bmd:BitmapData, radius:Number, type:int, finalMemento:ShapeMemento, startMemento:ShapeMemento = null):ShapeShape
		{
			if (type == CIRCLE)
				{ return ShapeShape.fromCircle(bmd, radius, finalMemento, startMemento); }
			else if (type == SQUARE)
				{ return ShapeShape.fromSquare(bmd, radius, finalMemento, startMemento); }
			else
				{ return null; }
		}
		
		
		public static function fromCircle(bmd:BitmapData, radius:Number, finalMemento:ShapeMemento, startMemento:ShapeMemento = null):ShapeShape
		{
			if (!finalMemento)
				{ return null; }
			//else
			
			var shapeShape:ShapeShape = new ShapeShape(finalMemento.rotation, startMemento);
			
			var matrix:Matrix = new Matrix(1, 0, 0, 1, -finalMemento.posX, -finalMemento.posY);
			matrix.rotate(finalMemento.rotation * matrixRotationMult);
			
			shapeShape.graphics.beginBitmapFill(bmd, matrix, false);
			shapeShape.graphics.drawCircle(0, 0, radius);
			shapeShape.graphics.endFill();
			
			return shapeShape;
		}
		
		public static function fromSquare(bmd:BitmapData, radius:Number, finalMemento:ShapeMemento, startMemento:ShapeMemento = null):ShapeShape
		{
			if (!finalMemento)
				{ return null; }
			//else
			
			var shapeShape:ShapeShape = new ShapeShape(finalMemento.rotation, startMemento);
			
			var matrix:Matrix = new Matrix(1, 0, 0, 1, -finalMemento.posX, -finalMemento.posY);
			matrix.rotate(finalMemento.rotation * matrixRotationMult);
			
			//import aRenberg.bmd.getAverageColor;
			//var color:uint = getAverageColor(bmd, new Rectangle(finalMemento.posX - radius, finalMemento.posY - radius, radius * 2, radius * 2));
			//shapeShape.graphics.beginFill(color);

			shapeShape.graphics.beginBitmapFill(bmd, matrix, false);
			shapeShape.graphics.drawRect(-radius, -radius, radius * 2, radius * 2);
			shapeShape.graphics.endFill();
			
			return shapeShape;
		}
		
		
		//public function CircleShape(bmd:BitmapData, radius:Number, finalX:Number, finalY:Number, finalRotation:Number)
		public function ShapeShape(baseRotation:Number, memento:ShapeMemento = null)
		{
			super();
			
			this.baseRotation = baseRotation;
			
			this.setFromMemento(memento);
		}
		
		
		private var baseRotation:Number;
		private var _visible:Boolean = true; //Faster than getter/setter?
		
		public function setFromMemento(memento:ShapeMemento):void
		{
			if (memento)
			{				
				this.x = memento.posX;
				this.y = memento.posY;
				this.rotation = memento.rotation //- baseRotation;
				
				if (!_visible)
				{
					_visible = true;
					this.visible = true;
				}
			}
			else
			{
				if (_visible)
				{
					_visible = false;
					this.visible = false;
				}
			}
		}
		
		/*
		public function resetPosition():void
		{
			//Make sure it begins off screen
			this.x = -300;
			this.y = -300;
		}*/
		
		
		
	}
}