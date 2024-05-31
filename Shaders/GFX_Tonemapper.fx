#include "ReShade.fxh"
#include "GFX_Utils.fxh"

float3 ACESFilm(float3 x)
{
	return saturate((x*(2.51*x+0.03))/(x*(2.43*x+0.59)+0.14));
}

float4 PS_Tonemapper(float4 vpos : VS_Position, float2 uv : TEXCOORD0) : SV_TARGET
{
	float4 input = tex2D(GFX::BackBuffer, uv);
	input = ACESFilm(input.rgb);
	return input;
}

technique GFX_Tonemapper
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_Tonemapper;
		RenderTarget = GFX::BackBufferTex;
	}
}