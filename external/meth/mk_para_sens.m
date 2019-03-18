function para_sensors=mk_para_sens(para_vc,sens);

[ndum,nvc]=size(para_vc);
[nsens,ndum]=size(sens);


for i=1:nsens;
    sensout=mk_vcharm(sens(i,:),para_vc{nvc}.center,para_vc{nvc}.coeffs);
    [u,d]=anasens_b(sensout,para_vc{nvc}.center,para_vc{nvc}.coeffs);
    para_sensors{i}=struct('senslocs',sensout,'uall',u,'dall',d);
end

for i=1:nsens;
    for k=1:nvc
        sensout=mk_vcharm(sens(i,:),para_vc{k}.center,para_vc{k}.coeffs);
        para_sensors{i}.sensproj{k}=sensout;
    end
end

     
return 