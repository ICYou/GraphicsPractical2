//------------------------------------------- Defines -------------------------------------------

#define Pi 3.14159265

//------------------------------------- Top Level Variables -------------------------------------

// Top level variables can and have to be set at runtime
float4 Color;
float3 LightSource;
float4 AmbientColor;
float AmbientIntensity;
// Matrices for 3D perspective projection 
float4x4 View, Projection, World;
float4 Color, LightDirection;

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
	//1.2 Checkerboard pattern
	// Set scalar for checkers
	int checkerSize = 5;
	float X = input.Coordinate.x;
	float Y = input.Coordinate.y;
	
	//Comment
	if (X < 0)
		X--;
	if (Y < 0)
		Y--;

	bool x = (int)(X * checkerSize) % 2;
	bool y = (int)(Y * checkerSize) % 2;	

	bool test = x != y;

	if (test) 
	{
			return float4(-input.Normal.x, -input.Normal.y, -input.Normal.z, 1);		
	}
	else 
	{
			return float4(input.Normal.x, input.Normal.y, input.Normal.z, 1);
	}
}

<<<<<<< HEAD
float4 LambertianLighting(VertexShaderInput input){

	return float4(1, 0, 0, 1);
}

float4 AmbientShading(VertexShaderInput input)
{
	return LambertianLighting(input) + AmbientColor * AmbientIntensity;
=======
float4 LambertianLighting(VertexShaderOutput input)
{
	float3x3 rotationAndScale = (float3x3) World;
	return Color * max(0, dot(normalize(mul(input.Normal, rotationAndScale)), normalize((-1) * normalize(LightDirection))));
>>>>>>> origin/master
}

//---------------------------------------- Technique: Simple ----------------------------------------

VertexShaderOutput SimpleVertexShader(VertexShaderOutput input)
{
	// Allocate an empty output struct
	VertexShaderOutput output = (VertexShaderOutput)0;

	// Do the matrix multiplications for perspective projection and the world transform
	float4 worldPosition = mul(input.Position3D, World);
    float4 viewPosition  = mul(worldPosition, View);
	output.Position2D    = mul(viewPosition, Projection);
	//1.1 Coloring using normals (add normal values to the output, so it can be used for coloring)
	output.Normal = input.Normal3D;
	//1.2 Checkerboard pattern (add pixel coordinates)
	output.Coordinate = input.Position3D.xy;

	return output;
}

float4 SimplePixelShader(VertexShaderOutput input) : COLOR0
{
	//float4 color = NormalColor(input);
	//float4 color = ProceduralColor(input);
<<<<<<< HEAD
	//float4 color = LambertianLighting(input);
	float4 color = AmbientShading(input);
=======
	float4 color = LambertianLighting(input);
>>>>>>> origin/master
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