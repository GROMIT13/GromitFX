#include "ReShade.fxh"
#include "GFX_Utils.fxh"

uniform float _DepthMask <
	ui_type = "drag";
	ui_max =  0.0;
	ui_min = 1.0;
> = 0.5;

//texture2D currTex : COLOR;
texture2D prevTex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; };

texture2D CurrTexCopy {Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; MipLevels = 1; };
sampler2D CurrTexCopySampler{Texture = CurrTexCopy;};

//sampler2D currColor { Texture = currTex; };
sampler2D prevColor { Texture = prevTex; };

float4 PS_PostProcess(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target0
{
	float4 depth = tex2D(ReShade::DepthBuffer,texcoord);
	float4 curr = tex2D(GFX::BackBuffer, texcoord);
	float4 prev = tex2D(prevColor, texcoord);
	
	float4 output = ((prev) + (-curr + 1.0)) /  2.0;
	//output -= 0.5;
	//output *= 3;
	//if(depth.x < _DepthMask)
	// 	return output > 0.0;
	//else
	// 	return curr;
	return output;
}
float4 PS_CopyFrame(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	return tex2D(GFX::BackBuffer, texcoord);
}

float4 PS_ShowPastFrame(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	return tex2D(prevColor, texcoord);
}

float4 PS_ClearTexture(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	return float4(1.0, 1.0, 1.0, 1.0);
}

float4 PS_DisplayFrame(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	return tex2D(CurrTexCopySampler,texcoord);
}

technique GFX_MotionExtraction
{
	pass DoPostProcessing
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_PostProcess;
		RenderTarget = CurrTexCopy;
	}
	pass ClearTexture
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_ClearTexture;
		RenderTarget = prevTex;
	}
	pass DoCopyFrameForPrevAccess
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_CopyFrame;
		RenderTarget = prevTex;
	}
	pass 
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_DisplayFrame;
		RenderTarget = GFX::BackBufferTex;
	}
}
