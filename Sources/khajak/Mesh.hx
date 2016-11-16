package khajak;

import kha.graphics4.IndexBuffer;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;

class Mesh {
	public var vertexBuffer: VertexBuffer;
	public var indexBuffer: IndexBuffer;

	public function new(data: Array<Float>, indices: Array<Int>, vertexStructure: VertexStructure) {
		vertexBuffer = new VertexBuffer(
		  Std.int(data.length / (vertexStructure.byteSize() / 4)),
		  vertexStructure,
		  Usage.StaticUsage
		);
		
		var vbData = vertexBuffer.lock();
		for (i in 0...vbData.length) {
		  vbData.set(i, data[i]);
		}
		vertexBuffer.unlock();
		
		indexBuffer = new IndexBuffer(
		  indices.length,
		  Usage.StaticUsage
		);
		
		var iData = indexBuffer.lock();
		for (i in 0...iData.length) {
		  iData[i] = indices[i];
		}
		indexBuffer.unlock();
	}
	
	public static function FromModel(objData: String): Mesh {
		var obj = new ObjLoader(objData);
		return new Mesh(obj.data, obj.indices, VertexStructures.Basic);
	}
}