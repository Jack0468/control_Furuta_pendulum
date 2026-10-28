%% Week 12 - Numerical validation of the observer-based controller
% Every test uses the NONLINEAR plant, quantised encoders, +/-10 V saturation and
% the discrete-time observer (furuta_sim_obs). Results map onto the requirements
% R1-R9 in docs/03 and the report's "Numerical Validations" section.
clear; clc; close all;
P = furuta_params();
D = furuta_design(P);
figdir = fullfile('..', 'figures'); if ~exist(figdir, 'dir'), mkdir(figdir); end
deg = @rad2deg;
% Realistic start: the observer is initialised from the first encoder reading
xh0 = @(x0) [P.enc_res*round(x0(1:2)/P.enc_res); 0; 0];
res = struct();

%% V1. Balance recovery from alpha0 = 10 deg (R1, R2, R5, R9)
x0 = [0; deg2rad(10); 0; 0];
S1 = furuta_sim_obs(P, D, x0, 4, struct('xhat0', xh0(x0)));
k = find(abs(S1.x(:,2)) > deg2rad(1), 1, 'last');
res.V1 = struct('t_alpha_1deg', S1.t(k+1), 'max_u', max(abs(S1.u)), 'max_theta', deg(max(abs(S1.x(:,1)))));
fprintf('V1 recovery 10 deg: |alpha|<1 deg after %.2f s, max|u| = %.2f V, max|theta| = %.1f deg\n', ...
        res.V1.t_alpha_1deg, res.V1.max_u, res.V1.max_theta);

%% V2. 30 deg arm step at t = 0.5 s (R3, R4, R5)
r0 = deg2rad(30); tstep = 0.5;
S2 = furuta_sim_obs(P, D, zeros(4,1), 4.5, struct('r', @(t) r0*(t >= tstep)));
m = S2.t >= tstep; tt = S2.t(m) - tstep; th = S2.x(m,1);
k = find(abs(th - r0) > 0.02*r0, 1, 'last');
t10 = tt(find(th >= 0.1*r0, 1)); t90 = tt(find(th >= 0.9*r0, 1));
res.V2 = struct('Ts', tt(k+1), 'tr', t90 - t10, 'OS', (max(th) - r0)/r0*100, ...
                'US', -min(th)/r0*100, 'max_u', max(abs(S2.u)));
fprintf('V2 30 deg step: Ts = %.2f s, tr = %.2f s, OS = %.1f %%, US = %.1f %%, max|u| = %.2f V\n', ...
        res.V2.Ts, res.V2.tr, res.V2.OS, res.V2.US, res.V2.max_u);

%% V3. Pendulum tap + constant arm drag, with and without integrator (R6, R7)
op3 = struct('tau_p', @(t) 0.02*(t >= 0.5 & t < 0.52), 'tau_d', @(t) 0.002*(t >= 2.5));
S3i = furuta_sim_obs(P, D, zeros(4,1), 6, op3);
op3.integrator = false;
S3p = furuta_sim_obs(P, D, zeros(4,1), 6, op3);
res.V3 = struct('max_alpha', deg(max(abs(S3i.x(:,2)))), 'theta_end_int', deg(S3i.x(end,1)), ...
                'theta_end_noint', deg(S3p.x(end,1)), 'max_u', max(abs(S3i.u)), 'max_theta', deg(max(abs(S3i.x(:,1)))));
fprintf('V3 tap + drag: max|alpha| = %.1f deg, max|theta| = %.1f deg, final theta: %.2f deg (integrator) vs %.1f deg (none), max|u| = %.2f V\n', ...
        res.V3.max_alpha, res.V3.max_theta, res.V3.theta_end_int, res.V3.theta_end_noint, res.V3.max_u);

%% V4. Encoder offset on the pendulum (datasheet position error, docs/08)
for b = [P.enc_pos_err_typ, P.enc_pos_err_max]
    Si = furuta_sim_obs(P, D, zeros(4,1), 8, struct('bias', [0; b]));
    Sp = furuta_sim_obs(P, D, zeros(4,1), 8, struct('bias', [0; b], 'integrator', false));
    fprintf('V4 alpha offset %.0f arcmin: final theta %.2f deg (integrator), %.1f deg (none); true alpha_end %.3f deg\n', ...
            deg(b)*60, deg(Si.x(end,1)), deg(Sp.x(end,1)), deg(Si.x(end,2)));
end

%% V5. Noise: quantisation + random torque disturbances
op5 = struct('torque_std', [2e-4; 5e-5]);
S5 = furuta_sim_obs(P, D, zeros(4,1), 6, op5);
w = S5.t >= 1;
res.V5 = struct('rms_u', rms(S5.u(w)), 'rms_alpha', deg(rms(S5.x(w,2))), 'rms_theta', deg(rms(S5.x(w,1))), ...
                'rms_e_alphadot', deg(rms(S5.e(w,4))));
fprintf('V5 noise: RMS u = %.3f V, RMS alpha = %.3f deg, RMS theta = %.2f deg, RMS alpha_dot error = %.2f deg/s\n', ...
        res.V5.rms_u, res.V5.rms_alpha, res.V5.rms_theta, res.V5.rms_e_alphadot);

%% V6. Monte Carlo parameter uncertainty (+/-20 %, uniform), nominal K and L
Nmc = 40; rng(7);
names = {'mp','Lp','Lr','Rm','km','Dr','Dp','Jr'};
x0 = [0; deg2rad(10); 0; 0];
% (a) recovery from 10 deg only; (b) the same plus the 20 mN.m tap at 2 s
upA = false(Nmc,1); upB = false(Nmc,1); mu = zeros(Nmc,1); t1 = nan(Nmc,1); amx = zeros(Nmc,1);
pole_lin = zeros(Nmc,1);
figure('Position', [100 100 800 450]); hold on;
for n = 1:Nmc
    Pk = P;
    for j = 1:numel(names), Pk.(names{j}) = P.(names{j})*(0.8 + 0.4*rand); end
    Pk.Jp = Pk.mp*Pk.Lp^2/12;
    SA = furuta_sim_obs(P, D, x0, 4, struct('Pplant', Pk, 'xhat0', xh0(x0), 'seed', n));
    SB = furuta_sim_obs(P, D, x0, 4, struct('Pplant', Pk, 'xhat0', xh0(x0), 'seed', n, ...
                        'tau_p', @(t) 0.02*(t >= 2 & t < 2.02)));
    up = @(S) abs(S.x(end,2)) < deg2rad(1) && max(abs(S.x(:,2))) < pi/2;   % did not fall
    upA(n) = up(SA); upB(n) = up(SB);
    mu(n) = max(abs(SA.u)); amx(n) = max(abs(SB.x(:,2)));
    k = find(abs(SA.x(:,2)) > deg2rad(1), 1, 'last');
    if isempty(k), t1(n) = 0; elseif k < numel(SA.t), t1(n) = SA.t(k+1); end   % NaN = never settled
    % linear check: true perturbed plant with the nominal controller + observer (sampled)
    [Ak, Bk, Ck] = furuta_linmodel(Pk); sk = c2d(ss(Ak, Bk, Ck, 0), D.Ts);
    Acl = [sk.A, -sk.B*D.Ki, -sk.B*D.Kx; D.Ts*[1 0 0 0], 1, zeros(1,4); ...
           D.L*Ck, -D.Bd*D.Ki, D.Ad - D.Bd*D.Kx - D.L*D.C];
    pole_lin(n) = max(abs(eig(Acl)));
    plot(SB.t, deg(SB.x(:,2)), 'Color', [0 0.45 0.74 0.35]);
end
grid on; xlabel('t [s]'); ylabel('\alpha [deg]'); ylim([-40 40]);
title(sprintf('Monte Carlo: %d plants with \\pm20%% parameters (tap at 2 s)', Nmc));
exportgraphics(gcf, fullfile(figdir, 'w12_monte_carlo.png'));
res.V6 = struct('N', Nmc, 'up_recovery', sum(upA), 'up_with_tap', sum(upB), 'lin_stable', sum(pole_lin < 1), ...
                'max_u', max(mu), 'n_sat', sum(mu >= P.Vmax), 't1_worst', max(t1), 'n_unsettled', sum(isnan(t1)), ...
                'alpha_max_median', deg(median(amx)), 'alpha_max_worst', deg(max(amx)));
fprintf(['V6 Monte Carlo (%d plants): linear loop stable %d, upright after 10 deg recovery %d, ' ...
         'upright with tap %d; recovery max|u| worst %.2f V (%d saturated), worst t(|alpha|<1) %.2f s, %d not settled in 4 s; ' ...
         'tap max|alpha| median %.1f / worst %.1f deg\n'], Nmc, res.V6.lin_stable, res.V6.up_recovery, ...
        res.V6.up_with_tap, res.V6.max_u, res.V6.n_sat, res.V6.t1_worst, res.V6.n_unsettled, res.V6.alpha_max_median, res.V6.alpha_max_worst);

%% V7. Region of attraction and anti-windup (observer + saturation)
fprintf('V7 largest recoverable alpha0:');
for aw = [true false]
    amax = 0;
    for a0 = 10:2:40
        x0 = [0; deg2rad(a0); 0; 0];
        Sa = furuta_sim_obs(P, D, x0, 3, struct('xhat0', xh0(x0), 'antiwindup', aw));
        if abs(Sa.x(end,2)) < deg2rad(1) && max(abs(Sa.x(:,2))) < pi/2, amax = a0; else, break; end
    end
    fprintf('  %d deg (anti-windup %s)', amax, mat2str(aw));
end
fprintf('\n');

%% Figure: V1-V3 overview
figure('Position', [100 100 950 700]);
T = {S1, '\alpha_0 = 10^\circ'; S2, '30^\circ arm step'; S3i, 'tap 0.5 s + drag 2.5 s'};
for i = 1:3
    S = T{i,1};
    subplot(3,3,i);   plot(S.t, deg(S.x(:,1)), S.t, deg(S.xhat(:,1)), '--'); grid on; ylabel('\theta [deg]'); title(T{i,2});
    subplot(3,3,3+i); plot(S.t, deg(S.x(:,2)), S.t, deg(S.xhat(:,2)), '--'); grid on; ylabel('\alpha [deg]');
    subplot(3,3,6+i); plot(S.t, S.u); grid on; ylabel('V_m [V]'); xlabel('t [s]'); yline([P.Vmax -P.Vmax], 'r--');
end
subplot(3,3,1); legend('true', 'estimate');
exportgraphics(gcf, fullfile(figdir, 'w12_validation_overview.png'));

figure; plot(S3p.t, deg(S3p.x(:,1)), S3i.t, deg(S3i.x(:,1))); grid on;
xlabel('t [s]'); ylabel('\theta [deg]'); legend('no integrator', 'with integrator');
title('Arm angle: pendulum tap at 0.5 s, 2 mN\cdotm drag from 2.5 s');
exportgraphics(gcf, fullfile(figdir, 'w12_integrator_drag.png'));

save(fullfile(figdir, 'w12_results.mat'), 'res');
