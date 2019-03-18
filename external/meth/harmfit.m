function [coeffs,err]=harmfit(vc,center,order);
% fits spherical harmonics to a set 
% of surface points 
% usage: [coeffs,err]=harmfit(vc,center,order); 
% input:
% vc: nx3 matrix of n coordinates on a surface
% center: 1x3 vector of coordinates for the (chosen) center
% order: order of spherical harmonics (e.g. order=10 is often reasonable)
% output: 
% coeffs: coefficients of spherical harmonics
% err: fit error

vc=vc(:,1:3);
[nsurf,ndum]=size(vc);
vc=vc-repmat(center,nsurf,1);
basis=legs_ori(vc,order);

rad=sqrt(vc(:,1).^2+vc(:,2).^2+vc(:,3).^2);

coeffs=inv(basis'*basis)*(basis'*rad);

err=sqrt(mean(abs(rad-basis*coeffs).^2));

return
