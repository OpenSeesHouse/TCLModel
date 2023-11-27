function MSE(numRecs, skipRecs)
addpath '../general'
path = cd();
targSpecPath = '../general/DBESpectrum.txt';      %target spectrum path (T and Sa in two columns)
inputSpecPath = '../general/GMfiles/spectra';    %input spectrum path (Sa columns in given dT values)
numInputSpecs = numRecs-size(skipRecs,2);
Ts = load(sprintf('%s/periods.txt', path));
T = Ts(1,2);
Tmax = 2*T;             %upper bound Ts for spectrum matching
Tmin = T*0.2;   %lower bound Ts for spectrum matching
iRec = 1;
filePath = sprintf('%s/%d.txt', inputSpecPath, iRec);
tmp = load(filePath);
dt = 0.01;
Tm = max(tmp(:,1));
Ts = transpose(dt:dt:Tm);
numTs = Tm/dt;
inputSpecs = zeros(numTs,numInputSpecs);
iRec = 0;
for rec = 1:numRecs
    if isempty(find(skipRecs == rec))
        iRec = iRec + 1;
        filePath = sprintf('%s/%d.txt', inputSpecPath, rec);
        tmp = load(filePath);
        t = 0.01;
        i = 1;
        while t <= Tm
            inputSpecs(i,iRec) = interpolateSpec(tmp, t);
            i = i +1;
            t = t + dt;
        end
    end
end
specDT = dt;
targSpec = zeros(numTs,1);
targSpecArr = load(targSpecPath);
targSpec(1) = targSpecArr(1);
for i = 2: numTs
    targSpec(i) = interpolateSpec(targSpecArr, Ts(i,1));
end
iT1 = floor(Tmin/specDT);
iT2 = ceil(Tmax/specDT);
scaleFacs = zeros(numInputSpecs,1);
minScale = 0.1;
maxScale = 10;
options = optimset('Display','off', 'TolX', 0.01, 'MaxIter', 20);
scaledSpecs = zeros(numTs,numInputSpecs);
for i=1:numInputSpecs
    inputSpec = inputSpecs(:,i);
    errorFunction = @(x) GetSpectrumMSE(x, targSpec, specDT, inputSpec, Tmin, Tmax);
    scaleFacs(i) = fminbnd(errorFunction, minScale, maxScale, options);
    scaledSpecs(:,i) = inputSpec * scaleFacs(i);
end
%     medianSpec = zeros(numTs,1);
%     for i = 1: numTs
%         medianSpec(i) = median(scaledSpecs(i,:));
%     end

meanSpec = inputSpecs * scaleFacs;
meanSpec = meanSpec / numInputSpecs;
fileName1 = sprintf('%s/scaleFacs.txt', path);
fileName2 = sprintf('%s/scaledSpecs.txt', path);
fileName3 = sprintf('%s/meanSpec.txt', path);
save(fileName1, 'scaleFacs', '-ascii');
save(fileName2, 'scaledSpecs', '-ascii');
save(fileName3, 'meanSpec', '-ascii');
plot(Ts, scaledSpecs, 'c', Ts, meanSpec, 'k', Ts, targSpec, 'k--');
xlabel ('T (sec)');
ylabel ('Spectral Acceleration (g)');
minScale = min(scaleFacs)
maxScale = max(scaleFacs)
meanScale = mean(scaleFacs)

