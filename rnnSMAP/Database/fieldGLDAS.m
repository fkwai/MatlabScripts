function [varName,mF,aF] = fieldGLDAS( field )
% for given GLDAS field name, return:
% 1. a variable name used in Database
% 2. a transfer factor to common unit. out=(in+aF)*mF
% reference to GLDAS v2 document

%% refine field name
C=strsplit(field,'_');
if strcmp(field,'Rainf_f_tavg')
    varName='Prcp';
elseif strcmp(field(1:4),'Soil')
    varName=[C{1},'-',C{2}(1:end-2)];
else
    varName=C{1};
end

%%
switch(field)
    case {'Snowf_tavg','Rainf_tavg','Evap_tavg','Rainf_f_tavg'} % convert to m/day
        mF=60*60*24;
        aF=0;
    case {'Qs_acc','Qsb_acc','Qsm_acc'}% convert to /day
        mF=8;
        aF=0;
    case {'AvgSurfT_inst','SoilTMP0_10cm_inst','SoilTMP0_40cm_inst','SoilTMP0_100cm_inst','SoilTMP0_200cm_inst'} % convert to C
        mF=1;
        aF=-273.15;
    otherwise
        mF=1;
        aF=0;
end

end

