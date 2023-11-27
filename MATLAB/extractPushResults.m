for stNum = stNums
    for ecc = eccFacs
        for isDsgnd = isDsgndFlags
            if strcmp(ecc, "5%") && ~isDsgnd
                continue
            end
            baseStr = "Designed";
            if ~isDsgnd
                baseStr = "NotDsgnd";
            end
            for fc = fcs
                outFilePath = sprintf("../PushPlots/%dStory/%sEcc/fc=%s/%s/", stNum, ecc, fc, baseStr);
                
                if ~exist(outFilePath, 'dir')
                    mkdir(outFilePath);
                end
                outFileName = sprintf("%s/globalDriftX.out", outFilePath);
                
                resMat = zeros(10000,size(fyStrs,2)*2);
                iFy = 0;
                maxNRow = 0;
                for fyStr = fyStrs
                    iFy = iFy + 1;
                    inFilePath = sprintf("../Designs/%dStory/%sEcc/fc=%s/%s/push-%s", stNum, ecc, fc, fyStr, baseStr);
                    fileName = sprintf("%s/globalDriftX.out", inFilePath);
                    data = load(fileName);
                    nRows = size(data,1);
                    nCols = size(data,2);
                    for i=1:nRows
                        resMat(i, 2*iFy-1) = data(i,1);
                        resMat(i, 2*iFy) = max(data(i, 2:nCols), [], 'all');
                    end
                    maxNRow = max(nRows, maxNRow);
                end
                resMat(maxNRow:10000,:) = [];
                save(outFileName, 'resMat', '-ascii');
            end
        end
    end
end