function [newpoints,center,radius,coeffs,dist]=pointsonsurface(vc,points,order);
% Purpose: Moves points to a surface given by a set of points, and calculates normals 
% for the shifted points. 
% The surface will be modeled in spherical harmonics. Points are shifted
% towards (or away from) center of mass of surface to be exactly on the surface. 
% 
% Usage: [newpoints,center,radius,coeffs,dist]=pointsonsurface(vc,points,order);
%
% Input:
%  vc: Nx3 matrix definining coordinates of N surface points
%  points: Mx3 coordinates of M points to be shifted. 
% order: order of spherical harmonics. (order=10 is often good enough)
%
% output: 
% newpoints: mx6 matrix containing locations (first the columns) and
%           normals (last three columns) of shifted points
% center: estimated center of surface
% radius: radius of spherical fit to surface
% dist: vector of distances of how much each point was moved. 

[center,radius]=sphfit(vc);
[coeffs,err]=harmfit(vc,center,order);
newpoints=mk_vcharm(points,center,coeffs);
[n,ndum]=size(points);

r1=points-repmat(center,n,1);
d1=sqrt(sum(r1.^2,2));
r2=newpoints(:,1:3)-repmat(center,n,1);
d2=sqrt(sum(r2.^2,2));

dist=d2-d1;
  
  return;