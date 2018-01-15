%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   demo script to insert new nodes to a tetrahedral mesh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load rat_head.mat

[node,elem,face]=iso2mesh.vol2mesh(volimage>0.05,1:size(volimage,1),1:size(volimage,2),...
                           1:size(volimage,3),2,2,1);

iso2mesh.plotmesh(node,face);

dt=pi/10;
r=3;
x0=30;
y0=28;
theta=dt:dt:2*pi;
x=x0+r*cos(theta);
y=y0+r*sin(theta);

p0=[x;y;ones(1,length(theta))*50]';
v0=[0,0,-1];

[t,u,v,idx,xnode]=iso2mesh.raysurf(p0,v0,node,face(:,1:3));

hold on
iso2mesh.plotmesh(p0,'r+');

goodpt=find(~isnan(xnode(:,1)) & ~isnan(xnode(:,2)) & ~isnan(xnode(:,3)));
[newnode,newelem,newface]=iso2mesh.meshrefine(node,elem,face,xnode(goodpt,:));

figure
iso2mesh.plotmesh(newnode,newface);
hold on
iso2mesh.plotmesh(p0,'r+');
iso2mesh.plotmesh(xnode,'r.')
