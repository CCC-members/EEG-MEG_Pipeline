function [center,radius,sensors_out]=multi_sphfit_global(vc,sensors,para)

if nargin>1
    sensors=sensors(:,1:3);
end


if nargin<3
    para.method=0;
end

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
    end

if ~isfield(para,'p0')
    para.p0=2;
end
if ~isfield(para,'d0')
    [nvcloc,ndum]=size(vc{k});
    vcmean=vc{K}-repmat(mean(vc{K}),nvcloc,1);
    scal=mean((sqrt( sum((vcmean.^2)')))');
    para.d0=scal/10.;
end

if nargin<2
    [center,radius]=multi_sphfit(vc);
else
	if para.method==0
        [center,radius]=multi_sphfit(vc);
        sensors_out=sensors_in_sphere(sensors,center,max(radius));
	elseif para.method==1
        weights=calc_weights(vc,sensors,para);
        [center,radius]=multi_sphfit(vc,weights);
        sensors_out=sensors_in_sphere(sensors,center,max(radius));
	elseif para.method==2;
        [ns,ndum]=size(sensors);
        center=zeros(ns,3);
        radius=zeros(ns,K);
        for i=1:ns;
            weights=calc_weights(vc,sensors(i,:),para);
            [center_loc,radius_loc]=multi_sphfit(vc,weights);
            sensors_out(i,:)=sensors_in_sphere(sensors(i,:),center_loc,max(radius_loc));
            center(i,:)=center_loc;
            radius(i,:)=radius_loc;
        end
	end
end
    

return;

function sensors_out=sensors_in_sphere(sensors,center,radius);

[ns,ndun]=size(sensors);
sensors=sensors-repmat(center,ns,1);
norms=(sqrt( sum((sensors.^2)')))';
sensors_out=repmat(center,ns,1)+radius*sensors./repmat(norms,1,3);

return;

function weights=calc_weights(vc,sensors,distance_par);
     K=length(vc);
     [ns,ndum]=size(sensors);
     for k=1:K
         [nvcloc,ndum]=size(vc{k});
         for i=1:ns
               weights{k}=distance(vc{k}-repmat(sensors(i,:),nvcloc,1),distance_par);
         end
     end
     
return

function dist=distance(locs,distance_par);
  d=(sqrt( sum((locs.^2)')))';
  d0=distance_par.d0;
  p0=distance_par.p0;
  dist=1./(d+d0).^p0;
  
return;
  
  


 
 