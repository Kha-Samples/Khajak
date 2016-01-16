package khajak;

import kha.graphics4.IndexBuffer;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;

class Mesh {
	public var vertexBuffer: VertexBuffer;
	public var indexBuffer: IndexBuffer;

	public function new(objData: String) {
		var obj = new ObjLoader(objData);
		var data = obj.data;
		var indices = obj.indices;
		
		vertexBuffer = new VertexBuffer(
		  Std.int(data.length / Renderer.the.basicVertexStructure.byteSize()),
		  Renderer.the.basicVertexStructure,
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
}