function [Gain,OPTIONS] = pipeline_brainstorm_gain(MriFile,elect, nVerticesCortex,resamplingMethod,erodeFactor,...
                                   fillFactor,headVertices, isEEG, SnrFixed,NoiseReg,conductivity, showFigure, FileFormat)
%Pipeline ESI Readme
% INPUT:
% -MriFile               : Mri Freesufer File Path
% -electrodPos           : Electrode Position Matrix
% -nVertices             : Number of vertices for the cortex
% -resamplingMethod      : Resampling Method options: 'reducepatch' ||  'iso2mesh'
% -erodeFactor           : Parameter for convexifing the scalp surface, ranges from 0 (min) to 3 (max)(default: 1)
% -fillFactor            : Parameter for filling holes in the scalp surface ranges from 0 (min) to 3 (max)(default: 2)
% -headVertices          : Number of vertices on the estimated scalp surface(default: 1922)
% -isEEG                 : 1 for EEG or 0 for MEG (default: 1)
% -conductivity          : parameter modelling the conductivity of the skull surface, relative to the conductivities of the scalp and the cortex surfaces (default: 0.0125)
% -NoiseReg              : Noise Covariance Regularization (default:0.1)
% -SnrFixed              :Signal to noise ratio 1/lambda (default:3)
% -showFigure            :Produce Graphics
%End Pipeline ESI Readme

Brainstorm_route = cd;
my_addjava(Brainstorm_route);

%Validation Parameters
if (nargin < 12) || isempty(showFigure)  
    showFigure = 0;
end

if (nargin < 11) || isempty(conductivity)  
    conductivity = 0.0125;
end

if (nargin < 10) || isempty(NoiseReg)
    NoiseReg = 0.1;
end

if (nargin < 9) || isempty(SnrFixed)
      SnrFixed = 3;
end

if (nargin < 8) || isempty(isEEG) || isEEG>0 
    isEEG = 1;
end

if (nargin < 7) || isempty(headVertices)
    headVertices = 1922;
end

if (nargin < 6) || isempty(fillFactor)
    fillFactor = 2;
end

if (nargin < 5) || isempty(erodeFactor)
    erodeFactor =1;
end

if (nargin < 4) || isempty(resamplingMethod) || (not(strcmp(resamplingMethod,'reducepatch' ))&& not(strcmp(resamplingMethod,'iso2mesh')))
    resamplingMethod = 'reducepatch';
end

if (nargin < 3) || isempty(nVerticesCortex)
   nVerticesCortex = 10000;
end

if (nargin < 2) || isempty(elect) || isempty(MriFile)
   error('Error, electrodPos or/and MriFile isempty, you must define the path to load it')
end


%Fiducial point estimation
sMri = my_bst_normalize_mni(MriFile);

sMri.SCS.NAS=round(sMri.SCS.NAS,2);
sMri.SCS.LPA=round(sMri.SCS.LPA,2);
sMri.SCS.RPA=round(sMri.SCS.RPA,2);
sMri.SCS.Origin=round(sMri.SCS.Origin,3);
%-----------------------------Testear------------------------------------------
%Importing the anatomy
[sMri, Cortex] = my_import_anatomy_fs( MriFile,sMri, nVerticesCortex, 0, [], 0, resamplingMethod);

%Cleaning the surfaces
sHead = my_tess_isohead(sMri, 10000, erodeFactor, fillFactor);

%----------------------------OK-------------------------------------
% %Skull Interpolation
nvert = [headVertices 1922 1922];
thickness = [7 4 3];
[sInner,sOuter,sHeadBEM] = bem_surfaces_brainstorm(sMri,sHead,Cortex,nvert,thickness,Brainstorm_route);


%Electrode fitting
if(isEEG)
    locsx = channel_project_scalp(sHeadBEM.Vertices,elect);
else
    locsx = elect;
end
 

%Checking electrode positions
% if(showFigure)
%   head.vc = sHeadBEM.Vertices;
%   head.tri = sHeadBEM.Faces;
%   figure;showsurface(head,[],locsx);
% end


%BEM
OPTIONS.GridLoc = Cortex.Vertices;
OPTIONS.isEeg = isEEG;
OPTIONS.isMeg = not(OPTIONS.isEeg);
OPTIONS.BemSurf = cell(3,1);
OPTIONS.BemSurf{3} = sInner;
OPTIONS.BemSurf{2}= sOuter;
OPTIONS.BemSurf{1} = sHeadBEM;


OPTIONS.BemNames = {'Scalp'    'Skull'    'Brain'};
OPTIONS.BemCond = [1.0000    conductivity    1.0000];

OPTIONS.isAdjoint = 1;
OPTIONS.isAdaptative = not(OPTIONS.isAdjoint);
OPTIONS.GridOrient = Cortex.VertNormals;

OPTIONS.Channel.Loc = locsx;
iVertInside = find(inpolyhd(locsx', sInner.Vertices, sInner.Faces));
Gain = my_bst_openmeeg(OPTIONS);
iBad = find(any(isnan(OPTIONS.GridOrient),2) | any(isinf(OPTIONS.GridOrient),2) | (sqrt(sum(OPTIONS.GridOrient.^2,2)) < eps));
if ~isempty(iBad)
    OPTIONS.GridOrient(iBad,:) = repmat([1 0 0], length(iBad), 1);
end


end

