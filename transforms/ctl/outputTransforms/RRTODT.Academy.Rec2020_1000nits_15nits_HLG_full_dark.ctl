import "ACESlib.Utilities";
import "ACESlib.OutputTransforms";


// Support for HLG in ACES is tricky, since HLG is "scene-referred" and ACES 
// Output transforms produce display-referred output. ACES supports HLG at
// 1000 nits by converting the ST.2084 output to HLG using the method specified
// in Section 7 of ITU-R BT.2390-0. 


const OutputParameters OT_PARAMS = 
{
    0.0001, 15.0, 1000.0,   // black luminance, mid-point luminance, peak white luminance
    {{ 0.708, 0.292},{ 0.17, 0.797},{ 0.131, 0.046},{ 0.3127, 0.329}},  // encoding primaries
    {{ 0.708, 0.292},{ 0.17, 0.797},{ 0.131, 0.046},{ 0.3127, 0.329}},  // limiting primaries
    0,      // 0: ST-2084 (PQ), 1: BT.1886 (Rec.709/2020 settings), 2: sRGB (mon_curve w/ presets), 3: gamma 2.6, 4: linear (no EOTF)
    0,      // 0: dark, 1: dim, 2, 2: normal
    true,  // stretch black luminance to a PQ code value of 0
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

    float cv[3] = outputTransform( aces, OT_PARAMS);

    // Convert PQ signal to HLG, as detailed in Sec. 7 of ITU-R BT.2390
    cv = ST2084_2_HLG_1000nits( cv);
    
    rOut = cv[0];
    gOut = cv[1];
    bOut = cv[2];
    aOut = aIn;
}