
// <ACEStransformID>LMT.Academy.Better_ARRIAlexa_blueHighlights.a1.0.1</ACEStransformID>
// <ACESuserName>ACES 1.0 - RRT</ACESuserName>

// 
// Look Modification Transform (LMT)
//
//   Input is ACES
//   Output is ACES
//



//
// LMT for fixing ARRI blue rendering
//

const float correctionMatrix[3][3] = {
  { 0.98373,  0.00753,  0.00018},
  {-0.01694,  0.87943, -0.00059},
  { 0.03320,  0.11304,  1.00041}
};

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
    float aces[3] = {rIn, gIn, bIn};

    float acesMod[3] = mult_f3_f33( aces, correctionMatrix);

    rOut = acesMod[0];
    gOut = acesMod[1];
    bOut = acesMod[2];
    aOut = aIn;
}