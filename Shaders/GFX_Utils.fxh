#pragma once

#include "ReShade.fxh"

uniform float _Time < source = "timer"; >;

namespace GFX
{
	texture2D BackBufferTex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; };
	sampler2D BackBuffer { Texture = BackBufferTex; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };
}
