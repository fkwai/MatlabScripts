t=20151013;
[dataSMAP,latSMAP,lonSMAP,tnumSMAP] = readSMAP_L2(t);
[dataGLDAS,latGLDAS,lonGLDAS,tnumGLDAS] = readGLDAS_NOAH( t,18 );

%% construct transfer matrix
% construct a sprase matrix that M(j,i) is the overlap area between jth
% GLDAS grid and ith SMAP grid

% corrXXX: [lat,lon,x1,x2,y1,y2]
[lonMeshGLDAS,latMeshGLDAS]=meshgrid(lonGLDAS,latGLDAS);
[x1GLDAS,x2GLDAS,y1GLDAS,y2GLDAS]=gridbound(latGLDAS,lonGLDAS);
[x1MeshGLDAS,y1MeshGLDAS]=meshgrid(x1GLDAS,y1GLDAS);
[x2MeshGLDAS,y2MeshGLDAS]=meshgrid(x2GLDAS,y2GLDAS);
corrGLDAS=[lonMeshGLDAS(:),x1MeshGLDAS(:),x2MeshGLDAS(:),...
    latMeshGLDAS(:),y1MeshGLDAS(:),y2MeshGLDAS(:)];
nxGLDAS=length(lonGLDAS);
nyGLDAS=length(latGLDAS);
nGLDAS=length(corrGLDAS);

[lonMeshSMAP,latMeshSMAP]=meshgrid(lonSMAP,latSMAP);
[x1SMAP,x2SMAP,y1SMAP,y2SMAP]=gridbound(latSMAP,lonSMAP);
[x1MeshSMAP,y1MeshSMAP]=meshgrid(x1SMAP,y1SMAP);
[x2MeshSMAP,y2MeshSMAP]=meshgrid(x2SMAP,y2SMAP);
corrSMAP=[lonMeshSMAP(:),x1MeshSMAP(:),x2MeshSMAP(:),...
    latMeshSMAP(:),y1MeshSMAP(:),y2MeshSMAP(:)];
nxSMAP=length(lonSMAP);
nySMAP=length(latSMAP);
nSMAP=length(corrSMAP);


A = spalloc(nSMAP,nGLDAS,nSMAP*9);
indC=cell(nSMAP,1);
areaC=cell(nSMAP,1);
parfor i=1:nSMAP;
    xx=corrSMAP(i,1);
    xx1=corrSMAP(i,2);
    xx2=corrSMAP(i,3);
    yy=corrSMAP(i,4);
    yy1=corrSMAP(i,5);
    yy2=corrSMAP(i,6);
    m=corrGLDAS(:,1);
    m1=corrGLDAS(:,2);
    m2=corrGLDAS(:,3);
    n=corrGLDAS(:,4);
    n1=corrGLDAS(:,5);
    n2=corrGLDAS(:,6);
    ind=find((m2>xx1)&(m1<xx2)&(n2<yy1)&(n1>yy2));
    
    a=zeros(length(ind),1)*nan;
    for kk=1:length(ind)
        k=ind(kk);
        mm1=m1(k);
        mm2=m2(k);
        nn1=n1(k);
        nn2=n2(k);
        dx=min(mm2,xx2)-max(mm1,xx1);
        dy=min(nn1,yy1)-max(nn2,yy2);
        a(kk)=dx*dy;
    end
    indC{i}=ind;
    areaC{i}=a;
    
    
    if rem(i,100)==0
        disp([num2str(i)])
    end
    
end

tic
for i=1:nSMAP
    ind=indC{i};
    a=areaC{i};
    A(i,ind)=a';
    if rem(i,1000)==0
        disp([num2str(i),':',num2str(toc)])
    end
end

save Y:\SMAP\AreaMat_SMAP_GLDAS.mat A

% % plot to test
% plot([xx1,xx1,xx2,xx2,xx1],[yy1,yy2,yy2,yy1,yy1],'b-');hold on
% plot(xx,yy,'b*');hold on
% for kk=1:length(ind)
%     k=ind(kk);
%     plot([m1(k),m1(k),m2(k),m2(k),m1(k)],...
%         [n1(k),n2(k),n2(k),n1(k),n1(k)],'r--');hold on
%     plot(m(k),n(k),'r*');hold on
%     text(m(k),n(k),num2str(a(kk)));hold on
% end
% hold off

%% SMAP to GLDAS grid
load('Y:\SMAP\AreaMat_SMAP_GLDAS.mat')
SMAP=load('Y:\SMAP\SMAP_L2.mat'); % 5 mins
GLDAS=load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\GLDAS_NOAH_SoilM.mat'); % 8 mins
SMAPmat=permute(reshape(SMAP.data,[length(SMAP.lon)*length(SMAP.lat),length(SMAP.tnum)]),[2,1]);
SMAPmatB=~isnan(SMAPmat);
Amat=SMAPmatB*A;
A_GLDAS=sum(A);
Aintep=Amat./repmat(A_GLDAS,[length(SMAP.tnum),1]);
SMAPmat_q=SMAPmat*A./Amat;
data=reshape(SMAPmat_q',[length(GLDAS.lat),length(GLDAS.lon),length(SMAP.tnum)]);
Aintep=reshape(Aintep',[length(GLDAS.lat),length(GLDAS.lon),length(SMAP.tnum)]);
lat=GLDAS.lat;
lon=GLDAS.lon;
tnum=SMAP.tnum;

save Y:\SMAP\SMAP_L2_q.mat data Aintp lat lon tnum -v7.3












