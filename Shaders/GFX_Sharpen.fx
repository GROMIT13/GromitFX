#include "ReShade.fxh"

static const float pixelWidth = 1.0 / BUFFER_WIDTH;
static const float pixelheight = 1.0 / BUFFER_HEIGHT;

float3 PS_Sharpen(float4 vpos : VS_Position, float2 uv : TEXCOORD0) : SV_TARGET
{
	float3 input = tex2D(ReShade::BackBuffer, uv).rgb;
	float3 up = -tex2D(ReShade::BackBuffer, uv - pixelheight).rgb;
	float3 down = -tex2D(ReShade::BackBuffer, uv + pixelheight).rgb;
	float3 left = -tex2D(ReShade::BackBuffer, uv - pixelWidth).rgb;
	float3 right = -tex2D(ReShade::BackBuffer, uv + pixelWidth).rgb;
	
	input *= 5;
	input += (up + down + left + right);

	return input;
}

technique GFX_Sharpen
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = PS_Sharpen;
    }
}
