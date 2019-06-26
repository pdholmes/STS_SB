function L = compute_controller_LQR_gains(A,B,Q,R,t)
% COMPUTE_CONTROLLER_LQR_GAINS
%
%   COMPUTE_CONTROLLER_LQR_GAINS(A,B,Q,R,t) gives the LQR gains for an LTV
%   system specified by cell A{t}, B, with weighting matrices Q and R, and time
%   vector t.

% first, solve for S(t) using Heun's method
S=cell(length(t),1); L=cell(length(t),1);
S{1}=Q;
dt = t(2) - t(1);
%
for i=1:length(t)-1
    %initial prediction P_intermed made with Euler's method (not very
    %accurate)
    S_intermed=S{i}+dt*S_dot(A{i},B,Q,R,S{i});
    %final approximation of P{i+1} is achieved by using an average of the
    %two slopes from P_i and P_intermed
    S{i+1}=S{i}+dt/2*(S_dot(A{i},B,Q,R,S{i})+...
        S_dot(A{i},B,Q,R,S_intermed));
    %Now determine K{i}
    L{i}=inv(R)*B'*S{i};
end
%K{end} isn't defined in the loop (only goes to length(t)-1)
L{end}=inv(R)*B'*S{end};

    function F = S_dot(A,B,Q,R,S)

        F = -(-A'*S-S*A+S*B*inv(R)*B'*S-Q);
        
    end
end