function [ ] = create_dynamics( subject )
% CREATE_DYNAMICS creates TIPM equations of motion
%
%   CREATE_DYNAMICS(subject) uses the subject specific mass and saves the
%   EOM as matfiles to be called by CORA later on.

t = sym('t', 'real');
x = sym('x', [4 1], 'real');
u = sym('u', [2 1], 'real');

load(sprintf('STS_trajectories/subject%s/subject%s_trajectories_N.mat', subject, subject), 'subject_mass');

m = subject_mass;
g = 9.81;
j1 = 0;
%% Definitions
% Generalized coordinates
rx = x(1);
ry = x(3);
vx = x(2);
vy = x(4);
q    = [rx ry];
% Generalized speeds
dqdt = [vx vy];

%% DYNAMICS (obtained via the Euler-Lagrange equation)
 
% CoG-positions (from kinematics):
CoG = [rx;
      ry];
 
% CoG-velocities (computed via jacobians):
d_CoG = jacobian(CoG, q)*dqdt.';
 
% Potential Energy (due to gravity):
V = CoG(2)*m*g;
V = simplify(V);
 
dtheta_1 = (vx*ry - rx*vy)/(rx^2 + ry^2); 
% Kinetic Energy:         
% T = 0.5 * (m * sum(d_CoG.^2) +...
%            j1 * dtheta_1^2);
%just assume rotational KE is zero (ie, j1 will be zero)
% Kinetic Energy
T = 0.5 * (m * sum(d_CoG.^2) +...
           0 * j1 * dtheta_1^2);
T = simplify(T);
 
% Lagrangian:
L = T-V;
% Partial derivatives:
dLdq   = jacobian(L,q).';
dLdqdt = jacobian(L,dqdt).';
      
% Compute Mass Matrix:
M = jacobian(dLdqdt,dqdt);
M = simplify(M);
invM = inv(M);
 
% Compute the coriolis and gravitational forces:
dL_dqdt_dt = jacobian(dLdqdt,q)*dqdt.';
f_cg = dLdq - dL_dqdt_dt;
f_cg = simplify(f_cg);
 
% The equations of motion are given with these functions as:   
% M * dqddt = f_cg(q, dqdt) + u;

%% create necessary folders ---------------------------
if ~exist('dynamics_functions', 'dir')
    mkdir('dynamics_functions');
end
%% create closed loop LQR dynamics ---------------------------
u = sym('u', [14, 1], 'real');

u_1 = [u(1); u(8)] - [u(4) u(5) u(6) u(7); u(11) u(12) u(13) u(14)] * [x(1) - u(2); x(2) - u(3); x(3) - u(9); x(4) - u(10)];
dx(1,1) = x(2);
dx(3,1) = x(4);
mydynamics = invM*f_cg + invM*u_1;
dx(2,1) = mydynamics(1);
dx(4,1) = mydynamics(2);

matlabFunction(dx, 'File', sprintf('dynamics_functions/dyn_subject%s_TIPM_LQR', subject), 'vars', {t, x, u});
matlabFunction(-dx, 'File', sprintf('dynamics_functions/dyn_subject%s_TIPM_LQR_backwards', subject), 'vars', {t, x, u});

%% create FF + FB system with single set of gains--------------------------
u = sym('u', [10, 1], 'real');

u_1 = [u(5); u(10)] + [u(1) u(2) u(3) u(4); u(6) u(7) u(8) u(9)] * [x(1); x(2); x(3); x(4)];
dx(1,1) = x(2);
dx(3,1) = x(4);
mydynamics = invM*f_cg + invM*u_1;
dx(2,1) = mydynamics(1);
dx(4,1) = mydynamics(2);

dx = simplify(dx);

matlabFunction(dx, 'File', sprintf('dynamics_functions/dyn_subject%s_TIPM_FFFB', subject), 'vars', {t, x, u});
matlabFunction(-dx, 'File', sprintf('dynamics_functions/dyn_subject%s_TIPM_FFFB_backwards', subject), 'vars', {t, x, u});

%% now create uncertain input system-------------------------
u = sym('u', [14, 1], 'real');
scale1 = (u(6) - u(7))/2;
mean1 = ([u(2); u(3); u(4); u(5); u(6)]'*[x(1); x(2); x(3); x(4); 1] + [u(2); u(3); u(4); u(5); u(7)]'*[x(1); x(2); x(3); x(4); 1])/2;
scale2 = (u(13) - u(14))/2;
mean2 = ([u(9); u(10); u(11); u(12); u(13)]'*[x(1); x(2); x(3); x(4); 1] + [u(9); u(10); u(11); u(12); u(14)]'*[x(1); x(2); x(3); x(4); 1])/2;
u_1 = [scale1*u(1) + mean1; scale2*u(8) + mean2];
dx(1,1) = x(2);
dx(3,1) = x(4);
mydynamics = invM*f_cg + invM*u_1;
dx(2,1) = mydynamics(1);
dx(4,1) = mydynamics(2);

dx = simplify(dx);

matlabFunction(dx, 'File', sprintf('dynamics_functions/dyn_subject%s_TIPM_InputBounds', subject), 'vars', {t, x, u});
matlabFunction(-dx, 'File', sprintf('dynamics_functions/dyn_subject%s_TIPM_InputBounds_backwards', subject), 'vars', {t, x, u});

end

