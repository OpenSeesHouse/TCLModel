clear; clc
gmPath = '../NearWithPulse/AT2';
outPath = '../NearWithPulse/AT2/Spectra';
recList = 1:28;
nCores = 6;
cp = gcp("nocreate");
if nCores > 1 && isempty(cp) 
    parpool(nCores);
end
inPath = outPath;
dt = 0;
if ~exist(outPath, "dir")
    mkdir(outPath);
end
specType = 'elastic'; % 'inelastic'
targDuctils = [1];
if strcmp(specType,'inelastic')
    modelName = 'inelasticModel';
    targDuctils = [4];
end
zetaDamp = 0.05;
specVar = 'sMax';
TLimits = [0.1;0.2;0.5;1;4;8;20];
TSteps = [0.01;0.02;0.05;0.1;0.2;0.5;2];
maxT = 20;
allTs = [];
T = 0;
Tstep = TSteps(1);
i = 1;
j = 1;
while T <= maxT
    T = T + Tstep;
    if T - TLimits (j,1) > 0.001
        j = j + 1;
        if j > size(TLimits,1)
            break;
        end
        T = T - Tstep;
        Tstep = TSteps(j);
        T = T + Tstep;
    end
    allTs(i,1) = T;
    i = i + 1;
end
numT = size(allTs,1);
numRecs = size(recList,2);

for ductil = targDuctils
    fprintf ('ductil= %.2f\n', ductil);
    parfor (i=1:numRecs)
        iRec = recList(1,i);
        SF = 1;
        if strcmp(specType,'inelastic')
            outSpec = sprintf('%s/duct_%.3f_%d.txt', outPath, ductil, iRec);
            makeInelastSpectrum(allTs, ductil, iRec, outSpec, modelName, SF, zetaDamp, gmPath, outPath, specVar);
        else
            outSpec = sprintf('%s/%d.txt', outPath, iRec);
            makeElastSpectrum(allTs, iRec, outSpec, SF, zetaDamp, gmPath, outPath, specVar);
        end
    end
end

