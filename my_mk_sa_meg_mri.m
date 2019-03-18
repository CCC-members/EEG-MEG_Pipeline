function sa_out=my_mk_sa_meg_mri(sa,vol,mri)
% The creation of sa-structurs for MEG for CTF data is done in two steps. 
% This is the first step, reading MRI and analyzing the MRI data. 
% It requires fieldtrip. The output is the input for mk_sa_meg_forward.   
%
% usage: sa_out=mk_sa_meg_mri(sa,fn); 
%
% input: 
% sa: template sa structure.
% fn: name of MRI file
%
% output: 
% sa_out: intermediate structure to be used as input for second step. 


sa_out=sa;


% check units
if isfield(vol.bnd,'pnt')
  xx=vol.bnd.pnt;
elseif isfield(vol.bnd,'pos')
  xx=vol.bnd.pos;
end

yy=xx;
for i=1:3;yy(:,i)=xx(:,i)-mean(xx(:,i));end
xrad=mean(sqrt(sum(yy.^2,2)));
if xrad>20;
    warning('units mm?')
    vol.bnd.pnt=xx/10;
end

% T1.nii -> MNI standard head
% template = ft_read_mri('T1.nii');
% template.coordsys = 'spm';

mygrid=sa.grid_medium;
[xgrid,ygrid,zgrid]=grid2cube(mygrid);

% preparing FieldTrip structure for "ft_prepare_sourcemodel"
% 
cfg = [];
cfg.grid.warpmni   = 'yes';

mytemplate_grid.pos=mygrid; % standard MNI template
mytemplate_grid.xgrid=xgrid;
mytemplate_grid.ygrid=ygrid;
mytemplate_grid.zgrid=zgrid;
mytemplate_grid.dim=[length(xgrid) length(ygrid) length(zgrid)];
mytemplate_grid.inside=1:length(mygrid);
mytemplate_grid.outside=[];
cfg.grid.template=mytemplate_grid;

cfg.grid.nonlinear = 'yes'; % use non-linear normalization
cfg.mri            = mri;
grid               = ft_prepare_sourcemodel(cfg);

grid1=grid.pos;  % indivual source model
grid2=mygrid;    % template source model

% re-calculate the transformation from individual grid 
% to template grid
r1=mean(grid1);
r2=mean(grid2);
ng=length(grid1);
grid1m=grid1-repmat(r1,ng,1);
grid2m=grid2-repmat(r2,ng,1);

A=inv(grid1m'*grid1m)*(grid1m'*grid2m);
Ainv=inv(A);
r=r1-r2*Ainv;

ng=length(sa.grid_coarse);
sa_out.grid_coarse_indi=sa_out.grid_coarse*Ainv+repmat(r,ng,1);

ng=length(sa.grid_medium);
sa_out.grid_medium_indi=sa_out.grid_medium*Ainv+repmat(r,ng,1);

ng=length(sa.grid_fine);
sa_out.grid_fine_indi=sa_out.grid_fine*Ainv+repmat(r,ng,1);

ng=length(sa.grid_xcoarse);
sa_out.grid_xcoarse_indi=sa_out.grid_xcoarse*Ainv+repmat(r,ng,1);

ng=length(sa.grid_cortexhippo);
sa_out.grid_cortexhippo_indi=sa_out.grid_cortexhippo*Ainv+repmat(r,ng,1);

ng=length(sa.grid_cortex3000);
sa_out.grid_cortex3000_indi=sa_out.grid_cortex3000*Ainv+repmat(r,ng,1);

sa_out.vc_indi.vc=vol.bnd.pos;
sa_out.vc_indi.tri=vol.bnd.tri;

sa_out.trafo.u_indi2template=A;
sa_out.trafo.r_indi2template=-r1*A+r2;
sa_out.trafo.readme='xtemplate=xindi*u+r, row-vectors';

return;
