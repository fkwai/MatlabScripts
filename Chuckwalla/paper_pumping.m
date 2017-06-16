% Influence of pumping. Time trajectory of different scenarios

dMat=[
    0	0	0	0	0
    0	0	0	0	0
    0	0	0	0	0
    0	0	0	0	0
    0	0	0	0	0
    1	1	1	1	1
    0	0	1	1	0
    1	1	1	1	1
    1	1	1	1	1
    1	1	0	1	0
    0	0	0	0	0
    ];
doFt=1;
figFolder='E:\Kuai\chuckwalla\paper\';
outDir='E:\Kuai\chuckwalla\GMS\chuckwalla\output\';
wellNameLst={'Desert Sunlight','Desert Harvest','Eagle Moutain','Palen','Genesis'};
if doFt==0
    wellRange=[-20,0;-20,0;-18,0;-15,0;-15,0;];
else
    wellRange=[-60,0;-60,0;-60,0;-50,0;-50,0;];
end
nP=length(wellNameLst);
caseLst={'f3','f4','f5','f6','f7'};
syLst={'sy05_ss5e6.csv';'sy15_ss5e6.csv';'sy20_ss5e6.csv'};
syVec=[0.05,0.15,0.2];

%% redefine dMat
% load('E:\Kuai\chuckwalla\GMS\chuckwalla\output\statMat.mat')
% dMat=zeros(size(rmseTab));
% dMat(rmseTab<3 & stdTab1<4)=1;


%% read data
out=[];
for iRch=1:11
    outFolder=[outDir,'simNewMount',num2str(iRch),'\'];
    temp=csvread([outFolder,caseLst{1},'_',syLst{1}]);
    t=temp(:,1);
    
    mat=zeros(length(t),nP,length(syLst));
    for iCase=1:length(caseLst)
        for iSy=1:length(syLst)
            file=[outFolder,caseLst{iCase},'_',syLst{iSy}];
            temp=csvread(file);
            for iP=1:nP
                mat(:,iP,iSy)=temp(:,iP*2);
            end
        end
        mat(mat==-888)=nan;
        out(iRch,iCase).t=t;
        out(iRch,iCase).data=mat;
    end
end

%% plot
for iP=1:5
    figure('Position',[1,1,1000,800])
    for iSy=1:length(syLst)
        subplot(3,1,iSy)
        for iRch=1:11
            for iCase=1:length(caseLst)
                t=out(iRch,iCase).t;
                h=out(iRch,iCase).data(1,iP,iSy);
                v=out(iRch,iCase).data(:,iP,iSy)-h;
                if dMat(iRch,iCase)~=1
                    if doFt==0
                        l1=plot(t/365,v,'color',[0.5,0.5,0.5],'LineWidth',2);hold on
                    else
                        l1=plot(t/365,v/0.3048,'color',[0.5,0.5,0.5],'LineWidth',2);hold on
                    end
                    %[iRch,iCase]
                end
            end
        end
        for iRch=1:7
            for iCase=1:length(caseLst)
                t=out(iRch,iCase).t;
                h=out(iRch,iCase).data(1,iP,iSy);
                v=out(iRch,iCase).data(:,iP,iSy)-h;
                if dMat(iRch,iCase)==1
                    if doFt==0
                        l2=plot(t/365,v,'r-','LineWidth',2);hold on
                    else
                        l2=plot(t/365,v/0.3048,'r-','LineWidth',2);hold on
                    end
                    %[iRch,iCase]
                end
            end
        end
        ylim(wellRange(iP,:))
        xlim([0 9200]/365)
        
        %% texts on plot
        if iSy==2
            if doFt==0
                ylabel('Negative drawdown (m)')
            else
                ylabel('Negative drawdown (ft)')
            end
        end
        if iSy==3
            xlabel('Years after pumping')
        end
        title(['Specfic Yield = ', num2str(syVec(iSy))]);
        
        if ismember(iP,[1,2,4,5]) && iSy==3
            legend([l2,l1],{'Accepted','Rejected'},'Location','southwest');
        elseif ismember(iP,[3]) && iSy==3
            legend([l2,l1],{'Accepted','Rejected'},'Location','southeast');
        end

    end
    t=suptitle(['Drawdown at ',wellNameLst{iP}]);
    set(t,'FontSize',20)
    
    suffix = '.eps';
    if doFt==0
        fname=[figFolder,'Fig_pumping',num2str(iP)];
    else
        fname=[figFolder,'Fig_pumping',num2str(iP),'_ft'];
    end
    fixFigure([],[fname,suffix]);
    saveas(gcf, fname);
end
