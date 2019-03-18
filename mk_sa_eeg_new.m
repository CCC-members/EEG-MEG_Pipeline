function LeadField=mk_sa_eeg_new(sa_in,locs,para)
% makes sa structures for EEG for a given template
% usage: sa_out=mk_sa_eeg(sa_in,locs,para);
%
% Warning: the code writes files A_diag.mat and A_offdiag.mat 
%          into the folder 'lowlevel' and deletes these files 
%          in the end.
% 
% The EEG output is always for common average reference
% A little warning: the code writes and in the end deletes files 
% named A_diag.mat and A_offdiag.mat in the current folder
%
% input: 
% sa_in:  template sa structure, containing anatomical information, i.e. 
%         MRI, segmentation and grids;
% locs: location of electrodes
% para: (optional), contains additional parameters
%        para.rot  rotates output for topoplot by this angle (in degrees)
%        para.sigmas row vector of conductivities, defaults ratios for  skin/skull and
%                    brain/skull is 50. 
% 
sa_out=sa_in;
 
parax.type=4;
 pars.rot=0;
 if nargin>2;
     if isfield(para,'sigmas');
       parax.sigmas=para.sigmas;
     end
     if isfield(para,'rot');
       pars.rot=para.rot;
     end
 end
 


 [newpoints,center,radius,coeffs]=pointsonsurface(sa_out.vc{3}.vc,locs,12); 
  sa_out.locs_2D=mk_sensors_plane(newpoints(:,1:3),pars); 
  
%   locsx=[locs;locs(end,:)];
%   locsx=locsx(:,1:3);
%   
locsx=newpoints(:,1:3);

  
 [fp,vc_model]=eeg_ini_meta(sa_out.vc,locsx,parax); 
 
 [nchan,ndum]=size(locs);
 Tref=[eye(nchan-1);zeros(1,nchan-1)];
 P=eye(nchan)-ones(nchan,1)*ones(1,nchan)/nchan;
 fp.lintrafo=P*Tref;
 sa_out.fp=fp;
 LeadField=grid2L(sa_out.Cortex,sa_out.fp);
  
 
return;


