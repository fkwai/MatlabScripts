function s1 = concatStruct(s1,s2,varargin)
F = fieldnames(s1);

dim = 1;
if length(varargin)>0
    dim = varargin{1};
end

for i=1:length(F)
    f = F{i};
    s1.(f) = cat(dim,s1.(f),s2.(f));
end
