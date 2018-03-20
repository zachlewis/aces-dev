import "ACESlib.Transform_Common";
import "ACESlib.RRT_Common";
import "ACESlib.ODT_Common";
import "ACESlib.SSTS";



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
    float Y_MIN,
    float Y_MID,
    float Y_MAX,    
    Chromaticities DISPLAY_PRI,
    Chromaticities LIMITING_PRI,
    int EOTF,  
    int SURROUND,
    bool STRETCH_BLACK = true,
    bool D60_SIM = false,
    bool LEGAL_RANGE = false
)
{
    float XYZ_2_DISPLAY_PRI_MAT[4][4] = XYZtoRGB( DISPLAY_PRI, 1.0);

    // NOTE: This is a bit of a hack - probably a more direct way to do this.
    // Fix in future version
    TsParams PARAMS_DEFAULT = init_TsParams( Y_MIN, Y_MAX);
    float expShift = log2(inv_ssts(Y_MID, PARAMS_DEFAULT))-log2(0.18);
    TsParams PARAMS = init_TsParams( Y_MIN, Y_MAX, expShift);

    // RRT sweeteners
    float rgbPre[3] = rrt_sweeteners( in);

    // Apply the tonescale independently in rendering-space RGB
    float rgbPost[3] = ssts_f3( rgbPre, PARAMS);

    // At this point data encoded AP1, scaled absolute luminance (cd/m^2)

    // Scale to linear code value
//     if (EOTF != 0) {  // ST-2084 (PQ)
//         rgbPost = Y_2_linCV_f3( rgbPost, Y_MAX, Y_MIN);
//     }
    float linearCV[3] = Y_2_linCV_f3( rgbPost, Y_MAX, Y_MIN);
    
    // Rendering primaries to XYZ
    float XYZ[3] = mult_f3_f44( linearCV, AP1_2_XYZ_MAT);

    // Apply gamma adjustment to compensate for dim surround
    // NOTE: This section would only apply for SDR. This is a placeholder block.
    // TOD0: Come up with new surround compensation algorithm, applicable across
    // all dynamic ranges and supporting dark/dim/normal surround.
//     if (SURROUND == 1) {
//         print( "\nDim surround\n");
//         XYZ = dark_to_dim( XYZ);
//     }

    // Gamut limit to limiting primaries
    // NOTE: Would be nice to just say
    //    if (LIMITING_PRI != DISPLAY_PRI)
    // but you can't because Chromaticities do not work with bool comparison operator
    // For now, limit no matter what.
    XYZ = limit_to_primaries( XYZ, LIMITING_PRI); 
    
    // Apply CAT from ACES white point to assumed observer adapted white point
    // TODO: Needs to expand from just supporting D60 sim to allow for any
    // observer adapted white point.
    if (D60_SIM == false) {
        if ((DISPLAY_PRI.white[0] != AP0.white[0]) &
            (DISPLAY_PRI.white[1] != AP0.white[1])) {
            float CAT[3][3] = calculate_cat_matrix( AP0.white, DISPLAY_PRI.white);
            XYZ = mult_f3_f33( XYZ, D60_2_D65_CAT);
        }
    }

    // CIE XYZ to display encoding primaries
    linearCV = mult_f3_f44( XYZ, XYZ_2_DISPLAY_PRI_MAT);

    // Scale to avoid clipping when device calibration is different from D60. 
    // To simulate D60, unequal code values are sent to the display.
    // TODO: Needs to expand from just supporting D60 sim to allow for any
    // observer adapted white point.
    if (D60_SIM == true) {
        /* TODO: The scale requires calling itself. Scale is same no matter the luminance.
           Currently precalculated for D65, DCI. If DCI, roll_white_fwd is used also.
           This needs a more complex algorithm to handle all cases.
        */
        float SCALE = 1.0;
        if ((DISPLAY_PRI.white[0] == 0.3127) & 
            (DISPLAY_PRI.white[1] == 0.329)) { // D65
                SCALE = 0.96362;
        } 
        else if ((DISPLAY_PRI.white[0] == 0.314) & 
                 (DISPLAY_PRI.white[1] == 0.351)) { // DCI
                linearCV[0] = roll_white_fwd( linearCV[0], 0.918, 0.5);
                linearCV[1] = roll_white_fwd( linearCV[1], 0.918, 0.5);
                linearCV[2] = roll_white_fwd( linearCV[2], 0.918, 0.5);
                SCALE = 0.96;                
        } 
        linearCV = mult_f_f3( SCALE, linearCV);
    }


    // Clip values < 0 (i.e. projecting outside the display primaries)
    // NOTE: P3 red and values close to it fall outside of Rec.2020 green-red 
    // boundary
    linearCV = clamp_f3( linearCV, 0., HALF_POS_INF);

    // EOTF
    // 0: ST-2084 (PQ)
    // 1: BT.1886 (Rec.709/2020 settings)
    // 2: sRGB (mon_curve w/ presets)
    //    moncurve_r with gamma of 2.4 and offset of 0.055 matches the EOTF found in IEC 61966-2-1:1999 (sRGB)
    // 3: gamma 2.6
    // 4: linear (no EOTF)
    // 5: HLG
    float outputCV[3];
    if (EOTF == 0) {  // ST-2084 (PQ)
        // NOTE: This is a kludgy way of ensuring a PQ code value of 0. Ideally,
        // luminance would map directly to code value, but colorists don't like
        // that. Might just need the tonescale to go darker so that darkest
        // values through the tone scale quantize to code value of 0.
        if (STRETCH_BLACK == true) {
            outputCV = Y_2_ST2084_f3( clamp_f3( linCV_2_Y_f3(linearCV, Y_MAX, 0.0), 0.0, HALF_POS_INF) );
        } else {
            outputCV = Y_2_ST2084_f3( linCV_2_Y_f3(linearCV, Y_MAX, Y_MIN) );        
        }
    } else if (EOTF == 1) { // BT.1886 (Rec.709/2020 settings)
        outputCV = bt1886_r_f3( linearCV, 2.4, 1.0, 0.0);
    } else if (EOTF == 2) { // sRGB (mon_curve w/ presets)
        outputCV = moncurve_r_f3( linearCV, 2.4, 0.055);
    } else if (EOTF == 3) { // gamma 2.6
        outputCV = pow_f3( linearCV, 1./2.6);
    } else if (EOTF == 4) { // linear
        outputCV = linCV_2_Y_f3(linearCV, Y_MAX, Y_MIN);
    } else if (EOTF == 5) { // HLG
        // NOTE: HLG just maps ST.2084 output to HLG encoding. 
        // TODO: Restructure if/else tree to minimize this redundancy.
        if (STRETCH_BLACK == true) {
            outputCV = Y_2_ST2084_f3( clamp_f3( linCV_2_Y_f3(linearCV, Y_MAX, 0.0), 0.0, HALF_POS_INF) );
        }
        else {
            outputCV = Y_2_ST2084_f3( linCV_2_Y_f3(linearCV, Y_MAX, Y_MIN) );        
        }
        outputCV = ST2084_2_HLG_1000nits( outputCV);
    }

    return outputCV;    
}

float[3] invOutputTransform
(
    float in[3],
    float Y_MIN,
    float Y_MID,
    float Y_MAX,    
    Chromaticities DISPLAY_PRI,
    Chromaticities LIMITING_PRI,
    int EOTF,  
    int SURROUND,
    bool STRETCH_BLACK = true,
    bool D60_SIM = false,
    bool LEGAL_RANGE = false
)
{
    float DISPLAY_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ( DISPLAY_PRI, 1.0);

    // NOTE: This is a bit of a hack - probably a more direct way to do this.
    // Update in accordance with forward algorithm.
    TsParams PARAMS_DEFAULT = init_TsParams( Y_MIN, Y_MAX);
    float expShift = log2(inv_ssts(Y_MID, PARAMS_DEFAULT))-log2(0.18);
    TsParams PARAMS = init_TsParams( Y_MIN, Y_MAX, expShift);

    float outputCV[3] = in;
    // Inverse EOTF
    // 0: ST-2084 (PQ)
    // 1: BT.1886 (Rec.709/2020 settings)
    // 2: sRGB (mon_curve w/ presets)
    //    moncurve_r with gamma of 2.4 and offset of 0.055 matches the EOTF found in IEC 61966-2-1:1999 (sRGB)
    // 3: gamma 2.6
    // 4: linear (no EOTF)
    // 5: HLG
    float linearCV[3];
    if (EOTF == 0) {  // ST-2084 (PQ)
        if (STRETCH_BLACK == true) {
            linearCV = Y_2_linCV_f3( ST2084_2_Y_f3( outputCV), Y_MAX, 0.);
        } else {
            linearCV = Y_2_linCV_f3( ST2084_2_Y_f3( outputCV), Y_MAX, Y_MIN);
        }
    } else if (EOTF == 1) { // BT.1886 (Rec.709/2020 settings)
        linearCV = bt1886_f_f3( outputCV, 2.4, 1.0, 0.0);
    } else if (EOTF == 2) { // sRGB (mon_curve w/ presets)
        linearCV = moncurve_f_f3( outputCV, 2.4, 0.055);
    } else if (EOTF == 3) { // gamma 2.6
        linearCV = pow_f3( outputCV, 2.6);
    } else if (EOTF == 4) { // linear
        linearCV = Y_2_linCV_f3( outputCV, Y_MAX, Y_MIN);
    } else if (EOTF == 5) { // HLG
        outputCV = HLG_2_ST2084_1000nits( outputCV);
        if (STRETCH_BLACK == true) {
            linearCV = Y_2_linCV_f3( ST2084_2_Y_f3( outputCV), Y_MAX, 0.);
        } else {
            linearCV = Y_2_linCV_f3( ST2084_2_Y_f3( outputCV), Y_MAX, Y_MIN);
        }
    }

    // Un-scale
    if (D60_SIM == true) {
        /* TODO: The scale requires calling itself. Need an algorithm for this.
            Scale is same no matter the luminance.
            Currently using precalculated values for D65, DCI.
            If DCI, roll_white_fwd is used also.
        */
        float SCALE = 1.0;
        if ((DISPLAY_PRI.white[0] == 0.3127) & 
            (DISPLAY_PRI.white[1] == 0.329)) { // D65
                SCALE = 0.96362;
                linearCV = mult_f_f3( 1./SCALE, linearCV);
        } 
        else if ((DISPLAY_PRI.white[0] == 0.314) & 
                 (DISPLAY_PRI.white[1] == 0.351)) { // DCI
                SCALE = 0.96;                
                linearCV[0] = roll_white_rev( linearCV[0]/SCALE, 0.918, 0.5);
                linearCV[1] = roll_white_rev( linearCV[1]/SCALE, 0.918, 0.5);
                linearCV[2] = roll_white_rev( linearCV[2]/SCALE, 0.918, 0.5);
        } 

    }    

    // Encoding primaries to CIE XYZ
    float XYZ[3] = mult_f3_f44( linearCV, DISPLAY_PRI_2_XYZ_MAT);

    // Undo CAT from assumed observer adapted white point to ACES white point
    if (D60_SIM == false) {
        if ((DISPLAY_PRI.white[0] != AP0.white[0]) &
            (DISPLAY_PRI.white[1] != AP0.white[1])) {
            float CAT[3][3] = calculate_cat_matrix( AP0.white, DISPLAY_PRI.white);
            XYZ = mult_f3_f33( XYZ, invert_f33(D60_2_D65_CAT) );
        }
    }

    // Apply gamma adjustment to compensate for dim surround
//     if (SURROUND == 1) {
//         print( "\nDim surround\n");
//         XYZ = dim_to_dark( XYZ);
//     }

    // XYZ to rendering primaries
    linearCV = mult_f3_f44( XYZ, XYZ_2_AP1_MAT);

    float rgbPost[3] = linCV_2_Y_f3( linearCV, Y_MAX, Y_MIN);

    // Apply the inverse tonescale independently in rendering-space RGB
    float rgbPre[3] = inv_ssts_f3( rgbPost, PARAMS);

    // RRT sweeteners
    float aces[3] = inv_rrt_sweeteners( rgbPre);

    return aces;
}