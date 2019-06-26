function [ observed_u_set ] = compute_inverseDynamics(traj, times_vec, subject_mass)
% COMPUTE_INVERSEDYNAMICS returns the estimated input used to a generate a
% trajectory
%
%   COMPUTE_INVERSEDYNAMICS(traj, times_vec, subject_mass) iterates through
%   the trials in the cell 'traj' to estimate the input to a TIPM model
%   given 'subject_mass' at the times specified by 'times_vec'

g = 9.81;
%get the inputs
observed_u_set = cell(length(times_vec)-1, 1);
for i = 1:length(traj)
    % compute inputs
    a_x_com = diff(traj{i}.v_x_com)*traj{i}.skel_mocap.sampling_freq;
    a_x_com(end+1) = a_x_com(end);
    a_y_com = diff(traj{i}.v_y_com)*traj{i}.skel_mocap.sampling_freq;
    a_y_com(end+1) = a_y_com(end);
    a_x_com = traj{i}.times(end)^2*a_x_com;
    a_y_com = traj{i}.times(end)^2*a_y_com;

    u_x_com = subject_mass*a_x_com;
    u_y_com = subject_mass*a_y_com + subject_mass*g;
    
    idxs = 1:length(traj{i}.times);
    if isfield(traj{i}, 'first_pert_idx') && ~isnan(traj{i}.first_pert_idx)
        %throw out the portion where the pert is active using a mask of NaN's
        pert_force_x = zeros(length(idxs), 1);
        pert_force_x(traj{i}.first_pert_idx:min(traj{i}.last_pert_idx, length(idxs))) = nan;
        pert_force_y = zeros(length(idxs), 1);
        pert_force_y(traj{i}.first_pert_idx:min(traj{i}.last_pert_idx, length(idxs))) = nan;
    else
        pert_force_x = zeros(length(idxs), 1);
        pert_force_y = zeros(length(idxs), 1);
    end
    
    % throw out the x forces during pert with a mask
    u_x_com = u_x_com - pert_force_x;
    
    % also throw out the y forces during pert with a mask
    u_y_com = u_y_com - pert_force_y;
    
    for t = 1:length(times_vec)
        myT = traj{i}.times(end);
        [~, myidx] = min(abs(traj{i}.times/myT - times_vec(t)));
        observed_u_set{t}(1:6, i) = [traj{i}.p_x_com(myidx); myT*traj{i}.v_x_com(myidx); traj{i}.p_y_com(myidx); myT*traj{i}.v_y_com(myidx); u_x_com(myidx); u_y_com(myidx)];
    end
end

end

