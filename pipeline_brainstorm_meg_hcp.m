function [ K] = pipeline_brainstorm_meg_hcp(nVertices, colormap,  fs_folder, MriFile)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
%% initial values...
load(fs_folder);
load(colormap);
nVertices        = 6000;                                % must be defined by the user...
resamplingMethod = 'reducepatch';
erodeFactor      = 0; 
fillFactor       = 1; 
headVertices     = 1922;
isMEG            = 1;
SnrFixed         = 3;
NoiseReg         = 0.1;
conductivity     = 0.0125;
showFigure       = 0;
ThetaJJ          = [];
SJJ              = [];
indms            = [];
count            = 0;
verbosity        = 1;                                   % must be defined by the user...
ind_act          = 39;
addpath external;
%% sensor position estimation...
elect = zeros(length(data.label),3);
for ii = 1:length(data.label)
    for jj = 1:length(data.hdr.grad.label)
        if strcmp(data.label{ii},data.hdr.grad.label{jj})
            elect(ii,:) = data.hdr.grad.chanpos(jj,:);
            break;
        end
    end
end
%% head model estimation...
disp('************************************');
disp('*   estimating BEM head model...   *');
disp('************************************');
[Gain,Cortex,sHeadBEM] = pipeline_brainstorm_gain(MriFile,elect,nVertices,...
    resamplingMethod,erodeFactor,fillFactor,headVertices,...
    isMEG,SnrFixed,NoiseReg,conductivity,showFigure);
K = bst_gain_orient(Gain,Cortex.VertNormals);




