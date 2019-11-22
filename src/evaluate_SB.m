function [ ] = evaluate_SB( varargin )
% EVALUATE_SB generates the SB results for a specific subject, nominal sts
% type, and controller type
%
%   EVALUATE_SB(subject, nominal_sts_type) generates results for the Input Bounds
%   controller
%
%   EVALUATE_SB(subject, nominal_sts_type, basintype) generates results for
%   the controller specified by 'basintype'. Options are:
%   'InputBounds','FFFB','LQR','naive'.

% This will run through all of the trials for each strategy type and for
% each subject.
% 
% Here's a brief summary of what happens in this function:
% iterate through the successful trials to be left out
% run leave one out input computation
% compute the stability basin for those inputs
% then checks whether left out trial is in SB or not
% once all successful trials have been checked in this way, build a single
%   SB using all successful trials.
% then check each trial where failure was observed against this SB.

%BEGIN CODE ---------------------------------------------------------------
SBruntime = tic;
addpath(genpath('dynamics_functions'));
switch nargin
    case 2
        subject = varargin{1};
        nominal_sts_type = varargin{2};
        % if no basin type specified, default is Input Bounds
        basintype = 'InputBounds';
        disp('Using Input Bounds basin type by default. To test another basin type, specify third argument')
    case 3
        subject = varargin{1};
        nominal_sts_type = varargin{2};
        basintype = varargin{3};
    otherwise
        error('Expected 2 or 3 inputs.');
end

%set options --------------------------------------------------------------
options = struct();
options.tStart = 0;
options.tFinal = 1;
options.timeStep = 0.005;
options.times_vec = options.tStart:options.timeStep:options.tFinal;
options.leaveoneout = true; % use leave one out procedure to check successes
options.basintype = basintype;
options.saveon = 1;

% this just makes a table with the correct fields:
initialize_predictionResults(subject, nominal_sts_type, options);

%iterate through left out trials, then form single SB ---------------------
if options.leaveoneout
    load(sprintf('STS_trajectories/subject%s/subject%s_trajectories_%s.mat', subject, subject, nominal_sts_type));
    idxs = find(strcmp(traj_metadata.classification, 'success'));
    for i = 1:length(idxs)
        options.leaveoneout_index = idxs(i);
        options.leaveoneout_sts_type = traj_metadata.sts_type{idxs(i)};
        
        compute_controller(subject, nominal_sts_type, options);
        compute_SB(subject, nominal_sts_type, options);
        check_predictions(subject, nominal_sts_type, options);
    end
    
    % now, use all successful trials to build basin for checking failed
    % trials.
    options.leaveoneout_index = 0;
    options.leaveoneout_sts_type = '';
    
    compute_controller(subject, nominal_sts_type, options);
    compute_SB(subject, nominal_sts_type, options);
    check_predictions(subject, nominal_sts_type, options);
else
    compute_controller(subject, nominal_sts_type, options);
    compute_SB(subject, nominal_sts_type, options);
    check_predictions(subject, nominal_sts_type, options);
end

SBrunend = toc(SBruntime);
disp('Total evaluate_SB run time: ');
disp(SBrunend)
end