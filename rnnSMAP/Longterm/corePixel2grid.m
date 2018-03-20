function [sitePixel,msg] = corePixel2grid( pID,varargin)
% read site and siteinfo and combine to surface and rootzone observation

% doVor - if use stations and weights given by voronoi file.
% optWeight - 1: use voronoi; 2: use refpix; 3: calculate; 0: find best (1>2>3)

global kPath
varinTab={'figFolder',[];'optWeight',0;'shiftPixel',[0,0]};
[figFolder,optWeight,shiftPixel]=internal.stats.parseArgs(varinTab(:,1),varinTab(:,2), varargin{:});

pIDstr=sprintf('%08d',pID);
siteIDstr=pIDstr(1:4);
siteID=str2num(pIDstr(1:4));
resStr=pIDstr(5:6);

dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];
dirSiteInfo=dir([dirCoreSite,'coresiteinfo',filesep,siteIDstr(1:2),'*']);
folderSiteInfo=[dirCoreSite,'coresiteinfo',filesep,dirSiteInfo.name,filesep];

msg=[];

%% read site
saveMatFile=[dirCoreSite,'siteMat',filesep,'site_',siteIDstr,'.mat'];
if exist(saveMatFile,'file')
    load(saveMatFile)
else
    site = readCoreSite(siteID);
end
layerLst=fieldnames(site);

%% read site info
crd = readCoreInfo_crd(siteID);
refpix = readCoreInfo_refpix(pID);
vor=readCoreInfo_voronoi(pID);

% fix refpix file
if ~isempty(refpix)
    idRefpix=refpix(1).id;
    for k=2:length(refpix)
        if ~isequal(idRefpix,refpix(1).id)
            msg=[msg,newline,'refpix different layers has different stations.'];
            [idRefPix,~,~]=intersect(idRefpix,refpix(1).id);
            % not finished
        end
    end
end

for k=1:length(refpix)
    if unique(refpix(k).staW)==1
        refpix(k).staW=[];
    elseif sum(refpix(k).staW)>=95&&sum(sum(refpix(k).staW))<=100
        refpix(k).staW=refpix(k).staW./100;
    end
end

%% report message
if optWeight==0
    if ~isempty(vor)
        optWeight=1;
    elseif ~isempty(refpix) && ~isempty(refpix(1).staW)
        optWeight=2;
    else
        optWeight=3;
    end
end

if optWeight==1
    if isempty(vor)
        msg=[msg,newline,'Failed! doVor=1 but no vor file.'];
        sitePixel=[];
        msg=['pixel ',pIDstr,msg];
        return
    else
        idRef=vor(end).id;
        if isempty(refpix)
            msg=[msg,newline,'used voronoi file but no refpix file'];
        elseif ~isequal(vor(end).id,refpix(1).id)
            msg=[msg,newline,'conflict between refpix and voronoi file'];
        end
    end
else
    idRef=refpix(1).id;
    idRef=unique(idRef);
end

[~,indCrdSta,~]=intersect(crd.id,idRef);
if length(indCrdSta)~=length(idRef)
    error('refpix contains crd that did not provide')
end
crdSite=[crd.lat(indCrdSta),crd.lon(indCrdSta)];

if size(unique(crdSite,'rows'),1)~=size(crdSite,1)
    if optWeight~=3
        msg=[msg,newline,'repeated crd! Check voronoi file'];
    else
        msg=[msg,newline,'Failed! Repeated crd and no voronoi file.'];
        sitePixel=[];
        msg=['pixel ',pIDstr,msg];
        return
    end
end


%% calculate voronoi
matfileGrid=dir([folderSiteInfo,siteIDstr,'*SMAP_M_grid_90km*.mat']);
mat=load([folderSiteInfo, matfileGrid(end).name]);
matGrid=mat.s;

y=matGrid.(['lat',resStr,'_nodes'])(:,1);
x=matGrid.(['lon',resStr,'_nodes'])(1,:);
yy=matGrid.(['lat',resStr,'_corners'])(:,1);
xx=matGrid.(['lon',resStr,'_corners'])(1,:);
b=matGrid.(['lat03_corners'])(:,1);
a=matGrid.(['lon03_corners'])(1,:);
[~,iX]=min(abs(mean(crdSite(:,2))-x));
[~,iY]=min(abs(mean(crdSite(:,1))-y));

% extend crd if need
while x(iX)<xx(1),xx=[xx(1)*2-xx(2),xx];end
while x(iX)>xx(end),xx=[xx,xx(end)*2-xx(end-1)];end
while y(iY)>yy(1),yy=[yy(1)*2-yy(2);yy];end
while y(iY)<yy(end),yy=[yy;yy(end)*2-yy(end-1)];end

x0=x(iX);y0=y(iY);
% x1 y1 left bottom corner
temp=find(xx<x0);x1=xx(temp(end));
temp=find(xx>x0);x2=xx(temp(1));
temp=find(yy<y0);y1=yy(temp(1));
temp=find(yy>y0);y2=yy(temp(end));

bb=[x1,y1;x2,y2];
if ~isequal(shiftPixel,[0,0])
    while x1<a(1),a=[a(1)*2-a(2),a];end
    while x2>a(end),a=[a,a(end)*2-a(end-1)];end
    while y2>b(1),b=[b(1)*2-b(2);b];end
    while y1<b(end),b=[b;b(end)*2-b(end-1)];end
    
    [~,temp]=min(abs(a-x0));    x0=a(temp+shiftPixel(1));
    [~,temp]=min(abs(a-x1));    x1=a(temp+shiftPixel(1));
    [~,temp]=min(abs(a-x2));    x2=a(temp+shiftPixel(1));
    [~,temp]=min(abs(b-y0));    y0=b(temp+shiftPixel(2));
    [~,temp]=min(abs(b-y1));    y1=b(temp+shiftPixel(2));
    [~,temp]=min(abs(b-y2));    y2=b(temp+shiftPixel(2));
    
    bb=[x1,y1;x2,y2];
    
end
wHorCal=voronoiRec(crdSite(:,2),crdSite(:,1),bb);

if ~isempty(figFolder)
    if ~exist(figFolder,'dir')
        mkdir(figFolder);
    end
    bbPolyX=[x1,x1,x2,x2,x1];
    bbPolyY=[y1,y2,y2,y1,y1];
    [xv,yv]=voronoi(crdSite(:,2),crdSite(:,1));
    f=figure;
    plot(x0,y0,'b*');hold on
    plot(crdSite(:,2),crdSite(:,1),'ro');hold on
    plot(xv,yv,'k-');hold on
    plot(bbPolyX,bbPolyY,'b-');hold off
    dx=x2-x1;
    dy=y2-y1;
    xlim([x1-dx/2,x2+dx/2])
    ylim([y1-dy/2,y2+dy/2])
    title(pIDstr)
    axis square
    saveas(f,[figFolder,pIDstr,'.jpg'])
    close(f)
    
    folderVor=[folderSiteInfo,'voronoi',filesep];
    dirVor=dir([folderVor,'voronoi_',pIDstr,'*.png']);
    if ~isempty(dirVor)
        copyfile([folderVor,dirVor(end).name],[figFolder,pIDstr,'_voronoi.png'])
    end
    
    dirSiteFigure=dir([folderSiteInfo,pIDstr,'*CLAY*.png']);
    copyfile([folderSiteInfo,dirSiteFigure(end).name],[figFolder,pIDstr,'_site.png'])
    
end

if optWeight==1
    wHor=vor(end).staW;
elseif optWeight==2
    wHor=refpix(1).staW;
elseif optWeight==3
    wHor=wHorCal;
end

if sum(wHor)<0.95&&sum(wHor)>1
    error('Check weight. Our of range.')
end

%% extract stations
nSta=size(idRef,2);
nLayer=length(layerLst);
sd=site.SM_05.t(1);
ed=site.SM_05.t(end);
depth=zeros(nLayer,1);
for k=1:nLayer
    layer=layerLst{k};
    C=strsplit(layer,'_');
    depth(k)=str2num(C{2})/100;
    sdt=site.(layerLst{k}).t(1);
    edt=site.(layerLst{k}).t(end);
    if sdt<sd,  sd=sdt; end
    if edt>ed,  ed=edt; end
end
tnum=[sd:ed]';
nt=length(tnum);
dataRaw=zeros(nt,nSta,nLayer)*nan;

% extract dataRaw
for k=1:nLayer
    temp=site.(layerLst{k});
    idStaStr=temp.stationID;
    t=temp.t;
    idSta=cellfun(@str2num,idStaStr);
    [~,indSta,indOut]=intersect(idSta,idRef(1,:));
    [~,~,indT]=intersect(t,tnum);
    data=temp.v(:,indSta);
    data(data<0|data>1)=nan;
    dataRaw(indT,indOut,k)=data;
end

%% sumarize data
wHorMat=repmat(VectorDim(wHor,2),[nt,1]);

% surface
dataRawSurf=dataRaw(:,:,1);
validMat=~isnan(dataRawSurf);
rSurf=sum(validMat.*wHorMat,2);
vSurf=nansum(dataRawSurf.*wHorMat,2)./sum(validMat.*wHorMat,2);
indValid=find(rSurf~=0);
ind=indValid(1):indValid(end);
tSurf=tnum(ind);
vSurf=vSurf(ind);
rSurf=rSurf(ind);

% rootzone
if length(depth)>1
    wVer=d2w_rootzone(depth);
    wVerMat=repmat(permute(wVer,[2,3,1]),[nt,nSta,1]);
    dataRawRoot=sum(dataRaw.*wVerMat,3);
    validMat=~isnan(dataRawRoot);
    rRoot=sum(validMat.*wHorMat,2);
    vRoot=nansum(dataRawRoot.*wHorMat,2)./sum(validMat.*wHorMat,2);
    indValid=find(rRoot~=0);
    ind=indValid(1):indValid(end);
    tRoot=tnum(ind);
    vRoot=vRoot(ind);
    rRoot=rRoot(ind);
else
    tRoot=[];
    vRoot=[];
    rRoot=[];
    wVer=[];
end


sitePixel=struct('ID',pID,'IDstr',pIDstr,'depth',depth,'crdC',[y0,x0],'BoundingBox',bb,...
    'vSurf',vSurf,'vRoot',vRoot,'rSurf',rSurf,'rRoot',rRoot,'tSurf',tSurf,'tRoot',tRoot,...
    'wVer',wVer,'wHor',wHor,'wHorCal',wHorCal,'dataRaw',dataRaw,...
    'crd',crd,'refpix',refpix,'vor',vor,'optWeight',optWeight);

if ~isempty(msg)
    msg=['pixel ',pIDstr,msg];
end

end