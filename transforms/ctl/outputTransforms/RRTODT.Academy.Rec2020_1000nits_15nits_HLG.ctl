
// <ACEStransformID>ODT.Academy.Rec2020_1000nits_15nits_HLG.a1.0.3</ACEStransformID>
// <ACESuserName>ACES 1.0 Output - Rec.2020 HLG (1000 nits)</ACESuserName>

// 
// Output Transform - Rec.2020 (1000 cd/m^2)
//

//
// Summary :
//  This transform maps ACES onto a Rec.2020 HLG HDR display calibrated 
//  to a D65 white point at 1000 cd/m^2. The assumed observer adapted white is 
//  D65, and the viewing environment is that of a dark surround. Mid-gray
//  luminance is targeted at 15 cd/m^2.
//
// Device Primaries : 
//  Primaries are those specified in Rec. ITU-R BT.2020
//  CIE 1931 chromaticities:  x         y         Y
//              Red:          0.708     0.292
//              Green:        0.17      0.797
//              Blue:         0.131     0.046
//              White:        0.3127    0.329     1000 cd/m^2
//              18% Gray:     0.3127    0.329     15 cd/m^2
//
// Display EOTF :
//  The reference electro-optical transfer function specified in Table 5 of 
//  ITU-R BT.2100 (HLG)
//
// Assumed observer adapted white point:
//         CIE 1931 chromaticities:    x            y
//                                     0.3127       0.329
//
// Viewing Environment:
//  Environment specified in SMPTE RP 431-2-2007
//



import "ACESlib.Utilities";
import "ACESlib.OutputTransforms";


// Support for HLG in ACES is tricky, since HLG is "scene-referred" and ACES 
// Output transforms produce display-referred output. ACES supports HLG at
// 1000 nits by converting the ST.2084 output to HLG using the method specified
// in Section 7 of ITU-R BT.2390-0. 


const float Y_MIN = 0.0001;                     // black luminance (cd/m^2)
const float Y_MID = 15.0;                       // mid-point luminance (cd/m^2)
const float Y_MAX = 1000.0;                     // peak white luminance (cd/m^2)

const Chromaticities DISPLAY_PRI = REC2020_PRI; // encoding primaries (device setup)
const Chromaticities LIMITING_PRI = REC2020_PRI;// limiting primaries

const int EOTF = 5;                             // 0: ST-2084 (PQ)
                                                // 1: BT.1886 (Rec.709/2020 settings) 
                                                // 2: sRGB (mon_curve w/ presets)
                                                // 3: gamma 2.6
                                                // 4: linear (no EOTF)
                                                // 5: HLG

const int SURROUND = 0;                         // 0: dark
                                                // 1: dim
                                                // 2: normal

const bool STRETCH_BLACK = true;                // stretch black luminance to a PQ code value of 0
const bool D60_SIM = false;                       
const bool LEGAL_RANGE = false;


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

    float cv[3] = outputTransform( aces, Y_MIN,
                                         Y_MID,
                                         Y_MAX,
                                         DISPLAY_PRI,
                                         LIMITING_PRI,
                                         EOTF,
                                         SURROUND,
                                         STRETCH_BLACK,
                                         D60_SIM,
                                         LEGAL_RANGE );

    rOut = cv[0];
    gOut = cv[1];
    bOut = cv[2];
    aOut = aIn;
}