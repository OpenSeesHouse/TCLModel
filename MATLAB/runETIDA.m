clear;clc;
% function idaRes = runETIDA(runID, modelName, T)
% runID = 1;
model = "SCBF16-RSA";
SF = 1;
Tfile = sprintf("../%s/periods.txt", model);
T = load(Tfile);
T = T(1,2);
% W = 486479; %4-st
% W = 994552; %8-st
W = 4021400; %16-st
numPnts = 100;
parfor nRec = 1:3
    inputs(resFolder) = sprintf("ET/%d", nRec);
    tmpPath = sprintf("../tmpRuns/%s_rec_%d.tcl", model, nRec);
    fid = fopen(tmpPath, 'w');
    fprintf(fid, "set SF %f\n", SF);
    fprintf(fid, "set iRec %d\n", nRec);
    fprintf(fid, "set inputs(resFolder) %s\n", inputs(resFolder));
    fprintf(fid, "cd ../%s\n", model);
    fprintf(fid, "source ../general/runET.tcl\n");
    fclose(fid);
    cmnd = sprintf("OpenSeesH %s", tmpPath);
    [stat, cmdout] = system(cmnd);
    cmdout
end
dMax(3) = 0;
for nRec = 1:3
    respFile(1) = sprintf("../%s/ET/%d/Drifts/maxAll.out", model, nRec);
    respFile(2) = sprintf("../%s/ET/%d/StoryShear/1.txt", model, nRec);
    respFile(3) = sprintf("../%s/ET/%d/globalDrift.txt", model, nRec);
    t_Sa_File = sprintf("GMFiles/ETA40lc/0%d-spec-avrgd.txt", nRec);
    res = extractET_IDA(respFile, t_Sa_File, T);
    n = size(res,1);
    idaSize(nRec) = n;
    idaMat(1:n,:,nRec) = res;
    for i = 1:3
        d = max(idaMat(:,i+1,nRec),[], 'all');
        dMax(i) = max([dMax(i), d]);
    end
end
idaRes = zeros(numPnts,6);

%average IDA curve
j = 1;
dd = dMax(j)/numPnts;
for i = 1:numPnts
    d = i*dd;
    saAvrg = 0;
    for nRec = 1:3
        n = idaSize(nRec);
        sa = interp1(idaMat(1:n,j+1,nRec), idaMat(1:n,1,nRec), d, 'linear', 'extrap');
        saAvrg = saAvrg + SF*sa;
    end
    idaRes(i,2*j-1) = saAvrg/3;
    idaRes(i,2*j) = d;
end

%average v-d curve (average the v values interpolated at increasing d values)
j = 2;
dd = dMax(3)/numPnts;
for i = 1:numPnts
    d = i*dd;
    vAvrg = 0;
    for nRec = 1:3
        n = idaSize(nRec);
        v = interp1(idaMat(1:n,4,nRec), idaMat(1:n,3,nRec), d, 'linear', 'extrap');
        vAvrg = vAvrg + v;
    end
    idaRes(i,2*j-1) = vAvrg/3;
    idaRes(i,2*j) = d;
end

respFile = sprintf("../%s/ET/ETIDA.txt", model);
tmp(:,2) = idaRes(:,1);
tmp(:,1) = idaRes(:,2);
save(respFile, 'tmp', '-ascii');

respFile = sprintf("../%s/ET/ETVD.txt", model);
tmp(:,2) = idaRes(:,3)/W;
tmp(:,1) = idaRes(:,4);
save(respFile, 'tmp', '-ascii');


