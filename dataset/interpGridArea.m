function vq=interpGridArea(x,y,v,xq,yq,varargin)
%integrate grid1 data to grid based on area
% grid contains: lat, lon, data, t

%% example:
% t=20160105;
% [dataSMAP,latSMAP,lonSMAP,tnumSMAP] = readSMAP_L2(t);
% [dataGLDAS,latGLDAS,lonGLDAS,tnumGLDAS] = readGLDAS_NOAH( t,18 );
% x=lonSMAP;
% y=latSMAP;
% xq=lonGLDAS;
% yq=lonGLDAS;
% v=dataSMAP(:,:,1);

%%
if ~isempty(varargin)
    oper=varargin{1};
else
    oper='mean';
end
yq=VectorDim(yq,1);
y=VectorDim(y,1);
xq=VectorDim(xq,2);
x=VectorDim(x,2);

the=0.2;
nyq=length(yq);
nxq=length(xq);
nt=size(v,3);
vq=zeros(nyq,nxq,nt)*nan;

% m,n - new data; x,y - target grid
[x1,x2,y1,y2]=gridbound(yq,xq);
[m1,m2,n1,n2]=gridbound(y,x);
nDigit=-12;
xSize=unique(roundn(x(2:end)-x(1:end-1),nDigit));
ySize=unique(roundn(y(2:end)-y(1:end-1),nDigit));

%% not evenly-distributed grid
if length(xSize)~=1 || length(ySize)~=1
    disp('not evenly-distributed grid')
    parfor j=1:nyq
        for i=1:nxq
            xx1=x1(i);xx2=x2(i);
            yy1=y1(j);yy2=y2(j);
            %A=(xx2-xx1)*(yy1-yy2);
            ix=find((m2>xx1)&(m1<xx2));
            iy=find((n2<yy1)&(n1>yy2));
            if ~isempty(ix) && ~isempty(iy)
                temp=v(iy,ix);
                if mean(isnan(temp(:)))~=1
                    a=zeros(length(iy),length(ix))*nan;
                    vtemp=zeros(length(iy),length(ix))*nan;
                    for ky=iy
                        for kx=ix
                            mm1=m1(kx);
                            mm2=m2(kx);
                            nn1=n1(ky);
                            nn2=n2(ky);
                            dx=min(mm2,xx2)-max(mm1,xx1);
                            dy=min(nn1,yy1)-max(nn2,yy2);
                            a(ky,kx)=dx*dy;
                            vtemp(ky,kx)=v(ky,kx);
                        end
                    end
                    a(isnan(vtemp))=nan;
                    mat=a.*vtemp;
                    vq(j,i)=nansum(mat(:))/nansum(a(:));
                end
            end
        end
    end
end

%% evenly-distributed grid
if length(xSize)==1 && length(ySize)==1
    disp('evenly-distributed grid')
    for j=1:nyq        
        for i=1:nxq
            xx1=x1(i);xx2=x2(i);
            yy1=y1(j);yy2=y2(j);
            ix=find((m2>xx1)&(m1<xx2));
            iy=find((n2<yy1)&(n1>yy2));
            if ~isempty(ix) && ~isempty(iy)
                tempMat=v(iy,ix,:);
                temp=v(iy,ix);
                vRatio=length(find(isnan(temp(:))))/length(temp(:));                
                if vRatio<=the
                    m1Lst=m1(ix);m1Lst(1)=max(xx1,m1(1));
                    m2Lst=m2(ix);m2Lst(end)=min(xx2,m2(end));
                    n1Lst=n1(iy);n1Lst(1)=min(yy1,n1(1));
                    n2Lst=n2(iy);n2Lst(end)=max(yy2,n2(end));
                    [m1Mesh,n1Mesh]=meshgrid(m1Lst,n1Lst);                    
                    [m2Mesh,n2Mesh]=meshgrid(m2Lst,n2Lst);
                    areaMat=(m2Mesh-m1Mesh).*(n1Mesh-n2Mesh);
                    nanMat=~isnan(temp);
                    areaMean=sum(sum(areaMat.*nanMat))/sum(sum(nanMat));
                    
%                     [m1Vec,n1Vec]=meshgrid(m1(ix),n1(iy));
%                     m1Vec=m1Vec(:);n1Vec=n1Vec(:);
%                     [m2Vec,n2Vec]=meshgrid(m2(ix),n2(iy));
%                     m2Vec=m2Vec(:);n2Vec=n2Vec(:);                    
%                     plot(m1Vec,n1Vec,'b*');hold on
%                     plot(m2Vec,n2Vec,'ro');hold on
%                     plot([xx1,xx1,xx2,xx2],[yy1,yy2,yy1,yy2],'kx');hold off
                    
                    switch oper
                        case 'mean'
                            tempArea=(tempMat.*repmat(areaMat,[1,1,nt]))./areaMean;
                            vq(j,i,:)=nanmean(nanmean(tempArea,1),2);
                        case 'max'
                            vq(j,i)=nanmax(temp(:));
                        case 'mode'
                            vq(j,i)=mode(temp(:));
                    end
                end
            end
        end
    end
end


end