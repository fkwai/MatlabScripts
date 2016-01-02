function ShpPlot_selectRec( T,pT,XXn )
% raw a rectangle and plot attributes inside that retangle

Data=figureLineData(gcf);
set(Data(5).handle,'Selected','on');
[dat,poly,in] = extractFromPolygon;
predictorPlot(T(in),pT(in),XXn(in,:),[],1,1);

end

