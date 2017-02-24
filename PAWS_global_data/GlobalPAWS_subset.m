function GlobalPAWS_subset(datafolder,subsetdir,boundingbox,daterange)
%GLOABLPAWS_SUBSET Summary of this function goes here
%   this function will devide a Global PAWS Raw data into subset of
%   according bounding box and daterange.

%   example:
% subsetdir='Y:\GlobalRawData\NA\';
% datafolder='Y:\GlobalRawData\';
% boundingbox=[-125,25;-67,53];
% daterange=[20000101,20100101];
% GlobalPAWS_subset(datafolder,subsetdir,boundingbox,daterange)

datalstfile=[datafolder,'\datalist.txt'];
[fields,chars,file,S]=load_settings_file(datalstfile);

if ~(S.lon_left<boundingbox(1, 1) && S.lon_right>boundingbox(2, 1)...
        && S.lat_bottom<boundingbox(1, 2) && S.lat_top>boundingbox(2, 2))
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
Ssub.sd=datenumMulti(daterange(1),2);
Ssub.ed=datenumMulti(daterange(2),2);

%CRUNCEP subset
if isfield(S,'CRUNCEP') && ~isempty(S.CRUNCEP)
    disp('start CRUNCEP subsetting');tic
    CRUNCEPdir=S.CRUNCEP;
    CRUNCEPdirNEW=[subsetdir,'\CLM_forcing'];
    subset_CRUNCEP(boundingbox,daterange,CRUNCEPdir, CRUNCEPdirNEW);
    Ssub.CRUNCEP='\CLM_forcing';
    toc
end

%TRMM subset
if isfield(S,'TRMM') && ~isempty(S.TRMM)
    disp('start TRMM subsetting');tic
    TRMMdir=S.TRMM;
    TRMMdirNEW=[subsetdir,'\TRMM'];
    subset_TRMM(boundingbox,daterange,TRMMdir,TRMMdirNEW);
    Ssub.TRMM='\TRMM';
    toc
end

% %Global Soil Thickness
% if isfield(S,'SoilDepth') && ~isempty(S.SoilDepth)
%     disp('start Global Soil Thickness subsetting');tic
%     SoilDepthfile=S.SoilDepth;
%     SoilDepthfileNEW=[subsetdir,'\GW\GlobalSoilDepth.tif'];
%     subset_SoilDepth(boundingbox,SoilDepthfile,SoilDepthfileNEW);
%     Ssub.SoilDepth=SoilDepthdirNEW;
%     toc
% end

%Soil_CLM subset
if isfield(S,'Soil_CLM') && ~isempty(S.Soil_CLM)
    disp('start CLM soil subsetting');tic
    Soil_CLMdir=S.Soil_CLM;
    Soil_CLMdirNEW=[subsetdir,'\rawdata'];
    subset_Soil_CLM(boundingbox,Soil_CLMdir,Soil_CLMdirNEW);
    Ssub.Soil_CLM='\rawdata';
    toc
end

%LULC_CLM subset
if isfield(S,'LULC_CLM') && ~isempty(S.LULC_CLM)
    disp('start CLM soil subsetting');tic
    LULC_CLMdir=S.LULC_CLM;
    LULC_CLMdirNEW=[subsetdir,'\rawdata'];
    subset_LULC_CLM(boundingbox,LULC_CLMdir,LULC_CLMdirNEW);
    Ssub.LULC_CLM='\rawdata';
    toc
end

%Carbon init subset (fake)
if isfield(S,'CS_CLM') && ~isempty(S.CS_CLM)
    disp('start CLM soil subsetting');tic
    CS_CLMdir=S.CS_CLM;
    CS_CLMdirNEW=[subsetdir,'\initdata'];    
    if ~exist(CS_CLMdirNEW,'dir')
        mkdir(CS_CLMdirNEW);
    end
    filename='\clmi.BCN.2000-01-01_0.9x1.25_gx1v6_simyr2000_c100303.nc';
    copyfile([CS_CLMdir,filename],[CS_CLMdirNEW,filename])
    Ssub.CS_CLM='\initdata';
    toc
end

write_settings_file(Ssub,[subsetdir,'\datalist.txt']);


end

