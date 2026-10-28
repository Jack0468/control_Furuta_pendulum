%% Week 11 - Furuta pendulum: observer design and observer-based state feedback
% Designs a discrete-time Luenberger observer for the unmeasured velocities,
% verifies the separation principle, and tests observer-based feedback on the
% nonlinear plant with real encoder quantisation (docs/08, docs/04 section 4).
clear; clc; close all;
P = furuta_params();
D = furuta_design(P);                      % controller (D2 + integrator) and default observer
figdir = fullfile('..', 'figures'); if ~exist(figdir, 'dir'), mkdir(figdir); end
A = D.A; B = D.B; C = D.C; Ts = D.Ts;

%% 1. Observer design and checks
fprintf('Observability rank (A,C): %d of 4\n', rank(obsv(A, C)));
fprintf('Controller poles (cont.): %s\n', mat2str(D.p_int, 3));
fprintf('Observer poles   (cont.): %s\n', mat2str(D.p_obs, 3));
fprintf('Kx = %s, Ki = %.3f\n', mat2str(D.Kx, 4), D.Ki);
fprintf('L =\n'); disp(D.L);
z_obs = eig(D.Ad - D.L*C);
fprintf('eig(Ad - L*C) mapped back to s = log(z)/Ts: %s\n', mat2str(sort(log(z_obs)/Ts).', 4));

% Separation principle on the linear sampled-data loop: states [x; xi; xhat]
Kx = D.Kx; Ki = D.Ki; Ad = D.Ad; Bd = D.Bd; L = D.L; Ct = [1 0 0 0];
Acl = [Ad,              -Bd*Ki,  -Bd*Kx;
       Ts*Ct,            1,       zeros(1,4);
       L*C,             -Bd*Ki,   Ad - Bd*Kx - L*C];
Aad = [Ad zeros(4,1); Ts*Ct 1]; Bad = [Bd; 0];
z_ctrl = eig(Aad - Bad*[Kx Ki]);
z_all = eig(Acl); z_sep = [z_ctrl; z_obs];
fprintf('Separation check: max distance between eig(closed loop) and eig(ctrl) U eig(obs) = %.2e\n', ...
        max(min(abs(z_all - z_sep.'), [], 2)));
fprintf('Largest |z| of closed loop = %.5f (< 1 => stable)\n', max(abs(z_all)));

%% 2. Estimation-error convergence on the nonlinear plant (quantised encoders)
x0 = [0; deg2rad(10); 0; 0];
S_obs = furuta_sim_obs(P, D, x0, 4, struct('xhat0', zeros(4,1)));
S_fs  = furuta_sim_obs(P, D, x0, 4, struct('full_state', true));
e0 = norm(S_obs.e(1,:)); k2 = find(vecnorm(S_obs.e, 2, 2) < 0.02*e0, 1);
fprintf('\nEstimation error: |e(0)| = %.3f, below 2%% after %.3f s\n', e0, S_obs.t(k2));
fprintf('Observer-based: max|u| = %.2f V, final alpha = %.3f deg\n', max(abs(S_obs.u)), rad2deg(S_obs.x(end,2)));
fprintf('Full state    : max|u| = %.2f V\n', max(abs(S_fs.u)));

lbl = {'\theta [deg]', '\alpha [deg]', '\theta'' [deg/s]', '\alpha'' [deg/s]'};
figure('Position', [100 100 900 650]);
for i = 1:4
    subplot(3, 2, i);
    plot(S_obs.t, rad2deg(S_obs.x(:,i)), S_obs.t, rad2deg(S_obs.xhat(:,i)), '--'); grid on;
    ylabel(lbl{i}); xlim([0 1.5]);
    if i == 1, legend('true', 'estimate'); title('Observer estimates, \alpha_0 = 10^\circ, estimate starts at 0'); end
end
subplot(3, 2, 5); semilogy(S_obs.t, vecnorm(S_obs.e, 2, 2)); grid on; xlim([0 1.5]);
ylabel('estimation error norm'); xlabel('t [s]');
subplot(3, 2, 6); plot(S_fs.t, S_fs.u, S_obs.t, S_obs.u, '--'); grid on; xlim([0 1.5]);
ylabel('V_m [V]'); xlabel('t [s]'); legend('full state', 'observer-based');
exportgraphics(gcf, fullfile(figdir, 'w11_observer_convergence.png'));

%% 3. Choice of observer poles: speed vs noise
% Same test for each pole set: alpha0 = 5 deg, xhat0 = 0, quantised encoders,
% small random torque disturbances so the loop never sits exactly still.
sets = {[-15 -16 -17 -18], [-40 -45 -50 -55], [-100 -110 -120 -130], [-250 -260 -270 -280]};
names = {'slow (-15..-18)', 'medium (-40..-55)', 'chosen (-100..-130)', 'very fast (-250..-280)'};
op = struct('xhat0', zeros(4,1), 'torque_std', [2e-4; 5e-5]);
fprintf('\n%-24s %10s %12s %12s %12s %10s\n', 'observer poles', 'e<2% [s]', 'RMS u [V]', 'RMS da [deg/s]', 'max|u| [V]', 'alpha_end');
figure('Position', [100 100 800 500]); hold on;
for k = 1:numel(sets)
    Dk = furuta_design(P, sets{k});
    S = furuta_sim_obs(P, Dk, [0; deg2rad(5); 0; 0], 5, op);
    e0 = norm(S.e(1,:)); kk = find(vecnorm(S.e, 2, 2) < 0.02*e0, 1);
    if isempty(kk), tconv = NaN; else, tconv = S.t(kk); end
    w = S.t >= 2;                                       % steady-state window
    fprintf('%-24s %10.3f %12.3f %12.2f %12.2f %10.3f\n', names{k}, tconv, rms(S.u(w)), ...
            rad2deg(rms(S.e(w,4))), max(abs(S.u)), rad2deg(S.x(end,2)));
    plot(S.t, S.u);
end
grid on; xlabel('t [s]'); ylabel('V_m [V]'); legend(names); xlim([2 3]);
title('Steady-state voltage with quantised encoders (zoom 2-3 s)');
exportgraphics(gcf, fullfile(figdir, 'w11_observer_poles_noise.png'));

%% 4. Why not just differentiate the encoder signal?
S = furuta_sim_obs(P, D, [0; deg2rad(5); 0; 0], 5, op);
ad_fd = [0; diff(S.y(:,2))/Ts];                         % backward difference of quantised alpha
w = S.t >= 2;
fprintf('\nalpha_dot error RMS (t >= 2 s): finite difference %.2f deg/s, observer %.2f deg/s\n', ...
        rad2deg(rms(ad_fd(w) - S.x(w,4))), rad2deg(rms(S.e(w,4))));
fprintf('One encoder count per sample = q/Ts = %.2f rad/s = %.0f deg/s\n', P.enc_res/Ts, rad2deg(P.enc_res/Ts));
figure; plot(S.t, rad2deg(ad_fd), S.t, rad2deg(S.xhat(:,4)), S.t, rad2deg(S.x(:,4)), 'k'); grid on;
xlim([2 2.5]); xlabel('t [s]'); ylabel('\alpha'' [deg/s]');
legend('finite difference of encoder', 'observer estimate', 'true');
title('Pendulum velocity: differentiating a quantised angle vs the observer');
exportgraphics(gcf, fullfile(figdir, 'w11_velocity_estimate.png'));
