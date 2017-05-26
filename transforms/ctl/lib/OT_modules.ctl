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

    // AP1, absolute
    
    // 


    // Scale to linear code value
//     if (OT_PARAMS.eotf != 0) {  // ST-2084 (PQ)
//         rgbPost = Y_2_linCV_f3( rgbPost, OT_PARAMS.Y_max, OT_PARAMS.Y_min);
//     }
    float linearCV[3] = Y_2_linCV_f3( rgbPost, OT_PARAMS.Y_max, OT_PARAMS.Y_min);
    
    // Scale to avoid clipping when device calibration is different from D60. To simulate 
    // D60, unequal code values are sent to the display. 
    if (OT_PARAMS.d60sim == true) {
        /* TODO: The scale requires calling itself. Scale is same no matter the luminance.
           Currently precalculated for D65, DCI, and E. If DCI, roll_white_fwd is used also.
        */
        print( "\n", OT_PARAMS.encoding_primaries.white[0], "\n", OT_PARAMS.encoding_primaries.white[1], "\n");
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
        else if ((OT_PARAMS.encoding_primaries.white[0] == 1/3.) & 
                 (OT_PARAMS.encoding_primaries.white[1] == 1/3.)) { // E
                SCALE = 0.99126;
        } 
        linearCV = mult_f_f3( SCALE, linearCV);
    }
    
    // Convert to mastering primaries encoding and limit gamut
    // Rendering space RGB to XYZ
    float XYZ[3] = mult_f3_f44( linearCV, AP1_2_XYZ_MAT);

    // Apply CAT from ACES white point to assumed observer adapted white point
    if (OT_PARAMS.d60sim == false) {
        if ((OT_PARAMS.encoding_primaries.white[0] != AP0.white[0]) &
            (OT_PARAMS.encoding_primaries.white[1] != AP0.white[1])) {
            float CAT[3][3] = calculate_cat_matrix( AP0.white, OT_PARAMS.encoding_primaries.white);
            print( "\nCAT applied.\n");
            XYZ = mult_f3_f33( XYZ, D60_2_D65_CAT);
        }
    }

    // Limit gamut to mastering primaries
    XYZ = limit_to_primaries( XYZ, OT_PARAMS.limiting_primaries); 

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
        outputCV = Y_2_ST2084_f3( linCV_2_Y_f3(linearCV, OT_PARAMS.Y_max, OT_PARAMS.Y_min) );
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