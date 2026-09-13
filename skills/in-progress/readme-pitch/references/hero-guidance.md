# Hero guidance

Choosing and placing a hero is in scope. Producing the image is not. If the
repo has no usable hero, write a design prompt file and list it under
`OUTSIDE THIS CHANGE`. Do not generate, download, or invent an image.

## Pick one, in this order

1. **Screenshot of the product running.** The outcome the reader wants.
   A running session, a finished report, a UI in the state that sold you.
2. **Designed terminal frame.** When the product is a CLI and a screenshot
   would be a wall of unstyled text. Dark background, readable at 900 px
   wide, the commands the reader will type plus the output they should see.
3. **Diagram.** Last resort, and never above the fold. Architecture boxes
   belong in docs. AutoGen's concept art sitting at line 174 of 241 is the
   pattern: if you must ship a diagram, put it below the pitch.

The hero shows the outcome or the mechanism, not the architecture.

## Size

GitHub's README column is about 900 px. Rendered height is
`pixelHeight * (900 / pixelWidth)`.

| Goal | Rendered height at 900 wide | Typical source |
|------|-----------------------------|----------------|
| Usage block must also fit on the first screen | ~300 px | 1800 x 600 |
| The image carries the pitch itself | ~500 px | 1800 x 1000 |

Always set an explicit width on the tag (`width="900"` or `width="80%"`).
Without one, GitHub renders at native size and pushes the pitch off the
first screen.

Place the hero **before any code block**, after the tagline and the badge
row (skeleton sections 1 to 4). Cap at one image in the pitch.

## Contradicting the text

If the image shows a flag sequence, a default, or a product name that the
new README contradicts, **do not silently pick it anyway**. Place it only if
it still tells the truth; otherwise skip it, write the design prompt, and
flag the contradiction under `OUTSIDE THIS CHANGE`.

Example of the failure: a poster that shows the `--strict` sequence as if it
were the default `ship`.

## `--hero <path>`

If the user passed a path, use that file when it exists. If it is missing,
say so, fall back to the inventory, and continue. Do not invent a
replacement image.

## Design prompt (when no usable hero exists)

Write `$HAND/readme-pitch-hero-prompt-<timestamp>.md` from the template
below. Fill the verbatim appendix from commands that exist (inventory
`--help`, the usage block you drafted). **No invented lines:** every command
and every output line in the appendix must be copy-pasteable from a real
run or from `--help`. If you have not run it, omit that line rather than
guess.

```markdown
# Hero design prompt

Product: <name>
Format: designed terminal frame (1800 x 600, dark, readable at 900 px wide)
Purpose: first-screen README hero. Shows the outcome, not the architecture.

## Art direction

- One terminal window, no window-manager chrome soup, no watermark, no logo salad.
- The heading or prompt in the frame is the product name or the command the
  reader will type, not a slogan you wrote for the picture.
- No boxes-and-arrows overlay. No invented flags.

## Verbatim transcript

Render these lines exactly, in this order. Do not add, reorder, or
paraphrase. If a line is missing, leave it missing.

    <paste the usage block and a short real output, indented>

## Do not

- Do not invent extra commands, flags, or output lines.
- Do not show an architecture diagram.
- Do not depict a default the README does not claim.
```

Hand that file to a human (or an image tool they run). The skill's job ended
when the prompt was written.
