function para_out=calc_leadcoeffs_all(vcall,para,lead0_all);

paraout=para;
[ndum,nvc]=size(para);

sigma=zeros(nvc+1,1);for k=1:nvc;sigma(k)=para{k}.sigma;end;
sigma_plus=zeros(nvc,1);sigma_minus=zeros(nvc,1);
for k=1:nvc
   sigma_plus(k)=sigma(k)/(sigma(k)+sigma(k+1));
end
for k=2:nvc
   sigma_minus(k)=sigma(k)/(sigma(k)+sigma(k-1));
end


%% calculation A^TA 

% normal part, diagonal (fixed expansions on both sides of the compartment)

for k=1:nvc;
    para_tmp_a=para{k}.para;
    [ndum,ncenter]=size(para_tmp_a);
    
   % outside 
   vc=vcall{k}.vc_norm;
   a=[];
   for i=1:ncenter;
      para_tmp=struct('center',para_tmp_a{i}.center,'order',para_tmp_a{i}.order);
      [bas_0,a_0]=getbasis_memory(vc(:,1:3),vc(:,4:6),para_tmp,para_tmp_a{i}.type); 
      a=[a,a_0];
   end
   A_diag{k}=a'*a*sigma_plus(k)^2;
   
   % inside
   if k>1
     vc=vcall{k-1}.vc_norm;
     a=[];
     for i=1:ncenter;
       para_tmp=struct('center',para_tmp_a{i}.center,'order',para_tmp_a{i}.order);
       [bas_0,a_0]=getbasis_memory(vc(:,1:3),vc(:,4:6),para_tmp,para_tmp_a{i}.type); 
       a=[a,a_0];
     end
     A_diag{k}=A_diag{k}+a'*a*sigma_minus(k)^2;
   end
end

% normal part, off-diagonal (two expansions from inside and outside of fixed surface) 

for k=1:nvc-1;
    para_tmp_a=para{k}.para;
    para_tmp_b=para{k+1}.para;
    [ndum,ncenter_a]=size(para_tmp_a);
    [ndum,ncenter_b]=size(para_tmp_b);

   % from inside 
   vc=vcall{k}.vc_norm;
   a=[];
   for i=1:ncenter_a;
      para_tmp=struct('center',para_tmp_a{i}.center,'order',para_tmp_a{i}.order);
      [bas_0,a_0]=getbasis_memory(vc(:,1:3),vc(:,4:6),para_tmp,para_tmp_a{i}.type); 
      a=[a,a_0];
   end
   
   % from outside
     b=[];
     for i=1:ncenter_b;
       para_tmp=struct('center',para_tmp_b{i}.center,'order',para_tmp_b{i}.order);
       [bas_0,b_0]=getbasis_memory(vc(:,1:3),vc(:,4:6),para_tmp,para_tmp_b{i}.type); 
       b=[b,b_0];
     end
 
     A_offdiag{k}=-b'*a*(sigma_minus(k+1)*sigma_plus(k));
 end

 
 

% tangential part, diagonal (fixed expansions on both sides of the compartment)

   % outside 
for k=1:nvc-1;
    para_tmp_a=para{k}.para;
    [ndum,ncenter]=size(para_tmp_a);
    
    vc=vcall{k}.vc_tang;
    a=[];
    for i=1:ncenter;
       para_tmp=struct('center',para_tmp_a{i}.center,'order',para_tmp_a{i}.order);
       [bas_0,a_0]=getbasis_memory(vc(:,1:3),vc(:,4:6),para_tmp,para_tmp_a{i}.type); 
       a=[a,a_0];
    end
    A_diag{k}=A_diag{k}+a'*a;
end

   % inside
for k=2:nvc;
    para_tmp_a=para{k}.para;
    [ndum,ncenter]=size(para_tmp_a);
    vc=vcall{k-1}.vc_tang;
    a=[];
    for i=1:ncenter;
      para_tmp=struct('center',para_tmp_a{i}.center,'order',para_tmp_a{i}.order);
      [bas_0,a_0]=getbasis_memory(vc(:,1:3),vc(:,4:6),para_tmp,para_tmp_a{i}.type); 
      clear bas_0;
      a=[a,a_0];
    end
    A_diag{k}=A_diag{k}+a'*a;
end

% save A_diag;
% clear A_diag;

% tangential part, off-diagonal (two expansions from inside and outside of fixed surface) 

for k=1:nvc-1;
   para_tmp_a=para{k}.para;
   para_tmp_b=para{k+1}.para;
   [ndum,ncenter_a]=size(para_tmp_a);
   [ndum,ncenter_b]=size(para_tmp_b);
   
   % from inside 
   vc=vcall{k}.vc_tang;
   disp([k])
   a=[];
   for i=1:ncenter_a;
      para_tmp=struct('center',para_tmp_a{i}.center,'order',para_tmp_a{i}.order);
      [bas_0,a_0]=getbasis_memory(vc(:,1:3),vc(:,4:6),para_tmp,para_tmp_a{i}.type); 
      clear bas_0;
      a=[a,a_0];
   end
   
   % from outside
   b=[];
   for i=1:ncenter_b;
      para_tmp=struct('center',para_tmp_b{i}.center,'order',para_tmp_b{i}.order);
      [bas_0,b_0]=getbasis_memory(vc(:,1:3),vc(:,4:6),para_tmp,para_tmp_b{i}.type);
      clear bas_0;
      b=[b,b_0];
   end
 
   A_offdiag{k}=A_offdiag{k}-b'*a;
end

% if nvc>1;
%   save A_offdiag
%   clear A_offdiag;
% end
%% calculation of A^TH 

% normal part  (fixed expansions on both sides of the compartment)

for k=1:nvc;
    para_tmp_a=para{k}.para;
    [ndum,ncenter]=size(para_tmp_a);
    
    
   % outside 
   
   % 'diagonal' 
   vc=vcall{k}.vc_norm;
   a=[];
   for i=1:ncenter;
      para_tmp=struct('center',para_tmp_a{i}.center,'order',para_tmp_a{i}.order);
      [bas_0,a_0]=getbasis_memory(vc(:,1:3),vc(:,4:6),para_tmp,para_tmp_a{i}.type); 
      clear bas_0;
      a=[a,a_0];
   end
   H{k}=(a'*lead0_all{k}.norm_out)*sigma_plus(k)^2;

   % 'off-diagonal'
   if k<nvc
       H{k}=H{k}-sigma_plus(k)*sigma_minus(k+1)*a'*lead0_all{k+1}.norm_in;
   end
                    
   % inside
   if k>1
      vc=vcall{k-1}.vc_norm;
      a=[];
      for i=1:ncenter;
         para_tmp=struct('center',para_tmp_a{i}.center,'order',para_tmp_a{i}.order);
         [bas_0,a_0]=getbasis_memory(vc(:,1:3),vc(:,4:6),para_tmp,para_tmp_a{i}.type);
         clear bas_0;
         a=[a,a_0];
      end
      H{k}=H{k}+(a'*lead0_all{k}.norm_in)*sigma_minus(k)^2;
 
      % off-diagonal 
      H{k}=H{k}-(a'*lead0_all{k-1}.norm_out)*sigma_minus(k)*sigma_plus(k-1);
   end
   
end

% tangential part  (fixed expansions on both sides of the compartment)

for k=1:nvc;
    para_tmp_a=para{k}.para;
    [ndum,ncenter]=size(para_tmp_a);
    
    
   % outside 
   if k<nvc
      vc=vcall{k}.vc_tang;
      a=[];
      for i=1:ncenter;
         para_tmp=struct('center',para_tmp_a{i}.center,'order',para_tmp_a{i}.order);
         [bas_0,a_0]=getbasis_memory(vc(:,1:3),vc(:,4:6),para_tmp,para_tmp_a{i}.type);
         clear bas_0;
         a=[a,a_0];
      end
   % 'diagonal'
      H{k}=H{k}+(a'*lead0_all{k}.tang_out);
   % 'off-diagonal'
      H{k}=H{k}-a'*lead0_all{k+1}.tang_in;
   end
                    
   % inside
   if k>1
     vc=vcall{k-1}.vc_tang;
     a=[];
     for i=1:ncenter;
        para_tmp=struct('center',para_tmp_a{i}.center,'order',para_tmp_a{i}.order);
        [bas_0,a_0]=getbasis_memory(vc(:,1:3),vc(:,4:6),para_tmp,para_tmp_a{i}.type);
        clear bas_0;
        a=[a,a_0];
     end
     % diagonal
     H{k}=H{k}+(a'*lead0_all{k}.tang_in);
     % off-diagonal 
     H{k}=H{k}-(a'*lead0_all{k-1}.tang_out);
   end
   
end
 
H_all=[];
nbasis=zeros(nvc,1);
for k=1:nvc;
    H_all=[H_all;H{k}];
    [nbasis(k),ndum]=size(H{k});
end
%nbasis_all=sum(nbasis);
%A_all=zeros(nbasis_all,nbasis_all);

clear a a_0 b b_0 bas_0 

% load A_diag;
% if nvc>1
%   load A_offdiag;
% end


A_all=[];
for k2=1:nvc;
     A_column=[];
     for k1=1:nvc
            if k1<k2-1 | k1>k2+1
            matloc=zeros(nbasis(k1),nbasis(k2));
        elseif k1==k2-1
            matloc=A_offdiag{k1}';
        elseif k1==k2+1
            matloc=A_offdiag{k2};
        elseif k1==k2
            matloc=A_diag{k1};
        end
        A_column=[A_column;matloc];
    end
    A_all=[A_all,A_column];
end
clear A_column A_diag A_offdiag matloc
regu=1e-12*max(abs(diag(A_all)));

[nbasis_all,nbasis_all]=size(A_all);
Ddiag=sqrt(diag(A_all));
iD=diag(1./Ddiag);
atap=iD*A_all*iD;
clear iD;
clear A_all;
regu=1e-12*max(abs(diag(atap)));
atap=atap+regu*eye(nbasis_all);
atapi=inv(atap);clear atap;
clear atap;
iD=diag(1./Ddiag);

atapi=(iD*atapi)*iD;
coeffs=atapi*H_all; 

kloc=1;
for k=1:nvc
    para_tmp_a=para{k}.para;
    [ndum,ncenter]=size(para_tmp_a);
    for i=1:ncenter;
        if para_tmp_a{i}.type==1
            nbasis=(para_tmp_a{i}.order+1)^2-1;
        elseif para_tmp_a{i}.type==2
            nbasis=2*(para_tmp_a{i}.order+1)^2-1;
        elseif para_tmp_a{i}.type==3
            nbasis=(para_tmp_a{i}.order+1)^2;
        end
    para{k}.para{i}.coeffs=coeffs(kloc:kloc+nbasis-1,:);
    kloc=kloc+nbasis;
    end
end

para_out=para;
return;
