import "ACESlib.Transform_Common";
import "ACESlib.RRT_Common";
import "ACESlib.ODT_Common";
import "ACESlib.SSTS";


struct OutputParameters
{
    float Y_min; float Y_mid; float Y_max;
    Chromaticities encoding_primaries;
    Chromaticities limiting_primaries;
    int eotf;  // 0: ST-2084 (PQ), 1: BT.1886 (Rec.709/2020 settings), 2: sRGB (mon_curve w/ presets), 3: gamma 2.6
    int surround_type; // 0: dark, 1: dim
    bool forceBlack; //
    bool d60sim;
    bool legal_range;
};



float[3] limit_to_primaries
( 
    float XYZ[3], 
    Chromaticities LIMITING_PRI
)
{
    float XYZ_2_LIMITING_PRI_MAT[4][4] = XYZtoRGB( LIMITING_PRI, 1.0);
    float LIMITING_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ( LIMITING_PRI, 1.0);

    // XYZ to limiting primaries
    float rgb[3] = mult_f3_f44( XYZ, XYZ_2_LIMITING_PRI_MAT);

    // Clip any values outside the limiting primaries
    float limitedRgb[3] = clamp_f3( rgb, 0., 1.);
    
    // Convert limited RGB to XYZ
    return mult_f3_f44( limitedRgb, LIMITING_PRI_2_XYZ_MAT);
}


float[3] dark_to_dim( float XYZ[3])
{
  float xyY[3] = XYZ_2_xyY(XYZ);
  xyY[2] = clamp( xyY[2], 0., HALF_POS_INF);
  xyY[2] = pow( xyY[2], DIM_SURROUND_GAMMA);
  return xyY_2_XYZ(xyY);
}

float[3] dim_to_dark( float XYZ[3])
{
  float xyY[3] = XYZ_2_xyY(XYZ);
  xyY[2] = clamp( xyY[2], 0., HALF_POS_INF);
  xyY[2] = pow( xyY[2], 1./DIM_SURROUND_GAMMA);
  return xyY_2_XYZ(xyY);
}

float[3] outputTransform
(
    float in[3],
    OutputParameters OT_PARAMS
)
{
    float XYZ_2_DISPLAY_PRI_MAT[4][4] = XYZtoRGB( OT_PARAMS.encoding_primaries, 1.0);

    // NOTE: This is a bit of a hack - probably a more direct way to do this.
    TsParams PARAMS_DEFAULT = init_TsParams( OT_PARAMS.Y_min, OT_PARAMS.Y_max);
    float expShift = log2(inv_ssts(OT_PARAMS.Y_mid, PARAMS_DEFAULT))-log2(0.18);
    TsParams PARAMS = init_TsParams( OT_PARAMS.Y_min, OT_PARAMS.Y_max, expShift);

    // RRT sweeteners
    float rgbPre[3] = rrt_sweeteners( in);

    // Apply the tonescale independently in rendering-space RGB
    float rgbPost[3] = ssts_f3( rgbPre, PARAMS);

    // At this point AP1, absolute luminance

    // Scale to linear code value
//     if (OT_PARAMS.eotf != 0) {  // ST-2084 (PQ)
//         rgbPost = Y_2_linCV_f3( rgbPost, OT_PARAMS.Y_max, OT_PARAMS.Y_min);
//     }
    float linearCV[3] = Y_2_linCV_f3( rgbPost, OT_PARAMS.Y_max, OT_PARAMS.Y_min);
    
    // Rendering primaries to XYZ
    float XYZ[3] = mult_f3_f44( linearCV, AP1_2_XYZ_MAT);

    // Apply gamma adjustment to compensate for dim surround
    if (OT_PARAMS.surround_type == 1) {
        print( "\nDim surround\n");
        XYZ = dark_to_dim( XYZ);
    }

    // Gamut limit to mastering primaries
//     if (OT_PARAMS.limiting_primaries != OT_PARAMS.encoding_primaries) {
//         XYZ = limit_to_primaries( XYZ, OT_PARAMS.limiting_primaries); 
//     }
    
    // Apply CAT from ACES white point to assumed observer adapted white point
    if (OT_PARAMS.d60sim == false) {
        if ((OT_PARAMS.encoding_primaries.white[0] != AP0.white[0]) &
            (OT_PARAMS.encoding_primaries.white[1] != AP0.white[1])) {
            float CAT[3][3] = calculate_cat_matrix( AP0.white, OT_PARAMS.encoding_primaries.white);
//             print( "\nCAT applied.\n");
            XYZ = mult_f3_f33( XYZ, D60_2_D65_CAT);
        }
    }

    // CIE XYZ to encoding primaries
    linearCV = mult_f3_f44( XYZ, XYZ_2_DISPLAY_PRI_MAT);

    // Scale to avoid clipping when device calibration is different from D60. To simulate 
    // D60, unequal code values are sent to the display. 
    if (OT_PARAMS.d60sim == true) {
        /* TODO: The scale requires calling itself. Scale is same no matter the luminance.
           Currently precalculated for D65, DCI, and E. If DCI, roll_white_fwd is used also.
        */
//         print( "\n", OT_PARAMS.encoding_primaries.white[0], "\n", OT_PARAMS.encoding_primaries.white[1], "\n");
        float SCALE = 1.0;
        if ((OT_PARAMS.encoding_primaries.white[0] == 0.3127) & 
            (OT_PARAMS.encoding_primaries.white[1] == 0.329)) { // D65
                SCALE = 0.96362;
        } 
        else if ((OT_PARAMS.encoding_primaries.white[0] == 0.314) & 
                 (OT_PARAMS.encoding_primaries.white[1] == 0.351)) { // DCI
                linearCV[0] = roll_white_fwd( linearCV[0], 0.918, 0.5);
                linearCV[1] = roll_white_fwd( linearCV[1], 0.918, 0.5);
                linearCV[2] = roll_white_fwd( linearCV[2], 0.918, 0.5);
                SCALE = 0.96;                
        } 
        linearCV = mult_f_f3( SCALE, linearCV);
    }


    // Clip values < 0 (i.e. projecting outside the display primaries)
    // Note: P3 red and values close to it fall outside of Rec.2020 green-red boundary
    linearCV = clamp_f3( linearCV, 0., HALF_POS_INF);

    // EOTF
    // 0: ST-2084 (PQ), 
    // 1: BT.1886 (Rec.709/2020 settings)
    // 2: sRGB (mon_curve w/ presets)
    //    moncurve_r with gamma of 2.4 and offset of 0.055 matches the EOTF found in IEC 61966-2-1:1999 (sRGB)
    // 3: gamma 2.6
    // 4: linear (no EOTF)
    float outputCV[3];
    if (OT_PARAMS.eotf == 0) {  // ST-2084 (PQ)
        if (OT_PARAMS.forceBlack == true) {
            outputCV = Y_2_ST2084_f3( clamp_f3( linCV_2_Y_f3(linearCV, OT_PARAMS.Y_max, 0.0), 0.0, HALF_POS_INF) );
        }
        else {
            outputCV = Y_2_ST2084_f3( linCV_2_Y_f3(linearCV, OT_PARAMS.Y_max, OT_PARAMS.Y_min) );        
        }
//         outputCV = Y_2_ST2084_f3( linearCV);
    } else if (OT_PARAMS.eotf == 1) { // BT.1886 (Rec.709/2020 settings)
        outputCV = bt1886_r_f3( linearCV, 2.4, 1.0, 0.0);
    } else if (OT_PARAMS.eotf == 2) { // sRGB (mon_curve w/ presets)
        outputCV = moncurve_r_f3( linearCV, 2.4, 0.055);
    } else if (OT_PARAMS.eotf == 3) { // gamma 2.6
        outputCV = pow_f3( linearCV, 1./2.6);
    } else if (OT_PARAMS.eotf == 4) { // linear
        outputCV = linCV_2_Y_f3(linearCV, OT_PARAMS.Y_max, OT_PARAMS.Y_min);
    }

    return outputCV;    
}

float[3] invOutputTransform
(
    float in[3],
    OutputParameters OT_PARAMS
)
{

    // NOTE: This is a bit of a hack - probably a more direct way to do this.
    TsParams PARAMS_DEFAULT = init_TsParams( OT_PARAMS.Y_min, OT_PARAMS.Y_max);
    float expShift = log2(inv_ssts(OT_PARAMS.Y_mid, PARAMS_DEFAULT))-log2(0.18);
    TsParams PARAMS = init_TsParams( OT_PARAMS.Y_min, OT_PARAMS.Y_max, expShift);

    float DISPLAY_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ( OT_PARAMS.encoding_primaries, 1.0);




    float outputCV[3] = in;
    // Inverse EOTF
    // 0: ST-2084 (PQ), 
    // 1: BT.1886 (Rec.709/2020 settings)
    // 2: sRGB (mon_curve w/ presets)
    //    moncurve_r with gamma of 2.4 and offset of 0.055 matches the EOTF found in IEC 61966-2-1:1999 (sRGB)
    // 3: gamma 2.6
    // 4: linear (no EOTF)
    float linearCV[3];
    if (OT_PARAMS.eotf == 0) {  // ST-2084 (PQ)
        if (OT_PARAMS.forceBlack == true) {
            linearCV = Y_2_linCV_f3( ST2084_2_Y_f3( outputCV), OT_PARAMS.Y_max, 0.);
        }
        else {
            linearCV = Y_2_linCV_f3( ST2084_2_Y_f3( outputCV), OT_PARAMS.Y_max, OT_PARAMS.Y_min);
        }
    } else if (OT_PARAMS.eotf == 1) { // BT.1886 (Rec.709/2020 settings)
        linearCV = bt1886_f_f3( outputCV, 2.4, 1.0, 0.0);
    } else if (OT_PARAMS.eotf == 2) { // sRGB (mon_curve w/ presets)
        linearCV = moncurve_f_f3( outputCV, 2.4, 0.055);
    } else if (OT_PARAMS.eotf == 3) { // gamma 2.6
        linearCV = pow_f3( outputCV, 2.6);
    } else if (OT_PARAMS.eotf == 4) { // linear
        linearCV = Y_2_linCV_f3( outputCV, OT_PARAMS.Y_max, OT_PARAMS.Y_min);
    }

    // Un-scale
    if (OT_PARAMS.d60sim == true) {
        /* TODO: The scale requires calling itself. Need an algorithm for this.
            Scale is same no matter the luminance.
            Currently using precalculated values for D65, DCI, and E.
            If DCI, roll_white_fwd is used also.
        */
        float SCALE = 1.0;
        if ((OT_PARAMS.encoding_primaries.white[0] == 0.3127) & 
            (OT_PARAMS.encoding_primaries.white[1] == 0.329)) { // D65
                SCALE = 0.96362;
                linearCV = mult_f_f3( 1./SCALE, linearCV);
        } 
        else if ((OT_PARAMS.encoding_primaries.white[0] == 0.314) & 
                 (OT_PARAMS.encoding_primaries.white[1] == 0.351)) { // DCI
                SCALE = 0.96;                
                linearCV[0] = roll_white_rev( linearCV[0]/SCALE, 0.918, 0.5);
                linearCV[1] = roll_white_rev( linearCV[1]/SCALE, 0.918, 0.5);
                linearCV[2] = roll_white_rev( linearCV[2]/SCALE, 0.918, 0.5);
        } 

    }    

    // Encoding primaries to CIE XYZ
    float XYZ[3] = mult_f3_f44( linearCV, DISPLAY_PRI_2_XYZ_MAT);

    // Undo CAT from assumed observer adapted white point to ACES white point
    if (OT_PARAMS.d60sim == false) {
        if ((OT_PARAMS.encoding_primaries.white[0] != AP0.white[0]) &
            (OT_PARAMS.encoding_primaries.white[1] != AP0.white[1])) {
            float CAT[3][3] = calculate_cat_matrix( AP0.white, OT_PARAMS.encoding_primaries.white);
            XYZ = mult_f3_f33( XYZ, invert_f33(D60_2_D65_CAT) );
        }
    }

    // Apply gamma adjustment to compensate for dim surround
    if (OT_PARAMS.surround_type == 1) {
        print( "\nDim surround\n");
        XYZ = dim_to_dark( XYZ);
    }

    // XYZ to rendering primaries
    linearCV = mult_f3_f44( XYZ, XYZ_2_AP1_MAT);

    float rgbPre[3] = linCV_2_Y_f3( linearCV, OT_PARAMS.Y_max, OT_PARAMS.Y_min);

    // Apply the inverse tonescale independently in rendering-space RGB
    float rgbPost[3] = inv_ssts_f3( rgbPre, PARAMS);

    // RRT sweeteners
    float aces[3] = inv_rrt_sweeteners( rgbPost);
    return aces;
}