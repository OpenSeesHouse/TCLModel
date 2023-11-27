function outMat = extractET_IDA(respFile, t_Sa_File, T)
% respFile = "DynamicDir1/DriftRecord/Story1.txt";
% t_Sa_File = "ETA40lc/01-spec-avrgd.txt";
% T = 1.12;

%read t-sa map matrix
respMat = load(t_Sa_File);
nClmn = size(respMat, 2);
TVec = respMat(:,1);
TVec = TVec';
TVec = [0 TVec];
numT = size(TVec,2);
spec = zeros(numT,81);
spec(2:numT,2:81) = respMat(:,2:nClmn);

%extract resp envelope
nRespFiles = size(respFile,2);
respMat = load(respFile(1));
for n = 2:nRespFiles
    tmp = load(respFile(n));
    nCol = size(tmp,2);
    respMat(:,n+1) = tmp(:,nCol);
end

dMax = 0;
nLine = size(respMat, 1);
outMat = zeros(nLine,nRespFiles+1);
tVec = 0:0.5:40;
j = 1;
[X,Y] = meshgrid(tVec,TVec);
for i = 1:nLine
	t = respMat(i,1);
	d = abs(respMat(i,2));
	if d > dMax
		dMax = d;
        if dMax > 0.2
            break
        end
        sa = interp2(X, Y, spec, t, T);
        outMat(j,1:2) = [sa dMax];
        for n = 2:nRespFiles
            outMat(j,n+1) = abs(respMat(i,n+1));
        end
        j = j + 1;
    end
end
outMat(j:nLine,:) = [];
winSize = round(j/40);
outMat(:,1) = movavg(outMat(:,1),'exponential',winSize);
% outMat(:,3) = movavg(outMat(:,2),'square',winSize);
% x= outMat(:,1);
% y= outMat(:,2);
% sy= outMat(:,3);
% plot(x,y,x,sy);


