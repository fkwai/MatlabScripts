function [tickPos,tickVal,tickLabel,datOut,nColor] = colorBarRange(range, nlevel, openEnds, varargin)
% helper for discrete coloring
% from range(1) to range (2), separete into nlevel bins (so nlevel+1
% bounds & nlevel intervals). If we consider the region outside we can have
% n+2 colors.
% openEnds [0/1 0/1] describes whether left end or right end opens up one
% more bin
% varargin: a data that will be processed.
tickPos=[]; tickL = {}; datOut = [];
openEnds=openEnds>0; % convert to 0 & 1
div = (range(2)-range(1))/nlevel;
bounds = linspace(range(1),range(2),nlevel+1);
offset  = 0;
if length(varargin)>0
    dat = varargin{1};
end
insert0  = 1;
if length(varargin)>1
    insert0 = varargin{2};
end
if insert0
    [k,bounds,pos] = insertZero(bounds);
end
tickPos = bounds;

if openEnds(1)
    offset = 1;
else
    dat(dat<range(1))=range(1)+eps;
end
if openEnds(2)
else
    dat(dat>range(2))=range(2)-eps;
end

if length(varargin)>0
    datOut = dat * 0;
    datOut(dat<=bounds(1))=offset;
    for i=1:length(bounds)-1
        datOut(dat>bounds(i) & dat<=bounds(i+1))=i+offset;
    end
    datOut(dat>bounds(end))=length(bounds)+offset;
    if ~openEnds(1)
        datOut(dat==range(1))=1;
    end
end
if any(isnan(dat(:))), withNaN = 1; else withNaN = 0; end
nColor = (length(bounds)-1+sum(openEnds)+withNaN);
%
% correct but not derived from bounds
v = ver('Matlab'); v = str2num(v.Release(3:6));
if v<2017
    div   = 1/nColor; % this is correct regardless of how bounds are set
    if openEnds(1), t1=div*(1+withNaN)-eps; else t1=div*withNaN; end
    if openEnds(2), t2=1-div+eps; else, t2=1; end
else
    % the interpretation of position seem to have changed for the colorbar
    div   = 1;
    if openEnds(1), t1=div*(1+withNaN)-eps; else t1=div*withNaN; end
    if openEnds(2), t2=nColor-div+eps; else, t2=nColor; end
end
%
tickVal = bounds;
tickPos  = t1:div:t2;

% f1 = @(x) num2str(x,'%.3f');
% tickLabel =cellfun(f1,num2cell(bounds),'UniformOutput',false);
tickLabel =cellfun(@num2str,num2cell(bounds),'UniformOutput',false);
