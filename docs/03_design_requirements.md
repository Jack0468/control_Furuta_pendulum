# 03: Design Requirements (Lab 10 A1)

## 1. Answers to the Lab 10 questions

**Why does the system need to be controlled?**
The upright equilibrium is unstable, with an open-loop pole at +10.55 rad/s (time constant 95 ms). Released at 2°, the pendulum passes 15° in 0.23 s, which is faster than a human can react. Without feedback the upright position cannot be held at all.

**Which signals can we measure?**
θ (motor encoder) and α (pendulum encoder), each with 2048 counts/rev (3.07 mrad resolution). The velocities θ̇ and α̇ are not measured, so 2 sensors cover 4 states. This motivates the observer.

**How can we act on the system?**
Through the motor voltage V_m only, limited to ±10 V. The motor torque τ = (k_m/R_m)(V_m − k_m θ̇) gives a stall torque of about 0.05 N·m at 10 V.

**What are the minimum improvements that justify control?**
The pendulum must stay upright indefinitely, with a stable closed loop, and the arm must go to a commanded angle. Anything less is failure, because the uncontrolled system falls in under 0.3 s.

**How should the system respond to realistic disturbances?**

- A tap on the pendulum must be rejected without falling or saturating for long.
- Constant arm drag (from the encoder cable or friction) must not leave a large arm offset.
- Encoder quantisation must not cause visible chatter in V_m.

**What are the constraints?**

- Input: |V_m| ≤ 10 V.
- States: |α| ≲ 15° for the linear model to stay valid. The controller's region of attraction is larger; see [04_controller_and_observer.md](04_controller_and_observer.md).
- Arm: |θ| ≤ 90°, to limit cable wind-up and stay within a sensible workspace.

## 2. Requirements

| ID | Requirement | Target | Why this value |
| --- | --- | --- | --- |
| R1 | Closed-loop stability | All poles of A − BK in the LHP; balance indefinitely | Basic purpose |
| R2 | Pendulum recovery | From α₀ = 10°: \|α\| < 1° within 1.5 s; no fall | 10° is a realistic hand-release error |
| R3 | Arm step tracking (30°) | 2% settling ≤ 2.0 s; overshoot ≤ 5%; undershoot ≤ 10% | Comparable to the Quanser lab specification; the undershoot comes from the RHP zero and cannot be avoided |
| R4 | Arm rise time | t_r ≥ 0.3 s (do not go faster) | The RHP zero at 8.97 rad/s limits the achievable bandwidth to about z/2 ≈ 4.5 rad/s |
| R5 | Actuator | \|V_m\| ≤ 10 V in tests R2, R3, R6, with margin (target ≤ 6 V) | Margin is kept for disturbances and uncertainty |
| R6 | Disturbance: pendulum tap | 20 mN·m for 20 ms: max \|α\| < 15°, recovered within 2 s | Stays in the linear region |
| R7 | Disturbance: arm drag | 2 mN·m constant: steady-state θ error < 2° (with integral action: 0) | About 4% of stall torque, a realistic cable drag |
| R8 | Robustness | R1, R2, R5 still met with ±20% on m_p, L_p, R_m, k_m, D_r, D_p | Parameter uncertainty |
| R9 | Arm excursion | \|θ\| ≤ 90° during R2 and R6 | Cable and workspace limit |

## 3. Converting requirements into pole locations

Use second-order dominant-pole approximations:

$$
\zeta = \frac{-\ln(OS/100)}{\sqrt{\pi^2 + \ln^2(OS/100)}},\qquad
T_s(2\%) \approx \frac{4}{\zeta\omega_n},\qquad
t_r \approx \frac{1.8}{\omega_n}
$$

- OS ≤ 5% gives ζ ≥ 0.69. Choose **ζ = 0.7**.
- T_s ≤ 2.0 s gives ζω_n ≥ 2.0 rad/s.
- The RHP-zero limit (R4) gives ω_n ≲ 4.5 rad/s.
- Choose **ω_n = 4 rad/s**: s = −2.8 ± 2.86j. The predicted T_s is 1.43 s, which leaves margin for the zero and the extra poles.
- Place the remaining two poles 4–10× faster than the dominant pair, real, on the negative axis. Faster poles mean higher gains and more voltage (see the comparison in doc 04).

Desired characteristic polynomial (design D2):

$$
\Delta_d(s) = (s^2 + 5.6s + 16)(s + 12)(s + 15)
$$

**Caveat:** the plant has a RHP zero, and the "fast" poles are not very far away. The 2nd-order formulas are therefore only a starting point. Always check the result with `stepinfo` and the nonlinear simulation, then iterate.
