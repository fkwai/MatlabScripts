function [dataset,field,type] = DatasetOrg_ggII(IDI,ggII,S_I,HUCstr)
% add data from ggII, HUCstr to a dataset for supervised learning
% 
% load('Y:\Kuai\USGSCorr\usgsCorr','IDI') % IDI
% load('Y:\Kuai\USGSCorr\gagesII.mat')    %ggII
% load('Y:\Kuai\USGSCorr\usgsCorr','S_I') %S_I
% load('E:\work\DataAnaly\HUCstr_HUC4_32.mat')    %HUCstr


% add ggII data
idNew=IDI';
id=ggII.BasinID.STAID;
%[C,indNew,ind]=intersect(idNew,id); 
% bug cause C will be automatically sorted

ind=zeros(length(idNew),1);
for i=1:length(idNew)
    ind(i) = find(id == idNew(i));
end

%% ggII field selection

L1Var_Old={'BasinID','Bas_Classif','Bas_Morph','Bound_QA','Climate','FlowRec',...
    'Geology','Hydro','HydroMod_Dams','HydroMod_Other','Landscape_Pat',...
    'LC06_Basin','Soils','Topo'};

L2Var_Old=...
    ... %BasinID
    {{'DRAIN_SQKM'};...
    ... %Bas_Classif
    {'CLASS'};... 
    ... %Bas_Morph
    {'BAS_COMPACTNESS'};...
    ... %Bound_QA
    {'BASIN_BOUNDARY_CONFIDENCE','HUC10_CHECK'};...   
    ... %Climate
    {'PPTAVG_SITE','T_AVG_SITE','RH_SITE','PPTAVG_BASIN',...    
    'T_AVG_BASIN','RH_BASIN','FST32SITE','LST32SITE',...
    'PET','SNOW_PCT_PRECIP','ET'};...
    ... %FlowRec
    {'FLOW_PCT_EST_VALUES','FLOWYRS_1990_2009'};...   
    ... %Geology
    {'GEOL_REEDBUSH_DOM','GEOL_REEDBUSH_DOM_PCT','GEOL_REEDBUSH_SITE'};...    
    ... %Hydro
    {'STREAMS_KM_SQ_KM','MAINSTEM_SINUOUSITY',...
    'PERDUN','PERHOR','TOPWET','CONTACT','DEPTH_WATTAB'};...
    ... %HydroMod_Dams
    {'NDAMS_2009','DDENS_2009','STOR_NID_2009','RAW_DIS_NEAREST_DAM'};...   
    ... %HydroMod_Other
    {'CANALS_PCT','RAW_DIS_NEAREST_MAJ_NPDES'};... 
    ... %Landscape_Pat
    {'FRAGUN_BASIN','HIRES_LENTIC_NUM'};... 
    ... $LC06_basin
    {'DEVNLCD06','FORESTNLCD06','PLANTNLCD06','WATERNLCD06','SNOWICENLCD06',...
    'DEVOPENNLCD06','DEVLOWNLCD06','DEVMEDNLCD06','DEVHINLCD06','BARRENNLCD06',...
    'DECIDNLCD06','EVERGRNLCD06','MIXEDFORNLCD06','SHRUBNLCD06','GRASSNLCD06',...
    'PASTURENLCD06'};...
    ... %Soils
    {'AWCAVE','PERMAVE','BDAVE','OMAVE','WTDEPAVE','ROCKDEPAVE',...
    'HGA','HGB','HGAD','HGC','HGD','HGBC','HGVAR','CLAYAVE','SILTAVE','SANDAVE'};...    
    ... %Topo
    {'ELEV_SITE_M_30M','ELEV_STD_M_BASIN_30M','ELEV_MEAN_M_BASIN_30M','SLOPE_PCT_30M',...
    'RRMEAN_30M','ELEV_MAX_M_BASIN_30M','ELEV_MIN_M_BASIN_30M'}
    };

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
% L1Var={'BasinID','Bas_Morph','Climate','Geology','Topo'};
% 
% L2Var=...
%     ... %BasinID
%     {{'DRAIN_SQKM'};...
%     ... %Bas_Morph
%     {'BAS_COMPACTNESS'};...  
%     ... %Climate
%     {'PPTAVG_SITE','T_AVG_SITE','RH_SITE','PPTAVG_BASIN',...    
%     };...
%     ... %Geology
%     {'GEOL_REEDBUSH_DOM','GEOL_REEDBUSH_DOM_PCT','GEOL_REEDBUSH_SITE'};...     
%     ... %Topo
%     {'ELEV_SITE_M_30M','ELEV_STD_M_BASIN_30M','ELEV_MEAN_M_BASIN_30M','SLOPE_PCT_30M'}
%     };

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


%%
% add HUC4 and GRACE data
n=length(idNew);
Amp_P=zeros(n,1);
Amp1=zeros(n,1);
acf=zeros(n,1);
Ep_P=zeros(n,1);
NDVI=zeros(n,1);
snow_P=zeros(n,1);
SimIndex=zeros(n,1);
HUCid=[HUCstr.HUCid];
P=zeros(n,1);
for i=1:n
    ind=find(HUCid==S_I(i).huc);
    Amp_P(i)=HUCstr(ind).Amp_fft/nanmean(HUCstr(ind).Rain+HUCstr(ind).Snow)/12;
    Amp1(i)=HUCstr(ind).Amp1;
    acf(i)=HUCstr(ind).acf;
    Ep_P(i)=nanmean(HUCstr(ind).rET3)/nanmean(HUCstr(ind).Rain+HUCstr(ind).Snow);
    NDVI(i)=HUCstr(ind).NDVI_avg;
    snow_P(i)=nanmean(HUCstr(ind).Snow)/nanmean(HUCstr(ind).Rain+HUCstr(ind).Snow);
    SimIndex(i)=HUCstr(ind).SimIndex;
    P(i)=nanmean(HUCstr(ind).Rain+HUCstr(ind).Snow);
end
dataset=[dataset,Amp_P,Amp1,acf,Ep_P,NDVI,snow_P,SimIndex,P];
field=[field;'Amp/P';'Amp1';'acf';'Ep/P';'NDVI';'snow/P';'SimIndex';'P'];
type=[type;zeros(8,1)];

%save('Y:\Kuai\USGSCorr\dataset.mat','dataset','field','type')

