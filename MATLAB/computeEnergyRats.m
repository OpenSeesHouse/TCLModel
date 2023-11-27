numRecs = size(recList,2);
for stNum = stNums
    for ecc = eccFacs
        for useBaseModel = baseModeStats
            if strcmp(ecc, "5%") && ~useBaseModel
                continue
            end
            baseStr = "";
            if ~useBaseModel
                baseStr = "-noBase";
            end
            for fc = fcs
                for fac = facList
                    if fac == 1
                        facStr = sprintf("%d", fac);
                    else
                        facStr = sprintf("%.1f", fac);
                    end
                    iFy = 0;
                    for fyStr = fyStrs
                        iFy = iFy + 1;
                        for iRec = recList
                            s(iRec) = 0;
                            for j = 1:stNum
                                iResp = 0;
                                for respName = energyResps
                                    iResp = iResp + 1;
                                    inFilePath = sprintf("../Designs/%dStory/%sEcc/fc=%s/%s/%s-DBE%s/%d/%s", stNum, ecc, fc, fyStr, facStr, baseStr, iRec, respName);
                                    fileName = sprintf("%s.out", strrep(energyRespPats(1,iResp), "j", num2str(j)));
                                    data = load(sprintf("%s/%s",inFilePath, fileName));
                                    hasTime = energyHasTimes(1,iResp);
                                    nRows = size(data,1);
                                    nCols = size(data,2);
                                    data = data(nRows,:);
                                    if hasTime
                                        k = 1;
                                        for i = 2:2:nCols
                                            data(1,k) = data(1,i);
                                            k = k+1;
                                        end
                                        data(:,k:nCols) = [];
                                    end
                                    s(iRec) = s(iRec) + sum(data, 'all');
                                end
                            end
                        end
                        for j = 1:stNum
                            for iRec = recList
                                iResp = 0;
                                for respName = energyResps
                                    iResp = iResp + 1;
                                    inFilePath = sprintf("../Designs/%dStory/%sEcc/fc=%s/%s/%s-DBE%s/%d/%s", stNum, ecc, fc, fyStr, facStr, baseStr, iRec, respName);
                                    fileName = sprintf("%s.out", strrep(energyRespPats(1,iResp), "j", num2str(j)));
                                    data = load(sprintf("%s/%s",inFilePath, fileName));
                                    hasTime = energyHasTimes(1,iResp);
                                    nRows = size(data,1);
                                    nCols = size(data,2);
                                    data = data(nRows,:);
                                    if hasTime
                                        k = 1;
                                        for i = 2:2:nCols
                                            data(1,k) = data(1,i);
                                            k = k+1;
                                        end
                                        data(:,k:nCols) = [];
                                    end
                                    data = sum(data, 'all')/s(iRec);
                                    outFilePath = sprintf("../Designs/%dStory/%sEcc/fc=%s/%s/%s-DBE%s/%d/%s-ratio", stNum, ecc, fc, fyStr, facStr, baseStr, iRec, respName);
                                    if ~exist(outFilePath, 'dir')
                                        mkdir(outFilePath);
                                    end
                                    fileName = sprintf("%s/%s.out",outFilePath, strrep(energyRespPats(1,iResp), "j", num2str(j)));
                                    save(fileName, 'data', '-ascii');
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
