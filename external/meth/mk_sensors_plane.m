function loc_phys=mk_sensors_plane(sensors,pars);
% Purpose: a) maps 3D coordinates of sensors on a plane, and b)
% calculates slightly shifted 2D coordinates to be used for head-in-head plots 
% to avoid overlapping circles. 
% 
% usage: locs_2D=mk_sensors_plane(sensors,pars);
% 
% input: 
% sensors: Either nx3 matrix if coordinates of sensors in 3D for both purposes, or 
%           nx2 matrix of 2D coordinates for second purpose only. 
% pars: optional structure of parameters with the following fields
% pars.rot  rotation angle in degrees of 2D coordinates
% pars.nin  number of sensors if only a subset of sensors shall be
%           displayed in head-in-head plots
% pars.zdir 1x3 vector defining the z-direction. If not provided, it will
%            be estimated assuming that the z-direction is the difference between 
%            center of mass of sensors and center of a spherical approximation of the sensors 
% 
% output: 
% loc_phys: nx5 matrix for n sensors. The first column are just indices,
%           and values of tero mean that these sensors are not shown in
%           head-in-head plots. Column 2 and 3 coordinates of sensors in a
%           2D plane. Columns 4 and 5 are slghtly shifted locations to be
%           used in head-in-head plots. 

showfigs=0;
[ns_ori,ndim]=size(sensors);

zdir=[];

if nargin>1
  if isfield(pars,'rot');
      rot=pars.rot;
  else
      rot=0;
  end
  if isfield(pars,'nin');
      nin=pars.nin;
  else
      nin=ns_ori;
  end
  if isfield(pars,'indices');
      indices=pars.indices;
  else
      indices=[1:ns_ori]';
  end
  if isfield(pars,'zdir');
      zdir=pars.zdir;
  end
  if isfield(pars,'circle_shift');
      shift_cont=pars.circle_shift;
  else
      shift_cont=1;
  end
  if isfield(pars,'showfigs');
      showfigs=pars.showfigs;
  else
      showfigs=0;
  end

else
    rot=0;
    nin=ns_ori;
    indices=[1:ns_ori]';
    shift_cont=1;
    showfigs=0;
end



if nin<ns_ori;
    [sensors_n,inds]=select_chans(sensors,nin);
else
    sensors_n=sensors;
end


if ndim==3
   s2d=sensor3d2sensor2d(sensors,[],[],zdir);
else
   s2d=sensors;
end

%s2d=s2d

if nin<ns_ori;
    s2d_n=s2d(inds,:);
else
    sensors_n=sensors;
    s2d_n=s2d;
end

[ns,ndum]=size(sensors_n);

phi=rot*pi/180;
   
s2d=([[cos(phi),-sin(phi)];[sin(phi),cos(phi)]]*s2d')';
s2d_n=([[cos(phi),-sin(phi)];[sin(phi),cos(phi)]]*s2d_n')';
 
    
if shift_cont>0  
   loc_phys_sparse=locphys2locphys([[1:ns]',s2d_n]);
  
else
    loc_phys_sparse=[[1:ns]',s2d_n,s2d_n];
       if showfigs==1
        figure;
        for i=1:ns;
            text(s2d_n(i,1),s2d_n(i,2),num2str(i));
        end
        axis([-.6 .6 -.6 .6]);
    end

end

   if nin<ns_ori
       loc_phys=[-(1:ns_ori)',s2d,s2d];
       loc_phys(inds,:)=[inds,loc_phys_sparse(:,2:5)];
   else
       loc_phys=loc_phys_sparse;
   end
   
loc_phys(:,1)=indices.*sign(loc_phys(:,1));

return;