function dx = dyn_subject10_TIPM_FFFB(t,in2,in3)
%DYN_SUBJECT10_TIPM_FFFB
%    DX = DYN_SUBJECT10_TIPM_FFFB(T,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 8.2.
%    25-Jun-2019 23:02:28

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
x1 = in2(1,:);
x2 = in2(2,:);
x3 = in2(3,:);
x4 = in2(4,:);
dx = [x2;u5.*(5.0./3.26e2)+u1.*x1.*(5.0./3.26e2)+u2.*x2.*(5.0./3.26e2)+u3.*x3.*(5.0./3.26e2)+u4.*x4.*(5.0./3.26e2);x4;u10.*(5.0./3.26e2)+u6.*x1.*(5.0./3.26e2)+u7.*x2.*(5.0./3.26e2)+u8.*x3.*(5.0./3.26e2)+u9.*x4.*(5.0./3.26e2)-9.81e2./1.0e2];
