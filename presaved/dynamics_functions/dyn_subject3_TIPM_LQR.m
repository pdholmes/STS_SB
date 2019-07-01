function dx = dyn_subject3_TIPM_LQR(t,in2,in3)
%DYN_SUBJECT3_TIPM_LQR
%    DX = DYN_SUBJECT3_TIPM_LQR(T,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 8.2.
%    25-Jun-2019 22:36:22

u1 = in3(1,:);
u2 = in3(2,:);
u3 = in3(3,:);
u4 = in3(4,:);
u5 = in3(5,:);
u6 = in3(6,:);
u7 = in3(7,:);
u8 = in3(8,:);
u9 = in3(9,:);
u10 = in3(10,:);
u11 = in3(11,:);
u12 = in3(12,:);
u13 = in3(13,:);
u14 = in3(14,:);
x1 = in2(1,:);
x2 = in2(2,:);
x3 = in2(3,:);
x4 = in2(4,:);
t2 = u2-x1;
t3 = u3-x2;
t4 = u9-x3;
t5 = u10-x4;
dx = [x2;u1.*1.750577690637911e-2+t2.*u4.*1.750577690637911e-2+t3.*u5.*1.750577690637911e-2+t4.*u6.*1.750577690637911e-2+t5.*u7.*1.750577690637911e-2;x4;u8.*1.750577690637911e-2+t2.*u11.*1.750577690637911e-2+t3.*u12.*1.750577690637911e-2+t4.*u13.*1.750577690637911e-2+t5.*u14.*1.750577690637911e-2-9.81e2./1.0e2];
