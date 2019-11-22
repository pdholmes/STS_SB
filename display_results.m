function [ ] = display_results()

datapath = 'presaved/';
% uncomment the following to use local (not presaved) results
% datapath = '';

dispon = 1;
dispCPon = 0;

nominal_sts_types = {'MT', 'N', 'QS'};
basintypes = {'InputBounds', 'LQR', 'FFFB', 'naive'};
for j = 1:length(basintypes)
    basintype = basintypes{j};
    disp('Basin type:');
    disp(basintype);
    load(sprintf('%stotal_results/total_results_%s', datapath, basintype));
    disptable = struct();
    disptable.sts_types = {'MT'; 'N'; 'QS'; 'total'};
    
    disptable_CP = struct();
    
    for k = 1:length(nominal_sts_types)
        nSucc_all = sum(tally_CP.(nominal_sts_types{k}).nSucc);
        nSuccCorrect_all = sum(tally_CP.(nominal_sts_types{k}).nSuccCorrect);
        nStep_all = sum(tally_CP.(nominal_sts_types{k}).nStep);
        nStepCorrect_all = sum(tally_CP.(nominal_sts_types{k}).nStepCorrect);
        nSit_all = sum(tally_CP.(nominal_sts_types{k}).nSit);
        nSitCorrect_all = sum(tally_CP.(nominal_sts_types{k}).nSitCorrect);
        nPredSucc = nSuccCorrect_all + (nStep_all - nStepCorrect_all) + (nSit_all - nSitCorrect_all);
        nPredSuccWrong = (nStep_all - nStepCorrect_all) + (nSit_all - nSitCorrect_all);
        nPredFail = nStepCorrect_all + nSitCorrect_all + (nSucc_all - nSuccCorrect_all);
        nPredFailWrong = (nSucc_all - nSuccCorrect_all);
        disptable_CP.(nominal_sts_types{k}).force_levels = {'low'; 'med'; 'high'; 'total'};
        for i = 1:3
            disptable_CP.(nominal_sts_types{k}).success_accuracy{i, 1} = [num2str(nSuccCorrect_all(i)) '/' num2str(nSucc_all(i)) ' = ' num2str(100*(nSuccCorrect_all(i)/nSucc_all(i))) '%'];
            disptable_CP.(nominal_sts_types{k}).step_accuracy{i, 1} = [num2str(nStepCorrect_all(i)) '/' num2str(nStep_all(i)) ' = ' num2str(100*(nStepCorrect_all(i)/nStep_all(i))) '%'];
            disptable_CP.(nominal_sts_types{k}).sit_accuracy{i, 1} = [num2str(nSitCorrect_all(i)) '/' num2str(nSit_all(i)) ' = ' num2str(100*(nSitCorrect_all(i)/nSit_all(i))) '%'];
            disptable_CP.(nominal_sts_types{k}).false_successful_predictions{i, 1} = [num2str(nPredSuccWrong(i)) '/' num2str(nPredSucc(i)) ' = ' num2str(100*(nPredSuccWrong(i)/nPredSucc(i))) '%'];
            disptable_CP.(nominal_sts_types{k}).false_failure_predictions{i, 1} = [num2str(nPredFailWrong(i)) '/' num2str(nPredFail(i)) ' = ' num2str(100*(nPredFailWrong(i)/nPredFail(i))) '%'];
        end

        disptable_CP.(nominal_sts_types{k}).success_accuracy{4, 1} = [num2str(sum(nSuccCorrect_all)) '/' num2str(sum(nSucc_all)) ' = ' num2str(100*(sum(nSuccCorrect_all)/sum(nSucc_all))) '%'];
        disptable_CP.(nominal_sts_types{k}).step_accuracy{4, 1} = [num2str(sum(nStepCorrect_all)) '/' num2str(sum(nStep_all)) ' = ' num2str(100*(sum(nStepCorrect_all)/sum(nStep_all))) '%'];
        disptable_CP.(nominal_sts_types{k}).sit_accuracy{4, 1} = [num2str(sum(nSitCorrect_all)) '/' num2str(sum(nSit_all)) ' = ' num2str(100*(sum(nSitCorrect_all)/sum(nSit_all))) '%'];
        disptable_CP.(nominal_sts_types{k}).false_successful_predictions{4, 1} = [num2str(sum(nPredSuccWrong)) '/' num2str(sum(nPredSucc)) ' = ' num2str(100*(sum(nPredSuccWrong)/sum(nPredSucc))) '%'];
        disptable_CP.(nominal_sts_types{k}).false_failure_predictions{4, 1} = [num2str(sum(nPredFailWrong)) '/' num2str(sum(nPredFail)) ' = ' num2str(100*(sum(nPredFailWrong)/sum(nPredFail))) '%'];
    end
    
    nSucc_all = sum(tally.nSucc);
    nSuccCorrect_all = sum(tally.nSuccCorrect);
    nStep_all = sum(tally.nStep);
    nStepCorrect_all = sum(tally.nStepCorrect);
    nSit_all = sum(tally.nSit);
    nSitCorrect_all = sum(tally.nSitCorrect);
    nPredSucc = nSuccCorrect_all + (nStep_all - nStepCorrect_all) + (nSit_all - nSitCorrect_all);
    nPredSuccWrong = (nStep_all - nStepCorrect_all) + (nSit_all - nSitCorrect_all);
    nPredFail = nStepCorrect_all + nSitCorrect_all + (nSucc_all - nSuccCorrect_all);
    nPredFailWrong = (nSucc_all - nSuccCorrect_all);
    for i = 1:3
        disptable.success_accuracy{i, 1} = [num2str(nSuccCorrect_all(i)) '/' num2str(nSucc_all(i)) ' = ' num2str(100*(nSuccCorrect_all(i)/nSucc_all(i))) '%'];
        disptable.step_accuracy{i, 1} = [num2str(nStepCorrect_all(i)) '/' num2str(nStep_all(i)) ' = ' num2str(100*(nStepCorrect_all(i)/nStep_all(i))) '%'];
        disptable.sit_accuracy{i, 1} = [num2str(nSitCorrect_all(i)) '/' num2str(nSit_all(i)) ' = ' num2str(100*(nSitCorrect_all(i)/nSit_all(i))) '%'];
        disptable.false_successful_predictions{i, 1} = [num2str(nPredSuccWrong(i)) '/' num2str(nPredSucc(i)) ' = ' num2str(100*(nPredSuccWrong(i)/nPredSucc(i))) '%'];
        disptable.false_failure_predictions{i, 1} = [num2str(nPredFailWrong(i)) '/' num2str(nPredFail(i)) ' = ' num2str(100*(nPredFailWrong(i)/nPredFail(i))) '%'];
    end
    
    disptable.success_accuracy{4, 1} = [num2str(sum(nSuccCorrect_all)) '/' num2str(sum(nSucc_all)) ' = ' num2str(100*(sum(nSuccCorrect_all)/sum(nSucc_all))) '%'];
    disptable.step_accuracy{4, 1} = [num2str(sum(nStepCorrect_all)) '/' num2str(sum(nStep_all)) ' = ' num2str(100*(sum(nStepCorrect_all)/sum(nStep_all))) '%'];
    disptable.sit_accuracy{4, 1} = [num2str(sum(nSitCorrect_all)) '/' num2str(sum(nSit_all)) ' = ' num2str(100*(sum(nSitCorrect_all)/sum(nSit_all))) '%'];
    disptable.false_successful_predictions{4, 1} = [num2str(sum(nPredSuccWrong)) '/' num2str(sum(nPredSucc)) ' = ' num2str(100*(sum(nPredSuccWrong)/sum(nPredSucc))) '%'];
    disptable.false_failure_predictions{4, 1} = [num2str(sum(nPredFailWrong)) '/' num2str(sum(nPredFail)) ' = ' num2str(100*(sum(nPredFailWrong)/sum(nPredFail))) '%'];
    
    if dispon
        disp(struct2table(disptable));
    end
    
    if dispCPon
       for k = 1:length(nominal_sts_types)
           disp(nominal_sts_types{k})
           disp(struct2table(disptable_CP.(nominal_sts_types{k})));           
       end
    end
    
%     save(sprintf('total_results/disp_results_%s', basintype));
end


end