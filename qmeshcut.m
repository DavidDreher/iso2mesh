function [cutpos,cutvalue,facedata]=qmeshcut(elem,node,value,plane)
% [cutpos,cutvalue,facedata]=qmeshcut(elem,node,value,plane)
%
% Fast un-structual mesh cross-sectional plot
%   by Qianqian Fang, <fangq at nmr.mgh.harvard.edu>
%
% parameters: 
%   elem: integer array with dimensions of NE x 4, each row contains
%         the indices of all the nodes for each tetrahedron
%   node: node coordinates, 3 columns for x, y and z respectively
%   value: a scalar array with the length of node numbers, can have 
%          multiple columns 
%   plane: defines a plane by 3 points: plane=[x1 y1 z1;x2 y2 z2;x3 y3 z3]
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)

% get the x,y,z of the 3 input points

x=plane(:,1);
y=plane(:,2);
z=plane(:,3);

% compute the plane equation a*x + b*y +c*z =d

a=y(1)*(z(2)-z(3))+y(2)*(z(3)-z(1))+y(3)*(z(1)-z(2));
b=z(1)*(x(2)-x(3))+z(2)*(x(3)-x(1))+z(3)*(x(1)-x(2));
c=x(1)*(y(2)-y(3))+x(2)*(y(3)-y(1))+x(3)*(y(1)-y(2));
d=-det(plane);

% compute which side of the plane for each nodes in the mesh
co=repmat([a b c],size(node,1),1);
dist=sum( (co.*node)' )+d;
asign=dist;
asign(find(asign>=0))=1;
asign(find(asign<0))=-1;

% get all the edges of the mesh

edges=[elem(:,[1,2]);elem(:,[1,3]);elem(:,[1,4]);
       elem(:,[2,3]);elem(:,[2,4]);elem(:,[3,4])];

% find all edges with two ends at the both sides of the plane
edgemask=sum(asign(edges),2);
cutedges=find(edgemask==0);
%edgemask=prod(asign(edges)');
%cutedges=find(edgemask<0);

% calculate the distances of the two nodes, and use them as interpolation weight 
cutweight=dist(edges(cutedges,:));
totalweight=diff(cutweight');

cutweight=abs(cutweight./repmat(totalweight(:),1,2));

% calculate the cross-cut position and the interpolated values

cutpos=node(edges(cutedges,1),:).*repmat(cutweight(:,2),[1 3])+...
       node(edges(cutedges,2),:).*repmat(cutweight(:,1),[1 3]);
cutvalue=value(edges(cutedges,1),:).*repmat(cutweight(:,2),[1 size(value,2)])+...
       value(edges(cutedges,2),:).*repmat(cutweight(:,1),[1 size(value,2)]);
   
% organize all cross-cuts into patch facedata format

emap=zeros(size(edges,1),1);
emap(cutedges)=1:length(cutedges);
emap=reshape(emap,[size(elem,1),6]);
faceid=find(any(emap,2)==1);
facelen=length(faceid);

% cross-cuts can only be triangles or quadrilaterals for tetrahedral mesh
% (co-plannar mesh needs to be considered)

etag=sum(emap>0,2);
tricut=find(etag==3);
quadcut=find(etag==4);

% fast way (vector-form) to get all triangles

tripatch=emap(tricut,:)';
tripatch=reshape(tripatch(find(tripatch)),[3,length(tricut)])';

% fast wall to get all quadrilaterals in convexhull form (avoid using convhulln)

quadpatch=emap(quadcut,:)';
quadpatch=reshape(quadpatch(find(quadpatch)),[4,length(quadpatch)])';

% combine the two sets to create the final facedata
% using the matching-tetrahedra algorithm as shown in 
% https://visualization.hpc.mil/wiki/Marching_Tetrahedra

facedata=[tripatch(:,[1 2 3 3]); quadpatch(:,[1 2 4 3])];

% plot your results with the following command

%patch('Vertices',cutpos,'Faces',facedata,'FaceVertexCData',cutvalue,'facecolor','interp');
