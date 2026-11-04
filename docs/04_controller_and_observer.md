# 04: Controller and Observer Design (Lab 10 A2–A3, Lab 11)

## 1. Control law

Full-state feedback with arm reference r:

$$
u = -K\left(x - \begin{bmatrix} r & 0 & 0 & 0 \end{bmatrix}^T\right)
$$

This is the same as u = −Kx + N̄r with N̄ = K₁. Because the plant has a free integrator in θ, no separate N̄ calculation is needed: with r = 0 the equilibrium is any θ, and the error term makes θ = r the only equilibrium.

The gains are computed with `K = place(A, B, p)`. The system is reachable (rank 4), so any pole set p is achievable.

## 2. Candidate designs: results from `week10_state_feedback.m`

The columns are measured on the linear model, except "Max α₀", which comes from the nonlinear plant with ±10 V saturation. D1–D3 use ζ = 0.7 for the dominant pair; D4 uses ζ = 0.75.

| Design | Poles | K = [k_θ, k_α, k_θ̇, k_α̇] | t_r (s) | T_s (s) | OS (%) | Undershoot (%) | \|V\| at α₀ = 10° | Max α₀ recovered |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| D1 aggressive | −2.8 ± 2.86j, −30, −40 | [−9.16, 110, −3.94, 7.95] | 0.48 | 1.55 | 5.2 | 7.6 | 19.2 V | 27° |
| D2 moderate | −2.8 ± 2.86j, −12, −15 | [−1.37, 30.3, −0.838, 2.44] | 0.52 | 1.65 | 4.7 | 4.0 | 5.3 V | 30° |
| D3 slow | −2.1 ± 2.14j, −12, −15 | [−0.773, 27.1, −0.624, 2.14] | 0.70 | 2.15 | 4.7 | 2.4 | 4.7 V | 30° |
| **D4 final** | −2.7 ± 2.38j, −10.8, −13.5 | [−0.902, 26.6, −0.674, 2.11] | 0.64 | 1.76 | 2.8 | 2.9 | 4.6 V | 30° |
| LQR, Q = diag(5,1,0,0), R = 1 | −3.96 ± 3.46j, −12.6, −13.5 | [−2.24, 34.5, −1.14, 2.82] | 0.43 | 1.24 | 2.8 | 5.8 | 6.0 V | 28° |

### Interpretation

- **D1** demands 19.2 V for a 10° offset, far above the 10 V limit, misses the 5% overshoot limit, and recovers from a smaller angle than the others.
- **D3** meets the 2.5 s limit (T_s = 2.15 s), with the least margin.
- **D2 and D4** both meet the criteria. D4 has less overshoot and voltage, and it does better than D2 once the integrator and observer are in the loop (§3c), so it is the final design (D-19).
- **LQR** is the fastest (1.24 s), with 5.8% undershoot and 6.0 V. It is a good comparison to discuss pole placement versus optimal control.
- The region of attraction (27–30°) is much larger than the linear validity range (15°). The nonlinear plant is more forgiving than the linear model suggests.

## 3. D4 on the nonlinear plant (true state, no integrator)

See `figures/w10_nonlinear_tests.png`.

| Test | Result | Requirement |
| --- | --- | --- |
| α₀ = 10° recovery | max \|V\| = 4.6 V | R5 met |
| 30° arm step | max \|V\| = 0.5 V | R5 met |
| Pendulum tap (20 mN·m, 20 ms) | max \|α\| = 8.0°; max \|V\| = 7.3 V | R5, R6 met |
| Constant arm drag (2 mN·m) | **Arm settles 25.7° off target** | **R7 fails** |
| ±20% parameter sweep (linear) | All closed-loop poles stay in the LHP (slowest −2.23 rad/s, for k_m × 1.2) | R8 met for stability |

**Why R7 fails:** the steady-state arm offset is τ_d / (k_θ k_m / R_m). With k_θ = 0.90 V/rad, a 2 mN·m drag gives about 0.44 rad (25°). There are two possible fixes:

1. **Integral action (chosen).** Augment the state with x_i = ∫(θ − r) dt and place 5 poles. Result with poles [D4, −5]: K_a = [−3.56, 38.0, −1.42, 3.15, −4.51]. Under the tap and drag test the final θ error is 0.00° with the true state, with max \|α\| = 11.3°, max \|θ\| = 45.3° and max \|V\| = 9.8 V. See `figures/w10_integral_action.png`.
2. A faster θ loop (larger k_θ). This reduces the offset but never removes it, and it costs voltage.

```matlab
Aa = [A zeros(4,1); 1 0 0 0 0];   % xi_dot = theta - r
Ba = [B; 0];
Ka = place(Aa, Ba, [-2.7+2.38i, -2.7-2.38i, -10.8, -13.5, -5]);
% Final control law (type-1 servo): u = -Ka(1:4)*x - Ka(5)*xi
```

**Final design: D4 + integrator.**

### 3a. How the reference enters: type-1 servo

The first version fed the reference twice: through u = −K_a[x − x_r; ξ] *and* through the integrator ξ̇ = θ − r. On a 30° step this gave very large overshoot (57% with the gains of the time). The disturbance tests above did not show it, because they use r = 0.

The fix is the standard type-1 servo structure (Ogata, *Modern Control Engineering*, "servo system with integrator"), where r enters **only** through the integrator:

$$
u = -K_x x - k_i\xi,\qquad \dot\xi = \theta - r
$$

With the final gains on the linear model (`week12_validation.m`, V9):

| Reference path | T_s | OS | US |
| --- | --- | --- | --- |
| Integrator and K_x(1) | 1.82 s | 50.7% | 9.5% |
| **Integrator only (chosen)** | 1.43 s | 1.7% | 1.3% |

On the nonlinear plant with the observer, OS is 1.4% and T_s is 1.43 s without quantisation, or 1.38 s with it (doc 05, V2).

### 3b. Where Aleksei's poles come from

Aleksei used the **same method** with slightly different choices (his notes, November 2026).

| Step | Aleksei | This repo (D2) |
| --- | --- | --- |
| Damping ratio from 5% overshoot | ζ ≥ 0.690, chose **0.75** for margin | ζ ≥ 0.690, chose **0.70** |
| Natural frequency | t_r ≈ 1.8/ω_n ≤ 0.5 s gives ω_n ≥ 3.6; T_s ≈ 4/(ζω_n) ≤ 1.5 s gives ω_n ≥ 3.56; chose **3.6** | RHP zero and slosh give ω_n ≲ 4.5; chose **4** |
| Dominant pair | −2.70 ± 2.38j | −2.80 ± 2.86j |
| Fast poles | 4× and 5× σ: **−10.8, −13.5** | **−12, −15** |
| Integrator | None in his notes (his K has 4 gains) | Pole at −5 |

The real parts are almost the same (2.7 vs 2.8), so they settle about equally fast. His pair has less imaginary part, hence more damping. His fast poles are about 10% slower, so the gains are lower.

His published K = [−0.90, 26.37, −0.77, 2.14] can't be compared directly with ours. It was computed on a different model (D_r 0.001, D_p 0.00005), without an integrator.

### 3c. Comparing the two pole sets on the updated model

Same integrator (−5), published damping, spin term included, quantised encoders, observer −100…−130 (`week12_validation.m`, V8).

| | Ours (D2) | Aleksei's (D4) |
| --- | --- | --- |
| K_x | [−4.85, 43.5, −1.75, 3.64] | [−3.56, 38.0, −1.42, 3.15] |
| k_i | −6.87 | −4.51 |
| Step: T_s | 1.97 s | **1.38 s** |
| Step: overshoot | 2.8% | **1.4%** |
| Step: arm ripple, peak to peak | 0.81° | **0.71°** |
| 10° release: peak voltage | 7.6 V | **6.6 V** |
| Tap: max \|α\|, peak voltage | 15.0°, 9.7 V | **14.6°, 9.0 V** |
| Noise: RMS voltage | 0.249 V | **0.216 V** |

**Decision (D-19): Aleksei's poles adopted.** They clear the tap limit with less voltage and less ripple, and they settle sooner. His rise-time target of ≤ 0.5 s isn't met with the integrator-only reference path (0.75 s), so that target isn't used. They are set in `furuta_design.m`.

**His observer (checked 2026-11-04).** His Simulink uses observer poles −40, −45, −50, −55 with no integrator or disturbance model. In our full loop, those poles give a 20.4° tap (limit 15°) and 10/200 unstable plants, against 14.6° and 3/200 for −100…−130 (`week11_kalman.m`). We keep −100…−130 (LOGBOOK D-20).

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

- K_x = [−3.561, 38.01, −1.423, 3.146] and k_i = −4.508, from controller poles −2.7 ± 2.38j, −10.8, −13.5, −5.
- Observer poles −100, −110, −120, −130 rad/s, 7.4–9.6× the fastest controller pole.

**Separation principle (verified).** The eigenvalues of the full sampled closed loop, with states [x; ξ; x̂], equal those of the controller plus those of the observer to 1.5 × 10⁻¹³. Largest |z| = 0.9973, so the loop is stable.

### Choosing the observer poles

Test: start at α₀ = 5° with x̂₀ = 0; quantised encoders; small random torques (`week11_observer.m`). The tap and robustness columns come from `week11_kalman.m`: the robustness count is the linear sampled loop on 200 plants with all parameters ±20%.

| Observer poles | Error < 2% after | RMS u (V) | RMS α̇ error (deg/s) | Tap: max \|α\| | Unstable / 200 |
| --- | --- | --- | --- | --- | --- |
| −15…−18 | 0.53 s | 0.046 | 0.57 | falls | 52 |
| −40…−55 | 0.22 s | 0.095 | 1.09 | 20.4° | 10 |
| **−100…−130 (chosen)** | 0.37 s (noise floor) | 0.210 | 2.93 | 14.6° | **3** |
| −250…−280 | 0.40 s (noise floor) | 0.494 | 7.83 | 12.7° | 2 |
| True state | — | — | — | 11.4° | 1 |

**Why fast poles were chosen (LOGBOOK D-10, D-20).** A slow observer gives smooth estimates, but it reacts too late to a tap and badly erodes robustness. The plants it fails on have a weaker motor than modelled (k_m low, R_m high). This is the known result that observer-based feedback has no guaranteed robustness margins (Doyle, 1978). −100…−130 is the slowest set tested that meets the tap limit, at a cost of 0.22 V RMS of noise and about 0.7° peak-to-peak of arm ripple from quantisation. With x̂₀ = 0 it also hits the 10 V limit briefly at start-up, because of the large initial estimation error.

**Velocity estimates vs differentiation.** Differentiating the encoder gives a 29 deg/s RMS error in α̇, because one count per sample is 176 deg/s. The observer gives 2.9 deg/s (`figures/w11_velocity_estimate.png`).

**Cost of the observer.** It reacts later than full-state feedback to a sudden disturbance. A 20 mN·m, 20 ms tap gives max |α| = 14.6° with the observer, against 11.4° with the true state. The region of attraction is 24°, against 30° for the same poles with the true state. The phase margin is 36°, against 59° (`week12_margins.m`).

**A Kalman filter offers a different trade-off.** It is modestly quieter for a similar tap response, but not clearly better overall: see [doc 09](09_kalman_filter.md). The report uses the pole-placed observer (D-12, option A).

## 5. Discussion points for Assessment 2

- **Fundamental limitations:** the RHP pole p = 12.09 sets a minimum bandwidth for stabilisation, and the RHP zero z = 10.31 in θ/V_m sets a maximum bandwidth for θ tracking. Because z < p for the θ channel, the second measurement α is essential.
- **Saturation versus aggressiveness:** compare D1 and D4. Faster poles give no gain in recovery angle (27° versus 30°) for 4.2× the voltage.
- **Model validity:** with the true state the controller recovers from 30° (24° with the observer) even though the linearisation is accurate only to about 15°.
- **Uncertainty:** D_r and D_p are the least certain parameters. Show stability margins under ±50% changes to them.
