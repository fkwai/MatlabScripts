L1Var=fieldnames(ggII);
for i=1:length(L1Var)
    str1=L1Var{i};
    L2Var=fieldnames(ggII.(str1));
    for j=1:length(L2Var)
        str2=L2Var{j};
        temp=ggII.(str1).(str2);
        if(length(temp)>9067)
            temp=temp(1:9067);
            ggII.(str1).(str2)=temp;
        end
    end
end


save gagesII.mat ggII