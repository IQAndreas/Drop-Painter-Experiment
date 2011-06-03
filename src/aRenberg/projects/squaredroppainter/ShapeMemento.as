package aRenberg.projects.squaredroppainter
{
	import Box2D.Dynamics.b2Body;

	public final class ShapeMemento
	{
		private static const RTD:Number = 180 / Math.PI;
		public function ShapeMemento(body:b2Body, ratio:Number)
		{
			this.posX = body.GetPosition().x * ratio;
			this.posY = body.GetPosition().y * ratio;
			this.rotation = body.GetAngle() * RTD;
		}
		
		public var posX:Number;
		public var posY:Number;
		public var rotation:Number;
	}
}