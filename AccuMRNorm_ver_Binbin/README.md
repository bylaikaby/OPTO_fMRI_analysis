# AccuMRNorm
Manual coregistration tool with streamlined spatial registration and warping by SPM/Dartels

AccuMRNorm is a pipeline for spatially normalizing single-subject MRI data to a common reference (template) image. AccuMRNorm comprises a series of linear and nonlinear (warping) transformations used to register a single-subject’s anatomical scan to a standard MRI template. Some tests were conducted to optimize AccuMRNorm as noted in the documentation below. Data quality checks were performed to compare the anatomical regions and functional activations across scans before and after spatial normalization (see Case Examples). This pipeline is capable of yielding anatomical registration with an estimated 0.5 mm accuracy. This small spatial discrepancy is below the spatial resolution of most EPI voxel dimensions; as such some tolerance for minimal mismatch exists. The degree of accuracy can be pushed by the user to the necessary extent. Thus, AccuMRNorm encourages users to evaluate their result from the automated section (steps preceding #7 in the documentation below) of the pipeline to estimate the degree, if any, of manual intervention is required to obtain a satisfactory registration. 
_____________________________________________________________________________________
AccuMRNorm Pipeline Overview:

Package download
Download AccuMRNorm.zip and add the unzipped folder to your working path directory. The package contains:
Video showing anatomical consistency, by moving from landmark to landmark

Data & workspace organization
In the experiment folder, place the individual’s anatomical file into a sub-folder called ‘ana’ and the relevant functional time series images (as a 4D file) into another sub-folder called ‘func’. These files should all be in the NiFTI image file format.
In AccuMRnorm.m (lines 19-23) specify the following information:
datapath    = ('');                                           % specify datapath
addpath('')                                                    % add path for toolbox
tempPath = ('');				    % specify template path
tempFile = ('');                                              % specify template name
Note: AccuMRNorm is not compatible with Fieldtrip and the ‘cfg’ dependency may exhibit complications when both packages are on the path. 

Linear Alignment
This is a crucial step because we need to keep all functional images (i.e., EPIs) in alignment with the subject’s native anatomy. Before registering data to a template, check that the functional images are in alignment with the subject’s anatomical (e.g. RARE) scan. 
A manual coregistration tool utilizing the SPM program functions can be used to linearly align the subject’s anatomical scan (source image) to the template (reference image), while applying the transformation to all functional images aligned to the subject’s native anatomical scan. 

Skull-stripping
The first step in the pipeline is essentially the ‘Initial Import’ phase (embedded within seg_ana.m), which outputs the anatomical image’s segmented Tissue Probability Maps (TPMs). The anatomical output (whether original, bias corrected, or skull-stripped) is rescaled so that the mean of the white matter intensity = 1 (this might be taken as some form of homogenization, or intensity normalization). With the skull-stripped option, the output is additionally scaled by the sum of the grey and white matter probabilities (this could account for slight differences in overall contrast between the skull-stripped and original output versions.

6. Dartel Nonlinear Registration
Dartel is an SPM-based fast diffeomorphic image registration algorithm (Ashburner, 2007). The default setting calls upon the TPMs of the template, otherwise the average template from an experiment cohort can be taken instead. 
Modifications from the default settings include: 
Changing the number of cycles & iterations over which the Template and deformation field (‘u_’) are created from 3 to 8.
Changing the ‘Regularisation Form’ for Template creation  from ‘Linear Elastic Energy’ to ‘Membrane Energy’.
Changed setting from 0 to 1 for Regularisation Form = ‘Membrane Energy’
Relevant line change: matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).K = 1;
Increasing the Levenberg-Marquardt regularization value from 0.01 to 0.1 
Maximum iteration value = 1
Relevant line change: matlabbatch{1}.spm.tools.dartel.warp.settings.optim.lmreg = 0.1;

7. Ad hoc morphological deformation correction
At this point, we have shown how to nonlinear register the data with an anatomical template using the Dartel algorithm. Any critique of this result may be addressed using the mreg2d_gui.m (Figure 2) to achieve a better (with +/- 0.5 mm precision) coregistration between the functional and anatomical scans (Figure 3). For this purpose, the mreg2dgui is a useful graphical user interface (GUI) for making manual edits during the warping of single-subject MRI data to a standard template space. The aim here is to identify, then match corresponding anatomical features between the individual and template brains.
To open the GUI, enter the following command line into Matlab:
mreg2d_gui(Reference Image Path, Source Image Path)
The GUI will open and display the reference image (1), which is the template, on the left and source image (2), which is the individual subject’s anatomical scan, in the middle. The transformed image is displayed on the right (3).
Figure 2: The mreg2d graphical user interface (GUI). The GUI interface with the template as the reference image  (1) and the individual’s morphed anatomical image as the source image  (2). The source image here is the result from the Dartels diffeomorphic warping. The (3) overlay of the reference and source images before transformation by manually establishing (4) fiducial points on a consistent interleaving of slices (e.g., manually laying points on every three slices). A few different (5) types of transformations are possible, here the default setting is lwm, which uses a linear local-weighted mean approach to nonlinear warping. After laying the minimum number of points (12 for lwm) the user needs to initiate the (6) transform using the GUI. The result should be (7) saved intermittently and at the conclusion of manual intervention. 
To lay down points, select Append, in the drop down menu (4) and click alternating on landmarks in the reference and source image. Once enough points are put down (minimum number depends on transformation algorithms), select a transformation algorithm (5) and click transform (6) and then save the result (7). The results will be saved as .mat files and have to be transformed into .nii files using the tvol.m script.
Note: Start laying down points only when the whole plane of the individual’s brain is in the view of the ‘Source Image’ panel. 
Once points are laid down for this first slice, slices can be skipped in a fixed interval of 1, 2, 3, or 4. The blanks will be filled automatically while the file is transformed from a .mat file to a .nii file (the script will ask the user for the interval chosen). However, the interval must be decided at the beginning of the manual work and cannot be changed during one experiment. By laying points down on only every x slice, the user saves time and manual work.
Figure 3 highlights that there is no difference between the individual’s resulting normalized scan, whether all slices were manually entered via mreg2d_gui or whether the interpolation points for every other slice were filled in by automatically replacing the transformation points from the preceding slice. By adding this function to the tvol.m script, the amount of time the user has to spend laying points and manually adapting the registration is lowered significantly and therefore further limiting the amount of manual intervention.
Figure 3. Optimizing mreg2d_gui usage. A test was made to determine if a noticeable difference arises in the method of placing and/or copying fiducial points from slice-to-slice, or whether it can automatically be calculated for you via the AccuMRNorm pipeline. The original normalized anatomical image from one individual (case K07.EH1; top row) was the result of manually interpolated consecutive slices using the GUI. Interleaving point placement by every other (top panel) and by every third slice (bottom panel) is shown in two axial planes for slices (a) 120 and (b) 101. From the apparent similarity in the result, AccuMRNorm streamlined the interleaving method of point placement every third slice.

8. Image Smoothing
To smooth lines induced by the nonlinear registration, a final image smoothing is performed, by default this is 2 mm; however, depending on the user’s image resolution this can be modified.

9. Quality check
To check the quality of the performed normalization, the user can run the script qualitycheck. After some preparatory steps (masking and noise removal via binarization), the dice coefficient is calculated, which gives an objective measure on the similarity of the normalized image to the template. The dice coefficient is a widely used method to calculate the similarity between two samples by calculating the number of the overlapping elements*2 divided by the total number of elements in either sample. The resulting coefficient will be between 0 and 1, with 1 indicating identical samples.
___________________________________________________________________________________
References:
Ashburner. 2007. A fast diffeomorphic image registration algorithm. NeuroImage. 38, 95-113.
Comments:
Pipeline test suggestion: Using two within-subject datasets, acquired on 2 separate days with implanted coils, and showing very consistent small activations. See that these activations survive the morphing.
