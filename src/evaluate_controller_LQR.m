function tot_norm = evaluate_controller_LQR(u_tmp, observed_u_set)
% takes in cell of feedback matrices K and avg_nominal_trajectory,
% evaluates how well K recreates the observed inputs for the successful
% trajectories used in training.

tot_norm = 0;
for t = 1:length(u_tmp)
    u = u_tmp{t};
    u_1 = [u(1); u(8)] - [u(4) u(5) u(6) u(7); u(11) u(12) u(13) u(14)] * [observed_u_set{t}(1, :) - u(2); observed_u_set{t}(2, :) - u(3); observed_u_set{t}(3, :) - u(9); observed_u_set{t}(4, :) - u(10)];
    
    u_diff = observed_u_set{t}(5:6, :) - u_1;
    idx = find(~any(isnan(u_diff)));
    tmp_norm = sum(sqrt(sum(u_diff(:, idx).^2)))/length(idx);

    tot_norm = tot_norm + tmp_norm;
end

end