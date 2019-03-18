% This is a pipeline for HCP MEG data head model estimation based on
% Pedro Ariel pipeline and modified by Eduardo Gonzalez Moreira for 
% MEG data analysis.
%
% Date:
%   2018/12/01

%% cleaning all...
clc;
clear all;
close all;
warning off;
%% loading Anatomical (T1) and MEG data...
disp('******************************************');
disp('*   loading anatomical and MEG data...   *');
disp('******************************************');
[filename_meg, pathname] = uigetfile({'dataMEG\'},'Pick the MEG data (RestingState):');
fs_folder=[pathname,filename_meg];      % MEG data
MriFile = uigetdir('data\','Pick the Freesurfer Output folder:');

colormap='dataMEG\mycolormap_brain_basic_conn.mat';
nVertices        = 6000;                                % must be defined by the user...


[K]=pipeline_brainstorm_meg_hcp(nVertices, colormap,  fs_folder, MriFile);