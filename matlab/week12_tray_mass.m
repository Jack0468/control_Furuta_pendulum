function week12_tray_mass()
%WEEK12_TRAY_MASS What a tray and drink at the pendulum tip would do (report, Section II-C).
%   Run from the matlab/ folder. Writes no figures. Run directly: run_all doesn't include it.
% A point mass m_t at distance L_p from the pivot changes the pendulum's total mass, centre of
% mass and inertia. The model only uses m_p, L_p/2 and J_p, so an equivalent uniform-rod
% parameter set represents it exactly: m_p = M, L_p = 2*l, J_p = J about the new centre of mass.
P = furuta_params();
D = furuta_design(P);
opT = struct('tau_p', @(t) 0.02*(t >= 0.5 & t < 0.52));
x0 = [0; deg2rad(10); 0; 0];
xh0 = @(x) [P.enc_res*round(x(1:2)/P.enc_res); 0; 0];
r0 = deg2rad(30);
fprintf('Stall torque at 10 V = %.3f N.m\n', P.km/P.Rm*P.Vmax);
fprintf('Largest tip mass whose gravity torque at 15 deg is below stall (rod included): %.0f g\n', ...
        1e3*max((P.km/P.Rm*P.Vmax/(P.g*sind(15)) - P.mp*P.Lp/2)/P.Lp, 0));
fprintf('\n%6s %8s %8s %8s | %s\n', 'mt[g]', 'pole', 'zero', 'c/c0', 'NOMINAL GAINS: max|z|, 10 deg peak V and up?, tap deg, tap V, up?');
mts = [0 2 5 10 15 20 30 50 100 200];
for mt = mts
    Pt = withTip(P, mt/1e3);
    [A, B, C] = furuta_linmodel(Pt);
    pol = max(real(eig(A)));
    zz = tzero(ss(A, B, [1 0 0 0], 0)); zr = max(real(zz));
    sk = c2d(ss(A, B, C, 0), P.Ts);
    Acl = [sk.A, -sk.B*D.Ki, -sk.B*D.Kx; P.Ts*[1 0 0 0], 1, zeros(1,4); ...
           D.L*C, -D.Bd*D.Ki, D.Ad - D.Bd*D.Kx - D.L*C];
    zm = max(abs(eig(Acl)));
    S1 = furuta_sim_obs(P, D, x0, 4, struct('Pplant', Pt, 'xhat0', xh0(x0)));
    S2 = furuta_sim_obs(P, D, zeros(4,1), 3, setfield(opT, 'Pplant', Pt)); %#ok<SFLD>
    c = Pt.Jp + 0.25*Pt.mp*Pt.Lp^2; c0 = P.Jp + 0.25*P.mp*P.Lp^2;
    fprintf('%6.0f %8.2f %8.2f %8.2f | %.4f  %5.1f V %3s  %6.1f deg %5.1f V %3s\n', mt, pol, zr, c/c0, zm, ...
            max(abs(S1.u)), yn(up(S1)), rad2deg(max(abs(S2.x(:,2)))), max(abs(S2.u)), yn(up(S2)));
end
fprintf('\n%6s | %s\n', 'mt[g]', 'REDESIGNED, SAME POLES: Kx, Ki | 10 deg V, up | step Ts, OS, V | tap deg, V, up | RMS u');
for mt = mts
    Pt = withTip(P, mt/1e3);
    Dt = furuta_design(Pt);
    S1 = furuta_sim_obs(Pt, Dt, x0, 4, struct('xhat0', xh0(x0)));
    Ss = furuta_sim_obs(Pt, Dt, zeros(4,1), 4.5, struct('r', @(t) r0*(t >= 0.5)));
    S2 = furuta_sim_obs(Pt, Dt, zeros(4,1), 3, opT);
    Sn = furuta_sim_obs(Pt, Dt, zeros(4,1), 6, struct('torque_std', [2e-4; 5e-5]));
    m = Ss.t >= 0.5; th = Ss.x(m,1); tt = Ss.t(m) - 0.5; k = find(abs(th - r0) > 0.02*r0, 1, 'last');
    if k < numel(tt), ts = tt(k+1); else, ts = NaN; end
    fprintf('%6.0f | %s %.2f | %5.1f V %3s | %5.2f s %5.1f %% %5.2f V | %6.1f deg %5.1f V %3s | %.3f V\n', mt, mat2str(Dt.Kx, 3), Dt.Ki, ...
            max(abs(S1.u)), yn(up(S1)), ts, (max(th) - r0)/r0*100, max(abs(Ss.u)), ...
            rad2deg(max(abs(S2.x(:,2)))), max(abs(S2.u)), yn(up(S2)), rms(Sn.u(Sn.t >= 1)));
end
end

function Pt = withTip(P, mt)
M = P.mp + mt;
l = (P.mp*P.Lp/2 + mt*P.Lp)/M;
J = P.Jp + P.mp*(l - P.Lp/2)^2 + mt*(P.Lp - l)^2;
Pt = P; Pt.mp = M; Pt.Lp = 2*l; Pt.Jp = J;
end

function tf = up(S)
tf = abs(S.x(end,2)) < deg2rad(1) && max(abs(S.x(:,2))) < pi/2;
end

function s = yn(tf)
if tf, s = 'yes'; else, s = 'NO'; end
end
