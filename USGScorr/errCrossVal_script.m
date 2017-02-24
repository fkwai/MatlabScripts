figure('Position',[1,1,1080,1000])
rankInd=zeros(100,6);
predList={};
for c=0:5
    CVmatfile=['py_predCV_mB_4949_c',num2str(c),'.mat'];
    subplot(3,2,c+1)
    [rankInd(:,c+1),predList{c+1}] = errCrossVal( CVmatfile );
    title(['cluster',num2str(c)])    
end
saveas(gcf,'D:\Kuai\SSRS\tree\solo\CrossVal.fig')
save D:\Kuai\SSRS\tree\solo\CrossVal_rank.mat rankInd predList


CVmatfile='py_predCV_mB_4949_nosoil.mat';
[rankInd,predList] = errCrossVal( CVmatfile );
saveas(gcf,'D:\Kuai\SSRS\tree\solo\CrossVal_nosoil.fig')

CVmatfile='py_predCV_mB_4949_nosoil2.mat';
[rankInd,predList] = errCrossVal( CVmatfile );
saveas(gcf,'D:\Kuai\SSRS\tree\solo\CrossVal_nosoil2.fig')


