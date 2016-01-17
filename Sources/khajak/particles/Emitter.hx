package khajak.particles;
import kha.Image;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.Vector2;
import khajak.Mesh;

class Emitter {

	private var active: Bool;
	
	private var position: FastVector3;
	private var direction: FastVector3;
	private var spreadAngle: Float;
	private var affectedByGravity: Bool;
	
	private var timeToLive: Vector2;
	private var speed: Vector2;
	private var size: Array<FastVector2>;
	private var texture: Image;
	private var mesh: Mesh;
	
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
	
	public function new(position: FastVector3, direction: FastVector3, spreadAngle: Float, affectedByGravity: Bool, timeToLive: Vector2, speed: Vector2, sizeMin: FastVector2, sizeMax: FastVector2, texture: Image, rate: Float, maxCount: Int, mesh: Mesh) {
		this.position = position;
		this.direction = direction;
		direction.normalize();
		this.spreadAngle = spreadAngle;
		this.affectedByGravity = affectedByGravity;
		this.timeToLive = timeToLive;
		this.speed = speed;
		this.size = [ sizeMin, sizeMax ];
		this.texture = texture;
		this.mesh = mesh;
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
		var size = getRandomVectorValueInRange(this.size);
		
		var movement = direction.mult(speed);
		// TODO: spreadAngle
		
		particleBuffers[currentBufferId][particleCounts[currentBufferId]] = new Particle(position, movement, affectedByGravity, timeToLive, size, texture, mesh);
		particleCounts[currentBufferId] ++;
	}
	
	private function getRandomValueInRange(range: Vector2): Float {
		return range.x + Math.random() * (range.y - range.x);
	}
	
	private function getRandomVectorValueInRange(range: Array<FastVector2>): FastVector2 {
		return new FastVector2(range[0].x + Math.random() * (range[1].x - range[0].x), range[0].y + Math.random() * (range[1].y - range[0].y));
	}
}