function [sHead] = my_tess_isohead(sMri, nVertices, erodeFactor, fillFactor, Comment)
% TESS_GENERATE: Reconstruct a head surface based on the MRI, based on an isosurface
%
% USAGE:  [HeadFile, iSurface] = tess_isohead(iSubject, nVertices=10000, erodeFactor=0, fillFactor=2, Comment)
%         [HeadFile, iSurface] = tess_isohead(MriFile,  nVertices=10000, erodeFactor=0, fillFactor=2, Comment)

% @=============================================================================
% This function is part of the Brainstorm software:
% http://neuroimage.usc.edu/brainstorm
% 
% Copyright (c)2000-2018 University of Southern California & McGill University
% This software is distributed under the terms of the GNU General Public License
% as published by the Free Software Foundation. Further details on the GPLv3
% license can be found at http://www.gnu.org/copyleft/gpl.html.
% 
% FOR RESEARCH PURPOSES ONLY. THE SOFTWARE IS PROVIDED "AS IS," AND THE
% UNIVERSITY OF SOUTHERN CALIFORNIA AND ITS COLLABORATORS DO NOT MAKE ANY
% WARRANTY, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, NOR DO THEY ASSUME ANY
% LIABILITY OR RESPONSIBILITY FOR THE USE OF THIS SOFTWARE.
%
% For more information type "brainstorm license" at command prompt.
% =============================================================================@
%
% Authors: Francois Tadel, 2012-2016

%% ===== PARSE INPUTS =====
% Initialize returned variables

% Parse inputs
if (nargin < 5) || isempty(Comment)
    Comment = [];
end

% Ask user to set the parameters if they are not set
if (nargin < 4) || isempty(erodeFactor) || isempty(nVertices)
    res = java_dialog('input', {'Number of vertices [integer]:', 'Erode factor [0,1,2,3]:', 'Fill holes factor [0,1,2,3]:'}, 'Generate head surface', [], {'10000', '0', '2'});
    % If user cancelled: return
    if isempty(res)
        return
    end
    % Get new values
    nVertices   = str2num(res{1});
    erodeFactor = str2num(res{2});
    fillFactor  = str2num(res{3});
end
% Check parameters values
if isempty(nVertices) || (nVertices < 50) || (nVertices ~= round(nVertices)) || isempty(erodeFactor) || ~ismember(erodeFactor,[0,1,2,3]) || isempty(fillFactor) || ~ismember(fillFactor,[0,1,2,3])
    bst_error('Invalid parameters.', 'Head surface', 0);
    return
end






% Check that everything is there
if ~isfield(sMri, 'Histogram') || isempty(sMri.Histogram) || isempty(sMri.SCS) || isempty(sMri.SCS.NAS) || isempty(sMri.SCS.LPA) || isempty(sMri.SCS.RPA)
    bst_error('You need to set the fiducial points in the MRI first.', 'Head surface', 0);
    return
end
% Threshold mri to the level estimated in the histogram
headmask = (sMri.Cube > sMri.Histogram.bgLevel);
% Closing all the faces of the cube
headmask(1,:,:)   = 0*headmask(1,:,:);
headmask(end,:,:) = 0*headmask(1,:,:);
headmask(:,1,:)   = 0*headmask(:,1,:);
headmask(:,end,:) = 0*headmask(:,1,:);
headmask(:,:,1)   = 0*headmask(:,:,1);
headmask(:,:,end) = 0*headmask(:,:,1);
% Erode + dilate, to remove small components
if (erodeFactor > 0)
    headmask = headmask & ~mri_dilate(~headmask, erodeFactor);
    headmask = mri_dilate(headmask, erodeFactor);
end

headmask = (mri_fillholes(headmask, 1) & mri_fillholes(headmask, 2) & mri_fillholes(headmask, 3));

% view_mri_slices(headmask, 'x', 20)


%% ===== CREATE SURFACE =====
% Compute isosurface
[sHead.Faces, sHead.Vertices] = mri_isosurface(headmask, 0.5);

% Downsample to a maximum number of vertices
maxIsoVert = 60000;
if (length(sHead.Vertices) > maxIsoVert)
    [sHead.Faces, sHead.Vertices] = reducepatch(sHead.Faces, sHead.Vertices, maxIsoVert./length(sHead.Vertices));
  
end
% Remove small objects
[sHead.Vertices, sHead.Faces] = tess_remove_small(sHead.Vertices, sHead.Faces);


% Downsampling isosurface
[sHead.Faces, sHead.Vertices] = reducepatch(sHead.Faces, sHead.Vertices, nVertices./length(sHead.Vertices));

% Convert to millimeters
sHead.Vertices = sHead.Vertices(:,[2,1,3]);
sHead.Faces    = sHead.Faces(:,[2,1,3]);
sHead.Vertices = bst_bsxfun(@times, sHead.Vertices, sMri.Voxsize);
% Convert to SCS
sHead.Vertices = cs_convert(sMri, 'mri', 'scs', sHead.Vertices ./ 1000);

% Reduce the final size of the meshed volume
erodeFinal = 3;
% Fill holes in surface
%if (fillFactor > 0)
  
    [sHead.Vertices, sHead.Faces] = tess_fillholes(sMri, sHead.Vertices, sHead.Faces, fillFactor, erodeFinal);
  
% end







