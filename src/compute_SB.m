function [ ] = compute_SB(subject, nominal_sts_type, options)
% COMPUTE_SB generates SB for a given subject, nominal_sts_type, and
% basintype
%
%   COMPUTE_SB(subject, nominal_sts_type, options) uses CORA to generate
%   an SB for a given subject, nominal sts type, and controller type
%   specified in options.basintype. It does so by first generating the
%   standing set, then using CORA to find the backwards reachable set of
%   the standing set under the controller model and dynamics.

% if "naive" method used, no reachability analysis is done.
if strcmp(options.basintype, 'naive')
    compute_SB_direct(subject, nominal_sts_type, options);
    return;
end

% initialize standing set
standing_set = initialize_standingSet(subject, nominal_sts_type, options);

%set additional reachability options --------------------------------------
dim = 4;
options.taylorTerms=4; %number of taylor terms for reachable sets
options.zonotopeOrder=200; %zonotope order
options.reductionTechnique='girard';
options.reductionInterval = 1e3;
options.maxError = 1*ones(dim,1);
options.advancedLinErrorComp = 0;
options.tensorOrder = 2;
options.verbose = 0;
options.R0 = standing_set;
times_vec = options.times_vec;

%load the specified controller
controller = load(sprintf('controller_models/subject%s/subject%s_%s_controller_%s', subject, subject, nominal_sts_type, options.basintype));
options.uTransVec = zeros(controller.nInput, length(controller.u_x));
u_zonoMat = zeros(controller.nInput, controller.nInput+1);
switch options.basintype
    case 'BFFFB'
        for i = 1:length(times_vec)
            options.uTransVec(:, i) = [0; controller.u_x{i}; 0; controller.u_y{i}];
        end
        % let u_1 and u_8 be uncertain between [-1, 1]...
        % u_2 thru u_7 and u_9 thru u_14 are the parameters of the bounds.
        % the appropriate scaling of u_1 and u_7 is handled in the dynamics functions.
        u_zonoMat(1, 2) = 1;
        u_zonoMat(8, 9) = 1;
    case {'LQR', 'FFFB'}
        for i = 1:length(times_vec)
            options.uTransVec(:, i) = [controller.u_x{i}; controller.u_y{i}];
        end
    otherwise
        error('Unrecognized basin type.')
end
options.uTransVec = fliplr(options.uTransVec); % flip uTransVec for going backwards
options.U = zonotope(u_zonoMat);

%specify the dynamics
dyn_file = str2func(sprintf('dyn_subject%s_TIPM_%s_backwards', subject, options.basintype));
SBsystem = nonlinearSys(dim,controller.nInput,dyn_file,options);
%--------------------------------------------------------------------------

%compute reachable set using zonotopes
tic
Rcont = reach(SBsystem, options);
tComp = toc;
% disp(['computation time of reachable set: ',num2str(tComp)]);

%save
if ~exist(sprintf('stability_basins/subject%s', subject), 'dir')
    mkdir(sprintf('stability_basins/subject%s', subject));
end

if options.saveon
    save(sprintf('stability_basins/subject%s/subject%s_%s_basin_%s', subject, subject, nominal_sts_type, options.basintype), 'Rcont', 'options', 'SBsystem');
end


end

