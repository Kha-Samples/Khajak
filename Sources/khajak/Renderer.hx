package khajak;

import kha.Color;
import kha.Framebuffer;
import kha.graphics4.Graphics;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.math.FastMatrix4;
import kha.math.FastVector3;
import kha.Shaders;
import kha.System;

class Renderer {
	
	var basicPipeline: BasicPipeline;
	public var basicVertexStructure: VertexStructure;
	
	var view: FastMatrix4;
	var projection: FastMatrix4;
	
	public var light1: Light;
	public var light2: Light;
	public var light3: Light;
	public var light4: Light;
	public var light5: Light;
	public var light6: Light;
	public var light7: Light;
	public var light8: Light;
	public var objects: Array<RenderObject>;
	
	public var clearColor: Color;
	
	public static var the(default, null): Renderer;
	
	public function new(clearColor: Color) {
		this.clearColor = clearColor;
		
		basicVertexStructure = new VertexStructure();
        basicVertexStructure.add("pos", VertexData.Float3);
        basicVertexStructure.add("uv", VertexData.Float2);
        basicVertexStructure.add("nor", VertexData.Float3);
		
		basicPipeline = new BasicPipeline(Shaders.basic_frag, Shaders.basic_vert, [ basicVertexStructure ]);
		
		updateCamera(new FastVector3(0, 0, -10), new FastVector3(0, 0, 0));
		
		projection = FastMatrix4.perspectiveProjection(45.0, System.pixelWidth / System.pixelHeight, 0.1, 100.0);
		
		light1 = new Light(Color.White, 0, new FastVector3(0, 0, 0));
		light2 = new Light(Color.White, 0, new FastVector3(0, 0, 0));
		light3 = new Light(Color.White, 0, new FastVector3(0, 0, 0));
		light4 = new Light(Color.White, 0, new FastVector3(0, 0, 0));
		light5 = new Light(Color.White, 0, new FastVector3(0, 0, 0));
		light6 = new Light(Color.White, 0, new FastVector3(0, 0, 0));
		light7 = new Light(Color.White, 0, new FastVector3(0, 0, 0));
		light8 = new Light(Color.White, 0, new FastVector3(0, 0, 0));
		objects = new Array<RenderObject>();
	}
	
	public static function init(renderer: Renderer) {
		the = renderer;
	}
	
	public function updateCamera(cameraPos: FastVector3, cameraLook: FastVector3) {
		view = FastMatrix4.lookAt(cameraPos, cameraLook, new FastVector3(0, 1, 0));
	}
	
	public function render(frame: Framebuffer) {
		// Render 3d scene
		var g4 = frame.g4;
		
		g4.begin();
		
		basicPipeline.set(g4, view, light1, light2, light3, light4, light5, light6, light7, light8); // Depth clear only works when depth test is enabled!
		g4.clear(clearColor);
		
		for (object in objects) {
			renderObject(g4, basicPipeline, object);
		}
		
        g4.end();
		
		// Render 2d gui
		/*var g2 = frame.g2;
		
		g2.begin(false);
		
		// TODO: renderGUI
		
		g2.end();*/
    }
	
	function renderObject(g4: Graphics, pipeline: BasicPipeline, object: RenderObject) {
		g4.setFloat3(pipeline.colorID, object.color.R, object.color.G, object.color.B);
		g4.setMatrix(pipeline.modelMatrixID, object.model);
		g4.setMatrix(pipeline.mvpMatrixID, calculateMVP(object));
		
		g4.setTexture(pipeline.textureUnit, object.texture);
		
		g4.setVertexBuffer(object.mesh.vertexBuffer);
		g4.setIndexBuffer(object.mesh.indexBuffer);
		
		g4.drawIndexedVertices();
	}
	
	function calculateMVP(object: RenderObject) : FastMatrix4 {
		var mvp : FastMatrix4 = FastMatrix4.identity();
		mvp = mvp.multmat(projection);
		mvp = mvp.multmat(view);
		mvp = mvp.multmat(object.model);
		return mvp;
	}
}