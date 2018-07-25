function fixFigure(varargin)
% (E) fix the legend, title, xlabel, ylabel and axis fonts, set them to-
% publication size, then print an eps for further editing in other software
% This is the last function I used before using adobe Illustrator for-
% further editing. The output is named file.eps
hh = gcf;
C = findobj(hh,'Type','Axes','-not','Tag','legend');

s = 16;
axisFont = s;
legFont = s;
titleFont = s;
xlabFont = s;
ylabFont = s;
for i=1:length(C)
    h = C(i);
    
    set(h,'FontSize',axisFont);
    %set(h,'LineWidth',3);
    set(h,'Layer','top')
    %set(h,'ticklength',[0.025 0.025])
    
    hh = get(h,'Title');
    set(hh,'FontSize',titleFont);
%     l = legend(h);
    l = findobj(gcf, 'Type', 'Legend');
    %legend('boxoff')
    if ~isempty(l)
        set(l,'FontSize',legFont);
    end
    xl = get(h,'XLabel'); set(xl,'FontSize',xlabFont);
    xl = get(h,'YLabel'); set(xl,'FontSize',ylabFont);
    set(h,'ticklength',[0.015 0.025])
    set(h,'LineWidth',2)
end
%export_fig file.eps %maybe useful for raster map??  
% just fixing the 
mustInclude = [];
if length(varargin)>2 && ~isempty(varargin{3})
    % must-include item on the color bar
    mustInclude = varargin{3};
end
hc = findobj(gcf,'tag','Colorbar');
if ~isempty(hc) && length(varargin)>0 && ~isempty(varargin{1})
    range = varargin{1};
    for k=1:length(hc)
        YTick=get(hc(k),'YTick');
        set(hc(k),'YLim',[0.1 1])
        YTick = [0 0.2 0.4 0.6 0.8 1];
            set(hc(k),'YTick',YTick);
        p = YTick*(range(2)-range(1))+range(1);
        
        if ~isempty(mustInclude)
            mustIncludePos = (mustInclude-range(1))/(range(2)-range(1));
            kk = find(abs(mustIncludePos - YTick) == min(abs(mustIncludePos - YTick)));
            if abs(mustIncludePos - YTick(kk))<0.08 % eat it
                YTick(kk)=mustIncludePos; p(kk)=mustInclude;
            else
                kk2 = find(YTick>mustIncludePos,1,'first');
                YTick = [YTick(1:kk2-1),mustIncludePos,YTick(kk2:end)];
                p = [p(1:kk2-1),mustInclude,p(kk2:end)];
            end
        end
        %for i=1:length(p), labels{i}=num2str(p(i),4); end
        for i=1:length(p), labels{i}=sprintf('%0.1f',p(i)); end
        set(hc(k),'YTick',YTick)
        set(hc(k),'YTickLabel',labels)
    end
end
set(gcf, 'PaperPositionMode', 'auto');
if length(varargin)>1
    ff = varargin{2};
else
    ff = 'figure.eps';
end
%export_fig(ff,'-transparent');
%{
print('-depsc2', 'file.eps','-painters')
fixPSlinestyle('file.eps', 'file.eps');
%}