package khajak;

import kha.Color;
import kha.FastFloat;
import kha.Image;
import kha.math.FastMatrix4;

class RenderObject {
	public var mesh: Mesh;
	public var color: Color;
	public var texture: Image;
	
	public var model: FastMatrix4;
	
	public function new(mesh: Mesh, color: Color, texture: Image) {
		this.mesh = mesh;
		this.color = color;
		this.texture = texture;
		
		this.model = FastMatrix4.identity();
	}
	
	public function reset() {
		model = FastMatrix4.identity();
	}
	
	public function translate(x: FastFloat, y: FastFloat, z: FastFloat) {
		model = FastMatrix4.translation(x, y, z).multmat(model);
	}
}