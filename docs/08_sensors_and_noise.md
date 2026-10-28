# 08: Sensors and Measurement-Noise Model

**Result:** both angles are measured with 512-cycle-per-revolution optical incremental encoders, read in 4× quadrature (2048 counts/rev). Their dominant error is **quantisation**: q = 2π/2048 = 3.07 mrad, which behaves like uniform noise with σ = q/√12 = **0.886 mrad (0.051°)**.

The other datasheet error terms are either much smaller (cycle error) or slowly varying offsets (position error), which the integrator removes. The velocities are not measured, and differentiating the encoder is far too noisy. That is why an observer is needed.

Datasheets are stored locally in `references/datasheets/` (git-ignored; links in [references/README.md](../references/README.md)).

---

## 1. Which sensor, and why

| Requirement | Why it matters here |
| --- | --- |
| Measure θ (arm) and α (pendulum) absolutely after start-up | The controller needs both angles. The upright reference α = 0 is set by holding the pendulum upright (or from the index pulse) at start-up |
| Resolution well below the angles we care about | R2 asks for \|α\| < 1° = 17.5 mrad; we want q ≪ 17.5 mrad |
| Very low added inertia on the pendulum joint | The pendulum's pivot inertia c = 1.33 × 10⁻⁴ kg·m² is tiny |
| Digital output | No analogue noise or drift; the error is set by the code pattern |
| Fast enough | The pendulum swings at up to about 20 rad/s, so at most about 3.2 rev/s |

**Optical incremental encoders** meet all of these. The QUBE-Servo 2 uses this type: its two channels are read in 4× quadrature mode, with channel 0 for the motor and channel 1 for the pendulum ([Quanser HIL documentation](https://docs.quanser.com/quarc/documentation/qube_servo2_usb.html)).

Two real, orderable parts at the resolution assumed in the model:

| | **Broadcom HEDS-5540, option I** | **US Digital E5-512** |
| --- | --- | --- |
| Resolution | 512 CPR, three-channel with index (ordering table, p. 11) | 512 CPR is an orderable option (part number guide, p. 12) |
| Counts/rev in 4× quadrature | 2048 | 2048 |
| Codewheel inertia | 0.6 g·cm² = 6.0 × 10⁻⁸ kg·m² (p. 7) | 8.0 × 10⁻⁶ oz·in·s² = 5.6 × 10⁻⁸ kg·m² (p. 5) |
| Max count rate / speed | 100 kHz count frequency (p. 5), i.e. about 195 rev/s at 512 CPR | 300 kHz; max RPM = min(18×10⁶/CPR, 60 000) = 35 000 rpm (p. 5) |
| Max acceleration | — | 250 000 rad/s² (p. 5) |
| Accuracy data | Full table: position, cycle, state-width and phase error (p. 5) | Edge timing only, on the EM1 module datasheet: symmetry 180 ± 30 °e, quadrature 90 ± 30 °e, worst case over a full rotation (EM1 p. 10) |
| Output | TTL, 5 V | TTL, 5 V (single-ended option) |

**Chosen for the model: Broadcom HEDS-5540, option I.** Its datasheet gives a complete accuracy specification, so every error term in our model traces to a published number.

**Added inertia is negligible:** 6.0 × 10⁻⁸ / 1.33 × 10⁻⁴ = 0.045% of the pendulum's pivot inertia. It is not included in the model.

---

## 2. Datasheet error terms, converted to mechanical angle

Encoder datasheets quote errors in **electrical degrees (°e)**: 360 °e is one cycle, which is 1/512 of a revolution. So for 512 CPR:

$$
1\ ^\circ\text{e} = \frac{1}{512}\ ^\circ\text{mech} = 34.1\ \mu\text{rad}
$$

HEDS-5540 values from the "Encoding Characteristics" table (p. 5; typical values at 25 °C, 5 V), with definitions from p. 3:

| Term (symbol) | Definition (p. 3) | Typical | Max | Typical (mrad) | Max (mrad) | Relative to q = 3.07 mrad |
| --- | --- | --- | --- | --- | --- | --- |
| Position error ΔΘ | Difference between the actual shaft angle and the angle indicated by the count | 10 arcmin | 40 arcmin | 2.91 | 11.6 | 0.95 q / 3.8 q |
| Cycle error ΔC | Variation of one cycle from its nominal 1/N rev | 3 °e | 5.5 °e | 0.10 | 0.19 | 0.03 q / 0.06 q |
| Logic state width error ΔS | Deviation of each count interval from its nominal 90 °e | 5 °e | 35 °e | 0.17 | 1.19 | 0.06 q / 0.39 q |
| Phase error Δφ | Deviation of the A–B phase from 90 °e | 2 °e | 15 °e | 0.07 | 0.51 | — |
| **Quantisation** (from the resolution) | One count = 360°/2048 | — | — | **3.07** step | ±1.53 | 1 q |

### What each term does to the measurement

- **Quantisation** dominates the sample-to-sample noise.
- **Position error ΔΘ** comes mainly from codewheel eccentricity. It varies slowly with angle: roughly once per revolution, so over a ±10° balancing range it is almost constant. It therefore acts as an **offset (bias)**, not noise. Setting α = 0 by calibrating at upright removes most of it. The residual is tested in validation V4.
- **State-width error ΔS** shifts individual count edges by up to 0.39 q. This slightly widens the quantisation error, but its typical value (0.06 q) is negligible.
- **Cycle and phase errors** are negligible.
- **Electrical noise:** the outputs are digital, so there is no analogue noise. The only electrical failure mode is a missed or extra count from interference, which is not modelled.

---

## 3. Measurement model used in the simulations

$$
y_k = q\cdot\operatorname{round}\!\left(\frac{C x(kT_s) + b + n_k}{q}\right),\qquad q = \frac{2\pi}{2048} \tag{S1}
$$

| Symbol | Meaning | Value used | Source |
| --- | --- | --- | --- |
| y_k | Encoder readings [θ, α] at sample k | — | — |
| C | [I₂ 0]: picks θ and α from the state | — | doc 02 |
| q | Quantisation step | 3.068 × 10⁻³ rad | 512 CPR × 4 |
| b | Constant offset (uncalibrated position error) | 0 nominal; 10 and 40 arcmin in test V4 | HEDS-5540 ΔΘ typ / max |
| n_k | Optional extra white noise (sensitivity tests) | 0 by default | — |
| T_s | Sample time | 1 ms (1 kHz) | Typical for QUBE-Servo 2 control |

Implemented in [furuta_sim_obs.m](../matlab/furuta_sim_obs.m), step 1, with the parameters in [furuta_params.m](../matlab/furuta_params.m) (`enc_res`, `enc_sigma`, `enc_pos_err_typ`, `enc_pos_err_max`).

### Statistical (white-noise) approximation, for the observer and Kalman design

When the angle changes by more than a few counts between samples, the rounding error is approximately uniform on [−q/2, q/2] and uncorrelated between samples. This is the standard quantisation-noise model:

$$
v_k \sim \mathcal{U}\!\left(-\tfrac{q}{2}, \tfrac{q}{2}\right),\qquad \sigma_v^2 = \frac{q^2}{12} = 7.85\times10^{-7}\ \text{rad}^2,\qquad \sigma_v = 0.886\ \text{mrad} = 0.051^\circ \tag{S2}
$$

**Where it comes from:** the variance of a uniform distribution of width q is q²/12.

So the measurement-noise covariance used for the Kalman filter (doc 09) is R = σ_v² I₂.

**Limit of this approximation:** near equilibrium the pendulum moves less than one count per sample. The rounding error is then strongly correlated, not white. It can create small limit cycles (the loop "hunting" between two adjacent counts). The simulations use the exact rounding in (S1), not the approximation, so this effect is included in the results.

---

## 4. Why the velocities cannot simply be differentiated

Differentiating the angle over one sample turns one count into a velocity jump of

$$
\frac{q}{T_s} = \frac{3.07\ \text{mrad}}{1\ \text{ms}} = 3.07\ \text{rad/s} = 176^\circ/\text{s} \tag{S3}
$$

| Velocity estimate (V5-type test) | RMS error of α̇ |
| --- | --- |
| Backward difference of the encoder | 29 deg/s |
| Observer, poles −100…−130 (chosen) | 2.6 deg/s |
| Observer, poles −40…−55 | 1.0 deg/s |

Source: [week11_observer.m](../matlab/week11_observer.m) §4 and §3; figure `figures/w11_velocity_estimate.png`.

The observer uses the model to fill in between counts, which is why it is about 10× better. A slower observer is smoother still, but it is less robust and slower to react to disturbances (doc 04 §4, LOGBOOK D-10). Doc 09 picks this trade-off systematically with a Kalman filter.

---

## 5. Validation results that depend on the sensor model

| Test | Result |
| --- | --- |
| V4: 10 arcmin offset on α (typical ΔΘ) | With the integrator, the arm settles 0.04° from target (5.5° without) |
| V4: 40 arcmin offset on α (maximum ΔΘ) | 0.21° with the integrator (21° without) |
| V5: quantisation + random torque disturbances | RMS voltage 0.091 V; RMS α 0.08°; RMS θ 0.33° |

**Why the integrator also fixes a sensor offset:** a biased α makes the controller think the pendulum is leaning. It would keep accelerating the arm, but the integrator on θ settles at whatever value cancels that bias.

## References

- Avago/Broadcom, *HEDM-55xx/560x & HEDS-55xx/56xx Quick Assembly Two and Three Channel Optical Encoders*, data sheet AV02-1046EN. [docs.broadcom.com/doc/AV02-1046EN](https://docs.broadcom.com/doc/AV02-1046EN)
- US Digital, *E5 Motor Encoder* datasheet, rev. 2026.04.06. [Link](https://cdn2.usdigital.com/datasheets/E5-Datasheet.pdf)
- US Digital, *EM1 Transmissive Optical Encoder Module* datasheet, rev. 2026.04.14. [Link](https://cdn2.usdigital.com/datasheets/EM1-Datasheet.pdf)
- Quanser, *QUBE-Servo 2 USB* HIL board documentation (encoder channels, 4× quadrature). [Link](https://docs.quanser.com/quarc/documentation/qube_servo2_usb.html)
- B. Widrow and I. Kollár, *Quantization Noise*, Cambridge University Press, 2008. The standard reference for the uniform-noise model (S2); verify the edition before citing.
