function [argout1] = my_bst_get(Brainstorm_route, AnatName )        
        progDir   = bst_fullfile(Brainstorm_route, 'defaults', 'anatomy');
        progFiles = dir(progDir);
        % Get templates from the user folder
        userDir   = bst_fullfile(bst_get('UserDefaultsDir'), 'anatomy');
        userFiles = dir(userDir);
        % Combine the two lists
        AllFiles = cat(2, cellfun(@(c)bst_fullfile(progDir,c), {progFiles.name}, 'UniformOutput', 0), ...
                          cellfun(@(c)bst_fullfile(userDir,c), setdiff({userFiles.name}, {progFiles.name}), 'UniformOutput', 0));
        % Initialize list of defaults
        sTemplates = repmat(struct('FilePath',[],'Name',[]), 0);
        % Find all the valid defaults (.zip files or subdirectory with a brainstormsubject.mat in it)
        for i = 1:length(AllFiles)
            % Decompose file name
            [fPath, fBase, fExt] = bst_fileparts(AllFiles{i});
            % Entry is a directory W/ a name that does not start with a '.' 
            if isempty(fBase) || strcmpi(fBase(1),'.') || (~isempty(fExt) && ~strcmpi(fExt, '.zip'))
                continue;
            end
            % If it's a folder: check for a brainstormsubject file
            if isdir(AllFiles{i})
                bstFiles = dir(bst_fullfile(AllFiles{i}, 'brainstormsubject*.mat'));
                if (length(bstFiles) == 1)
                    sTemplates(end+1).FilePath = AllFiles{i};
                    sTemplates(end).Name = fBase;
                end
            % If it's a zip file
            elseif isequal(fExt, '.zip')
                sTemplates(end+1).FilePath = AllFiles{i};
                sTemplates(end).Name = fBase;
            end
        end
        % Get defaults from internet 
        if ~ismember(lower({sTemplates.Name}), 'icbm152')
            sTemplates(end+1).FilePath = 'http://neuroimage.usc.edu/bst/getupdate.php?t=ICBM152_2016c';
            sTemplates(end).Name = 'ICBM152';
        end
%         if ~ismember(lower({sTemplates.Name}), 'icbm152_2016')
%             sTemplates(end+1).FilePath = 'http://neuroimage.usc.edu/bst/getupdate.php?t=ICBM152_2016';
%             sTemplates(end).Name = 'ICBM152_2016';
%         end
        if ~ismember(lower({sTemplates.Name}), 'icbm152_2016c')
            sTemplates(end+1).FilePath = 'http://neuroimage.usc.edu/bst/getupdate.php?t=ICBM152_2016c';
            sTemplates(end).Name = 'ICBM152_2016c';
        end
        if ~ismember(lower({sTemplates.Name}), 'icbm152_brainsuite_2016')
            sTemplates(end+1).FilePath = 'http://neuroimage.usc.edu/bst/getupdate.php?t=ICBM152_BrainSuite_2016';
            sTemplates(end).Name = 'ICBM152_BrainSuite_2016';
        end
        if ~ismember(lower({sTemplates.Name}), 'colin27_2016')
            sTemplates(end+1).FilePath = 'http://neuroimage.usc.edu/bst/getupdate.php?t=Colin27_2016';
            sTemplates(end).Name = 'Colin27_2016';
        end
        if ~ismember(lower({sTemplates.Name}), 'colin27_2012')
            sTemplates(end+1).FilePath = 'http://neuroimage.usc.edu/bst/getupdate.php?t=Colin27_2012';
            sTemplates(end).Name = 'Colin27_2012';
        end
        if ~ismember(lower({sTemplates.Name}), 'colin27_brainsuite_2016')
            sTemplates(end+1).FilePath = 'http://neuroimage.usc.edu/bst/getupdate.php?t=Colin27_BrainSuite_2016';
            sTemplates(end).Name = 'Colin27_BrainSuite_2016';
        end
        if ~ismember(lower({sTemplates.Name}), 'bci-dni_brainsuite_2016')
            sTemplates(end+1).FilePath = 'http://neuroimage.usc.edu/bst/getupdate.php?t=BCI-DNI_BrainSuite_2016';
            sTemplates(end).Name = 'BCI-DNI_BrainSuite_2016';
        end
        if ~ismember(lower({sTemplates.Name}), 'uscbrain_brainsuite_2017')
            sTemplates(end+1).FilePath = 'http://neuroimage.usc.edu/bst/getupdate.php?t=USCBrain_BrainSuite_2017';
            sTemplates(end).Name = 'USCBrain_BrainSuite_2017';
        end
        if ~ismember(lower({sTemplates.Name}), 'fsaverage_2016')
            sTemplates(end+1).FilePath = 'http://neuroimage.usc.edu/bst/getupdate.php?t=FSAverage_2016';
            sTemplates(end).Name = 'FSAverage_2016';
        end
        if ~ismember(lower({sTemplates.Name}), 'infant7w_2015b')
            sTemplates(end+1).FilePath = 'http://neuroimage.usc.edu/bst/getupdate.php?t=Infant7w_2015b';
            sTemplates(end).Name = 'Infant7w_2015b';
        end
        if ~ismember(lower({sTemplates.Name}), 'oreilly_1y')
            sTemplates(end+1).FilePath = 'http://neuroimage.usc.edu/bst/getupdate.php?t=Oreilly_1y';
            sTemplates(end).Name = 'Oreilly_1y';
        end
        % If a specific template was requested
        if ~isempty(AnatName)
            iAnat = find(strcmpi({sTemplates.Name}, AnatName));
            sTemplates = sTemplates(iAnat);
        end
        % Return defaults list
        argout1 = sTemplates;
end