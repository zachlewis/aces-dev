void main
(
    input varying float rIn,
    input varying float gIn,
    input varying float bIn,
    input varying float aIn,
    input uniform float eI,
    output varying float rOut,
    output varying float gOut,
    output varying float bOut,
    output varying float aOut
)
{
    float blackOffset = 256.0 / 65535.0;
    float scaleFactor = 0.18 / (0.01 * (400.0 / eI));

    rOut = scaleFactor * (rIn - blackOffset);
    gOut = scaleFactor * (gIn - blackOffset);
    bOut = scaleFactor * (bIn - blackOffset);
    aOut = 1.0;
}

