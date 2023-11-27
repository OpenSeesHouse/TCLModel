function error = GetSpectrumMSE(scale, targSpec, specDT, inputSpec, Tmin, Tmax)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    minSize = min(size(inputSpec,1), size(targSpec,1));
    i = floor(Tmin/specDT)-1;
    i = min(i, minSize);
    i = max(i,1);
    j = floor(Tmax/specDT)-1;
    j = min(j,minSize);
    j = max(j,1);
    error = 0;
    num = j-i+1;
    while i <= j
        error = error + (scale*inputSpec(i)-targSpec(i))^2;
        i = i + 1;
    end
    error = sqrt(error/num);
end

