function iJob = runSinglePush(work)
    stNum = work(1);
    ecc = work(2);
    fc = work(3);
    fyStr = work(4);
    base = work(5);
    jobNum = work(6);
    isDsgnd = work(7);
	pushDir = work(8);
    opsPath = work(9);
    iJob = str2num(jobNum);
    path = sprintf("../Designs/%sStory/%sEcc/fc=%.0f/%s", stNum, ecc, fc, fyStr);
    filename = sprintf('tmpRuns/run_%s.tcl', jobNum);
    fid = fopen(filename, 'w');
    if strcmp(isDsgnd,"1")
        fprintf(fid, 'set inputs(resFolder) %s/push-Designed\n', path);
    else
        fprintf(fid, 'set specFilePath %s\n', base);
        fprintf(fid, 'set inputs(resFolder) %s/push-NotDsgnd\n', path);
    end
    fprintf(fid, 'set pushDir %s\n', pushDir);
    fprintf(fid, 'set modelFolder %s\n', path);
    fprintf(fid, 'source general/runSinglePush.tcl\n');
    fclose(fid);
    cmnd = sprintf('%s %s', opsPath, filename);
    [stat, cmd] = system(cmnd);
%     cmd
    delete(filename);
