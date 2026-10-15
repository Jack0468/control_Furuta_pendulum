%% Week 10 - Pole placement worked step by step (checks docs/06_pole_placement_derivation.md)
% Reproduces every intermediate number of the hand derivation:
%   1) requirements -> zeta, wn -> poles
%   2) desired characteristic polynomial
%   3) closed-loop characteristic polynomial det(sI - A + BK) in terms of K
%   4) coefficient matching -> K
%   5) Ackermann cross-check, 6) place() cross-check
clear; clc;
P = furuta_params();
[A, B] = furuta_linmodel(P);
fmt = @(v) mat2str(v, 6);

%% Step 1: requirements -> dominant poles
OS = 5; Ts = 2.0;
zeta_min = -log(OS/100)/sqrt(pi^2 + log(OS/100)^2);
fprintf('Step 1: zeta_min = %.4f, sigma_min = 4/Ts = %.4f\n', zeta_min, 4/Ts);
zeta = 0.7; wn = 4;
sig = zeta*wn; wd = wn*sqrt(1 - zeta^2);
fprintf('        sigma = %.4f, wd = %.4f, predicted Ts = %.3f s, OS = %.2f %%, tr = %.3f s\n', ...
        sig, wd, 4/sig, 100*exp(-pi*zeta/sqrt(1-zeta^2)), 1.8/wn);
p = [-sig + 1i*wd, -sig - 1i*wd, -12, -15];

%% Step 2: desired characteristic polynomial
dd = poly(p);
fprintf('\nStep 2: Delta_d(s) coefficients [1 a3 a2 a1 a0] = %s\n', fmt(real(dd)));

%% Step 3: closed-loop characteristic polynomial det(sI - A + BK)
% Hand result (docs/06 Step 3): every coefficient is affine in K,
%   c3 = -(a33 + a44) + b3*k3 + b4*k4
%   c2 = (a33*a44 - a34*a43 - a42) + b3*k1 + b4*k2 + beta1*k3 + beta2*k4
%   c1 = (a33*a42 - a32*a43) + beta1*k1 + beta2*k2 + beta3*k3
%   c0 = beta3*k1
% with beta1 = a34*b4 - a44*b3, beta2 = a43*b3 - a33*b4, beta3 = a32*b4 - a42*b3
a32 = A(3,2); a33 = A(3,3); a34 = A(3,4); a42 = A(4,2); a43 = A(4,3); a44 = A(4,4);
b3 = B(3); b4 = B(4);
fprintf('\nStep 3: a32=%.4f a33=%.4f a34=%.4f a42=%.4f a43=%.4f a44=%.4f b3=%.4f b4=%.4f\n', ...
        a32, a33, a34, a42, a43, a44, b3, b4);
beta1 = a34*b4 - a44*b3; beta2 = a43*b3 - a33*b4; beta3 = a32*b4 - a42*b3;
fprintf('        beta1 = %.4f, beta2 = %.4f, beta3 = %.4f\n', beta1, beta2, beta3);
c_ol = [-(a33 + a44); a33*a44 - a34*a43 - a42; a33*a42 - a32*a43; 0];   % [c3 c2 c1 c0] at K = 0
M = [0     0     b3    b4;
     b3    b4    beta1 beta2;
     beta1 beta2 beta3 0;
     beta3 0     0     0];
fprintf('        open-loop constants [c3 c2 c1 c0] = %s\n', fmt(c_ol.'));
fprintf('        M =\n'); disp(M);
% numerical check of the hand formulas: poly(A - B*K) for unit gains
M_num = zeros(4); c0_num = poly(A); c0_num = c0_num(2:5).';
for i = 1:4
    e = zeros(1,4); e(i) = 1;
    ci = poly(A - B*e); M_num(:,i) = ci(2:5).' - c0_num;
end
fprintf('        check: max|M - M_numeric| = %.2e, max|c_ol - poly(A)| = %.2e\n', ...
        max(abs(M - M_num), [], 'all'), max(abs(c_ol - c0_num)));

%% Step 4: coefficient matching  c_ol + M*K' = [a3 a2 a1 a0]'
rhs = real(dd(2:5)).' - c_ol;
fprintf('\nStep 4: rhs = Delta_d coeffs - open-loop constants = %s\n', fmt(rhs.'));
k1 = rhs(4)/beta3;
fprintf('        from s^0: k1 = %.6f\n', k1);
K_match = (M\rhs).';
fprintf('        K (coefficient matching) = %s\n', fmt(K_match));

%% Step 5: Ackermann
Wc = ctrb(A, B);
phiA = polyvalm(real(dd), A);
K_ack = [0 0 0 1]/Wc*phiA;
fprintf('\nStep 5: rank(Wc) = %d, det(Wc) = %.4e\n', rank(Wc), det(Wc));
fprintf('        K (Ackermann) = %s\n', fmt(K_ack));

%% Step 6: place() and verification
K_place = place(A, B, p);
fprintf('\nStep 6: K (place) = %s\n', fmt(K_place));
fprintf('        eig(A - B*K) = %s\n', mat2str(eig(A - B*K_match).', 5));
fprintf('        max |K_match - K_place| = %.2e\n', max(abs(K_match - K_place)));
