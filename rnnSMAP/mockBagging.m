% two levels of random selection:
% choose ns=6 from 18. do nr=20 times
% then, choose ns2=4 from ne=6. this is 15 jobs.

nt=18; nr = 25; ns=6; exclude=8; elem=1:nt;elem(elem==exclude)=[];
k=0;A=zeros([1,ns]); ns2=4;
while 1
    d = randsample(elem,ns); d= sort(d,'ascend');
    if ~any(ismember(d,A,'rows'))
        k = k + 1;
        A(k,:) = d;
        if k==nr, break; end
    end
end
%save exp A
AA = []; AU=[]; AC={};
for i=1:size(A,1)
    aa = combnk(A(i,:),ns2);
    AA = [AA; aa];
    AC{i}=aa;
end
AU = unique(AA,'rows');

% add consecutive jobs.
% for i=1: nt-length(exclude) - (ns-1)
%     d = elem(i:i+ns-1);
%     if ~any(ismember(d,A,'rows'))
%         k = k + 1;
%         A(k,:) = d;
%         if k==nr, break; end
%     end
% end