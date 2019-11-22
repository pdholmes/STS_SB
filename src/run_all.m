function [ ] = run_all( run_type )
% RUN_ALL Run the whole stability basin pipeline
%
%   RUN_ALL('parallel') will use MATLAB's parfor toolbox to iterate through
%   the subjects.

subjects = 1:11;
if exist('run_type', 'var') && strcmp(run_type, 'parallel')
    parfor i = subjects
        run_subject(num2str(i));
    end
else
    for i = subjects
        run_subject(num2str(i));
    end
end

% finally, build the results tables for each controller type
build_table_results('InputBounds');
build_table_results('LQR');
build_table_results('FFFB');
build_table_results('naive');

end

