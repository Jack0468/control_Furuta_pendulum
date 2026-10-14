function [t, x, u] = furuta_sim_cl(K, P, x0, r, tend, opts)
%FURUTA_SIM_CL Closed-loop simulation of the NONLINEAR plant with state feedback
%   u = sat( -K*(x - [r(t);0;0;0]) )
%   r     : function handle r(t) for the arm reference [rad]
%   opts  : struct with optional fields
%           .sat   (true)  apply +/-P.Vmax saturation
%           .tau_d (@(t)0) arm disturbance torque  [N.m]
%           .tau_p (@(t)0) pendulum disturbance torque [N.m]
if nargin < 6, opts = struct; end
if ~isfield(opts, 'sat'),   opts.sat = true; end
if ~isfield(opts, 'tau_d'), opts.tau_d = @(t) 0; end
if ~isfield(opts, 'tau_p'), opts.tau_p = @(t) 0; end

ctrl = @(t, x) sat_u(-K*(x - [r(t); 0; 0; 0]), P.Vmax, opts.sat);
f = @(t, x) furuta_nl(x, ctrl(t, x), P, opts.tau_d(t), opts.tau_p(t));
odeopt = odeset('RelTol', 1e-6, 'AbsTol', 1e-8, 'MaxStep', 1e-3);
[t, x] = ode45(f, [0 tend], x0, odeopt);
u = zeros(size(t));
for k = 1:numel(t), u(k) = ctrl(t(k), x(k,:).'); end
end

function u = sat_u(u, umax, on)
if on, u = min(max(u, -umax), umax); end
end
