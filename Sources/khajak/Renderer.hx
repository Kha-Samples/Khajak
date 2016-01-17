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
import khajak.particles.Emitter;
import khajak.particles.Particle;

class Renderer {
	
	var basicPipeline: BasicPipeline;
	var billboardPipeline: BillboardPipeline;
	
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
	public var particleEmitters: Array<Emitter>;
	
	public var clearColor: Color;
	
	public static var the(default, null): Renderer;
	
	public function new(clearColor: Color) {
		this.clearColor = clearColor;
		
		basicPipeline = new BasicPipeline(Shaders.basic_frag, Shaders.basic_vert, [ VertexStructures.Basic ]);
		billboardPipeline = new BillboardPipeline(Shaders.billboard_frag, Shaders.billboard_vert, [ VertexStructures.Billboards ]);
		
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
		particleEmitters = new Array<Emitter>();
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
		
		billboardPipeline.set(g4, view);
		
		for (emitter in particleEmitters) {
			for (i in 0...emitter.particleCount) {
				renderParticle(g4, billboardPipeline, emitter.particles[i]);
			}
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
		g4.setMatrix(pipeline.mvpMatrixID, calculateMVP(object.model));
		
		g4.setTexture(pipeline.textureUnit, object.texture);
		
		g4.setVertexBuffer(object.mesh.vertexBuffer);
		g4.setIndexBuffer(object.mesh.indexBuffer);
		
		g4.drawIndexedVertices();
	}
	
	function renderParticle(g4: Graphics, pipeline: BillboardPipeline, particle: Particle) {
		g4.setVector2(pipeline.sizeID, particle.size);
		g4.setVector3(pipeline.centerID, particle.position);
		g4.setVector2(pipeline.rotDataID, particle.rotData);
		g4.setMatrix(pipeline.mvpMatrixID, calculateMVP(particle.model));
		
		g4.setTexture(pipeline.textureUnit, particle.texture);
		
		g4.setVertexBuffer(particle.mesh.vertexBuffer);
		g4.setIndexBuffer(particle.mesh.indexBuffer);
		
		g4.drawIndexedVertices();
	}
	
	function calculateMVP(model: FastMatrix4) : FastMatrix4 {
		var mvp : FastMatrix4 = FastMatrix4.identity();
		mvp = mvp.multmat(projection);
		mvp = mvp.multmat(view);
		mvp = mvp.multmat(model);
		return mvp;
	}
}