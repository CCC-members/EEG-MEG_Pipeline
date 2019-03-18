function [ sMri ] = my_bst_normalize_mni( FsDir )

% Find MRI
MriFile = file_find(FsDir, 'T1.mgz', 3);
if isempty(MriFile)
    errorMsg = [errorMsg 'MRI file was not found: T1.mgz' 10];
end

sMri=db_template('mrimat');
sMriAux = in_mri(MriFile, 'ALL', 0);

sMri.Voxsize=sMriAux.Voxsize;
sMri.Cube=sMriAux.Cube;
sMri.Header=sMriAux.Header;
sMri.InitTransf=sMriAux.InitTransf;

% Resample volume if needed
if any(abs(sMri.Voxsize - [1 1 1]) > 0.001)
    [sMriRes, Tres] = mri_resample(sMri, [256 256 256], [1 1 1]);
else
    sMriRes = sMri;
    Tres = [];
end


%% ===== ESTIMATE MNI TRANSFORMATION =====
% Compute affine transformation to MNI space
try
    Tmni = mri_register_maff(sMriRes);
    % Transf = mri_register_ls(sMri);
catch
    errMsg = ['mri_register_maff: ' lasterr()];
    sMri = [];
    return;
end
% Append the resampling transformation matrix
if ~isempty(Tres)
    Tmni = Tmni * Tres;
end


%% ===== SAVE RESULTS =====
bst_progress('start', 'Normalize anatomy', 'Saving results...');
% Save results into the MRI structure
sMri.NCS.R = Tmni(1:3,1:3);
sMri.NCS.T = Tmni(1:3,4);
% Compute default fiducials positions based on MNI coordinates
sMri = mri_set_default_fid(sMri);


% % Find fiducials definitions
% FidFile = file_find(FsDir, 'fiducials.m');
% %% ===== IMPORT MRI =====
% % Read MRI
% sMri = in_mri(MriFile, 'ALL', 0);
% % Size of the volume
% cubeSize = (size(sMri.Cube) - 1) .* sMri.Voxsize;
% 
% %% ===== DEFINE FIDUCIALS =====
% % If fiducials file exist: read it
% OffsetMri = [];
% isComputeMni = 1;
% if ~isempty(FidFile)
%     % Execute script
%     fid = fopen(FidFile, 'rt');
%     FidScript = fread(fid, [1 Inf], '*char');
%     fclose(fid);
%     % Execute script
%     eval(FidScript);    
%     % If not all the fiducials were loaded: ignore the file
%     if ~exist('NAS', 'var') || ~exist('LPA', 'var') || ~exist('RPA', 'var') || isempty(NAS) || isempty(LPA) || isempty(RPA)
%         FidFile = [];
%     end
%     % If the normalized points were not defined: too bad...
%     if ~exist('AC', 'var')
%         AC = [];
%     end
%     if ~exist('PC', 'var')
%         PC = [];
%     end
%     if ~exist('IH', 'var')
%         IH = [];
%     end
%     % NOTE THAT THIS FIDUCIALS FILE CAN CONTAIN A LINE: "isComputeMni = 1;"
% end
% % Random or predefined points
% if  ~isempty(FidFile)
%     % Use fiducials from file
%     if ~isempty(FidFile)
%         % Already loaded
%     % Compute them from MNI transformation
%     elseif isempty(sFid)
% %         NAS = [cubeSize(1)./2,  cubeSize(2),           cubeSize(3)./2];
% %         LPA = [1,               cubeSize(2)./2,        cubeSize(3)./2];
% %         RPA = [cubeSize(1),     cubeSize(2)./2,        cubeSize(3)./2];
% %         AC  = [cubeSize(1)./2,  cubeSize(2)./2 + 20,   cubeSize(3)./2];
% %         PC  = [cubeSize(1)./2,  cubeSize(2)./2 - 20,   cubeSize(3)./2];
% %         IH  = [cubeSize(1)./2,  cubeSize(2)./2,        cubeSize(3)./2 + 50];
%         NAS = [];
%         LPA = [];
%         RPA = [];
%         AC  = [];
%         PC  = [];
%         IH  = [];
%         isComputeMni = 1;
%         warning('BST> Import anatomy: Anatomical fiducials were not defined, using standard MNI positions for NAS/LPA/RPA.');
%     % Else: use the defined ones
%     else
%         NAS = sFid.NAS;
%         LPA = sFid.LPA;
%         RPA = sFid.RPA;
%         AC = sFid.AC;
%         PC = sFid.PC;
%         IH = sFid.IH;
%         % If the NAS/LPA/RPA are defined, but not the others: Compute them
%         if ~isempty(NAS) && ~isempty(LPA) && ~isempty(RPA) && isempty(AC) && isempty(PC) && isempty(IH)
%             isComputeMni = 1;
%         end
%     end
%     if ~isempty(NAS) || ~isempty(LPA) || ~isempty(RPA) || ~isempty(AC) || ~isempty(PC) || ~isempty(IH)
%         figure_mri('SetSubjectFiducials', iSubject, NAS, LPA, RPA, AC, PC, IH);
%     end
% % Define with the MRI Viewer
% else
%        % Resample volume if needed
%     if any(abs(sMri.Voxsize - [1 1 1]) > 0.001)
%         [sMriRes, Tres] = mri_resample(sMri, [256 256 256], [1 1 1]);
%     else
%         sMriRes = sMri;
%         Tres = [];
%     end
%     %% ===== ESTIMATE MNI TRANSFORMATION =====
%     % Compute affine transformation to MNI space
% %     try
%         Tmni = mri_register_maff(sMriRes);
%         % Transf = mri_register_ls(sMri);
% %     catch
% %         errMsg = ['mri_register_maff: ' lasterr()];
% %         sMri = [];
% %         return;
% %     end
%     % Append the resampling transformation matrix
%     if ~isempty(Tres)
%         Tmni = Tmni * Tres;
%     end
% 
% 
%     %% ===== SAVE RESULTS =====
%   
%     % Save results into the MRI structure
%     sMri.NCS.R = Tmni(1:3,1:3);
%     sMri.NCS.T = Tmni(1:3,4);
%     % Compute default fiducials positions based on MNI coordinates
%     sMri = mri_set_default_fid(sMri);
% end
% 
% if ~isComputeMni && (~isfield(sMri, 'SCS') || isempty(sMri.SCS) || isempty(sMri.SCS.NAS) || isempty(sMri.SCS.LPA) || isempty(sMri.SCS.RPA) || isempty(sMri.SCS.R))
%     errorMsg = ['Could not import FreeSurfer folder: ' 10 10 'Some fiducial points were not defined properly in the MRI.'];
%     if isInteractive
%         bst_error(errorMsg, 'Import FreeSurfer folder', 0);
%     end
%     return;
% end

end

