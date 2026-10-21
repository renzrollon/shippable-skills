# Changelog

## 0.1.0 (unreleased)

First release.

- Writes a nine-section handoff file with a resume stamp on its first line and
  prints a resume phrase for the next session.
- Lists stranded work first: uncommitted files, unpushed commits, running jobs.
- Redacts secrets, in the file and in the inline fallback.
- Proposes at most three reusable constraints for your instruction file and
  writes nothing without a yes.
- Reads the first existing of `.claude/handoff/`, `.agents/handoff/`,
  `docs/handoff/`, else creates `.agents/handoff/`.
