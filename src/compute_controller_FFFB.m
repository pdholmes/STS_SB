function [] = compute_controller_FFFB( subject, nominal_sts_type, options )
% COMPUTE_CONTROLLER_FFFB
%
%   COMPUTE_CONTROLLER_FFFB(subject, nominal_sts_type, options) computes
%   the FF+FB controller from data for the given subject and nominal sts
%   type. It differs from the BFF+FB controller in that it does not
%   generate bounds, but rather a line of best fit.

load(sprintf('STS_trajectories/subject%s/subject%s_trajectories_%s.mat', subject, subject, nominal_sts_type));
if isfield(options, 'leaveoneout_sts_type')
    idxs = find(strcmp(traj_metadata.classification, 'success') & ~strcmp(traj_metadata.sts_type, options.leaveoneout_sts_type));
else
    idxs = find(strcmp(traj_metadata.classification, 'success'));
end

times_vec = options.times_vec;

observed_u_set = compute_inverseDynamics(traj(idxs), times_vec, subject_mass);

u_x = cell(length(times_vec)-1, 1);
u_y = cell(length(times_vec)-1, 1);

for t = 1:length(times_vec)
    C = [];
    d = [];
    
    % take out nan idxs
    nnan_idx = find(~isnan(observed_u_set{t}(5, :)));
    C = observed_u_set{t}(1:4, nnan_idx)';
    d = observed_u_set{t}(5, nnan_idx)';

    C = [C, ones(size(C, 1), 1)];

    myline = lsqlin(C, d, [], []);
    u_x{t} = myline;
    
    %now do the same thing for the y inputs.
    d = observed_u_set{t}(6, nnan_idx)';
    myline = lsqlin(C, d, [], []);
    u_y{t} = myline;
end

if ~exist(sprintf('controller_models/subject%s', subject), 'dir')
    mkdir(sprintf('controller_models/subject%s', subject));
end

nInput = 10; % 10 inputs required for dynamics function
save(sprintf('controller_models/subject%s/subject%s_%s_controller_FFFB', subject, subject, nominal_sts_type), 'u_x', 'u_y', 'nInput');


end

