function [ ] = check_predictions(subject, nominal_sts_type, options)
% CHECK_PREDICTIONS checks whether trajectory exits SB or not
%
%   CHECK_PREDICTIONS(subject, nominal_sts_type, options) loads the SB for
%   the given subject, nominal sts type, and basintype specified in
%   options.basintype. Then, it checks whether the specified leave one out
%   trajectory or unsuccessful trajectories remain within the SB at all
%   time steps. Finally, it updates the prediction struct with results.

load(sprintf('STS_trajectories/subject%s/subject%s_trajectories_%s.mat', subject, subject, nominal_sts_type));
load(sprintf('prediction_results/subject%s/subject%s_%s_prediction_results_%s', subject, subject, nominal_sts_type, options.basintype));
SB = load(sprintf('stability_basins/subject%s/subject%s_%s_basin_%s', subject, subject, nominal_sts_type, options.basintype));

times_vec = 1 - (options.times_vec(2:end));

if isfield(options, 'leaveoneout_index')
    if options.leaveoneout_index == 0
        pred_idx = find(strcmp(traj_metadata.classification, 'fail'));
    else
        pred_idx = options.leaveoneout_index;
    end
else
    pred_idx = traj_metadata.index;
end

for i = 1:length(pred_idx)
    disp(['Checking: subject' subject ' ' traj_metadata.sts_type{pred_idx(i)}]);
    
    % this function actually checks whether the given trajectory is inside
    % the SB at all time steps
    inSB = check_inSB(traj{pred_idx(i)}, SB, times_vec);
    
    pred.prediction{pred_idx(i), 1} = inSB.prediction;
    pred.prediction_correct(pred_idx(i), 1) = strcmp(inSB.prediction, pred.classification{pred_idx(i)});
    pred.max_lambda(pred_idx(i), 1) = inSB.max_lambda;
    pred.max_lambda_percent(pred_idx(i), 1) = inSB.max_lambda_percent;
    pred.firstexit_lambda(pred_idx(i), 1) = inSB.firstexit_lambda;
    pred.firstexit_percent(pred_idx(i), 1) = inSB.firstexit_percent;
end

save(sprintf('prediction_results/subject%s/subject%s_%s_prediction_results_%s', subject, subject, nominal_sts_type, options.basintype), 'pred');

end

