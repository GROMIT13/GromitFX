#include "ReShade.fxh"
#include "GFX_Utils.fxh"

uniform int _DownscaleeAmount <
    ui_type = "slider";
    ui_max = 10;
    ui_min = 0;
> = 1;

texture2D downsampleTex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; MipLevels = 5; };

sampler2D downsampleSampler
{
    Texture = downsampleTex;
    MagFilter = POINT;
    MinFilter = POINT;
    MipFilter = POINT;
};

float3 PS_Downscale(float4 vpos : VS_Position, float2 uv : TEXCOORD0) : SV_TARGET
{
    float3 input = tex2D(GFX::BackBuffer, uv).rgb;
    return input;
}

float3 PS_Return (float4 vpos : VS_Position, float2 uv : TEXCOORD0) : SV_TARGET
{
    float3 input = tex2Dlod(downsampleSampler, float4(uv,_DownscaleeAmount.xx)).rgb;
    return input;
}

technique GFX_Downscale
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = PS_Downscale;
        RenderTarget = downsampleTex;
    }

    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = PS_Return;
        RenderTarget = GFX::BackBufferTex;
    }
}