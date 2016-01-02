function [ outlier ] = findOutlier( T, D )
%this function will find out outliers based on distance to cluster center

outlier=[];
for j=1:nclass
    tempD=D(T==j,j);
    tempind=find(T==j);
    p1=prctile(tempD,25);
    p2=prctile(tempD,75);
    r1=p1-(p2-p1)*0.5;
    r2=p2+(p2-p1)*0.5;
    out= tempD<r1|tempD>r2;
    outlier=[outlier;tempind(out)];
end


end

