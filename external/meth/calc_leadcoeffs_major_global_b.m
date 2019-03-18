function para_global_out=calc_leadcoeffs_major_global_b(para_sensors,para_vc,para_algo)


[ndum,nsens]=size(para_sensors);
[ndum,nvc]=size(para_vc);

 for k=1:nvc;
     vc_all{k}.vc_norm=para_vc{k}.vc_coarse;
     vc_all{k}.vc_tang=vc2vctang_b(vc_all{k}.vc_norm,para_vc{k}.center');
 end
   
        clear lead0_all;
    
for k=1:nvc
  lead0_all{k}.norm_out=[];
  lead0_all{k}.norm_in=[];
  lead0_all{k}.tang_out=[];
  lead0_all{k}.tang_in=[];
  lead1_corr_all{k}.norm_out=[];
  lead1_corr_all{k}.norm_in=[];
  lead1_corr_all{k}.tang_out=[];
  lead1_corr_all{k}.tang_in=[];

end

        
 for i=1:nsens;
    for k=1:nvc  
       lead0{k}.norm_out=getleadfield_sphero(vc_all{k}.vc_norm(:,1:3),vc_all{k}.vc_norm(:,4:6),para_sensors{i})';
       lead0_all{k}.norm_out=[lead0_all{k}.norm_out,lead0{k}.norm_out];
    end
    for k=2:nvc  
       lead0{k}.norm_in=getleadfield_sphero(vc_all{k-1}.vc_norm(:,1:3),vc_all{k-1}.vc_norm(:,4:6),para_sensors{i})';
       lead0_all{k}.norm_in=[lead0_all{k}.norm_in,lead0{k}.norm_in];

    end
    for k=1:nvc-1  
       lead0{k}.tang_out=getleadfield_sphero(vc_all{k}.vc_tang(:,1:3),vc_all{k}.vc_tang(:,4:6),para_sensors{i})';
       lead0_all{k}.tang_out=[lead0_all{k}.tang_out,lead0{k}.tang_out];
    end
    for k=2:nvc  
        lead0{k}.tang_in=getleadfield_sphero(vc_all{k-1}.vc_tang(:,1:3),vc_all{k-1}.vc_tang(:,4:6),para_sensors{i})';
        lead0_all{k}.tang_in=[lead0_all{k}.tang_in,lead0{k}.tang_in];
    end
end

for k=1:nvc
    lead0_all{k}.norm_out=lead0_all{k}.norm_out(:,1:nsens-1)-repmat(lead0_all{k}.norm_out(:,nsens),1,nsens-1);
end
for k=2:nvc
    lead0_all{k}.norm_in=lead0_all{k}.norm_in(:,1:nsens-1)-repmat(lead0_all{k}.norm_in(:,nsens),1,nsens-1);
end
for k=1:nvc-1
    lead0_all{k}.tang_out=lead0_all{k}.tang_out(:,1:nsens-1)-repmat(lead0_all{k}.tang_out(:,nsens),1,nsens-1);
end
for k=2:nvc
    lead0_all{k}.tang_in=lead0_all{k}.tang_in(:,1:nsens-1)-repmat(lead0_all{k}.tang_in(:,nsens),1,nsens-1);
end



for k=1:nvc;
       lead1_corr_all{k}.norm_out=calc_leadcorr_major(vc_all{k}.vc_norm(:,1:3),vc_all{k}.vc_norm(:,4:6),para_sensors,k);
       lead1_all{k}.norm_out=lead0_all{k}.norm_out+lead1_corr_all{k}.norm_out;
end
for k=2:nvc;
       lead1_corr_all{k}.norm_in=calc_leadcorr_major(vc_all{k-1}.vc_norm(:,1:3),vc_all{k-1}.vc_norm(:,4:6),para_sensors,k);
       lead1_all{k}.norm_in=lead0_all{k}.norm_in+lead1_corr_all{k}.norm_in;
end
for k=1:nvc-1;
       lead1_corr_all{k}.tang_out=calc_leadcorr_major(vc_all{k}.vc_tang(:,1:3),vc_all{k}.vc_tang(:,4:6),para_sensors,k);
       lead1_all{k}.tang_out=lead0_all{k}.tang_out+lead1_corr_all{k}.tang_out;
end
for k=2:nvc;
       lead1_corr_all{k}.tang_in=calc_leadcorr_major(vc_all{k-1}.vc_tang(:,1:3),vc_all{k-1}.vc_tang(:,4:6),para_sensors,k);
       lead1_all{k}.tang_in=lead0_all{k}.tang_in+lead1_corr_all{k}.tang_in;
end


for k=1:nvc
 para_global{k}.para{1}.order=para_algo.order_2;
 para_global{k}.para{1}.center=para_vc{k}.center;
 para_global{k}.sigma=para_vc{k}.sigma;

 if k==1;
     para_global{k}.para{1}.type=1;
 else
     para_global{k}.para{1}.type=2;
 end
end

 
para_global_out=calc_leadcoeffs_all(vc_all,para_global,lead1_all);



return
