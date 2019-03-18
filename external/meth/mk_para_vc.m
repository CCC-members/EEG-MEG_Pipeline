function para_vc=mk_para_vc(vc_in,sigma,order,vc_coarse,vc_fine);

[ndum,nvc]=size(vc_in);

if nargin> 3
   [nsurf_coarse,ndum]=size(vc_coarse.surf);
end
if nargin> 4
   [nsurf_fine,ndum]=size(vc_fine.surf);
end

for k=1:nvc;
    disp(['shell number: ',num2str(k)])
    
  [center,radius]=sphfit(vc_in{k}(:,1:3))
  [coeffs,err]=harmfit(vc_in{k},center,order{k});
  
  disp('calculating model vc for original grid')
  vc_ori_model=mk_vcharm(vc_in{k},center,coeffs);

  
  if nargin> 3
      disp('calculating model vc for coarse grid');
      vc_coarse_model=mk_vcharm(vc_coarse.surf(:,1:3)+repmat(center,nsurf_coarse,1),center,coeffs);
  end
  if nargin> 4
      disp('calculating model vc for fine grid')
      vc_fine_model=mk_vcharm(vc_fine.surf(:,1:3)+repmat(center,nsurf_fine,1),center,coeffs);
  end
    




  para_vc{k}.vc_ori=vc_in{k};
  para_vc{k}.vc_ori_model=vc_ori_model;

  if nargin>3 
      para_vc{k}.vc_coarse=vc_coarse_model;
  end

  if nargin>4 
      para_vc{k}.vc_fine=vc_fine_model;
  end
  para_vc{k}.center=center;
  para_vc{k}.radius=radius;
  para_vc{k}.coeffs=coeffs;
  para_vc{k}.sigma=sigma{k};
  
end

return; 

    
    