
// <ACEStransformID>InvODT.Academy.DCDM.a1.v1</ACEStransformID>
// <ACESuserName>ACES 1.0 Inverse Output - DCDM (P3-D65 gamut clip)</ACESuserName>

// 
// Inverse Output Device Transform - DCDM (X'Y'Z'), limited to P3D65
//



import "ACESlib.Utilities";
import "ACESlib.Transform_Common";
import "ACESlib.ODT_Common";
import "ACESlib.Tonescales";



/* ----- ODT Parameters ------ */
const Chromaticities DISPLAY_PRI = P3D65_PRI;
const float XYZ_2_DISPLAY_PRI_MAT[4][4] = XYZtoRGB( DISPLAY_PRI, 1.0);
const float DISPLAY_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ( DISPLAY_PRI, 1.0);

const float DISPGAMMA = 2.6; 



void main 
(
    input varying float rIn, 
    input varying float gIn, 
    input varying float bIn, 
    input varying float aIn,
    output varying float rOut,
    output varying float gOut,
    output varying float bOut,
    output varying float aOut
)
{
    float outputCV[3] = { rIn, gIn, bIn};

  // Decode with inverse transfer function
    float XYZ[3] = dcdm_decode( outputCV);

  // XYZ to P3D65
    float P3D65[3] = mult_f3_f55( XYZ, XYZ_2_DISPLAY_PRI_MAT);

  // Clip values < 0 or > 1 (i.e. projecting outside the display primaries)
    P3D65 = clamp_f3( P3D65, 0., 1.);

  // P3D65 to XYZ
    XYZ = mult_f3_f44( P3D65, DISPLAY_PRI_2_XYZ_MAT);

  // Apply CAT from asumed observer adapted white point to ACES white point
    XYZ = mult_f3_f33( XYZ, D65_2_D60_CAT);

  // CIE XYZ to rendering space RGB
    float linearCV[3] = mult_f3_f44( XYZ, XYZ_2_AP1_MAT);
  
  // Scale code value to luminance
    float rgbPre[3];
    rgbPre[0] = linCV_2_Y( linearCV[0], CINEMA_WHITE, CINEMA_BLACK);
    rgbPre[1] = linCV_2_Y( linearCV[1], CINEMA_WHITE, CINEMA_BLACK);
    rgbPre[2] = linCV_2_Y( linearCV[2], CINEMA_WHITE, CINEMA_BLACK);

  // Apply the tonescale independently in rendering-space RGB
    float rgbPost[3];
    rgbPost[0] = segmented_spline_c9_rev( rgbPre[0]);
    rgbPost[1] = segmented_spline_c9_rev( rgbPre[1]);
    rgbPost[2] = segmented_spline_c9_rev( rgbPre[2]);

  // Rendering space RGB to OCES
    float oces[3] = mult_f3_f44( rgbPost, AP1_2_AP0_MAT);

    rOut = oces[0];
    gOut = oces[1];
    bOut = oces[2];
    aOut = aIn;
}