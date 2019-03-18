function [uall,dall]=anasens_b(sens,center,coeffs)
sens=sens(:,1:3); 
[nsens,ndum]=size(sens);

[gradient,gradgradient]=mk_vcharm_gradgrad_b(sens,center,coeffs);

uall=zeros(nsens,3,3);
dall=zeros(nsens,2);


for i=1:nsens
    gradloc=gradient(i,:);
    gradnorm=norm(gradloc);
    gradloc=gradloc/gradnorm;
    
    curvloc=reshape(gradgradient(i,:,:),3,3);
    curvloc=curvloc/gradnorm;
        
    utang=getutang(gradloc');
    
     curvloc_tang=utang'*curvloc*utang;
     %save c curvloc_tang utang
    %[u_azi,d]=eigs(curvloc_tang);
    [u_azi,d,v]=svd(curvloc_tang);
    dd=diag(d);dd(1)=dd(1)*u_azi(:,1)'*u_azi(:,1);dd(2)=dd(2)*u_azi(:,2)'*u_azi(:,2);
    dd=dd
    
    u=[utang*u_azi,gradloc'];
    if det(u)<0;
        u=[-u(:,1),u(:,2),u(:,3)];
    end
    uall(i,:,:)=u;
    dall(i,:)=dd'/2;
    %     save u u gradloc d
%    
      
    
end

return;
    