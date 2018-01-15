% This example calls cgalmesher to mesh a segmented
% brain volume. The segmentation was done by FreeSurfer
% and there are 41 different types of tissues. Each tissue
% type is labeled by a unique integer.

fprintf(1,'loading segmented brain image...\n');
for i=1:256
  brain(:,:,i)=imread('brain_seg.tif',i);
end
brain=uint8(brain);

% call cgalmesher to mesh the segmented volume
% this will take 30 seconds on an Intel P4 2.4GHz PC

fprintf(1,'meshing the segmented brain (this may take a few minutes) ...\n');

[node,elem,face]=iso2mesh.v2m(brain,[],2,100,'cgalmesh');

figure
hs=iso2mesh.plotmesh(node,face,'y>100');

axis equal;
title('cross-cut view of the generated surface mesh');

% find the sub-region number 3, it happens to be the right-hemisphere
% cerebellum white matter. Use volface to extract the white matter surface.

fprintf(1,'extracting the right-hemisphere cerebellum white matter surface\n')

LHwhitemat=elem(find(elem(:,5)==5),:);
wmsurf=iso2mesh.volface(LHwhitemat(:,1:4));

figure;
hs=iso2mesh.plotmesh(node,wmsurf);
axis equal;
title('pre-smoothed cerebellum white matter surface');


fprintf(1,'performing mesh smoothing on the white matter surface\n')

[no,el]=iso2mesh.removeisolatednode(node,wmsurf);
wmno=iso2mesh.sms(no(:,1:3),el,3,0.5);

figure;
hs=iso2mesh.plotmesh(wmno,el);
axis equal;
title('smoothed cerebellum white matter surface of the right-hemisphere');


fprintf(1,'generate volumetric mesh from the smoothed cerebellum white matter surface \n')

[wmnode,wmelem,wmface]=iso2mesh.s2m(wmno(:,1:3),el(:,1:3),1,200);
