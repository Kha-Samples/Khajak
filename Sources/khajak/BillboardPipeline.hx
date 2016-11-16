package khajak;
import kha.Color;
import kha.graphics4.BlendingFactor;
import kha.graphics4.BlendingOperation;
import kha.graphics4.CompareMode;
import kha.graphics4.ConstantLocation;
import kha.graphics4.CullMode;
import kha.graphics4.FragmentShader;
import kha.graphics4.Graphics;
import kha.graphics4.PipelineState;
import kha.graphics4.TextureUnit;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;
import kha.math.FastMatrix4;

class BillboardPipeline {
	public var pipeline: PipelineState;
	
	public var textureUnit: TextureUnit;
	
	public var viewMatrixID: ConstantLocation;
	
	public var baseColorID: ConstantLocation;
	public var centerID: ConstantLocation;
	public var sizeID: ConstantLocation;
	public var rotDataID: ConstantLocation;
	public var mvpMatrixID: ConstantLocation;
	
	public function new(fragmentShader: FragmentShader, vertexShader: VertexShader, inputLayout: Array<VertexStructure>) {
		pipeline = new PipelineState();
		pipeline.fragmentShader = fragmentShader;
		pipeline.vertexShader = vertexShader;
		pipeline.inputLayout = inputLayout;
		pipeline.depthWrite = false; // Particles usually have transparent parts, so they should not cover each other
		pipeline.depthMode = CompareMode.Less;
		pipeline.cullMode = CullMode.CounterClockwise;
		pipeline.blendSource = BlendingFactor.SourceAlpha;
		pipeline.blendDestination = BlendingFactor.InverseSourceAlpha;
		pipeline.compile();
		
		textureUnit = pipeline.getTextureUnit("tex");
		
		viewMatrixID = pipeline.getConstantLocation("viewMatrix");
		
		baseColorID = pipeline.getConstantLocation("baseColor");
		centerID = pipeline.getConstantLocation("centerWorldspace");
		sizeID = pipeline.getConstantLocation("sizeWorldspace");
		rotDataID = pipeline.getConstantLocation("rotData");
		mvpMatrixID = pipeline.getConstantLocation("mvpMatrix");
	}
	
	public function set(g: Graphics, viewMatrix: FastMatrix4) {
		g.setPipeline(pipeline);
		
		g.setMatrix(viewMatrixID, viewMatrix);
	}
}