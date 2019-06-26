function [avg_traj] = compute_averageNominal(subject, nominal_sts_type)
% COMPUTE_AVERAGENOMINAL
% 
%   [avg_traj] = COMPUTE_AVERAGENOMINAL(subject, nominal_sts_type) averages
%   together the nominal trials for the given subject and nominal sts type
%   to form a single average nominal trajectory returned in 'avg_traj'

load(sprintf('STS_trajectories/subject%s/subject%s_trajectories_%s.mat', subject, subject, nominal_sts_type));
idxs = find(traj_metadata.label == 1);

p_x_com_mat = [];
p_y_com_mat = [];
endtimes = [];
samples = 1001;
sampling_freq = traj{idxs(1)}.skel_mocap.sampling_freq;

for i = 1:length(idxs)
    p_x_com_mat(i, :) = ppval(spline(traj{idxs(i)}.times, traj{idxs(i)}.p_x_com), linspace(0, traj{idxs(i)}.times(end), samples));
    p_y_com_mat(i, :) = ppval(spline(traj{idxs(i)}.times, traj{idxs(i)}.p_y_com), linspace(0, traj{idxs(i)}.times(end), samples));
    endtimes(i) = traj{idxs(i)}.times(end);
end

p_x_com_mean = mean(p_x_com_mat);
p_y_com_mean = mean(p_y_com_mat);
endtime_mean = mean(endtimes);

times = 0:1/sampling_freq:endtime_mean;
p_x_com = ppval(spline(linspace(0, endtime_mean, samples), p_x_com_mean), times);
p_y_com = ppval(spline(linspace(0, endtime_mean, samples), p_y_com_mean), times);

v_x_com = diff(p_x_com) * sampling_freq;
v_x_com(end+1) = v_x_com(end);

v_y_com = diff(p_y_com) * sampling_freq;
v_y_com(end+1) = v_y_com(end);

avg_traj.p_x_com = p_x_com';
avg_traj.v_x_com = v_x_com';
avg_traj.p_y_com = p_y_com';
avg_traj.v_y_com = v_y_com';
avg_traj.skel_mocap.sampling_freq = sampling_freq;
avg_traj.times = times';

end

