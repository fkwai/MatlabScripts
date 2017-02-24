% all code will start from usgsCorr2.mat and dataset2.mat. Here describe how those two are generated. 

PERIODS = {[20021001 20120930],[20030101 20121231],[20021001 20140930],[20030101 20141231]};
supname={'WY_02_12','CY_03_12','WY_02_14','CY_03_14'};
load('Y:\Kuai\USGSCorr\usgs2\CORR_ALL.mat')
savefolder='E:\Kuai\SSRS\data\';

%% extract usgsCorr.mat
ind=cell(4,1);
[C,ind{1},ind{2}]=intersect(IDs_ALL{1},IDs_ALL{2},'stable');
[C,ind{3},ind{4}]=intersect(IDs_ALL{3},IDs_ALL{4},'stable');

UCfilename=cell(4,1);
for i=1:4
    CorrMax=CORR_ALL{i}(:,:,1,1);
    CorrMin=CORR_ALL{i}(:,:,2,1);
    usgsCorr=[CorrMax(:,1:15),CorrMin(:,1:15)];
    idCorr=IDs_ALL{i}';
    ID=idCorr;
    usgsCorr=usgsCorr(ind{i},:);
    ID=ID(ind{i});
    ngage=length(ID);
    UCfilename{i}=[savefolder,'\usgsCorr_',supname{i},'_',num2str(ngage),'.mat'];
    save(UCfilename{i},'usgsCorr','ID');
end

%% find common ID with ggII and save
load('Y:\ggII\MasterList\refTable.mat')
IDall=refTable.ID;
for i=1:4
    mat=load(UCfilename{i});
    [C,ind,indall]=intersect(mat.ID,IDall,'stable');
    usgsCorr=mat.usgsCorr(ind,:);
    ID=mat.ID(ind);
    ngage=length(ID);
    UCfilename{i}=[savefolder,'\usgsCorr_',supname{i},'_',num2str(ngage),'.mat'];
    save(UCfilename{i},'usgsCorr','ID');
end
save E:\Kuai\SSRS\data\UCfilename UCfilename

%% ggIIstr - not involove time.. 
load Y:\ggII\MasterList\refTable.mat
load E:\Kuai\SSRS\data\UCfilename

for k=1:18
    ggIIdir='Y:\ggII';
    ns=sprintf('%02d',k);    
    strmatfile=[ggIIdir,'\basins',ns,'\basins',ns,'_str2.mat'];
    cmdstr=['basinstr_',ns,'=load(''',strmatfile,''')'];
    eval(cmdstr);
end
fields=fieldnames(basinstr_01.BasinStr);
ggIIstr_t=basinstr_01.BasinStr_t;

GGfilename=cell(4,1);
for k=1:length(UCfilename)
    ggIIstr=struct(basinstr_01.BasinStr(1));
    mat=load(UCfilename{k});
    for i=1:length(mat.ID)
        i
        id=mat.ID(i);
        ind=find(refTable.ID==id);
        ns=refTable.REG(ind);
        cmdstr=['BasinStr=basinstr_',ns{1},'.BasinStr;'];
        eval(cmdstr)
        ind2=find([BasinStr.ID]==id);
        ggIIstr(i)=BasinStr(ind2);
    end
    
    for i=1:length(mat.ID)
        id=mat.ID(i);
        ind=find(refTable.ID==id);
        ns=refTable.REG(ind);
        ggIIstr(i).Reg=ns;
        ggIIstr(i).Area_sqm=refTable.DArea_sqm(ind);
    end
    ggIIstr=ggIIstr';
    ngage=length(mat.ID);
    GGfilename{k}=[savefolder,'\ggIIstr_',supname{k},'_',num2str(ngage),'.mat'];
    save(GGfilename{k},'ggIIstr','ggIIstr_t');
end

%% combind WY and CY
%ggIIstr
load('ggIIstr_CY_03_14_4881.mat')
save('ggIIstr_14_4881.mat','ggIIstr','ggIIstr_t');
load('ggIIstr_CY_03_12_4919.mat')
save('ggIIstr_12_4919.mat','ggIIstr','ggIIstr_t');

%usgsCorr: WY - max 1:15, CY - min 16:30
mat1=load('E:\Kuai\SSRS\data\usgsCorr_WY_02_14_4881.mat');
mat2=load('E:\Kuai\SSRS\data\usgsCorr_CY_03_14_4881.mat');
usgsCorr=[mat1.usgsCorr(:,1:15),mat2.usgsCorr(:,16:30)];
ID=mat1.ID;
save('usgsCorr_14_4881.mat','usgsCorr','ID');

%usgsCorr: WY - max 1:15, CY - min 16:30
mat1=load('E:\Kuai\SSRS\data\usgsCorr_WY_02_12_4919.mat');
mat2=load('E:\Kuai\SSRS\data\usgsCorr_CY_03_12_4919.mat');
usgsCorr=[mat1.usgsCorr(:,1:15),mat2.usgsCorr(:,16:30)];
ID=mat1.ID;
save('usgsCorr_12_4919.mat','usgsCorr','ID');


%% write shapefile
load E:\Kuai\SSRS\data\usgsCorr_14_4881.mat
shapefile='Y:\ggII\gagesII_9322_point_shapefile\gagesII_9322_prj.shp';
shape=shaperead(shapefile);
idCorr=ID;
idshape=cellfun(@str2num,{shape.STAID}');
[C,indCorr,indshape]=intersect(idCorr,idshape,'stable');
shapenew=shape(indshape);
shapewrite(shapenew,'E:\Kuai\SSRS\data\gages_14_4881');

load E:\Kuai\SSRS\data\usgsCorr_12_4919.mat
shapefile='Y:\ggII\gagesII_9322_point_shapefile\gagesII_9322_prj.shp';
shape=shaperead(shapefile);
idCorr=ID;
idshape=cellfun(@str2num,{shape.STAID}');
[C,indCorr,indshape]=intersect(idCorr,idshape,'stable');
shapenew=shape(indshape);
shapewrite(shapenew,'E:\Kuai\SSRS\data\gages_12_4919');

%% ggIIstr_fixGRACE.m

%% Sum up to dataset
% load('E:\Kuai\SSRS\data\usgsCorr_14_4881.mat')
% load('E:\Kuai\SSRS\data\ggIIstr_14_4881_fixnan.mat')

load('E:\Kuai\SSRS\data\usgsCorr_12_4919.mat')
load('E:\Kuai\SSRS\data\ggIIstr_12_4919_fixnan.mat')
usgsCorr_t=datenumMulti(unique(datenumMulti(datenumMulti(200210,1):datenumMulti(201209,1),3)),1);

load('E:\Kuai\SSRS\gagesII.mat')
load('Y:\DataAnaly\BasinStr\HUCstr_new.mat')
load('Y:\Kuai\USGSCorr\usgsCorr.mat','TAB')

IDusgs=ID;
[C,ind1,ind2]=intersect(ID,TAB(:,1),'stable');
IDhuc=TAB(ind2,2);
[dataset,field,type] = DatasetOrg2_ggII(IDusgs,IDhuc,ggII,ggIIstr,HUCstr,usgsCorr_t,ggIIstr_t,HUCstr_t);

% save('E:\Kuai\SSRS\data\dataset_14_4881.mat','dataset','field','type','ID')
save('E:\Kuai\SSRS\data\dataset_12_4919.mat','dataset','field','type','ID')

%% geophysical division
% E:\Kuai\SSRS\geodivision.m



