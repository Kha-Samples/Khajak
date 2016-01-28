package khajak.particles;
import kha.Color;
import kha.Image;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.Random;
import kha.math.Vector2;
import kha.math.Vector3;
import kha.Scheduler;

class Emitter {

	private var active: Bool;
	
	private var position: FastVector3;
	private var radiusMin: Float;
	private var radiusMax: Float;
	private var direction: FastVector3;
	private var spreadAngle: Float;
	private var gravity: Float;
	private var timeToLiveMin: Float;
	private var timeToLiveMax: Float;
	private var sizeMin: FastVector2;
	private var sizeMax: FastVector2;
	
	private var rotationStartMin: Float;
	private var rotationStartMax: Float;
	private var rotationEndMin: Float;
	private var rotationEndMax: Float;
	private var speedStartMin: Float;
	private var speedStartMax: Float;
	private var speedEndMin: Float;
	private var speedEndMax: Float;
	private var colorStartMin: Color;
	private var colorStartMax: Color;
	private var colorEndMin: Color;
	private var colorEndMax: Color;
	
	private var rateMin: Float;
	private var rateMax: Float;
	private var rateNext: Float;
	private var maxCount: Int;
	private var texture: Image;
	
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
	
	public function new(position: FastVector3, radiusMin: Float, radiusMax: Float, direction: FastVector3, spreadAngle: Float, gravity: Float, timeToLiveMin: Float, timeToLiveMax: Float, sizeMin: FastVector2, sizeMax: FastVector2, rotationStartMin: Float, rotationStartMax: Float, rotationEndMin: Float, rotationEndMax: Float, speedStartMin: Float, speedStartMax: Float, speedEndMin: Float, speedEndMax: Float, colorStartMin: Color, colorStartMax: Color, colorEndMin: Color, colorEndMax: Color, rateMin: Float, rateMax: Float, maxCount: Int, texture: Image) {
		if (random == null) random = new Random(Std.int(Scheduler.realTime() * 1000000));
		
		this.position = position;
		this.radiusMin = radiusMin;
		this.radiusMax = radiusMax;
		this.direction = direction;
		direction.normalize();
		this.spreadAngle = spreadAngle;
		this.gravity = gravity;
		this.timeToLiveMin = timeToLiveMin;
		this.timeToLiveMax = timeToLiveMax;
		this.sizeMin = sizeMin;
		this.sizeMax = sizeMax;
		
		this.rotationStartMin = rotationStartMin;
		this.rotationStartMax = rotationStartMax;
		this.rotationEndMin = rotationEndMin;
		this.rotationEndMax = rotationEndMax;
		this.speedStartMin = speedStartMin;
		this.speedStartMax = speedStartMax;
		this.speedEndMin = speedEndMin;
		this.speedEndMax = speedEndMax;
		this.colorStartMin = colorStartMin;
		this.colorStartMax = colorStartMax;
		this.colorEndMin = colorEndMin;
		this.colorEndMax = colorEndMax;
		
		this.rateMin = rateMin;
		this.rateMax = rateMax;
		rateNext = getRandomValue(rateMin, rateMax);
		this.maxCount = maxCount;
		this.texture = texture;
		
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
	
	public function burst() {
		while (particleCounts[currentBufferId] < maxCount) {
			emitParticle();
		}
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
		var orthoVector = direction.cross(new FastVector3(0, 0, 1));
		orthoVector = rotateAroundAxis(orthoVector, direction, getRandomValue(0, 2 * Math.PI));
		orthoVector.normalize();
		var nextPosition = position.add(orthoVector.mult(getRandomValue(radiusMin, radiusMax)));
		
		var nextAngle = getRandomValue(-spreadAngle, spreadAngle);
		var nextDirection = direction.add(orthoVector.mult(Math.tan(nextAngle)));
		nextDirection = rotateAroundAxis(nextDirection, direction, getRandomValue(0, 2 * Math.PI));
		nextDirection.normalize();
		
		var nextTimeToLive = getRandomValue(timeToLiveMin, timeToLiveMax);
		var nextSize = getRandomVectorValue(sizeMin, sizeMax);
		var nextRotationStart = getRandomValue(rotationStartMin, rotationStartMax);
		var nextRotationEnd = getRandomValue(rotationEndMin, rotationEndMax);
		var nextSpeedStart = getRandomValue(speedStartMin, speedStartMax);
		var nextSpeedEnd = getRandomValue(speedEndMin, speedEndMax);
		var nextColorStart = getRandomColorValue(colorStartMin, colorStartMax);
		var nextColorEnd = getRandomColorValue(colorEndMin, colorEndMax);
		
		particleBuffers[currentBufferId][particleCounts[currentBufferId]] = new Particle(nextPosition, nextDirection, gravity, nextTimeToLive, nextSize, nextRotationStart, nextRotationEnd, nextSpeedStart, nextSpeedEnd, nextColorStart, nextColorEnd, texture);
		particleCounts[currentBufferId] ++;
	}
	
	private function rotateAroundAxis(vector: FastVector3, normalizedAxis: FastVector3, angle: Float) : FastVector3 {
		// Direction has to be normalized!
		return vector.mult(Math.cos(angle)).add((normalizedAxis.cross(vector)).mult(Math.sin(angle))).add(normalizedAxis.mult(normalizedAxis.dot(vector)).mult(1 - Math.cos(angle)));
	}
	
	private inline function getRandomValue(min: Float, max: Float): Float {
		return min + random.GetFloat() * (max - min);
	}
	
	private inline function getRandomValueInRange(range: Vector2): Float {
		return getRandomValue(range.x, range.y);
	}
	
	private inline function getRandomVectorValue(min: FastVector2, max: FastVector2): FastVector2 {
		return new FastVector2(min.x + random.GetFloat() * (max.x - min.x), min.y + random.GetFloat() * (max.y - min.y));
	}
	
	private inline function getRandomColorValue(min: Color, max: Color): Color {
		return Color.fromFloats(getRandomValue(min.R, max.R), getRandomValue(min.G, max.G), getRandomValue(min.B, max.B));
	}
}