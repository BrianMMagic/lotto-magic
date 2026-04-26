# Lotto Ticket Generator

Web app that composites a fake Powerball ticket image from a blank template and digit PNG overlays, served via GitHub Pages and usable on iPhone Safari.

## Key Files

- `lotto.html` — self-contained web app with all images embedded as base64; hosted on GitHub Pages
- `Lotto Blank/lotto.png` — blank ticket template, 699×786 px
- `lotto example.jpeg` — reference for completed ticket layout
- `small/sm0-9.png` — small digits for date/time row (original, 79×79 with padding)
- `large/lg0-9.png` — large digits for lotto number row (original, 119×119 with padding)
- `cropped/small/sm0-9.png` — small digits with whitespace cropped (~30×58)
- `cropped/large/lg0-9.png` — large digits with whitespace cropped (~72×99)
- `crop_numbers.py` — Python script that generated digit assets from `numbers.png`
- `PRD.md` — full requirements and technical design

## How It Works

1. User opens `https://brianmmagic.github.io/lotto-magic/lotto.html` in Safari on iPhone
2. Enters 5 lotto numbers + Powerball in the 6 circular inputs (auto-advances on 2 digits)
3. Taps **Generate Ticket**
4. JS draws all digits onto an HTML canvas (699×786) using current date/time and entered numbers
5. Long-presses the image to save to Photos

## Deployment

- Hosted at: `https://brianmmagic.github.io/lotto-magic/lotto.html`
- GitHub repo: `https://github.com/BrianMMagic/lotto-magic`
- To update: edit `lotto.html` locally, then `git add lotto.html && git commit && git push`
- Rebuild script: run the PowerShell block in this session that reads all images, base64-encodes them, and writes `lotto.html`

## Coordinate Tuning

All coordinates are in `lotto.html` in the JS section. The canvas is always 699×786px regardless of display size.

```
DATE_Y = 384   TIME_Y = 384   NUMS_Y = 484

dateX  = [283, 294, 313, 324, 343, 354, 365, 376]
          M1   M2   D1   D2   Y1   Y2   Y3   Y4

timeX  = [421, 432, 449, 460, 477, 488]
          H1   H2   Mn1  Mn2  S1   S2

numsX  = [77, 97, 130, 150, 183, 203, 236, 256, 289, 309, 539, 559]
          N1t N1o N2t  N2o  N3t  N3o  N4t  N4o  N5t  N5o  PBt  PBo

LG_W=17  LG_H=24   (large digits drawn at this size)
SM_W=7   SM_H=14   (small digits drawn at this size)
```

To tune: check "Show debug overlay" before generating — red boxes show number positions, blue show date, green show time.
