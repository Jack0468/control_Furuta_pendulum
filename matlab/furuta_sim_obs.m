function S = furuta_sim_obs(P, D, x0, tend, opts)
%FURUTA_SIM_OBS Sampled-data simulation: nonlinear plant + encoders + observer + controller.
%   The controller runs at D.Ts (1 kHz). Between samples the voltage is held constant
%   (zero-order hold) and the nonlinear plant furuta_nl is integrated with fixed-step RK4.
%
%   Each sample k:
%     1. Encoders read y = quantise(C*x + bias + white noise)        (doc 08)
%     2. Controller  u = sat(-Kx*xhat - Ki*xi)   (no integrator: -K*(xhat - [r;0;0;0]))
%     3. Integrator  xi += Ts*(y_theta - r)   (frozen while saturated if antiwindup)
%     4. Observer    xhat += predictor update with the SATURATED u
%     5. Plant       integrate furuta_nl over one sample with u held
%
%   opts fields (all optional):
%     r(t), tau_d(t), tau_p(t)  reference [rad] and disturbance torques [N.m]
%     quant        (true)   quantise to P.enc_res
%     bias         ([0;0])  constant encoder offset [rad] on [theta; alpha]
%     white_std    ([0;0])  extra white measurement noise std [rad]
%     torque_std   ([0;0])  white torque noise std on [arm; pendulum] [N.m], held per sample
%     integrator   (true)   use Ki (false: pure state feedback D.K)
%     antiwindup   (true)   conditional integration while saturated
%     sat          (true)   +/-P.Vmax limit
%     xhat0        (zeros)  initial observer state
%     Pplant       (P)      plant parameters (for uncertainty tests)
%     L            (D.L)    observer gain override (e.g. Kalman gain)
%     full_state   (false)  feed back the TRUE state (no observer), for comparison
%     seed         (1)      random seed
%     nsub         (4)      RK4 sub-steps per sample

if nargin < 5, opts = struct; end
def = struct('r', @(t) 0, 'tau_d', @(t) 0, 'tau_p', @(t) 0, 'quant', true, ...
             'bias', [0;0], 'white_std', [0;0], 'torque_std', [0;0], ...
             'integrator', true, 'antiwindup', true, 'sat', true, ...
             'xhat0', zeros(4,1), 'Pplant', P, 'L', D.L, 'full_state', false, ...
             'seed', 1, 'nsub', 4);
fn = fieldnames(def);
for i = 1:numel(fn)
    if ~isfield(opts, fn{i}), opts.(fn{i}) = def.(fn{i}); end
end
rng(opts.seed);

Ts = D.Ts; N = round(tend/Ts); h = Ts/opts.nsub;
C = D.C; L = opts.L; Pp = opts.Pplant; q = P.enc_res;
if opts.integrator, Kx = D.Kx; Ki = D.Ki; else, Kx = D.K; Ki = 0; end

S.t = (0:N-1).'*Ts;
S.x = zeros(N, 4); S.xhat = zeros(N, 4); S.y = zeros(N, 2);
S.u = zeros(N, 1); S.u_unsat = zeros(N, 1); S.xi = zeros(N, 1);

x = x0(:); xh = opts.xhat0(:); xi = 0;
for k = 1:N
    tk = S.t(k); rk = opts.r(tk);
    % 1. measurement
    ym = C*x + opts.bias(:) + opts.white_std(:).*randn(2,1);
    if opts.quant, ym = q*round(ym/q); end
    % 2. control law (from the estimate, or the true state for comparison)
    if opts.full_state, xc = x; else, xc = xh; end
    if opts.integrator
        % type-1 servo: the reference enters ONLY through the integrator (docs/04 section 3)
        uc = -Kx*xc - Ki*xi;
    else
        uc = -Kx*(xc - [rk; 0; 0; 0]);
    end
    if opts.sat, us = min(max(uc, -P.Vmax), P.Vmax); else, us = uc; end
    % store
    S.x(k,:) = x.'; S.xhat(k,:) = xh.'; S.y(k,:) = ym.';
    S.u(k) = us; S.u_unsat(k) = uc; S.xi(k) = xi;
    % 3. integrator (conditional integration = anti-windup)
    if ~(opts.antiwindup && us ~= uc)
        xi = xi + Ts*(ym(1) - rk);
    end
    % 4. observer, predictor form, driven by the applied (saturated) voltage
    xh = D.Ad*xh + D.Bd*us + L*(ym - C*xh);
    % 5. plant over one sample, voltage held (ZOH), torque noise held
    wn = opts.torque_std(:).*randn(2,1);
    for j = 1:opts.nsub
        tj = tk + (j-1)*h;
        f = @(tt, xx) furuta_nl(xx, us, Pp, opts.tau_d(tt) + wn(1), opts.tau_p(tt) + wn(2));
        k1 = f(tj, x);
        k2 = f(tj + h/2, x + h/2*k1);
        k3 = f(tj + h/2, x + h/2*k2);
        k4 = f(tj + h,   x + h*k3);
        x = x + h/6*(k1 + 2*k2 + 2*k3 + k4);
    end
end
S.e = S.x - S.xhat;                      % estimation error
end
