# Project Logbook: Furuta Pendulum Upright Balance Control

ELEC3304 Open Design Project. **Due 11:59 pm, Friday 6 November 2026.**

This logbook records what was done, what was decided and why, and what is still open. The actionable checklist of open work is [TODO.md](TODO.md). Add a new dated entry at the bottom for each work session. When a decision is made or reversed, also update the **Decision register**. When an issue is found or closed, update **Open issues**.

**Note on numbers:** entries dated before 2026-11-03 used J_r = m_rL_r²/12 and are kept as history. Current numbers are in docs 02–09.

AI assistance (Claude) was used throughout for derivations, code and drafting. Every entry notes this so it can be declared in the report as required by the Lecture 1 guidelines.

---

## Decision register

| ID | Date | Decision | Why | Status |
| --- | --- | --- | --- | --- |
| D-01 | 2026-10-15 | Plant: Furuta (rotary inverted) pendulum, balanced upright, linearised about α = 0 | Meets all 5 Lab 9 requirements; 4 states, 2 sensors, 1 actuator | **Confirmed**: tutor approved 2026-10-29 |
| D-02 | 2026-10-15 | Parameters from the Quanser QUBE-Servo 2 | Realistic lab hardware | Values still to be verified against a primary source (I-03) |
| D-03 | 2026-10-15 | Requirements: OS ≤ 5%, T_s ≤ 2.0 s, undershoot ≤ 10%, t_r ≥ 0.3 s, \|V\| ≤ 10 V (target ≤ 6 V) | Derived from the RHP zero (8.97 rad/s) and the voltage limit; see doc 03 | Active |
| D-04 | 2026-10-15 | Rejected a 0.4–0.8 s settling-time requirement | Needs ωₙ ≈ 10 rad/s, beyond the RHP zero: 18–38% undershoot, smaller region of attraction | Closed |
| D-05 | 2026-10-15 | Controller poles D2: −2.8 ± 2.86j, −12, −15 (ζ = 0.7, ωₙ = 4) | Meets D-03 with the lowest voltage of the candidates (D1, D3, LQR compared) | Replaced by D-19 |
| D-06 | 2026-10-15 | Add integral action on θ (extra pole at −5) | Without it a 2 mN·m arm drag leaves a 45° offset | Active |
| D-07 | 2026-10-29 | Reference enters **only through the integrator** (type-1 servo: u = −Kₓx̂ − kᵢξ) | The original structure double-counted r: 57% overshoot. Fixed: 1.5% | Active |
| D-08 | 2026-10-29 | Sensors: 512-CPR optical incremental encoders in 4× quadrature (2048 counts/rev), e.g. Broadcom HEDS-5540 #I or US Digital E5-512 | Datasheet-backed noise model; matches the QUBE-Servo 2 resolution | Active (doc 08) |
| D-09 | 2026-10-29 | Controller and observer run in discrete time at 1 kHz; observer in predictor form, driven by the saturated voltage | Matches real hardware; makes quantisation and sampling effects visible | Active |
| D-10 | 2026-10-29 | Observer poles −100, −110, −120, −130 rad/s (was −40…−55) | The slower observer left 39/500 random ±20% plants unstable; this set leaves 6/500. Noise cost: RMS u 0.09 V instead of 0.05 V | Active; may be replaced by a Kalman gain (D-12) |
| D-11 | 2026-10-29 | Course PDFs and vendor datasheets kept in `references/` but git-ignored; working scripts in `scratch/`, git-ignored | Copyrighted material must not go on the public repo | Active |
| D-12 | 2026-10-29 | Investigate a steady-state Kalman filter as the observer | Principled trade-off between noise and disturbance response; may fix I-01 and I-02 | **Closed 2026-11-04 (Jack):** Kalman removed from the report as outside the unit and brief. Doc 09 stays as background |
| D-13 | 2026-11-03 | **Arm geometry: case A.** Uniform bar with the motor at one end, so J_r = m_rL_r²/3 (was /12) | /12 is inconsistent with L_r being the motor-to-joint distance (doc 02 §4.1). Aleksei's model also uses /3 | Active; closes I-04 |
| D-14 | 2026-11-03 | **R3 settling limit relaxed to 2.5 s, for now** (was 2.0 s) | The measured 2.40 s includes quantisation ripple; 1.81 s without it. Still a design choice to be justified from the aims (I-10) | Active, provisional |
| D-15 | 2026-11-03 | Dropped the 6 V voltage target; the limit is ±10 V | With J_r = `/3` the gains are higher and 6 V isn't achievable; 10 V is inside the ±15 V drive range and 18 V motor rating | Active |
| D-16 | 2026-11-03 | **Published damping: D_r 0.0005, D_p 0.0001** (Jack's decision) | The only damping values with a source (Xu et al. 2023) | Active |
| D-17 | 2026-11-03 | Restored the pendulum spin term in the nonlinear model | Gäfvert and the QUBE model in Xu et al. keep it; an earlier claim that Quanser drops it was wrong. Linear model unchanged | Active |
| D-18 | 2026-11-03 | **Application: serving arm carrying a drink on a passive joint** (Jack's bartender idea). Tilt, speed and settling requirements derived from it | Doc 03 §4. Golf, mixer, weather station and ML benchmark considered and rejected | **Superseded 2026-11-06 by D-24** |
| D-19 | 2026-11-03 | **Final controller poles: Aleksei's,** −2.7 ± 2.38j, −10.8, −13.5, plus our integrator pole at −5 (Jack's decision) | On the updated model they meet the tap limit (14.6°) with less voltage and ripple than D2 (doc 04 §3c). Replaces D-05 | Active |
| D-20 | 2026-11-04 | **One report: ours as the base, with Aleksei's prose merged in.** Our α sign, 2.5 s settling limit, integrator and observer poles −100…−130 are kept (Jack's decision) | Our draft covers all seven sections. His observer −40…−55 gives a 20.4° tap and 10/200 unstable plants on the current model, against 14.6° and 3/200 | Active |
| D-21 | 2026-11-04 | **Report keeps to course content** (Jack's review): LQR removed from the design comparison, Kalman removed, "Luenberger" replaced by "state observer" | The brief asks for observer-based state feedback as learned in the unit. LQR stays only where the literature review discusses existing approaches, which the rubric marks | Active |
| D-22 | 2026-11-04 | **Page limit: 6 pages, not counting references and the appendix** (Jack). Tray and glass stated as a model limitation, with no redesign | Our copy of the brief says 8, so confirm on Canvas; 6 fits either way. A schooner glass alone is over twice what the motor can hold, so no redesign could make it a rig payload | Active |
| D-23 | 2026-11-06 | **Rise-time floor set by the 10 V limit, found iteratively; no payload claims** (Jack) | The gains grow with ω_n: 10 V for a 10° tilt is reached at ω_n = 5.73 rad/s (t_r ≈ 0.31 s), and an 0.8 s settling target needs 13.5 V. No payload was modelled directly, so the ±20% is justified from sources instead: copper winding resistance rises about 20% over 50 °C | Active |
| D-24 | 2026-11-06 | **Bartender framing dropped; criteria justified from the model, the motor and the literature** (Jack) | The serving arm was not modelled directly. Same numbers: 15° is the linear region, 10° is beyond the 6° of Barrios Valero, the ω_n cap is now z/2 = 5.2 rad/s from the RHP zero (Åström & Murray), 2.5 s settling is an iterative choice above the ≈1 s floor. Replaces D-18 | Active |
| D-25 | 2026-11-06 | **Aleksei's words first in Sections I–III** (Jack) | His third draft (`main (3).tex`, with unresolved merge markers) rewrote the Introduction, System Model, Aim, state-space model and design criteria. Merged in his words, converted to our symbols; key information is never cut to fit, only padding in our own wording | Active |
| D-26 | 2026-11-06 | **Minimal references: keep only those needed for a claim, preferring sources we have read** (Jack) | Izutsu, Jung, Hamza, Bélanger and Baltazar removed (claims now rest on Acosta, which was read in full, or on our own Section II-E); Åström–Furuta cited as the 1996 IFAC paper actually read. 15 references, in first-cited order | Active |
| D-27 | 2026-11-06 | **8 pages in total: 6-page body, then appendix, acknowledgment and references (IEEE order)** (Jack) | Wide appendix figures are defined at the end of the body so they can float to page 7 | Active |

---

## Open issues

| ID | Opened | Issue | Next step |
| --- | --- | --- | --- |
| I-01 | 2026-10-29 | **Closed 2026-11-04 by D-19**, confirmed by `run_all`: tap 14.6° (limit 15°) | — |
| I-02 | 2026-10-29 | **Closed 2026-11-03.** Plants that fall have a weaker motor (k_m/R_m factor 0.84 vs 1.02) and shorter arm (0.91 vs 1.01), which lower the loop gain towards its lower stability limit | In the report's Validations |
| I-03 | 2026-10-15 | Quanser workbook not read directly. Xu et al. support R_m, k_m, L_r, L_p, m_p and damping; a matching motor datasheet supports R_m, k_m. m_r still has no opened source | Find the workbook or another source for m_r |
| I-04 | 2026-10-29 | **Closed 2026-11-03 by D-13** (J_r = m_rL_r²/3). A published or measured J_r would still be better | — |
| I-05 | 2026-10-29 | Textbook chapter numbers in docs are from memory. The report draft cites no textbooks | Check only if textbooks are cited |
| I-06 | 2026-10-29 | **Closed 2026-11-03.** Anti-windup tested on arm-torque pulses to the edge of falling and on large releases: results identical or nearly so, because saturation lasts at most about 0.2 s before recovery or a fall. Kept as a safeguard | State it in the report if there's space |
| I-07 | 2026-10-29 | **Closed 2026-11-03:** `Template-Latex.zip` (IEEEtran conference template) is in the project folder. Confirm it matches Canvas | — |
| I-08 | 2026-11-03 | **Closed 2026-11-04.** Final values from `run_all`: 0.71° arm ripple, inside the ±0.6° band; T_s 1.38 s (1.43 s unquantised). D2 had 0.81° and T_s 1.97 s. Stated in the report | — |
| I-09 | 2026-11-03 | Poles agreed (D-19) and Simulink checked (2026-11-04 entry). Still open: his design script isn't in the repo, so his gain signs and his abstract's results can't be reproduced | Aleksei to add the script, or confirm those results aren't used |
| I-10 | 2026-11-03 | **Closed 2026-11-03, pending acceptance of D-18.** Settling limit derived from serving throughput, with stated assumptions (doc 03 §4) | — |
| I-11 | 2026-11-03 | **Closed 2026-11-03 by D-17** | — |
| I-12 | 2026-11-03 | **Closed 2026-11-03.** Allied Motion CL40 16705 matches R_m and k_m: 18 V, 0.54 A rated, 2.1 A stall, 22 mN·m. No opened source says the QUBE uses it, so word it as "matching constants" | — |

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

- [x] Write `docs/08_sensors_and_noise.md`: encoder choice, datasheet table (with page numbers), noise model (S1)–(S3).
- [x] Write `docs/09_kalman_filter.md` and `matlab/week11_kalman.m`. Derive the steady-state Kalman filter for this plant (process noise = torque disturbances, measurement noise = quantisation). Compare it with the pole-placed observers on noise, tap response and robustness.
- [x] Update docs 04 and 05 with the observer and validation results; add `run_all.m` (full reproduction in about 3.5 min, checked); update the README.
- [ ] Commit, then ask Jack before pushing.

### Kalman study outcome (evening)

- The steady-state Kalman gain was derived from recursive least squares (MIT 6.241J §2.6) and the DARE. It matches MATLAB's `kalman()` to 9 × 10⁻¹⁴.
- **Kalman gains beat pole placement on every measure.** Kalman Q×100 vs poles −100…−130: voltage noise 0.056 vs 0.089 V, unstable plants 3/200 vs 6/200, tap 18.8° vs 18.0°.
- **The "matched" Kalman filter (Q = the real random-torque noise) lets the pendulum fall after the tap.** Q must represent all unmodelled torques.
- **R6 (≤ 15°) is only met at Q×10⁶, with 0.53 V RMS of noise.** No observer reaches the full-state 14.1°.
- **D-12 is open, a decision for Jack.** Option A (recommended): keep the pole-placed observer as the assessed design and present the Kalman filter as the extension. Options B/C: adopt Kalman Q×100 or Q×10⁴ if the lecturer accepts it. Next technical step for I-01: a disturbance-estimating Kalman filter.

### Plan to submission

| Date | Task |
| --- | --- |
| Thu 30 Oct | Close I-03 (verify parameters), I-04 (J_r), I-05 (references). Decide the final observer (D-12) and rerun the validation |
| Fri 31 Oct – Sun 2 Nov | Draft the report in the LaTeX template: System Model, Problem Definition, Controller Design |
| Mon 3 – Tue 4 Nov | Numerical Validations, Introduction, Abstract, Conclusions; produce the final figures |
| Wed 5 Nov | Cut to 8 pages; check reproducibility from a clean clone (`run_all.m`); write the AI-use declaration |
| Thu 5 – Fri 6 Nov | Proofread and submit (report PDF and MATLAB files) |

AI-assisted today: derivations, sensor research, all new scripts, docs 02 (§2), 07, 08, 09, and this logbook.

---

## 2026-11-03 (Week 13): arm geometry decision and alignment with Aleksei

**Decision D-13: the arm is a uniform bar with the motor at one end, J_r = m_rL_r²/3.** Changed `furuta_params.m` and the sweep in `week9_model_and_openloop.m`, reran everything, and updated docs 01–09 and the README. Poles, damping and requirements were not changed.

**Reviewed Aleksei's Google Doc notes and messages.** He has finished a Simulink model and proposed writing the control design, with Jack covering testing.

- His main A and B equal ours under /3 with α flipped; a second set of his eigenvalues corresponds to D_r = 0.001, D_p = 0.00005.
- His K cannot be used in our sign convention without flipping k₂ and k₄ (otherwise a pole at +440).
- His doc contains two settling requirements (1.5 s and 0.4–0.8 s). The 0.8 s design saturates and falls after the tap.

**Effect of /3 on the current design** (same poles):

| Measure | /12 | /3 |
| --- | --- | --- |
| Unstable pole | +10.55 | +9.96 |
| K_x | [−1.86, 20.0, −0.99, 1.24] | [−5.04, 49.1, −2.08, 3.53] |
| Peak voltage, 10° tilt | 3.5 V | 8.6 V |
| Tap: max \|α\| / peak voltage | 18.0° / 5.3 V | 15.1° / 9.7 V |
| RMS voltage from noise | 0.09 V | 0.24 V |
| Monte Carlo: survive tap | 23/40 | 30/40 |

**New finding (I-08).** The measured T_s of 2.40 s comes from a quantisation limit cycle, not from the poles: T_s is 1.81 s without quantisation. The earlier 1.26 s had the same cause.

**Plan:** align with Aleksei (I-09), settle the requirements (I-10), rerun, then draft the report. See [TODO.md](TODO.md).

AI-assisted today: comparison with Aleksei's notes, code change, reruns, doc updates, this entry.

### Later on 2026-11-03: rubric, research, margins, first report draft

- **Rubric and annotated brief received** (`references/course/`, git-ignored). New requirements: stable ranges of controller parameters, Bode/Nyquist gain margins, closed-loop linear vs nonlinear comparison, modelled disturbances, up to 5 keywords.
- **R3 relaxed to 2.5 s (D-14).**
- **Literature research (doc 10).** Citations checked against Crossref; two errors in other sources corrected. Reading the sources overturned two things said earlier: `/12` matches a published QUBE value, and the spin term isn't dropped in the published models.
- **`week12_margins.m` added.** Gain margins −4.9 / +17.8 dB, phase margin 38°, delay margin 35 ms; stable range of every gain; linear vs nonlinear at 5°, 10° and 20°; design stable on published J_r and damping values.
- **Report drafted** in `report/` with the IEEE template and `build.py`. Blue prose is AI-drafted and must be rewritten by the team; red numbers depend on the pending pole decision.

AI-assisted: research, margin script, report draft.

### Evening of 2026-11-03: published damping, application, remaining engineering

**Where Aleksei's poles came from.** The same method with different choices: ζ = 0.75 for margin, ω_n = 3.6 from his t_r ≤ 0.5 s and T_s ≤ 1.5 s, fast poles at 4× and 5× σ. See doc 04 §3b.

**Decisions:** D-15 to D-18 above. Jack chose the published damping and proposed the bartender idea, which led to the serving-arm application.

**Preview on the updated model** (full pipeline, written to `scratch/preview/`, not `figures/`):

- Open-loop poles 0, −14.06, −1.75, +12.09 rad/s; zero +10.31 rad/s; 2° release passes 15° in 0.22 s.
- Our poles: T_s 1.97 s, OS 2.8%, 10° release 7.6 V, tap 15.0°.
- Aleksei's poles: T_s 1.38 s, OS 1.4%, 10° release 6.6 V, tap 14.6°. Both 0 of 300 plants unstable. **Recommended.**

**Practical note:** a preview stalled for 90 minutes because the computer slept. It wasn't a bug.

**Not done yet, deliberately:** `run_all` to `figures/`, and refreshing result numbers in docs and the report. Those wait for the team's check.

AI-assisted: research, code, previews, docs.

---

## 2026-11-04 (Week 13): Aleksei's report and Simulink merged and checked

**Report merge (D-20).** Aleksei's intro wording, energy and Euler–Lagrange steps, motor text and M, D, K linearisation are now in `report/main.tex` as black text. They were converted to our α sign and symbols. The generalised coordinate became η, because q is already the encoder step, and D and K became D_η and K_η to avoid clashing with the damping and gain symbols. His Baltazar reference was left out: it was never cited in his text and hasn't been read.

**Simulink check** (`Simulink/`, run with our A, B and K; nothing saved):

- Both models use a **linear** State-Space plant, a 4-gain K and a 1 V voltage tap. Neither has an integrator, disturbance model, reference input or encoder quantisation.
- His abstract describes a nonlinear simulation, a disturbance model and integral action, with a 1.08 s step settling time. These models can't produce those results, so those numbers were not merged.
- His observer loop agrees with ours for a 10° release and 1 V tap: peak voltage 8.45 vs 8.60 V, peak θ 23.5° vs 24.3°, peak α after the tap 4.40° vs 4.47°, RMS α difference 0.10°. The small gap is expected, as his plant is linear and sampled at no fixed rate, while ours is nonlinear at 1 kHz.
- His observer poles are −40, −45, −50, −55. In our full loop they give a 20.4° tap and 27/500 unstable plants, against 14.6° and 5/500 for −100…−130 (one set of random plants, scratch run). The `run_all` count on 200 plants is 10 against 3.

**Sources.** Barrios Valero read (§5.1): pole placement in simulation, three poles with torque as the input, plot starts just above 0.1 rad. Acosta's full text was blocked on every mirror tried, so its claims stay marked for a person to check.

AI-assisted: merge, Simulink comparison, source checks, this entry.

### Later on 2026-11-04: `run_all`, and everything refreshed

- **`run_all` run to `figures/`** with the agreed poles, then re-run after adding metrics to `week12_validation.m` (V2 ripple and unquantised T_s, V3 tap recovery and true-state tap, V4 means over 2 s, new V8 and V9), `week11_kalman.m` (true-state count) and `week10_state_feedback.m` (LQR poles), so every number in the report comes from the scripts. Log: `scratch/run_all_2026-11-04.log`.
- **Report:** all numbers refreshed; Controller Design rewritten for D4; red marks removed. It is 8 pages in draft and 7 with `--final`, because the draft marks take space.
- **Docs 01–07, 09, 10 and the README refreshed.** Doc 06's hand derivation is redone for D4 and agrees with the script's output.

**Final results:** T_s 1.38 s, OS 1.4%, t_r 0.75 s; 10° recovery 0.97 s at 6.6 V; tap 14.6° at 9.0 V; PM 36°, GM ×0.59 / ×6.74; region of attraction 24°.

**Things to be honest about in the viva or report:**

- The tap passes by only 0.4°.
- R8 is partial: 38/40 recover, 31/40 survive the tap, and 3/200 plants are linearly unstable (1/200 even with the true state).
- At higher damping (0.0015, 0.0005) the loop is close to marginal, with a slow wobble of about 1 V RMS.
- Earlier "0 of 300 unstable" was one random sample. Quote counts with their sample size.

AI-assisted: script additions, reruns, report and doc refresh, this entry.

### Evening of 2026-11-04: Jack's review notes applied

Jack compared the Overleaf copy with the repo (identical) and listed review notes in `docs/TODO.md`.

- **Report:** LQR and Kalman removed (D-21). Each design D1–D4 now explained. Design criteria expanded, each derived from an aim. Disturbances listed explicitly. The 30° step defined. Figure 5 explained panel by panel. Observer section now has an analytical derivation of L.
- **Correction:** "error below 2% within 0.11 s" was only the first brief dip. The error norm settles on a noise floor above 2%. The report and doc 04 now give the peak, the floor and the RMS errors.
- **Code:** `week11_observer.m` now produces the observer-speed table, the analytical L and the Figure 5 numbers, so the report no longer depends on `week11_kalman.m`. `run_all` and the Canvas zip skip that script. Results are unchanged.
- **Marking criteria** copied to `references/course/marking_criteria.md` (git-ignored).

AI-assisted: all of the above.

### Aleksei's second draft, and a tray-mass check

**Merged in his words, with our symbols:** the stacking step to the block state-space form, the sentence on testing state feedback with the full state in simulation, the three arm-modelling elements, and his grouped parameter table (our `Basis` column kept). Figures were trimmed again to stay at 8 pages.

**Not merged:**

- His statement that all parameters come from Xu et al. It doesn't list m_r, and its arm inertia corresponds to `/12`.
- Räsänen & Pyrhönen 2019: not cited in his text, and one search found no record of it.
- His abstract's results, as these still can't be reproduced from the repo (I-09).

**Tray mass check** (`scratch/tray_mass_study.m`, not yet in `run_all`). The model has no tray. A point mass m_t at the pendulum tip can be represented exactly by changing m_p, L_p and J_p to equivalent values.

| m_t | Unchanged gains | Same poles, redesigned for that mass |
| --- | --- | --- |
| 0 g | Stays up: tap 14.6° | Tap 14.6°, 10° release 6.6 V, RMS u 0.22 V |
| 10 g | Stays up: tap 10.9° | Tap 7.4°, 8.3 V, 0.29 V, T_s 2.70 s |
| 20 g | Stays up: tap 9.3° | Tap 5.2°, 9.2 V, 0.33 V, T_s 2.75 s |
| 30 g | **Falls** (max \|z\| 0.9995, stable but saturates) | Tap 4.1°, 9.7 V, 0.35 V, T_s 2.69 s |
| 50 g | **Falls** (linearly unstable) | Tap 3.0°, 10.0 V, 0.37 V, T_s 2.97 s |

The tap shrinks because the same 20 mN·m pulse acts on more inertia, so those tap figures don't show that a real bump would be easier. With a tip mass the arm ripple starts to touch the ±0.6° band, so T_s moves between about 1.4 s and 2.7 s, and at 100 g it never settles in the 4 s test. The 35 mm glass used for the tilt and slosh criteria holds at least 135 mL at H = R, close to the 141 g at which gravity at 15° reaches the motor's stall torque, so the rig couldn't carry that glass.

AI-assisted: merge, tray study, this entry.

### Report restructured to six pages

No simulation was run for this: text and layout only, using the numbers already logged.

- **Appendix:** Bode/Nyquist, linear vs nonlinear, and observer convergence figures moved there, after the references. The overview and Monte Carlo figures stay in the body.
- **Removed:** the open-loop figure (its 0.22 s result stays in the text; the script still produces it), a repeated block equation, and the sampled gain's matrix display.
- **`build.py`** now checks the body against 6 pages, counting the references label and the body figures. A first version counted only the text and reported 6 while two figures sat on page 7.
- **Prose trimmed** across the AI-drafted text, mainly the Introduction, with no numbers changed. Cazzolato & Prime dropped (it was unread), along with the table row repeating the plant-input gain range.
- **Tray limitation** added to Section II-C. The ±20% section stays, and now says it covers parameter error of about ±5 g on the pendulum, not a glass being added or removed. An earlier line wrongly said taking a glass was covered by that uncertainty.
- **`matlab/week12_tray_mass.m`** is `scratch/tray_mass_study.m` with only its path setup removed. It hasn't been run from that location yet; the fresh-clone check should run it once.

### Sign convention check

Checked symbolically, with no simulation: the report's energies give its equations of motion, these match `furuta_nl.m`, and its M, D and K give the printed A and B. Aleksei's draft is self-consistent but uses the opposite α direction: substituting α → −α turns his equations into ours. A(3,2), A(3,4), A(4,3) and B(4) change sign, and so would k_α and k_α̇. The α direction is stated in the report only, not in his draft. His Simulink's sign can't be checked, because the script that sets its A, B and K isn't in the repo (I-09).

## 2026-11-06 (due today): Aleksei's third draft merged

Checked first: the Overleaf copy Jack pasted is identical to GitHub `de928cb`, so no human edits had been made to `report/main.tex` since 4 Nov.

**Merged in his words, with `r` for his θ_ref:**

- his actuator limitation (Section II-D), with our citation and motor ratings kept
- his aim and operating point, replacing our blue III-A
- his summary of the design requirements, at the start of III-C

**Not merged:**

- his numeric A, open-loop poles (+9.96) and zero (+8.97), which are from the old damping and use his opposite α sign
- his requirements table, which uses T_s ≤ 1.5 s (ζω_n ≥ 2.67) against the agreed 2.5 s
- the unfinished sentence "This desing could be used as a"
- his disturbance paragraph, which is our earlier text that the expanded list replaced

**To fit 6 pages:** these cuts were made, with no numbers changed:

- Tang et al. (unread) and the LQR sentence citing it
- the back-EMF sentence, which his limitation now covers
- the criteria items his paragraph now states
- some shorter wording elsewhere
- the two body figures, shrunk slightly

AI-assisted: merge and fit.

### Speed limit from the voltage limit; ±20% justified from sources

- **Step 7 added to `week10_pole_placement_derivation.m`** (gains only, no simulation; runs in seconds). With ζ = 0.75 and fast poles at 4σ and 5σ, the first voltage for a 10° release is 4.6 V at ω_n = 3.6 and reaches 10 V at ω_n = 5.73 rad/s. An 0.8 s settling target needs ω_n = 6.67 rad/s and 13.5 V. These are true-state numbers; the full loop uses more (6.6 V on the release).
- **Report Section III-C:** a new criterion item sets t_r ≥ 0.3 s from the voltage limit and states the iteration. Slosh stays as the cap on ω_n.
- **Payload claims removed** (Jack: not modelled directly). Section II-C now justifies the ±20% from the copper temperature coefficient (IEC 60028, seen in a secondary copy) and the motor's −10 to 60 °C operating range. `week12_tray_mass.m` stays in the repo as background, but is no longer in the Canvas zip.
- Three short AI-drafted phrases were trimmed to stay at 6 pages.
- **Introduction:** the serving arm is now stated as the motivation for the requirements only ("no drink is modelled"); the duplicate sentence in Section II-C and "or takes a glass" in the tray-bump item were removed. Still 6 pages.

### Bartender framing dropped (D-24)

- **Report:** abstract, introduction, Section II-C disturbances and every Section III-C criterion now justified from the linear model, the motor and published results. No numbers changed, no simulation run. The slosh limit (ω_n ≲ 4.5 rad/s) is replaced by the RHP-zero bound z/2 ≈ 5.2 rad/s; the design (ω_n = 3.6) meets both. The tap is now "Tap on the pendulum".
- **References:** Heins & Schoellig, Biagiotti et al., Reclari et al. and Makr Shakr removed. Åström & Murray, *Feedback Systems* (2nd ed., 2021) added for the z/2 bound, marked orange until the section is checked.
- **Section II-C:** Xu et al.'s arm inertia now worded as "a smaller arm inertia, equivalent to m_rL_r²/12".
- Still 6 pages, 0 warnings.

### Jack's wording for Section II merged

- Sections II-A (sign convention and assumptions), II-B (parameters) and the first part of II-C (simplifications, uncertainty, ±20%) are now Jack's words, in black. Sign corrected to our convention (positive α leans *against* positive arm rotation). Blue blocks 32 → 30. Still 6 pages.
- **Arm ±90° limit** reworded as a workspace limit we chose, not a hardware (encoder cable) limit, which was never verified. Not binding (57° after the tap), and the Monte Carlo survival test uses α only, so no results change. One orange item cleared.

### Jack's Section IV questions answered in the text

- **"Region above"** now names the pole region of Section III-C.
- **26° drag offset explained:** a steady 0.4 V (τ_d R_m/k_m) is needed to hold the arm against the drag, and without an integrator it can only come from an angle error 0.4/|k_θ|, with k_θ = −0.90 for D4 without the integrator (Ackermann on the report's A, B gives 25.4°; the simulation gave 26°).
- **Integrator:** augmented model [A 0; C_θ 0], [B; 0], −[0; 1]r added; ξ is computed from the measured θ, so the observer still estimates x only.
- **Observer derivation:** motivation (closed form, check on `place`), the substitution e_2 = ė_1 + L_1e_1, and why the diagonal choice decouples the two angle errors.
- Trims to stay at 6 pages: D1 "misses overshoot" sentence, L_d entries, D2/D4 noise voltage, D3 poles (in Table III), shorter conclusion.

### Papers folder checked; arm mass; AI declaration drafted

- **Acosta 2010 read in full:** the Introduction's claims hold (Sec. 3.2; Fig. 6: LQR 0.75 rad, energy shaping 0.82 rad, on hardware). Orange marks removed. His rig has a slip ring on the arm joint, now cited for the ±90° being our choice.
- **Rocket claim:** the NASA SLS pole-cart paper (Pei & Rothhaar) is about launch vehicles, so "rocket landings" became "unstable launch vehicles". Venue and year still to confirm.
- **Friction:** Bellati et al. (IEEE URUCON 2021, read) replaces the unread Gäfvert 1999 for Coulomb friction and stiction.
- **Arm mass:** no source found, so checked against a solid aluminium bar, L_r × 20 × 20 mm at 2700 kg/m³ = 0.092 kg, within 3% of 0.095 kg.
- **AI declaration:** Lecture 1-2 says only "ask an LLM agent, but be critical"; the brief says AI agents follow the Lecture 1 guidelines. Draft in the Acknowledgment, orange until checked.
- **Drag numbers:** Section V-D said 39° without the integrator (final gains with k_i switched off, mean over 5–6 s) while Section IV says 26° (D4 designed without an integrator). V-D now points to Section IV instead.
- Trims to stay at 6 pages. Orange 15 → 11.

### Aleksei's third draft merged (D-25)

- **Source:** `main (3).tex` from Aleksei, based on our commit 69daef3 and still containing git conflict markers (`<<<<<<< HEAD` … `>>>>>>> 64eb98d`). His side of each conflict is his new text; everything outside the conflicts was our old version, so Sections IV–VI keep the current text.
- **Taken in his words:** Introduction; System Model (J̄_p and l_p = L_p/2 in place of c, separate k_t and k_m, the Gäfvert sign note, a Linearisation subsection, Parameters, Disturbances, Sensors and noise, Limitations); Aim; State-space model (symbolic A_21, A_22, B_2, C and D, regulated output C_r); design criteria with his justifications (Skogestad z/2 bound, Baltazar 1.68 s, limits).
- **Changed for consistency:**
  - q → η for the generalised coordinates, since q is the encoder resolution.
  - θ_ref → r, as in the rest of the report.
  - "Luenberger observer" → "state observer" (earlier decision); there is no Luenberger bibitem.
  - "rocket landings" → "unstable launch vehicles" [Pei].
  - The ±90° arm bound is now a workspace limit, not the encoder cable (Section II-F).
  - The structure sentence now names all six sections.
  - The motor inductance sentence was removed from Section II-F, since his Section II-A now gives the 0.14 ms.
  - Section IV: τ_dR_m/k_t, and C_r replaces C_θ.
  - Section V-E now points to Section II-F, and the Monte Carlo text uses k_t/R_m.
- **Kept from ours:**
  - Table II (criteria with results), because Section V needs it. His "time-based criteria" table repeats three of its rows, so it was not added.
  - The parameter table's "Basis" column with sources; his version had units only.
  - The encoder offset b, which Section V-D uses.
  - Jack's simplification and ±20% paragraphs, now in Section II-F.
  - The voltage-limit iteration (D-23), added to his "Speed" justification.
  - The aluminium-bar check on m_r.
- **Figure:** his open-loop release figure (`w9_openloop_release.png`) is in the Appendix, cited from the Introduction.
- **References:**
  - Added Skogestad & Postlethwaite (2005) and Baltazar et al. (2024), both orange.
  - Removed Åström & Murray (his Skogestad citation covers the z/2 bound) and Antonio-Cruz and Arai (no longer cited).
  - The abstract no longer mentions unactuated arm joints.
- **Page fit:** some AI-drafted detail was cut, then restored when Jack said key information must not be deleted. The body fits instead by inlining four short equations (Euler–Lagrange, V, the linearised equation, C and D) and two redundant AI phrases. The overview figure is at 0.6 of the text width.

### Geometry diagram and tone pass

- **`report/furuta_diagram.py`** (matplotlib) draws `figures/furuta_diagram.png`: (a) a 3D view with the motor axis, θ from θ = 0, the arm (L_r, m_r) and the pendulum leaning against +θ̇ by α; (b) the view from the motor along the arm, with α clockwise, l_p = L_p/2, L_p and m_pg. Lengths are drawn to Table I. It is in the Appendix and cited from Section II.
- **Tone pass on the blue text** (Jack's request): reworded towards Jack's style ("we", "hence", "as", "which", fewer colons and semicolons). No content or numbers changed; the text stays blue. The wordiest changes were pulled back to keep the 6-page body.

### Independent marking and fixes (D-26, D-27)

- **Marker (a subagent, strict reading of the rubric): 83/100.** Points lost: Intro clarity and model justification (−2), System Model disturbance basis and noise effect (−3), Problem Definition clarity (−3), Numerical Validations figures and alternative method (−8), Conclusion numbers (−1).
- **Text fixes:**
  - **Introduction:** split into three paragraphs; the "However…" and "more things that can move" sentences replaced; Gäfvert's model justified by Xu's matching structure.
  - **Section II:** the drag basis is now a fifth of Gäfvert's 10 mN·m Coulomb friction; the 10 V limit is a design choice everywhere; the tilt that saturates is named (20° needs 13 V).
  - **Section III:**
    - the "external masses" sentence is deleted and the III-B list that repeated Section II is condensed;
    - ω_B and ω_n are now distinguished, and the cos α error (3.4%) is stated;
    - the voltage iteration moved to IV-B.
  - **Section IV:** k_θ = −0.90 labelled as D4 without the integrator; the integrator pole position explained; Table III caption now says no integrator; the Doyle claim matched to what the paper shows.
  - **Section V:** the noise result (V5) is reported; the 1.38 s settling-time caveat added; an alternative method given for the ±20% miss (faster observer: 2/200 at 2.3× noise; disturbance estimation).
  - **Conclusion:** results with numbers; "testing revealed" (it was the linear model).
  - **Acknowledgment:** says which sections AI drafted, and how to reproduce (run_all.m).
- **Figures** were re-exported at their printed size (8 pt text). No numbers changed: the rerun reproduced V1–V9, the Monte Carlo and Table IV exactly.
  - **Monte Carlo:** failed plants in red, legend, ±60° axis, no title.
  - **Overview:** at 0.7 of the text width; the legend moved off the curve.
  - **Observer convergence:** θ̇ and α̇ labels; units on ‖e‖.
  - **Captions:** the open-loop caption is corrected (agree to about 30°); Fig. 6 text notes the 13 V and the arm angles are not plotted.
- **Space** came from duplicates (the 10 V point stated three times, a III-B remark, Table I rows repeating values in II-E and II-F) and from inlining two short displays. No key information was cut.
- **Structure:** IEEE order (Appendix, Acknowledgment, References), references in first-cited order, "Fig." mid-sentence. The PDF is now 8 pages.

### Submission package and reproducibility check

- **Portal requirement:** zip only, for an independent reader to reproduce the results. `build.py --package` now adds:
  - `Simulink/` (Aleksei's linear-plant models, marked supplementary);
  - `python/furuta_diagram.py` (Fig. 3);
  - a full `README.txt` (`report/package_README.txt`: requirements, steps, fixed seeds, and which script reproduces each figure, table and equation);
  - `expected_results.txt`.
- **Clean run:** unzipped into an empty folder and ran `run_all` there. Exit 0 in 267 s, 14 figures, and every number matches the report (V1–V9, margins, gain ranges, Step 7, observer gain). That console output is `report/expected_results.txt`.
