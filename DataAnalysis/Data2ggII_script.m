
% load('Y:\DataAnaly\HUCstr_HUC4_32.mat')
% ggIIStr_t=HUCstr_t;
% ggIIdir='Y:\ggII';
% 

t1=datenumMulti(200210,1);
t2=datenumMulti(201409,1);
t=unique(datenumMulti(t1:t2,3));
tnum=datenumMulti(t,1);

%% add NLDAS and GRACE data
for k=1:18
    disp(['basin',num2str(k)]);tic
    
    t1=datenumMulti(200210,1);
    t2=datenumMulti(201409,1);
    t=unique(datenumMulti(t1:t2,3));
    tnum=datenumMulti(t,1);
    
    % put inside to empty memory
    %load('Y:\DataAnaly\HUCstr_HUC4_32.mat')
    ggIIstr_t=tnum;
    ggIIdir='Y:\ggII';
    
    ns=sprintf('%02d',k);
    maskfile=[ggIIdir,'\basins',ns,'\basins',ns,'_mask.mat'];
    shpfile=[ggIIdir,'\basins',ns,'\basins',ns,'.shp'];
    outmatfile=[ggIIdir,'\basins',ns,'\basins',ns,'_str2.mat'];
    ggIIstr=initialHUCstr( shpfile,'SITE_NO' );
    
    mask=load(maskfile);
    BasinStr=NAdata2Str_monthly( mask.maskNLDAS,mask.maskGRACE,mask.maskNDVI,ggIIstr,ggIIstr_t);
    BasinStr_t=ggIIstr_t;
    save(outmatfile,'BasinStr','BasinStr_t');
    toc
    clear all    
end

% download and add usgs data
for k=3:18    
    % put inside to empty memory    
    ggIIdir='Y:\ggII';
    
    tic
    ns=sprintf('%02d',k);    
    strmatfile=[ggIIdir,'\basins',ns,'\basins',ns,'_str.mat'];
    shpfile=[ggIIdir,'\basins',ns,'\basins',ns,'.shp'];    
    USGSsavedir=[ggIIdir,'\basins',ns,'\gages\'];
    if ~exist(USGSsavedir,'dir')
        mkdir(USGSsavedir);
    end
    
    S=load(strmatfile);
    shape=shaperead(shpfile);
    sd=datenumMulti(S.BasinStr_t(1),2);
    ed=datenumMulti(S.BasinStr_t(end)+31,2);
    
    emptygage={};
    for j=1:length(S.BasinStr)
        disp(['basin',num2str(k),'; site',num2str(j)]);
        S.BasinStr(j).usgsQ=zeros(length(S.BasinStr_t),1)*nan;
        usgsNo=shape(j).SITE_NO;
        
        try
            usgs=downloadUSGS_kuai(usgsNo, 'streamflow',USGSsavedir,[sd,ed]);
            %usgs.v=usgs.v*60*60*24;  %m3/s -> m3/day can not do it here. Will be removed in wMonthly3                
            ts = wMonthly3(usgs,'sum'); %m3/day -> m3/month
            area=shape(j).SQMI*(1609.344^2);    
            v=ts.v/area*1000*60*60*24; %mm/month
            [C,indS,indQ]=intersect(S.BasinStr_t,ts.t);
            S.BasinStr(j).usgsQ(indS)=v(indQ);
        catch
            %disp(['empty site: ',usgsNo]);
            emptygage=[emptygage;usgsNo];
        end
    end
    BasinStr=S.BasinStr;
    BasinStr_t=S.BasinStr_t;
    pause(10)
    fclose all
    save(strmatfile,'BasinStr','BasinStr_t','-v7.3')
    T=cell2table(emptygage);
    writetable(T,[USGSsavedir,'\emptygage']);    
    clear all
    toc
end

% use Chaopeng's usgs dataset
load('Y:\ggII\MasterList\ggIIstr_USGScorr.mat')
load('E:\Chaopeng\AMHG\usgs.mat')
for i=1:length(usgs)
    usgs(i).id=str2num(usgs(i).name); 
    usgs(i).v=usgs(i).v*0.3048^3;
end

usgsid=[usgs.id];
for i=1:length(ggIIstr)
    area=ggIIstr(i).Area_sqm;
    ID=ggIIstr(i).ID;
    ind=find(usgsid==ID);
    sd=ggIIstr_t(1);
    ed=ggIIstr_t(end);
    ts.t=usgs(ind).t;
    ts.v=usgs(ind).v;
    ts = truncateTS(ts,[sd,ed]);
    ts = wMonthly3(ts,'sum'); %m3/sec -> m3/month
    v=ts.v*60*60*24/area*1000; %mm/month
    ggIIstr(i).usgsQ1=ggIIstr(i).usgsQ;
    ggIIstr(i).usgsQ=v';
end
save Y:\ggII\MasterList\ggIIstr_USGScorr.mat ggIIstr ggIIstr_t


% build up a refTable
refTable=readtable('Y:\ggII\MasterList\MasterList.xlsx');
refTable.ID=zeros(length(refTable.SITE_NO),1);
for i=1:length(refTable.SITE_NO)
    refTable.ID(i)=str2num(refTable.SITE_NO{i});
end
refTable.DArea_sqm=refTable.SQMI*(1609.34^2);
save Y:\ggII\MasterList\refTable.mat refTable

%% sum those data to USGScorr table

% get common ID
load('Y:\ggII\MasterList\refTable.mat')
load('E:\Kuai\SSRS\data\usgsCorr_5364.mat')
IDall=refTable.ID;
[C,ind,indall]=intersect(ID,IDall,'stable');
usgsCorr=usgsCorr(ind,:);
ID=ID(ind);
save('E:\Kuai\SSRS\data\usgsCorr_4949.mat','usgsCorr','ID');

 
% % load('Y:\Kuai\USGSCorr\S_I.mat')
% % for i=1:length(S_I)
% %     S_I(i).ID=str2num(S_I(i).STAID);
% % end
% % save Y:\Kuai\USGSCorr\S_I.mat S_I
% 
% 
% IDall=refTable.ID;
% %ID=[S_I.ID]';
% [C,ind,indall]=intersect(ID,IDall,'stable');
% % S_I=S_I(ind);
% % save Y:\Kuai\USGSCorr\S_I2.mat S_I


for k=1:18
    ggIIdir='Y:\ggII';
    ns=sprintf('%02d',k);    
    strmatfile=[ggIIdir,'\basins',ns,'\basins',ns,'_str2.mat'];
    cmdstr=['basinstr_',ns,'=load(''',strmatfile,''')'];
    eval(cmdstr);
end

load 'E:\Kuai\SSRS\data\usgsCorr_4949.mat'
load Y:\ggII\MasterList\refTable.mat
fields=fieldnames(basinstr_01.BasinStr);
ggIIstr=struct(basinstr_01.BasinStr(1));
for i=1:length(ID)
    i
    id=ID(i);
    ind=find(refTable.ID==id);
    ns=refTable.REG(ind);
    cmdstr=['BasinStr=basinstr_',ns{1},'.BasinStr;'];
    eval(cmdstr)
    ind2=find([BasinStr.ID]==id);
    ggIIstr(i)=BasinStr(ind2);
end

for i=1:length(ID)
    id=ID(i);
    ind=find(refTable.ID==id);
    ns=refTable.REG(ind);
    ggIIstr(i).Reg=ns;
    ggIIstr(i).Area_sqm=refTable.DArea_sqm(ind);
end

save E:\Kuai\SSRS\data\ggIIstr_4949 ggIIstr ggIIstr_t

%% use HUC4 GRACE related dataset for budyko regress
load Y:\Kuai\USGSCorr\S_I.mat
idall=[S_I.id];
hucall=[HUCstr.ID];
fields={'Amp_fft','Amp0','Amp1','acf_dtr48','pcf_dtr48',...
    'acf_dtr72','pcf_dtr72','HurstExp','GRACE','GRACEt'};
for i=1:length(ggIIstr)
    id=ggIIstr(i).ID;
    ind=find(idall==id);
    hucid=S_I(ind).huc;
    indhuc=find(hucall==hucid);
    for j=1:length(fields)
        ff=fields{j};
        ggIIstr(i).(ff)=HUCstr(indhuc).(ff);
    end
end
save Y:\ggII\MasterList\ggIIstr_BDreg.mat ggIIstr ggIIstr_t

%% Regenerate shapefile for those 4627 usgs gages
load('Y:\ggII\MasterList\refTable.mat')
load('Y:\ggII\MasterList\ggIIstr_USGScorr.mat')
for k=1:18
    ns=sprintf('%02d',k);
    shapefile=['Y:\ggII\basins_project\basins',ns,'.shp'];
    shape=shaperead(shapefile);
    siteno=cellfun(@str2num,{shape.SITE_NO}');
    cmdstr=['shape',ns,'=shape;'];
    eval(cmdstr);    
    cmdstr=['siteno',ns,'=siteno;'];
    eval(cmdstr);
end

shape=shape01(1);
for i=1:length(ggIIstr)
    i
    id=ggIIstr(i).ID;
    ns=refTable.REG(find(refTable.ID==id));
    ns=ns{1};
    cmdstr=['ind=find(siteno',ns,'==id);'];  %ind=find(siteno01==id)
    eval(cmdstr)
    cmdstr=['shape(i)=shape',ns,'(ind);'];  %shape(i)=shape01(ind)
    eval(cmdstr)
end
shape=shape';
shapewrite(shape,'Y:\ggII\MasterList\ggIIstr_shape.shp')

%% test HUCstr
% load('E:\work\DataAnaly\mask\mask_huc4_nldas_32.mat')
% maskNLDAS=mask;
% load('E:\work\DataAnaly\mask\mask_HUC4_NDVI_2.mat')
% maskNDVI=mask;
% load('E:\work\DataAnaly\mask\mask_huc4_grace_global_32.mat')
% maskGRACE=mask;
% HUCstr=initialHUCstr( 'E:\work\DataAnaly\HUC\HUC4_main_data.shp','HUC4' );
% load('Y:\DataAnaly\HUCstr_HUC4_32.mat','HUCstr_t')
%
% HUCstr=NAdata2Str_monthly( maskNLDAS,maskGRACE,maskNDVI,'E:\work\DataAnaly\HUCstr_test.mat',HUCstr,HUCstr_t);
% save 'E:\work\DataAnaly\HUCstr_new.mat' HUCstr HUCstr_t
%
% D1=load('E:\work\DataAnaly\HUCstr_HUC4_32.mat');
% D2=load('E:\work\DataAnaly\HUCstr_test.mat');
%
% %Old hucstr
% fields1={'ARAIN_NOAH','ASNOW_NOAH','rET3','Amp_fft','Amp0','Amp1','acf_dtr48','pcf_dtr48',...
%     'acf_dtr72','pcf_dtr72','HurstExp','NDVI_avg','SimIndex','GRACE'};
% fields2={'Rain','Snow','rET3','Amp_fft','Amp0','Amp1','acf_dtr48','pcf_dtr48',...
%     'acf_dtr72','pcf_dtr72','HurstExp','NDVI','SimInd','GRACE'};
% for i=1:length(fields1)
%     figure
%     f1=fields1{i};
%     f2=fields2{i};
%     d1=[D1.HUCstr.(f1)];
%     d2=[D3.HUCstr.(f2)];
%     [nt,nbasin]=size(d1);
%     d1=reshape(d1,nt*nbasin,1);
%     d2=reshape(d2,nt*nbasin,1);
%     plot(d1,d2,'*');hold on
%     plot121Line;hold off
%     title(f1)
% end
%
% % find that amplitude are different. Probably different time range. try
% % again
% BasinStr=D2.HUCstr;
% sd=20031001;
% ed=20101001;
% % Amplitude
% BasinStr =amp2HUC( BasinStr,sd,ed,0,1001 );
% BasinStr =amp2HUC( BasinStr,sd,ed,1,1001 );
% BasinStr  = amp2HUC_fft( BasinStr,sd,ed);
% % Acf and Pcf
% BasinStr  = acf2HUC_detrend( BasinStr,sd,ed);
% D3=D2;
% D3.HUCstr=BasinStr;
%
%
%
%
