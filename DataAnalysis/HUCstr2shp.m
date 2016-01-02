function HUCstr2shp( HUCstr,HUCstr_t, HUCshpfile, outputshpfile )
%HUCSTR2SHP Summary of this function goes here
%   Detailed explanation goes here
%   
%   
%   outputshpfile='Y:\DataAnaly\HUC\HUC4_main_data.shp';
%   HUCshpfile='Y:\DataAnaly\HUC\HUC4_main.shp';


shape=shaperead(HUCshpfile);

if(length(shape)~=length(HUCstr))
    error('input HUCstr and shapefile do not match')
end

sd=datenum(num2str(20031001),'yyyymmdd');
ed=datenum(num2str(20121001),'yyyymmdd');
tt=HUCstr_t;
ind=find(tt<ed&tt>=sd);

for i=1:length(HUCstr)
    shape(i).P=mean(HUCstr(i).Rain(ind)+HUCstr(i).Snow(ind));
    shape(i).Rain=mean(HUCstr(i).Rain(ind));
    shape(i).Snow=mean(HUCstr(i).Snow(ind));
    shape(i).Evp=mean(HUCstr(i).Evp(ind));
    shape(i).PEvp=mean(HUCstr(i).PEvp(ind));
    
    dStemp=HUCstr(i).dS;
    dStemp(isnan(dStemp))=0;
    shape(i).dS=mean(dStemp(ind));    
    
    if (~isempty(HUCstr(i).Q))
        shape(i).Q=mean(HUCstr(i).Q(ind) );
    else
        shape(i).Q=0;
    end    
    
    shape(i).Amp0=HUCstr(i).AvgAmp0;    
    shape(i).Amp1=HUCstr(i).AvgAmp1;
end

shapewrite(shape,outputshpfile)



end

