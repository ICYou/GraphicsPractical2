//------------------------------------------- Defines -------------------------------------------

#define Pi 3.14159265

//------------------------------------- Top Level Variables -------------------------------------

// Top level variables can and have to be set at runtime

// Matrices for 3D perspective projection 
float4x4 View, Projection, World, InversedTransposedWorld;
float4 Color, LightDirection, AmbientColor, SpecularColor;
float AmbientIntensity, SpecularIntensity, SpecularPower;
float3 CameraPosition;


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
	float4 Position3D : TEXCOORD2;
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

// LambertianLighting implementation
float4 LambertianLighting(VertexShaderOutput input)
{
	float4 lightVector = (-1) * normalize(LightDirection);

		//lambertian calculation (2.1)
		float4 lambColor = Color * max(0, dot(input.Normal, normalize(lightVector)));
		//ambientcolor calculation (2.2)
		float4 ambColor = AmbientColor * AmbientIntensity;

		return lambColor + ambColor;
}

// PhongLighting implementation
float4 PhongLighting(VertexShaderOutput input)
{
	float4 lightVector = (-1) * normalize(LightDirection);
		lightVector.w = 0;
		//Normal Fix
	//float4 Normal = input.Normal;
		float4 Normal = mul(input.Normal, InversedTransposedWorld);
		//3x3 maken
		Normal.w = 0;
	Normal = normalize(Normal);

	//lambertian calculation (2.1)
	float4 lambColor = Color * max(0, dot(Normal, normalize(lightVector)));
		//ambientcolor calculation (2.2)
		float4 ambColor = AmbientColor * AmbientIntensity;
		//specular calculation (2.3)
		float4 viewVector = normalize(mul(CameraPosition, World));
		//viewVector.w = 0;
		float4 halfVector = normalize(lightVector + viewVector);
		float4 specColor = SpecularColor * (SpecularIntensity * pow(saturate(dot(Normal, halfVector)), SpecularPower));
		return lambColor + ambColor + specColor;
}

//---------------------------------------- Technique: Simple ----------------------------------------

VertexShaderOutput SimpleVertexShader(VertexShaderInput input)
{
	// Allocate an empty output struct
	VertexShaderOutput output = (VertexShaderOutput)0;

	// Do the matrix multiplications for perspective projection and the world transform
	//2.3
	float4 worldPosition = mul(input.Position3D, World);

		float4 viewPosition = mul(worldPosition, View);
		output.Position2D = mul(viewPosition, Projection);

	//1.1 Coloring using normals (add normal values to the output, so it can be used for coloring)
	output.Normal = input.Normal3D;

	//1.2 Checkerboard pattern (add pixel coordinates)
	output.Coordinate = input.Position3D.xy;
	output.Position3D = input.Position3D;

	return output;
}

float4 SimplePixelShader(VertexShaderOutput input) : COLOR0
{
	//float4 color = NormalColor(input);
	//float4 color = ProceduralColor(input);
	//float4 color = LambertianLighting(input); //(+ 2.2)
	float4 color = PhongLighting(input);
	return color;
}

technique Simple
{
	pass Pass0
	{
		VertexShader = compile vs_2_0 SimpleVertexShader();
		PixelShader = compile ps_2_0 SimplePixelShader();
	}
}