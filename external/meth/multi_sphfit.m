function [center,radius]=multi_sphfit(vc,weights)
% fits a K spheres to K sets of surface points (K shells)
%
% input: 
% vc   structure where vc{k} for k=1:K contains  n_kx3 matrix, where each row represents the location
%      of one surface point. vc_k can have more than 3 columns 
%      (e.g. orientations) - then only the first 3 columns are used
% 
% weights : weights{k} is an n_kx1 matrix containing the weights for each point 
%                         
% output  
% center  1x3 vector denoting the center
% radius  Kx1 vector denoting the radii for each shell  



K=length(vc);

if isfield(vc{1},'vc');
    for k=1:K
        vc_tmp{k}=vc{k}.vc;
    end
    vc=vc_tmp;
elseif isfield(vc{1},'vc_ori_model');
    for k=1:K
        vc_tmp{k}=vc{k}.vc_ori_model;
    end
    vc=vc_tmp;
end


    

for k=1:K
    vc{k}=vc{k}(:,1:3);
    [nvc_loc,ndum]=size(vc{k});
    nvc(k)=nvc_loc;
    if nargin<2
        weights{k}=ones(nvc(k),1);
    end
end


center_0=zeros(1,3);
for k=1:K
  center_0=center_0+mean(vc{k})/K;
end

radius_0=zeros(1,K);
for k=1:K
  vcx=vc{k}-repmat(center_0,nvc(k),1);
  radius_0(k)=mean(sqrt(vcx(:,1).^2+vcx(:,2).^2+vcx(:,3).^2));
end
% 
% center_0=center_0+[0,0,5];
% radius_0=radius_0*1.1;

alpha=1;
err_0=costfun(vc,weights,center_0,radius_0);

for k=1:10;
     %  disp([k,err_0,center_0])

    [center_new,radius_new]=lm1step(vc,weights,center_0,radius_0,alpha);
    
    err_new=costfun(vc,weights,center_new,radius_new);
    %disp([k,err_0,err_new,center_new,radius_new]);
    
    if err_new<err_0;
        center_0=center_new;
        radius_0=radius_new;
        err_0=err_new;
        alpha=alpha/5;
    else
        alpha=alpha*5;
    end
     
end

 radius=radius_0;
 center=center_0;
 
return;

function err=costfun(vc,weights,center,radius);

K=length(vc);
err=0;
for k=1:K;
    
  [nvc,ndum]=size(vc{k});
  vcx=vc{k}-repmat(center,nvc,1);
  err=err+mean( (vcx(:,1).^2+vcx(:,2).^2+vcx(:,3).^2-radius(k)^2).^2.*weights{k}.^2);
end
err=sqrt(sqrt(err));
 
 return;
 
 
function  [center_new,radius_new]=lm1step(vc,weights,center,radius,alpha);
 K=length(vc);

 for k=1:K
    [nvc_loc,ndum]=size(vc{k});
    nvc(k)=nvc_loc;
 end
nvcall=sum(nvc);
nvcallcum=cumsum(nvc);

 vcy=zeros(nvcall,3);
 L2=zeros(nvcall,K);
 f=zeros(nvcall,1);
 for k=1:K
     vcx=vc{k}-repmat(center,nvc(k),1);
     if k==1
         nvcstart=0;
     else
         nvcstart=nvcallcum(k-1);
     end
     vcy(nvcstart+1:nvcallcum(k),:)=vcx.*repmat(weights{k},1,3);
     L2(nvcstart+1:nvcallcum(k),k)=radius(k)*weights{k};
     f(nvcstart+1:nvcallcum(k))=(vcx(:,1).^2+vcx(:,2).^2+vcx(:,3).^2-radius(k)^2).*weights{k};
 end
 
 L=2*[vcy,L2];
 
 
   
 par_new=inv(L'*L+alpha*eye(3+K))*L'*f;
 
 center_new=center+par_new(1:3)';
 for k=1:K
    radius_new(k)=radius(k)+par_new(3+k);
 end
 
 return;
 
 