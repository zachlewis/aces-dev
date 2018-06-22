## Reference Images ##

Reference, or "golden", images have been provided in order to help you verify 
your implementation of the reference color transformations. Each provided file 
is the output of one of the transforms included with the system. One pictorial, 
one synthetically generated test chart, and one file representative of a film 
scan have been provided.

The reference images can be downloaded individually or as a zip file from: 
<https://www.dropbox.com/sh/9xcfbespknayuft/AAD5SqM-W9RyYiAo8YFsUrqha?dl=0>


### Confirmation ###
To confirm your implementation of each transform:

  1. Use your implementation to process the "input" reference image appropriate to the transform being tested
  2. Compare the output from your implementation to the provided corresponding "output" reference image


### Directory Structure ###

**NOTE**: The ACEScc and ACESproxy image files are included for the confirmation of transform implementations only.  
ACEScc and ACESproxy image data is **NOT** intended to be written out to image files. See the ACEScc and ACESproxy documentation for more information.

  * **camera/**
    * *DigitalLAD.2048x1556.dpx* - original file representative of a film scan
    * *SonyF35.StillLife.dpx* - pictorial camera original file
    * *syntheticChart.01.exr* - a synthetic test chart    
  * **ACES/**
    * *DigitalLAD.2048x1556.exr* - `ACEScsc.ADX10_to_ACES.ctl` applied to *camera/DigitalLAD.2048x1556.dpx*
    * *SonyF35.StillLife.exr* - `IDT.Sony.SLog1_SGamut_10i.a1.v1.ctl` applied to *camera/SonyF35.StillLife.dpx*
    * *syntheticChart.01.exr* - `ACESlib.Unity.ctl` applied to *camera/syntheticChart.01.exr*
  * **ACEScc/**
    * *SonyF35.StillLife.exr* - `ACEScsc.ACES_to_ACEScc.ctl` applied to *ACES/SonyF35.StillLife.exr*
    * *syntheticChart.01.exr* - `ACEScsc.ACES_to_ACEScc.ctl` applied to *ACES/syntheticChart.01.exr*
  * **ACEScct/**
    * *SonyF35.StillLife.exr* - `ACEScsc.ACES_to_ACEScct.ctl` applied to *ACES/SonyF35.StillLife.exr*
    * *syntheticChart.01.exr* - `ACEScsc.ACES_to_ACEScct.ctl` applied to *ACES/syntheticChart.01.exr*
  * **ACEScg/**
    * *SonyF35.StillLife.exr* - `ACEScsc.ACES_to_ACEScg.ctl` applied to *ACES/SonyF35.StillLife.exr*
    * *syntheticChart.01.exr* - `ACEScsc.ACES_to_ACEScg.ctl` applied to *ACES/syntheticChart.01.exr*
  * **ACESproxy/**
    * *SonyF35.StillLife_ACESproxy10i.tiff* - `ACEScsc.ACES_to_ACESproxy10i.ctl` applied to *ACES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_ACESproxy12i.tiff* - `ACEScsc.ACES_to_ACESproxy12i.ctl` applied to *ACES/SonyF35.StillLife.exr*
    * *syntheticChart_ACESproxy10i.01.tiff* - `ACEScsc.ACES_to_ACESproxy10i.ctl` applied to *ACES/syntheticChart.01.exr*
    * *syntheticChart_ACESproxy12i.01.tiff* - `ACEScsc.ACES_to_ACESproxy12i.ctl` applied to *ACES/syntheticChart.01.exr*
  * **InvACES/**
    * *SonyF35.StillLife_from_ACEScc.exr* - `ACEScsc.ACEScc_to_ACES.ctl` applied to *ACEScc/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_from_ACEScct.exr* - `ACEScsc.ACEScct_to_ACES.ctl` applied to *ACEScct/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_from_ACEScg.exr* - `ACEScsc.ACEScg_to_ACES.ctl` applied to *ACEScg/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_from_ACESproxy10i.exr* - `ACEScsc.ACESproxy10i_to_ACES.ctl` applied to *ACESproxy/SonyF35.StillLife_ACESproxy10i.exr*
    * *SonyF35.StillLife_from_ACESproxy12i.exr* - `ACEScsc.ACESproxy12i_to_ACES.ctl` applied to *ACESproxy/SonyF35.StillLife_ACESproxy12i.exr*
    * *SonyF35.StillLife_from_InvRRT.exr* - `InvRRT.ctl` applied to *OCES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_from_RRTODT.Academy.P3D65_108nits_7.2nits_ST2084.tiff* - `InvRRTODT.Academy.P3D65_108nits_7.2nits_ST2084.ctl` applied to *RRTODT/SonyF35.StillLife_RRTODT.Academy.P3D65_108nits_7.2nits_ST2084.tiff**
    * *SonyF35.StillLife_from_RRTODT.Academy.Rec2020_1000nits_15nits_HLG.tiff* - `InvRRTODT.Academy.Rec2020_1000nits_15nits_HLG.ctl` applied to *RRTODT/SonyF35.StillLife_RRTODT.Academy.Rec2020_1000nits_15nits_HLG.tiff**
    * *SonyF35.StillLife_from_RRTODT.Academy.Rec2020_1000nits_15nits_ST2084.tiff* - `InvRRTODT.Academy.Rec2020_1000nits_15nits_ST2084.ctl` applied to *RRTODT/SonyF35.StillLife_RRTODT.Academy.Rec2020_1000nits_15nits_ST2084.tiff**
    * *SonyF35.StillLife_from_RRTODT.Academy.Rec2020_2000nits_15nits_ST2084.tiff* - `InvRRTODT.Academy.Rec2020_2000nits_15nits_ST2084.ctl` applied to *RRTODT/SonyF35.StillLife_RRTODT.Academy.Rec2020_2000nits_15nits_ST2084.tiff**
    * *SonyF35.StillLife_from_RRTODT.Academy.Rec2020_4000nits_15nits_ST2084.tiff* - `InvRRTODT.Academy.Rec2020_4000nits_15nits_ST2084.ctl` applied to *RRTODT/SonyF35.StillLife_RRTODT.Academy.Rec2020_4000nits_15nits_ST2084.tiff**
    * *syntheticChart.01_from_ACEScc.exr* - `ACEScsc.ACEScc_to_ACES.ctl` applied to *ACEScc/syntheticChart.01.exr*
    * *syntheticChart.01_from_ACEScct.exr* - `ACEScsc.ACEScct_to_ACES.ctl` applied to *ACEScct/syntheticChart.01.exr*
    * *syntheticChart.01_from_ACEScg.exr* - `ACEScsc.ACEScg_to_ACES.ctl` applied to *ACEScg/syntheticChart.01.exr*
    * *syntheticChart.01_from_ACESproxy10i.exr* - `ACEScsc.ACESproxy10i_to_ACES.ctl` applied to *ACESproxy/syntheticChart.01_ACESproxy10i.exr*
    * *syntheticChart.01_from_ACESproxy12i.exr* - `ACEScsc.ACESproxy12i_to_ACES.ctl` applied to *ACESproxy/syntheticChart.01_ACESproxy12i.exr*
    * *syntheticChart.01_from_InvRRT.exr* - `InvRRT.ctl` applied to *OCES/syntheticChart.01.exr*
    * *syntheticChart.01_from_RRTODT.Academy.P3D65_108nits_7.2nits_ST2084.tiff* - `InvRRTODT.Academy.P3D65_108nits_7.2nits_ST2084.ctl` applied to *RRTODT/syntheticChart.01_RRTODT.Academy.P3D65_108nits_7.2nits_ST2084.tiff**
    * *syntheticChart.01_from_RRTODT.Academy.Rec2020_1000nits_15nits_HLG.tiff* - `InvRRTODT.Academy.Rec2020_1000nits_15nits_HLG.ctl` applied to *RRTODT/syntheticChart.01_RRTODT.Academy.Rec2020_1000nits_15nits_HLG.tiff**
    * *syntheticChart.01_from_RRTODT.Academy.Rec2020_1000nits_15nits_ST2084.tiff* - `InvRRTODT.Academy.Rec2020_1000nits_15nits_ST2084.ctl` applied to *RRTODT/syntheticChart.01_RRTODT.Academy.Rec2020_1000nits_15nits_ST2084.tiff**
    * *syntheticChart.01_from_RRTODT.Academy.Rec2020_2000nits_15nits_ST2084.tiff* - `InvRRTODT.Academy.Rec2020_2000nits_15nits_ST2084.ctl` applied to *RRTODT/syntheticChart.01_RRTODT.Academy.Rec2020_2000nits_15nits_ST2084.tiff**
    * *syntheticChart.01_from_RRTODT.Academy.Rec2020_4000nits_15nits_ST2084.tiff* - `InvRRTODT.Academy.Rec2020_4000nits_15nits_ST2084.ctl` applied to *RRTODT/syntheticChart.01_RRTODT.Academy.Rec2020_4000nits_15nits_ST2084.tiff**
  * **InvOCES/**
    * *SonyF35.StillLife_from_ODT.Academy.DCDM_P3D60limited.tiff* - `InvODT.Academy.DCDM.ctl` applied to *ODT/SonyF35.StillLife_ODT.Academy.DCDM_P3D60limited.tiff*
    * *SonyF35.StillLife_from_ODT.Academy.DCDM_P3D65limited.tiff* - `InvODT.Academy.DCDM_P3D65limited.ctl` applied to *ODT/SonyF35.StillLife_ODT.Academy.DCDM_P3D65limited.tiff*
    * *SonyF35.StillLife_from_ODT.Academy.DCDM.tiff* - `InvODT.Academy.DCDM.ctl` applied to *ODT/SonyF35.StillLife_ODT.Academy.DCDM.tiff*
    * *SonyF35.StillLife_from_ODT.Academy.P3D60_48nits.tiff* - `InvODT.Academy.P3D60_48nits.ctl` applied to *ODT/SonyF35.StillLife_ODT.Academy.P3D60_48nits.tiff*
    * *SonyF35.StillLife_from_ODT.Academy.P3D65_48nits.tiff* - `InvODT.Academy.P3D65_48nits.ctl` applied to *ODT/SonyF35.StillLife_ODT.Academy.P3D65_48nits.tiff*
    * *SonyF35.StillLife_from_ODT.Academy.P3D65_D60sim_48nits.tiff* - `InvODT.Academy.P3D65_D60sim_48nits.ctl` applied to *ODT/SonyF35.StillLife_ODT.Academy.P3D65_D60sim_48nits.tiff*
    * *SonyF35.StillLife_from_ODT.Academy.P3D65_Rec709limited_48nits.tiff* - `InvODT.Academy.P3D65_48nits.ctl` applied to *ODT/SonyF35.StillLife_ODT.Academy.P3D65_Rec709limited_48nits.tiff*
    * *SonyF35.StillLife_from_ODT.Academy.P3DCI_D60sim_48nits.tiff* - `InvODT.Academy.P3DCI_D60sim_48nits.ctl` applied to *ODT/SonyF35.StillLife_ODT.Academy.P3DCI_D60sim_48nits.tiff*
    * *SonyF35.StillLife_from_ODT.Academy.P3DCI_D65sim_48nits.tiff* - `InvODT.Academy.P3DCI_D65sim_48nits.ctl` applied to *ODT/SonyF35.StillLife_ODT.Academy.P3DCI_D65sim_48nits.tiff*
    * *SonyF35.StillLife_from_ODT.Academy.Rec709_100nits_dim.tiff* - `InvODT.Academy.Rec709_100nits_dim.ctl` applied to *ODT/SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff*
    * *SonyF35.StillLife_from_ODT.Academy.Rec709_D60sim_100nits_dim.tiff* - `InvODT.Academy.Rec709_D60sim_100nits_dim.ctl` applied to *ODT/SonyF35.StillLife_ODT.Academy.Rec709_D60sim_100nits_dim.tiff*
    * *SonyF35.StillLife_from_ODT.Academy.Rec2020_100nits_dim.tiff* - `InvODT.Academy.Rec2020_100nits_dim.ctl` applied to *ODT/SonyF35.StillLife_ODT.Academy.Rec2020_100nits_dim.tiff*
    * *SonyF35.StillLife_from_ODT.Academy.Rec2020_P3D65limited_100nits_dim.tiff* - `InvODT.Academy.Rec2020_100nits_dim.ctl` applied to *ODT/SonyF35.StillLife_ODT.Academy.Rec2020_P3D65limited_100nits_dim.tiff*
    * *SonyF35.StillLife_from_ODT.Academy.Rec2020_Rec709limited_100nits_dim.tiff* - `InvODT.Academy.Rec2020_100nits_dim.ctl` applied to *ODT/SonyF35.StillLife_ODT.Academy.Rec2020_Rec709limited_100nits_dim.tiff*
    * *SonyF35.StillLife_from_ODT.Academy.sRGB_100nits_dim.tiff* - `InvODT.Academy.sRGB_100nits_dim.ctl` applied to *ODT/SonyF35.StillLife_ODT.Academy.sRGB_100nits_dim.tiff*
    * *SonyF35.StillLife_from_ODT.Academy.sRGB_D60sim_100nits_dim.tiff* - `InvODT.Academy.sRGB_D60sim_100nits_dim.ctl` applied to *ODT/SonyF35.StillLife_ODT.Academy.sRGB_D60sim_100nits_dim.tiff*
    * *syntheticChart.01_from_ODT.Academy.DCDM_P3D60limited.tiff* - `InvODT.Academy.DCDM.ctl` applied to *ODT/syntheticChart.01_ODT.Academy.DCDM_P3D60limited.tiff*
    * *syntheticChart.01_from_ODT.Academy.DCDM_P3D65limited.tiff* - `InvODT.Academy.DCDM_P3D65limited.ctl` applied to *ODT/syntheticChart.01_ODT.Academy.DCDM_P3D65limited.tiff*
    * *syntheticChart.01_from_ODT.Academy.DCDM.tiff* - `InvODT.Academy.DCDM.ctl` applied to *ODT/syntheticChart.01_ODT.Academy.DCDM.tiff*
    * *syntheticChart.01_from_ODT.Academy.P3D60_48nits.tiff* - `InvODT.Academy.P3D60_48nits.ctl` applied to *ODT/syntheticChart.01_ODT.Academy.P3D60_48nits.tiff*
    * *syntheticChart.01_from_ODT.Academy.P3D65_48nits.tiff* - `InvODT.Academy.P3D65_48nits.ctl` applied to *ODT/syntheticChart.01_ODT.Academy.P3D65_48nits.tiff*
    * *syntheticChart.01_from_ODT.Academy.P3D65_D60sim_48nits.tiff* - `InvODT.Academy.P3D65_D60sim_48nits.ctl` applied to *ODT/syntheticChart.01_ODT.Academy.P3D65_D60sim_48nits.tiff*
    * *syntheticChart.01_from_ODT.Academy.P3D65_Rec709limited_48nits.tiff* - `InvODT.Academy.P3D65_48nits.ctl` applied to *ODT/syntheticChart.01_ODT.Academy.P3D65_Rec709limited_48nits.tiff*
    * *syntheticChart.01_from_ODT.Academy.P3DCI_D60sim_48nits.tiff* - `InvODT.Academy.P3DCI_D60sim_48nits.ctl` applied to *ODT/syntheticChart.01_ODT.Academy.P3DCI_D60sim_48nits.tiff*
    * *syntheticChart.01_from_ODT.Academy.P3DCI_D65sim_48nits.tiff* - `InvODT.Academy.P3DCI_D65sim_48nits.ctl` applied to *ODT/syntheticChart.01_ODT.Academy.P3DCI_D65sim_48nits.tiff*
    * *syntheticChart.01_from_ODT.Academy.Rec709_100nits_dim.tiff* - `InvODT.Academy.Rec709_100nits_dim.ctl` applied to *ODT/syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff*
    * *syntheticChart.01_from_ODT.Academy.Rec709_D60sim_100nits_dim.tiff* - `InvODT.Academy.Rec709_D60sim_100nits_dim.ctl` applied to *ODT/syntheticChart.01_ODT.Academy.Rec709_D60sim_100nits_dim.tiff*
    * *syntheticChart.01_from_ODT.Academy.Rec2020_100nits_dim.tiff* - `InvODT.Academy.Rec2020_100nits_dim.ctl` applied to *ODT/syntheticChart.01_ODT.Academy.Rec2020_100nits_dim.tiff*
    * *syntheticChart.01_from_ODT.Academy.Rec2020_P3D65limited_100nits_dim.tiff* - `InvODT.Academy.Rec2020_100nits_dim.ctl` applied to *ODT/syntheticChart.01_ODT.Academy.Rec2020_P3D65limited_100nits_dim.tiff*
    * *syntheticChart.01_from_ODT.Academy.Rec2020_Rec709limited_100nits_dim.tiff* - `InvODT.Academy.Rec2020_100nits_dim.ctl` applied to *ODT/syntheticChart.01_ODT.Academy.Rec2020_Rec709limited_100nits_dim.tiff*
    * *syntheticChart.01_from_ODT.Academy.sRGB_100nits_dim.tiff* - `InvODT.Academy.sRGB_100nits_dim.ctl` applied to *ODT/syntheticChart.01_ODT.Academy.sRGB_100nits_dim.tiff*
    * *syntheticChart.01_from_ODT.Academy.sRGB_D60sim_100nits_dim.tiff* - `InvODT.Academy.sRGB_D60sim_100nits_dim.ctl` applied to *ODT/syntheticChart.01_ODT.Academy.sRGB_D60sim_100nits_dim.tiff*
  * **LMT/**
    * *SonyF35.StillLife_LMT.Academy.ACES_0_1_1.exr* - `LMT.Academy.ACES_0_1_1.ctl` applied to *ACES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_LMT.Academy.ACES_0_2_2.exr* - `LMT.Academy.ACES_0_2_2.ctl` applied to *ACES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_LMT.Academy.ACES_0_7_1.exr* - `LMT.Academy.ACES_0_7_1.ctl` applied to *ACES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_LMT.Academy.BlueLightArtifactFix.exr* - `LMT.Academy.BlueLightArtifactFix.ctl` applied to *ACES/SonyF35.StillLife.exr*
    * *syntheticChart.01_LMT.Academy.ACES_0_1_1.exr* - `LMT.Academy.ACES_0_1_1.ctl` applied to *ACES/syntheticChart.01.exr*
    * *syntheticChart.01_LMT.Academy.ACES_0_2_2.exr* - `LMT.Academy.ACES_0_2_2.ctl` applied to *ACES/syntheticChart.01.exr*
    * *syntheticChart.01_LMT.Academy.ACES_0_7_1.exr* - `LMT.Academy.ACES_0_7_1.ctl` applied to *ACES/syntheticChart.01.exr*
    * *syntheticChart.01_LMT.Academy.BlueLightArtifactFix.exr* - `LMT.Academy.BlueLightArtifactFix.ctl` applied to *ACES/syntheticChart.01.exr*
  * **OCES/**
    * *SonyF35.StillLife.exr* - `RRT.ctl` applied to *ACES/SonyF35.StillLife.exr*
    * *syntheticChart.01.exr* - `RRT.ctl` applied to *ACES/syntheticChart.01.exr*
  * **ODT/**
    * *SonyF35.StillLife_ODT.Academy.DCDM_P3D60limited.tiff* - `ODT.Academy.DCDM_P3D60limited.ctl` applied to *OCES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_ODT.Academy.DCDM_P3D65limited.tiff* - `ODT.Academy.DCDM_P3D65limited.ctl` applied to *OCES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_ODT.Academy.DCDM.tiff* - `ODT.Academy.DCDM.ctl` applied to *OCES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_ODT.Academy.P3D60_48nits.tiff* - `ODT.Academy.P3D60_48nits.ctl` applied to *OCES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_ODT.Academy.P3D65_48nits.tiff* - `ODT.Academy.P3D65_48nits.ctl` applied to *OCES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_ODT.Academy.P3D65_D60sim_48nits.tiff* - `ODT.Academy.P3D65_D60sim_48nits.ctl` applied to *OCES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_ODT.Academy.P3D65_Rec709limited_48nits.tiff* - `ODT.Academy.P3D65_Rec709limited_48nits.ctl` applied to *OCES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_ODT.Academy.P3DCI_D60sim_48nits.tiff* - `ODT.Academy.P3DCI_D60sim_48nits.ctl` applied to *OCES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_ODT.Academy.P3DCI_D65sim_48nits.tiff* - `ODT.Academy.P3DCI_D65sim_48nits.ctl` applied to *OCES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_ODT.Academy.Rec709_100nits_dim.tiff* - `ODT.Academy.Rec709_100nits_dim.ctl` applied to *OCES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_ODT.Academy.Rec709_D60sim_100nits_dim.tiff* - `ODT.Academy.Rec709_D60sim_100nits_dim.ctl` applied to *OCES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_ODT.Academy.Rec2020_100nits_dim.tiff* - `ODT.Academy.Rec2020_100nits_dim.ctl` applied to *OCES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_ODT.Academy.Rec2020_P3D65limited_100nits_dim.tiff* - `ODT.Academy.Rec2020_P3D65limited_100nits_dim.ctl` applied to *OCES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_ODT.Academy.Rec2020_Rec709limited_100nits_dim.tiff* - `ODT.Academy.Rec2020_Rec709limited_100nits_dim.ctl` applied to *OCES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_ODT.Academy.sRGB_100nits_dim.tiff* - `ODT.Academy.sRGB_100nits_dim.ctl` applied to *OCES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_ODT.Academy.sRGB_D60sim_100nits_dim.tiff* - `ODT.Academy.sRGB_D60sim_100nits_dim.ctl` applied to *OCES/SonyF35.StillLife.exr*
    * *syntheticChart.01_ODT.Academy.DCDM_P3D60limited.tiff* - `ODT.Academy.DCDM_P3D60limited.ctl` applied to *OCES/syntheticChart.01.exr*
    * *syntheticChart.01_ODT.Academy.DCDM_P3D65limited.tiff* - `ODT.Academy.DCDM_P3D65limited.ctl` applied to *OCES/syntheticChart.01.exr*
    * *syntheticChart.01_ODT.Academy.DCDM.tiff* - `ODT.Academy.DCDM.ctl` applied to *OCES/syntheticChart.01.exr*
    * *syntheticChart.01_ODT.Academy.P3D60_48nits.tiff* - `ODT.Academy.P3D60_48nits.ctl` applied to *OCES/syntheticChart.01.exr*
    * *syntheticChart.01_ODT.Academy.P3D65_48nits.tiff* - `ODT.Academy.P3D65_48nits.ctl` applied to *OCES/syntheticChart.01.exr*
    * *syntheticChart.01_ODT.Academy.P3D65_D60sim_48nits.tiff* - `ODT.Academy.P3D65_D60sim_48nits.ctl` applied to *OCES/syntheticChart.01.exr*
    * *syntheticChart.01_ODT.Academy.P3D65_Rec709limited_48nits.tiff* - `ODT.Academy.P3D65_Rec709limited_48nits.ctl` applied to *OCES/syntheticChart.01.exr*
    * *syntheticChart.01_ODT.Academy.P3DCI_D60sim_48nits.tiff* - `ODT.Academy.P3DCI_D60sim_48nits.ctl` applied to *OCES/syntheticChart.01.exr*
    * *syntheticChart.01_ODT.Academy.P3DCI_D65sim_48nits.tiff* - `ODT.Academy.P3DCI_D65sim_48nits.ctl` applied to *OCES/syntheticChart.01.exr*
    * *syntheticChart.01_ODT.Academy.Rec709_100nits_dim.tiff* - `ODT.Academy.Rec709_100nits_dim.ctl` applied to *OCES/syntheticChart.01.exr*
    * *syntheticChart.01_ODT.Academy.Rec709_D60sim_100nits_dim.tiff* - `ODT.Academy.Rec709_D60sim_100nits_dim.ctl` applied to *OCES/syntheticChart.01.exr*
    * *syntheticChart.01_ODT.Academy.Rec2020_100nits_dim.tiff* - `ODT.Academy.Rec2020_100nits_dim.ctl` applied to *OCES/syntheticChart.01.exr*
    * *syntheticChart.01_ODT.Academy.Rec2020_P3D65limited_100nits_dim.tiff* - `ODT.Academy.Rec2020_P3D65limited_100nits_dim.ctl` applied to *OCES/syntheticChart.01.exr*
    * *syntheticChart.01_ODT.Academy.Rec2020_Rec709limited_100nits_dim.tiff* - `ODT.Academy.Rec2020_Rec709limited_100nits_dim.ctl` applied to *OCES/syntheticChart.01.exr*
    * *syntheticChart.01_ODT.Academy.sRGB_100nits_dim.tiff* - `ODT.Academy.sRGB_100nits_dim.ctl` applied to *OCES/syntheticChart.01.exr*
    * *syntheticChart.01_ODT.Academy.sRGB_D60sim_100nits_dim.tiff* - `ODT.Academy.sRGB_D60sim_100nits_dim.ctl` applied to *OCES/syntheticChart.01.exr*
  * **RRTODT/**
    * *SonyF35.StillLife_RRTODT.Academy.P3D65_108nits_7.2nits_ST2084.tiff* - `RRTODT.Academy.P3D65_108nits_7.2nits_ST2084.ctl` applied to *ACES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_RRTODT.Academy.Rec2020_1000nits_15nits_HLG.tiff* - `RRTODT.Academy.Rec2020_1000nits_15nits_HLG.ctl` applied to *ACES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_RRTODT.Academy.Rec2020_1000nits_15nits_ST2084.tiff* - `RRTODT.Academy.Rec2020_1000nits_15nits_ST2084.ctl` applied to *ACES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_RRTODT.Academy.Rec2020_2000nits_15nits_ST2084.tiff* - `RRTODT.Academy.Rec2020_2000nits_15nits_ST2084.ctl` applied to *ACES/SonyF35.StillLife.exr*
    * *SonyF35.StillLife_RRTODT.Academy.Rec2020_4000nits_15nits_ST2084.tiff* - `RRTODT.Academy.Rec2020_4000nits_15nits_ST2084.ctl` applied to *ACES/SonyF35.StillLife.exr*
    * *syntheticChart.01_RRTODT.Academy.P3D65_108nits_7.2nits_ST2084.tiff* - `RRTODT.Academy.P3D65_108nits_7.2nits_ST2084.ctl` applied to *ACES/syntheticChart.01.exr*
    * *syntheticChart.01_RRTODT.Academy.Rec2020_1000nits_15nits_HLG.tiff* - `RRTODT.Academy.Rec2020_1000nits_15nits_HLG.ctl` applied to *ACES/syntheticChart.01.exr*
    * *syntheticChart.01_RRTODT.Academy.Rec2020_1000nits_15nits_ST2084.tiff* - `RRTODT.Academy.Rec2020_1000nits_15nits_ST2084.ctl` applied to *ACES/syntheticChart.01.exr*
    * *syntheticChart.01_RRTODT.Academy.Rec2020_2000nits_15nits_ST2084.tiff* - `RRTODT.Academy.Rec2020_2000nits_15nits_ST2084.ctl` applied to *ACES/syntheticChart.01.exr*
    * *syntheticChart.01_RRTODT.Academy.Rec2020_4000nits_15nits_ST2084.tiff* - `RRTODT.Academy.Rec2020_4000nits_15nits_ST2084.ctl` applied to *ACES/syntheticChart.01.exr*