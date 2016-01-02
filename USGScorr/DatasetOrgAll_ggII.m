% load('usgsCorr','IDI')
% load('gagesII.mat')

idNew=IDI';
id=ggII.BasinID.STAID;
[C,indNew,ind]=intersect(idNew,id);

L1Var=fieldnames(ggII);

% some number should be treat as string. Like STAID.
lable={'STAID','HUC4','HUC12'};

dataset=[];
for i=1:length(L1Var)
    str1=L1Var{i};
    L2Var=fieldnames(ggII.(str1));
    for j=1:length(L2Var)
        str2=L2Var{j};
        temp=ggII.(str1).(str2);
        if isnumeric(temp)
            if any(strcmp(lable,str2))
                data=codeIndividual(temp,['Variable: ',str1,'.',str2],0);
            else
                data=temp;
            end
        elseif iscell(temp)
            if iscellstr(temp)
                data=codeIndividual(temp,['Variable: ',str1,'.',str2],0);
            else
                if any(strcmp(lable,str2))
                    data=codeIndividual(temp,['Variable: ',str1,'.',str2],0);
                else
                    temp(cellfun(@ischar,temp))={NaN};
                    data=cell2mat(temp);
                end
                
            end
        else
            warning(['look at ',str1,' ',str2])
        end
        dataset=[dataset,data];
    end
end
dataset=dataset(ind,:);
save dataset_ggII_All dataset
