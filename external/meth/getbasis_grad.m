function   gradbas=getbasis_grad(x1,n1,para,i); 
  scale=10; 
  [nshell,ndum]=size(para.sigma);
  [ndip,ndum]=size(x1);
  x1=x1-repmat(para.center',ndip,1);
  
  if para.order>0
    if i==1
      gradbas=legs_grad(x1,n1,para.order,scale); 
    else
      gradbas=legs_grad_b(x1,n1,para.order,scale); 
    end
  else
    gradbas=[];
  end

  if para.orderout>0
    scale=5/para.orderout;
    scale=1;
    scale=para.scale;
    lead_sens=getleadfield_virt(x1,n1,para.outlocs(1,:),para.orderout,scale);
    lead_ref=getleadfield_virt(x1,n1,para.outlocs(2,:),para.orderout,scale);
    gradbas=[gradbas,lead_sens,lead_ref];
  end
  
 

 if i<nshell
     lead0=lead_mon(x1,n1,para.outlocs(:,1:3));
     gradbas=[gradbas,lead0];
 end
     

 return

