%  GIT Notes for resetting a branch completely to another branch so that
%  dev_branch == master
% git checkout master
% git merge -s ours dev_branch
% git checkout dev_branch
% git merge master

% overwriteFiles = true;
% packageTopDirectory = false;
% packagePacker('../iso2mesh', {'bin', 'doc', 'sample'}, overwriteFiles, packageTopDirectory)