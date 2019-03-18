function sensors_out=sensors_on_surface(para_vc,sensors,msurf);

[n,m]=size(para_vc);

if nargin>2
    m=msurf;
end


sensors_out=mk_vcharm(sensors,para_vc{m}.center,para_vc{m}.coeffs);

return;
