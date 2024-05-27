#include "ReShade.fxh"
#include "GFX_Utils.fxh"

float4 PS_End(float4 vpos : VS_Position, float2 uv : TEXCOORD0) : SV_TARGET
{
    return tex2D(GFX::BackBuffer, uv);
}

technique GFX_End
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_End;
	}
}
