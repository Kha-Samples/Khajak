package khajak;

import kha.arrays.Float32Array;
import kha.Color;
import kha.Framebuffer;
import kha.graphics4.Graphics;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.Shaders;
import kha.System;
import khajak.particles.Emitter;
import khajak.particles.Particle;

using kha.Float32ArrayExtensions;

class Renderer {
	
	public static var PARTICLE_BATCH_SIZE : Int = 256;
	
	var basicPipeline: BasicPipeline;
	var basicStencilPipeline: BasicPipeline;
	var billboardPipeline: BillboardPipeline;
	var billboardPipelineInstanced: BillboardPipeline;
	var vertexBuffersBillboardInstanced : Array<VertexBuffer> = new Array();
	
	public var view: FastMatrix4;
	public var projection: FastMatrix4;
	var splitscreenCount: Int;
	
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
		basicStencilPipeline = new BasicPipeline(Shaders.basic_frag, Shaders.basic_vert, [ VertexStructures.Basic ], true);
		billboardPipeline = new BillboardPipeline(Shaders.billboard_frag, Shaders.billboard_uniform_vert, [ VertexStructures.Billboards ]);
		billboardPipelineInstanced = new BillboardPipeline(Shaders.billboard_frag, Shaders.billboard_attribute_vert, [ VertexStructures.Billboards, VertexStructures.BillboardsInstanced ]);
		
		vertexBuffersBillboardInstanced[1] = new VertexBuffer(
			PARTICLE_BATCH_SIZE,
			VertexStructures.BillboardsInstanced,
			Usage.DynamicUsage,
			1 // changed after every instance, use i higher number for repetitions
		);
		
		setSplitscreenMode(1);
		updateCamera(new FastVector3(0, 0, -10), new FastVector3(0, 0, 0));
		
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
	
	public function setSplitscreenMode(count: Int) {
		splitscreenCount = count;
		projection = FastMatrix4.perspectiveProjection(45.0, (System.pixelWidth / splitscreenCount) / System.pixelHeight, 0.1, 100.0);
	}
	
	public function updateCamera(cameraPos: FastVector3, cameraLook: FastVector3) {
		view = FastMatrix4.lookAt(cameraPos, cameraLook, new FastVector3(0, 1, 0));
	}
	
	public function beginRender(frame: Framebuffer, splitscreenID: Int = 0) {
		var g4 = frame.g4;
		
		g4.begin();
		
		var splitscreenWidth = Std.int(System.pixelWidth / splitscreenCount);
		g4.viewport(splitscreenID * splitscreenWidth, 0, splitscreenWidth, System.pixelHeight);
		g4.scissor(splitscreenID * splitscreenWidth, 0, splitscreenWidth, System.pixelHeight);
		
		basicPipeline.set(g4, view, light1, light2, light3, light4, light5, light6, light7, light8); // Depth clear only works when depth test is enabled!
		g4.clear(clearColor, 10000, 0);
	}
	
	public function endRender(frame: Framebuffer, splitscreenID: Int = 0) {
		var g4 = frame.g4;
		g4.disableScissor();
        g4.end();
	}
	
	public function render(frame: Framebuffer, splitscreenID: Int = 0) {
		// Render 3d scene
		var g4 = frame.g4;
		
		for (object in objects) {
			renderObject(g4, object.writestencil ? basicStencilPipeline : basicPipeline, object);
		}
		
		billboardPipeline.set(g4, view);
		
		// Render particles
		if (g4.instancedRenderingAvailable()) {
			billboardPipelineInstanced.set(g4, view);
			
			vertexBuffersBillboardInstanced[0] = Meshes.Billboard.vertexBuffer;
			
			var bufferData = vertexBuffersBillboardInstanced[1].lock();
			var i = 0;
			var particleTexture: kha.Image = null;
			for (emitter in particleEmitters) {				
				for (pi in 0...emitter.particleCount) {
					if (i == PARTICLE_BATCH_SIZE || (emitter.particles[pi].texture != particleTexture && particleTexture != null)) {
						// Render current batch
						actuallyRenderParticlesInstanced(g4, i, particleTexture);
						
						// Prepare for next batch
						bufferData = vertexBuffersBillboardInstanced[1].lock();
						i = 0;
					}
					
					particleTexture = emitter.particles[pi].texture;
					addParticleToInstanceBuffers(emitter.particles[pi], bufferData, i);
					i++;
				}
			}
			
			// Render rest
			if (i > 0) {
				actuallyRenderParticlesInstanced(g4, i, particleTexture);
			}
		}
		else {
			billboardPipeline.set(g4, view);
			for (emitter in particleEmitters) {
				for (i in 0...emitter.particleCount) {
					renderParticle(g4, billboardPipeline, emitter.particles[i]);
				}
			}
		}
		
		// Render 2d gui
		/*var g2 = frame.g2;
		
		g2.begin(false);
		
		// TODO: renderGUI
		
		g2.end();*/
    }
	
	function actuallyRenderParticlesInstanced(g: Graphics, i: Int, texture: kha.Image) {
		vertexBuffersBillboardInstanced[1].unlock();
		
		g.setVertexBuffers(vertexBuffersBillboardInstanced);
		g.setIndexBuffer(Meshes.Billboard.indexBuffer);
		
		g.setTexture(billboardPipelineInstanced.textureUnit, texture);
		
		g.drawIndexedVerticesInstanced(i);
	}
	
	function renderObject(g4: Graphics, pipeline: BasicPipeline, object: RenderObject) {
		pipeline.set(g4, view, light1, light2, light3, light4, light5, light6, light7, light8);
		
		g4.setFloat3(pipeline.colorID, object.color.R, object.color.G, object.color.B);
		g4.setMatrix(pipeline.modelMatrixID, object.model);
		g4.setMatrix(pipeline.mvpMatrixID, calculateMVP(object.model));
		
		g4.setTexture(pipeline.textureUnit, object.texture);
		
		g4.setVertexBuffer(object.mesh.vertexBuffer);
		g4.setIndexBuffer(object.mesh.indexBuffer);
		
		g4.drawIndexedVertices();
	}
	
	function renderParticle(g4: Graphics, pipeline: BillboardPipeline, particle: Particle) {
		g4.setFloat4(pipeline.baseColorID, particle.color.R, particle.color.G, particle.color.B, particle.color.A);
		g4.setVector2(pipeline.sizeID, particle.size);
		g4.setVector3(pipeline.centerID, particle.position);
		g4.setVector2(pipeline.rotDataID, particle.rotData);
		g4.setMatrix(pipeline.mvpMatrixID, calculateMVP(particle.model));
		
		g4.setTexture(pipeline.textureUnit, particle.texture);
		
		g4.setVertexBuffer(particle.mesh.vertexBuffer);
		g4.setIndexBuffer(particle.mesh.indexBuffer);
		
		g4.drawIndexedVertices();
	}
	
	private function addParticleToInstanceBuffers(particle : Particle, bufferData : Float32Array, position : Int) {
		var actualPosition = position * VertexStructures.BillboardsInstanced.byteSize();
		
		bufferData.setVector2(actualPosition, particle.size);
		bufferData.setVector3(actualPosition + 2, particle.position);
		bufferData.setVector2(actualPosition + 5, particle.rotData);
		bufferData.setColor(actualPosition + 7, particle.color);
		bufferData.setMatrix4(actualPosition + 11, calculateMVP(particle.model));
	}
	
	function calculateMVP(model: FastMatrix4) : FastMatrix4 {
		var mvp : FastMatrix4 = FastMatrix4.identity();
		mvp = mvp.multmat(projection);
		mvp = mvp.multmat(view);
		mvp = mvp.multmat(model);
		return mvp;
	}
	
	public function calculateMV(): FastMatrix4 {
		var mvp : FastMatrix4 = FastMatrix4.identity();
		mvp = mvp.multmat(projection);
		mvp = mvp.multmat(view);
		return mvp;
	}
}