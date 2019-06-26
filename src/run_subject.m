function [ ] = run_subject(subject)
% RUN_SUBJECT Run the SB pipeline for a single subject
%
%   RUN_SUBJECT('subject') will evaluate the SB results for each nominal
%   sts type and each controller type.

% create subject-specific TIPM dynamics:
create_dynamics(subject);

% Evaluate the SBs for each subject, STS strategy, and basin type:

% for BFF+FB controller:
evaluate_SB(subject, 'MT', 'BFFFB');
evaluate_SB(subject, 'N',  'BFFFB');
evaluate_SB(subject, 'QS',  'BFFFB');

%for LQR controller:
evaluate_SB(subject, 'MT', 'LQR');
evaluate_SB(subject, 'N',  'LQR');
evaluate_SB(subject, 'QS',  'LQR');

%for FF+FB controller:
evaluate_SB(subject, 'MT', 'FFFB');
evaluate_SB(subject, 'N',  'FFFB');
evaluate_SB(subject, 'QS',  'FFFB');

% for 'direct' method:
evaluate_SB(subject, 'MT', 'direct');
evaluate_SB(subject, 'N',  'direct');
evaluate_SB(subject, 'QS',  'direct');

end

