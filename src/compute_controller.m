function [ ] = compute_controller( subject, nominal_sts_type, options )
% COMPUTE_CONTROLLER computes and saves controller of specified type
%
% COMPUTE_CONTROLLER(subject, nominal_sts_type, options) computes a
% controller for the specified subject and nominal_sts_type, where the type
% of the controller is specified in the options struct as
% options.basintype

switch options.basintype
    case 'BFFFB'
        compute_controller_BFFFB(subject, nominal_sts_type, options);
    case 'LQR'
        compute_controller_LQR(subject, nominal_sts_type, options);
    case 'FFFB'
        compute_controller_FFFB(subject, nominal_sts_type, options);
    case 'direct'
        % no controller is necessary for 'direct' basin type.
        return
    otherwise
        error('Unrecognized basin type');
end

end

