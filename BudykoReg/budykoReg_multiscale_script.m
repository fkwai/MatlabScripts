load('Y:\ggII\MasterList\ggIIstr_USGScorr.mat')
ggIIstr2=ggIIstr;
load('Y:\ggII\MasterList\ggIIstr_BDreg.mat')
load('Y:\DataAnaly\HUCstr_new.mat')
load('Y:\DataAnaly\GRDCstr_sel.mat')

%% multi scale of ggII
%shapefiles to plot
shapeggII=shaperead('Y:\ggII\MasterList\ggIIstr_shape.shp');
shapeHUC=shaperead('Y:\DataAnaly\HUC\HUC4_main.shp');
shapeIDggII=cellfun(@str2num,{shapeggII.SITE_NO}');
shapeIDHUC=cellfun(@str2num,{shapeHUC.HUC4}');


%area=[ggIIstr2.Area_sqm]';
area=[GRDCstr_sel.AreaCalc]';
arealog=log10(area);
mina=min(arealog);
maxa=max(arealog);
hist(arealog,[mina:(maxa-mina)/20:maxa]);
[S,I]=sort(area,'descend');
ngg=length(area);

Mississippi_exclude
% [Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe]=...
%     budykoReg_MS( HUCstr,HUCstr_t);
% plotOutlier_selectRec(HUCstr(ind),shapeHUC,shapeIDHUC)

sel=[0,0.1];
indsel=I(ceil(ngg*sel(1))+1:ceil(ngg*sel(2)));
[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind]=budykoReg_MS( ggIIstr2(indsel),ggIIstr_t,HUCstr_t,[b]);
plotOutlier_selectRec(ggIIstr2(indsel(ind)),shapeggII,shapeIDggII)

[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind]=budykoReg_MS( ggIIstr2(indsel),ggIIstr_t,HUCstr_t,[]);

%% HUC4 and global GRDC

%run HUC4
Mississippi_exclude
% [Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe]=...
%     budykoReg_MS( HUCstr,HUCstr_t); % HUC4 regression

% replace the above with the following: {'AoP'} means using Amplitude over
% P as the only regression parameter
[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe]= budykoReg_MS_SCP( HUCstr,HUCstr_t, {'AoP'}); % HUC4 regression

% [Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe]=...
%     budykoReg_MS_GRDC( GRDCstr_sel,GRDCstr_sel_t,[HUCstr_t]);% GRDC regression of HUC4 time

% Replace the above with a call to the same function
[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe]= budykoReg_MS_SCP( GRDCstr_sel,GRDCstr_sel_t, {'AoP'}, HUCstr_t); % GRDC regression

% [Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe]=...
%     budykoReg_MS( HUCstr,HUCstr_t,[GRDCstr_sel_t],b,bXe);   %apply b from previous regression

[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe]= budykoReg_MS_SCP( HUCstr,HUCstr_t, {'AoP'},[GRDCstr_sel_t],b,bXe);

% [Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe]=...
%     budykoReg_MS( HUCstr,HUCstr_t,GRDCstr_sel_t);
[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,bXe]= budykoReg_MS_SCP( HUCstr,HUCstr_t, {'AoP'},[GRDCstr_sel_t]);

% [Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind]=...
%     budykoReg_MS_GRDC( GRDCstr_sel,GRDCstr_sel_t,HUCstr_t,b,bXe);
[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind]= budykoReg_MS_SCP(  GRDCstr_sel,GRDCstr_sel_t, {'AoP'},HUCstr_t,b,bXe);

% Below is a standard validation function with option to skip fitting to
% first BasinStr: faster access for loop scenario.
% It replaces the two statements above
[imp,stats] = task_formulaValidation(HUCstr,HUCstr_t,{'AoP'},GRDCstr_sel,GRDCstr_sel_t,[]);

%% plot of scale vs improvement
% based on area
iterclog=[11:-0.25:6];
iterc=10.^iterclog;
impall=zeros(length(iterclog)-2,1);
for i=2:length(iterclog)-1
    indsel=find(area<iterc(i-1)&area>=iterc(i+1));
    [Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind]=budykoReg_MS( ggIIstr2(indsel),ggIIstr_t,HUCstr_t,[b]);
    impall(i-1)=imp;
end
plot(iterc(2:end-1),impall);
set(gca,'XScale','log');
    
% based on rank
areakm=area/1e6;
bin=[1:150:length(ggIIstr)];
impall=zeros(length(bin)-2,1);
r1all=zeros(length(bin)-2,1);
r2all=zeros(length(bin)-2,1);
maall=zeros(length(bin)-2,1);
R2all=zeros(length(bin)-2,1);
option == 2;
if option == 1
    % Kuai's codes
    for i=2:length(bin)-1
        i
        indsel=I(bin(i-1):bin(i+1));
        ma=areakm(I(bin(i)));
        maall(i-1)=ma;
        [Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,r1,r2]=budykoReg_MS( ggIIstr2(indsel),ggIIstr_t,HUCstr_t,[b]);
        impall(i-1)=imp;
        r1all(i-1)=r1;
        r2all(i-1)=r2;
        R2all(i-1)=R2;
        close all;
    end
else
    b = [];
    for i=2:length(bin)-1
        i
        indsel=I(bin(i-1):bin(i+1));
        ma=areakm(I(bin(i)));
        maall(i-1)=ma;
        %[Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,r1,r2]=budykoReg_MS( ggIIstr2(indsel),ggIIstr_t,HUCstr_t,[b]);
        [IMP,STATS] = task_formulaValidation(HUCstr,HUCstr_t,{'AoP'},GRDCstr_sel,GRDCstr_sel_t,b)
        impall(i-1)=imp;
        r1all(i-1)=r1;
        r2all(i-1)=r2;
        R2all(i-1)=R2;
        % STATS: first row: budyko; second row: corrected budyko
        RMSE(i-1) = STATS(2,1); 
        close all;
    end
end

pickp=[1:5:length(impall)];
ma1=maall(pickp);
imp1=impall(pickp);
r11=r1all(pickp);
r21=r2all(pickp);
ma0=maall;ma0(pickp)=[];
imp0=impall;imp0(pickp)=[];
r10=r1all;r10(pickp)=[];
r20=r2all;r20(pickp)=[];

for j=1:length(pickp)
    i=pickp(j)+1;
    indsel=I(bin(i-1):bin(i+1));
    [Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind]=budykoReg_MS( ggIIstr2(indsel),ggIIstr_t,HUCstr_t,[b]);
    areamax=areakm(indsel(1));
    areamin=areakm(indsel(end));
    areamid=areakm(I(bin(i)));
    title(['Mid Area = ',num2str(areamid),' sqkm, [',num2str(areamax),' , ',num2str(areamin),']'])
    axis([0,1200,0,1200])
    plot121Line
    close all;
end

figure('Position', [100, 100, 700, 560]);
plot(maall,impall,'k-','LineWidth',1.5);hold on
plot(ma0,imp0,'ko','LineWidth',2);hold on
p1=plot(ma1,imp1,'r*','LineWidth',2);hold on
set(gca,'XScale','log');
set(gca, 'xdir','reverse')
xlabel('Basin Area (sqkm)')
ylabel('Improvement Ratio')
set(gca,'fontsize',18)
legend(p1(1),'picked scale')
title('Improvement Ration of Mutil-scale Basins')


figure('Position', [100, 100, 700, 560]);
plot(maall,r1all,'k-','LineWidth',1.5);hold on
plot(maall,r2all,'b-','LineWidth',1.5);hold on
p1=plot(ma0,r10,'ko','LineWidth',2);hold on
p2=plot(ma0,r20,'bo','LineWidth',2);hold on
p=plot(ma1,r11,'r*','LineWidth',2);hold on
plot(ma1,r21,'r*','LineWidth',2);hold on
set(gca,'XScale','log');
set(gca, 'xdir','reverse')
xlabel('Basin Area (sqkm)')
ylabel('R^2 to Observation')
set(gca,'fontsize',18)
pp=[];str={};
pp=[pp,p1(1),p2(1),p(1)];
str=[str,'R^2 of Corrected E and Obs','R^2 of Budyko E and Obs','picked scale'];
legend(pp,str)
title('R^2 to Observation of Multi-scale Basins')


%% use HUC4 GRACE related dataset
% load Y:\Kuai\USGSCorr\S_I.mat
% idall=[S_I.id];
% hucall=[HUCstr.ID];
% fields={'Amp_fft','Amp0','Amp1','acf_dtr48','pcf_dtr48',...
%     'acf_dtr72','pcf_dtr72','HurstExp','GRACE','GRACEt'};
% for i=1:length(ggIIstr)
%     id=ggIIstr(i).ID;
%     ind=find(idall==id);
%     hucid=S_I(ind).huc;
%     indhuc=find(hucall==hucid);
%     for j=1:length(fields)
%         ff=fields{j};
%         ggIIstr(i).(ff)=HUCstr(indhuc).(ff);
%     end
% end
% save Y:\ggII\MasterList\ggIIstr_BDreg.mat ggIIstr ggIIstr_t

% id1=find([HUCstr.ID]==1102);
% id2=find([ggIIstr.ID]==7130500);
% fields={'Rain','Snow','rET3','Amp_fft','Amp0','Amp1','acf_dtr48','pcf_dtr48',...
%     'acf_dtr72','pcf_dtr72','HurstExp','NDVI','SimInd','GRACE','usgsQ'};
% for i=1:length(fields)
%     figure  
%     d1=[HUCstr(id1).(fields{i})];
%     d2=[ggIIstr(id2).(fields{i})];
%     plot(d1,d2,'*');hold on
%     plot121Line;hold off
%     title(fields{i})
% end
% 
