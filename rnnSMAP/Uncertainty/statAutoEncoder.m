function stat = statAutoEncoder(input,output)
% calculate stat of self autoencoder


[nt,ngrid,nx]=size(input);

if length(size(output))==3    
    outputBatch=[];
else
    outputBatch=output;
    output=nanmean(outputBatch,4);
end
    
%% 
diffAll=output-input;
rmse_mT=permute(mean(diffAll.^2).^0.5,[2,3,1]);
rmse_mX=mean(diffAll.^2,3).^0.5;
rmse=mean(rmse_mX)';
rho_mT=zeros(ngrid,nx).*nan;
for i=1:ngrid
    for j=1:nx
        a=input(:,i,j);
        b=output(:,i,j);
        ind=find(~isnan(a) & ~isnan(b));
        if ~isempty(ind)
            rho_mT(i,j)=corr(a(ind),b(ind));
        end
    end
end
rho=nanmean(rho_mT,2);

stat.diff=diffAll;
stat.rmse_mT=rmse_mT;
stat.rmse_mX=rmse_mX;
stat.rmse=rmse;
stat.rho_mT=rho_mT;
stat.rho=rho;

%% ensemble 
if ~isempty(outputBatch)
    stdAll=std(outputBatch,[],4);
    std_mX=mean(stdAll,3);
    std_mT=permute(mean(stdAll),[2,3,1]);
    std_m=mean(std_mX)';
    
    stat.stdAll=stdAll;
    stat.std_mX=std_mX;
    stat.std_mT=std_mT;
    stat.std=std_m;
end

end

