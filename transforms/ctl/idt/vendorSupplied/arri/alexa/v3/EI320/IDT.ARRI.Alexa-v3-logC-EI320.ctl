
// <ACEStransformID>IDT.ARRI.Alexa-v3-logC-EI320.a1.v2</ACEStransformID>
// <ACESuserName>ACES 1.0 Input - ARRI V3 LogC (EI320)</ACESuserName>

// ARRI ALEXA IDT for ALEXA logC files
//  with camera EI set to 320
// Written by v3_IDT_maker.py v0.09 on Thursday 22 December 2016


float
normalizedLogCToRelativeExposure(float x) {
	return lookup1D(inverseLogCCurve, 0.0, 1.0, x);
}

void main
(	input varying float rIn,
	input varying float gIn,
	input varying float bIn,
	input varying float aIn,
	output varying float rOut,
	output varying float gOut,
	output varying float bOut,
	output varying float aOut)
{

	float r_lin = normalizedLogCToRelativeExposure(rIn);
	float g_lin = normalizedLogCToRelativeExposure(gIn);
	float b_lin = normalizedLogCToRelativeExposure(bIn);

	rOut = r_lin * 6.8020600000000e-01 + g_lin * 2.3613700000000e-01 + b_lin * 8.3658000000000e-02;
	gOut = r_lin * 8.5415000000000e-02 + g_lin * 1.0174710000000e+00 + b_lin * -1.0288600000000e-01;
	bOut = r_lin * 2.0570000000000e-03 + g_lin * -6.2563000000000e-02 + b_lin * 1.0605060000000e+00;
	aOut = 1.0;

}