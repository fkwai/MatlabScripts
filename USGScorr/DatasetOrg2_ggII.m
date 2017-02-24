function [dataset,field,type] = DatasetOrg2_ggII(IDusgs,IDhuc,ggII,ggIIstr,HUCstr,varargin)
% add data from ggII, HUCstr to a dataset for supervised learning
% difference from DatasetOrg_ggII: using usgs drainage basins. 
% 
% load('Y:\Kuai\USGSCorr\gagesII.mat')    %ggII
% load('Y:\Kuai\USGSCorr\S_I2.mat','S_I') %S_I
% load('Y:\ggII\MasterList\ggIIstr_USGScorr.mat ')    %ggIIstr
% load('E:\work\DataAnaly\HUCstr_HUC4_32.mat')    %HUCstr

% varargin: [usgsCorr_t, ggIIstr_t, HUCstr_t]
doDateInterp=0;
if ~isempty(varargin)
    usgsCorr_t=varargin{1};
    ggIIstr_t=varargin{2};
    HUCstr_t=varargin{3};
    doDateInterp=1;
end

% add ggII data
idNew=IDusgs;
id=ggII.BasinID.STAID;
%[C,indNew,ind]=intersect(idNew,id); 
% bug cause C will be automatically sorted

ind=zeros(length(idNew),1);
for i=1:length(idNew)
    ind(i) = find(id == idNew(i));
end

%% ggII field selection
L1Var={'BasinID','Bas_Morph','Climate','Geology',...
    'Hydro','HydroMod_Dams','Landscape_Pat',...
    'LC06_Basin','Soils','Topo'};

L2Var=...
    ... %BasinID
    {{'DRAIN_SQKM'};...
    ... %Bas_Morph
    {'BAS_COMPACTNESS'};...
    ... %Climate
    {'PPTAVG_BASIN',...    
    'T_AVG_BASIN','RH_BASIN','FST32SITE','LST32SITE',...
    'PET','WD_BASIN','SNOW_PCT_PRECIP','ET','PRECIP_SEAS_IND'};...
    ... %Geology
    {'GEOL_REEDBUSH_DOM','GEOL_REEDBUSH_DOM_PCT','GEOL_REEDBUSH_SITE','BEDROCK_PERM'};...
    ... %Hydro
    {'STREAMS_KM_SQ_KM','MAINSTEM_SINUOUSITY',...
    %'PERDUN','PERHOR','TOPWET','CONTACT','DEPTH_WATTAB'};... % NOT SURE
    'TOPWET','DEPTH_WATTAB'};...
    ... %HydroMod_Dams
    {'MAJ_DDENS_2009','STOR_NID_2009'};...   
    %... %HydroMod_Other
    %{'CANALS_PCT','RAW_DIS_NEAREST_MAJ_NPDES'};... 
    ... %Landscape_Pat
    {'FRAGUN_BASIN'};... 
    ... $LC06_basin
    {'DEVNLCD06','FORESTNLCD06','PLANTNLCD06','WATERNLCD06',...
    %'DEVOPENNLCD06','DEVLOWNLCD06','DEVMEDNLCD06','DEVHINLCD06','BARRENNLCD06',...
    %'DECIDNLCD06','EVERGRNLCD06','MIXEDFORNLCD06','SHRUBNLCD06','GRASSNLCD06',...
    %'PASTURENLCD06'};...
    };...
    ... %Soils
    %{'AWCAVE','PERMAVE','BDAVE','OMAVE','WTDEPAVE','ROCKDEPAVE',...
    {'AWCAVE','PERMAVE','BDAVE','OMAVE','ROCKDEPAVE',...
    'CLAYAVE','SILTAVE','SANDAVE',...
    'HGA','HGB','HGAD','HGC','HGD','HGBC'};...  % try commenting out this line to see how big difference it makes
    ... %Topo
    {'ELEV_STD_M_BASIN_30M','ELEV_MEAN_M_BASIN_30M','SLOPE_PCT_30M',...
    'RRMEAN_30M','ASPECT_NORTHNESS'}
    };


%% add selected fields to dataset
% some number should be treat as string. Like STAID.
lable={'STAID','HUC4','HUC12'};

dataset=[];
field={};
type=[];    %output type. 0 - numeric. 1 -  catagory
for i=1:length(L1Var)
    str1=L1Var{i};
    for j=1:length(L2Var{i})
        str2=L2Var{i}{j};
        temp=ggII.(str1).(str2);
        if isnumeric(temp)
            if any(strcmp(lable,str2))
                data=codeIndividual(temp,['Variable: ',str1,'.',str2],0);
                tp=1;
            else
                data=temp;
                tp=0;
            end
        elseif iscell(temp)
            if iscellstr(temp)
                data=codeIndividual(temp,['Variable: ',str1,'.',str2]);
                tp=1;
            else
                if any(strcmp(lable,str2))
                    data=codeIndividual(temp,['Variable: ',str1,'.',str2],0);
                    tp=1;
                else
                    temp(cellfun(@ischar,temp))={NaN};
                    data=cell2mat(temp);
                    tp=0;
                end
                
            end
        else
            warning(['look at ',str1,' ',str2])
        end
        dataset=[dataset,data];
        field=[field;[str1,'.',str2]];
        type=[type;tp];
    end
end
dataset=dataset(ind,:);

%% add ggII and GRACE data
n=length(idNew);
Amp_P=zeros(n,1);
Amp1=zeros(n,1);
acf=zeros(n,1);
Ep_P=zeros(n,1);
NDVI=zeros(n,1);
snow_P=zeros(n,1);
SimIndex=zeros(n,1);
ggIIid=[ggIIstr.ID];
P=zeros(n,1);

if doDateInterp==0
    tind=1:length(ggIIstr_t);
elseif doDateInterp==1
    [C,tind1,tind]=intersect(usgsCorr_t,ggIIstr_t);
end

for i=1:n
    ind=find(ggIIid==IDusgs(i));
    Amp_P(i)=ggIIstr(ind).Amp_fft/nanmean(ggIIstr(ind).Rain(tind)+ggIIstr(ind).Snow(tind))/12;
    Amp1(i)=ggIIstr(ind).Amp1;
    acf(i)=ggIIstr(ind).acf_dtr72;
    Ep_P(i)=nanmean(ggIIstr(ind).rET3(tind))/nanmean(ggIIstr(ind).Rain(tind)+ggIIstr(ind).Snow(tind));
    NDVI(i)=ggIIstr(ind).NDVI;
    snow_P(i)=nanmean(ggIIstr(ind).Snow(tind))/nanmean(ggIIstr(ind).Rain(tind)+ggIIstr(ind).Snow(tind));
    if ~isempty(ggIIstr(ind).SimInd)
        SimIndex(i)=ggIIstr(ind).SimInd.v;
    else
        SimIndex(i)=nan;
    end
    P(i)=nanmean(ggIIstr(ind).Rain(tind)+ggIIstr(ind).Snow(tind));
end
dataset=[dataset,Amp_P,Amp1,acf,Ep_P,NDVI,snow_P,SimIndex,P];
field=[field;'Amp/P';'Amp1';'acf';'Ep/P';'NDVI';'snow/P';'SimIndex';'P'];
type=[type;zeros(8,1)];

%% add HUC4 and GRACE data
n=length(idNew);
Amp_P=zeros(n,1);
Amp1=zeros(n,1);
acf=zeros(n,1);
Ep_P=zeros(n,1);
NDVI=zeros(n,1);
snow_P=zeros(n,1);
SimIndex=zeros(n,1);
HUCid=[HUCstr.ID];
P=zeros(n,1);

if doDateInterp==0
    tind=1:length(HUCstr_t);
elseif doDateInterp==1
    [C,tind1,tind]=intersect(usgsCorr_t,HUCstr_t);
end

for i=1:n
    ind=find(HUCid==IDhuc(i));
    Amp_P(i)=HUCstr(ind).Amp_fft/nanmean(HUCstr(ind).Rain(tind)+HUCstr(ind).Snow(tind))/12;
    Amp1(i)=HUCstr(ind).Amp1;
    acf(i)=HUCstr(ind).acf_dtr72;
    Ep_P(i)=nanmean(HUCstr(ind).rET3(tind))/nanmean(HUCstr(ind).Rain(tind)+HUCstr(ind).Snow(tind));
    NDVI(i)=HUCstr(ind).NDVI;
    snow_P(i)=nanmean(HUCstr(ind).Snow(tind))/nanmean(HUCstr(ind).Rain(tind)+HUCstr(ind).Snow(tind));
    if ~isempty(HUCstr(ind).SimInd)
        SimIndex(i)=HUCstr(ind).SimInd.v;
    else
        SimIndex(i)=nan;
    end
    P(i)=nanmean(HUCstr(ind).Rain(tind)+HUCstr(ind).Snow(tind));
end
dataset=[dataset,Amp_P,Amp1,acf,Ep_P,NDVI,snow_P,SimIndex,P];
field=[field;'Amp/P(HUC4)';'Amp1(HUC4)';'acf(HUC4)';'Ep/P(HUC4)';'NDVI(HUC4)';'snow/P(HUC4)';'SimIndex(HUC4)';'P(HUC4)'];
type=[type;zeros(8,1)];

% ID=[S_I.ID]'
% save('Y:\Kuai\USGSCorr\dataset2.mat','dataset','field','type','ID')

