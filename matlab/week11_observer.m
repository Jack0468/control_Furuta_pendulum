%% Week 11 - Furuta pendulum: observer design and observer-based state feedback
% Designs a discrete-time state observer for the unmeasured velocities, derives the
% observer gain analytically, verifies the separation principle, and tests
% observer-based feedback on the nonlinear plant with real encoder quantisation
% (docs/08, docs/04 section 4).
clear; clc; close all;
P = furuta_params();
D = furuta_design(P);                      % final controller (with integrator) and default observer
A = D.A; B = D.B; C = D.C; Ts = D.Ts;

%% 1. Observer design and checks
fprintf('Observability rank (A,C): %d of 4\n', rank(obsv(A, C)));
fprintf('Controller poles (cont.): %s\n', mat2str(D.p_int, 3));
fprintf('Observer poles   (cont.): %s\n', mat2str(D.p_obs, 3));
fprintf('Kx = %s, Ki = %.3f\n', mat2str(D.Kx, 4), D.Ki);
fprintf('L =\n'); disp(D.L);
z_obs = eig(D.Ad - D.L*C);
fprintf('eig(Ad - L*C) mapped back to s = log(z)/Ts: %s\n', mat2str(sort(log(z_obs)/Ts).', 4));

% Analytical gain (continuous time). With C = [I 0], A = [0 I; A21 A22], L = [L1; L2]:
%   det(sI - A + L*C) = det(s^2*I + s*(L1 - A22) + (L2 - A22*L1 - A21))
% Making both coefficients diagonal splits this into (s+100)(s+130) * (s+110)(s+120).
A21 = A(3:4,1:2); A22 = A(3:4,3:4);
L1 = A22 + 230*eye(2);
L2 = A21 + A22*L1 + diag([13000 13200]);
Lc = [L1; L2];
fprintf('Analytical L (continuous) =\n'); disp(Lc);
fprintf('eig(A - Lc*C) = %s, largest error from the requested poles %.1e\n', mat2str(sort(eig(A - Lc*C)).', 6), ...
        max(abs(sort(real(eig(A - Lc*C))) - [-130; -120; -110; -100])));
fprintf('Ts*Lc(1:2,:) = %s; Ts*Lc(3:4,:) = %s\n', mat2str(Ts*Lc(1:2,:), 3), mat2str(Ts*Lc(3:4,:), 3));
fprintf('Observer pole time constants: %s ms; slowest controller pole time constant %.0f ms\n', ...
        mat2str(1e3./abs(D.p_obs), 3), 1e3/abs(real(D.p_int(1))));

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
en = vecnorm(S_obs.e, 2, 2); e0 = en(1); [epk, kpk] = max(en);
wf = S_obs.t >= 0.2;                       % after the start-up transient: quantisation noise floor
floor_e = median(en(wf));
ksettle = find(en > 3*floor_e, 1, 'last');
fprintf('\nEstimation error norm (mixes rad and rad/s, so velocities dominate): |e(0)| = %.3f, peak %.2f at %.0f ms\n', ...
        e0, epk, 1e3*S_obs.t(kpk));
fprintf('  noise floor (median, t >= 0.2 s) %.3f; last above 3x floor at %.3f s in the first 0.2 s window: %.3f s\n', ...
        floor_e, S_obs.t(ksettle), S_obs.t(find(en(1:find(wf,1)) > 3*floor_e, 1, 'last')));
fprintf('  RMS error for t >= 0.2 s: theta %.3f mrad, alpha %.3f mrad, thetadot %.2f deg/s, alphadot %.2f deg/s\n', ...
        1e3*rms(S_obs.e(wf,1)), 1e3*rms(S_obs.e(wf,2)), rad2deg(rms(S_obs.e(wf,3))), rad2deg(rms(S_obs.e(wf,4))));
fprintf('  alpha_dot estimate peak %.0f deg/s at %.0f ms (true value there %.0f deg/s); |alpha_hat| first within 1 deg of true at %.1f ms\n', ...
        rad2deg(max(S_obs.xhat(:,4))), 1e3*S_obs.t(find(S_obs.xhat(:,4) == max(S_obs.xhat(:,4)), 1)), ...
        rad2deg(S_obs.x(find(S_obs.xhat(:,4) == max(S_obs.xhat(:,4)), 1), 4)), ...
        1e3*S_obs.t(find(abs(S_obs.e(:,2)) < deg2rad(1), 1)));
fprintf('  voltage at the limit for %.0f ms\n', 1e3*Ts*sum(abs(S_obs.u) >= P.Vmax));
fprintf('Observer-based: max|u| = %.2f V, final alpha = %.3f deg, peak theta %.1f deg, peak alpha after release %.1f deg\n', ...
        max(abs(S_obs.u)), rad2deg(S_obs.x(end,2)), rad2deg(max(abs(S_obs.x(:,1)))), rad2deg(min(S_obs.x(:,2))));
fprintf('Full state    : max|u| = %.2f V, peak theta %.1f deg, peak alpha after release %.1f deg\n', ...
        max(abs(S_fs.u)), rad2deg(max(abs(S_fs.x(:,1)))), rad2deg(min(S_fs.x(:,2))));

lbl = {'$\theta$ [deg]', '$\alpha$ [deg]', '$\dot\theta$ [deg/s]', '$\dot\alpha$ [deg/s]'};
figure('Position', [100 100 900 650]);
for i = 1:4
    subplot(3, 2, i);
    plot(S_obs.t, rad2deg(S_obs.x(:,i)), S_obs.t, rad2deg(S_obs.xhat(:,i)), '--'); grid on;
    ylabel(lbl{i}, 'Interpreter', 'latex'); xlim([0 1.5]);
    if i == 1, legend('true', 'estimate'); title('Observer estimates, \alpha_0 = 10^\circ, estimate starts at 0'); end
end
subplot(3, 2, 5); semilogy(S_obs.t, vecnorm(S_obs.e, 2, 2)); grid on; xlim([0 1.5]);
ylabel('||e|| (rad, rad/s)'); xlabel('t [s]'); yticks([1e-3 1e-2 1e-1 1]);
subplot(3, 2, 6); plot(S_fs.t, S_fs.u, S_obs.t, S_obs.u, '--'); grid on; xlim([0 1.5]);
ylabel('V_m [V]'); xlabel('t [s]'); legend('full state', 'observer-based', 'Location', 'southeast');
furuta_savefig(gcf, 'w11_observer_convergence', 7.16, 2.9);

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

% The report's table: noise (no initial tilt), tap response, and a linear robustness count
% on 200 random +/-20% plants (sampled loop, nominal K and L).
pnames = {'mp','Lp','Lr','Rm','km','Dr','Dp','Jr'}; Nr = 200; rng(1);
F = 0.8 + 0.4*rand(Nr, numel(pnames));
plants = cell(Nr, 1);
for n = 1:Nr
    Pn = P; for j = 1:numel(pnames), Pn.(pnames{j}) = P.(pnames{j})*F(n,j); end
    Pn.Jp = Pn.mp*Pn.Lp^2/12;
    [An, Bn, Cn] = furuta_linmodel(Pn); plants{n} = c2d(ss(An, Bn, Cn, 0), Ts);
end
opN = struct('torque_std', [2e-4; 5e-5]);
opT = struct('tau_p', @(t) 0.02*(t >= 0.5 & t < 0.52));
fprintf('\n%-24s %12s %14s %14s %12s %10s\n', 'observer poles', 'RMS u [V]', 'RMS e_ad[d/s]', 'tap max|a|', 'max|u| tap', 'unstable');
for k = 1:numel(sets)
    Lk = furuta_design(P, sets{k}).L;
    SN = furuta_sim_obs(P, D, zeros(4,1), 5, setfield(opN, 'L', Lk)); w = SN.t >= 1; %#ok<SFLD>
    ST = furuta_sim_obs(P, D, zeros(4,1), 3, setfield(opT, 'L', Lk));                %#ok<SFLD>
    nu = 0;
    for n = 1:Nr
        sk = plants{n};
        Aclk = [sk.A, -sk.B*D.Ki, -sk.B*D.Kx; Ts*Ct, 1, zeros(1,4); ...
                Lk*sk.C, -D.Bd*D.Ki, D.Ad - D.Bd*D.Kx - Lk*C];
        nu = nu + (max(abs(eig(Aclk))) >= 1);
    end
    fprintf('%-24s %12.3f %14.2f %14.1f %12.2f %7d/%d\n', names{k}, rms(SN.u(w)), rad2deg(rms(SN.e(w,4))), ...
            rad2deg(max(abs(ST.x(:,2)))), max(abs(ST.u)), nu, Nr);
end
nf = 0;
for n = 1:Nr
    sk = plants{n};
    nf = nf + (max(abs(eig([sk.A - sk.B*D.Kx, -sk.B*D.Ki; Ts*Ct, 1]))) >= 1);
end
ST = furuta_sim_obs(P, D, zeros(4,1), 3, setfield(opT, 'full_state', true));         %#ok<SFLD>
fprintf('%-24s %12s %14s %14.1f %12.2f %7d/%d\n', 'true state', '-', '-', rad2deg(max(abs(ST.x(:,2)))), max(abs(ST.u)), nf, Nr);
figure(2);                                               % back to the steady-state voltage figure
grid on; xlabel('t [s]'); ylabel('V_m [V]'); legend(names); xlim([2 3]);
title('Steady-state voltage with quantised encoders (zoom 2-3 s)');
furuta_savefig(gcf, 'w11_observer_poles_noise', 3.5, 2.3);

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
furuta_savefig(gcf, 'w11_velocity_estimate', 3.5, 2.2);
