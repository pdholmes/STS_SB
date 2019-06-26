function [ ] = compute_controller_LQR( subject, nominal_sts_type, options )
% COMPUTE_CONTROLLER_LQR
%
%   COMPUTE_CONTROLLER_LQR(subject, nominal_sts_type, options) computes the
%   LQR controller for the specified subject and nominal sts type at the
%   times listed in options.times_vec. It computes a feedforward input for
%   an average nominal trajectory, then specifies the LQR gains to track
%   the nominal_trajectory.

load(sprintf('STS_trajectories/subject%s/subject%s_trajectories_%s.mat', subject, subject, nominal_sts_type));

times_vec = options.times_vec;

avg_traj{1} = compute_averageNominal(subject, nominal_sts_type);
observed_u_set = compute_inverseDynamics(avg_traj, times_vec, subject_mass);

u_x = cell(length(times_vec)-1, 1);
u_y = cell(length(times_vec)-1, 1);

% use LQR to get gains ----------------------------------------------------
A = cell(length(times_vec),1);
for t = 1:length(times_vec)
    A{t} = [0 1 0 0; 0 0 0 0; 0 0 0 1; 0 0 0 0];
end
B = [0 0; 1/subject_mass 0; 0 0; 0 1/subject_mass];
Q = eye(4);
R = 0.0001*eye(2); % this combination of weighting matrices empirically observed to produce best results
K = compute_controller_LQR_gains(A, B, Q, R, times_vec);

% output in a nice format -------------------------------------------------
for t = 1:length(times_vec)
   u_x{t} = [observed_u_set{t}(5); observed_u_set{t}(1:2); K{t}(1, :)'];
   u_y{t} = [observed_u_set{t}(6); observed_u_set{t}(3:4); K{t}(2, :)'];
end

if ~exist(sprintf('controller_models/subject%s', subject), 'dir')
    mkdir(sprintf('controller_models/subject%s', subject));
end

nInput = 14; % 14 inputs required for dynamics function
save(sprintf('controller_models/subject%s/subject%s_%s_controller_LQR', subject, subject, nominal_sts_type), 'u_x', 'u_y', 'nInput');


end

