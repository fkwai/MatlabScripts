GLDASdir='Y:\GLDAS\Monthly\GLDAS_matfile\NOAH_V2\';
GRACEdata=load('Y:\GRACE\graceGrid_CSR.mat');
GRACEcrd=load('Y:\GRACE\crd_GRACE_global.mat');
GRACEerr=load('Y:\GRACE\GRACE_ERR_grid.mat');

varList={'Rainf','Snowf','Qair','Wind','LWnet','SWnet','SoilM','SWE','Canopint'};
SvarList={'SoilM','SWE','Canopint'};
sd=datenumMulti(20021001,1);
ed=datenumMulti(20140930,1);
tm=unique(datenumMulti(sd:ed,3));
t=datenumMulti(tm,1);

%% process GRACE and MASK
tGRACE_month=unique(datenumMulti(GRACEdata.t,3));
[C,indGRACE,indt]=intersect(tGRACE_month,tm);

var=varList{1};
mat=load([GLDASdir,var,'.mat']);
matGLDAS=mat.(var);

bMask=ones(length(mat.(var)),1);
measureErr=zeros(length(mat.(var)),1);
matGRACE=zeros(length(mat.(var)),length(t)).*nan;
xg=GRACEdata.x;
yg=GRACEdata.y;

for j=1:length(mat.crd)
    x=mat.crd(j,1);
    y=mat.crd(j,2);
    indx=find(xg==x);
    indy=find(yg==y);
    v=reshape(GRACEdata.graceGrid(indy,indx,indGRACE),[length(indGRACE),1]);    
    if isempty(find(isnan(v), 1)) && sum(v)~=0
        vv=zeros(length(t),1)*nan;
        vv(indt)=v;
        vv=interpTS(vv,t,'spline');
        matGRACE(j,:)=vv;
    else 
        bMask(j)=0;
    end 
    
    vN=matGLDAS(j,:);
    if ~isempty(find(isnan(vN), 1))
        bMask(j)=0;
    end   
    
    measureErr(j)=GRACEerr.measure_Err(indy,indx);
end
%indMask=find(bMask==1);

% x=mat.crd(:,1);
% y=mat.crd(:,2);
% xland=x(indMask);
% yland=y(indMask);
% save indMask.mat indMask x y

%% measurement error
measureErr(measureErr==32767)=nan;
%mapmeaErr=rnnPred2map(measureErr(indMask));
bMask(measureErr>4)=0;

indMask=find(bMask==1);
x=mat.crd(:,1);
y=mat.crd(:,2);
xland=x(indMask);
yland=y(indMask);
save indMask.mat indMask x y xland yland

% %% continent each point belong to
% shapefile='Y:\Maps\WorldContinents.shp';
% shape=shaperead(shapefile);
% cont=zeros(length(indMask),1);
% 
% for i=1:length(shape)
%     i
%     indpoly=[0,find(isnan(shape(i).X))];    
%     for j=1:length(indpoly)-1
%         X=shape(i).X(indpoly(j)+1:indpoly(j+1)-1);
%         Y=shape(i).Y(indpoly(j)+1:indpoly(j+1)-1);        
%         inout = int32(zeros(size(xland)));
%         pnpoly(X,Y,xland,yland,inout);
%         inout=double(inout);
%         cont(inout==1)=i;
%     end
% end
% 
% mapcont=rnnPred2map(cont);

%% save GRACE and GLDAS
saveDir='E:\Kuai\rnnGRACE\data\';
prefix='gridTab';
perc=10;

%GRACE
matGRACE_save=matGRACE(indMask,:);
dlmwrite([saveDir,prefix,'GRACE.csv'], matGRACE_save, 'precision',16);
[matGRACE_save_norm,lb,ub,data_mean]=normalize_perc( matGRACE_save,perc);
dlmwrite([saveDir,prefix,'GRACE_norm.csv'], matGRACE_save_norm, 'precision',16);

%GLDAS
for i=1:length(varList)
    var=varList{i};
    mat=load([GLDASdir,var,'.mat']);
    matGLDAS=mat.(var);
    tGLDAS_month=mat.t;
    [C,indGLDAS,indt]=intersect(tGLDAS_month,tm);
    matGLDAS_save=matGLDAS(indMask,indGLDAS);
    dlmwrite([saveDir,prefix,var,'.csv'], matGLDAS_save, 'precision',16);
    [matGLDAS_save_norm,lb,ub,data_mean]=normalize_perc( matGLDAS_save,perc);
    dlmwrite([saveDir,prefix,var,'_norm.csv'], matGLDAS_save_norm, 'precision',16);
end

%Storage
matS=zeros(length(indMask),length(t));
for i=1:length(SvarList)
    var=SvarList{i};
    mat=load([GLDASdir,var,'.mat']);
    matGLDAS=mat.(var);
    tGLDAS_month=mat.t;
    [C,indGLDAS,indt]=intersect(tGLDAS_month,tm);
    matGLDAS_save=matGLDAS(indMask,indGLDAS);
    matS=matS+matGLDAS_save;    
end
dlmwrite([saveDir,prefix,'Storage.csv'], matS, 'precision',16)
[matS_norm,lb,ub,data_mean]=normalize_perc( matS,perc);
dlmwrite([saveDir,prefix,'Storage_norm.csv'], matS_norm, 'precision',16)

%Error
var='SoilM';
mat=load([GLDASdir,var,'.mat']);
matSoilM=mat.(var);
tGLDAS_month=mat.t;
[C,indGLDAS,indt]=intersect(tGLDAS_month,tm);
matSoilM_save=matGLDAS(indMask,indGLDAS);
matSoilM_mean=repmat(mean(matSoilM_save,2),[1,144]);
matSoilM_anorm=matSoilM_save-matSoilM_mean;
matErr=matGRACE_save-matSoilM_anorm;

dlmwrite([saveDir,prefix,'SErr.csv'], matErr, 'precision',16)
[matErr_norm,lb,ub,data_mean]=normalize_perc( matErr,perc);
dlmwrite([saveDir,prefix,'SErr_norm.csv'], matErr_norm, 'precision',16)


