package khajak.particles;
import kha.Color;
import kha.Image;
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.Random;

class Particle {

	public var position: FastVector3;
	public var model: FastMatrix4;
	private var direction: FastVector3;
	private var gravity: Float;
	private var gravityForce: FastVector3;
	
	private var timeToLive: Float;
	private var timeToLiveOverall: Float;
	
	public var size: FastVector2;
	private var rotationStart: Float;
	private var rotationEnd: Float;
	public var rotData: FastVector2;
	private var speedStart: Float;
	private var speedEnd: Float;
	private var colorStart: Color;
	private var colorEnd: Color;
	public var color: Color;
	
	public var texture: Image;
	public var mesh: Mesh;
	
	public function new(position: FastVector3, direction: FastVector3, gravity: Float, timeToLive: Float, size: FastVector2, rotationStart: Float, rotationEnd: Float, speedStart: Float, speedEnd: Float, colorStart: Color, colorEnd: Color, texture: Image) {
		this.position = position;
		model = FastMatrix4.translation(position.x, position.y, position.z);
		this.direction = direction;
		this.gravity = gravity;
		gravityForce = new FastVector3(0, 0, 0);
		
		this.timeToLive = timeToLive;
		timeToLiveOverall = timeToLive;
		
		this.size = size;
		this.rotationStart = rotationStart;
		this.rotationEnd = rotationEnd;
		updateRotData();
		this.speedStart = speedStart;
		this.speedEnd = speedEnd;
		this.colorStart = colorStart;
		this.colorEnd = colorEnd;
		updateColor();
		
		this.texture = texture;
		this.mesh = Meshes.Billboard;
	}
	
	public function update(deltaTime: Float): Bool {
		timeToLive -= deltaTime;
		
		var speed = interpolate(speedStart, speedEnd);
		var movement = direction.mult(speed);
		gravityForce = gravityForce.add(new FastVector3(0, -gravity * deltaTime, 0));
		position = position.add(movement.add(gravityForce).mult(deltaTime));
		
		model = FastMatrix4.translation(position.x, position.y, position.z);
		updateRotData();
		updateColor();
		
		return timeToLive >= 0;
	}
	
	private function updateRotData() {
		var rotation = interpolate(rotationStart, rotationEnd);
		rotData = new FastVector2(Math.sin(rotation), Math.cos(rotation));
	}
	
	private function updateColor() {
		color = Color.fromFloats(interpolate(colorStart.R, colorEnd.R), interpolate(colorStart.G, colorEnd.G), interpolate(colorStart.B, colorEnd.B), interpolate(colorStart.A, colorEnd.A));
	}
	
	private function interpolate(start: Float, end: Float): Float {
		return end + (start - end) * (timeToLive / timeToLiveOverall);
	}
}