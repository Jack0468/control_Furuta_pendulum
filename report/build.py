#!/usr/bin/env python3
"""Compile the LaTeX report to a PDF and check it against the submission rules.

Usage (from anywhere):
    python report/build.py            draft: blue/orange marks visible
    python report/build.py --final    submission version: all marks hidden
    python report/build.py --open     also open the PDF when done
    python report/build.py --package  also zip the MATLAB code for Canvas
    python report/build.py --preview  use figures from scratch/preview (see FURUTA_FIGDIR in furuta_savefig.m)

Output: report/Furuta_report_draft.pdf or report/Furuta_report_final.pdf
Requires pdflatex on PATH (MiKTeX or TeX Live). Regenerate figures first with matlab/run_all.m.
"""
import argparse
import os
import re
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

PAGE_LIMIT = 6         # not counting references and the appendix
ABSTRACT_TARGET = 200   # words, from the assignment criteria
KEYWORD_LIMIT = 5


def run_pdflatex(here, out, final, preview):
    # \def\FINAL{1} before \input hides the draft marks (see the top of main.tex).
    source = r"\input{main.tex}"
    if final:
        source = r"\def\FINAL{1}" + source
    if preview:
        source = r"\def\FIGDIR{../scratch/preview/}" + source
    cmd = ["pdflatex", "-interaction=nonstopmode", "-halt-on-error",
           f"-output-directory={out.name}", "-jobname=main", source]
    return subprocess.run(cmd, cwd=here, capture_output=True, text=True, errors="replace")


def check_source(tex):
    """Report what still needs a person's attention in main.tex."""
    no_comments = re.sub(r"(?m)(?<!\\)%.*$", "", tex)
    issues = {
        "AI-drafted blocks still to rewrite (blue)": no_comments.count(r"\begin{rw}"),
        "items to verify (orange)": no_comments.count(r"\vfy{"),
    }
    abstract = re.search(r"\\begin\{abstract\}(.*?)\\end\{abstract\}", no_comments, re.S)
    words = None
    if abstract:
        text = re.sub(r"\\(begin|end)\{rw\}|\\[a-zA-Z]+\{\}|\\[a-zA-Z]+|[{}$]", " ", abstract.group(1))
        words = len(text.split())
    keywords = re.search(r"\\begin\{IEEEkeywords\}(.*?)\\end\{IEEEkeywords\}", no_comments, re.S)
    n_keywords = len(keywords.group(1).split(",")) if keywords else 0
    return issues, words, n_keywords


def main():
    parser = argparse.ArgumentParser(description="Compile the Furuta pendulum report.")
    parser.add_argument("--final", action="store_true", help="hide all draft marks")
    parser.add_argument("--open", action="store_true", help="open the PDF afterwards")
    parser.add_argument("--package", action="store_true", help="zip the MATLAB code for submission")
    parser.add_argument("--preview", action="store_true", help="use figures from scratch/preview")
    args = parser.parse_args()

    here = Path(__file__).resolve().parent
    out = here / "build"
    out.mkdir(exist_ok=True)

    if shutil.which("pdflatex") is None:
        sys.exit("pdflatex not found on PATH. Install MiKTeX or TeX Live.")

    # Two passes resolve figure, table and citation numbers; a third settles any page shifts.
    for n in range(1, 4):
        print(f"pdflatex pass {n}/3 ...")
        result = run_pdflatex(here, out, args.final, args.preview)
        if result.returncode != 0:
            log = (out / "main.log").read_text(errors="replace") if (out / "main.log").exists() else result.stdout
            errors = [l for l in log.splitlines() if l.startswith("!")]
            print("\nLaTeX failed:")
            print("\n".join(errors[:10]) or log[-1500:])
            match = re.search(r"(?m)^l\.(\d+) (.*)$", log)
            if match:
                print(f"At main.tex line {match.group(1)}: {match.group(2)}")
            print(f"Full log: {out / 'main.log'}")
            sys.exit(1)

    log = (out / "main.log").read_text(errors="replace")
    name = "Furuta_report_final.pdf" if args.final else "Furuta_report_draft.pdf"
    target = here / name
    try:
        shutil.copy(out / "main.pdf", target)
    except PermissionError:
        target = out / "main.pdf"
        print(f"\nCould not overwrite {name} (open in a viewer?). Using {target} instead.")

    # The log hard-wraps long lines, so the page count can fall on the next line.
    pages = re.search(r"Output written on .*?\((\d+)\s+pages?", log, re.S)
    pages = int(pages.group(1)) if pages else -1
    issues, words, n_keywords = check_source((here / "main.tex").read_text(encoding="utf-8"))

    print(f"\nPDF: {target}")
    # The body ends at the Conclusions (labelled in main.tex) or its last figure, whichever is later.
    aux = (out / "main.aux").read_text(errors="replace")
    body = max((int(n) for label in ("report:bodyend", "fig:overview", "fig:mc")
                for n in re.findall(r"\\newlabel\{" + label + r"\}\{\{[^}]*\}\{(\d+)\}", aux)), default=-1)
    print(f"Body pages: {body} (limit {PAGE_LIMIT}, not counting acknowledgment, references and appendix) "
          f"{'OK' if 0 < body <= PAGE_LIMIT else '<-- OVER LIMIT'}. Total PDF pages: {pages}")
    print(f"Abstract: about {words} words (target about {ABSTRACT_TARGET})")
    print(f"Keywords: {n_keywords} (limit {KEYWORD_LIMIT}) {'OK' if n_keywords <= KEYWORD_LIMIT else '<-- TOO MANY'}")
    undefined = len(re.findall(r"(?:Reference|Citation) `[^']*'.*?undefined", log, re.S))
    overfull = len(re.findall(r"Overfull \\hbox", log))
    print(f"LaTeX warnings: {undefined} undefined references/citations, {overfull} overfull lines")
    print("\nStill to do in main.tex:")
    for label, count in issues.items():
        print(f"  {count:3d}  {label}")
    if args.final and any(issues.values()):
        print("\nWARNING: --final hides these marks, but they have not been resolved.")

    if args.package:
        archive = here / "Furuta_matlab_submission.zip"
        # The Kalman and tray-mass studies are background (docs 09, 03): the report doesn't use them.
        files = sorted(f for f in (here.parent / "matlab").glob("*.m") if f.name not in ("week11_kalman.m", "week12_tray_mass.m"))
        with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as z:
            for f in files:
                z.write(f, Path("matlab") / f.name)
            z.writestr("README.txt", "Run matlab/run_all.m from inside the matlab folder. Requires the "
                                     "Control System Toolbox. Tested on R2025b. Figures go to ../figures.\n")
        print(f"\nMATLAB package: {archive} ({len(files)} files)")

    if args.open:
        if sys.platform.startswith("win"):
            os.startfile(target)
        else:
            subprocess.run(["open" if sys.platform == "darwin" else "xdg-open", str(target)])


if __name__ == "__main__":
    main()
