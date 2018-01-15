function tempfname=mwpath(fname)
%
% tempname=meshtemppath(fname)
%
% get full temp-file name by prepend working-directory and current session name
%
% author: Qianqian Fang (fangq <at> nmr.mgh.harvard.edu)
%
% input:
%    fname: input, a file name string
%
% output:
%    tempname: output, full file name located in the working directory
%
%    if global variable ISO2MESH_TEMP is set in 'base', it will use it
%    as the working directory; otherwise, will use matlab function tempdir
%    to return a working directory.
%
%    if global variable ISO2MESH_SESSION is set in 'base', it will be
%    prepended for each file name, otherwise, use supplied file name.
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

p=iso2mesh.getvarfrom({'caller','base'},'ISO2MESH_TEMP');
session=iso2mesh.getvarfrom({'caller','base'},'ISO2MESH_SESSION');
persistent uuid
if isempty(uuid)
    [~, uuid] = fileparts(tempname);
end
username=getenv('USER'); % for Linux/Unix/Mac OS

if(isempty(username))
   username=getenv('UserName'); % for windows
end

if(~isempty(username))
   username=['iso2mesh-' username];
end

if(isempty(p))
    if(iso2mesh.isoctavemesh && tempdir=='\')
        tempfname=['.'  filesep session fname];
    else
        tdir=tempdir;
        if(tdir(end)~=filesep)
            tdir=[tdir filesep];
        end
        if(~isempty(username))
            tdir=[tdir username filesep];
        end
        tdir = [tdir, uuid, filesep];
        if(exist(tdir, 'dir')==0)
            mkdir(tdir);
        end
        if(nargin==0)
            tempfname=tdir;
        else
            tempfname=[tdir session fname];
        end
    end
else
    if(nargin==0)
        tempfname=[p, filesep];
    else
        tempfname=[p, filesep, session, fname];
    end
end
