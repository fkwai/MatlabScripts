% save GLDAS soilM and SMAP into csv database

load('Y:\GLDAS\maskGLDAS_025.mat')

sd=20150331;
ed=20160901;
tt=datenumMulti(sd,1):datenumMulti(ed,1);

for i=1:length(tt)
    i
    tic
    t=tt(i);
    [dataGLDAS,latGLDAS,lonGLDAS,tnumGLDAS] = readGLDAS_NOAH( t,18 );
    grid2csv_time( dataGLDAS,latGLDAS,lonGLDAS,tnumGLDAS,mask,'D:\Kuai\rnnSMAP\tDB_soilM\' )
    
    [dataGLDAS,latGLDAS,lonGLDAS,tnumGLDAS] = readGLDAS_NOAH( t,8 );
    grid2csv_time( dataGLDAS,latGLDAS,lonGLDAS,tnumGLDAS,mask,'D:\Kuai\rnnSMAP\tDB_EVAP\' )
    
    [dataSMAP,latSMAP,lonSMAP,tnumSMAP] = readSMAP_L2(t);
    if ~isempty(dataSMAP)
        dataSMAP_q=zeros(length(latGLDAS),length(lonGLDAS),length(tnumGLDAS))*nan;
        tnumSMAP_q=zeros(length(tnumSMAP));
        for j=1:length(tnumSMAP)
            gridtemp=interp_grid(lonSMAP,latSMAP,dataSMAP(:,:,j),lonGLDAS,latGLDAS)*100;
            [temp2,iGLDAS]=min(abs(tnumSMAP(j)-tnumGLDAS));
            C=cat(3,gridtemp,dataSMAP_q(:,:,iGLDAS));
            dataSMAP_q(:,:,iGLDAS)=nanmean(C,3);
        end
        grid2csv_time( dataSMAP_q,latGLDAS,lonGLDAS,tnumGLDAS,mask,'D:\Kuai\rnnSMAP\tDB_SMPq\' )
    end
    toc
end