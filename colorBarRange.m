function [tickPos,tickVal,tickLabel,dataOut,nColor] = colorBarRange(data,range, nlevel, openEnds, varargin)
% helper for discrete coloring
% from range(1) to range (2), separete into nlevel bins (so nlevel+1
% bounds & nlevel intervals). If we consider the region outside we can have
% n+2 colors.
% openEnds [0/1 0/1] describes whether left end or right end opens up one
% more bin
% varargin: a data that will be processed.

pnames={'insert0'};
dflts={1};
[insert0]=internal.stats.parseArgs(pnames, dflts, varargin{:});

openEnds=openEnds>0; % convert to 0 & 1
bounds = linspace(range(1),range(2),nlevel+1);
offset  = 0;

if insert0==1
    [k,bounds,pos] = insertZero(bounds);
end

if openEnds(1)
    offset = 1;
else
    data(data<range(1))=range(1)+eps;
end
if openEnds(2)
else
    data(data>range(2))=range(2)-eps;
end

dataOut = data * 0;
dataOut(data<=bounds(1))=offset;
for i=1:length(bounds)-1
    dataOut(data>bounds(i) & data<=bounds(i+1))=i+offset;
end
dataOut(data>bounds(end))=length(bounds)+offset;
if ~openEnds(1)
    dataOut(data==range(1))=1;
end

if any(isnan(data(:)))
    withNaN = 1;
else
    withNaN = 0; 
end
nColor = (length(bounds)-1+sum(openEnds)+withNaN);
%
% correct but not derived from bounds
v = ver('Matlab'); v = str2num(v.Release(3:6));
if v<0
    % this is correct regardless of how bounds are set
    div   = 1/nColor; 
    if openEnds(1)
        t1=div*(1+withNaN)-eps; 
    else
        t1=div*withNaN;
    end
    if openEnds(2)
        t2=1-div+eps; 
    else
        t2=1; 
    end
else
    % the interpretation of position seem to have changed for the colorbar
    div   = 1;
    if openEnds(1)
        t1=div*(1+withNaN)-eps; 
    else
        t1=div*withNaN;
    end
    if openEnds(2)
        t2=nColor-div+eps;
    else
        t2=nColor;
    end
end
%
tickVal = bounds;
tickPos  = t1:div:t2;

% f1 = @(x) num2str(x,'%.3f');
% tickLabel =cellfun(f1,num2cell(bounds),'UniformOutput',false);
tickLabel =cellfun(@num2str,num2cell(bounds),'UniformOutput',false);
