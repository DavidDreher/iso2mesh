%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   demo script for surface repairing using surf2vol and remeshsurf
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% preparation
% user must add the path of iso2mesh to matlab path list
% addpath('../');

% user need to add the full path to .../iso2mesh/bin directory
% to windows/Linux/Unix PATH environment variable

%% load the sample data
load rat_head.mat

% volimage is a volumetric image such as an X-ray or MRI image
% A,b are registration matrix and vector, respectively
%% perform mesh generation

[node,face]=iso2mesh.v2s(volimage,0.5,2,'cgalmesh');

node=node(:,1:3);
face=face(:,1:3);

iso2mesh.plotmesh(node,face);
axis equal

[newno,newfc]=iso2mesh.remeshsurf(node,face,1);

newno=iso2mesh.sms(newno,newfc(:,1:3),3,0.5);

figure;
iso2mesh.plotmesh(newno,newfc(:,1:3));
axis equal
