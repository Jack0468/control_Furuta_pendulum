# TODO: What Is Still Open

**Due: 11:59 pm Friday 6 November 2026.** Last updated 2026-11-04.

Tick items off here as they are done. When an item closes a logbook issue (I-xx) or decision (D-xx), also update [LOGBOOK.md](LOGBOOK.md).

**Current state:** `run_all` is done and the figures, docs and report numbers all match the final design (published damping, Aleksei's poles, observer −100…−130). What's left is mainly the people-only items and rewriting the blue prose. Nothing from this refresh is committed yet.

"Who" is a suggestion: **Jack**, **Aleksei**, **Team** (both), or **Claude** (AI-assisted; declare this in the report).

---

## 1. Confirm with Aleksei

| Done | ID | Task | Who | Notes |
| --- | --- | --- | --- | --- |
| [ ] | I-09 | **Get Aleksei's design script into the repo,** or confirm his abstract's results aren't used. Check his gain signs against his report's α convention | Aleksei | His `.slx` files need A, B, C and K from a script that isn't committed. Details in the LOGBOOK, 2026-11-04 |
| [ ] | D-18 | **Aleksei to confirm the serving-arm application and 2.5 s settling limit** | Aleksei | Jack accepted on 2026-11-04. [Doc 03 §4](03_design_requirements.md). Be ready to answer "why is the tray inverted?" |
| [ ] | D-12 | **Confirm the observer:** pole-placed as the main design, Kalman as the extension. The report is written this way | Team | [Doc 09 §6](09_kalman_filter.md). Ask the lecturer only if you want a Kalman gain as the main design |
| [ ] | — | Look over the regenerated figures in `figures/` and the draft PDF | Jack | `python report/build.py --open` |

## 2. Refresh and publish

| Done | ID | Task | Who | Notes |
| --- | --- | --- | --- | --- |
| [x] | — | Run `run_all` (3–7 min; keep the computer awake, as sleep pauses it) | Claude | Done 2026-11-04. Log in `scratch/` |
| [x] | — | Refresh every result in the docs, README and the report from the new log | Claude | Done 2026-11-04, including the hand derivation in doc 06 |
| [x] | I-08 | Record the final ripple and settling time | Claude | 0.71° ripple, inside the ±0.6° band; T_s 1.38 s |
| [ ] | — | Commit and push, so Aleksei can see everything | Jack | `main` matches GitHub, plus uncommitted work. Claude commits only when asked |

## 3. Things only a person can do

| Done | ID | Task | Who | By | Notes |
| --- | --- | --- | --- | --- | --- |
| [ ] | — | Read the sources tagged in the report's reference list, starting with Hamza 2019 and Cazzolato & Prime 2011 | Team | Wed 4 Nov | The brief rejects unverified references; [doc 10 §1](10_literature_review.md) shows what was only an abstract or record |
| [ ] | — | Read Acosta 2010 and confirm the 0.75 rad LQR claim and the methods listed in the Introduction | Aleksei | Wed 4 Nov | Full text blocked for automated access. `--final` hides the orange mark, so fix or remove the sentence first |
| [ ] | — | Give a source for the rocket-landing claim in the Introduction, or drop it | Aleksei | Wed 4 Nov | No source in either draft |
| [ ] | — | Check Aleksei's MATEC paper: it's about a *tilted* Furuta pendulum, so does it support what he cites it for? | Aleksei | Wed 4 Nov | Only needed if it's cited: his report draft doesn't cite it. The site blocked automated access |
| [ ] | I-03 | Find a source for m_r = 0.095 kg, ideally the QUBE-Servo 2 workbook | Jack | Wed 4 Nov | J_r depends on it. The TU Delft sheet was unreachable |
| [ ] | — | Confirm the arm's ±90° cable limit, or state it as an assumption | Team | Wed 4 Nov | Both of you assumed it |
| [ ] | — | Get the AI-citation rules from Canvas or your tutor, then write the declaration | Team | Thu 5 Nov | Searched every course PDF: no rule stated, only "ask an LLM, but be critical" (Lecture 1, p. 32) and slides crediting "source: ChatGPT" |
| [ ] | — | Confirm `Template-Latex.zip` matches the one on Canvas | Jack | Wed 4 Nov | |
| [ ] | I-05 | Only if you cite textbooks: check chapter numbers against your edition | Team | Thu 5 Nov | The report draft cites none |

## 4. Report (IEEE LaTeX, max 8 pages; build with `python report/build.py`)

| Done | Task | Who | By | Source material |
| --- | --- | --- | --- | --- |
| [ ] | **Rewrite all blue prose in your own words.** Equations, tables and data can stay | Team | Thu 5 Nov | `report/main.tex` |
| [ ] | §1 Abstract (about 200 words, up to 5 keywords) and §7 Conclusions | Team | Thu 5 Nov | LOGBOOK |
| [ ] | §2 Introduction (literature review, justify choices, report structure) | Team | Thu 5 Nov | [Doc 10 §2](10_literature_review.md) |
| [ ] | §3 System Model | Team | Wed 4 Nov | Docs 02, 08, 10 §3 |
| [ ] | §4 Problem Definition | Team | Wed 4 Nov | Docs 02 §3, 03 §4 |
| [ ] | §5 Controller Design | Aleksei (proposed) | Thu 5 Nov | Docs 04, 06, 09 |
| [ ] | §6 Numerical Validations | Jack (proposed) | Thu 5 Nov | Doc 05 |
| [ ] | Decide whether the Kalman trade-off figure goes in. The `--final` build is 7 pages (8 in draft, because of the marks), so there is room if the rewrite doesn't add length | Team | Thu 5 Nov | `w11_kalman_tradeoff.png` |
| [ ] | Stay within 8 pages: check with `--final`, as the 7-page build has about one page spare; check notation, including `b` used for both the encoder offset and a model constant; every figure is discussed in the text | Team | Thu 5 Nov | |
| [ ] | Put the reference list in first-cited order, as IEEE style expects | Team | Thu 5 Nov | `report/main.tex` |

## 5. Before submission

| Done | Task | Who | By |
| --- | --- | --- | --- |
| [ ] | Clone the repo fresh, run `run_all`, and check the numbers and figures match the report | Team | Thu 5 Nov |
| [ ] | Build with `python report/build.py --final --package` for the final PDF and MATLAB zip | Jack | Fri 6 Nov |
| [ ] | Check the PDF: machine-readable, ≤ 8 pages, IEEE format, all seven sections | Team | Fri 6 Nov |
| [ ] | Proofread | Team | Fri 6 Nov |
| [ ] | Submit the report PDF and MATLAB files on Canvas | Jack | **Fri 6 Nov** |

---

## Done (for reference)

Closed items, newest first. Details are in the [LOGBOOK](LOGBOOK.md).

- [x] `run_all` to `figures/`, then the report and docs refreshed from the log; doc 06 redone for D4, 2026-11-04
- [x] Aleksei's report sections merged into `report/main.tex` (D-20), 2026-11-04
- [x] Aleksei's Simulink run with our gains: agrees with our code on the shared test, 2026-11-04
- [x] Aleksei's poles adopted in the code (D-19), 2026-11-03
- [x] I-10: settling limit derived from the serving-arm application (doc 03 §4), pending your acceptance, 2026-11-03
- [x] I-02: Monte Carlo failures explained: weak motor and short arm reduce loop gain, 2026-11-03
- [x] I-06: anti-windup tested at the edge of falling: no practical effect, 2026-11-03
- [x] I-11: pendulum spin term restored in the model and equations, 2026-11-03
- [x] I-12: motor data found: CL40 16705 matches R_m and k_m, rated 18 V, 0.54 A, 2026-11-03
- [x] 2-D Kalman Q sweep: pendulum noise dominates, 2026-11-03
- [x] Disturbance-estimating Kalman filter: not needed if Aleksei's poles meet the tap limit; listed as future work, 2026-11-03
- [x] Report-quality figures: `furuta_savefig.m`, IEEE widths, 300 dpi, 2026-11-03
- [x] Published damping values adopted (D-16), 2026-11-03
- [x] Doc 01 and doc 03 updated; requirements justified, 2026-11-03
- [x] MATLAB packaging added to `build.py`, 2026-11-03
- [x] Report first draft, compile script, literature research, margins (docs 10, `week12_margins.m`), 2026-11-03
- [x] Rubric received and coverage mapped (doc 10 §4); LaTeX template located (I-07), 2026-11-03
- [x] Arm geometry: case A (D-13); settling limit 2.5 s (D-14), 2026-11-03
- [x] Kalman filter derivation and trade-off study (doc 09), 2026-10-29
- [x] Observer-based control at 1 kHz, validation V1–V7, `run_all.m`, 2026-10-29
- [x] Type-1 servo fix (D-07); faster observer (D-10), 2026-10-29
- [x] Encoder selection and datasheet noise model (doc 08), 2026-10-29
- [x] Tutor approval of the Furuta pendulum (D-01), 2026-10-29
- [x] Equations of motion derived with references (doc 02 §2); code explained (doc 07), 2026-10-29
- [x] Model, requirements, state feedback, hand derivation of K (docs 01–06), 2026-10-15
