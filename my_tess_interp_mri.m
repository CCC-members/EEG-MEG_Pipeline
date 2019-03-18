function [ tess2mri_interp ] = my_tess_interp_mri( MRI,sSurf )
Vertices = sSurf.Vertices;
Faces    = sSurf.Faces;
% Vertices: SCS->Voxels
Vertices = cs_convert(MRI, 'scs', 'voxel', Vertices);
cubeSize = size(MRI.Cube);

% ===== CHECK VERTICES LOCATION =====
% Get all the vertices that are outside the MRI volume
iOutsideVert = find((Vertices(:,1) >= cubeSize(1)) | (Vertices(:,1) < 2) | ...
                    (Vertices(:,2) >= cubeSize(2)) | (Vertices(:,2) < 2) | ...
                    (Vertices(:,3) >= cubeSize(3)) | (Vertices(:,3) < 2));
% Compute percentage of vertices outside the MRI
percentOutside = length(iOutsideVert) / length(Vertices);
% If more than 95% vertices are outside the MRI volume : exit with ar error message
if (percentOutside > .95)
    tess2mri_interp = [];
    java_dialog('error', ['Surface is not registered with the MRI.' 10 'Please try to import all your surfaces again.'], 'Surface -> MRI');
    return;
% If more than 10% vertices are outside the MRI volume : display warning message
elseif (percentOutside > .4)
    java_dialog('warning', ['Surface does not seem to be registered with the MRI.', 10 10 ...
                'Please right-click on surface node and execute' 10 ' "Align>Align all surfaces...".'], ...
                'Surface -> MRI');
end


% ===== INTERPOLATION SURFACE -> MRI =====

% If interpolation matrix already computed:
if isfield(sSurf, 'tess2mri_interp') && ~isempty(sSurf.tess2mri_interp)
    tess2mri_interp = sSurf.tess2mri_interp;
% Else: Compute it 
else
    % Compute interpolation matrix from tessellation to MRI voxel grid
    tess2mri_interp = tess_tri_interp(Vertices, Faces, cubeSize,0);
    
end

end

