
// <ACEStransformID>ODT.ARRI.Samsung_UN65JS9500F_PQ_1000nits.a1.0.0</ACEStransformID>
// <ACESuserName>ACES 1.0 Output - ARRI's Samsung UN65JS9500F PQ (1000 nits)</ACESuserName>

// 
// Output Device Transform - ARRI Burbank Samsung UN65JS9500F PQ (1000 cd/m^2)
//

//
// Summary :
//  This transform is intended for mapping OCES onto a particular HDR display,
//  a Samsung 65" UN65JS9500F used at ARRI Burbank. As measured by Joe Kane on 4/9/15,
//  the primaries and white point read as follows:
//
//  CIE 1931 chromaticities:  x         y         Y
//              Red:          0.6742    0.3107
//              Green:        0.2631    0.6494
//              Blue:         0.1521    0.0530
//              White:        0.3056    0.3274   1019 cd/m^2
//
//  Also assumes a black level of 0.005 cd/m^2 and a dim surround.
//
// Display EOTF :
//  The reference electro-optical transfer function specified in SMPTE ST 
//  2084-2014. The Samsung appears to use legal-range (what ST 2084 calls
// 'narrow range' in section 8.7) encoding for its HDMI interface.
//
// Assumed observer adapted white point:
//         CIE 1931 chromaticities:    x            y
//                                     0.3056       0.3274
// Or in other words, the observer is expected to be fullly adapted to the display white point.
//
// Viewing Environment:
//  This ODT is designed for a viewing environment more typically associated 
//  with video mastering.
//

import "ACESlib.Utilities";
import "ACESlib.Transform_Common";
import "ACESlib.ODT_Common";
import "ACESlib.Tonescales";

/* --- ODT Parameters --- */
const Chromaticities ARRI_Burbank_Samsung_PRI =
{
  { 0.6742,  0.3107},
  { 0.2631,  0.6494},
  { 0.1521,  0.0530},
  { 0.3056,  0.3274}
};

const Chromaticities DISPLAY_PRI = ARRI_Burbank_Samsung_PRI;
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
    output varying float aOut
)
{
    float oces[3] = { rIn, gIn, bIn};

  // OCES to RGB rendering space
    float rgbPre[3] = mult_f3_f44( oces, AP0_2_AP1_MAT);

  // Apply the tonescale independently in rendering-space RGB
    float rgbPost[3];
    rgbPost[0] = segmented_spline_c9_fwd( rgbPre[0], ODT_1000nits);
    rgbPost[1] = segmented_spline_c9_fwd( rgbPre[1], ODT_1000nits);
    rgbPost[2] = segmented_spline_c9_fwd( rgbPre[2], ODT_1000nits);

  // Convert to display primary encoding
    // Rendering space RGB to XYZ
    float XYZ[3] = mult_f3_f44( rgbPost, AP1_2_XYZ_MAT);

    // CIE XYZ to display primaries
    float rgb[3] = mult_f3_f44( XYZ, XYZ_2_DISPLAY_PRI_MAT);
    
  // Handle out-of-gamut values
    // Clip values < 0 (i.e. projecting outside the display primaries)
    rgb = clamp_f3( rgb, 0., HALF_POS_INF);    

  // Encode with PQ transfer function
    float outputCV[3] = fullRange_to_smpteRange_f3(Y_2_ST2084_f3( rgb));
  
    rOut = outputCV[0];
    gOut = outputCV[1];
    bOut = outputCV[2];
    aOut = aIn;
}