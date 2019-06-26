function [ ] = build_table_results( basintype, presaved )
% BUILD_TABLE_RESULTS
%
%   BUILD_TABLE_RESULTS(basintype, presaved) compiles the results for
%   a given controller type across subjects and nominal sts types. The
%   output of build_table_results may be viewed using the function
%   display_results.m. Also, specifying the flag 'presaved' as true will
%   allow presaved results to be compiled instead.

if ~exist('basintype', 'var')
    error('Please specify the basin type for which to build results.');
end

if ~exist('presaved', 'var')
    presaved = false;
end

subjects = 1:11;
nominal_sts_types = {'MT', 'N', 'QS'};
force_levels = {'low', 'med', 'high'};

total = struct();
total.subject = {};
total.index = [];
total.sts_type = {};
total.label = [];
total.notes = {};
total.classification = {};
total.prediction = {};
total.prediction_correct = [];
total.max_lambda = [];
total.max_lambda_percent = [];
total.firstexit_lambda = [];
total.firstexit_percent = [];
total.firstpert_percent = [];
total.lastpert_percent = [];
total.step_percent = [];
total.sit_percent = [];
total.trial_time = [];

tally = struct();
tally.subjects = subjects';
tally.nominal_sts_types = nominal_sts_types';
tally.nSucc = zeros(length(subjects), length(nominal_sts_types));
tally.nSuccCorrect = zeros(length(subjects), length(nominal_sts_types));
tally.nStep = zeros(length(subjects), length(nominal_sts_types));
tally.nStepCorrect = zeros(length(subjects), length(nominal_sts_types));
tally.nSit = zeros(length(subjects), length(nominal_sts_types));
tally.nSitCorrect = zeros(length(subjects), length(nominal_sts_types));

tally_CP = struct();
for j = 1:length(nominal_sts_types)
    tally_CP.(nominal_sts_types{j}).subjects = subjects';
    tally_CP.(nominal_sts_types{j}).force_levels = force_levels;
    tally_CP.(nominal_sts_types{j}).nSucc = zeros(length(subjects), length(nominal_sts_types));
    tally_CP.(nominal_sts_types{j}).nSuccCorrect = zeros(length(subjects), length(nominal_sts_types));
    tally_CP.(nominal_sts_types{j}).nStep = zeros(length(subjects), length(nominal_sts_types));
    tally_CP.(nominal_sts_types{j}).nStepCorrect = zeros(length(subjects), length(nominal_sts_types));
    tally_CP.(nominal_sts_types{j}).nSit = zeros(length(subjects), length(nominal_sts_types));
    tally_CP.(nominal_sts_types{j}).nSitCorrect = zeros(length(subjects), length(nominal_sts_types));
end

for i = subjects
    subject = num2str(i);
    for j = 1:length(nominal_sts_types)
        nominal_sts_type = nominal_sts_types{j};
        if ~presaved
            load(sprintf('prediction_results/subject%s/subject%s_%s_prediction_results_%s', subject, subject, nominal_sts_type, basintype));
        else
            load(sprintf('prediction_results_20190207/subject%s/subject%s_%s_prediction_results_%s', subject, subject, nominal_sts_type, basintype));
        end
        total.subject = [total.subject; pred.subject];
        total.index = [total.index; pred.index];
        total.sts_type = [total.sts_type; pred.sts_type];
        total.label = [total.label; pred.label];
        total.notes = [total.notes; pred.notes];
        total.classification = [total.classification; pred.classification];
        total.prediction = [total.prediction; pred.prediction];
        total.prediction_correct = [total.prediction_correct; pred.prediction_correct];
        total.max_lambda = [total.max_lambda; pred.max_lambda];
        total.max_lambda_percent = [total.max_lambda_percent; pred.max_lambda_percent];
        total.firstexit_lambda = [total.firstexit_lambda; pred.firstexit_lambda];
        total.firstexit_percent = [total.firstexit_percent; pred.firstexit_percent];
        total.firstpert_percent = [total.firstpert_percent; pred.firstpert_percent];
        total.lastpert_percent = [total.lastpert_percent; pred.lastpert_percent];
        total.step_percent = [total.step_percent; pred.step_percent];
        total.sit_percent = [total.sit_percent; pred.sit_percent];
        total.trial_time = [total.trial_time; pred.trial_time];
        
        idxSucc = find(strcmp(pred.classification, 'success'));
        tally.nSucc(i, j) = length(idxSucc);
        tally.nSuccCorrect(i, j) = nnz(pred.prediction_correct(idxSucc));
        
        idxStep = find(pred.label == 6);
        tally.nStep(i, j) = length(idxStep);
        tally.nStepCorrect(i, j) = nnz(pred.prediction_correct(idxStep));
        
        idxSit = find(pred.label == 7);
        tally.nSit(i, j) = length(idxSit);
        tally.nSitCorrect(i, j) = nnz(pred.prediction_correct(idxSit));
        
        for k = 1:length(force_levels)
            idxSucc = find(strcmp(pred.classification, 'success') & startsWith(pred.sts_type, [nominal_sts_types{j} '_' force_levels{k}]));
            tally_CP.(nominal_sts_types{j}).nSucc(i, k) = length(idxSucc);
            tally_CP.(nominal_sts_types{j}).nSuccCorrect(i, k) = nnz(pred.prediction_correct(idxSucc));
            
            idxStep = find(pred.label == 6 & startsWith(pred.sts_type, [nominal_sts_types{j} '_' force_levels{k}]));
            tally_CP.(nominal_sts_types{j}).nStep(i, k) = length(idxStep);
            tally_CP.(nominal_sts_types{j}).nStepCorrect(i, k) = nnz(pred.prediction_correct(idxStep));
            
            idxSit = find(pred.label == 7 & startsWith(pred.sts_type, [nominal_sts_types{j} '_' force_levels{k}]));
            tally_CP.(nominal_sts_types{j}).nSit(i, k) = length(idxSit);
            tally_CP.(nominal_sts_types{j}).nSitCorrect(i, k) = nnz(pred.prediction_correct(idxSit));
        end
            
        
        
    end
end

%save
if ~exist('total_results', 'dir')
    mkdir('total_results');
end

save(sprintf('total_results/total_results_%s', basintype), 'total', 'tally', 'tally_CP', 'basintype', 'subjects');

end

