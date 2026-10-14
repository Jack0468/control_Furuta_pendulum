function [A, B, C, D] = furuta_linmodel(P)
%FURUTA_LINMODEL LTI model linearised about the upright equilibrium.
%   x = [theta; alpha; theta_dot; alpha_dot], u = Vm, y = [theta; alpha]
%   Equilibrium: x = 0, u = 0 (alpha = 0 is upright).

a = P.Jr + P.mp*P.Lr^2;          % arm inertia seen at upright
b = 0.5*P.mp*P.Lp*P.Lr;          % arm-pendulum coupling
c = P.Jp + 0.25*P.mp*P.Lp^2;     % pendulum inertia about the pivot
d = 0.5*P.mp*P.g*P.Lp;           % gravity stiffness
Delta = a*c - b^2;

Beq = P.Dr + P.km^2/P.Rm;        % viscous + back-EMF damping on the arm

A = [0 0          1             0;
     0 0          0             1;
     0 b*d/Delta -c*Beq/Delta  -b*P.Dp/Delta;
     0 a*d/Delta -b*Beq/Delta  -a*P.Dp/Delta];

B = P.km/(P.Rm*Delta) * [0; 0; c; b];

C = [1 0 0 0;
     0 1 0 0];

D = zeros(2, 1);
end
