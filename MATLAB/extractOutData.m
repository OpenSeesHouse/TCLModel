numRecs = size(recList,2);

iOut = 0;
for stNum = stNums
    outData.stNum = stNum;
    for ecc = eccFacs
        outData.ecc = ecc;
        for useBaseModel = baseModeStats
            if strcmp(ecc, "5%") && ~useBaseModel
                continue
            end
            baseStr = "";
            if ~useBaseModel
                baseStr = "-noBase";
            end
            outData.useBaseModel = useBaseModel;
            for fc = fcs
                outData.fc = fc;
                for fac = facList
                    if fac == 1
                        facStr = sprintf("%d", fac);
                    else
                        facStr = sprintf("%.1f", fac);
                    end
                    outData.fac = fac;
                    outData.facStr = facStr;
                    iResp = 0;
                    for respName = respNames
                        outData.respName = respName;
                        iResp = iResp + 1;
                        outData.iResp = iResp;
                        iOut = iOut + 1;
                        outFilePath = sprintf("../NTHPlots/%dStory/%sEcc/fc=%s/useBase-%d/%s-DBE", stNum, ecc, fc, useBaseModel, facStr);
                        outFileName = sprintf("%s/%s.txt", outFilePath, respName);
                        outData.outFilePath = outFilePath;
                        outData.outFileName = outFileName;
                        outDataMat(iOut) = outData;
                    end
                end
            end
        end
    end
end
save("dataStruc.out", 'outDataMat');