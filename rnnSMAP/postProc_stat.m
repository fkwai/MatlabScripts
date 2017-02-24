outfolder='Y:\Kuai\rnnSMAP\output\out_soilM\';
yfolder='Y:\Kuai\rnnSMAP\tDB_SMPq\';
ysfolder='Y:\Kuai\rnnSMAP\tDB_soilM\';

nt=4160;
iterLst=[200:200:1200];
nind=100;
nashMat=zeros(nind,length(iterLst)+1);

obsMat=zeros(nt,nind);
modelMat=zeros(nt,nind);
for ind=1:nind        
    gridInd=20000+ind;    
    %read obs
    y=zeros(4160,length(gridInd));
    for i=1:length(gridInd)
        yfile=[yfolder,'data\',sprintf('%06d',gridInd(i)),'.csv'];
        y(:,i)=csvread(yfile);
    end
    y(y==-9999)=nan;
    obsMat(:,ind)=y;
    
    % read soilM
    ys=zeros(4160,length(gridInd));
    for i=1:length(gridInd)
        yfile=[ysfolder,'data\',sprintf('%06d',gridInd(i)),'.csv'];
        ys(:,i)=csvread(yfile);
    end
    ys(ys==-9999)=nan;
    ys=ys/100;
    modelMat(:,ind)=ys;
end
nash=1-nansum((modelMat-obsMat).^2)./nansum((obsMat-repmat(nanmean(obsMat),[nt,1])).^2);
nashMat(:,1)=nash';

%% read sim
temp=csvread([yfolder,'stat.csv']);
lb=temp(1);ub=temp(2);

iterLst=[200:200:1200];
for k=1:length(iterLst)
    iter=iterLst(k);
    outfile=[outfolder,'iter',num2str(iter),'.csv'];
    yp=csvread(outfile);
    yp=(yp+1)*(ub-lb)/2+lb;
    nash=1-nansum((yp-obsMat).^2)./nansum((obsMat-repmat(nanmean(obsMat),[nt,1])).^2);
    nashMat(:,k+1)=nash';
end