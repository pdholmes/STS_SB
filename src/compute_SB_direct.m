function [ ] = compute_SB_direct(subject, nominal_sts_type, options)
% COMPUTE_SB_DIRECT
%
%   COMPUTE_SB_DIRECT(subject, nominal_sts_type, options) computes the SB
%   using the "direct" or "naive" method. This means that we take all of
%   the successful trials for a given subject and nominal sts type (except
%   for a left out trial) and form an SB by generating a zonotope with four
%   generators that encompasses all observed successful states at each
%   instance in time. This is the same procedure used to generate the
%   standing set, but applied to all time steps.

enlargeBy = 1.05;

load(sprintf('STS_trajectories/subject%s/subject%s_trajectories_%s.mat', subject, subject, nominal_sts_type));
if isfield(options, 'leaveoneout_sts_type')
    idxs = find(strcmp(traj_metadata.classification, 'success') & ~strcmp(traj_metadata.sts_type, options.leaveoneout_sts_type));
else
    idxs = find(strcmp(traj_metadata.classification, 'success'));
end

times_vec = 1 - (options.times_vec(2:end));

%initialize zonotopes -----------------------------------------------------
Rcont = {};
for i = 1:length(times_vec)
	Rcont{i} = {};
end

%iterate through time steps, create zonotopes -----------------------------
for t = 1:length(times_vec)
    trajpts = zeros(4, length(idxs));
    tau = times_vec(t); %current percent of motion
    for i = 1:length(idxs)
        mytraj = traj{idxs(i)};
        myT = mytraj.times(end);
        [~, myidx] = min(abs(mytraj.times/myT - tau));
        mytrajpts = [mytraj.p_x_com(myidx); myT*mytraj.v_x_com(myidx); mytraj.p_y_com(myidx); myT*mytraj.v_y_com(myidx)];
        trajpts(:, i) = mytrajpts;
    end
    
    ch = convhulln(trajpts');
    vert = vertices(trajpts(:, ch));
    zono = zonotope(vert);
    zono = enlarge(zono, enlargeBy);
    Rcont{t}{1} = zono;
end

%also create standing set
options.R0 = initialize_standingSet(subject, nominal_sts_type, options);

%save
if ~exist(sprintf('stability_basins/subject%s', subject), 'dir')
    mkdir(sprintf('stability_basins/subject%s', subject));
end

save(sprintf('stability_basins/subject%s/subject%s_%s_basin_%s', subject, subject, nominal_sts_type, options.basintype), 'Rcont', 'options');

end