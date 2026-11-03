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
| D1 aggressive | −2.8 ± 2.86j, −30, −40 | [−9.16, 122, −4.38, 7.95] | 0.48 | 1.57 | 5.2 | 8.8 | 21.4 V | 27° |
| **D2 moderate** | −2.8 ± 2.86j, −12, −15 | [−1.37, 32.6, −1.07, 2.23] | 0.52 | 1.67 | 4.7 | 4.9 | 5.7 V | 28° |
| D3 slow | −2.1 ± 2.14j, −12, −15 | [−0.773, 28.6, −0.844, 1.92] | 0.70 | 2.17 | 4.7 | 3.0 | 5.0 V | 29° |
| LQR, Q = diag(5,1,0,0), R = 1 | −4.29 ± 2.87j, −9.99, −17.6 | [−2.24, 40.1, −1.49, 2.85] | 0.51 | 0.97 | 0.8 | 6.6 | 7.0 V | 27° |

### Interpretation

- **D1** nearly meets the timing requirement, but it demands 21.4 V for a 10° offset, far above the 10 V limit, so it saturates immediately.
- **D3** meets the 2.5 s limit (T_s = 2.17 s), but with no margin to spare once encoder ripple is added.
- **D2** meets the timing requirements and uses 5.7 V at a 10° offset, inside the 6 V target. It is the recommended baseline.
- **LQR** is the fastest (0.97 s) with 6.6% undershoot, but uses 7.0 V, just over the 6 V target. It is a good comparison to discuss pole placement versus optimal control.
- The region of attraction (27–29°) is much larger than the linear validity range (15°). The nonlinear plant is more forgiving than the linear model suggests.

## 3. D2 on the nonlinear plant

See `figures/w10_nonlinear_tests.png`.

| Test | Result | Requirement |
| --- | --- | --- |
| α₀ = 10° recovery | max \|V\| = 5.7 V; arm swings to −43°; α within ±1° after 1.05 s | R2 met, R5 met, R9 met |
| 30° arm step | max \|V\| = 0.7 V; small undershoot, then 4.6% overshoot | R3 met |
| Pendulum tap (20 mN·m, 20 ms) | max \|α\| = 8.4°; arm swings to ±61°; max \|V\| = 7.5 V | R6 met, R9 met |
| Constant arm drag (2 mN·m) | **Arm settles 16.7° off target** | **R7 fails** |
| ±20% parameter sweep (linear) | All closed-loop poles stay in the LHP (slowest −2.17 rad/s, for D_r × 1.2) | R8 met for stability |

**Why R7 fails:** the steady-state arm offset is τ_d / (k_θ k_m / R_m). With D2's k_θ = 1.37 V/rad, a 2 mN·m drag gives 0.29 rad (16.7°). There are two possible fixes:

1. **Integral action (recommended).** Augment the state with x_i = ∫(θ − r) dt and place 5 poles. Result with poles [D2, −5]: K_a = [−5.04, 49.1, −2.08, 3.53, −6.87]. Under the tap and drag test the **steady-state θ error is 0.00°**, with max \|α\| = 12.4°, max \|θ\| = 45.6°, and max \|V\| = 10.0 V (brief saturation). See `figures/w10_integral_action.png`.
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

With the same gains, the linear step response becomes T_s 1.80 s, OS 2.5%, US 2.2%, with about one-seventh of the initial voltage. On the nonlinear plant with the observer, OS is 2.0% and T_s is 1.81 s without quantisation, or 2.40 s with it (doc 05, V2).

Feeding a fraction N_r·K_x(1) of the reference forward trades speed for overshoot:

| N_r | T_s | OS | US |
| --- | --- | --- | --- |
| 1 (original) | 2.04 s | 57.5% | 14.4% |
| 0.5 | 1.64 s | 14.7% | 7.8% |
| 0.25 | 1.67 s | 4.2% | 4.6% |
| **0 (chosen)** | 1.80 s | 2.5% | 2.2% |

Produced by `scratch/ref_structure.m`, which is not part of the public repo.

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

Same integrator (−5), published damping, spin term included, quantised encoders.

| Observer −100…−130 | Ours (D2) | Aleksei's |
| --- | --- | --- |
| K_x | [−4.85, 43.5, −1.75, 3.64] | [−3.56, 38.0, −1.42, 3.15] |
| k_i | −6.87 | −4.51 |
| Step: T_s, quantised / unquantised | 1.97 / 1.79 s | **1.38 / 1.43 s** |
| Step: rise, overshoot, undershoot | 0.65 s, 2.8%, 1.5% | 0.75 s, 1.4%, 1.3% |
| 10° release: time to \|α\| < 1°, peak voltage | 0.94 s, 7.6 V | 0.97 s, **6.6 V** |
| Tap: max \|α\|, peak voltage | 15.0°, 9.7 V | **14.6°**, 9.0 V |
| Arm drag: final error | 0.14° | 0.21° |
| Noise: RMS voltage, arm ripple | 0.25 V, 0.88° | **0.22 V, 0.58°** |
| Unstable of 300 ±20% plants | 0 | 0 |
| Phase margin; gain margins | 37°; ×0.57, ×6.4 | 36°; ×0.59, ×6.7 |

**Recommendation: adopt Aleksei's poles.** They clear the tap limit with less voltage and less ripple. Their ripple stays inside the ±0.6° settling band, so the settling time isn't inflated. His rise-time target of ≤ 0.5 s isn't met with the integrator-only reference path (0.75 s), so that target shouldn't be used. The switch is one line in `furuta_design.m`, and it awaits the team's decision (I-09).

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

- K_x = [−5.036, 49.09, −2.083, 3.527] and k_i = −6.871, from controller poles −2.8 ± 2.86j, −12, −15, −5.
- Observer poles −100, −110, −120, −130 rad/s.

**Separation principle (verified).** The eigenvalues of the full sampled closed loop, with states [x; ξ; x̂], equal those of the controller plus those of the observer to 2.8 × 10⁻¹³. Largest |z| = 0.9972, so the loop is stable.

### Choosing the observer poles

Test: start at α₀ = 5° with x̂₀ = 0; quantised encoders; small random torques. The robustness column is the linear sampled loop on 500 plants with all parameters ±20%.

| Observer poles | Error < 2% after | RMS u (V) | RMS α̇ error (deg/s) | Unstable / 500 |
| --- | --- | --- | --- | --- |
| −15…−18 | 0.56 s | 0.048 | 0.46 | 114 |
| −40…−55 | 0.22 s | 0.098 | 0.83 | 27 |
| **−100…−130 (chosen)** | 0.98 s (noise floor) | 0.244 | 2.79 | **6** |
| −250…−280 | 1.89 s (noise floor) | 0.541 | 7.33 | not run |

**Why fast poles were chosen (LOGBOOK D-10).** A slow observer gives smooth estimates but badly erodes robustness. The plants it fails on have a weaker motor than modelled (k_m low, R_m high). With full-state feedback 0 of the 500 plants are unstable. This is the known result that observer-based feedback has no guaranteed robustness margins (Doyle, 1978). −100…−130 recovers most of the robustness, at a cost of 0.24 V RMS of noise and about 1° peak-to-peak of arm ripple from quantisation. With x̂₀ = 0 it also hits the 10 V limit briefly at start-up in this test, because of the large initial estimation error. This choice should be reviewed against −40…−55 (27/500 unstable, 0.10 V RMS); see LOGBOOK I-08.

**Velocity estimates vs differentiation.** Differentiating the encoder gives a 30 deg/s RMS error in α̇, because one count per sample is 176 deg/s. The observer gives 2.8 deg/s (`figures/w11_velocity_estimate.png`).

**Cost of the observer.** It reacts later than full-state feedback to a sudden disturbance. A 20 mN·m, 20 ms tap gives max |α| = 15.1° with the observer, against 12.4° with the true state. The region of attraction is 22°, against 28° for D2 with the true state.

**A Kalman filter offers a different trade-off.** It is modestly quieter for a similar tap response, but not clearly better overall: see [doc 09](09_kalman_filter.md). The choice between them is open decision D-12.

## 5. Discussion points for Assessment 2

- **Fundamental limitations:** the RHP pole p = 9.96 sets a minimum bandwidth for stabilisation, and the RHP zero z = 8.97 in θ/V_m sets a maximum bandwidth for θ tracking. Because z < p for the θ channel, the second measurement α is essential.
- **Saturation versus aggressiveness:** compare D1 and D2. Faster poles give no gain in recovery angle (27° versus 28°) for 3.8× the voltage.
- **Model validity:** the controller recovers from 28° even though the linearisation is accurate only to about 15°.
- **Uncertainty:** D_r and D_p are the least certain parameters. Show stability margins under ±50% changes to them.
