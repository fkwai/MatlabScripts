% this script will convert wm2 unit to mm

m=str2num(datestr(HUCstr_t,'mm'));
y=str2num(datestr(HUCstr_t,'yyyy'));
nday=eomday(y,m);
for i=1:length(HUCstr)
    HUCstr(i).TRANS_wm2=HUCstr(i).TRANS;
    HUCstr(i).PEvp_wm2=HUCstr(i).PEvp;
    HUCstr(i).TRANS=wm2mmPerMonth(HUCstr(i).TRANS,HUCstr(i).TMP,nday);
    HUCstr(i).PEvp=wm2mmPerMonth(HUCstr(i).PEvp,HUCstr(i).TMP,nday);
end
