function [ ind1,ind2 ] = intersectCrd( crdLst1,crdLst2,varargin )
% find intersection of two crd list. Same as intersect in matlab but for
% crd array ([lat,lon])

% input:
% crd1,crd2 - coordinate array of [latLst,lonLst]. Order of crd1 will be
% kept.
% varargin{1} - accuracy. HAVEN'T DONE YET

% output:
% ind1,ind2 - index of intersection

% example:
%{
global kPath
rootDB=kPath.DBSMAP_L3;
dataName1='hucv2n2_0102';
dataName2='CONUSv2f1';
crdFile1=[rootDB,dataName1,kPath.s,'crd.csv'];
crdFile2=[rootDB,dataName2,kPath.s,'crd.csv'];
crdLst1=csvread(crdFile1);
crdLst2=csvread(crdFile2);
[ind1,ind2]=intersectCrd( crdLst1,crdLst2);
%}

x1=crdLst1(:,2);
y1=crdLst1(:,1);
x2=crdLst2(:,2);
y2=crdLst2(:,1);

ind1=[];
ind2=[];
for k=1:size(crdLst1,1)
    indY=find(y2==y1(k));
    indX=find(x2==x1(k));
    C=intersect(indY,indX);
    if ~isempty(C)
        ind1=[ind1;k];
        ind2=[ind2;C];
    end
end

if isempty(ind1)
    disp('No intersect of crd found! Check accuracy.')
end

end

