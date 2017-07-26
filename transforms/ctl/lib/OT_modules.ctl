import "ACESlib.Transform_Common";
import "ACESlib.RRT_Common";
import "ACESlib.ODT_Common";
import "ssts";


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

struct OutputParameters_noTS
{
    Chromaticities encoding_primaries;
    Chromaticities limiting_primaries;
    int eotf;  // 0: ST-2084 (PQ), 1: BT.1886 (Rec.709/2020 settings), 2: sRGB (mon_curve w/ presets), 3: gamma 2.6
    int surround_type; // 0: dark, 1: dim
    bool forceBlack; //
    bool d60sim;
    bool legal_range;
};

struct OutputParameters_wPct
{
    float Y_min; float Y_mid; float Y_max;
    float pctLow; float pctHigh;
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
    Chromaticities PRI
)
{
    const float XYZ_2_LIMITING_PRI_MAT[4][4] = XYZtoRGB( PRI, 1.0);
    const float LIMITING_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ( PRI, 1.0);

    // XYZ to mastering primaries (i.e. the primaries to limit to)
    float limitRGB[3] = mult_f3_f44( XYZ, XYZ_2_LIMITING_PRI_MAT);

    // Clip any values outside the mastering primaries
    limitRGB = clamp_f3( limitRGB, 0., 1.);
    
    // Convert back to XYZ
    return mult_f3_f44( limitRGB, LIMITING_PRI_2_XYZ_MAT);
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

//     print( "ACESmin=",log2(PARAMS.Min.x/0.18),"\n");
//     print( "ACESmax=",log2(PARAMS.Max.x/0.18),"\n");    

    // RRT sweeteners
    float rgbPre[3] = rrt_sweeteners( in);

    // Apply the tonescale independently in rendering-space RGB
    float rgbPost[3] = ssts_f3( rgbPre, PARAMS);

    // AP1, absolute

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
    }

    // Un-scale
    if (OT_PARAMS.d60sim == true) {
        /* TODO: The scale requires calling itself. Scale is same no matter the luminance.
           Currently precalculated for D65, DCI, and E. If DCI, roll_white_fwd is used also.
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


float[3] outputTransform_wPct
(
    float in[3],
    OutputParameters_wPct OT_PARAMS
)
{
    float XYZ_2_DISPLAY_PRI_MAT[4][4] = XYZtoRGB( OT_PARAMS.encoding_primaries, 1.0);

    // NOTE: This is a bit of a hack - probably a more direct way to do this.
    TsParams PARAMS_DEFAULT = init_TsParams_wPct( OT_PARAMS.Y_min, OT_PARAMS.Y_max, OT_PARAMS.pctLow, OT_PARAMS.pctHigh);
    float expShift = log2(inv_ssts(OT_PARAMS.Y_mid, PARAMS_DEFAULT))-log2(0.18);
    TsParams PARAMS = init_TsParams_wPct( OT_PARAMS.Y_min, OT_PARAMS.Y_max, OT_PARAMS.pctLow, OT_PARAMS.pctHigh, expShift);

    // RRT sweeteners
    float rgbPre[3] = rrt_sweeteners( in);

    // Apply the tonescale independently in rendering-space RGB
    float rgbPost[3] = ssts_f3( rgbPre, PARAMS);

    // AP1, absolute


    // Scale to linear code value
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

    // Clip values < 0 (i.e. projecting outside the display primaries)
    // Note: P3 red and values close to it fall outside of Rec.2020 green-red boundary
    linearCV = clamp_f3( linearCV, 0., HALF_POS_INF);

    // EOTF
    // 0: ST-2084 (PQ), 
    // 1: BT.1886 (Rec.709/2020 settings)
    // 2: sRGB (mon_curve w/ presets)
    //    moncurve_r with gamma of 2.4 and offset of 0.055 matches the EOTF found in IEC 61966-2-1:1999 (sRGB)
    // 3: gamma 2.6
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
    }

    return outputCV;    
}


//     TsPoint MIN_PT = { lookup_ACESmin(minLum), minLum, 0.0};
//     TsPoint MID_PT = { 0.18, 4.8, 1.5};
//     TsPoint MAX_PT = { lookup_ACESmax(maxLum), maxLum, 0.0};
//     float cLow[5] = init_coefsLow( MIN_PT, MID_PT);
//     float cHigh[5] = init_coefsHigh( MID_PT, MAX_PT);
//     MIN_PT.x = shift(lookup_ACESmin(minLum),expShift);
//     MID_PT.x = shift(0.18,expShift);
//     MAX_PT.x = shift(lookup_ACESmax(maxLum),expShift);
// 
//     TsParams P = {
//         {MIN_PT.x, MIN_PT.y, MIN_PT.slope},
//         {MID_PT.x, MID_PT.y, MID_PT.slope},
//         {MAX_PT.x, MAX_PT.y, MAX_PT.slope},
//         {cLow[0], cLow[1], cLow[2], cLow[3], cLow[4], cLow[4]},
//         {cHigh[0], cHigh[1], cHigh[2], cHigh[3], cHigh[4], cHigh[4]}
//     };

float[3] outputTransform_wTsParams
(
    float in[3],
    OutputParameters_noTS OT_PARAMS,
    TsParams TS_PARAMS
)
{
    float XYZ_2_DISPLAY_PRI_MAT[4][4] = XYZtoRGB( OT_PARAMS.encoding_primaries, 1.0);

    // NOTE: This is a bit of a hack - probably a more direct way to do this.
//     TsParams PARAMS_DEFAULT = init_TsParams( OT_PARAMS.Y_min, OT_PARAMS.Y_max);
//     float expShift = log2(inv_ssts(OT_PARAMS.Y_mid, PARAMS_DEFAULT))-log2(0.18);
//     TsParams PARAMS = init_TsParams( OT_PARAMS.Y_min, OT_PARAMS.Y_max, expShift);
    float expShift = 0.73363; //log2(inv_ssts(TS_PARAMS.Mid.y, TS_PARAMS))-log2(0.18);
    TsParams PARAMS = {
        {shift(TS_PARAMS.Min.x,expShift), TS_PARAMS.Min.y, TS_PARAMS.Min.slope},
        {shift(TS_PARAMS.Mid.x,expShift), TS_PARAMS.Mid.y, TS_PARAMS.Mid.slope},
        {shift(TS_PARAMS.Max.x,expShift), TS_PARAMS.Max.y, TS_PARAMS.Max.slope},
        {TS_PARAMS.coefsLow[0], TS_PARAMS.coefsLow[1], TS_PARAMS.coefsLow[2], TS_PARAMS.coefsLow[3], TS_PARAMS.coefsLow[4], TS_PARAMS.coefsLow[4]},
        {TS_PARAMS.coefsHigh[0], TS_PARAMS.coefsHigh[1], TS_PARAMS.coefsHigh[2], TS_PARAMS.coefsHigh[3], TS_PARAMS.coefsHigh[4], TS_PARAMS.coefsHigh[4]}
    };

    // RRT sweeteners
    float rgbPre[3] = rrt_sweeteners( in);

    // Apply the tonescale independently in rendering-space RGB
    float rgbPost[3] = ssts_f3( rgbPre, PARAMS);

    // Scale to linear code value
    float linearCV[3] = Y_2_linCV_f3( rgbPost, TS_PARAMS.Max.y, TS_PARAMS.Min.y);
    
    // Rendering primaries to XYZ
    float XYZ[3] = mult_f3_f44( linearCV, AP1_2_XYZ_MAT);

    // Apply gamma adjustment to compensate for dim surround
    if (OT_PARAMS.surround_type == 1) {
        print( "\nDim surround\n");
        XYZ = dark_to_dim( XYZ);
    }

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

    // Clip values < 0 (i.e. projecting outside the display primaries)
    // Note: P3 red and values close to it fall outside of Rec.2020 green-red boundary
    linearCV = clamp_f3( linearCV, 0., HALF_POS_INF);

    // EOTF
    // 0: ST-2084 (PQ), 
    // 1: BT.1886 (Rec.709/2020 settings)
    // 2: sRGB (mon_curve w/ presets)
    //    moncurve_r with gamma of 2.4 and offset of 0.055 matches the EOTF found in IEC 61966-2-1:1999 (sRGB)
    // 3: gamma 2.6
    float outputCV[3];
    if (OT_PARAMS.eotf == 0) {  // ST-2084 (PQ)
        if (OT_PARAMS.forceBlack == true) {
            outputCV = Y_2_ST2084_f3( clamp_f3( linCV_2_Y_f3(linearCV, TS_PARAMS.Max.y, 0.0), 0.0, HALF_POS_INF) );
        }
        else {
            outputCV = Y_2_ST2084_f3( linCV_2_Y_f3(linearCV, TS_PARAMS.Max.y, TS_PARAMS.Min.y) );
        }
//         outputCV = Y_2_ST2084_f3( linearCV);
    } else if (OT_PARAMS.eotf == 1) { // BT.1886 (Rec.709/2020 settings)
        outputCV = bt1886_r_f3( linearCV, 2.4, 1.0, 0.0);
    } else if (OT_PARAMS.eotf == 2) { // sRGB (mon_curve w/ presets)
        outputCV = moncurve_r_f3( linearCV, 2.4, 0.055);
    } else if (OT_PARAMS.eotf == 3) { // gamma 2.6
        outputCV = pow_f3( linearCV, 1./2.6);
    }

    return outputCV;    
}