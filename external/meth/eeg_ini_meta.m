function [fp,para_vc]=eeg_ini_meta(vc,sensors,para);
% usage [fp,para_vc]=eeg_ini_meta(vc,sensors,para);
% makes standardizes EEG forward-models
%
% Warning: the code writes files A_diag.mat and A_offdiag.mat 
%          (into the folder 'lowlevel') 
% 
% input:
% vc: an array of shells; vc{i} is an nx3 matrix where containing 
%     the n points on the i.th shell, must be either from inside to outside
%     or from outside to inside but not mixed
% sensors: an Mx3 matrix containing the locations of M sensors
%          it is always assumed that the last location is the reference
% para:   is a optional structure containing parameters;
%         para.sigmas: a column-vector containing the conductivities 
%                      of each shell. Default is [.33,.33/50,.33]
%         para.type:  =1  3-shell-spherical with local approximation for each sensor   
%                     =2  3-shell-spherical global fit with higher weights near sensors
%                     =3  3-shell-spherical global fit without weights
%                     =4  realistic, only here the number of shells is arbitray
%
% output:
% fp: structure containing everything needed for the forward calculation
%     including the name of the program to use with this fp
% para_vc: information about volume conductor: expecially about an analyic
%          model for it. This is usually not needed. 


   sigmas=[.33,.33/50,.33];
    xtype=4;
commonaverage=1;

if nargin>2
    if isfield(para,'type')
        xtype=para.type;
    end
    if isfield(para,'sigmas')
        sigmas=para.sigmas;
    end
end



if xtype==1

   vc_type.type=0;
   para_vc=get_para_vc(vc,sigmas,vc_type); %calculate model volume-conductor
   sensors_out=sensors_on_surface(para_vc,sensors);  %put sensors on the outer surface
   
   %show_vc_tri(para_vc{3},sensors_out); %shows the electrodes and normals on the outermost surface 
                                        % replace sensors_out by sensors_out(:,1:3) if you don't want 
                                        % to see the surface normals (and have the same color for all electrodes)
 
    
   para_sphfit.method=2;
    [center,radius,sensors_sphe]=multi_sphfit_global(para_vc,sensors_out,para_sphfit);
   %show_vc_tri_sphe(para_vc{3},center(chan,:),radius(chan,3),sensors_out(chan,:));
    fp=eeg_ini_3sphere(sensors_sphe,center,radius,sigmas);
 
    fp.sensors=sensors_out;
elseif xtype==2
   vc_type.type=0;
   para_vc=get_para_vc(vc,sigmas,vc_type);%calculate model  volume-conductor
   sensors_out=sensors_on_surface(para_vc,sensors);  %put sensors on the outer surface
   %show_vc_tri(para_vc{3},sensors_out); %shows the electrodes and normals on the outermost surface 
                                        % replace sensors_out by sensors_out(:,1:3) if you don't want 
                                        % to see the surface normals (and have the same color for all electrodes)

     para_sphfit.method=1;
  
   [center,radius,sensors_sphe]=multi_sphfit_global(para_vc,sensors_out,para_sphfit);
   %show_vc_tri_sphe(para_vc{3},center(chan,:),radius(chan,3),sensors_out(chan,:));
    fp=eeg_ini_3sphere(sensors_sphe,center,radius,sigmas);
      fp.sensors=sensors_out;
elseif xtype==3
   vc_type.type=0;
   para_vc=get_para_vc(vc,sigmas,vc_type); %calculate model volume-conductor
   sensors_out=sensors_on_surface(para_vc,sensors);  %put sensors on the outer surface
   %show_vc_tri(para_vc{3},sensors_out); %shows the electrodes and normals on the outermost surface 
                                        % replace sensors_out by sensors_out(:,1:3) if you don't want 
                                        % to see the surface normals (and have the same color for all electrodes)

    
   para_sphfit.method=0;
   [center,radius,sensors_sphe]=multi_sphfit_global(para_vc,sensors_out,para_sphfit);
   %show_vc_tri_sphe(para_vc{3},center(chan,:),radius(chan,3),sensors_out(chan,:));
    fp=eeg_ini_3sphere(sensors_sphe,center,radius,sigmas);
     fp.sensors=sensors_out;
 elseif xtype==4
   vc_type.type=2;
    para_vc=get_para_vc(vc,sigmas,vc_type); %calculate model volume-conductor
   sensors_out=sensors_on_surface(para_vc,sensors);  %put sensors on the outer surface
      
   para_sphfit.method=0;
   [center,radius,sensors_sphe]=multi_sphfit_global(para_vc,sensors_out,para_sphfit);
   %show_vc_tri_sphe(para_vc{3},center(chan,:),radius(chan,3),sensors_out(chan,:));
   fp=eeg_ini(para_vc,sensors);
   % show_vc_tri(para_vc{3},sensors_out); %shows the electrodes and normals on the outermost surface 
                                        % replace sensors_out by sensors_out(:,1:3) if you don't want 
                                        % to see the surface normals (and have the same color for all electrodes)
   fp.centers=fp.para_global_out{1}.para{1}.center;

end
fp.sigmas=sigmas;

[nchan ndum]=size(sensors);
P1=[eye(nchan-1);zeros(1,nchan-1)];
P2=eye(nchan)-ones(nchan,1)*ones(1,nchan)/nchan;
fp.lintrafo=P2*P1;
return;