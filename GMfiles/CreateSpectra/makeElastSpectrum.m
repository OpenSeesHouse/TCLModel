function makeElastSpectrum(allTs, iRec, outSpec, SF, zetaDamp, gmPath, outPath, specVar)
    numT = size(allTs,1);
    TList = "";
    for i = 1:numT
        TList = sprintf('%s %.3f', TList, allTs(i,1));
    end
    % SF = 1;
    runFileName = sprintf('%s/run_mu_%.3f_%d.txt', outPath, 1, iRec);
    fileId2 = fopen(runFileName , 'w');
    fprintf(fileId2, 'set TList \"%s\"\n', TList);
    fprintf(fileId2, 'set SF %f\n', SF);
    fprintf(fileId2, 'set gmPath %s\n', gmPath);
    fprintf(fileId2, 'set zetaDamp %f\n',zetaDamp);
    fprintf(fileId2, 'set dataFile %s\n', outSpec);
    fprintf(fileId2, 'set iRec %d\n', iRec);
    fprintf(fileId2, 'set specVar %s\n', specVar);
    fprintf(fileId2, 'source makeElastSpectrum.tcl\n');
    fclose(fileId2);
    command = sprintf ('OpenSeesH.exe %s', runFileName);
    [status, cmdout] = system(command);
    if exist (outSpec , 'file') == 0
        fprintf('!!!! error creating spectrum for iRec = %d, targMu = %.3f !!!!\n', iRec, 1);
        file = sprintf('tempFiles/err_%.3f_%d.txt', 1, iRec);
        id = fopen(file, 'w');
        fprintf(id, cmdout);
        fclose (id);
    else
        delete(runFileName);
    end
end
