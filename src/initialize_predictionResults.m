function [ ] = initialize_predictionResults(subject, nominal_sts_type, options)
% INITIALIZE_PREDICTIONRESULTS builds prediction results struct
%
%   INITIALIZE_PREDICTIONRESULTS(subject, nominal_sts_type, options) builds
%   and saves a struct to be used later by the SB for generating the
%   results for a specific subject, nominal_sts_type, and basintype

load(sprintf('STS_trajectories/subject%s/subject%s_trajectories_%s.mat', subject, subject, nominal_sts_type));

pred = struct();
pred.subject = repmat({subject}, length(traj_metadata.index), 1);
pred.index = traj_metadata.index;
pred.sts_type = traj_metadata.sts_type;
pred.label = traj_metadata.label;
pred.notes = traj_metadata.notes;
pred.classification = traj_metadata.classification;
pred.prediction = {};
pred.prediction_correct = [];
pred.max_lambda = [];
pred.max_lambda_percent = [];
pred.firstexit_lambda = [];
pred.firstexit_percent = [];
for i = 1:length(traj_metadata.index)
    mytraj = traj{i};
    pred.firstpert_percent(i, 1) = mytraj.first_pert_idx/length(mytraj.times);
    pred.lastpert_percent(i, 1) = mytraj.last_pert_idx/length(mytraj.times);
    pred.step_percent(i, 1) = mytraj.step_idx/length(mytraj.times);
    pred.sit_percent(i, 1) = mytraj.sit_idx/length(mytraj.times);
    pred.trial_time(i, 1) = mytraj.times(end);
end

%save
if ~exist(sprintf('prediction_results/subject%s', subject), 'dir')
    mkdir(sprintf('prediction_results/subject%s', subject));
end

save(sprintf('prediction_results/subject%s/subject%s_%s_prediction_results_%s', subject, subject, nominal_sts_type, options.basintype), 'pred');



end

