function [T,D,Z] = cluster_Hierarchical( X,opt,value )
%CLUSTER_HIERARCHICAL Summary of this function goes here
%   opt = 1 - maxclust
%   opt = 2 - cutoff

D = pdist(X,'correlation');
DD=squareform(D);
Z = linkage(D);
% c = cophenet(Z,D)
% I = inconsistent(Z)

if opt==1
    T = cluster(Z,'maxclust',value);
elseif opt==2
    T = cluster(Z,'cutoff',value);
end

end

