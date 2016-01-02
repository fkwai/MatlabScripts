function out=normalize(mat)
% normalize matrix, assumng mat = #individual * #attribute

[nr,nc]=size(mat);
ub=max(mat,[],1);
lb=min(mat,[],1);
ubmat=repmat(ub,[nr,1]);
lbmat=repmat(lb,[nr,1]);
out=(mat-lbmat)./(ubmat-lbmat);
out(isnan(out))=0;

%remove all zero column
kk=sum(out,1);
out(:,kk==0)=[];

end

