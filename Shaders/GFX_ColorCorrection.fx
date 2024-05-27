#include "ReShade.fxh"
#include "GFX_Utils.fxh"

uniform float Exposure <
    ui_type = "slider";
    ui_min =  0.0;
    ui_max =  4.0;
> = 1.0;

uniform float Contrast <
    ui_type = "slider";
    ui_min =  0.0;
    ui_max =  5.0;
> = 1.0;

uniform float MidPoint <
    ui_type = "slider";
    ui_min =  0.0;
    ui_max =  1.0;
> = 0.5;

uniform float Brightness <
    ui_type = "slider";
    ui_min = -1.0;
    ui_max =  1.0;
> = 0.0;

uniform float Saturation <
    ui_type = "slider";
    ui_min =  0.0;
    ui_max =  2.0;
> = 1.0;

uniform float GammaCorrection <
    ui_type = "slider";
    ui_min =  0.0;
    ui_max =  4.0;
> = 1.0;

float3 ColorToGrayscale(float3 col)
{
    return dot(col.rgb,float3(0.299, 0.578, 0.114));
}

float4 PS_ColorCorrection(float4 vpos : VS_Position, float2 uv : TEXCOORD0) : SV_TARGET
{
    float4 color = tex2D(GFX::BackBuffer, uv);

    // Exposure
    color.rgb *= Exposure;
    // Constrast, Brightness
    color.rgb = max(0.0, Contrast * (color.rgb - MidPoint) + MidPoint + Brightness);
    // Saturation
    color.rgb = max(0.0, lerp(ColorToGrayscale(color.rgb),color.rgb,Saturation));
    // Gamma Correction
    color.rgb = pow(color.rgb,GammaCorrection);
    return color;
}

technique GFX_ColorCorrection
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = PS_ColorCorrection;
        RenderTarget = GFX::BackBufferTex;
    }
}
