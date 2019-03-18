function [sMri, CortexLow,WhiteLow, MidLow ] = my_import_anatomy_fs( FsDir,sMri, nVertices, isInteractive, sFid, isExtraMaps, resamplingMethod,quickLoad ,isAseg)
% IMPORT_ANATOMY_FS: Import a full FreeSurfer folder as the subject's anatomy.
%
% USAGE:  errorMsg = import_anatomy_fs(iSubject, FsDir=[], nVertices=15000, isInteractive=1, sFid=[], isExtraMaps=0, isAseg=1)
%
% INPUT:
%    - iSubject     : Indice of the subject where to import the MRI
%                     If iSubject=0 : import MRI in default subject
%    - FsDir        : Full filename of the FreeSurfer folder to import
%    - nVertices    : Number of vertices in the file cortex surface
%    - isInteractive: If 0, no input or user interaction
%    - sFid         : Structure with the fiducials coordinates
%    - isExtraMaps  : If 1, create an extra folder "FreeSurfer" to save some of the
%                     FreeSurfer cortical maps (thickness, ...)
%    - isAseg       : If 1, imports the aseg atlas as a set of surfaces
% OUTPUT:
%    - errorMsg : String: error message if an error occurs


% Import ASEG atlas
if (nargin < 9) || isempty(isAseg)
    isAseg = 1;
end
if (nargin < 8) || isempty(quickLoad)
    quickLoad = 1;
end
if (nargin < 7) || isempty(resamplingMethod)
    resamplingMethod = 'reducepatch';
end
% Extract cortical maps
if (nargin < 6) || isempty(isExtraMaps)
    isExtraMaps = 0;
end
% Fiducials
if (nargin < 5) || isempty(sFid)
    sFid = [];
end
% Interactive / silent
if (nargin < 4) || isempty(isInteractive)
    isInteractive = 1;
end
% Ask number of vertices for the cortex surface
if (nargin < 3) || isempty(nVertices)
    nVertices = [];
end
% Initialize returned variable
errorMsg = [];
% Ask folder to the user
if (nargin < 1) || isempty(FsDir)
    % Get default import directory and formats
    LastUsedDirs = bst_get('LastUsedDirs');
    % Open file selection dialog
    FsDir = java_getfile( 'open', ...
        'Import FreeSurfer folder...', ...     % Window title
        bst_fileparts(LastUsedDirs.ImportAnat, 1), ...           % Last used directory
        'single', 'dirs', ...                  % Selection mode
        {{'.folder'}, 'FreeSurfer folder', 'FsDir'}, 0);
    % If no folder was selected: exit
    if isempty(FsDir)
        return
    end
    % Save default import directory
    LastUsedDirs.ImportAnat = FsDir;
    bst_set('LastUsedDirs', LastUsedDirs);
end
% Unload everything
bst_memory('UnloadAll', 'Forced');

%% ===== ASK NB VERTICES =====

% Number for each hemisphere
nVertHemi = round(nVertices / 2);


%% ===== PARSE FREESURFER FOLDER =====


% Find surfaces
TessLhFile = file_find(FsDir, 'lh.pial', 2);
TessRhFile = file_find(FsDir, 'rh.pial', 2);
TessLwFile = file_find(FsDir, 'lh.white', 2);
TessRwFile = file_find(FsDir, 'rh.white', 2);
TessLsphFile = file_find(FsDir, 'lh.sphere.reg', 2);
TessRsphFile = file_find(FsDir, 'rh.sphere.reg', 2);
TessInnerFile = file_find(FsDir, 'inner_skull-*.surf', 2);
TessOuterFile = file_find(FsDir, 'outer_skull-*.surf', 2);
if isempty(TessLhFile)
    errorMsg = [errorMsg 'Surface file was not found: lh.pial' 10];
end
if isempty(TessRhFile)
    errorMsg = [errorMsg 'Surface file was not found: rh.pial' 10];
end
% Find volume segmentation
AsegFile = file_find(FsDir, 'aseg.mgz', 2);
% Find labels
AnnotLhFiles = {file_find(FsDir, 'lh.pRF.annot', 2), file_find(FsDir, 'lh.aparc.a2009s.annot', 2), file_find(FsDir, 'lh.aparc.annot', 2), file_find(FsDir, 'lh.aparc.DKTatlas40.annot', 2), file_find(FsDir, 'lh.BA.annot', 2), file_find(FsDir, 'lh.BA.thresh.annot', 2), file_find(FsDir, 'lh.BA_exvivo.annot', 2), file_find(FsDir, 'lh.BA_exvivo.thresh.annot', 2), ...
                file_find(FsDir, 'lh.PALS_B12_Brodmann.annot', 2), file_find(FsDir, 'lh.PALS_B12_Lobes.annot', 2), file_find(FsDir, 'lh.PALS_B12_OrbitoFrontal.annot', 2), file_find(FsDir, 'lh.PALS_B12_Visuotopic.annot', 2), file_find(FsDir, 'lh.Yeo2011_7Networks_N1000.annot', 2), file_find(FsDir, 'lh.Yeo2011_17Networks_N1000.annot', 2)};
AnnotRhFiles = {file_find(FsDir, 'rh.pRF.annot', 2), file_find(FsDir, 'rh.aparc.a2009s.annot', 2), file_find(FsDir, 'rh.aparc.annot', 2), file_find(FsDir, 'rh.aparc.DKTatlas40.annot', 2), file_find(FsDir, 'rh.BA.annot', 2), file_find(FsDir, 'rh.BA.thresh.annot', 2), file_find(FsDir, 'rh.BA_exvivo.annot', 2), file_find(FsDir, 'rh.BA_exvivo.thresh.annot', 2), ...
                file_find(FsDir, 'rh.PALS_B12_Brodmann.annot', 2), file_find(FsDir, 'rh.PALS_B12_Lobes.annot', 2), file_find(FsDir, 'rh.PALS_B12_OrbitoFrontal.annot', 2), file_find(FsDir, 'rh.PALS_B12_Visuotopic.annot', 2), file_find(FsDir, 'rh.Yeo2011_7Networks_N1000.annot', 2), file_find(FsDir, 'rh.Yeo2011_17Networks_N1000.annot', 2)};
AnnotLhFiles(cellfun(@isempty, AnnotLhFiles)) = [];
AnnotRhFiles(cellfun(@isempty, AnnotRhFiles)) = [];
% Find thickness maps
if isExtraMaps
    ThickLhFile = file_find(FsDir, 'lh.thickness', 2);
    ThickRhFile = file_find(FsDir, 'rh.thickness', 2);
end

% Report errors
if ~isempty(errorMsg)
    if isInteractive
        bst_error(['Could not import FreeSurfer folder: ' 10 10 errorMsg], 'Import FreeSurfer folder', 0);        
    end
    return;
end



OffsetMri = [];



%% ===== IMPORT SURFACES =====
% Left pial
if ~isempty(TessLhFile)
    % Import file
    [TessLh, nVertOrigL] = my_import_surfaces(sMri, TessLhFile, 'FS', 0);
   [TessLh] = my_in_tess_bst( TessLh, 1 );
    % Load atlases
    if ~isempty(AnnotLhFiles) && ~quickLoad
        
        [sAllAtlas, err] = my_import_label(TessLh, AnnotLhFiles, 1);
        errorMsg = [errorMsg err];
    end
    % Load sphere
    if ~isempty(TessLsphFile) && ~quickLoad
       
        [TessMat, err] = my_tess_addsphere(TessLh, TessLsphFile);
        errorMsg = [errorMsg err];
    end
    % Downsample
   
    [TessLhLow, iLhLow, xLhLow] = my_tess_downsize(TessLh, nVertHemi, resamplingMethod);
    [TessLhLow] = my_in_tess_bst( TessLhLow, 1 );
end
% Right pial
if ~isempty(TessRhFile)
    % Import file
    [ TessRh, nVertOrigR] = my_import_surfaces(sMri, TessRhFile, 'FS', 0);
     [TessRh] = my_in_tess_bst( TessRh, 1 );
   
    % Load atlases
    if ~isempty(AnnotRhFiles)&& ~quickLoad
       
        [sAllAtlas, err] = my_import_label(TessRh, AnnotRhFiles, 1);
        errorMsg = [errorMsg err];
    end
    % Load sphere
    if ~isempty(TessRsphFile)&& ~quickLoad
       
        [TessMat, err] = my_tess_addsphere(TessRh, TessRsphFile);
        errorMsg = [errorMsg err];
    end
    % Downsample
  
    [TessRhLow, iRhLow, xRhLow] = my_tess_downsize(TessRh, nVertHemi, resamplingMethod);
      [TessRhLow] = my_in_tess_bst( TessRhLow, 1 );
end
% Left white matter
if ~isempty(TessLwFile)&& ~quickLoad
    % Import file
    [ TessLw] = my_import_surfaces(sMri, TessLwFile, 'FS', 0);
      [TessLw] = my_in_tess_bst( TessLw, 1 );
    % Load atlases
    if ~isempty(AnnotLhFiles)
       
        [sAllAtlas, err] = my_import_label(TessLw, AnnotLhFiles, 1);
        errorMsg = [errorMsg err];
    end
    if ~isempty(TessLsphFile)
     
        [TessMat, err] = my_tess_addsphere(TessLw, TessLsphFile);
        errorMsg = [errorMsg err];
    end
    % Downsample
   
    [TessLwLow, iLwLow, xLwLow] = my_tess_downsize(TessLw, nVertHemi, resamplingMethod);
      [TessLwLow] = my_in_tess_bst( TessLwLow, 1 );
end
% Right white matter
if ~isempty(TessRwFile)&& ~quickLoad
    % Import file
    [ TessRw] = my_import_surfaces(sMri, TessRwFile, 'FS', 0);
      [TessRw] = my_in_tess_bst( TessRw, 1 );
    % Load atlases
    if ~isempty(AnnotRhFiles)
       
        [sAllAtlas, err] = my_import_label(TessRw, AnnotRhFiles, 1);
        errorMsg = [errorMsg err];
    end
    % Load sphere
    if ~isempty(TessRsphFile)
     
        [TessMat, err] = my_tess_addsphere(TessRw, TessRsphFile);
        errorMsg = [errorMsg err];
    end
    % Downsample
   
    [TessRwLow, iRwLow, xRwLow] = my_tess_downsize(TessRw, nVertHemi, resamplingMethod);
      [TessRwLow] = my_in_tess_bst( TessRwLow, 1 );
end
% Process error messages
if ~isempty(errorMsg)
    if isInteractive
        bst_error(errorMsg, 'Import FreeSurfer folder', 0);
    else
        disp(['ERROR: ' errorMsg]);
    end
    return;
end
% Inner skull
if ~isempty(TessInnerFile)
    import_surfaces(iSubject, TessInnerFile, 'FS', 0);
end
% Outer skull
if ~isempty(TessOuterFile)
    import_surfaces(iSubject, TessOuterFile, 'FS', 0);
end


%% ===== GENERATE MID-SURFACE =====
if ~isempty(TessLhFile) && ~isempty(TessRhFile) && ~isempty(TessLwFile) && ~isempty(TessRwFile)&& ~quickLoad
 
    % Average pial and white surfaces
    TessLm = my_tess_average([TessLh, TessLw]);
     [TessLm] = my_in_tess_bst( TessLm, 1 );
    TessRm = my_tess_average([TessRh, TessRw]);
     [TessRm] = my_in_tess_bst( TessRm, 1 );
    % Downsample
    [TessLmLow iLmLow, xLmLow] = my_tess_downsize(TessLm, nVertHemi, resamplingMethod);
    [TessLmLow] = my_in_tess_bst( TessLmLow, 1 );
    [TessRmLow, iRmLow, xRmLow] = my_tess_downsize(TessRm, nVertHemi, resamplingMethod);
    [TessRmLow] = my_in_tess_bst( TessRmLow, 1 );
else
    MidHiFile = [];
end


%% ===== MERGE SURFACES =====
rmFiles = {};
% Merge hemispheres: pial
if ~isempty(TessLhFile) && ~isempty(TessRhFile)
    % Hi-resolution surface
    CortexHi  = my_tess_concatenate([TessLh,    TessRh],    sprintf('cortex_%dV', nVertOrigL + nVertOrigR), 'Cortex');
   [CortexHi] = my_in_tess_bst( CortexHi, 1 );
    CortexLow = my_tess_concatenate([TessLhLow, TessRhLow], sprintf('cortex_%dV', length(xLhLow) + length(xRhLow)), 'Cortex');
    [CortexLow] = my_in_tess_bst( CortexLow, 1 );

end
% Merge hemispheres: white
if ~isempty(TessLwFile) && ~isempty(TessRwFile)&& ~quickLoad
    % Hi-resolution surface
    WhiteHi  = my_tess_concatenate([TessLw,    TessRw],    sprintf('white_%dV', nVertOrigL + nVertOrigR), 'Cortex');
     [WhiteHi] = my_in_tess_bst( WhiteHi, 1 );
    WhiteLow = my_tess_concatenate([TessLwLow, TessRwLow], sprintf('white_%dV', length(xLwLow) + length(xRwLow)), 'Cortex');
    [WhiteLow] = my_in_tess_bst( WhiteLow, 1 );
    % Delete separate hemispheres
    
end
% Merge hemispheres: mid-surface
if ~isempty(TessLhFile) && ~isempty(TessRhFile) && ~isempty(TessLwFile) && ~isempty(TessRwFile)&& ~quickLoad
    % Hi-resolution surface
    MidHi  = my_tess_concatenate([TessLm,    TessRm],    sprintf('mid_%dV', nVertOrigL + nVertOrigR), 'Cortex');
     [MidHi] = my_in_tess_bst( MidHi, 1 );
    MidLow = my_tess_concatenate([TessLmLow, TessRmLow], sprintf('mid_%dV', length(xLmLow) + length(xRmLow)), 'Cortex');
   [MidLow] = my_in_tess_bst( MidLow, 1 );
end


%% ===== GENERATE HEAD =====
% Generate head surface
sMri = my_in_mri_bst(sMri);


%% ===== LOAD ASEG.MGZ =====
if isAseg && ~isempty(AsegFile)&& ~quickLoad
    % Import atlas
    [ Aseg] = my_import_surfaces(sMri, AsegFile, 'MRI-MASK', 0, OffsetMri);
    % Extract cerebellum only
    try
        BstCerebFile = my_tess_extract_struct(Aseg, {'Cerebellum L', 'Cerebellum R'}, 'aseg | cerebellum');
    catch
        BstCerebFile = [];
    end
    % If the cerebellum surface can be reconstructed
    if ~isempty(BstCerebFile)
        % Downsample cerebllum
        [BstCerebLowFile, iCerLow, xCerLow] = my_tess_downsize(BstCerebFile, 2000, 'reducepatch');
        [BstCerebLowFile] = my_in_tess_bst( BstCerebLowFile, 1 );
        % Merge with low-resolution pial
%         BstCerebLowFile.VertNormals = [];
%         BstCerebLowFile.Curvature = [];
%         BstCerebLowFile.SulciMap = [];
         BstCerebLowFile.tess2mri_interp = [];
         BstCerebLowFile.Reg = [];
%         BstCerebLowFile.VertConn = [];
%         if(isfield(CortexLow, 'Atlas'))
%              BstCerebLowFile.Atlas = [];
%         end
        MixedLow = my_tess_concatenate([CortexLow, BstCerebLowFile], sprintf('cortex_cereb_%dV', length(xLhLow) + length(xRhLow) + length(xCerLow)), 'Cortex');
        [MixedLow] = my_in_tess_bst( MixedLow, 1 );
        % Rename mixed file
        
    end
else
    BstAsegFile = [];
end


%% ===== IMPORT THICKNESS MAPS =====
if isExtraMaps && ~isempty(CortexHiFile) && ~isempty(ThickLhFile) && ~isempty(ThickLhFile)
    % Create a condition "FreeSurfer"
    iStudy = db_add_condition(iSubject, 'FreeSurfer');
    % Import cortical thickness
    ThickFile = import_sources(iStudy, CortexHiFile, ThickLhFile, ThickRhFile, 'FS');
end

