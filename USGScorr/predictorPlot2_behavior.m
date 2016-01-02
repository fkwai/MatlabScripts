function [Quad] = predictorPlot2_behavior( T,pT,XXn,varargin )
% plot 2 predictor

% T: target lable of behavior. 1 - negative, 2 - positive
% pT: predict lable of behavior. 1 - negative, 2 - positive
% XXn: predictors
% varargin 1: selected predictor index
% varargin 2: fields


[nind,npred]=size(XXn);

if length(varargin)>0
    if ~isempty(varargin{1})
        indpred=varargin{1};
    else
        indpred=randperm(npred,2);
    end
end

if length(varargin)>1
    if ~isempty(varargin{2})
        field=varargin{2};
    else
        field=[];
    end
end

Quad=zeros(length(T),1);

Quad(pT==2&T==1)=1;
Quad(pT==1&T==1)=2;
Quad(pT==1&T==2)=3;
Quad(pT==2&T==2)=4;

figure
p2=plot(XXn(Quad==2,indpred(1)),XXn(Quad==2,indpred(2)),'go');hold on    
p4=plot(XXn(Quad==4,indpred(1)),XXn(Quad==4,indpred(2))','b*');hold on
p1=plot(XXn(Quad==3,indpred(1)),XXn(Quad==3,indpred(2))','ro');hold on    
p3=plot(XXn(Quad==1,indpred(1)),XXn(Quad==1,indpred(2))','r*');hold on
legend([p2(1),p4(1),p1(1),p3(1)],'pred F obs F','pred T obs T','pred T obs F','pred F obs T')


if ~isempty(field)
    xlabel(field{indpred(1)});
    ylabel(field{indpred(2)});
end

hold off


end

