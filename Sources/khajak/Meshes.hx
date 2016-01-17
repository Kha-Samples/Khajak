package khajak;

class Meshes {
	
	static var billboard: Mesh;
	public static var Billboard(get, null): Mesh;
	static function get_Billboard() {
		if (billboard == null) {
			var data = [
				-0.5, -0.5, 0.0,
				0.0, 0.0,
				0.5, -0.5, 0.0,
				1.0, 0.0,
				-0.5, 0.5, 0.0,
				0.0, 1.0,
				0.5, 0.5, 0.0,
				1.0, 1.0,
				0.0, 0.0, 1.0
			];
			
			var indices = [
				1, 3, 2,
				0, 1, 2
			];
			
			billboard = new Mesh(data, indices, VertexStructures.Billboards);
		}
		
		return billboard;
	}
}