#include "ReShade.fxh"

uniform int ColorAmount <
    ui_type = "slider";
    ui_min =  2;
    ui_max =  256;
> = 256;

static const int bayer2[2 * 2] = {
    0, 2,
    3, 1
};

static const int bayer4[4 * 4] = {
    0,  8,  2, 10,
    12, 3, 14, 6,
    3, 11,  1, 9,
    15, 7, 13, 5
};


static const int bayer8[8 * 8] = {
     0, 32,  8, 40,  2, 34, 10, 42,
    48, 16, 56, 24, 50, 18, 58, 26,
    12, 44,  4, 36, 14, 46,  6, 38,
    60, 28, 52, 20, 62, 30, 54, 22,
     3, 35, 11, 43,  1, 33,  9, 41,
    51, 19, 59, 27, 49, 17, 57, 25,
    15, 47,  7, 39, 13, 45,  5, 37,
    63, 31, 55, 23, 61, 29, 53, 21
};

float GetBayer2(int x, int y)
{
    x = x % 2;
    y = y % 2;
    return float(float(bayer2[x + y * 2]) * 1.0/4.0);
}

float GetBayer4(int x, int y)
{
    x = x % 4;
    y = y % 4;
    return float(float(bayer4[x + y * 4]) * 1.0/16.0);
}

float GetBayer8(int x, int y)
{
    x = x % 8;
    y = y % 8;
    return float(float(bayer8[x + y * 8]) * 1.0/64.0);
}

float3 QuantizeColor(float3 color)
{
    return floor(color*ColorAmount)/(ColorAmount-1.0);
}


float3 PS_DitherFXmain(float4 vpos : VS_Position, float2 uv : TEXCOORD0) : SV_TARGET
{
    float3 input = tex2D(ReShade::BackBuffer, uv).rgb;

    float2 pixelPos = float2(uv.x * BUFFER_WIDTH, uv.y * BUFFER_HEIGHT);
    input = QuantizeColor(input);

    input = saturate(input);
    input.r = step(GetBayer2(pixelPos.x,pixelPos.y), input.r);
    input.g = step(GetBayer2(pixelPos.x,pixelPos.y), input.g);
    input.b = step(GetBayer2(pixelPos.x,pixelPos.y), input.b);

    //  input.r = floor(input.r * (float(ColorAmount) - 1.0) + 0.5) / (float(ColorAmount)-1.0);
    //input.g = floor(input.g * (float(ColorAmount) - 1.0) + 0.5) / (float(ColorAmount)-1.0);
    //input.b = floor(input.b * (float(ColorAmount) - 1.0) + 0.5) / (float(ColorAmount)-1.0);
    //input = floor(input*ColorAmount)/(ColorAmount-1.0);
    return float3(input);
}

technique GFX_Dither
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = PS_DitherFXmain;
    }
}