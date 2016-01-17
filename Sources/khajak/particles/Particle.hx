package khajak.particles;
import kha.Image;
import kha.math.Vector3;

class Particle {

	private var position: Vector3;
	private var movement: Vector3;
	private var gravity: Vector3;
	private var affectedByGravity: Bool;
	
	private var timeToLive: Float;
	private var size: Float;
	private var texture: Image;
	
	public function new(position: Vector3, movement: Vector3, affectedByGravity: Bool, timeToLive: Float, size: Float, texture: Image) {
		this.position = position;
		this.movement = movement;
		this.gravity = new Vector3(0, 0, 0);
		this.affectedByGravity = affectedByGravity;
		this.timeToLive = timeToLive;
		this.size = size;
		this.texture = texture;
	}
	
	public function update(deltaTime: Float): Bool {
		timeToLive -= deltaTime;
		
		if (affectedByGravity) {
			gravity.add(new Vector3(0, -0.5 * 9.81 * deltaTime, 0));
		}
		position = position.add(movement.add(gravity).mult(deltaTime));
		
		return timeToLive >= 0;
	}
}