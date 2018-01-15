function [node,elem]=meshresample(v,f,keepratio)
%
% [node,elem]=meshresample(v,f,keepratio)
%
% resample mesh using CGAL mesh simplification utility
%
% author: Qianqian Fang, <q.fang at neu.edu>
% date: 2007/11/12
%
% input:
%    v: list of nodes
%    f: list of surface elements (each row for each triangle)
%    keepratio: decimation rate, a number less than 1, as the percentage
%               of the elements after the sampling
%
% output:
%    node: the node coordinates of the sampled surface mesh
%    elem: the element list of the sampled surface mesh
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

[node,elem]=domeshsimplify(v,f,keepratio);

if(length(node)==0)
    warning(['Your input mesh contains topological defects, and the ',...
           'mesh resampling utility aborted during processing. Now iso2mesh ',...
           'is trying to repair your mesh with iso2mesh.meshcheckrepair. ',...
           'You can also call this manually before passing your mesh to meshresample.'] );
    [vnew,fnew]=iso2mesh.meshcheckrepair(v,f);
    [node,elem]=domeshsimplify(vnew,fnew,keepratio);
end
[node,I,J]=unique(node,'rows');
elem=J(elem);
iso2mesh.saveoff(node,elem,iso2mesh.mwpath('post_remesh.off'));

end

% function to perform the actual resampling
function [node,elem]=domeshsimplify(v,f,keepratio)
  exesuff=iso2mesh.getexeext;
  exesuff=iso2mesh.fallbackexeext(exesuff,'cgalsimp2');

  iso2mesh.saveoff(v,f,iso2mesh.mwpath('pre_remesh.off'));
  iso2mesh.deletemeshfile(iso2mesh.mwpath('post_remesh.off'));
  system([' "' iso2mesh.mcpath('cgalsimp2') exesuff '" "' iso2mesh.mwpath('pre_remesh.off') '" ' num2str(keepratio) ' "' iso2mesh.mwpath('post_remesh.off') '"']);
  [node,elem]=iso2mesh.readoff(iso2mesh.mwpath('post_remesh.off'));
end
