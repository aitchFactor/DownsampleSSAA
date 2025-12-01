/**
	DownsampleSSAA version 1.0
	by PthoEastCoast

	Makes it look as if the image was downsampled from it's native resolution to a custom lower resolution.
	Giving the impression of rendering at a lower resolution but with higher image quality comparable to supersampling.
	It blurs the original image and then pixelates the image after blurring.
	For best image quality - run the game at the native resolution of your display with MSAA.

	Customised by _aitchFactor
	- Default smooth factor now leaves integer scaled content unsmoothened.
	- Nearest neighbor upscaling is no longer shifted slightly relative to the original image.
	- Separate horizontal and vertical upscaling and blur settings - useful for pairing with CRT filters.
	- Sample offset and panning options for custom alignment.
**/

#include "ReShadeUI.fxh"

uniform int HorizontalUpscalingSetting
<
	ui_type = "combo";
ui_items = "Nearest-neighbor" "\0"
"Bilinear" "\0"
"Bilinear Sharp 1" "\0"
"Bilinear Sharp 2" "\0"
"Bilinear Sharp 3" "\0"
"Bilinear Sharp 4" "\0";
ui_label = "Horizontal upscaling setting";
ui_tooltip = "Sets the method used to upscale the downsampled image.\n"
"Nearest-neighbor provides a pixel sharp image.\n"
"Bilinear provides a smooth image by blending between neighboring pixels.\n"
"Bilinear Sharp 1-4 will provide a progressively sharper image than Bilinear.";
> = 1;

uniform int VerticalUpscalingSetting
<
	ui_type = "combo";
ui_items = "Nearest-neighbor" "\0"
"Bilinear" "\0"
"Bilinear Sharp 1" "\0"
"Bilinear Sharp 2" "\0"
"Bilinear Sharp 3" "\0"
"Bilinear Sharp 4" "\0";
ui_label = "Vertical upscaling setting";
ui_tooltip = "Sets the method used to upscale the downsampled image.\n"
"Nearest-neighbor is the fastest and provides a pixel sharp image.\n"
"Bilinear provides a smooth image by blending between neighboring pixels.\n"
"Bilinear Sharp 1-4 will provide a progressively sharper image than Bilinear.";
> = 0;
uniform int numOfSamplesRight
<
	ui_type = "input";
ui_min = 1; ui_max = 99;
ui_tooltip = "Number of samples to take for blur. Higher gets a smoother blur effect, but is slower.";
ui_label = "Blur samples";
> = 6.0;

uniform int VerticalResolution
<
	ui_type = "input";
ui_min = 240.0; ui_max = 1080.0;
ui_tooltip = "Sets the vertical resolution of the downsampled image.";
> = 240.0;

uniform float HorizontalResolution
<
	ui_type = "input";
ui_min = 0.0; ui_max = 7680.0;
ui_tooltip = "Set to 0.0 or negative for automatic.";
> = 0.0;

uniform float HorizontalBlurFactor
<
	ui_type = "drag";
ui_min = -0.01; ui_max = 10.0; ui_step = 0.01;
ui_tooltip = "Sets the blur width in downsampled pixels. Set to negative for automatic (horizontal blur is synced to vertical resolution)";
ui_label = "Horizontal Blur";
> = 1.0;

uniform float VerticalBlurFactor
<
	ui_type = "drag";
ui_min = 0.0; ui_max = 10.0; ui_step = 0.01;
ui_label = "Vertical Blur";
ui_tooltip = "Sets the blur height in downsampled pixels.";
> = 1.0;

uniform int SampleOffsetX
< __UNIFORM_SLIDER_INT1
	ui_min = -20; ui_max = 20;
ui_tooltip = "Use to align any integer scaled content to the downsampling filter.";
> = 0.0;

uniform int SampleOffsetY
< __UNIFORM_SLIDER_INT1
	ui_min = -20.0; ui_max = 20.0;
ui_tooltip = "Use to align any integer scaled content to the downsampling filter.";
> = 0.0;

uniform float PanX
< __UNIFORM_SLIDER_INT1
	ui_min = -20; ui_max = 20; ui_step = 0.5;
ui_tooltip = "Pans the output image horizontally.";
> = 0.0;

uniform float PanY
< __UNIFORM_SLIDER_INT1
	ui_min = -20.0; ui_max = 20.0; ui_step = 0.5;
ui_tooltip = "Pans the output image vertically.";
> = 0.0;

#include "ReShade.fxh"



texture BoxBlurHTex < pooled = true; > { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
texture BoxBlurVTex < pooled = true; > { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };

sampler BoxBlurHSampler{ Texture = BoxBlurHTex; };
sampler BoxBlurVSampler{ Texture = BoxBlurVTex; };

float4 BoxBlurHorizontalPass(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
	if (HorizontalBlurFactor == 0.0) {
		return tex2D(ReShade::BackBuffer, texcoord);
	}


	float aspectRatio = 1.0 / BUFFER_ASPECT_RATIO;
	float pixelUVSize;
	if (HorizontalResolution <= 0.0) {
		pixelUVSize = (1.0 / (float)VerticalResolution) * aspectRatio;
	}
	else {
		pixelUVSize = (1.0 / (float)HorizontalResolution);
	}

	float smoothScale;
	if (HorizontalBlurFactor < 0.0) {
		// 1.5 looks close to downscaled resolution with bilinear but this isn't mathematically equivalent
		smoothScale =  (1.5/pixelUVSize) / (VerticalResolution / aspectRatio);
	}
	else {
		smoothScale = (float)HorizontalBlurFactor;
	}

	float bufferUVWidth = (1.0 / BUFFER_WIDTH);
	float uvDistBetweenSamples = ((pixelUVSize * smoothScale) - bufferUVWidth) / (0.0 + numOfSamplesRight * 2.0);



	float4 accumulatedColor = float4(0.0, 0.0, 0.0, 1.0);

	for (float i = -numOfSamplesRight; i <= numOfSamplesRight; i++)
	{
		accumulatedColor = accumulatedColor + tex2D(ReShade::BackBuffer, texcoord + float2(i * uvDistBetweenSamples - (bufferUVWidth * 0.5), 0.0));
	}
	accumulatedColor = accumulatedColor * (1.0 / (1.0 + numOfSamplesRight * 2.0));

	return accumulatedColor;
}

float4 BoxBlurVerticalPass(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{

	if (VerticalBlurFactor == 0.0) {
		return tex2D(BoxBlurHSampler, texcoord);
	}
	float pixelUVSize = 1.0 / (float)VerticalResolution;
	float smoothScale = (float)VerticalBlurFactor;

	float bufferUVHeight = (1.0 / BUFFER_HEIGHT);

	float uvDistBetweenSamples = ((pixelUVSize * smoothScale) - (bufferUVHeight)) / (0 + numOfSamplesRight * 2.0);

	float4 accumulatedColor = float4(0.0, 0.0, 0.0, 1.0);

	for (float i = -numOfSamplesRight; i <= numOfSamplesRight; i++)
	{
		accumulatedColor = accumulatedColor + tex2D(BoxBlurHSampler, texcoord + float2(0.0, i * uvDistBetweenSamples - (bufferUVHeight * 0.5)));
	}
	accumulatedColor = accumulatedColor * (1.0 / (1.0 + numOfSamplesRight * 2.0));

	return accumulatedColor;
}

float3 PixelationPass(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
	float aspectRatio = 1.0 / BUFFER_ASPECT_RATIO;
	float2 TexcoordSize = float2(1.0 / BUFFER_WIDTH, 1.0 / BUFFER_HEIGHT);
	float PixelUVSize = 1.0 / (float)VerticalResolution;

	float pixelUVSizeX;
	if (HorizontalResolution <= 0.0) {
		pixelUVSizeX = PixelUVSize * aspectRatio;
	}
	else {
		pixelUVSizeX = 1.0 / (float)HorizontalResolution;
	}
	float pixelUVSizeY = PixelUVSize;

	float2 fracSampleOffset = float2(
		TexcoordSize.x * (float)SampleOffsetX, 
		TexcoordSize.y * (float)SampleOffsetY
		);
	float2 fracPan = float2(TexcoordSize.x * (float)PanX, TexcoordSize.y * (float)PanY);

	float NNTexcoordDistFromPixelX = (fracSampleOffset.x + texcoord.x) % pixelUVSizeX;
	float NNTexcoordDistFromPixelY = (fracSampleOffset.y + texcoord.y) % pixelUVSizeY;

	float2 NNThisCoord;
	NNThisCoord.x = texcoord.x + fracPan.x - NNTexcoordDistFromPixelX + 0.5 * pixelUVSizeX + ((0.5 * TexcoordSize.x) % (0.5 * pixelUVSizeX));
	NNThisCoord.y = texcoord.y + fracPan.y - NNTexcoordDistFromPixelY + 0.5 * pixelUVSizeY + ((0.5 * TexcoordSize.y) % (0.5 * pixelUVSizeY));

	float3 NNPixelColor = tex2D(BoxBlurVSampler, NNThisCoord).rgb;
	if (HorizontalUpscalingSetting == 0 & VerticalUpscalingSetting == 0)
	{
		return NNPixelColor;
	}

	float texcoordDistFromPixelX = (fracSampleOffset.x + fracPan.x + texcoord.x + 0.5 * pixelUVSizeX) % pixelUVSizeX;
	float texcoordDistFromPixelY = (fracSampleOffset.y + fracPan.y + texcoord.y + 0.5 * pixelUVSizeY) % pixelUVSizeY;

	float2 thisCoord;
	thisCoord.x = texcoord.x + fracPan.x - texcoordDistFromPixelX + ((0.5 * TexcoordSize.x) % (0.5 * pixelUVSizeX));
	thisCoord.y = texcoord.y + fracPan.y - texcoordDistFromPixelY + ((0.5 * TexcoordSize.y) % (0.5 * pixelUVSizeY));
	

	float tx = texcoordDistFromPixelX / pixelUVSizeX;
	float ty = texcoordDistFromPixelY / pixelUVSizeY;

	float horizontalPowerAmount = 0.75 + HorizontalUpscalingSetting * 0.25;
	float verticalPowerAmount = 0.75 + VerticalUpscalingSetting * 0.25;

	tx = tx < 0.5 ? pow(abs(tx), horizontalPowerAmount) : pow(abs(tx), 1.0 / horizontalPowerAmount);
	ty = ty < 0.5 ? pow(abs(ty), verticalPowerAmount) : pow(abs(ty), 1.0 / verticalPowerAmount);

	float2 nextCoordShift = float2(pixelUVSizeX, pixelUVSizeY);

	float2 nextCoordUp = thisCoord;
	nextCoordUp += float2(0.0, nextCoordShift.y);

	float2 nextCoordRight = thisCoord;
	nextCoordRight += float2(nextCoordShift.x, 0.0);

	float2 nextCoordUpRight = thisCoord + nextCoordShift;

	if (HorizontalUpscalingSetting == 0) {
		float NNHCoord = NNThisCoord.x;
		thisCoord.x = NNHCoord;
		nextCoordUp.x = NNHCoord;
		nextCoordRight.x = NNHCoord;
		nextCoordUpRight.x = NNHCoord;
	}

	if (VerticalUpscalingSetting == 0) {
		float NNVCoord = NNThisCoord.y;
		thisCoord.y = NNVCoord;
		nextCoordUp.y = NNVCoord;
		nextCoordRight.y = NNVCoord;
		nextCoordUpRight.y = NNVCoord;
	}


	float3 thisPixelColor = tex2D(BoxBlurVSampler, thisCoord).rgb;
	float3 nextPixelColorUp = tex2D(BoxBlurVSampler, nextCoordUp).rgb;
	float3 nextPixelColorRight = tex2D(BoxBlurVSampler, nextCoordRight).rgb;
	float3 nextPixelColorUpRight = tex2D(BoxBlurVSampler, nextCoordUpRight).rgb;

	float3 lerpCurrentToRight = lerp(thisPixelColor, nextPixelColorRight, tx);
	float3 lerpUpToUpRight = lerp(nextPixelColorUp, nextPixelColorUpRight, tx);

	float3 pixelColor = lerp(lerpCurrentToRight, lerpUpToUpRight, ty);

	return pixelColor;
}

technique DownsampleSSAA
{
	pass BoxBlurHorizontalPass
	{
		VertexShader = PostProcessVS;
		PixelShader = BoxBlurHorizontalPass;
		RenderTarget = BoxBlurHTex;
	}
	pass BoxBlurVerticalPass
	{
		VertexShader = PostProcessVS;
		PixelShader = BoxBlurVerticalPass;
		RenderTarget = BoxBlurVTex;
	}
	pass PixelationPass
	{
		VertexShader = PostProcessVS;
		PixelShader = PixelationPass;
	}
}
