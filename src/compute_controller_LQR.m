function [ ] = compute_controller_LQR( subject, nominal_sts_type, options )
% COMPUTE_CONTROLLER_LQR
%
%   COMPUTE_CONTROLLER_LQR(subject, nominal_sts_type, options) computes the
%   LQR controller for the specified subject and nominal sts type at the
%   times listed in options.times_vec. It computes a feedforward input for
%   an average nominal trajectory, then specifies the LQR gains to track
%   the nominal_trajectory.

traj_load = load(sprintf('STS_trajectories/subject%s/subject%s_trajectories_%s.mat', subject, subject, nominal_sts_type));
traj = traj_load.traj;
traj_metadata = traj_load.traj_metadata;
subject_mass = traj_load.subject_mass;

times_vec = options.times_vec;

% leave one out
if isfield(options, 'leaveoneout_sts_type')
    idxs = find(strcmp(traj_metadata.classification, 'success') & ~strcmp(traj_metadata.sts_type, options.leaveoneout_sts_type));
else
    idxs = find(strcmp(traj_metadata.classification, 'success'));
end

avg_traj{1} = compute_averageNominal(subject, nominal_sts_type);
observed_avg_u_set = compute_inverseDynamics(avg_traj, times_vec, subject_mass);
observed_u_set = compute_inverseDynamics(traj(idxs), times_vec, subject_mass);

% use LQR to get gains ----------------------------------------------------
A = cell(length(times_vec),1);
for t = 1:length(times_vec)
    A{t} = [0 1 0 0; 0 0 0 0; 0 0 0 1; 0 0 0 0];
end
B = [0 0; 1/subject_mass 0; 0 0; 0 1/subject_mass];

cost_func = @(x)eval_cost(x);
lbrel = 0.1;
ubrel = 10;
lbscale = 1e-5;
ubscale = 1e-2;
best_scale = fmincon(cost_func, [1; 1; 1; 1e-4; 1], [], [], [], [], [lbrel; lbrel; lbrel; lbscale; lbrel], [ubrel; ubrel; ubrel; ubscale; ubrel]);

% use the best Q and R matrices -------------------------------------------
Q = diag([1; best_scale(1); best_scale(2); best_scale(3)]);
R = best_scale(4)*[1, 0; 0, best_scale(5)];

K = compute_controller_LQR_gains(A, B, Q, R, times_vec);

for t = 1:length(times_vec)
    u_x_tmp{t} = [observed_avg_u_set{t}(5); observed_avg_u_set{t}(1:2); K{t}(1, :)'];
    u_y_tmp{t} = [observed_avg_u_set{t}(6); observed_avg_u_set{t}(3:4); K{t}(2, :)'];
    u_tmp{t} = [u_x_tmp{t}; u_y_tmp{t}];
end

% evaluate fit of the K matrices to data
tmp_norm_best = evaluate_controller_LQR(u_tmp, observed_u_set);

% output in a nice format -------------------------------------------------
u_x = cell(length(times_vec)-1, 1);
u_y = cell(length(times_vec)-1, 1);

for t = 1:length(times_vec)
   u_x{t} = [observed_avg_u_set{t}(5); observed_avg_u_set{t}(1:2); K{t}(1, :)'];
   u_y{t} = [observed_avg_u_set{t}(6); observed_avg_u_set{t}(3:4); K{t}(2, :)'];
end

if ~exist(sprintf('controller_models/subject%s', subject), 'dir')
    mkdir(sprintf('controller_models/subject%s', subject));
end

nInput = 14; % 14 inputs required for dynamics function
save(sprintf('controller_models/subject%s/subject%s_%s_controller_LQR', subject, subject, nominal_sts_type), 'u_x', 'u_y', 'nInput');

    function [cost] = eval_cost(x)
        %         tmpQ = eye(4);
        tmpQ = diag([1; x(1); x(2); x(3)]);
        % R = scales(best_idx)*eye(2);
        tmpR = x(4)*[1, 0; 0, x(5)];
        tmpK = compute_controller_LQR_gains(A, B, tmpQ, tmpR, times_vec);
        
        for t = 1:length(times_vec)
            u_x_tmp{t} = [observed_avg_u_set{t}(5); observed_avg_u_set{t}(1:2); tmpK{t}(1, :)'];
            u_y_tmp{t} = [observed_avg_u_set{t}(6); observed_avg_u_set{t}(3:4); tmpK{t}(2, :)'];
            u_tmp{t} = [u_x_tmp{t}; u_y_tmp{t}];
        end
        
        cost = evaluate_controller_LQR(u_tmp, observed_u_set);
    end

end
