package khajak;
import kha.Color;
import kha.math.FastVector3;

class Light {
	public var color: Color;
	public var power: Float;
	public var position: FastVector3;
	
	public function new(color: Color, power: Float, position: FastVector3) {
		this.color = color;
		this.power = power;
		this.position = position;
	}
}