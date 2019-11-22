function [ ] = run_subject(subject)
% RUN_SUBJECT Run the SB pipeline for a single subject
%
%   RUN_SUBJECT('subject') will evaluate the SB results for each nominal
%   sts type and each controller type.

% create subject-specific TIPM dynamics:
create_dynamics(subject);

% Evaluate the SBs for each subject, STS strategy, and basin type:

% for Input Bounds controller:
evaluate_SB(subject, 'MT', 'InputBounds');
evaluate_SB(subject, 'N',  'InputBounds');
evaluate_SB(subject, 'QS',  'InputBounds');

%for LQR controller:
evaluate_SB(subject, 'MT', 'LQR');
evaluate_SB(subject, 'N',  'LQR');
evaluate_SB(subject, 'QS',  'LQR');

%for FF+FB controller:
evaluate_SB(subject, 'MT', 'FFFB');
evaluate_SB(subject, 'N',  'FFFB');
evaluate_SB(subject, 'QS',  'FFFB');

% for 'naive' method:
evaluate_SB(subject, 'MT', 'naive');
evaluate_SB(subject, 'N',  'naive');
evaluate_SB(subject, 'QS',  'naive');

end

