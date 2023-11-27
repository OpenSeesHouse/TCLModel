function iJob = runSingleTH(work, opsPath)
    isDsgnd = work.data.isDsgnd;
    % opsPath = work(11);
    outpath = work.outputPath;
    modelFolder = work.modelFolder;
    filename = sprintf('tmpRuns/run_%d.tcl', iJob);
    fid = fopen(filename, 'w');
    fprintf(fid, 'set iRec %d\n', iRec);
    fprintf(fid, 'set inputs(resFolder) %s\n', outpath);
    if ~isDsgnd
        fprintf(fid, 'set specFilePath %s\n', work.inputPath);
    end
    fprintf(fid, 'set SF %.4f\n', sf);
    fprintf(fid, 'set modelFolder %s\n', modelFolder);
    fprintf(fid, 'source general/runSingleTH_SF.tcl\n');
    fclose(fid);
    cmnd = sprintf('%s %s', opsPath, filename);
    [stat, cmd] = system(cmnd);
    % cmd
    delete(filename);
