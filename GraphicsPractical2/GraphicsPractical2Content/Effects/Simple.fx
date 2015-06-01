//------------------------------------------- Defines -------------------------------------------

#define Pi 3.14159265

//------------------------------------- Top Level Variables -------------------------------------

// Top level variables can and have to be set at runtime

// Matrices for 3D perspective projection 
float4x4 View, Projection, World;

//---------------------------------- Input / Output structures ----------------------------------

// Each member of the struct has to be given a "semantic", to indicate what kind of data should go in
// here and how it should be treated. Read more about the POSITION0 and the many other semantics in 
// the MSDN library
struct VertexShaderInput
{
	float4 Position3D : POSITION0;
	float4 Normal3D : NORMAL0;

};

// The output of the vertex shader. After being passed through the interpolator/rasterizer it is also 
// the input of the pixel shader. 
// Note 1: The values that you pass into this struct in the vertex shader are not the same as what 
// you get as input for the pixel shader. A vertex shader has a single vertex as input, the pixel 
// shader has 3 vertices as input, and lets you determine the color of each pixel in the triangle 
// defined by these three vertices. Therefor, all the values in the struct that you get as input for 
// the pixel shaders have been linearly interpolated between there three vertices!
// Note 2: You cannot use the data with the POSITION0 semantic in the pixel shader.
struct VertexShaderOutput
{
	float4 Position2D : POSITION0;
	float4 Normal : TEXCOORD0;
	float2 Coordinate : TEXCOORD1;
};

//------------------------------------------ Functions ------------------------------------------

// Implement the Coloring using normals assignment here
float4 NormalColor(VertexShaderOutput input)
{
	return float4(input.Normal.x, input.Normal.y, input.Normal.z, 1);
}

// Implement the Procedural texturing assignment here
float4 ProceduralColor(VertexShaderOutput input)
{
	// Set scalar for checkers
	int scalar = 5;
	
			// Implicit casting from (float) to (int)
	int posX = abs(input.Coordinate.x * scalar) % 2;
		int posY = abs(input.Coordinate.y * scalar) % 2;
	
			// Toggle between signs being both equal or not
	if (sign(input.Coordinate.x) == sign(input.Coordinate.y)) {
		if (posX == posY) {
			return float4(-input.Normal.x, -input.Normal.y, -input.Normal.z, 1);
			
		}
		else {
			return float4(input.Normal.x, input.Normal.y, input.Normal.z, 1);
			
		}
		
	}
	else {
		if (posX == posY) {
			return float4(input.Normal.x, input.Normal.y, input.Normal.z, 1);
			
		}
		else {
			return float4(-input.Normal.x, -input.Normal.y, -input.Normal.z, 1);
			
		}
		
	}
}

//---------------------------------------- Technique: Simple ----------------------------------------

VertexShaderOutput SimpleVertexShader(VertexShaderInput input)
{
	// Allocate an empty output struct
	VertexShaderOutput output = (VertexShaderOutput)0;

	// Do the matrix multiplications for perspective projection and the world transform
	float4 worldPosition = mul(input.Position3D, World);
    float4 viewPosition  = mul(worldPosition, View);
	output.Position2D    = mul(viewPosition, Projection);
	//1.1 Coloring using normals (add normal values to the output, so it can be used for coloring)
	output.Normal = input.Normal3D;
	// Assign 3D coordinates for procedural texture rendering
	output.Coordinate = input.Position3D.xy;

	return output;
}

float4 SimplePixelShader(VertexShaderOutput input) : COLOR0
{
	//float4 color = NormalColor(input);
	float4 color = ProceduralColor(input);
	return color;
}

technique Simple
{
	pass Pass0
	{
		VertexShader = compile vs_2_0 SimpleVertexShader();
		PixelShader  = compile ps_2_0 SimplePixelShader();
	}
}