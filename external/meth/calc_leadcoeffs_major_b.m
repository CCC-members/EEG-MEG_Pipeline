function para_sensors_out=calc_leadcoeffs_major(para_sensors,para_vc,para_algo)

para_sensors_out=para_sensors;
dis=40;center_all=[0,0,0];order_1=10;d_in=20;d_out=20;

order_1=para_algo.order_1;


[ndum,nsens]=size(para_sensors);
[ndum,nvc]=size(para_vc);

for i=1:nsens;
    
    clear para_all;clear vc_all;
    for k=1:nvc
        normsensproj=norm(para_sensors{i}.sensproj{k}(1:3)-para_vc{k}.center);
        d_out=para_algo.disproj*normsensproj;
        d_in=d_out;
        dis=para_algo.sizeproj*normsensproj;
        center=para_sensors{i}.sensproj{k}(1:3)+d_out*para_sensors{i}.sensproj{k}(4:6);
        clear para_tmp;
        para_tmp{1}=struct('center',center,'type',3,'order',order_1);
        if k>1 
            center=para_sensors{i}.sensproj{k-1}(1:3)-d_in*para_sensors{i}.sensproj{k-1}(4:6);
            para_tmp{2}=struct('center',center,'type',3,'order',order_1);
        end
        para_all{k}.para=para_tmp;
%         disp([i,k,normsensproj,dis])
        vc_all{k}.vc_norm=vc2vcclose(para_vc{k}.vc_fine,para_sensors{i}.sensproj{k}(1:3),dis);
        vc_all{k}.vc_tang=vc2vctang_b(vc_all{k}.vc_norm,center_all');
        disp([i,k,size(vc_all{k}.vc_norm)]);
    end

    clear lead0_all;
    
    for k=1:nvc  
       lead0_all{k}.norm_out=getleadfield_sphero(vc_all{k}.vc_norm(:,1:3),vc_all{k}.vc_norm(:,4:6),para_sensors{i})';
    end
    for k=2:nvc  
       lead0_all{k}.norm_in=getleadfield_sphero(vc_all{k-1}.vc_norm(:,1:3),vc_all{k-1}.vc_norm(:,4:6),para_sensors{i})';
    end
    for k=1:nvc-1  
       lead0_all{k}.tang_out=getleadfield_sphero(vc_all{k}.vc_tang(:,1:3),vc_all{k}.vc_tang(:,4:6),para_sensors{i})';
    end
    for k=2:nvc  
        lead0_all{k}.tang_in=getleadfield_sphero(vc_all{k-1}.vc_tang(:,1:3),vc_all{k-1}.vc_tang(:,4:6),para_sensors{i})';
    end

    for k=1:nvc
        para_all{k}.sigma=para_vc{k}.sigma;
    end
    para_out=calc_leadcoeffs_all(vc_all,para_all,lead0_all);
    para_sensors_out{i}.para_shell=para_out;
end

return
