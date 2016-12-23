
// <ACEStransformID>ODT.Academy.P3DCI_48nits_D65sim.a1.0.3</ACEStransformID>
// <ACESuserName>ACES 1.0 Output - P3-DCI (D65 sim.)</ACESuserName>
// Created by SHED 2016-08-25

// 
// Output Device Transform - P3-DCI (D65 Simulation)
//

//
// Summary :
//  This transform is intended for mapping OCES onto a P3 digital cinema 
//  projector that is calibrated to a DCI white point at 48 cd/m^2. The assumed 
//  observer adapted white is D65, and the viewing environment is that of a dark
//  theater. 
//
// Device Primaries : 
//  CIE 1931 chromaticities:  x         y         Y
//              Red:          0.68      0.32
//              Green:        0.265     0.69
//              Blue:         0.15      0.06
//              White:        0.314     0.351     48 cd/m^2
//
// Display EOTF :
//  Gamma: 2.6
//
// Assumed observer adapted white point (D65):
//         CIE 1931 chromaticities:    x            y
//                                     0.3127       0.3290
//
// Viewing Environment:
//  Environment specified in SMPTE RP 431-2-2007
//



import "ACESlib.Utilities";
import "ACESlib.Transform_Common";
import "ACESlib.ODT_Common";
import "ACESlib.Tonescales";



/* --- ODT Parameters --- */
const Chromaticities DISPLAY_PRI = P3DCI_PRI;
const float XYZ_2_DISPLAY_PRI_MAT[4][4] = XYZtoRGB( DISPLAY_PRI, 1.0);

const float DISPGAMMA = 2.6; 

// Rolloff white settings for P3DCI (same as P3DCI_48nits ODT)
const float NEW_WHT = 0.918;
const float ROLL_WIDTH = 0.5;

// SCALE recalculated to take into account additional D60->D65 Bradford transform
const float SCALE = 0.8691606769 / 0.918; // previously 0.96;

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
    rgbPost[0] = segmented_spline_c9_fwd( rgbPre[0]);
    rgbPost[1] = segmented_spline_c9_fwd( rgbPre[1]);
    rgbPost[2] = segmented_spline_c9_fwd( rgbPre[2]);

    // Scale luminance to linear code value
    float linearCV[3];
    linearCV[0] = Y_2_linCV( rgbPost[0], CINEMA_WHITE, CINEMA_BLACK);
    linearCV[1] = Y_2_linCV( rgbPost[1], CINEMA_WHITE, CINEMA_BLACK);
    linearCV[2] = Y_2_linCV( rgbPost[2], CINEMA_WHITE, CINEMA_BLACK);

    // --- Compensate for different white point being darker  --- //

    // Roll off highlights to avoid need for as much scaling
    linearCV[0] = roll_white_fwd( linearCV[0], NEW_WHT, ROLL_WIDTH);
    linearCV[1] = roll_white_fwd( linearCV[1], NEW_WHT, ROLL_WIDTH);
    linearCV[2] = roll_white_fwd( linearCV[2], NEW_WHT, ROLL_WIDTH);

    // Scale and clamp white to avoid casted highlights due to D65 simulation
    linearCV[0] = min( linearCV[0], NEW_WHT) * SCALE;
    linearCV[1] = min( linearCV[1], NEW_WHT) * SCALE;
    linearCV[2] = min( linearCV[2], NEW_WHT) * SCALE;

    // Convert to display primary encoding
    // Rendering space RGB to XYZ
    float XYZ[3] = mult_f3_f44( linearCV, AP1_2_XYZ_MAT);

    // Apply CAT from ACES white point to assumed observer adapted white point
    // (map D60 to D65)
    XYZ = mult_f3_f33( XYZ, D60_2_D65_CAT);

    // CIE XYZ to display primaries
    linearCV = mult_f3_f44( XYZ, XYZ_2_DISPLAY_PRI_MAT);

    // Handle out-of-gamut values
    // Clip values < 0 or > 1 (i.e. projecting outside the display primaries)
    linearCV = clamp_f3( linearCV, 0., 1.);
  
    // Encode linear code values with transfer function
    float outputCV[3] = pow_f3( linearCV, 1./ DISPGAMMA);
  
    rOut = outputCV[0];
    gOut = outputCV[1];
    bOut = outputCV[2];
    aOut = aIn;
}
