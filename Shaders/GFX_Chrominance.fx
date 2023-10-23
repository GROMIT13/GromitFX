//TO DO: ADD MORE COLOR SPACES
//       FIX YUV MATRICES (THY DONT WORK CORRECTLY)


#include "ReShade.fxh"

uniform float _Y <
    ui_type = "slider";
    ui_min =  0.0;
    ui_max =  1.0;
> = 0.0;

static const float3x3 rgb2yuv = float3x3(
       0.299,    0.587,    0.114,
    -0.14713, -0.28886,    0.436,
       0.615, -0.51499, -0.10001);

static const float3x3 yuv2rgb = float3x3(
    1.0,      0.0, 0.13983,
    1.0, -0.39465, -0.5806,
    1.0,  2.03211, 0.0);

//texture2D imageText < source = "../Textures/Luma_Chroma_both.png";> {Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT;};
//sampler2D imageSample { Texture = imageText; };

float3 mod(float3 x, float3 y)
{
    return x - y * trunc(x/y);
}

float3 PS_Chrominance(float4 vpos : VS_Position, float2 uv : TEXCOORD0) : SV_TARGET
{
    float3 input = tex2D(ReShade::BackBuffer, uv).xyz;
    input = mul(rgb2yuv,input);
    input.z = 0;
    input.y = 0;
    input = mul(yuv2rgb,input);
    input = saturate(input);
    return input;
}

technique GFX_Chrominance
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = PS_Chrominance;
    }
}