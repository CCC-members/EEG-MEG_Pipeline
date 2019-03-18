function [xrange,yrange,zrange,cube]=grid2cube(grid);

[ng,ndum]=size(grid);
grid=round(grid*10000);

gmin=min(grid);
gmax=max(grid);

dgrid=grid-repmat(grid(1,:),ng,1);
dgrid=dgrid(2:end,:);
d=round(min(sqrt(sum(dgrid.^2,2))))

xrange=(gmin(1):d:gmax(1))/10000;
yrange=(gmin(2):d:gmax(2))/10000;
zrange=(gmin(3):d:gmax(3))/10000;


return;