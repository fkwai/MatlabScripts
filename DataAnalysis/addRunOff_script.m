%% GRDC
shape=shaperead('Y:\GRDC_UNH\GIS_dataset\grdc_basins_smoothed_sel.shp');
shapeID=[shape.GRDC_NO]';
for i=1:length(GRDCstr)
    ID=GRDCstr(i).ID;
    ind=find(shapeID==ID);
    GRDCstr(i).AreaCalc=shape(ind).AREA_HYS;
    if(shape(ind).DISC_HYS~=-999)
        GRDCstr(i).Q=shape(ind).DISC_HYS*(60*60*24*365)*1000^3/(shape(ind).AREA_HYS*10^12);
    else
        GRDCstr(i).Q=nan;
    end
end
save Y:\DataAnaly\Datastr\GRDCstr_new.mat GRDCstr GRDCstr_t


%% ggII
load('Y:\DataAnaly\Datastr\ggIIstrt_new.mat')
load('E:\Chaopeng\AMHG\usgs.mat')
for i=1:length(usgs)
    usgs(i).id=str2num(usgs(i).name); 
    usgs(i).v=usgs(i).v*0.3048^3;
end

usgsid=[usgs.id];
for i=1:length(ggIIstr)
    area=ggIIstr(i).Area_sqm;
    ID=ggIIstr(i).ID;
    ind=find(usgsid==ID);
    sd=ggIIstr_t(1);
    ed=ggIIstr_t(end);
    ts.t=usgs(ind).t;
    ts.v=usgs(ind).v;
    ts = truncateTS(ts,[sd,ed]);
    ts = wMonthly3(ts,'sum'); %m3/sec -> m3/month
    v=ts.v*60*60*24/area*1000; %mm/month
    ggIIstr(i).usgsQ1=ggIIstr(i).usgsQ;
    ggIIstr(i).usgsQ=v';
end

% recalculate SimInd
for i=1:length(ggIIstr)
    P=ggIIstr(i).Rain+ggIIstr(i).Snow;
    T=ggIIstr(i).Tmp;
    [ SimInd ] = SimIndex_cal( P, T, 12);
    ggIIstr(i).SimInd=SimInd;
end
ggIIstr=ggIIstr';
save Y:\DataAnaly\Datastr\ggIIstr_new.mat ggIIstr ggIIstr_t
