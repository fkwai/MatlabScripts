function HUCstr = grid2HUC_month( dataName,dataGrid,dataT,mask,HUCstr, strT)
%   fit data into a huc 
%   see Sample_grid2HUCall.m
%   care! dataT and strT is datenum

if(length(mask)~=length(HUCstr))
    error('mask and HUCstr do not fit')
end

n=length(HUCstr);

%intersect by month
dataTM=datenumMulti(dataT,3);
strTM=datenumMulti(strT,3);
[C,idata,istr]=intersect(dataTM,strTM);

%dataGrid(isnan(dataGrid))=0;

for i=1:n
    masktemp=mask{i};
    temp=zeros(length(strT),1)*nan;
    data=zeros(length(dataT),1)*nan;
    for j=1:length(dataT)
        ind=find(masktemp>0);
        g=dataGrid(:,:,j);g=g(ind);
        m=masktemp(ind);
        
        ind2=find(~isnan(g)); 
        g2=g(ind2);m2=m(ind2);
        
        area1=sum(m);
        area2=sum(m2);
        if area2>=area1*0.8 % if 80% are covered go ahead
            data(j)=sum(g2.*m2)/sum(m2);
        end
    end
    temp(istr)=data(idata);
    eval(['HUCstr(i).',dataName, '=temp;']);
end

end

