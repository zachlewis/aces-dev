
// <ACEStransformID>ACEScsc.ARRI.AWG_to_ACES.a1.v1</ACEStransformID>
// <ACESuserName>ALEXA Wide Gamut to ACES2065-1</ACESuserName>

//
// ACES Color Space Conversion - ALEXA Wide Gamut to ACES
//
// converts ALEXA Wide Gamut to 
//          ACES2065-1 (AP0 w/ linear encoding)
//


const float AWG_to_AP0_MAT[4][4] =
   {{  0.680206,   0.085415,   0.002057,   0.0},
    {  0.236137,   1.017471,  -0.062563,   0.0},
    {  0.083658,  -0.102866,   1.060506,   0.0},
    {  0.0,        0.0,        0.0,        1.0}};

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
    float rgbIn[3] = { rIn, gIn, bIn };
    float rgbOut[3] = mult_f3_f44( rgbIn, AWG_to_AP0_MAT);

    rOut = rgbOut[0];
    gOut = rgbOut[1];
    bOut = rgbOut[2];
    aOut = 1.0;
}

