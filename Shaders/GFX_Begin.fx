#include "ReShade.fxh"
#include "GFX_Utils.fxh"

float4 PS_Beigin(float4 vpos : VS_Position, float2 uv : TEXCOORD0) : SV_TARGET
{
    float3 input = tex2D(ReShade::BackBuffer, uv).rgb;
    return float4(input,1.0);
}

technique GFX_Begin
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_Beigin;
		RenderTarget = GFX::BackBufferTex;
	}
}
