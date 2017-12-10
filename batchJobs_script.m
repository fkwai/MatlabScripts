% Kuai: forward all hucv2nx model to their local / CONUSv2f1

cd /home/kxf227/work/GitHUB/rnnSMAP/
global kPath
varFileLst={'varLst_Noah','varLst_NoModel'};
for nHUC=[3]
    for temporalTest=[1]
        for varOpt=[1]
			jobHead=['hucv2n',num2str(nHUC)];
			varFile=varFileLst{varOpt};
			
			nGPU =1; nMultiple=4; epoch=300; hs=256;
			action = [2]; % empty if using default settings on each machine
			
			rt=['/mnt/sdb1/Kuai/rnnSMAP_inputs/',jobHead,'/'];
			
			res = struct('nGPU',nGPU,'nConc',nMultiple*nGPU,'rt',rt);
			if nHUC~=4
				prob = struct('jobHead',jobHead,'varFile',varFile,'epoch',epoch,'hs',hs,'temporalTest',temporalTest);
			else
				prob = struct('jobHead','huc2_','varFile',varFile,'epoch',epoch,'hs',hs,'temporalTest',temporalTest);
			end
			
			prob.rootOut=['/mnt/sdb1/Kuai/rnnSMAP_outputs/',jobHead,'/'];
			%prob.rootDB=['/mnt/sdb1/Kuai/rnnSMAP_inputs/',jobHead,'/'];
			prob.rootDB=[kPath.DBSMAP_L3];

			batchJobs_old(res,prob,action,0) % action contains 1: train; contains 2: test
		end
    end
end
