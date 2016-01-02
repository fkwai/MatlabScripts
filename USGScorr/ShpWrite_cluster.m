function ShpWrite_cluster( T,pT,S_I,shapename )
%WRITESHP_ERRMAP Summary of this function goes here
%   Detailed explanation goes here
% T: target lable of behavior. 1 - negative, 2 - positive
% pT: predict lable of behavior. 1 - negative, 2 - positive
% S_I: load(Y:\Kuai\USGSCorr\S_I.mat)

for i=1:length(S_I)
    S_I(i).T=T(i);
    S_I(i).pT=pT(i);
end
shapewrite(S_I,shapename);


end


