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
the=0.2;
nyq=length(yq);
nxq=length(xq);
vq=zeros(nyq,nxq)*nan;

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
                temp=v(iy,ix);
                vRatio=length(find(isnan(temp(:))))/length(temp(:));
                if vRatio<=the
                    switch oper
                        case 'mean'
                            vq(j,i)=nanmean(temp(:));
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