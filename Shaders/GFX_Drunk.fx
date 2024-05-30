#include "ReShade.fxh"
#include "GFX_Utils.fxh"

uniform float timer < source = "timer"; >;

uniform float Speed <
    ui_type = "slider";
    ui_min =  0.2;
    ui_max =  3.0;
> = 1.0;

uniform float FoldAmount <
    ui_type = "slider";
    ui_min =  0.2;
    ui_max =  2.0;
> = 1.0;

uniform float Density <
    ui_type = "slider";
    ui_min =  0.2;
    ui_max =  3.0;
> = 1.0;

uniform float maskWidth <
    ui_type = "slider";
    ui_min =  0.0;
    ui_max =  2.0;
> = 0.15;

texture2D TempTex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; };
sampler2D TempSampler { Texture = TempTex; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };

float3 mod289 (float3 x)
{
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float2 mod289 (float2 x)
{
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float3 permute(float3 x)
{
    return mod289(((x*34.0)+1.0)*x);
}

float snoise(float2 v) {

    // Precompute values for skewed triangular grid
    const float4 C = float4(0.211324865405187,
                        // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,
                        // 0.5*(sqrt(3.0)-1.0)
                        -0.577350269189626,
                        // -1.0 + 2.0 * C.x
                        0.024390243902439);
                        // 1.0 / 41.0

    // First corner (x0)
    float2 i  = floor(v + dot(v, C.yy));
    float2 x0 = v - i + dot(i, C.xx);

    // Other two corners (x1, x2)
    float2 i1 = float2(0.0,0.0);
    i1 = (x0.x > x0.y)? float2(1.0, 0.0):float2(0.0, 1.0);
    float2 x1 = x0.xy + C.xx - i1;
    float2 x2 = x0.xy + C.zz;

    // Do some permutations to avoid
    // truncation effects in permutation
    i = mod289(i);
    float3 p = permute(permute( i.y + float3(0.0, i1.y, 1.0)) + i.x + float3(0.0, i1.x, 1.0 ));

    float3 m = max(0.5 - float3(dot(x0,x0),dot(x1,x1),dot(x2,x2)), 0.0);

    m = m*m ;
    m = m*m ;

    // Gradients:
    //  41 pts uniformly over a line, mapped onto a diamond
    //  The ring size 17*17 = 289 is close to a multiple
    //      of 41 (41*7 = 287)

    float3 x = 2.0 * frac(p * C.www) - 1.0;
    float3 h = abs(x) - 0.5;
    float3 ox = floor(x + 0.5);
    float3 a0 = x - ox;

    // Normalise gradients implicitly by scaling m
    // Approximation of: m *= inversesqrt(a0*a0 + h*h);
    m *= 1.79284291400159 - 0.85373472095314 * (a0*a0+h*h);

    // Compute final noise value at P
    float3 g = float3(0.0,0.0,0.0);
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * float2(x1.x,x2.x) + h.yz * float2(x1.y,x2.y);
    return 130.0 * dot(m, g);
}

float2x2 rotate2d(float angle)
{
	return float2x2(cos(angle),-sin(angle),
                	sin(angle),cos(angle));
}

float3 PS_Drunk(float4 vpos : VS_Position, float2 uv : TEXCOORD0) : SV_TARGET
{
    //Calculate mask to prevent getting out of uv bounds
    float2 maskUV = float2((uv.x/BUFFER_HEIGHT)*BUFFER_WIDTH,uv.y);
    float mask = smoothstep(0.0,maskWidth,maskUV.x) * 
                 smoothstep(0.0,maskWidth,maskUV.y) *
                 smoothstep(0.0,maskWidth,1-maskUV.y) *
                 smoothstep(0.0,maskWidth,(1.0/BUFFER_HEIGHT*BUFFER_WIDTH)-maskUV.x);

    float noise = snoise((uv * Density) + ((timer/10000) * Speed))/10;
	uv = mul(rotate2d(noise * FoldAmount * mask),uv);
	uv = frac(uv);
	float3 input = tex2D(GFX::BackBuffer, uv).rgb;
    return input;
}

float4 PS_End(float4 vpos : VS_Position, float2 uv : TEXCOORD0) : SV_TARGET
{
    return tex2D(TempSampler,uv);
}

technique GFX_Drunk
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = PS_Drunk;
        RenderTarget = TempTex;
    }

    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = PS_End;
        RenderTarget = GFX::BackBufferTex;
    }
}
