function L=grid2L(grid,fp);
% calculates lead field tensor
% usage: L=grid2L(grid,fp);
% 
% input:
% grid: Nx3 matrix of coordinates of grid point
% fp: structure which defines the forward calculation. fp can be 
%     created e.g. with eeg_ini_meta or meg_ini.
%
% output:
% L: nxmx3 tensor of forward calulations for n sensors, m voxels, and 3
%     dipole directions. 
vtest=forward_general(zeros(1,6),fp);
nchan=length(vtest);
[ns ndum]=size(grid);
L=zeros(nchan,ns,3);

u=eye(3);
for i=1:3;
    uloc=u(i,:);
    dips=[grid,repmat(uloc,ns,1)];
    L(:,:,i)=forward_general(dips,fp);
end

return


