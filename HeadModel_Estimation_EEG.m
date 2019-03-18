%% cleaning all...
clc;
clear all;
close all;
warning off;

% cd(fileparts(mfilename('fullpath')));
% addpath(genpath(cd));

%% loading Anatomical (T1) and MEG data...
disp('******************************************');
disp('*   loading anatomical and EEG data...   *');
disp('******************************************');
[filename_channel, pathname] = uigetfile({'dataEEG\'},'Channel file for the EEG data:');
pathElectPos=[pathname,filename_channel];


MriFile = uigetdir('dataEEG\','Pick the Freesurfer Output folder:');


nVerticesCortex  = 6000;                           
resamplingMethod = 'reducepatch';
erodeFactor      = 0; 
fillFactor       = 2; 
headVertices     = 1922;
isEEG            = 1;
SnrFixed         = 3;
NoiseReg         = 0.1;
conductivity     = 0.0125;
showFigure       = 1;
FileFormat       = 'FreeSurfer';

[Gain,OPTIONS] = pipeline_brainstorm_fs(MriFile,pathElectPos,nVerticesCortex,...
    resamplingMethod,erodeFactor,fillFactor,headVertices,...
    isEEG,SnrFixed,NoiseReg,conductivity,showFigure, FileFormat);

save([pathname 'LF_results.mat'],'Gain','OPTIONS');
