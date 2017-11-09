function writeHucComA(A,dat,saveFolderRt)
%parpool(8);
dat0=dat;
jobHead = ['hucv2n',num2str(size(A,2))];
global kPath

parfor i=1:size(A,1)
    i
    tic
    dat = dat0;
    dat.zoneSel = A(i,:); 
    ff=''; for j=dat.zoneSel,ff=[ff,sprintf('%02d',j)]; end
    subsetName = [jobHead,'_',ff];
    %saveFolder = ['CONUS',num2str(i)];
    indSub=subsetSMAP_shape(saveFolderRt,dat,subsetName );
    toc
    subsetSplit_All(subsetName);
    subsetPlot(subsetName);hold on
    if ~isfield(dat,'col')
        % col means it is a raster grid
        plot(dat.X,dat.Y,'-k'); end
    hold off
    axis equal
    saveas(gcf,[kPath.DBSMAP_L3,'Subset',kPath.s,'fig',kPath.s,subsetName,'.fig']);
    close(gcf)
end