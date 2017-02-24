load('E:\Kuai\SSRS\gagesII.mat')

% fix error data
temp=[];
for i=1:length(ggII.BasinID.DIVISION)
    if ~iscellstr(ggII.BasinID.DIVISION(i))
        temp=[temp;i];
    end
end

ggII.BasinID.DIVISION(857:859)=ggII.BasinID.DIVISION(856);
ggII.BasinID.DIVISION(1076)=ggII.BasinID.DIVISION(1075);
ggII.BasinID.DIVISION(1102)=ggII.BasinID.DIVISION(1101);
ggII.BasinID.DIVISION(1141)=ggII.BasinID.DIVISION(1140);
ggII.BasinID.DIVISION(1194)=ggII.BasinID.DIVISION(1193);
ggII.BasinID.DIVISION(1886)=ggII.BasinID.DIVISION(1885);
ggII.BasinID.DIVISION(1966)=ggII.BasinID.DIVISION(1967);
ggII.BasinID.DIVISION(2116)=ggII.BasinID.DIVISION(2117);

% build division.mat
% matfile='E:\Kuai\SSRS\data\usgsCorr_14_4881.mat';
% divfile='E:\Kuai\SSRS\data\division_14_4881.mat';
% matfile='E:\Kuai\SSRS\data\usgsCorr_12_4919.mat';
% divfile='E:\Kuai\SSRS\data\division_12_4919.mat';
matfile='E:\Kuai\SSRS\data\usgsCorr_mB_4949.mat';
divfile='E:\Kuai\SSRS\data\division_mB_4949.mat';


load(matfile)
division=cell(length(ID),1);
province=cell(length(ID),1);
for i=1:length(ID)
    ind=find(ggII.BasinID.STAID==ID(i));
    division(i)=ggII.BasinID.DIVISION(ind);
    province(i)=ggII.BasinID.PROVINCE(ind);
end

divCode=codeIndividual(division,[],1);
divName={'APPALACHIAN HIGHLANDS';'ATLANTIC PLAIN';'INTERIOR HIGHLANDS';...
    'INTERIOR PLAINS';'INTERMONTANE PLATEAUS';'LAURENTIAN UPLAND';...
    'PACIFIC MOUNTAIN SYSTEM';'ROCKY MOUNTAIN SYSTEM'};
save(divfile','divCode','divName')