function dx = furuta_nl(x, Vm, P, tau_d, tau_p)
%FURUTA_NL Full nonlinear Furuta pendulum dynamics (truth model).
%   x = [theta; alpha; theta_dot; alpha_dot], alpha = 0 upright.
%   Vm    : motor voltage [V] (saturate before calling if required)
%   tau_d : disturbance torque on the arm      [N.m] (optional)
%   tau_p : disturbance torque on the pendulum [N.m] (optional)

if nargin < 4, tau_d = 0; end
if nargin < 5, tau_p = 0; end

al = x(2); thd = x(3); ald = x(4);
s = sin(al); co = cos(al);

tau = P.km*(Vm - P.km*thd)/P.Rm;          % motor torque

M = [P.Jr + P.mp*P.Lr^2 + 0.25*P.mp*P.Lp^2*s^2,  -0.5*P.mp*P.Lp*P.Lr*co;
     -0.5*P.mp*P.Lp*P.Lr*co,                      P.Jp + 0.25*P.mp*P.Lp^2];

f = [tau - P.Dr*thd - 0.5*P.mp*P.Lp^2*s*co*thd*ald - 0.5*P.mp*P.Lp*P.Lr*s*ald^2 + tau_d;
     -P.Dp*ald + 0.25*P.mp*P.Lp^2*co*s*thd^2 + 0.5*P.mp*P.g*P.Lp*s + tau_p];

dx = [thd; ald; M\f];
end
