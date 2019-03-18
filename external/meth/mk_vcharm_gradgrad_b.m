function [gradient,gradgradient]=mk_vcharm_gradgrad(vc,center,coeffs);
vc=vc(:,1:3); 
[nsurf,ndum]=size(vc);
gradient=getgrad(vc,center,coeffs);
d=.000001;

vcd=vc+d*repmat([1,0,0],nsurf,1);gradp=getgrad(vcd,center,coeffs);
vcd=vc-d*repmat([1,0,0],nsurf,1);gradm=getgrad(vcd,center,coeffs);
gradx=(gradp-gradm)/(2*d);

vcd=vc+d*repmat([0,1,0],nsurf,1);gradp=getgrad(vcd,center,coeffs);
vcd=vc-d*repmat([0,1,0],nsurf,1);gradm=getgrad(vcd,center,coeffs);
grady=(gradp-gradm)/(2*d);

vcd=vc+d*repmat([0,0,1],nsurf,1);gradp=getgrad(vcd,center,coeffs);
vcd=vc-d*repmat([0,0,1],nsurf,1);gradm=getgrad(vcd,center,coeffs);
gradz=(gradp-gradm)/(2*d);

gradgradient=reshape([gradx,grady,gradz],nsurf,3,3);

return;

function gradient=getgrad(vc,center,coeffs);
   [nbasis,ndum]=size(coeffs);
   order=sqrt(nbasis)-1;
   vc=vc(:,1:3);
   [nsurf,ndum]=size(vc);
   vc=vc-repmat(center,nsurf,1);

ori=repmat([1,0,0],nsurf,1);[basis,gradbasis_x]=legs_ori_grad(vc,ori,order);
ori=repmat([0,1,0],nsurf,1);[basis,gradbasis_y]=legs_ori_grad(vc,ori,order);
ori=repmat([0,0,1],nsurf,1);[basis,gradbasis_z]=legs_ori_grad(vc,ori,order);


rads0=sqrt(vc(:,1).^2+vc(:,2).^2+vc(:,3).^2);
fs=repmat(basis*coeffs,1,3);
gradient=2*vc-2*fs.*[gradbasis_x*coeffs,gradbasis_y*coeffs,gradbasis_z*coeffs];

return;