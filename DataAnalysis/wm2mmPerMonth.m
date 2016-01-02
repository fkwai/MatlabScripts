function mmpermonth = wm2mmPerMonth(wm2,Tavg,ndaysMonth)
% this function will convert W/m^2 to mm/month
mmpermonth = wm2./(2.501-2.361e-3.*Tavg)./1e6*86400.*ndaysMonth;