mID=[1030,714,801,802,803,805,806,807,809];
hucid=[HUCstr.ID];
ind=find(~ismember(hucid,mID));
HUCstr=HUCstr(ind);