function vctang=vc2vctang(vcdat,center)



  [nsurf,ndum]=size(vcdat)
  vctangdat=[];
  for k=1:nsurf
      loc=vcdat(k,1:3)'-center;
      ori=vcdat(k,4:6)';
      
      theta=acos(loc(3)/norm(loc));
      phi=angle(loc(1)+sqrt(-1)*loc(2));
      etheta=[cos(theta)*cos(phi);cos(theta)*sin(phi);-sin(theta)];
      ephi=[-sin(phi);cos(phi);0];
      e1=cross(ori,etheta);e1=e1/norm(e1);
      e2=cross(e1,ori);e2=e2/norm(e2);
      vctangdat=[vctangdat;[vcdat(k,1:3),e1',e2']];
  end
  
  vctang=[vctangdat(:,1:6);[vctangdat(:,1:3),vctangdat(:,7:9)]];
  
      
  
return



