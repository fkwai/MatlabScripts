function HUCstr = initialHUCstr( hucshapefile,IDfieldname )

%   example
%   hucshapefile='E:\work\DataAnaly\HUC\HUC4';
%   IDfieldname='HUC4';

HUCstr=struct('ID',[]);
shape=shaperead(hucshapefile);

for i=1:length(shape)
    HUCid=eval(['shape(i).',IDfieldname]);
    if isstr(HUCid)
        HUCstr(i,1).ID=str2num(HUCid);
    else
        HUCstr(i,1).ID=HUCid;
    end

end


end

