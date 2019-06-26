function [standing_set] = initialize_standingSet(subject, nominal_sts_type, ~)
% INITIALIZE_STANDINGSET
%
%   INITIALIZE_STANDINGSET(subject, nominal_sts_type, ~) generates the
%   standing set for a given subject and nominal sts type. It does so by
%   getting the convex hull of all states observed to correspond to
%   successful standing, and encompassing them with a zonotope with four
%   generators. Then, each generator is expanded by 5% to avoid states
%   lying on the edge of the set.

enlargeBy = 1.05;

load(sprintf('STS_trajectories/subject%s/subject%s_trajectories_%s.mat', subject, subject, nominal_sts_type));
idxs = find(strcmp(traj_metadata.classification, 'success'));

finalpoints = zeros(length(idxs), 4);
for i = 1:length(idxs)
    mytraj = traj{idxs(i)};
    finalpoints(i, :) = [mytraj.p_x_com(end), mytraj.times(end)*mytraj.v_x_com(end), mytraj.p_y_com(end), mytraj.times(end)*mytraj.v_y_com(end)];
end

ch = convhulln(finalpoints);
vert = vertices(finalpoints(ch, :)');
zono = zonotope(vert);
standing_set = enlarge(zono, enlargeBy);

end

