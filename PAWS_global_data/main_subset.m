%input
subsetdir='Y:\GlobalRawData\test\';
datafolder='Y:\GlobalRawData\';
boundingbox=[-125,25;-67,53];
daterange=[20010101,20110101];

datalstfile=[datafolder,'\datalist.txt'];
[fields,chars,file,S]=load_settings_file(datalstfile);

if ~(S.lon_left<boundingbox(1, 1) && S.lon_right>boundingbox(2, 1)...
        && lat_bottom<boundingbox(1, 2) && lat_top>boundingbox(2, 2))
    error('not include in bounding box')
end

if ~(S.sd<=daterange(1) && S.ed>=daterange(2))
    error('not include in date range')
end

Ssub=S;
Ssub.lon_left = boundingbox(1, 1);
Ssub.lon_right = boundingbox(2, 1);
Ssub.lat_bottom = boundingbox(1, 2);
Ssub.lat_top = boundingbox(2, 2);
Ssub.sd=daterange(1);
Ssub.ed=daterange(2);

%CRUNCEP subset
if isfield(S,'CRUNCEP') && ~isempty(S.CRUNCEP)
    CRUNCEPdir=S.CRUNCEP;
    CRUNCEPdirNEW=[subsetdir,'\CLM_forcing'];    
    subset_CRUNCEP(boundingbox,daterange,CRUNCEPdir, CRUNCEPdirNEW);
    Ssub.CRUNCEP=CRUNCEPdirNEW;
end

%TRMM subset
if isfield(S,'TRMM') && ~isempty(S.TRMM)
    TRMMdir=S.TRMM;
    TRMMdirNEW=[subsetdir,'\TRMM'];    
    subset_TRMM(boundingbox,daterange,TRMMdir,TRMMdirNEW);
    Ssub.TRMM=TRMMdirNEW;
end

%Soil_CLM subset
if isfield(S,'Soil_CLM') && ~isempty(S.Soil_CLM)
    Soil_CLMdir=S.Soil_CLM;
    Soil_CLMdirNEW=[subsetdir,'\rawdata'];    
    subset_Soil_CLM(boundingbox,Soil_CLMdir,Soil_CLMdirNEW);
    Ssub.Soil_CLM=Soil_CLMdirNEW;
end

%LULC_CLM subset
if isfield(S,'LULC_CLM') && ~isempty(S.LULC_CLM)
    LULC_CLMdir=S.LULC_CLM;
    LULC_CLMdirNEW=[subsetdir,'\rawdata'];    
    subset_LULC_CLM(boundingbox,LULC_CLMdir,LULC_CLMdirNEW);
    Ssub.LULC_CLM=LULC_CLMdirNEW;
end


write_settings_file(Ssub,[subsetdir,'datalist.txt']);
