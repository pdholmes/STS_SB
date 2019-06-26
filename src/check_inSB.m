function [inSB] = check_inSB(mytraj, SB, times_vec)
% CHECK_INSB
%
%   [inSB] = CHECK_INSB(mytraj, SB, times_vec) checks whether the
%   trajectory given by 'mytraj' remains within 'SB' at all times specified
%   by 'times_vec'. It returns the struct inSB with the results of this
%   check.

myT = mytraj.times(end);

start_idx = max([0, mytraj.first_pert_idx]);
start_percent = start_idx/length(mytraj.times);
end_idx = min([length(mytraj.times), mytraj.step_idx, mytraj.sit_idx]);
end_percent = end_idx/length(mytraj.times);

traj_idxs = zeros(1, length(times_vec));
for t = 1:length(times_vec)
   [~, traj_idxs(t)] = min(abs(mytraj.times/myT - times_vec(t))); 
end

traj_pts = [mytraj.p_x_com(traj_idxs), myT*mytraj.v_x_com(traj_idxs), mytraj.p_y_com(traj_idxs), myT*mytraj.v_y_com(traj_idxs)]';
check_idxs = find(times_vec >= start_percent & times_vec <= end_percent);

lambdas = zeros(length(check_idxs), 1);
for i = 1:length(check_idxs)
    [lambdas(i), ~] = check_inZonotope(SB.Rcont{check_idxs(i)}{1}, traj_pts(:, check_idxs(i)));
end

inSB = struct();
[inSB.max_lambda, max_lambda_idx] = max(lambdas);
inSB.max_lambda_percent = times_vec(check_idxs(max_lambda_idx));
if inSB.max_lambda > 1
    inSB.prediction = 'fail';
else
    inSB.prediction = 'success';
end

firstexit_idx = find(lambdas > 1, 1, 'last');
if isempty(firstexit_idx)
    inSB.firstexit_lambda = nan;
    inSB.firstexit_percent = nan;
else
    inSB.firstexit_lambda = lambdas(firstexit_idx);
    inSB.firstexit_percent = times_vec(check_idxs(firstexit_idx));
end

end