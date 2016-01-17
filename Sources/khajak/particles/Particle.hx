package khajak.particles;
import kha.Image;
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.FastVector3;

class Particle {

	public var position: FastVector3;
	private var movement: FastVector3;
	private var gravity: FastVector3;
	private var affectedByGravity: Bool;
	
	private var timeToLive: Float;
	public var size: FastVector2;
	public var rotData: FastVector2;
	public var texture: Image;
	public var mesh: Mesh;
	
	public var model: FastMatrix4;
	
	public function new(position: FastVector3, angle: Float, movement: FastVector3, affectedByGravity: Bool, timeToLive: Float, size: FastVector2, texture: Image) {
		this.position = position;
		this.movement = movement;
		this.gravity = new FastVector3(0, 0, 0);
		this.affectedByGravity = affectedByGravity;
		this.timeToLive = timeToLive;
		this.size = size;
		this.rotData = new FastVector2(Math.sin(angle), Math.cos(angle));
		this.texture = texture;
		this.mesh = Meshes.Billboard;
		
		model = FastMatrix4.translation(position.x, position.y, position.z);
	}
	
	public function update(deltaTime: Float): Bool {
		timeToLive -= deltaTime;
		
		if (affectedByGravity) {
			gravity.add(new FastVector3(0, -0.5 * 9.81 * deltaTime, 0));
		}
		position = position.add(movement.add(gravity).mult(deltaTime));
		model = FastMatrix4.translation(position.x, position.y, position.z);
		
		return timeToLive >= 0;
	}
}