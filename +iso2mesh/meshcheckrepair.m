function [node,elem]=meshcheckrepair(node,elem,opt,varargin)
%
% [node,elem]=meshcheckrepair(node,elem,opt)
% 
% check and repair a surface mesh
%
% author: Qianqian Fang, <q.fang at neu.edu>
% date: 2008/10/10
%
% input/output:
%      node: input/output, surface node list, dimension (nn,3)
%      elem: input/output, surface face element list, dimension (be,3)
%      opt: options, including
%            'dupnode': remove duplicated nodes
%            'dupelem' or 'duplicated': remove duplicated elements
%            'dup': both above
%            'isolated': remove isolated nodes
%            'open': abort when open surface is found
%            'deep': call external jmeshlib to remove non-manifold vertices
%            'meshfix': repair a closed surface by the meshfix utility (new)
%                       it can remove self-intersecting elements and fill holes
%            'intersect': test a surface for self-intersecting elements
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

extra=iso2mesh.varargin2struct(varargin{:});

if(nargin<3 || strcmp(opt,'dupnode')|| strcmp(opt,'dup'))
    l1=size(node,1);
    [node,elem]=iso2mesh.removedupnodes(node,elem,iso2mesh.jsonopt('Tolerance',0,extra));
    l2=size(node,1);
    if(l2~=l1) fprintf(1,'%d duplicated nodes were removed\n',l1-l2); end
end

if(nargin<3 || strcmp(opt,'duplicated')|| strcmp(opt,'dupelem')|| strcmp(opt,'dup'))
    l1=size(elem,1);
    elem=iso2mesh.removedupelem(elem);
    l2=length(elem);
    if(l2~=l1) fprintf(1,'%d duplicated elements were removed\n',l1-l2); end
end

if(nargin<3 || strcmp(opt,'isolated'))
    l1=length(node);
    [node,elem]=iso2mesh.removeisolatednode(node,elem);
    l2=length(node);
    if(l2~=l1) fprintf(1,'%d isolated nodes were removed\n',l1-l2); end
end

if(nargin==3 && strcmp(opt,'open'))
    eg=iso2mesh.surfedge(elem);
    if(~isempty(eg)) 
        error('open surface found, you need to enclose it by padding zeros around the volume');
    end
end

if(nargin<3 || strcmp(opt,'deep'))
    exesuff=iso2mesh.getexeext;
    exesuff=iso2mesh.fallbackexeext(exesuff,'jmeshlib');
    iso2mesh.deletemeshfile(iso2mesh.mwpath('post_sclean.off'));
    iso2mesh.saveoff(node(:,1:3),elem(:,1:3),iso2mesh.mwpath('pre_sclean.off'));
    system([' "' iso2mesh.mcpath('jmeshlib') exesuff '" "' iso2mesh.mwpath('pre_sclean.off') '" "' iso2mesh.mwpath('post_sclean.off') '"']);
    [node,elem]=iso2mesh.readoff(iso2mesh.mwpath('post_sclean.off'));
end

exesuff=iso2mesh.fallbackexeext(iso2mesh.getexeext,'meshfix');
moreopt=' -q -a 0.01 ';
if(isstruct(extra) && isfield(extra,'MeshfixParam'))
    moreopt=extra.MeshfixParam;
end

if(nargin>=3 && strcmp(opt,'meshfix'))
    iso2mesh.deletemeshfile(iso2mesh.mwpath('pre_sclean.off'));
    iso2mesh.deletemeshfile(iso2mesh.mwpath('pre_sclean_fixed.off'));
    iso2mesh.saveoff(node,elem,iso2mesh.mwpath('pre_sclean.off'));
    system([' "' iso2mesh.mcpath('meshfix') exesuff '" "' iso2mesh.mwpath('pre_sclean.off') ...
        '" ' moreopt]);
    [node,elem]=iso2mesh.readoff(iso2mesh.mwpath('pre_sclean_fixed.off'));
end

if(nargin>=3 && strcmp(opt,'intersect'))
    moreopt=sprintf(' -q --no-clean --intersect -o "%s"',iso2mesh.mwpath('pre_sclean_inter.msh'));
    iso2mesh.deletemeshfile(iso2mesh.mwpath('pre_sclean.off'));
    iso2mesh.deletemeshfile(iso2mesh.mwpath('pre_sclean_inter.msh'));
    iso2mesh.saveoff(node,elem,iso2mesh.mwpath('pre_sclean.off'));
    system([' "' iso2mesh.mcpath('meshfix') exesuff '" "' iso2mesh.mwpath('pre_sclean.off') ...
        '" ' moreopt]);
    %[node,elem]=readoff(mwpath('pre_sclean_inter.off'));
end
