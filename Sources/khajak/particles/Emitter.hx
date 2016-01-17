package khajak.particles;
import kha.Image;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.Random;
import kha.math.Vector2;
import kha.math.Vector3;
import kha.Scheduler;
import khajak.Mesh;

class Emitter {

	private var active: Bool;
	
	private var position: FastVector3;
	private var radius: Float;
	private var rotate: Bool;
	private var direction: FastVector3;
	private var spreadAngle: Float;
	private var affectedByGravity: Bool;
	
	private var timeToLive: Vector2;
	private var speedStart: Vector2;
	private var speedEnd: Vector2;
	private var size: Array<FastVector2>;
	private var texture: Image;
	
	private var rateMin: Float;
	private var rateMax: Float;
	private var rateNext: Float;
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
	
	static var random: Random;
	
	public function new(position: FastVector3, radius: Float, rotate: Bool, direction: FastVector3, spreadAngle: Float, affectedByGravity: Bool, timeToLive: Vector2, speedStart: Vector2, speedEnd: Vector2, sizeMin: FastVector2, sizeMax: FastVector2, texture: Image, rateMin: Float, rateMax: Float, maxCount: Int) {
		if (random == null) random = new Random(Std.int(Scheduler.realTime() * 1000000));
		
		this.position = position;
		this.radius = radius;
		this.rotate = rotate;
		this.direction = direction;
		direction.normalize();
		this.spreadAngle = spreadAngle;
		this.affectedByGravity = affectedByGravity;
		this.timeToLive = timeToLive;
		this.speedStart = speedStart;
		this.speedEnd = speedEnd;
		this.size = [ sizeMin, sizeMax ];
		this.texture = texture;
		this.rateMin = rateMin;
		this.rateMax = rateMax;
		rateNext = getRandomValue(rateMin, rateMax);
		this.maxCount = maxCount;
		
		particleBuffers = [ new Array<Particle>(), new Array<Particle>() ];
		particleBuffers[0][maxCount - 1] = null;
		particleBuffers[1][maxCount - 1] = null;
		particleCounts = [ 0, 0 ];
	}
	
	public function start(time: Float) {
		active = true;
		remainingTime = time;
		sinceLastEmission = rateNext;
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
			while (sinceLastEmission >= rateNext) {
				sinceLastEmission -= rateNext;
				rateNext = getRandomValue(rateMin, rateMax);
				emitParticle();
			}
		}
	}
	
	private function emitParticle() {
		var nextSpeedStart = getRandomValueInRange(speedStart);
		var nextSpeedEnd = getRandomValueInRange(speedEnd);
		var timeToLive = getRandomValueInRange(this.timeToLive);
		var size = getRandomVectorValueInRange(this.size);
		
		var orthoVector = direction.cross(new FastVector3(0, 0, 1));
		orthoVector.normalize();
		var nextPosition = position.add(orthoVector.mult(getRandomValue(0, radius)));
		
		var nextAngle = getRandomValue(-spreadAngle, spreadAngle);
		var nextDirection = direction.add(orthoVector.mult(Math.tan(nextAngle)));
		nextDirection.normalize();
		
		particleBuffers[currentBufferId][particleCounts[currentBufferId]] = new Particle(nextPosition, (rotate ? getRandomValue(0, 2 * Math.PI) : 0), nextDirection, nextSpeedStart, nextSpeedEnd, affectedByGravity, timeToLive, size, texture);
		particleCounts[currentBufferId] ++;
	}
	
	private function rotateAroundAxis(vector: Vector3, normalizedAxis: Vector3, angle: Float) : Vector3 {
		// Direction has to be normalized!
		return vector.mult(Math.cos(angle)).add((normalizedAxis.cross(vector)).mult(Math.sin(angle))).add(normalizedAxis.mult(normalizedAxis.dot(vector)).mult(1 - Math.cos(angle)));
	}
	
	private inline function getRandomValue(min: Float, max: Float): Float {
		return min + random.GetFloat() * (max - min);
	}
	
	private inline function getRandomValueInRange(range: Vector2): Float {
		return getRandomValue(range.x, range.y);
	}
	
	private inline function getRandomVectorValueInRange(range: Array<FastVector2>): FastVector2 {
		return new FastVector2(range[0].x + random.GetFloat() * (range[1].x - range[0].x), range[0].y + random.GetFloat() * (range[1].y - range[0].y));
	}
}