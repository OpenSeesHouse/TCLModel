function printNTHWorkStat(work)
	stNum = work.data.stNum;
	ecc = work.data.ecc;
	fc = work.data.fc;
	fyStr = work.data.fyStr;
	iRec = work.iRec;
	fac = work.data.fac;
	iJob = work.iJob;
	isDsgnd = work.data.isDsgnd;
	fprintf('recieved job: %-5d iRec= %-2d numSt= %-2d ecc= %-3s fc= %-2s fyStr: %-15s isDesigned: %d, fac: %.2f\n', iJob, iRec, stNum, ecc, fc, fyStr, isDsgnd, fac);
