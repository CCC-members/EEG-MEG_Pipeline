function [sSurf, iSurface] = my_tess_extract_struct( sSurf, StructNames, NewComment )
% TESS_EXTRACT_STRUCT: Extract a few structures from a surface file (based on the "Structures" atlas).
%
% USAGE:  [NewSurfaceFile, iSurface] = tess_concatenate(SurfaceFile, StructNames, NewComment='')
% 
% INPUT: 
%    - SurfaceFile : File name of the surface file to process
%    - StructNames : Cell-array of structure names to extract from the selected file
%    - NewComment  : Name of the output surface
% OUTPUT:
%    - NewSurfaceFile : Filename of the newly created file
%    - iSurface    : Index of the new surface file



% Parse inputs
if (nargin < 3) || isempty(NewComment)
    NewComment = [];
end
if ischar(StructNames)
    StructNames = {StructNames};
end

% ===== LOAD FILE =====
% Progress bar

% Load file

if isempty(sSurf)
    return;
end
% Find atlas "Structures"
iAtlas = find(strcmpi({sSurf.Atlas.Name}, 'Structures'));
if isempty(iAtlas)
    error('Atlas "Structures" not found in this file.');
end
% Find all the scout names listed in input
[tmp,iScouts] = intersect(lower({sSurf.Atlas(iAtlas).Scouts.Label}), lower(StructNames));
if isempty(iScouts)
    error('Requested regions were not found.');
end

% ===== REMOVE VERTICES =====
% Get all the vertices in the selected scouts
iKeepVert = [sSurf.Atlas(iAtlas).Scouts(iScouts).Vertices];
% Get all the vertices to remove
iRemoveVert = setdiff(1:size(sSurf.Vertices,1), iKeepVert);
% Remove vertices
[sSurf.Vertices, sSurf.Faces, sSurf.Atlas] = tess_remove_vert(sSurf.Vertices, sSurf.Faces, iRemoveVert, sSurf.Atlas);

% ===== CREATE NEW STRUCTURE =====
% Comment
if ~isempty(NewComment)
    sSurf.Comment = NewComment;
elseif (length(StructNames) == 1)
    sSurf.Comment = [sSurf.Comment ' | ' StructNames{1}];
elseif (length(StructNames) == 2) && (length(StructNames{1}) > 2) && (length(StructNames{2}) > 2) && strcmpi(StructNames{1}(1:end-2), StructNames{2}(1:end-2))
    sSurf.Comment = [sSurf.Comment ' | ' StructNames{1}(1:end-2)];
else
    sSurf.Comment = [sSurf.Comment ' | keep'];
end









