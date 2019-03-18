function  my_addjava( BrainstormHomeDir )

if exist('javax.media.opengl.GLCanvas', 'class') && exist('com.sun.opengl.util.j2d.TextRenderer', 'class')
    JOGLVersion = 1;
% If JOGL2 is available
elseif exist('javax.media.opengl.awt.GLCanvas', 'class')
    JOGLVersion = 2;
% If JOGL2.3 is available
elseif exist('com.jogamp.opengl.awt.GLCanvas', 'class')
    JOGLVersion = 2.3;
% No JOGL available
else
    JOGLVersion = 0;
end
% Define jar file to remove from the Java classpath
switch (JOGLVersion)
    case 0,    jarfile = '';  disp('ERROR: JOGL not supported');
    case 1,    jarfile = 'brainstorm_jogl1.jar'; 
    case 2,    jarfile = 'brainstorm_jogl2.jar';
    case 2.3,  jarfile = 'brainstorm_jogl2.3.jar';
end
    
% Set dynamic JAVA CLASS PATH
if ~exist('org.brainstorm.tree.BstNode', 'class')
    % Add Brainstorm JARs to classpath
    javaaddpath([BrainstormHomeDir '/java/RiverLayout.jar']);
    javaaddpath([BrainstormHomeDir '/java/brainstorm.jar']);
    javaaddpath([BrainstormHomeDir '/java/vecmath.jar']);
    % Add JOGL package
    if ~isempty(jarfile)
        javaaddpath([BrainstormHomeDir '/java/' jarfile]);
    end
end

bst_set_path(BrainstormHomeDir)

end

function bst_set_path(BrainstormHomeDir)
    % Cancel add path in case of deployed application
    if exist('isdeployed', 'builtin') && isdeployed
        return
    end
    % Brainstorm folder itself
    %addpath(BrainstormHomeDir, '-BEGIN'); % make sure the main brainstorm folder is in the path
    % List of folders to add
    NEXTDIR = {'external', 'defaults'}; % in reverse order of priority
    for i = 1:length(NEXTDIR)
        nextdir = fullfile(BrainstormHomeDir,NEXTDIR{i});
        % Reset the last warning to blank
        lastwarn('');
        % Check that directory exist
        if ~isdir(nextdir)
            error(['Directory "' NEXTDIR{i} '" does not exist in Brainstorm path.' 10 ...
                   'Please re-install Brainstorm.']);
        end
        % Recursive search for subfolders in each main folder
        P = genpath(nextdir);
        % Add directory and subdirectories
        addpath(P, '-BEGIN');
    end
    % Adding user's mex path
    
%     userMexDir = fullfile(BrainstormHomeDir,'mex');
%     addpath(userMexDir, '-BEGIN');
%     % Adding user's custom process path
%     userProcessDir = bst_get('UserProcessDir');
%     addpath(userProcessDir, '-BEGIN');
end

