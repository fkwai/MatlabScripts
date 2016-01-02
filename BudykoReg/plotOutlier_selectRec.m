function plotOutlier_selectRec(BasinStr,shape,shapeID)
% plot shape of outliers in budyko regress plot

Data=figureLineData(gcf);
set(Data(end).handle,'Selected','on');
[dat,poly,in] = extractFromPolygon;
ID=[BasinStr(in).ID];
[C,ind,ind2]=intersect(shapeID,ID);

figure
refmap='Y:\Maps\USA.shp';
refshape=shaperead(refmap);
for i=1:length(refshape)
    plot(refshape(i).X,refshape(i).Y,'-k');
    hold on
end

for i=1:length(ind)
    plot(shape(ind(i)).X,shape(ind(i)).Y,'-r');hold on
end
hold off
set(gcf,'position',get(0,'screensize'))
axis equal

end

