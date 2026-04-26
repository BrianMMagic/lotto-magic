# Product Requirements Document — Lotto Ticket Generator

## Overview

A self-contained web app that generates a realistic-looking Powerball ticket image by overlaying the current date/time and user-supplied lotto numbers onto a blank ticket template. Hosted on GitHub Pages, works in iPhone Safari with no app or shortcut required.

## Goals

- Generate ticket image in under 3 seconds after number input
- No manual photo editing required
- Works entirely in the browser — no server, no app install
- Usable on iPhone Safari and desktop browsers
- Save to Photos by long-pressing the image

## Non-Goals

- Does not submit entries or connect to any lottery service
- Does not validate number ranges
- Does not support multiple play lines per ticket

---

## User Flow

1. User opens `https://brianmmagic.github.io/lotto-magic/lotto.html` in Safari
2. Enters numbers in 6 circular inputs (5 main numbers + Powerball in yellow)
   - Inputs auto-advance to next field after 2 digits are typed
   - Backspace on empty field returns to previous field
3. Taps **Generate Ticket**
4. Ticket image appears below the button
5. User long-presses the image → "Save to Photos"

---

## Image Composition

### Canvas
- Size: **699 × 786 px** (always — CSS scales display but canvas pixels are fixed)
- Base layer: `Lotto Blank/lotto.png` (blank Powerball ticket template)
- Pre-printed elements on the template (not drawn by app): slashes in date, colons in time, "PB:" label

### Overlay Layers

| Layer | Digit Set | Format | Row Y | Notes |
|-------|-----------|--------|-------|-------|
| Date  | Small (cropped) | MM DD YYYY | 384 | 8 digits; slashes pre-printed |
| Time  | Small (cropped) | HH MM SS   | 384 | 6 digits; colons pre-printed |
| Numbers | Large (cropped) | N1 N2 N3 N4 N5 PB | 484 | 12 digits total (2 per number) |

### Current Coordinates

```
DATE_Y = 384   TIME_Y = 384   NUMS_Y = 484

dateX  = [283, 294, 313, 324, 343, 354, 365, 376]
timeX  = [421, 432, 449, 460, 477, 488]
numsX  = [77, 97, 130, 150, 183, 203, 236, 256, 289, 309, 539, 559]

LG_W=17  LG_H=24
SM_W=7   SM_H=14
```

---

## Technical Approach

### Why a Self-Contained HTML File

All images (blank ticket + 20 digit PNGs) are base64-encoded and embedded directly in `lotto.html` at build time. The file requires no server, no network requests, and no external dependencies. It is a single file that can be hosted anywhere.

### Image Compositing

HTML Canvas API draws all digit images onto the 699×786 canvas at the correct pixel coordinates. `drawImage(img, x, y, w, h)` scales each digit to the target draw size.

### Digit Images

Source images (`small/`, `large/`) have significant whitespace padding. The `cropped/` versions have that padding removed via PowerShell + System.Drawing, so draw sizes map accurately to visible digit size.

- Large digit source: 119×119px → cropped to ~72×99px → drawn at 17×24px
- Small digit source: 79×79px → cropped to ~30×58px → drawn at 7×14px

---

## File Structure

```
lotto/                           ← Windows development folder
├── CLAUDE.md                    ← Claude Code instructions
├── PRD.md                       ← This document
├── lotto.html                   ← The web app (deploy this)
├── numbers.png                  ← Source image for digit extraction
├── crop_numbers.py              ← Python script that generated digit assets
├── Lotto Blank/
│   └── lotto.png                ← Blank ticket template (699×786)
├── lotto example.jpeg           ← Reference: completed ticket example
├── small/   sm0.png … sm9.png   ← Small digit images (original, with padding)
├── large/   lg0.png … lg9.png   ← Large digit images (original, with padding)
└── cropped/
    ├── small/  sm0.png … sm9.png ← Small digits, whitespace cropped
    └── large/  lg0.png … lg9.png ← Large digits, whitespace cropped
```

## Deployment

- GitHub repo: `https://github.com/BrianMMagic/lotto-magic`
- Live URL: `https://brianmmagic.github.io/lotto-magic/lotto.html`
- GitHub Pages serves from `main` branch root

### Rebuilding lotto.html

Run the PowerShell script from the session that:
1. Base64-encodes `Lotto Blank/lotto.png` and all `cropped/small/` and `cropped/large/` PNGs
2. Injects them into the HTML template
3. Writes `lotto.html`

Then: `git add lotto.html && git commit -m "..." && git push`

---

## Coordinate Tuning

Enable "Show debug overlay" checkbox before generating to see colored boxes:
- Blue = date digit positions
- Green = time digit positions  
- Red = lotto number positions

Measure correct positions in Photoshop against `lotto example.jpeg`, update the arrays in `lotto.html`.
