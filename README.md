## Academy Color Encoding System Developer Resources ##

The Academy Color Encoding System (ACES) is a set of components that facilitates a wide range of motion picture and television workflows while eliminating the ambiguity of legacy file formats.  The system is designed to support both all-digital and hybrid film-digital motion picture workflows.

The basic ACES components are:

* Color encoding and metric specifications, file format specifications, color
transformations, and an open source reference implementation 
* A set of reference images and calibration targets for film scanners and recorders 
* Documentation on the system and software tools

This toolkit is intended to serve as a distribution mechanism for key components of the system, including the reference implementation transforms, reference images, and documentation.

### Package Contents ###
 
* [`documents/`](./documents) – ACES-related documents 
* [`images/`](./images) - "golden" images created using the reference implementation transforms
* [`transforms/`](./transforms) - ACES reference implementation transforms

### Changes from Previous Release ###

Though the "master" branch is 1.1, the current major version of ACES remains 1.0. The 1.1 update adds a number of transforms but does not change the look or modify the existing core transforms (beyond addressing reported bugs and/or inconsequential formatting/whitespace changes).

As always, you should check the hotfixes and dev branches for the latest bug fixes and new features that will ultimately be rolled into a future version of ACES.  These improvements will continue to be staged on the dev branch for testing as they become available.

Included in ACES 1.1:

* New Transforms: 
    * P3 ODTs:
        * P3D65 (and inverse)
        * P3D65 "D60 simulation" (i.e. D60 adapted white point) (and inverse)
        * P3DCI "D65 simulation" (i.e. D65 adapted white point) (and inverse)
        * P3D65 limited to Rec.709 (inverse not required)
    * Rec.2020 ODTs:
        * Rec.2020 limited to Rec.709 (inverse not required)
        * Rec.2020 limited to P3D65 (inverse not required)
    * DCDM ODT:
        * DCDM with D65 adapted white point and limited to P3D65 (and inverse)
    * ACESlib:
        * SSTS: code for the Single Stage Tone Scale
        * OutputTransform: beginning of modules needed for parameterizing Output Transforms
    * HDR Output Transforms (RRT+ODT):
        * P3D65 (108 cd/m^2) ST.2084 - designed for use in Dolby Cinema (and inverse)
        * Rec.2020 (1000 cd/m^2) ST.2084 (and inverse)
        * Rec.2020 (2000 cd/m^2) ST.2084 (and inverse)
        * Rec.2020 (4000 cd/m^2) ST.2084 (and inverse)
        * Rec.2020 (1000 cd/m^2) HLG (and inverse)
    * Add new reference images for new transforms
* Bug Fixes:
    * Update copy and paste typo in ACESproxy document
    * Update ODT functions legal range input variable usage to avoid a situation where it may not execute as intended.
    * Update miscellaneous to local variables in utility functions to avoid clashes with existing global variables
    * Update miscellaneous minor errors in Transform IDs
    * Update miscellaneous transforms missing ACESuserName Tags
* Other:
    * Rename DCDM_P3D60 to DCDM_P3D60limited
    * Rename P3DCI to P3DCI_D60sim
    * Miscellaneous white space fixes in CTL transforms
    * Miscellaneous typo fixes in CTL transform comments

For a more detailed list of changes see the [CHANGELOG](./CHANGELOG.md) and in the [commit history](https://github.com/ampas/aces-dev/commits/master).

#### Notes on ACEScct ####

A new color correction working space has been added to ACES 1.0.3.  The new working space, known as ACEScct, is intended to address some colorists' desire for a grading behavior similar to that of traditional log film scans.  ACEScct is intended to be an alternate color correction working space to ACEScc for those who prefer its grading behavior.  As such, developers implementing ACES 1.0.3 in products that previously only used ACEScc should offer end users a choice of ACEScc or ACEScct in the user interface as the color correction working space.  Among the characteristics of ACEScct is a more distict "milking" or "fogging" of shadows when a lift operation is applied when compared to the same operation applied in ACEScc.  This is a result of the addition of a "toe" to the non-linear encoding function.  It is important to note that ACEScct is *NOT* compatible with ASC-CDL values generated on-set using the ACESproxy encoding.  If there is a need to reproduce a look generated on-set where ACESproxy was used, ACEScc must be used in the dailies and/or DI environment.

### Versioning ###
 
The links to the current and all past versions of the ACES Developer Resources
can be found at [https://github.com/ampas/aces-dev/releases](https://github.com/ampas/aces-dev/releases).  

Source code is version controlled using the [git version control system](http://git-scm.com/) and hosted on GitHub at [https://github.com/ampas/aces-dev/](https://github.com/ampas/aces-dev/).

Individual files now conform to the ACES System Versioning Specification.  Details can be found in the Academy Specification "S-2014-002 - Academy Color Encoding System - Versioning System" included in [`documents/`](./documents)

### Branch Structure ###

__Master Branch__
 
The current release version of ACES can always be found at the HEAD of the master branch.  The master branch contains no intermediate commits and all commits on the master branch are tagged to represent a release of ACES.

__Dev Branch__
 
Intermediate commits between releases will be staged on the dev branch.  Commits staged on the dev branch, but not yet merged into the master, should be considered as "planned for inclusion" in the next release version.  Commits on the dev branch will ultimately be merged into the master branch as part of a future release.

__Hotfixes Branch__

In some instances it may be necessary to create a hotfixes branch.  The hotfixes branch will include important, but not fully tested, fixes for bugs found in a particular release.  Hotfixes should only be implemented by developers if the bug they are intending to correct is encountered in the course of production and is deemed to be a barrier to using a particular ACES release.  Hotfixes, once fully tested, will be merged into the dev branch, and ultimately the master.

## Prerequisites ##

### Color Transformation Language ###

Color Transformation Language (CTL) can be downloaded from
https://github.com/ampas/CTL

## License Terms for Academy Color Encoding System Components ##

Academy Color Encoding System (ACES) software and tools are provided by the
Academy under the following terms and conditions: A worldwide, royalty-free,
non-exclusive right to copy, modify, create derivatives, and use, in source and
binary forms, is hereby granted, subject to acceptance of this license.

Copyright 2016 Academy of Motion Picture Arts and Sciences (A.M.P.A.S.).
Portions contributed by others as indicated. All rights reserved.

Performance of any of the aforementioned acts indicates acceptance to be bound
by the following terms and conditions:

* Copies of source code, in whole or in part, must retain the above copyright
notice, this list of conditions and the Disclaimer of Warranty.

* Use in binary form must retain the above copyright notice, this list of
conditions and the Disclaimer of Warranty in the documentation and/or other
materials provided with the distribution.

* Nothing in this license shall be deemed to grant any rights to trademarks,
copyrights, patents, trade secrets or any other intellectual property of
A.M.P.A.S. or any contributors, except as expressly stated herein.

* Neither the name "A.M.P.A.S." nor the name of any other contributors to this
software may be used to endorse or promote products derivative of or based on
this software without express prior written permission of A.M.P.A.S. or the
contributors, as appropriate.

This license shall be construed pursuant to the laws of the State of
California, and any disputes related thereto shall be subject to the
jurisdiction of the courts therein.

Disclaimer of Warranty: THIS SOFTWARE IS PROVIDED BY A.M.P.A.S. AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND
NON-INFRINGEMENT ARE DISCLAIMED. IN NO EVENT SHALL A.M.P.A.S., OR ANY
CONTRIBUTORS OR DISTRIBUTORS, BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, RESITUTIONARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, THE ACADEMY SPECIFICALLY
DISCLAIMS ANY REPRESENTATIONS OR WARRANTIES WHATSOEVER RELATED TO PATENT OR
OTHER INTELLECTUAL PROPERTY RIGHTS IN THE ACADEMY COLOR ENCODING SYSTEM, OR
APPLICATIONS THEREOF, HELD BY PARTIES OTHER THAN A.M.P.A.S.,WHETHER DISCLOSED OR
UNDISCLOSED.
