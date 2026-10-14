function P = furuta_params()
%FURUTA_PARAMS Nominal parameters of the Furuta (rotary inverted) pendulum.
%   Values based on the Quanser QUBE-Servo 2 rotary pendulum module.
%   Verify against the QUBE-Servo 2 user manual / workbook before submission.

P.g   = 9.81;      % gravity                                   [m/s^2]

% DC motor
P.Rm  = 8.4;       % armature resistance                       [Ohm]
P.km  = 0.042;     % back-EMF / torque constant (kt = km)      [V.s/rad] = [N.m/A]
P.Vmax = 10;       % actuator saturation limit                 [V]

% Rotary arm
P.mr  = 0.095;     % arm mass                                  [kg]
P.Lr  = 0.085;     % arm length (pivot to pendulum joint)      [m]
P.Jr  = P.mr*P.Lr^2/12;  % arm inertia about motor axis (Quanser convention) [kg.m^2]
P.Dr  = 0.0015;    % arm viscous damping (approximate)         [N.m.s/rad]

% Pendulum
P.mp  = 0.024;     % pendulum mass                             [kg]
P.Lp  = 0.129;     % pendulum full length                      [m]
P.Jp  = P.mp*P.Lp^2/12;  % pendulum inertia about its centre of mass [kg.m^2]
P.Dp  = 0.0005;    % pendulum viscous damping (approximate)    [N.m.s/rad]

% Sensors
P.enc_counts = 2048;                 % encoder counts per revolution (quadrature)
P.enc_res    = 2*pi/P.enc_counts;    % angle resolution        [rad]
P.Ts         = 1e-3;                 % controller sample time  [s]
end
