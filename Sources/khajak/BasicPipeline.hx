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

class BasicPipeline {
	public var pipeline: PipelineState;
	
	public var textureUnit: TextureUnit;
	
	public var viewMatrixID: ConstantLocation;
	public var light1ColorID: ConstantLocation;
	public var light1PowerID: ConstantLocation;
	public var light1PositionID: ConstantLocation;
	public var light2ColorID: ConstantLocation;
	public var light2PowerID: ConstantLocation;
	public var light2PositionID: ConstantLocation;
	public var light3ColorID: ConstantLocation;
	public var light3PowerID: ConstantLocation;
	public var light3PositionID: ConstantLocation;
	public var light4ColorID: ConstantLocation;
	public var light4PowerID: ConstantLocation;
	public var light4PositionID: ConstantLocation;
	public var light5ColorID: ConstantLocation;
	public var light5PowerID: ConstantLocation;
	public var light5PositionID: ConstantLocation;
	public var light6ColorID: ConstantLocation;
	public var light6PowerID: ConstantLocation;
	public var light6PositionID: ConstantLocation;
	public var light7ColorID: ConstantLocation;
	public var light7PowerID: ConstantLocation;
	public var light7PositionID: ConstantLocation;
	public var light8ColorID: ConstantLocation;
	public var light8PowerID: ConstantLocation;
	public var light8PositionID: ConstantLocation;
	
	public var colorID: ConstantLocation;
	public var modelMatrixID: ConstantLocation;
	public var mvpMatrixID: ConstantLocation;
	
	public function new(fragmentShader: FragmentShader, vertexShader: VertexShader, inputLayout: Array<VertexStructure>, writeStencil: Bool = false) {
		pipeline = new PipelineState();
		pipeline.fragmentShader = fragmentShader;
		pipeline.vertexShader = vertexShader;
		pipeline.inputLayout = inputLayout;
		pipeline.depthWrite = true;
		pipeline.depthMode = CompareMode.Less;
		pipeline.cullMode = CullMode.Clockwise;
		pipeline.blendSource = BlendingFactor.SourceAlpha;
		pipeline.blendDestination = BlendingFactor.InverseSourceAlpha;
		if (writeStencil) {
			pipeline.stencilWriteMask = 0xff;
			pipeline.stencilReferenceValue = 1;
			pipeline.stencilMode = kha.graphics4.CompareMode.Always;
			pipeline.stencilBothPass = kha.graphics4.StencilAction.Replace;
		}
		pipeline.compile();
		
		textureUnit = pipeline.getTextureUnit("tex");
		
		viewMatrixID = pipeline.getConstantLocation("viewMatrix");
		light1ColorID = pipeline.getConstantLocation("light1Color");
		light1PowerID = pipeline.getConstantLocation("light1Power");
		light1PositionID = pipeline.getConstantLocation("light1Position");
		light2ColorID = pipeline.getConstantLocation("light2Color");
		light2PowerID = pipeline.getConstantLocation("light2Power");
		light2PositionID = pipeline.getConstantLocation("light2Position");
		light3ColorID = pipeline.getConstantLocation("light3Color");
		light3PowerID = pipeline.getConstantLocation("light3Power");
		light3PositionID = pipeline.getConstantLocation("light3Position");
		light4ColorID = pipeline.getConstantLocation("light4Color");
		light4PowerID = pipeline.getConstantLocation("light4Power");
		light4PositionID = pipeline.getConstantLocation("light4Position");
		light5ColorID = pipeline.getConstantLocation("light5Color");
		light5PowerID = pipeline.getConstantLocation("light5Power");
		light5PositionID = pipeline.getConstantLocation("light5Position");
		light6ColorID = pipeline.getConstantLocation("light6Color");
		light6PowerID = pipeline.getConstantLocation("light6Power");
		light6PositionID = pipeline.getConstantLocation("light6Position");
		light7ColorID = pipeline.getConstantLocation("light7Color");
		light7PowerID = pipeline.getConstantLocation("light7Power");
		light7PositionID = pipeline.getConstantLocation("light7Position");
		light8ColorID = pipeline.getConstantLocation("light8Color");
		light8PowerID = pipeline.getConstantLocation("light8Power");
		light8PositionID = pipeline.getConstantLocation("light8Position");
		
		colorID = pipeline.getConstantLocation("color");
		modelMatrixID = pipeline.getConstantLocation("modelMatrix");
		mvpMatrixID = pipeline.getConstantLocation("mvpMatrix");
	}
	
	public function set(g: Graphics, viewMatrix: FastMatrix4, light1: Light, light2: Light, light3: Light, light4: Light, light5: Light, light6: Light, light7: Light, light8: Light) {
		g.setPipeline(pipeline);
		
		g.setMatrix(viewMatrixID, viewMatrix);
		
		g.setFloat3(light1ColorID, light1.color.R, light1.color.G, light1.color.B);
		g.setFloat(light1PowerID, light1.power);
		g.setFloat3(light1PositionID, light1.position.x, light1.position.y, light1.position.x);
		g.setFloat3(light2ColorID, light2.color.R, light2.color.G, light2.color.B);
		g.setFloat(light2PowerID, light2.power);
		g.setFloat3(light2PositionID, light2.position.x, light2.position.y, light2.position.x);
		g.setFloat3(light3ColorID, light3.color.R, light3.color.G, light3.color.B);
		g.setFloat(light3PowerID, light3.power);
		g.setFloat3(light3PositionID, light3.position.x, light3.position.y, light3.position.x);
		g.setFloat3(light4ColorID, light4.color.R, light4.color.G, light4.color.B);
		g.setFloat(light4PowerID, light4.power);
		g.setFloat3(light4PositionID, light4.position.x, light4.position.y, light4.position.x);
		g.setFloat3(light5ColorID, light5.color.R, light5.color.G, light5.color.B);
		g.setFloat(light5PowerID, light5.power);
		g.setFloat3(light5PositionID, light5.position.x, light5.position.y, light5.position.x);
		g.setFloat3(light6ColorID, light6.color.R, light6.color.G, light6.color.B);
		g.setFloat(light6PowerID, light6.power);
		g.setFloat3(light6PositionID, light6.position.x, light6.position.y, light6.position.x);
		g.setFloat3(light7ColorID, light7.color.R, light7.color.G, light7.color.B);
		g.setFloat(light7PowerID, light7.power);
		g.setFloat3(light7PositionID, light7.position.x, light7.position.y, light7.position.x);
		g.setFloat3(light8ColorID, light8.color.R, light8.color.G, light8.color.B);
		g.setFloat(light8PowerID, light8.power);
		g.setFloat3(light8PositionID, light8.position.x, light8.position.y, light8.position.x);
	}
}