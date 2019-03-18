function [ sEnvelope ] = my_tess_envelope( sSurface,sMri, method, nvert,scale )
if (nargin < 5) || isempty(scale)
    scale = [];
end
%% ===== SURFACE ENVELOPE =====
switch lower(method)
    % Using convex hull of the surface
    case 'convhull'
        % Compute the convex envelope of the surface
        env_vert = double(sSurface.Vertices);
        Faces = convhulln(env_vert);
        % Get the vertices that are used
        iVert = unique(Faces(:));
        % Remove the unused vertices
        iRemoveVert = setdiff(1:length(env_vert), iVert);
        [env_vert, env_faces] = tess_remove_vert(env_vert, Faces, iRemoveVert);
        % Smooth envelope
        % bst_progress('text', 'Envelope: Smoothing surface...');
        % env_vertconn = tess_vertconn(env_vert, env_faces);
        % env_vert = tess_smooth(env_vert, 1, 2, env_vertconn);

    % Using an MRI mask
    case {'mask_cortex', 'mask_head'}
        % Compute/get MRI mask for the surface
        mrimask =sSurface.mrimask;
        
        % Fill holes
       
        if strcmpi(method, 'mask_cortex')
            mrimask = mri_fillholes(mrimask, 3);
        else
            mrimask = mri_fillholes(mrimask, 2);
            mrimask = mri_fillholes(mrimask, 1);
        end
        % Closing all the faces of the cube
        mrimask(1,:,:)   = 0*mrimask(1,:,:);
        mrimask(end,:,:) = 0*mrimask(1,:,:);
        mrimask(:,1,:)   = 0*mrimask(:,1,:);
        mrimask(:,end,:) = 0*mrimask(:,1,:);
        mrimask(:,:,1)   = 0*mrimask(:,:,1);
        mrimask(:,:,end) = 0*mrimask(:,:,1);
        % Erode one layer of the mask
        if strcmpi(method, 'mask_head')
            mrimask = mrimask & ~mri_dilate(~mrimask, 1);
            mrimask = mrimask & ~mri_dilate(~mrimask, 1);
        end
        % Compute isosurface
        
        fv = isosurface(mrimask);
        env_vert = fv.vertices;
        env_faces = fv.faces;
        % Smooth isosurface
        env_vertconn = tess_vertconn(env_vert, env_faces);
        env_vert = tess_smooth(env_vert, 1, 10, env_vertconn, 0);
        % Downsampling isosurface
      
        [env_faces, env_vert] = reducepatch(env_faces, env_vert, 10000./length(env_vert));
        % Convert in millimeters
        env_vert = env_vert(:,[2,1,3]);
        env_vert = bst_bsxfun(@times, env_vert, sMri.Voxsize);
        % Convert in SCS coordinates
        env_vert = cs_convert(sMri, 'mri', 'scs', env_vert ./ 1000);
end
% Refine the faces that are too big
[env_vert, env_faces] = tess_refine(env_vert, env_faces, 3);
[env_vert, env_faces] = tess_refine(env_vert, env_faces, 3);


%% ===== RE-ORIENT ENVELOPE =====
% Compute the center of the head
head_center = mean(env_vert);
% Center head on (0,0,0)
env_vert = bst_bsxfun(@minus, env_vert, head_center);
% Orient in Talairach coordinate system (just the axes, not the coordinates
Transf = cs_compute(sMri, 'tal');
if isempty(Transf)
    error('Could not compute the MRI=>TAL transformation.');
end
R = Transf.R';
T = Transf.T';
env_vert = env_vert * R;


%% ===== REMESH ENVELOPE =====

[sph_vert, sph_faces] = tess_remesh(double(env_vert), nvert);


%% ===== CREATE OUTPUT STRUCTURE =====
% Rescale
if ~isempty(scale)
    % Convert to spherical coordinates
    [sph_th,sph_phi,sph_r] = cart2sph(sph_vert(:,1), sph_vert(:,2), sph_vert(:,3));
    % Apply scale to radius
    sph_r = sph_r + scale;
    % Convert back to cartesian coordinates
    [sph_vert(:,1),sph_vert(:,2),sph_vert(:,3)] = sph2cart(sph_th, sph_phi, sph_r);
end
% Restore initial coordinate system
sph_vert = sph_vert * inv(R);
sph_vert = bst_bsxfun(@plus, sph_vert, head_center);
% Create returned structure
sEnvelope.Vertices = sph_vert;
sEnvelope.Faces    = sph_faces;
sEnvelope.R        = R;
sEnvelope.T        = T;
sEnvelope.center   = head_center;
sEnvelope.NCS      = sMri.NCS;
sEnvelope.SCS      = sMri.SCS;



end

