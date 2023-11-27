function printPushWorkStat(work)
	stNum = work(1);
	ecc = work(2);
	fc = work(3);
	fyStr = work(4);
	iJob = work(6);
	useBaseModel = work(7);
	fprintf('recieved job: %-5s numSt= %-2s ecc= %-3s fc= %-2s fyStr: %-15s usaBase: %s\n', iJob, stNum, ecc, fc, fyStr, useBaseModel);
