function data= readRnnPred( outFolder,trainName,testName,iter)
% read prediction from testRnnSMAP.lua into a data.mat

% % example
% outFolder='Y:\Kuai\rnnSMAP\output\PA';
% trainName='PA';
% testName='PA';
% iter=2000;

testFolder=[outFolder,'\out_',trainName,'_',testName,'_',num2str(iter),'\'];
testFolderInfo=dir([testFolder,'*.csv']);
dataMatFile=[testFolder,'\data.mat'];

data=[];
ind=0;
if exist(dataMatFile,'file')
    dataMat=load(dataMatFile);
    data=dataMat.data;
else
    for i=1:length(testFolderInfo)
        % verify file order
        indtemp=str2num(testFolderInfo(i).name(1:end-4));
        if indtemp<ind
            error('file not in order');
        end
        ind=indtemp;
        M=csvread([testFolder,testFolderInfo(i).name]);
        data=[data,M];
    end
    save([testFolder,'data.mat'],'data');
end

end

