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

% Sensors: optical incremental encoders, 512 CPR read in 4x quadrature (docs/08)
%   e.g. Broadcom HEDS-5540#I (512 CPR) or US Digital E5-512 (datasheets in references/)
P.enc_cpr    = 512;                  % cycles per revolution (datasheet "CPR")
P.enc_counts = 4*P.enc_cpr;          % counts per revolution in 4x quadrature = 2048
P.enc_res    = 2*pi/P.enc_counts;    % quantisation step q     [rad] = 3.07 mrad
P.enc_sigma  = P.enc_res/sqrt(12);   % quantisation noise std q/sqrt(12) [rad] = 0.886 mrad
P.enc_pos_err_typ = deg2rad(10/60);  % HEDS-5540 position error, typical 10 arcmin [rad]
P.enc_pos_err_max = deg2rad(40/60);  % HEDS-5540 position error, max 40 arcmin [rad]
P.Ts         = 1e-3;                 % controller sample time  [s]
end
