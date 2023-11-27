function works = createPushJobs
worksFile = "";
% worksFile = "tmpRuns/allPushRuns.mat";
if strcmp(worksFile, "")
    eccFacs = ["5%", "10%", "20%"];
%     eccFacs = ["5%"];
    fcs = ["21", "33", "45"];
    fyStrs = ["Fy=400", "Fy=500", "Fy=600", "Fyb=400-Fyc=500", "Fyb=400-Fyc=600"];
    stNums = [4,8,12];
%     stNums = [4];
    isDsgndFlags = [1 0];
    numJobs = size(stNums,2)*size(eccFacs,2)*size(fcs,2)*size(fyStrs,2)*size(isDsgndFlags,2);
    works(1:numJobs,8) = "X";
    iJob = 0;
    for isDsgnd = isDsgndFlags
        for stNum = stNums
            for ecc = eccFacs
                if strcmp(ecc, "5%") && ~isDsgnd
                    continue
                end
                for fc = fcs
                    for fyStr = fyStrs
                        basePath = sprintf("../Designs/%dStory/%sEcc/fc=%s/%s", stNum, eccFacs(1), fc, fyStr);
                        path = sprintf("../Designs/%dStory/%sEcc/fc=%s/%s", stNum, ecc, fc, fyStr);
                        if ~exist(path, 'dir')
                            fprintf('skipping inputs(resFolder): %s\n', path);
                            continue;
                        end
						iJob = iJob + 1;	
						works(iJob,1) = stNum;
						works(iJob,2) = ecc;
						works(iJob,3) = fc;
						works(iJob,4) = fyStr;
						works(iJob,5) = basePath;
						works(iJob,6) = iJob;
						works(iJob,7) = isDsgnd;
                    end
                end
            end
        end
    end
    works(iJob+1:numJobs,:) = [];
    if ~exist('tmpRuns', 'dir')
        mkdir('tmpRuns')
    end
    save('tmpRuns/allPushRuns.mat', 'works');
else
    data = load(worksFile);
    works = data.works;
end
