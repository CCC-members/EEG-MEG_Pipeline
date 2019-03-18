function utang=getutang(unorm);

unorm=unorm/norm(unorm);

if abs(unorm(3))>.1;
    ux=[1;0;0];
    uy=cross(unorm,ux);
    uy=uy/norm(uy);
    ux=cross(uy,unorm);
    ux=ux/norm(ux);
    utang=[ux,uy];
elseif abs(unorm(2))>.1;
    uz=[0;0;1];
    ux=cross(unorm,uz);
    ux=ux/norm(ux);
    uz=cross(ux,unorm);
    uz=uz/norm(uz);
    utang=[uz,ux];
elseif abs(unorm(1))>.1;
    uy=[0;1;0];
    uz=cross(unorm,uy);
    uz=uz/norm(uz);
    uy=cross(uz,unorm);
    uy=uy/norm(uy);
    utang=[uy,uz];
end

return;
 

