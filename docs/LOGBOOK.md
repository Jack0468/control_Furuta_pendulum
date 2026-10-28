# Project Logbook: Furuta Pendulum Upright Balance Control

ELEC3304 Open Design Project. **Due 11:59 pm, Friday 6 November 2026.**

This logbook records what was done, what was decided and why, and what is still open. Add a new dated entry at the bottom for each work session. When a decision is made or reversed, also update the **Decision register**. When an issue is found or closed, update **Open issues**.

AI assistance (Claude) was used throughout for derivations, code and drafting. Every entry notes this so it can be declared in the report as required by the Lecture 1 guidelines.

---

## Decision register

| ID | Date | Decision | Why | Status |
| --- | --- | --- | --- | --- |
| D-01 | 2026-10-15 | Plant: Furuta (rotary inverted) pendulum, balanced upright, linearised about α = 0 | Meets all 5 Lab 9 requirements; 4 states, 2 sensors, 1 actuator | **Confirmed**: tutor approved 2026-10-29 |
| D-02 | 2026-10-15 | Parameters from the Quanser QUBE-Servo 2 | Realistic lab hardware | Values still to be verified against a primary source (I-03) |
| D-03 | 2026-10-15 | Requirements: OS ≤ 5%, T_s ≤ 2.0 s, undershoot ≤ 10%, t_r ≥ 0.3 s, \|V\| ≤ 10 V (target ≤ 6 V) | Derived from the RHP zero (8.97 rad/s) and the voltage limit; see doc 03 | Active |
| D-04 | 2026-10-15 | Rejected a 0.4–0.8 s settling-time requirement | Needs ωₙ ≈ 10 rad/s, beyond the RHP zero: 18–38% undershoot, smaller region of attraction | Closed |
| D-05 | 2026-10-15 | Controller poles D2: −2.8 ± 2.86j, −12, −15 (ζ = 0.7, ωₙ = 4) | Meets D-03 with the lowest voltage of the candidates (D1, D3, LQR compared) | Active |
| D-06 | 2026-10-15 | Add integral action on θ (extra pole at −5) | Without it a 2 mN·m arm drag leaves a 45° offset | Active |
| D-07 | 2026-10-29 | Reference enters **only through the integrator** (type-1 servo: u = −Kₓx̂ − kᵢξ) | The original structure double-counted r: 57% overshoot. Fixed: 1.5% | Active |
| D-08 | 2026-10-29 | Sensors: 512-CPR optical incremental encoders in 4× quadrature (2048 counts/rev), e.g. Broadcom HEDS-5540 #I or US Digital E5-512 | Datasheet-backed noise model; matches the QUBE-Servo 2 resolution | Active (doc 08) |
| D-09 | 2026-10-29 | Controller and observer run in discrete time at 1 kHz; observer in predictor form, driven by the saturated voltage | Matches real hardware; makes quantisation and sampling effects visible | Active |
| D-10 | 2026-10-29 | Observer poles −100, −110, −120, −130 rad/s (was −40…−55) | The slower observer left 39/500 random ±20% plants unstable; this set leaves 6/500. Noise cost: RMS u 0.09 V instead of 0.05 V | Active; may be replaced by a Kalman gain (D-12) |
| D-11 | 2026-10-29 | Course PDFs and vendor datasheets kept in `references/` but git-ignored; working scripts in `scratch/`, git-ignored | Copyrighted material must not go on the public repo | Active |
| D-12 | 2026-10-29 | Investigate a steady-state Kalman filter as the observer | Principled trade-off between noise and disturbance response; may fix I-01 and I-02 | In progress (doc 09) |

---

## Open issues

| ID | Opened | Issue | Next step |
| --- | --- | --- | --- |
| I-01 | 2026-10-29 | R6 not met: a 20 mN·m, 20 ms pendulum tap gives max \|α\| = 18° with the observer (limit 15°; full-state feedback gives 14°) | Kalman / disturbance observer study (doc 09); otherwise report it as a limitation |
| I-02 | 2026-10-29 | Monte Carlo (±20%, 40 plants): all 40 are linearly stable, but 4/40 fail to recover from 10° on the nonlinear plant and only 23/40 survive the tap | Identify the failing parameter combinations; test the Kalman gain |
| I-03 | 2026-10-15 | Quanser parameters and workbook citation come from memory and have not been verified | Get the QUBE-Servo 2 manual or workbook from the tutor/Canvas; otherwise cite Cazzolato & Prime and the datasheets only |
| I-04 | 2026-10-29 | J_r = m_rL_r²/12 assumes the arm pivots at its centre; /3 if it pivots at one end (stable poles −30 → −17.7) | Check the hardware/manual; rerun with the correct value |
| I-05 | 2026-10-29 | Textbook chapter numbers in the reference lists are from memory | Check against library editions before the report |
| I-06 | 2026-10-29 | Anti-windup made no difference to the region of attraction (22° both ways) | Expected: saturation episodes are short. State this in the report, or find a test where it matters |
| I-07 | 2026-10-29 | LaTeX report template not yet supplied | Jack to provide; then start drafting |

---

## 2026-10-15 (Week 9–10 practicals)

**Goal:** choose the plant, build the model, and design state feedback (Labs 9 and 10).

Work done:

- **Feasibility (D-01).** Assessed the upright Furuta pendulum against the five Lab 9 requirements. Feasible; the only caveat was the "not a lecture example" rule.
- **Model.** Set up the nonlinear Lagrangian model, the DC motor model, and the linearisation about upright (doc 02).
  - Open-loop poles: 0, −30.05, **+10.55**, −6.12 rad/s.
  - Reachable (rank 4). Observable from θ and α (rank 4), but not from α alone (rank 3).
  - θ/V_m has a **RHP zero at +8.97 rad/s**: non-minimum phase.
- **Requirements (D-03).** Answered the Lab 10 A1 questions (doc 03) and converted them into pole locations.
- **Designs (D-05).** Compared D1 (aggressive), D2, D3 (slow) and LQR. Chose D2: T_s 1.67 s, OS 4.7%, 2.4 V at a 10° tilt, recovers from up to 31° (nonlinear, full state).
- **Integral action (D-06).** A constant 2 mN·m arm drag leaves the arm 45° off target without it; adding an integrator gives a 0.00° error.
- **Settling-time question (D-04).** Analysed and rejected a 0.4–0.8 s settling-time requirement.
- **Pole-placement derivation.** Wrote the hand derivation (doc 06): coefficient matching, with Ackermann and `place` agreeing to 7 × 10⁻¹⁵. Found β₂ = 0, a structural property that makes the hand solution sequential.
- **Figures** for Lab 10 A2–A3: pole map, design comparison, nonlinear tests.

Commits: `b78618a`, `3c9ed74`, `a9bf321`. AI-assisted: model derivation, scripts, docs 01–06.

---

## 2026-10-29 (Week 12): observer, sensors, validation

**Goal for today:**

1. Respond to the final project brief.
2. Build the mandatory observer-based controller.
3. Base the sensor noise on real datasheets.
4. Run the full validation.
5. Investigate the Kalman filter.
6. Set up the documentation (this logbook).

### Context

- **Tutor confirmed the Furuta pendulum is acceptable** (closes the D-01 caveat).
- **Read the Open Design Project brief** (`references/course/`).
  - **Hard requirements we hadn't met yet:** observer-based feedback is mandatory; validation must include noise, uncertainty and estimation-error convergence; all references must be independently verified; AI use must be declared.
  - **Report:** IEEE style, ≤ 8 pages, LaTeX (template to come).

### Work done (morning)

1. **Code explained from first principles (doc 07).**
   - Re-derived the Lagrangian from scratch. This exposed a **sign-convention error in the text of doc 02**: positive α leans *against* positive arm rotation. The equations and code were already correct; only the wording was fixed.
   - Flagged the J_r pivot assumption (I-04).
2. **Equations of motion fully referenced (doc 02 §2).**
   - Wrote out every step of the derivation, numbered (M1)–(M21), with sources.
   - Confirmed the Cazzolato & Prime (2011) citation (doi:10.1155/2011/528341).
   - Marked the Quanser workbook as unverified (I-03).
3. **Sensor research (D-08, doc 08).**
   - Downloaded and read the Broadcom HEDS-5540 and US Digital E5/EM1 datasheets.
   - Noise model: quantisation q = 2π/2048 = 3.07 mrad, σ = q/√12 = 0.886 mrad. Position error (10 arcmin typical, 40 max) is a slow offset, not white noise.
   - Also checked the MIT 6.241J notes (Dahleh, Dahleh & Verghese): §2.6 derives the Kalman gain from recursive least squares, which is used in doc 09.
4. **Repo organisation (D-11).** Added `references/` with an index of sources, and `scratch/`; both are git-ignored except the index.

### Work done (afternoon): observer and validation

5. **New code:**
   - `furuta_design.m`: all final gains in one place.
   - `furuta_sim_obs.m`: 1 kHz sampled-data loop with encoder quantisation, offsets, noise, saturation, anti-windup and the observer.
   - `week11_observer.m`: observer design and tests.
   - `week12_validation.m`: tests V1–V7.
6. **Observer design (D-09).**
   - Discrete Luenberger observer, predictor form.
   - **Separation principle verified numerically**: the closed-loop eigenvalues equal the controller's plus the observer's, to 1.6 × 10⁻¹³.
   - The observer's velocity estimate has an RMS error of 2.6 deg/s; differentiating the encoder gives 29 deg/s, because one count per sample is 176 deg/s.
7. **Bug found and fixed: step overshoot (D-07).** The first validation showed 57% overshoot on a 30° step. Diagnosis: the reference was fed through both Kₓ and the integrator. Switching to the type-1 servo structure gave 1.5% overshoot and T_s = 1.26 s with the same gains.
8. **Robustness problem found (D-10).**
   - The Monte Carlo test showed the observer erodes robustness. Over 500 random ±20% plants: 1 unstable with full state, 111 with a slow observer, 39 with the medium one, 6 with the fast one.
   - The failing plants have a weaker motor than modelled (k_m low, R_m high).
   - This matches the known result that observer-based feedback has no guaranteed robustness margins (Doyle, 1978). Moved the observer to −100…−130.
9. **Validation results** (nonlinear plant, quantised encoders, saturation, observer in the loop):

| Test | Result | Requirement |
| --- | --- | --- |
| V1 recovery from 10° | \|α\| < 1° after 0.96 s; max 3.5 V; max \|θ\| 34.5° | R2 ✔, R5 ✔, R9 ✔ |
| V2 30° arm step | T_s 1.26 s, t_r 0.65 s, OS 1.5%, US 2.0%, max 0.46 V | R3 ✔, R4 ✔ |
| V3 tap 20 mN·m × 20 ms | max \|α\| 18.0°, max \|θ\| 62.8°, max 5.3 V | **R6 ✘ (15°)**, R9 ✔ |
| V3 arm drag 2 mN·m | final θ error 0.12° (53° without integrator) | R7 ✔ |
| V4 encoder offset 10 / 40 arcmin | final θ error 0.04° / 0.21° (5.5° / 21° without integrator) | Integrator also removes the sensor bias |
| V5 quantisation + torque noise | RMS u 0.091 V, RMS α 0.08°, RMS θ 0.33° | Feasible voltage |
| V6 Monte Carlo ±20% (40) | 40/40 linearly stable; 36/40 recover from 10°; 23/40 survive the tap | **R8 partial** (I-02) |
| V7 region of attraction | 22° with observer (31° full state) | — |

### Plan for the rest of today

- [ ] Write `docs/08_sensors_and_noise.md`: encoder choice, datasheet table, noise model.
- [ ] Write `docs/09_kalman_filter.md` and `matlab/week11_kalman.m`. Derive the steady-state Kalman filter for this plant (process noise = torque disturbances, measurement noise = quantisation). Compare it with the pole-placed observers on noise, tap response and robustness, then decide D-12.
- [ ] Update docs 04 and 05 with the observer and validation results; add `run_all.m`; update the README.
- [ ] Commit, then ask Jack before pushing.

### Plan to submission

| Date | Task |
| --- | --- |
| Thu 30 Oct | Close I-03 (verify parameters), I-04 (J_r), I-05 (references). Decide the final observer (D-12) and rerun the validation |
| Fri 31 Oct – Sun 2 Nov | Draft the report in the LaTeX template: System Model, Problem Definition, Controller Design |
| Mon 3 – Tue 4 Nov | Numerical Validations, Introduction, Abstract, Conclusions; produce the final figures |
| Wed 5 Nov | Cut to 8 pages; check reproducibility from a clean clone (`run_all.m`); write the AI-use declaration |
| Thu 5 – Fri 6 Nov | Proofread and submit (report PDF and MATLAB files) |

AI-assisted today: derivations, sensor research, all new scripts, docs 02 (§2), 07, 08, 09, and this logbook.
