mID=[1030,714,801,802,803,805,806,807,809];
if isfield(HUCstr,'HUCid')
    hucid=[HUCstr.HUCid];
else
    hucid=[HUCstr.ID];
end
ind=find(~ismember(hucid,mID));
HUCstr=HUCstr(ind);