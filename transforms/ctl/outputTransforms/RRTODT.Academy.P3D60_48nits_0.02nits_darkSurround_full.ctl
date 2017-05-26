import "ACESlib.Utilities";
import "OT_modules";



const OutputParameters OT_PARAMS = 
{
    0.02, 4.8, 48.0,
    {{ 0.68000, 0.32000},{ 0.26500, 0.69000},{ 0.15000, 0.06000}, { 0.32168, 0.33767}},  // encoding primaries
    {{ 0.68000, 0.32000},{ 0.26500, 0.69000},{ 0.15000, 0.06000}, { 0.32168, 0.33767}},  // limiting primaries
    0,      // 0: ST-2084 (PQ), 1: BT.1886 (Rec.709/2020 settings), 2: sRGB (mon_curve w/ presets), 3: gamma 2.6
    0,      // 0: dark, 1: dim, 2, 2: normal
    false,  // D60_sim
    false   // smpte_range
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

    float outputCV[3] = outputTransform( aces, OT_PARAMS);

    rOut = outputCV[0];
    gOut = outputCV[1];
    bOut = outputCV[2];
    aOut = aIn;
}