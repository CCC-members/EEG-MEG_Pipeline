function show_megsystem(system,rad);

if nargin<2;
    rad=1;
end

[nchan,ndum]=size(system);

hold on;
for i=1:nchan
  loc_c=system(i,1:3);
  ori_c=system(i,4:6);
   circle(loc_c',ori_c',rad);
end




return;

function circle(loc,ori,rad)

phi=0:100;
phi=phi*2*pi/100;

ex=[1; 0; 0];
ey=[0; 1; 0];

x=rad*cos(phi);
y=rad*sin(phi);
z=0.*x;
mat=[x;y;z];


sx=ex'*ori;
sy=ey'*ori;


if sx>sy

u3=cross(ori,ey)/norm(cross(ori,ey));

else 

u3=cross(ori,ex)/norm(cross(ori,ex));

end; 

u2=cross(u3,ori);

u=[u2,u3,ori];

matb=u*mat+repmat(loc,1,101);


hold on;
plot3(matb(1,:),matb(2,:),matb(3,:),'-k','linewidth',1);



return