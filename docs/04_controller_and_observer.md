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
% u = -Ka * [x - [r;0;0;0]; xi]
```

**Recommended Week 10 design: D2 + integrator.**

## 4. Observer (Week 11 plan)

Only θ and α are measured, so estimate x with a full-order Luenberger observer:

$$
\dot{\hat x} = A\hat x + Bu + L(y - C\hat x),\qquad u = -K\hat x \;(\text{plus the integrator on the measured } \theta)
$$

- The pair (A, C) is observable (rank 4), so the eigenvalues of A − LC can be placed anywhere. Use `L = place(A', C', po)'`. With two outputs, `place` picks one of many valid L matrices; an alternative is `L = lqe`/`kalman` with noise covariances.
- **Pole choice:** start 3–4× faster than the fastest controller pole, e.g. po = [−40, −45, −50, −55]. Then try [−80 … −100] and compare the noise in V_m when the measurements are quantised to 2π/2048 rad.
- The integrator state uses the **measured** θ, not θ̂, so it needs no estimation.
- Feed the **saturated** u into the observer.
- Tests to add in `week11_observer.m`:
    1. Initial estimation error, e.g. x̂(0) = 0 with x(0) = [0, 10°, 0, 0]: does the loop still recover?
    2. Quantised and noisy y: how does the noise in V_m compare between slow and fast observer poles?
    3. Compare with a simple dirty-derivative filter 50s/(s+50), the approach Quanser uses on the hardware.
    4. Repeat the ±20% parameter sweep: the observer uses the nominal A and B while the plant is perturbed.

## 5. Discussion points for Assessment 2

- **Fundamental limitations:** the RHP pole p = 10.55 sets a minimum bandwidth for stabilisation, and the RHP zero z = 8.97 in θ/V_m sets a maximum bandwidth for θ tracking. Because z < p for the θ channel, the second measurement α is essential.
- **Saturation versus aggressiveness:** compare D1 and D2. Faster poles give little gain in recovery angle (34° versus 31°) for 3.4× the voltage.
- **Model validity:** the controller recovers from 31° even though the linearisation is accurate only to about 15°.
- **Uncertainty:** D_r and D_p are the least certain parameters. Show stability margins under ±50% changes to them.
