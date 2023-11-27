numRecs = size(recList,2);

for iOut = 1:numOut
    outData = outDataMat(iOut);
    stNum = outData.stNum;
    ecc = outData.ecc;
    useBaseModel = outData.useBaseModel;
    if strcmp(ecc, "5%") && ~useBaseModel
        continue
    end
    baseStr = "";
    if ~useBaseModel
        baseStr = "-noBase";
    end
    fc = outData.fc;
    facStr = outData.facStr;
    fac = outData.fac;
    respName = outData.respName;
    iResp = outData.iResp;
    outFilePath = outData.outFilePath;
    if ~exist(outFilePath, 'dir')
        mkdir(outFilePath);
    end
    outFileName = outData.outFileName;
    
    resMat = zeros(stNum,size(fyStrs,2)+1);
    resMat(1:stNum,1) = transpose(1:stNum);
    for j = 1:stNum
        W = Ws(1,j);
        C = Cs(1,j);
        iFy = 0;
        for fyStr = fyStrs
            iFy = iFy + 1;
            s = 0;
            for iRec = recList
                inFilePath = sprintf("../Designs/%dStory/%sEcc/fc=%s/%s/%s-DBE%s/%d/%s", stNum, ecc, fc, fyStr, facStr, baseStr, iRec, respName);
                fileName = sprintf("%s.out", strrep(respPats(1,iResp), "j", num2str(j)));
                data = load(sprintf("%s/%s",inFilePath, fileName));
                hasTime = hasTimes(1,iResp);
                nRows = size(data,1);
                nCols = size(data,2);
                data = data(nRows,:);
                if strcmp(respName, "storyShears")
                    data = data/W/C;
                end
                if hasTime
                    k = 1;
                    for i = 2:2:nCols
                        data(1,k) = data(1,i);
                        k = k+1;
                    end
                    data(:,k:nCols) = [];
                end
                if strcmp(rowProcs(1,iResp),"max")
                    s = s + max(data, [], 'all');
                else
                    s = s + sum(data, 'all');
                end
            end
            resMat(j,iFy+1) = s/numRecs;
        end
    end
    save(outFileName, 'resMat', '-ascii');
end
save("dataStruc.out", 'outDataMat');