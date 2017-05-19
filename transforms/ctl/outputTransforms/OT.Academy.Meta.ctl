import "ACESlib.Utilities";
import "ACESlib.Transform_Common";
import "ACESlib.RRT_Common";
import "ACESlib.ODT_Common";
// import "ACESlib.Tonescales";
import "ssts";



const Chromaticities DISPLAY_PRI = 
{ // P3-D65
  { 0.68000,  0.32000},
  { 0.26500,  0.69000},
  { 0.15000,  0.06000},
  { 0.31270,  0.32900}
};
const float XYZ_2_DISPLAY_PRI_MAT[4][4] = XYZtoRGB( DISPLAY_PRI, 1.0);



void main
(
	input varying float rIn,
	input varying float gIn,
	input varying float bIn,
	input varying float aIn,
	output varying float rOut,
	output varying float gOut,
	output varying float bOut,
	output varying float aOut,
	float minLum = 0.02,
	float maxLum = 48.0,
	float midLum = 4.8
)
{
    // NOTE: This is a bit of a hack - probably a more direct way to do this.
    TsParams PARAMS_DEFAULT = init_TsParams( minLum, maxLum);
    float expShift = log2(inv_ssts( midLum, PARAMS_DEFAULT))-log2(0.18);

    TsParams PARAMS = init_TsParams( minLum, maxLum, expShift);
 
    // --- Initialize a 3-element vector with input variables (ACES) --- //
    float aces[3] = {rIn, gIn, bIn};

    // --- Glow module --- //
    float saturation = rgb_2_saturation( aces);
    float ycIn = rgb_2_yc( aces);
    float s = sigmoid_shaper( (saturation - 0.4) / 0.2);
    float addedGlow = 1. + glow_fwd( ycIn, RRT_GLOW_GAIN * s, RRT_GLOW_MID);

    aces = mult_f_f3( addedGlow, aces);

    // --- Red modifier --- //
    float hue = rgb_2_hue( aces);
    float centeredHue = center_hue( hue, RRT_RED_HUE);
    float hueWeight = cubic_basis_shaper( centeredHue, RRT_RED_WIDTH);

    aces[0] = aces[0] + hueWeight * saturation * (RRT_RED_PIVOT - aces[0]) * (1. - RRT_RED_SCALE);

    // --- ACES to RGB rendering space --- //
    aces = clamp_f3( aces, 0., HALF_POS_INF);
    float rgbPre[3] = mult_f3_f44( aces, AP0_2_AP1_MAT);

    // --- Global desaturation --- //
    rgbPre = mult_f3_f33( rgbPre, RRT_SAT_MAT);

    // Apply the tonescale independently in rendering-space RGB
    float rgbPost[3];
    rgbPost[0] = ssts( rgbPre[0], PARAMS);
    rgbPost[1] = ssts( rgbPre[1], PARAMS);
    rgbPost[2] = ssts( rgbPre[2], PARAMS);
    
    // Convert to display primary encoding
    // Rendering space RGB to XYZ
    float XYZ[3] = mult_f3_f44( rgbPost, AP1_2_XYZ_MAT);

    // Apply CAT from ACES white point to assumed observer adapted white point
    XYZ = mult_f3_f33( XYZ, D60_2_D65_CAT);

    // CIE XYZ to display primaries
    float rgb[3] = mult_f3_f44( XYZ, XYZ_2_DISPLAY_PRI_MAT);

  	// Handle out-of-gamut values
    // Clip values < 0 (i.e. projecting outside the display primaries)
    rgb = clamp_f3( rgb, 0., HALF_POS_INF);

    // Encode with ST2084 transfer function
    float outputCV[3] = Y_2_ST2084_f3( rgb);

    rOut = outputCV[0];
    gOut = outputCV[1];
    bOut = outputCV[2];
    aOut = aIn;
}