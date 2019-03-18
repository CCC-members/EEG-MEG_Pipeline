function [sAllAtlas, Messages] = my_import_label(sSurf, LabelFiles, isNewAtlas, GridLoc)
% IMPORT_LABEL: Import an atlas segmentation for a given surface
% 
% USAGE: import_label(SurfaceFile, LabelFiles, isNewAtlas=1, GridLoc=[]) : Add label information to SurfaceFile
%        import_label(SurfaceFile)                                       : Ask the user for the label file to import



import sun.misc.BASE64Decoder;


%% ===== GET FILES =====
sAllAtlas = repmat(db_template('Atlas'), 0);
Messages = [];
% Parse inputs
if (nargin < 4) || isempty(GridLoc)
    GridLoc = [];
end
if (nargin < 3) || isempty(isNewAtlas)
    isNewAtlas = 1;
end
if (nargin < 2) || isempty(LabelFiles)
    LabelFiles = [];
end

% CALL: import_label(SurfaceFile)
if isempty(LabelFiles)
    % Get last used folder
    LastUsedDirs = bst_get('LastUsedDirs');
    DefaultFormats = bst_get('DefaultFormats');
    % Get label files
    [LabelFiles, FileFormat] = java_getfile( 'open', ...
       'Import labels...', ...        % Window title
       LastUsedDirs.ImportAnat, ...   % Default directory
       'multiple', 'files', ...       % Selection mode
       bst_get('FileFilters', 'labelin'), ...
       DefaultFormats.LabelIn);
    % If no file was selected: exit
    if isempty(LabelFiles)
        return
    end
	% Save last used dir
    LastUsedDirs.ImportAnat = bst_fileparts(LabelFiles{1});
    bst_set('LastUsedDirs',  LastUsedDirs);
    % Save default export format
    DefaultFormats.LabelIn = FileFormat;
    bst_set('DefaultFormats',  DefaultFormats);
% CALL: import_label(SurfaceFile, LabelFiles)
else
    % Force cell input
    if ~iscell(LabelFiles)
        LabelFiles = {LabelFiles};
    end
    % Detect file format based on file extension
    [fPath, fBase, fExt] = bst_fileparts(LabelFiles{1});
    switch (fExt)
        case '.annot',  FileFormat = 'FS-ANNOT';
        case '.label',  FileFormat = 'FS-LABEL';
        case '.gii',    FileFormat = 'GII-TEX';
        case '.mat',    FileFormat = 'BST';
        case '.dfs',    FileFormat = 'DFS';
        case '.dset',   FileFormat = 'DSET';
        otherwise,      Messages = 'Unknown file extension.'; return;
    end
end


%% ===== READ FILES =====
% Read destination surface

if isempty(sSurf)
    isLoadedHere = 1;
    sSurf = bst_memory('LoadSurface', file_short(SurfaceFile));
    panel_scout('SetCurrentSurface', sSurf.FileName);
else
    isLoadedHere = 0;
end
% Process one after the other
for iFile = 1:length(LabelFiles)
    % Get updated atlases after the first iteration
    
    % Use the grid of points provided in input if available
    if ~isempty(GridLoc)
        Vertices = GridLoc;
        isVolumeAtlas = 1;
    % Otherwise, use the vertices of the cortex surface
    else
        Vertices = sSurf.Vertices;
        isVolumeAtlas = 0;
    end
    % Get filename
    [fPath, fBase, fExt] = bst_fileparts(LabelFiles{iFile});
    % New atlas structure: use filename as the atlas name
    if isNewAtlas || isempty(sSurf.Atlas) || isempty(sSurf.iAtlas)
        sAtlas = db_template('Atlas');
        iAtlas = 'Add';
        % Volume sources file
        if ~isempty(GridLoc)
            sAtlas.Name = sprintf('Volume %d: %s', length(GridLoc), fBase);
            sAtlas.Name = file_unique(sAtlas.Name, {sSurf.Atlas.Name});
        % Surface sources file
        else
            % FreeSurfer Atlas names
            switch (fBase)
                case {'lh.pRF', 'rh.pRF'}
                    sAtlas.Name = 'Retinotopy';
                case {'lh.aparc.a2009s', 'rh.aparc.a2009s'}
                    sAtlas.Name = 'Destrieux';
                case {'lh.aparc', 'rh.aparc'}
                    sAtlas.Name = 'Desikan-Killiany';
                case {'lh.BA', 'rh.BA', 'lh.BA_exvivo', 'rh.BA_exvivo'}
                    sAtlas.Name = 'Brodmann';
                case {'lh.BA.thresh', 'rh.BA.thresh', 'lh.BA_exvivo.thresh', 'rh.BA_exvivo.thresh'}
                    sAtlas.Name = 'Brodmann-thresh';
                case {'lh.aparc.DKTatlas40', 'rh.aparc.DKTatlas40'}
                    sAtlas.Name = 'Mindboggle';
                case {'lh.PALS_B12_Brodmann', 'rh.PALS_B12_Brodmann'}
                    sAtlas.Name = 'PALS-B12 Brodmann';
                case {'lh.PALS_B12_Lobes', 'rh.PALS_B12_Lobes'}
                    sAtlas.Name = 'PALS-B12 Lobes';
                case {'lh.PALS_B12_OrbitoFrontal', 'rh.PALS_B12_OrbitoFrontal'}
                    sAtlas.Name = 'PALS-B12 Orbito-frontal';
                case {'lh.PALS_B12_Visuotopic', 'rh.PALS_B12_Visuotopic'}
                    sAtlas.Name = 'PALS-B12 Visuotopic';
                case {'lh.Yeo2011_7Networks_N1000', 'rh.Yeo2011_7Networks_N1000'}
                    sAtlas.Name = 'Yeo 7 Networks';
                case {'lh.Yeo2011_17Networks_N1000', 'rh.Yeo2011_17Networks_N1000'}
                    sAtlas.Name = 'Yeo 17 Networks';
                otherwise
                    sAtlas.Name = fBase;
            end
        end
    % Existing atlas structure
    else
        iAtlas = sSurf.iAtlas;
        sAtlas = sSurf.Atlas(iAtlas);
        % For volume source files: Can only import volume scouts
        if ~isempty(GridLoc)
            % Can only work with volume scouts
            [isVolumeAtlas, nAtlasGrid] = panel_scout('ParseVolumeAtlas', sAtlas.Name);
            if ~isVolumeAtlas
                Messages = [Messages, 'Error: You can only load volume scouts for this sources file.'];
                return;
            end
            % Check the number of sources
            if (length(GridLoc) ~= nAtlasGrid)
                Messages = [Messages, sprintf('Error: The number of grid points in this sources file (%d) does not match the selected atlas (%d).', length(GridLoc), nAtlasGrid)];
                return;
            end
        end
    end
    % Check that atlas have the correct structure
    if isempty(sAtlas.Scouts)
        sAtlas.Scouts = repmat(db_template('scout'), 0);
    end
    % Switch based on file format
    switch (FileFormat)
        % ===== FREESURFER ANNOT =====
        case 'FS-ANNOT'
            % === READ FILE ===
            % Read label file
            [vertices, labels, colortable] = read_annotation(LabelFiles{iFile}, 0);
            % Check sizes
            if (length(labels) ~= length(Vertices))
                Messages = [Messages, sprintf('%s:\nNumbers of vertices in the surface (%d) and the label file (%d) do not match\n', fBase, length(Vertices), length(labels))];
                continue
            end

            % === CONVERT TO SCOUTS ===
            % Convert to scouts structures
            lablist = unique(labels);
            % Loop on each label
            for i = 1:length(lablist)
                % Find entry in the colortable
                iTable = find(colortable.table(:,5) == lablist(i));
                % If correspondence not defined: ignore label
                if (length(iTable) ~= 1)
                    continue;
                end
                % New scout index
                iScout = length(sAtlas.Scouts) + 1;
                sAtlas.Scouts(iScout).Vertices = find(labels == lablist(i))';
                sAtlas.Scouts(iScout).Label    = file_unique(colortable.struct_names{iTable}, {sAtlas.Scouts.Label});
                sAtlas.Scouts(iScout).Color    = colortable.table(iTable,1:3) ./ 255;
                sAtlas.Scouts(iScout).Function = 'Mean';
                sAtlas.Scouts(iScout).Region   = 'UU';
            end
            if isempty(sAtlas.Scouts)
                Messages = [Messages, fBase, ':' 10 'Could not match labels and color table.' 10];
                continue;
            end

        % ==== FREESURFER LABEL ====
        case 'FS-LABEL'
            % === READ FILE ===
            % Read label file
            LabelMat = mne_read_label_file(LabelFiles{iFile});
            % Convert indices from 0-based to 1-based
            LabelMat.vertices = LabelMat.vertices + 1;
            % Check sizes
            if (max(LabelMat.vertices) > length(Vertices))
                Messages = [Messages, sprintf('%s:\nNumbers of vertices in the label file (%d) exceeds the number of vertices in the surface (%d)\n', fBase, max(LabelMat.vertices), length(Vertices))];
                continue
            end
            % === CONVERT TO SCOUTS ===
            % Convert to scouts structures
            uniqueValues = unique(LabelMat.values);
            minmax = [min(uniqueValues), max(uniqueValues)];
            % Loop on each label
            for i = 1:length(uniqueValues)
                % New scout index
                iScout = length(sAtlas.Scouts) + 1;
                % Calculate intensity [0,1]
                if (minmax(1) == minmax(2))
                    c = 0;
                else
                    c = (uniqueValues(i) - minmax(1)) ./ (minmax(2) - minmax(1));
                end
                % Create structure
                sAtlas.Scouts(iScout).Vertices = sort(double(LabelMat.vertices(LabelMat.values == uniqueValues(i))));
                sAtlas.Scouts(iScout).Seed     = [];
                sAtlas.Scouts(iScout).Label    = file_unique(num2str(uniqueValues(i)), {sAtlas.Scouts.Label});
                sAtlas.Scouts(iScout).Color    = [1 c 0];
                sAtlas.Scouts(iScout).Function = 'Mean';
                sAtlas.Scouts(iScout).Region   = 'UU';
            end
            if isempty(sAtlas.Scouts)
                Messages = [Messages, fBase, ':' 10 'Could not match labels and color table.' 10];
                continue;
            end
            
        % ==== BRAINVISA GIFTI =====
        case 'GII-TEX'
            % Remove the "L" and "R" strings from the name
            AtlasName = sAtlas.Name;
            AtlasName = strrep(AtlasName, 'R', '');
            AtlasName = strrep(AtlasName, 'L', '');
            % Read .gii file
            [sXml, Values] = in_gii(LabelFiles{iFile});
            % If there is more than one entry: force adding
            if (length(Values) > 1)
                iAtlas = 'Add';
            end
            % Process all the entries
            for ia = 1:length(Values)
                % Atlas name
                if (length(Values) > 1) && isNewAtlas
                    sAtlas(ia).Name = sprintf('%s #%d', AtlasName, ia);
                end
                % Check sizes
                if (length(Values{ia}) ~= length(Vertices))
                    Messages = [Messages, sprintf('%s:\nNumbers of vertices in the surface (%d) and the label file (%d) do not match\n', fBase, length(Vertices), length(Values{ia}))];
                    continue;
                end
                % Round the label values
                Values{ia} = round(Values{ia} * 1e3) / 1e3;
                % Convert to scouts structures
                lablist = unique(Values{ia});
                % Loop on each label
                for i = 1:length(lablist)
                    % New scout index
                    iScout = length(sAtlas(ia).Scouts) + 1;
                    % Get the vertices for this annotation
                    sAtlas(ia).Scouts(iScout).Vertices = find(Values{ia} == lablist(i));
                    sAtlas(ia).Scouts(iScout).Seed     = [];
                    sAtlas(ia).Scouts(iScout).Label    = file_unique(num2str(lablist(i)), {sAtlas(ia).Scouts.Label});
                    sAtlas(ia).Scouts(iScout).Color    = [];
                    sAtlas(ia).Scouts(iScout).Function = 'Mean';
                    sAtlas(ia).Scouts(iScout).Region   = 'UU';
                end
            end
            
        % ===== SUMA DSET ROIs =====
        case 'DSET'
            % Read file
            sAtlas.Scouts = in_label_dset(LabelFiles{iFile});
            % Force adding new atlas
            iAtlas = 'Add';
            
   
            
        % ===== BRAINSTORM SCOUTS =====
        case 'BST'
            % Load file
            ScoutMat = load(LabelFiles{iFile});
            % Convert old scouts structure to new one
            if isfield(ScoutMat, 'Scout')
                ScoutMat.Scouts = ScoutMat.Scout;
            elseif isfield(ScoutMat, 'Scouts')
                % Ok
            else
                Messages = [Messages, fBase, ':' 10 'Invalid scouts file.' 10];
                continue;
            end
            % Check the number of vertices
            if ~isVolumeAtlas && (length(Vertices) ~= ScoutMat.TessNbVertices)
                Messages = [Messages, sprintf('%s:\nNumbers of vertices in the surface (%d) and the scout file (%d) do not match\n', fBase, length(Vertices), ScoutMat.TessNbVertices)];
                continue;
            end
            % If name is not defined: use the filename
            if isNewAtlas
                if isfield(ScoutMat, 'Name') && ~isempty(ScoutMat.Name)
                    sAtlas.Name = ScoutMat.Name;
                else
                    [fPath,fBase] = bst_fileparts(LabelFiles{iFile});
                    sAtlas.Name = strrep(fBase, 'scout_', '');
                end
            end
            % Copy the new scouts
            for i = 1:length(ScoutMat.Scouts)
                iScout = length(sAtlas.Scouts) + 1;
                sAtlas.Scouts(iScout).Vertices = ScoutMat.Scouts(i).Vertices;
                sAtlas.Scouts(iScout).Seed     = ScoutMat.Scouts(i).Seed;
                sAtlas.Scouts(iScout).Color    = ScoutMat.Scouts(i).Color;
                sAtlas.Scouts(iScout).Label    = file_unique(ScoutMat.Scouts(i).Label, {sAtlas.Scouts.Label});
                sAtlas.Scouts(iScout).Function = ScoutMat.Scouts(i).Function;
                if isfield(ScoutMat.Scouts(i), 'Region')
                    sAtlas.Scouts(iScout).Region = ScoutMat.Scouts(i).Region; 
                else
                    sAtlas.Scouts(iScout).Region = 'UU';
                end
            end

        % ===== BrainSuite/SVReg surface file =====
        case 'DFS'
            % === READ FILE ===
            [VertexLabelIds, labelMap] = in_label_bs(LabelFiles{iFile});
            % Could not read the label correctly
            if isempty(VertexLabelIds) || isempty(labelMap)
                continue;
            end
            
            % === CONVERT TO SCOUTS ===
            % Convert to scouts structures
            lablist = unique(VertexLabelIds);
            if isNewAtlas
                sAtlas.Name = 'SVReg';
            end

            % Loop on each label
            for i = 1:length(lablist)
                % Find label ID
                id = lablist(i);
                % Skip if label id is not in labelMap
                if ~labelMap.containsKey(num2str(id))
                    continue;
                end
                entry = labelMap.get(num2str(id));
                labelInfo.Name = entry(1);
                labelInfo.Color = entry(2);
                % Skip the "background" scout
                if strcmpi(labelInfo.Name, 'background')
                    continue;
                end
                % New scout index
                iScout = length(sAtlas.Scouts) + 1;
                sAtlas.Scouts(iScout).Vertices = find(VertexLabelIds == id);
                sAtlas.Scouts(iScout).Label    = file_unique(labelInfo.Name, {sAtlas.Scouts.Label});
                sAtlas.Scouts(iScout).Color    = labelInfo.Color;
                sAtlas.Scouts(iScout).Function = 'Mean';
                sAtlas.Scouts(iScout).Region   = 'UU';
            end
            if isempty(sAtlas.Scouts)
                Messages = [Messages, fBase, ':' 10 'Could not match vertex labels and label description file.' 10];
                continue;
            end

        % ===== Unknown file =====
        otherwise
            Messages = [Messages, fBase, ':' 10 'Unknown file extension.' 10];
            continue;
    end
    
    
end




end

    
