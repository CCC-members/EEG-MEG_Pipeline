function [NewTess, nVertices] = my_import_surfaces(sMri, SurfaceFiles, FileFormat, isApplyMriOrient, OffsetMri)
% IMPORT_SURFACES: Import a set of surfaces in a Subject of Brainstorm database.
% 
%
%    - SurfaceFiles : Cell array of full filenames of the surfaces to import (format is autodetected)
%                     => if not specified : files to import are asked to the user
%    - FileFormat   : String representing the file format to import.
%                     Please see in_tess.m to get the list of supported file formats
%    - isApplyMriOrient: {0,1}
%    - OffsetMri    : (x,y,z) values to add to the coordinates of the surface before converting it to SCS
%
% OUTPUT:
%    - iNewSurfaces : Indices of the surfaces added in database

%% ===== PARSE INPUTS =====
% Check command line

if (nargin < 3) || isempty(SurfaceFiles)
    SurfaceFiles = {};
    FileFormat = [];
else
    if ischar(SurfaceFiles)
        SurfaceFiles = {SurfaceFiles};
    end
    if (nargin == 2) || ((nargin >= 3) && isempty(FileFormat))
        error('When you pass a SurfaceFiles argument, FileFormat must be defined too.');
    end
end
if (nargin < 4) || isempty(isApplyMriOrient)
    isApplyMriOrient = [];
end
if (nargin < 5) || isempty(OffsetMri)
    OffsetMri = [];
end

nVertices = [];


%% ===== LOAD EACH SURFACE =====
% Process all the selected surfaces
for iFile = 1:length(SurfaceFiles)
    TessFile = SurfaceFiles{iFile};
    
    % ===== LOAD SURFACE FILE =====
  
    % Load surfaces(s)
    Tess = in_tess(TessFile, FileFormat, sMri, OffsetMri);
    if isempty(Tess)
        bst_progress('stop');
        return
    end
    
    % ===== INITIALIZE NEW SURFACE =====
    % Get imported base name
    if strcmpi(FileFormat, 'FS')
        [tmp__, fBase, fExt] = bst_fileparts(TessFile);
        importedBaseName = [fBase, strrep(fExt, '.', '_')];
    else
        [tmp__, importedBaseName] = bst_fileparts(TessFile);
    end
    importedBaseName = strrep(importedBaseName, 'tess_', '');
    importedBaseName = strrep(importedBaseName, '_tess', '');
    % Only one surface
    if (length(Tess) == 1)
        NewTess = db_template('surfacemat');
        NewTess.Comment  = Tess(1).Comment;
        NewTess.Vertices = Tess(1).Vertices;
        NewTess.Faces    = Tess(1).Faces;
    % Multiple surfaces
    else
        [Tess(:).Atlas] = deal(db_template('Atlas'));
        NewTess = my_tess_concatenate(Tess);
        if strcmpi(importedBaseName, 'aseg')
            NewTess.Comment = 'aseg atlas';
        else
            NewTess.Comment = importedBaseName;
        end
        NewTess.iAtlas  = find(strcmpi({NewTess.Atlas.Name}, 'Structures'));
    end

    % ===== APPLY MRI ORIENTATION =====
    if isApplyMriOrient
        % History: Apply MRI transformation
        NewTess = bst_history('add', NewTess, 'import', 'Apply transformation that was applied to the MRI volume');
        % Apply MRI transformation
        NewTess = applyMriTransf(sMri.InitTransf, NewTess);
    end

   
end


end   


%% ======================================================================================
%  ===== HELPER FUNCTIONS ===============================================================
%  ======================================================================================
%% ===== APPLY MRI ORIENTATION =====
function sSurf = applyMriTransf(MriTransf, sSurf)
    pts = sSurf.Vertices;
    % Apply step by step all the transformations that have been applied to the MRI
    for i = 1:size(MriTransf,1)
        ttype = MriTransf{i,1};
        val   = MriTransf{i,2};
        switch (ttype)
            case 'flipdim'
                % Detect the dimensions that have constantly negative coordinates
                iDimNeg = find(sum(sign(pts) == -1) == size(pts,1));
                if ~isempty(iDimNeg)
                    pts(:,iDimNeg) = -pts(:,iDimNeg);
                end
                % Flip dimension
                pts(:,val(1)) = val(2)/1000 - pts(:,val(1));
                % Restore initial negative values
                if ~isempty(iDimNeg)
                    pts(:,iDimNeg) = -pts(:,iDimNeg);
                end
            case 'permute'
                pts = pts(:,val);
            case 'vox2ras'
                
        end
    end
    % Report changes in structure
    sSurf.Vertices = pts;
    % Update faces order: If the surfaces were flipped an odd number of times, invert faces orientation
    if (mod(nnz(strcmpi(MriTransf(:,1), 'flipdim')), 2) == 1)
        sSurf.Faces = sSurf.Faces(:,[1 3 2]);
    end
end




    
