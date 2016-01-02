% This code will show how to use funtions in repo to generate a HUCstr
% file. Using HUC4 basins as a example

%   1. Initial Basin Structure
shapefile='Y:\DataAnaly\basin_test.shp';
IDfieldname='HUC4';
Bstr = initialHUCstr( shapefile,IDfieldname );
sd=20050101;
sdnum=datenum(num2str(sd),'yyyymmdd');
ed=20050229;
ednum=datenum(num2str(ed),'yyyymmdd');
Bstr_t=sdnum:ednum;
save('Basin.mat','Bstr','Bstr_t');

%   2. Calculate Mask for each basin
x=-179.5:179.5;
y=89.5:-1:-59.5;
cellsize=1;
factor=4;
mask=GridMaskofHUC(shapefile,x,y,cellsize,factor);
save('mask_GLDAS.mat','mask');

%   3. Add data from GLDAS to basin structure
matname='Rainf';
fieldname='Rainf';
HUCstrFieldname='Rainf';
maskfile='mask_GLDAS.mat';
datafolder='Y:\GLDAS\V2\GLDAS_V2_mat';
[Bstr,Bstr_t]=GLDAS2HUC_daily(datafolder,matname,fieldname,HUCstrFieldname,maskfile,Bstr,Bstr_t);

%   4. Calculate rET
DEMfile='Y:\DataAnaly\global_dem\dem_GLDAS.mat';
GLDASfolder='Y:\GLDAS\V2\GLDAS_V2_mat';
GLDASdailyfolder=dir(GLDASfolder);
rET=[];t_rET=[];
for i=3:length(GLDASdailyfolder)
    folder=[GLDASfolder,'\',GLDASdailyfolder(i).name];
    [rETtemp,ttemp,x,y]=rET_Calculate_GLDAS(folder,DEMfile);
    rET=cat(3,rET,rETtemp);
    t_rET=cat(2,t_rET,ttemp);
end
Bstr = grid2HUC_daily( 'rET',rET,t_rET,mask,Bstr,Bstr_t);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% monthly data. Create a Bstr_tm as monthly date. GRACE, HUC4_Q, E_JBF are
% all monthly data

Bstr_tm=datenum(num2str(unique(str2num(datestr(Bstr_t,'yyyymm')))),'yyyymm');

%   1. Add GRACE
GRACEdata=load('Y:\GRACE\graceGrid_CSR.mat');
mask_GRACE=mask;
for i=1:length(mask_GRACE)
    masktemp=mask_GRACE{i};
    masktemp(151:180,:)=0;
    mask_GRACE{i}=masktemp;    
end
save('mask_GRACE.mat','mask');
Bstr = grid2HUC_month( 'S',GRACEdata.graceGrid_CSR,GRACEdata.t,mask_GRACE,Bstr,Bstr_tm);

%   2.Add GRACE Amp, Acf and Pcf
Bstr=acf2HUC(Bstr,Bstr_t);
Bstr=acf2HUC_detrend(Bstr,Bstr_t);
Bstr=amp2HUC(Bstr,Bstr_t);
Bstr=amp2HUC_fft(Bstr,Bstr_t);

%   3. Add USGS Q
usgsQ=load('Y:\DataAnaly\Runoff_huc4.mat');
[C,itusgs,itstr]=intersect(usgsQ.t,str2num(datestr(Bstr_tm,'yyyymm')));
[C,idusgs,idstr]=intersect(usgsQ.hucid,[Bstr.HUCid]);
for i=1:length(Bstr)
    id=idusgs(idstr==i);    
    if(~isempty(id))
        Q=usgsQ.Q(:,id);Q=Q';
        HUCstr(i).Q(itstr)=Q(itusgs);
    end
end

%   4. Add JBF E
JBFdata=load('Y:\ET_JBF\AET_JBF_10deg.mat');
Bstr = grid2HUC_month( 'E_JBF',JBFdata.E_JBF,JBFdata.tym,mask_GRACE,Bstr,Bstr_tm);

save('Basin.mat','Bstr','Bstr_t','Bstr_tm');

