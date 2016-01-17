package khajak.particles;
import kha.Image;
import kha.math.Vector2;
import kha.math.Vector3;

class Emitter {

	private var active: Bool;
	
	private var position: Vector3;
	private var direction: Vector3;
	private var spreadAngle: Float;
	private var affectedByGravity: Bool;
	
	private var timeToLive: Vector2;
	private var speed: Vector2;
	private var size: Vector2;
	private var texture: Image;
	
	private var rate: Float;
	private var maxCount: Int;
	private var sinceLastEmission: Float;
	private var remainingTime: Float;
	
	// Using double buffering to make deletion efficient
	private var currentBufferId: Int;
	private var particleBuffers: Array<Array<Particle>>;
	private var particleCounts: Array<Int>;
	public var particles(get, null): Array<Particle>;
	function get_particles() {
		return particleBuffers[currentBufferId];
	}
	public var particleCount(get, null): Int;
	function get_particleCount() {
		return particleCounts[currentBufferId];
	}
	
	public function new(position: Vector3, direction: Vector3, spreadAngle: Float, affectedByGravity: Bool, timeToLive: Vector2, speed: Vector2, size: Vector2, texture: Image, rate: Float, maxCount: Int) {
		this.position = position;
		this.direction = direction;
		direction.normalize();
		this.spreadAngle = spreadAngle;
		this.affectedByGravity = affectedByGravity;
		this.timeToLive = timeToLive;
		this.speed = speed;
		this.size = size;
		this.texture = texture;
		this.rate = rate;
		this.maxCount = maxCount;
		
		particleBuffers = [ new Array<Particle>(), new Array<Particle>() ];
		particleBuffers[0][maxCount - 1] = null;
		particleBuffers[1][maxCount - 1] = null;
		particleCounts = [ 0, 0 ];
	}
	
	public function start(time: Float) {
		active = true;
		remainingTime = time;
		sinceLastEmission = rate;
	}
	
	public function stop() {
		active = false;
	}
	
	public function update(deltaTime: Float) {
		remainingTime -= deltaTime;
		sinceLastEmission += deltaTime;
		
		particleCounts[1 - currentBufferId] = 0;
		var currentParticle: Particle;
		for (i in 0...particleCounts[currentBufferId]) {
			currentParticle = particleBuffers[currentBufferId][i];
			if (currentParticle.update(deltaTime)) {
				particleBuffers[1 - currentBufferId][particleCounts[1 - currentBufferId]] = currentParticle;
				particleCounts[1 - currentBufferId]++;
			}
			else {
				// Remove reference for garbage collection
				particleBuffers[currentBufferId][i] = null;
				trace("Particle destroyed");
			}
		}
		currentBufferId = 1 - currentBufferId;
		
		if (remainingTime > 0 && particleCounts[currentBufferId] < maxCount) {
			while (sinceLastEmission >= rate) {
				sinceLastEmission -= rate;
				emitParticle();
			}
		}
	}
	
	private function emitParticle() {
		var speed = getRandomValueInRange(this.speed);
		var timeToLive = getRandomValueInRange(this.timeToLive);
		var size = getRandomValueInRange(this.size);
		
		var movement = direction.mult(speed);
		// TODO: spreadAngle
		
		particleBuffers[currentBufferId][particleCounts[currentBufferId]] = new Particle(position, movement, affectedByGravity, timeToLive, size, texture);
		particleCounts[currentBufferId] ++;
		
		trace("Particle created");
	}
	
	private function getRandomValueInRange(range: Vector2): Float {
		return range.x + Math.random() * (range.y - range.x);
	}
}