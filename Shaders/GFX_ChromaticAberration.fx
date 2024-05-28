#include "ReShade.fxh"
#include "GFX_Utils.fxh"

uniform float3 _Offset <
	ui_type = "drag";
	ui_max =  1.0;
	ui_min = -1.0;
> = 0.0;

texture2D TempTex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; };
sampler2D TempSampler { Texture = TempTex; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };

float4 PS_ChromaticAberration(float4 vpos : VS_Position, float2 uv : TEXCOORD0) : SV_TARGET
{
	float3 offsetUV = uv.x + _Offset;
	float3 input = float3(tex2D(GFX::BackBuffer, float2(offsetUV.x,uv.y)).x,
						  tex2D(GFX::BackBuffer, float2(offsetUV.y,uv.y)).y,
						  tex2D(GFX::BackBuffer, float2(offsetUV.z,uv.y)).z);
	return float4(input,1.0);

}

float4 PS_End(float4 vpos : VS_Position, float2 uv : TEXCOORD0) : SV_TARGET
{
	return tex2D(TempSampler,uv);
}

technique GFX_ChromaticAberration
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_ChromaticAberration;
		RenderTarget = TempTex;
	}

	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_End;
		RenderTarget = GFX::BackBufferTex;
	}
}
