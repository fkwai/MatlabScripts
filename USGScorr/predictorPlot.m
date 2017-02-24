function predictorPlot( T,pT,XXn,varargin )
% plot predictor

% T: target lable of behavior. 1 - negative, 2 - positive
% pT: predict lable of behavior. 1 - negative, 2 - positive
% XXn: predictors
% varargin: selected predictor index

[nind,npred]=size(XXn);

if length(varargin)>0
    if ~isempty(varargin{1})
        indpred=varargin{1};
    else
        indpred=[1:npred];
    end
end

if length(varargin)>1
    subf=varargin{2};
else
    subf=0;
end

if length(varargin)>2
    column=varargin{3};
else
    column=0;
end

Quad=zeros(length(T),1);

Quad(pT==2&T==1)=1;
Quad(pT==1&T==1)=2;
Quad(pT==1&T==2)=3;
Quad(pT==2&T==2)=4;


x=[0.5,indpred+0.5];x=[x',x'];
%x=[indpred];x=[x',x'];
x1=indpred+0.15;
x2=indpred-0.15;
mid=floor(length(indpred)/2);

if subf==1
    figure
    subplot(2,1,1)
else
    figure
end
p=[];str={};
if ~isempty(find(Quad==2))
    p2=plot(x1(1:mid),XXn(Quad==2,indpred(1:mid))','go');hold on
    p=[p,p2(1)];str=[str,'pred F obs F'];
end
if ~isempty(find(Quad==4))
    p4=plot(x1(1:mid),XXn(Quad==4,indpred(1:mid))','r.');hold on    
    p=[p,p4(1)];str=[str,'pred T obs T'];
end
if ~isempty(find(Quad==1))
    p1=plot(x2(1:mid),XXn(Quad==1,indpred(1:mid))','bo');hold on
    p=[p,p1(1)];str=[str,'pred T obs F'];
end
if ~isempty(find(Quad==3))
    p3=plot(x2(1:mid),XXn(Quad==3,indpred(1:mid))','k.');hold on
    p=[p,p3(1)];str=[str,'pred F obs T'];
end
if column==1
    x=[0.5,indpred(1:mid)+0.5];x=[x',x'];
    plot(x,[0,1],'k','LineWidth',1);hold on
end
legend(p,str)
%legend([p2(1),p4(1),p1(1),p3(1)],'pred F obs F','pred T obs T','pred T obs F','pred F obs T')
set(gcf,'position',get(0,'screensize'))
hold off

if subf==1
    subplot(2,1,2)
else
    figure
end
if ~isempty(find(Quad==2))
    p2=plot(x1(mid:end),XXn(Quad==2,indpred(mid:end))','go');hold on
    p=[p,p2(1)];str=[str,'pred F obs F'];
end
if ~isempty(find(Quad==4))
    p4=plot(x1(mid:end),XXn(Quad==4,indpred(mid:end))','r.');hold on
    p=[p,p4(1)];str=[str,'pred T obs T'];
end
if ~isempty(find(Quad==1))
    p1=plot(x2(mid:end),XXn(Quad==1,indpred(mid:end))','bo');hold on
    p=[p,p1(1)];str=[str,'pred T obs F'];
end
if ~isempty(find(Quad==3))
    p3=plot(x2(mid:end),XXn(Quad==3,indpred(mid:end))','k.');hold on
    p=[p,p3(1)];str=[str,'pred F obs T'];
end
if column==1
    x=[indpred(mid)-0.5,indpred(mid:end)+0.5];x=[x',x'];
    plot(x,[0,1],'k','LineWidth',1);hold on
end
%legend([p2(1),p4(1),p1(1),p3(1)],'pred F obs F','pred T obs T','pred T obs F','pred F obs T')
set(gcf,'position',get(0,'screensize'))
hold off

%
% figure
% %plot(x,[0,1],'g','LineWidth',15);hold on
% %plot(x,[0,1],'k','LineWidth',1);hold on
% p1=plot(x1,XXn(Quad==2,indpred)','b.');hold on
% p2=plot(x2,XXn(Quad==4,indpred)','r.');hold on
% legend([p1(1),p2(1)],'pred F obs F','pred T obs T')
% set(gcf,'position',get(0,'screensize'))
% hold off
%
% figure
% %plot(x,[0,1],'g','LineWidth',15);hold on
% %plot(x,[0,1],'k','LineWidth',1);hold on
% p1=plot(x1,XXn(Quad==1,indpred)','b.');hold on
% p2=plot(x2,XXn(Quad==3,indpred)','r.');hold on
% legend([p1(1),p2(1)],'pred T obs F','pred F obs T')
% set(gcf,'position',get(0,'screensize'))
% hold off

end

