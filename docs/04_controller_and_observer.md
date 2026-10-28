# 04: Controller and Observer Design (Lab 10 A2–A3, Lab 11)

## 1. Control law

Full-state feedback with arm reference r:

$$
u = -K\left(x - \begin{bmatrix} r & 0 & 0 & 0 \end{bmatrix}^T\right)
$$

This is the same as u = −Kx + N̄r with N̄ = K₁. Because the plant has a free integrator in θ, no separate N̄ calculation is needed: with r = 0 the equilibrium is any θ, and the error term makes θ = r the only equilibrium.

The gains are computed with `K = place(A, B, p)`. The system is reachable (rank 4), so any pole set p is achievable.

## 2. Candidate designs: results from `week10_state_feedback.m`

All designs use ζ = 0.7 for the dominant pair. The columns are measured on the linear model, except "Max α₀", which comes from the nonlinear plant with ±10 V saturation.

| Design | Poles | K = [k_θ, k_α, k_θ̇, k_α̇] | t_r (s) | T_s (s) | OS (%) | Undershoot (%) | \|V\| at α₀ = 10° | Max α₀ recovered |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| D1 aggressive | −2.8 ± 2.86j, −30, −40 | [−3.38, 47.1, −1.84, 2.87] | 0.48 | 1.57 | 5.2 | 8.8 | 8.2 V | 34° |
| **D2 moderate** | −2.8 ± 2.86j, −12, −15 | [−0.508, 13.9, −0.613, 0.762] | 0.52 | 1.67 | 4.7 | 4.9 | 2.4 V | 31° |
| D3 slow | −2.1 ± 2.14j, −12, −15 | [−0.286, 12.5, −0.528, 0.647] | 0.70 | 2.17 | 4.7 | 3.0 | 2.2 V | 31° |
| LQR, Q = diag(5,1,0,0), R = 1 | −5.73 ± 2.68j, −10.6, −29.8 | [−2.24, 28.1, −1.34, 1.89] | 0.45 | 0.90 | 0.1 | 10.3 | 4.9 V | 31° |

### Interpretation

- **D1** meets the timing requirement, but it uses 8.2 V for a 10° offset. That violates the R5 margin, and with noise it will saturate.
- **D3** is too slow and fails R3 (T_s = 2.17 s).
- **D2** meets R1–R5 with a large voltage margin. It is the recommended baseline.
- **LQR** is the fastest, but its undershoot is just above R3's 10% limit. It is a good comparison to discuss pole placement versus optimal control.
- The region of attraction (31–34°) is much larger than the linear validity range (15°). The nonlinear plant is more forgiving than the linear model suggests.

## 3. D2 on the nonlinear plant

See `figures/w10_nonlinear_tests.png`.

| Test | Result | Requirement |
| --- | --- | --- |
| α₀ = 10° recovery | max \|V\| = 2.4 V; arm swings to −43°; α within ±1° after about 1.3 s | R2 met, R5 met, R9 met |
| 30° arm step | max \|V\| = 0.4 V; small undershoot, then about 1% overshoot | R3 met |
| Pendulum tap (20 mN·m, 20 ms) | max \|α\| = 10.2°; arm swings to −72° | R6 met; R9 met but marginal |
| Constant arm drag (2 mN·m) | **Arm settles 45° off target** | **R7 fails** |
| ±20% parameter sweep (linear) | All closed-loop poles stay in the LHP (slowest −1.41 rad/s, for k_m × 0.8) | R8 met for stability |

**Why R7 fails:** the steady-state arm offset is τ_d / (k_θ k_m / R_m). With D2's small k_θ = 0.508 V/rad, a 2 mN·m drag gives 0.79 rad (45°). There are two possible fixes:

1. **Integral action (recommended).** Augment the state with x_i = ∫(θ − r) dt and place 5 poles. Result with poles [D2, −5]: K_a = [−1.86, 20.0, −0.985, 1.24, −2.54]. Under the tap and drag test the **steady-state θ error is 0.00°**, with max \|α\| = 14.0°, max \|θ\| = 51°, and max \|V\| = 4.7 V. See `figures/w10_integral_action.png`.
2. A faster θ loop (larger k_θ). This reduces the offset but never removes it, and it costs voltage.

```matlab
Aa = [A zeros(4,1); 1 0 0 0 0];   % xi_dot = theta - r
Ba = [B; 0];
Ka = place(Aa, Ba, [-2.8+2.86i, -2.8-2.86i, -12, -15, -5]);
% Final control law (type-1 servo): u = -Ka(1:4)*x - Ka(5)*xi
```

**Recommended Week 10 design: D2 + integrator.**

### 3a. How the reference enters: type-1 servo (fixed 2026-10-29)

The first version fed the reference twice: through u = −K_a[x − x_r; ξ] *and* through the integrator ξ̇ = θ − r. On a 30° step this gave **57% overshoot**. The disturbance tests above did not show it, because they use r = 0.

The fix is the standard type-1 servo structure (Ogata, *Modern Control Engineering*, "servo system with integrator"), where r enters **only** through the integrator:

$$
u = -K_x x - k_i\xi,\qquad \dot\xi = \theta - r
$$

With the same gains, the linear step response becomes T_s 1.80 s, OS 2.5%, US 2.2%, with half the voltage. On the nonlinear plant with the observer it is T_s 1.26 s, OS 1.5% (doc 05, V2).

Feeding a fraction N_r·K_x(1) of the reference forward trades speed for overshoot:

| N_r | T_s | OS | US |
| --- | --- | --- | --- |
| 1 (original) | 2.04 s | 57.5% | 14.4% |
| 0.5 | 1.64 s | 14.7% | 7.8% |
| 0.25 | 1.67 s | 4.2% | 4.6% |
| **0 (chosen)** | 1.80 s | 2.5% | 2.2% |

Produced by `scratch/ref_structure.m`, which is not part of the public repo.

## 4. Observer (Week 11): design and results

Only θ and α are measured (doc 08), so the velocities are estimated by a **discrete-time Luenberger observer** running at 1 kHz, in predictor form:

$$
\hat x_{k+1} = A_d\hat x_k + B_d u_k + L\left(y_k - C\hat x_k\right),\qquad u_k = \operatorname{sat}\!\left(-K_x\hat x_k - k_i\xi_k\right),\qquad \xi_{k+1} = \xi_k + T_s\left(y_{\theta,k} - r_k\right)
$$

- A_d and B_d are the zero-order-hold discretisation of (A, B) at T_s = 1 ms.
- L is found with `place(Ad', C', exp(p_obs*Ts))'`, which places the observer poles at exp(p_obs·T_s). (A, C) is observable (rank 4).
- The integrator uses the **measured** θ, so it needs no estimate.
- The observer is driven by the **saturated** voltage, so its estimate stays right while the motor is saturated.
- Code: [furuta_design.m](../matlab/furuta_design.m) (gains), [furuta_sim_obs.m](../matlab/furuta_sim_obs.m) (loop), [week11_observer.m](../matlab/week11_observer.m) (design and tests).

**Final gains:**

- K_x = [−1.861, 20.03, −0.985, 1.241] and k_i = −2.539, from controller poles −2.8 ± 2.86j, −12, −15, −5.
- Observer poles −100, −110, −120, −130 rad/s.

**Separation principle (verified).** The eigenvalues of the full sampled closed loop, with states [x; ξ; x̂], equal those of the controller plus those of the observer to 1.6 × 10⁻¹³. Largest |z| = 0.9972, so the loop is stable.

### Choosing the observer poles

Test: start at α₀ = 5° with x̂₀ = 0; quantised encoders; small random torques. The robustness column is the linear sampled loop on 500 plants with all parameters ±20%.

| Observer poles | Error < 2% after | RMS u (V) | RMS α̇ error (deg/s) | Unstable / 500 |
| --- | --- | --- | --- | --- |
| −15…−18 | 0.55 s | 0.023 | 0.57 | 111 |
| −40…−55 | 0.32 s | 0.046 | 1.04 | 39 |
| **−100…−130 (chosen)** | 0.23 s | 0.092 | 2.59 | **6** |
| −250…−280 | — (noise floor) | 0.190 | 6.53 | — (saturates at 10 V) |

**Why fast poles were chosen (LOGBOOK D-10).** A slow observer gives smooth estimates but badly erodes robustness. The plants it fails on have a weaker motor than modelled (k_m low, R_m high). With full-state feedback only 1 in 500 plants is unstable. This is the known result that observer-based feedback has no guaranteed robustness margins (Doyle, 1978). −100…−130 recovers most of the robustness for 0.09 V RMS of noise. At −250 the quantisation noise drives the motor into saturation.

**Velocity estimates vs differentiation.** Differentiating the encoder gives a 29 deg/s RMS error in α̇, because one count per sample is 176 deg/s. The observer gives 2.6 deg/s (`figures/w11_velocity_estimate.png`).

**Cost of the observer.** It reacts later than full-state feedback to a sudden disturbance. A 20 mN·m, 20 ms tap gives max |α| = 18° with the observer, against 14° with the true state. The region of attraction is 22° instead of 31°.

**A Kalman filter does this trade-off better.** For the same tap response, a Kalman gain is quieter and more robust: see [doc 09](09_kalman_filter.md). The choice between them is open decision D-12.

## 5. Discussion points for Assessment 2

- **Fundamental limitations:** the RHP pole p = 10.55 sets a minimum bandwidth for stabilisation, and the RHP zero z = 8.97 in θ/V_m sets a maximum bandwidth for θ tracking. Because z < p for the θ channel, the second measurement α is essential.
- **Saturation versus aggressiveness:** compare D1 and D2. Faster poles give little gain in recovery angle (34° versus 31°) for 3.4× the voltage.
- **Model validity:** the controller recovers from 31° even though the linearisation is accurate only to about 15°.
- **Uncertainty:** D_r and D_p are the least certain parameters. Show stability margins under ±50% changes to them.
