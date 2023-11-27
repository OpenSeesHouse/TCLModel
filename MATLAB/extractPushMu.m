for nFlrs = [4]
    for MEF = ["5%" "10%" "20%"]
		for isDsgnd = [0 1]
            if strcmp(MEF, "5%") && ~isDsgnd
                continue
            end
			baseStr = "NotDsgnd";
			if isDsgnd == 1
				baseStr = "Designed";
			end
			k = 1;
			refVm = 0;
			refMu = 0;
			for fc = [21]
				file1 = sprintf("../pushPlots/%dStory/%sECC/fc=%d/%s/absvm.txt", nFlrs, MEF, fc,  baseStr);
				file1 = fopen(file1, 'w');
				file2 = sprintf("../pushPlots/%dStory/%sECC/fc=%d/%s/absmu.txt", nFlrs, MEF, fc,  baseStr);
				file2 = fopen(file2, 'w');
				file3 = sprintf("../pushPlots/%dStory/%sECC/fc=%d/%s/relvm.txt", nFlrs, MEF, fc,  baseStr);
				file3 = fopen(file3, 'w');
				file4 = sprintf("../pushPlots/%dStory/%sECC/fc=%d/%s/relmu.txt", nFlrs, MEF, fc,  baseStr);
				file4 = fopen(file4, 'w');
				path = sprintf("../pushPlots/%dStory/%sECC/fc=%d/%s/globalDriftX.out", nFlrs, MEF, fc,  baseStr);
				mat = load(path);
				n = size(mat,1);
				for i = 1:3
					c2 = 2*i-1;
					c1 = 2*i;
					[vm, im] = max(mat(:,c2), [], 'all','linear');
					ey = mat(im,c1)/2;
					j = 1;
					for j = im:n
						v = mat(j,c2);
						if v < 0.8*vm
							break;
						end
					end
					mu = mat(j,c1)/ey;
					if refVm == 0
						refVm = vm;
						refMu = mu;
					end
					fprintf(file1, "%.3f ", vm);
					fprintf(file2, "%.3f ", mu);
					fprintf(file3, "%.3f ", vm/refVm);
					fprintf(file4, "%.3f ", mu/refMu);
				end
				if fc ~= 45
					fprintf(file1, "\n");
					fprintf(file2, "\n");
					fprintf(file3, "\n");
					fprintf(file4, "\n");
				end
			end
			fclose(file1);
			fclose(file2);
			fclose(file3);
			fclose(file4);
		end
    end
end