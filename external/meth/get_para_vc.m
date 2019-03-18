function para_vc=get_para_vc(surfs,sigmas,para)

m=length(surfs);

if ~isfield(surfs{1},'vc');
  for i=1:m;
      surfs_new{i}.vc=surfs{i};
  end
  surfs=surfs_new;
end

    
if nargin<3 
    for i=1:m
        order{i}=10;
    end
    
load vc_coarse;
load vc_fine;

else
    
    if isfield(para,'orders');
        for i=1:m
           order{i}=para.orders(i);
        end
    else
        for i=1:m
           order{i}=12;
        end
    end

    if isfield(para,'type');
        if para.type==0;
        elseif para.type==1;
            load vc_coarse;
            %vc_fine=vc_coarse;
        else
            load vc_coarse;
            load vc_fine;
        end
    else
        load vc_coarse;
        load vc_fine;
    end
end  
        
  
for i=1:m
   sigma{i}=sigmas(i);
end


for i=1:m
   [np,ndum]=size(surfs{i}.vc);
   radds(i)=mean(mean((surfs{i}.vc-repmat(mean(surfs{i}.vc),np,1)).^2));
end

for i=1:m
   if radds(1)>radds(m)
     vc_in{i}=surfs{m-i+1}.vc;
   else
     vc_in{i}=surfs{i}.vc;
   end
end


if isfield(para,'type');
      if para.type==0;
          para_vc=mk_para_vc(vc_in,sigma,order);
      elseif para.type==1;
         para_vc=mk_para_vc(vc_in,sigma,order,vc_coarse);
      else
         para_vc=mk_para_vc(vc_in,sigma,order,vc_coarse,vc_fine);
      end
else
      para_vc=mk_para_vc(vc_in,sigma,order,vc_coarse,vc_fine);
end






for i=1:m
   
   if radds(1)>radds(m)
       if isfield(surfs{m-i+1},'tri'); para_vc{i}.tri=surfs{m-i+1}.tri; end;
   else
        if isfield(surfs{i},'tri'); para_vc{i}.tri=surfs{i}.tri; end;
   end
   
   if isfield(para,'type');
      if para.type ~= 0;
        para_vc{i}.tri_coarse=vc_coarse.tri;
      end
   else
      para_vc{i}.tri_coarse=vc_coarse.tri;
   end
end


return;