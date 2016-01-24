package khajak;

import haxebullet.Bullet;

class Physics {
	public static var world: BtDiscreteDynamicsWorld;
	
	public static function init(): Void {
		var broadphase = new BtDbvtBroadphase();
		var collisionConfiguration = new BtDefaultCollisionConfiguration();
        var dispatcher = new BtCollisionDispatcher(collisionConfiguration);
		//BtGImpactCollisionAlgorith.registerAlgorithm(dispatcher);
		var solver = new BtSequentialImpulseConstraintSolver();
		world = new BtDiscreteDynamicsWorld(dispatcher, broadphase, solver, collisionConfiguration);
		world.setGravity(BtVector3.create(0, -10, 0));
	}
	
	public static function update(delta: Float): Void {
		world.value.stepSimulation(delta);
	}
}
