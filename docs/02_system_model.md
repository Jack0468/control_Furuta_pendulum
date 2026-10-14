# 02: System Model (Lab 9 A1)

## 1. Physical system and signals

A DC motor rotates a horizontal arm of length L_r. A pendulum of length L_p hangs from a free joint at the arm tip. The pendulum swings in the plane perpendicular to the arm. Both joints have encoders.

| Signal | Symbol | Unit | Role |
| --- | --- | --- | --- |
| Motor voltage | V_m | V | **Input** u (the only actuator) |
| Arm angle | θ | rad | State x₁ and measured output y₁ (motor encoder) |
| Pendulum angle | α | rad | State x₂ and measured output y₂ (pendulum encoder) |
| Arm angular velocity | θ̇ | rad/s | State x₃, **not measured** |
| Pendulum angular velocity | α̇ | rad/s | State x₄, **not measured** |
| Disturbance torque on arm (cable drag, friction) | τ_d | N·m | Disturbance (step or constant) |
| Disturbance torque on pendulum (a tap or push) | τ_p | N·m | Disturbance (impulse) |
| Encoder quantisation and noise | n | rad | Measurement disturbance |

**Conventions:**

- θ is positive counter-clockwise when viewed from above.
- **α = 0 is upright** and α = π is hanging down. α is positive counter-clockwise when looking outward along the arm.

## 2. Nonlinear equations of motion

These are derived by Euler–Lagrange, following the Quanser workbook and Cazzolato & Prime (2011). The modelling assumptions are a uniform slender pendulum rod, viscous damping at both joints, and negligible motor inductance.

Arm:

$$
\left(J_r + m_p L_r^2 + \tfrac14 m_p L_p^2 \sin^2\alpha\right)\ddot\theta
- \tfrac12 m_p L_p L_r \cos\alpha\,\ddot\alpha
+ \tfrac12 m_p L_p^2 \sin\alpha\cos\alpha\,\dot\theta\dot\alpha
+ \tfrac12 m_p L_p L_r \sin\alpha\,\dot\alpha^2
= \tau - D_r\dot\theta + \tau_d
$$

Pendulum:

$$
-\tfrac12 m_p L_p L_r \cos\alpha\,\ddot\theta
+ \left(J_p + \tfrac14 m_p L_p^2\right)\ddot\alpha
- \tfrac14 m_p L_p^2 \cos\alpha\sin\alpha\,\dot\theta^2
- \tfrac12 m_p g L_p \sin\alpha
= -D_p\dot\alpha + \tau_p
$$

Motor:

$$
\tau = \frac{k_m}{R_m}\left(V_m - k_m\dot\theta\right)
$$

These equations are implemented in `matlab/furuta_nl.m`, which solves the 2×2 mass matrix for θ̈ and α̈. This nonlinear model is the **truth model** used to test every linear design.

## 3. Linearisation about the upright equilibrium

**Equilibrium:** x̄ = [θ̄, 0, 0, 0] with ū = 0. Any θ̄ is an equilibrium, so choose θ̄ = 0. Linearise using sin α ≈ α and cos α ≈ 1, and drop products of small terms (sin²α, θ̇α̇, α̇², θ̇²).

Define the lumped constants:

$$
a = J_r + m_p L_r^2,\quad b = \tfrac12 m_p L_p L_r,\quad c = J_p + \tfrac14 m_p L_p^2,\quad d = \tfrac12 m_p g L_p,\quad \Delta = ac - b^2,\quad B_{eq} = D_r + \frac{k_m^2}{R_m}
$$

The linearised equations are

$$
a\ddot\theta - b\ddot\alpha = \tfrac{k_m}{R_m}V_m - B_{eq}\dot\theta, \qquad
-b\ddot\theta + c\ddot\alpha - d\alpha = -D_p\dot\alpha
$$

Solving for θ̈ and α̈ gives ẋ = Ax + Bu, y = Cx + Du:

$$
A = \begin{bmatrix} 0 & 0 & 1 & 0 \\ 0 & 0 & 0 & 1 \\ 0 & \frac{bd}{\Delta} & -\frac{cB_{eq}}{\Delta} & -\frac{bD_p}{\Delta} \\ 0 & \frac{ad}{\Delta} & -\frac{bB_{eq}}{\Delta} & -\frac{aD_p}{\Delta} \end{bmatrix},\quad
B = \frac{k_m}{R_m\Delta}\begin{bmatrix} 0 \\ 0 \\ c \\ b \end{bmatrix},\quad
C = \begin{bmatrix} 1 & 0 & 0 & 0 \\ 0 & 1 & 0 & 0 \end{bmatrix},\quad
D = \begin{bmatrix} 0 \\ 0 \end{bmatrix}
$$

Numerical values with the nominal parameters (from `furuta_linmodel.m`):

$$
A = \begin{bmatrix} 0 & 0 & 1 & 0 \\ 0 & 0 & 0 & 1 \\ 0 & 149.28 & -17.007 & -4.915 \\ 0 & 261.61 & -16.809 & -8.614 \end{bmatrix},\qquad
B = \begin{bmatrix} 0 \\ 0 \\ 49.73 \\ 49.15 \end{bmatrix}
$$

The positive gravity entries A(3,2) and A(4,2) cause the instability.

## 4. Parameters

| Parameter | Symbol | Value | Unit | Source / note |
| --- | --- | --- | --- | --- |
| Motor resistance | R_m | 8.4 | Ω | QUBE-Servo 2 manual |
| Torque / back-EMF constant | k_m = k_t | 0.042 | N·m/A | QUBE-Servo 2 manual |
| Arm mass | m_r | 0.095 | kg | QUBE-Servo 2 manual |
| Arm length | L_r | 0.085 | m | QUBE-Servo 2 manual |
| Arm inertia | J_r = m_r L_r²/12 | 5.72 × 10⁻⁵ | kg·m² | Quanser workbook convention |
| Pendulum mass | m_p | 0.024 | kg | QUBE-Servo 2 manual |
| Pendulum length | L_p | 0.129 | m | QUBE-Servo 2 manual |
| Pendulum inertia (about CoM) | J_p = m_p L_p²/12 | 3.33 × 10⁻⁵ | kg·m² | Uniform rod |
| Arm damping | D_r | 0.0015 | N·m·s/rad | Approximate; highly uncertain |
| Pendulum damping | D_p | 0.0005 | N·m·s/rad | Approximate; highly uncertain |
| Voltage limit | V_max | ±10 | V | Amplifier / software limit; verify |
| Encoder resolution | — | 2048 counts/rev (3.07 mrad) | — | QUBE-Servo 2 manual |
| Gravity | g | 9.81 | m/s² | — |

> **Action:** check each value against your copy of the QUBE-Servo 2 user manual and cite it in the report. If your values differ, edit only `furuta_params.m`; everything else is computed from it.

## 5. Model properties (verified in MATLAB)

| Property | Result | Meaning |
| --- | --- | --- |
| Open-loop poles | 0, −30.05, **+10.55**, −6.12 rad/s | Unstable. The time constant is 95 ms; from 2° the pendulum passes 15° in 0.23 s |
| Reachability | rank 4 / 4 | All poles can be placed with V_m |
| Observability (θ, α) | rank 4 / 4 | An observer can estimate θ̇ and α̇ |
| Observability (θ only) | rank 4 / 4 | θ alone is enough in theory; α improves conditioning |
| Observability (α only) | rank 3 / 4 | θ cannot be recovered from α (θ is a free integrator) |
| Zeros of θ / V_m | **+8.97**, −12.72 rad/s | Non-minimum phase: the arm initially moves the wrong way, which limits θ tracking bandwidth |
| cond(ctrb) | ≈ 5 × 10⁵ | Use `place`/`lqr`, not Ackermann by hand |

### Sensitivity of the unstable pole to ±20% parameter error

| Parameter | × 0.8 | × 1.2 |
| --- | --- | --- |
| m_p | 9.74 | 11.23 |
| L_p | 10.88 | 10.09 |
| L_r | 10.15 | 10.89 |
| R_m | 10.52 | 10.57 |
| k_m | 10.59 | 10.50 |
| D_r | 10.73 | 10.40 |
| D_p | 11.05 | 10.08 |

The unstable pole stays between 9.7 and 11.3 rad/s, so the model is structurally robust. The pendulum mass and the damping coefficients matter most.

## 6. Open-loop simulations (Lab 9 A2)

Generated by `week9_model_and_openloop.m`:

- `figures/w9_openloop_release.png`: release from α₀ = 2°. The linear and nonlinear responses agree up to about 15°, then diverge. The nonlinear pendulum falls and swings to hanging (α = 180°) instead of growing without bound.
- `figures/w9_pulse_response.png`: 1 V, 50 ms voltage pulse from upright. A pulse this small is enough to topple the pendulum. Linear and nonlinear responses agree until α ≈ 15° (t ≈ 0.2 s). After that, the nonlinear arm reverses as the pendulum falls, while the linear arm diverges.
