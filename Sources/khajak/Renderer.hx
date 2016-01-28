package khajak;

import kha.arrays.Float32Array;
import kha.Assets;
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

class Renderer {
	
	public static var PARTICLE_BATCH_SIZE : Int = 512;
	
	var basicPipeline: BasicPipeline;
	var billboardPipeline: BillboardPipeline;
	var billboardPipelineInstanced: BillboardPipeline;
	var vertexBuffersBillboardInstanced : Array<VertexBuffer> = new Array();
	
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
		billboardPipeline = new BillboardPipeline(Shaders.billboard_frag, Shaders.billboard_uniform_vert, [ VertexStructures.Billboards ]);
		billboardPipelineInstanced = new BillboardPipeline(Shaders.billboard_frag, Shaders.billboard_attribute_vert, [ VertexStructures.Billboards, VertexStructures.BillboardsInstanced ]);
		
		vertexBuffersBillboardInstanced[1] = new VertexBuffer(
			PARTICLE_BATCH_SIZE,
			VertexStructures.BillboardsInstanced,
			Usage.DynamicUsage,
			1 // changed after every instance, use i higher number for repetitions
		);
		
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
		
		// Render particles
		if (g4.instancedRenderingAvailable()) {
			billboardPipelineInstanced.set(g4, view);
			
			vertexBuffersBillboardInstanced[0] = Meshes.Billboard.vertexBuffer;
			
			var bufferData = vertexBuffersBillboardInstanced[1].lock();
			var i = 0;
			for (emitter in particleEmitters) {
				
				// TODO: This fails if any emitter has more particles than fit into a single batch
				if (i + emitter.particleCount > PARTICLE_BATCH_SIZE) {
					// Render current batch
					actuallyRenderParticlesInstanced(g4, i);
					
					// Prepare for next batch
					bufferData = vertexBuffersBillboardInstanced[1].lock();
					i = 0;
				}
				
				for (pi in 0...emitter.particleCount) {
					addParticleToInstanceBuffers(emitter.particles[pi], bufferData, i);
					i++;
				}
			}
			
			// Render rest
			if (i > 0) {
				actuallyRenderParticlesInstanced(g4, i);
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
		
		
        g4.end();
		
		// Render 2d gui
		/*var g2 = frame.g2;
		
		g2.begin(false);
		
		// TODO: renderGUI
		
		g2.end();*/
    }
	
	function actuallyRenderParticlesInstanced(g : Graphics, i : Int) {
		vertexBuffersBillboardInstanced[1].unlock();
		
		g.setVertexBuffers(vertexBuffersBillboardInstanced);
		g.setIndexBuffer(Meshes.Billboard.indexBuffer);
		
		g.setTexture(billboardPipelineInstanced.textureUnit, Assets.images.smoke);
		
		g.drawIndexedVerticesInstanced(i);
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
		
		addVector2ToBuffer(bufferData, particle.size, actualPosition);
		addVector3ToBuffer(bufferData, particle.position, actualPosition + 2);
		addVector2ToBuffer(bufferData, particle.rotData, actualPosition + 5);
		addColorToBuffer(bufferData, particle.color, actualPosition + 7);
		addMatrixToBuffer(bufferData, calculateMVP(particle.model), actualPosition + 11);
	}
	
	private function addVector2ToBuffer(buffer : Float32Array, vector : FastVector2, offset : Int) {
		buffer.set(offset +  0, vector.x);
		buffer.set(offset +  1, vector.y);
	}
	
	private function addVector3ToBuffer(buffer: Float32Array, vector: FastVector3, offset: Int) {
		buffer.set(offset +  0, vector.x);
		buffer.set(offset +  1, vector.y);
		buffer.set(offset +  2, vector.z);
	}
	
	private function addColorToBuffer(buffer : Float32Array, color : Color, offset : Int) {
		buffer.set(offset +  0, color.R);
		buffer.set(offset +  1, color.G);
		buffer.set(offset +  2, color.B);
		buffer.set(offset +  3, color.A);
	}
	
	private function addMatrixToBuffer(buffer : Float32Array, matrix : FastMatrix4, offset : Int) {
		buffer.set(offset +  0, matrix._00);
		buffer.set(offset +  1, matrix._01);
		buffer.set(offset +  2, matrix._02);
		buffer.set(offset +  3, matrix._03);
		
		buffer.set(offset +  4, matrix._10);
		buffer.set(offset +  5, matrix._11);
		buffer.set(offset +  6, matrix._12);
		buffer.set(offset +  7, matrix._13);
		
		buffer.set(offset +  8, matrix._20);				
		buffer.set(offset +  9, matrix._21);				
		buffer.set(offset + 10, matrix._22);
		buffer.set(offset + 11, matrix._23);
		
		buffer.set(offset + 12, matrix._30);				
		buffer.set(offset + 13, matrix._31);				
		buffer.set(offset + 14, matrix._32);
		buffer.set(offset + 15, matrix._33);
	}
	
	function calculateMVP(model: FastMatrix4) : FastMatrix4 {
		var mvp : FastMatrix4 = FastMatrix4.identity();
		mvp = mvp.multmat(projection);
		mvp = mvp.multmat(view);
		mvp = mvp.multmat(model);
		return mvp;
	}
}