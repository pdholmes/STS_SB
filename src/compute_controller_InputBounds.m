function [ ] = compute_controller_InputBounds( subject, nominal_sts_type, options )
% COMPUTE_CONTROLLER_InputBounds
%
%   COMPUTE_CONTROLLER_InputBounds(subject, nominal_sts_type, options) computes
%   the InputBounds controller from data for the given subject and
%   nominal_sts_type. The times at which to save the controller gains are 
%   specified in options.times_vec.

plot_on = 0; % can use this flag to plot a projection of the planes computed by the controller

load(sprintf('STS_trajectories/subject%s/subject%s_trajectories_%s.mat', subject, subject, nominal_sts_type));
if isfield(options, 'leaveoneout_sts_type')
    idxs = find(strcmp(traj_metadata.classification, 'success') & ~strcmp(traj_metadata.sts_type, options.leaveoneout_sts_type));
else
    idxs = find(strcmp(traj_metadata.classification, 'success'));
end

times_vec = options.times_vec;

% get the estimated input trajectories via inverse dynamics
observed_u_set = compute_inverseDynamics(traj(idxs), times_vec, subject_mass);

u_x = cell(length(times_vec)-1, 1);
u_y = cell(length(times_vec)-1, 1);

% this will iterate through each of the times listed in times_vec, and run
% constrained linear least squares at each time step to generate upper and
% lower bounds on the input.
for t = 1:length(times_vec)
    C = [];
    d = [];

    % take out nan indices for fitting
    nnan_idx = find(~isnan(observed_u_set{t}(5, :)));
    C = observed_u_set{t}(1:4, nnan_idx)';
    d = observed_u_set{t}(5, nnan_idx)';
    if plot_on
        figure(1); clf; hold on; view(45, 45);
        title(num2str(t));
        plot3(C(:, 1), C(:, 2), d, 'b.', 'MarkerSize', 20);
        pause;
    end
    slope_constraint = [1 0 0 0 0 -1 0 0 0 0; 0 1 0 0 0 0 -1 0 0 0; 0 0 1 0 0 0 0 -1 0 0; 0 0 0 1 0 0 0 0 -1 0];
    c_ = [0; 0; 0; 0];

    C = [C, ones(size(C, 1), 1)];
    C_ = [C, zeros(size(C)); zeros(size(C)), C];
    d_ = [d; d];
    A_ = [C, zeros(size(C)); zeros(size(C)), -C];
    b_ = [d; -d];
    B_ = slope_constraint;
    myplanes = lsqlin(C_, d_, A_, b_, B_, c_);
    u_x{t} = myplanes([1:4, 10, 5], 1);

    %now do the same thing for the y inputs.
    d = observed_u_set{t}(6, nnan_idx)';
    d_ = [d; d];
    b_ = [d; -d];
    myplanes = lsqlin(C_, d_, A_, b_, B_, c_);
    u_y{t} = myplanes([1:4, 10, 5], 1);
end

if ~exist(sprintf('controller_models/subject%s', subject), 'dir')
    mkdir(sprintf('controller_models/subject%s', subject));
end

nInput = 14; % 14 inputs required for dynamics function
save(sprintf('controller_models/subject%s/subject%s_%s_controller_InputBounds', subject, subject, nominal_sts_type), 'u_x', 'u_y', 'nInput');

end

