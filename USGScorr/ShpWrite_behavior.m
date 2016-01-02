function [ Quad ] = ShpWrite_behavior( T,pT,S_I,shapename )
%WRITESHP_ERRMAP Summary of this function goes here
%   Detailed explanation goes here
% T: target lable of behavior. 1 - negative, 2 - positive
% pT: predict lable of behavior. 1 - negative, 2 - positive
% S_I: load(Y:\Kuai\USGSCorr\S_I.mat)
% Quad: quadrant of error map. pT=2 while T=1 - quad = 1;

Quad=zeros(length(T),1);

Quad(pT==2&T==1)=1;
Quad(pT==1&T==1)=2;
Quad(pT==1&T==2)=3;
Quad(pT==2&T==2)=4;

for i=1:length(S_I)
    S_I(i).Quad=Quad(i);
end
shapewrite(S_I,shapename);


end

