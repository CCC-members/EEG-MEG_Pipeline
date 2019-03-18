function sa_out=my_mk_sa_meg_forward(sa,sens1,refs);
% The creation of sa-structurs for MEG for CTF data is done in two steps. 
% This is the second step, reading the CTF file to find the sensor coordinates 
% in the head coordinate system. It calls a fieldtrip function to read the CTF file. 
% It requires the first step done with mk_sa_meg_mri. 
%
% usage: sa_out=mk_sa_meg_forward(sa,fn); 
%
% input: 
% sa: structure generated with mk_sa_meg_mri.
% fn: name of directory containing CTF data 
%
% output: 
% sa_out: final structure with complete structural information

p1=15;
p2=10;

sa_out=sa;



[vc,center,radius,coeffs]=pointsonsurface(sa.vc_indi.vc(:,1:3),sa.vc_indi.vc(:,1:3),p1);

sa_out.fp_indi=meg_ini(vc,center',p2,sens1,refs); 

sa_out.locs_3D_indi=sens1(:,1:3);
%sa_out.ori_3D_indi=sens.coilori(inds,:);
% sa_out.sens_indi=sens;
sa_out.coils_indi=sens1;
sa_out.inds=(1:size(sens1,1));

    para1.rot=90;
     locs_2D=mk_sensors_plane(sa_out.locs_3D_indi,para1);
     para2.rot=90;
     para2.nin=50;
     locs_2D_sparse=mk_sensors_plane(sa_out.locs_3D_indi,para2);
     sa_out.locs_2D=locs_2D;
     sa_out.locs_2D_sparse=locs_2D_sparse;
  
    
return;



