# TODO: What Is Still Open

**Due: 11:59 pm Friday 6 November 2026.** Last updated 2026-10-29.

Tick items off here as they are done. When an item closes a logbook issue (I-xx) or decision (D-xx), also update [LOGBOOK.md](LOGBOOK.md). The engineering is mostly complete. The main remaining work is decisions, verifying sources, and writing the report.

"Who" is a suggestion: **Jack**, **Team** (both group members), or **Claude** (AI-assisted; declare this in the report).

---

## 1. Decisions (blocking other work)

| Done | ID | Task | Who | By | Notes |
| --- | --- | --- | --- | --- | --- |
| [ ] | D-12 | Choose the observer for the report | Jack | Thu 30 Oct | Recommended: pole-placed observer (−100…−130) as the main design, Kalman filter as the innovation section. Ask the lecturer whether a Kalman filter counts as "observer-based feedback as learned in this unit". See [doc 09 §6](09_kalman_filter.md) |
| [ ] | I-01 | Decide how to handle R6 (tap: 18° vs a 15° limit) | Jack | Thu 30 Oct | Option 1: relax R6 to about 20°, justified by the 22° region of attraction. Option 2: a disturbance-estimating Kalman filter (about half a day) |
| [ ] | — | Push the pending local commit to GitHub | Jack | Thu 30 Oct | Local `main` is 1 commit ahead of `origin/main` |

## 2. Engineering

| Done | ID | Task | Who | By | Notes |
| --- | --- | --- | --- | --- | --- |
| [ ] | I-02 | Explain the Monte Carlo failures: 4/40 plants don't recover from 10° on the nonlinear model; only 23/40 survive the tap | Claude | Thu 30 Oct | Find which parameter combinations fail (weak motor? saturation?) so the report can explain them |
| [ ] | I-01 | (Only if option 2 is chosen) Disturbance-estimating Kalman filter: pendulum torque as a 5th state | Claude | Fri 31 Oct | [doc 09 §7](09_kalman_filter.md) |
| [ ] | I-06 | Anti-windup: find a test with sustained saturation where it matters, or state that it had no effect | Claude | Fri 31 Oct | Region of attraction is 22° with and without it |
| [ ] | — | If D-12 picks a Kalman gain: put it in `furuta_design.m` and rerun `run_all` | Claude | after D-12 | Updates V1–V7 and every figure |
| [ ] | — | Update stale docs: doc 01 (still says "check with tutor"), and doc 03's requirements table (add final pass/fail) | Claude | Thu 30 Oct | |
| [ ] | — | Optional: a 2-D Kalman Q sweep (arm vs pendulum noise ratio) | Claude | if time | [doc 09 §7](09_kalman_filter.md) |

## 3. Verification (the brief: "all references must be cited and independently verified")

| Done | ID | Task | Who | By | Notes |
| --- | --- | --- | --- | --- | --- |
| [ ] | I-03 | Check the QUBE-Servo 2 parameters (m_r, L_r, m_p, L_p, R_m, k_m, D_r, D_p, V_max) against the Quanser manual or workbook | Jack | Fri 31 Oct | Ask the tutor or check Canvas. If unavailable, cite only Cazzolato & Prime and the datasheets, and label the parameters "typical values" |
| [ ] | I-04 | Does the arm pivot at its centre or at one end? | Jack | Fri 31 Oct | Change `P.Jr` in `furuta_params.m` (`/12` → `/3` for an end pivot), then rerun `run_all` |
| [ ] | I-05 | Check the textbook chapter and section numbers against library editions | Team | Mon 3 Nov | Ogata; Franklin–Powell–Emami-Naeini; Goldstein; Spong; Hibbeler; Anderson & Moore; Widrow & Kollár |
| [ ] | — | Open and check every paper cited in the Introduction | Team | Tue 4 Nov | Required by the brief |
| [ ] | — | Write the AI-use declaration (Lecture 1 guidelines) | Team | Wed 5 Nov | The logbook records what was AI-assisted each day |

## 4. Report (IEEE LaTeX, max 8 pages)

| Done | ID | Task | Who | By | Source material |
| --- | --- | --- | --- | --- | --- |
| [ ] | I-07 | Get the LaTeX template | Jack | Fri 31 Oct | Blocks everything below |
| [ ] | — | Choose the 6–8 figures | Team | Sat 1 Nov | Candidates in [doc 05](05_test_plan.md): open-loop release, pole map, observer convergence, Kalman trade-off, validation overview, integrator drag, Monte Carlo |
| [ ] | — | §3 System Model (20%): derivation (condensed), parameter table, sensor noise model, limitations | Team | Sun 2 Nov | Docs 02, 08 |
| [ ] | — | §4 Problem Definition (20%): aims, operating point, linear model, requirements R1–R9 | Team | Sun 2 Nov | Docs 02 §3, 03 |
| [ ] | — | §5 Controller Design (25%): reachability, observability, gains, integrator, observer, separation principle, Kalman comparison | Team | Mon 3 Nov | Docs 04, 06, 09 |
| [ ] | — | §6 Numerical Validations (20%): V1–V7 against the requirements; discuss every figure | Team | Tue 4 Nov | Doc 05 results table |
| [ ] | — | §2 Introduction (7%): motivation, review of Furuta pendulum control approaches, report outline | Team | Tue 4 Nov | Doc 01, plus a literature search |
| [ ] | — | §1 Abstract (3%) and §7 Conclusions (5%): findings, limitations, future work | Team | Tue 4 Nov | LOGBOOK |
| [ ] | — | Cut to 8 pages; check notation is consistent; every figure is referenced and discussed in the text | Team | Wed 5 Nov | |

## 5. Before submission

| Done | Task | Who | By |
| --- | --- | --- | --- |
| [ ] | Clone the repo fresh, run `run_all`, and check every number and figure in the report matches | Team | Wed 5 Nov |
| [ ] | Package the MATLAB files for Canvas (the brief requires code that reproduces the results) | Jack | Thu 5 Nov |
| [ ] | Check the PDF: machine-readable, ≤ 8 pages, IEEE format, all seven required sections | Team | Thu 5 Nov |
| [ ] | Proofread | Team | Thu 5 Nov |
| [ ] | Submit the report PDF and MATLAB files on Canvas | Jack | **Fri 6 Nov** |

---

## Done (for reference)

Closed items, newest first. Details are in the [LOGBOOK](LOGBOOK.md).

- [x] Kalman filter derivation and trade-off study (doc 09), 2026-10-29
- [x] Observer-based control at 1 kHz, validation V1–V7, `run_all.m`, 2026-10-29
- [x] Type-1 servo fix for step overshoot (D-07); faster observer for robustness (D-10), 2026-10-29
- [x] Encoder selection and datasheet noise model (doc 08), 2026-10-29
- [x] Tutor approval of the Furuta pendulum (D-01), 2026-10-29
- [x] Equations of motion derived with references (doc 02 §2); code explained (doc 07), 2026-10-29
- [x] Model, requirements, state feedback, hand derivation of K (docs 01–06), 2026-10-15
