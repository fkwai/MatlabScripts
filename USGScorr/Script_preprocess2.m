load('E:\Kuai\SSRS\data\CORR_mB_3_3_and_8_4.mat')
load('E:\Kuai\SSRS\data\IDs_mB_3_3_and_8_4.mat')
savefolder='E:\Kuai\SSRS\data\';

%%
CorrMax=CORR(:,:,1,1);
CorrMin=CORR(:,:,2,1);
usgsCorr=[CorrMax(:,1:15),CorrMin(:,1:15)];
ID=IDs';
ngage=length(ID);
UCfilename=[savefolder,'\usgsCorr_mB_',num2str(ngage),'.mat'];
save(UCfilename,'usgsCorr','ID');

%%
load('Y:\ggII\MasterList\refTable.mat')
IDall=refTable.ID;

mat=load(UCfilename);
[C,ind,indall]=intersect(mat.ID,IDall,'stable');
usgsCorr=mat.usgsCorr(ind,:);
ID=mat.ID(ind);
ngage=length(ID);
UCfilename2=[savefolder,'\usgsCorr_mB_',num2str(ngage),'.mat'];
save(UCfilename2,'usgsCorr','ID');

%% ggIIstr - not involove time.. 
load Y:\ggII\MasterList\refTable.mat

for k=1:18
    ggIIdir='Y:\ggII';
    ns=sprintf('%02d',k);    
    strmatfile=[ggIIdir,'\basins',ns,'\basins',ns,'_str2.mat'];
    cmdstr=['basinstr_',ns,'=load(''',strmatfile,''')'];
    eval(cmdstr);
end
fields=fieldnames(basinstr_01.BasinStr);
ggIIstr_t=basinstr_01.BasinStr_t;

ggIIstr=struct(basinstr_01.BasinStr(1));
mat=load(UCfilename2);
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
GGfilename=[savefolder,'\ggIIstr_mB_',num2str(ngage),'.mat'];
save(GGfilename,'ggIIstr','ggIIstr_t');

%% write shapefile
load E:\Kuai\SSRS\data\usgsCorr_mB_4949.mat
shapefile='Y:\ggII\gagesII_9322_point_shapefile\gagesII_9322_prj.shp';
shape=shaperead(shapefile);
idCorr=ID;
idshape=cellfun(@str2num,{shape.STAID}');
[C,indCorr,indshape]=intersect(idCorr,idshape,'stable');
shapenew=shape(indshape);
shapewrite(shapenew,'E:\Kuai\SSRS\data\gages_mB_4949');

%% ggIIstr_fixGRACE.m

%% Sum up to dataset
load('E:\Kuai\SSRS\data\usgsCorr_mB_4949.mat')
load('E:\Kuai\SSRS\data\ggIIstr_mB_4949_fixnan.mat')
usgsCorr_t=datenumMulti(unique(datenumMulti(datenumMulti(200210,1):datenumMulti(201209,1),3)),1);

load('E:\Kuai\SSRS\gagesII.mat')
load('Y:\DataAnaly\BasinStr\HUCstr_new.mat')
load('Y:\Kuai\USGSCorr\usgsCorr.mat','TAB')

IDusgs=ID;
[C,ind1,ind2]=intersect(ID,TAB(:,1),'stable');
IDhuc=TAB(ind2,2);
[dataset,field,type] = DatasetOrg2_ggII(IDusgs,IDhuc,ggII,ggIIstr,HUCstr,usgsCorr_t,ggIIstr_t,HUCstr_t);

save('E:\Kuai\SSRS\data\dataset_mB_4949.mat','dataset','field','type','ID')

%% get HUC2 ID from above section
IDhuc(:,2)=0;
IDhuc(:,2)=floor(IDhuc(:,1)/100);
save E:\Kuai\SSRS\data\IDhuc_mb_4949.mat IDhuc