# Lightweight PDD Guidelines

Use this template to write concise, high-value Product Design Documents (PDDs) or feature specs. The aim is to capture user value, UX expectations, and delivery checkpoints without unnecessary overhead.

## Document Structure

1. **Overview**
   - 2-3 sentence summary of the feature and the primary user problem it solves.
   - Mention the target users and the expected outcome.
2. **Goals**
   - Bullet list of measurable or observable outcomes the release must achieve.
3. **Non-Goals**
   - Explicitly state scenarios or capabilities that are out of scope.
4. **User Stories & Scenarios**
   - Capture the primary user flows as "As a …, I want … so that …" statements.
   - Include edge cases or alternative flows if relevant.
5. **User Experience**
   - Describe the interaction model, UI surfaces, and feedback expectations.
   - Reference sketches or prototypes if available.
6. **Functional Requirements**
   - Enumerate the behaviors the system must support.
   - Call out dependencies, data inputs/outputs, and platform considerations.
7. **Technical Notes**
   - Summarize architectural guidance, integration points, or implementation constraints.
8. **Open Questions & Assumptions**
   - Track decisions that still need alignment and assumptions that require validation.
9. **Release Criteria**
   - Define the tests, metrics, or sign-off steps required before launch.

## Writing Best Practices

- Keep sections concise; use bullet lists and short paragraphs.
- Prefer active voice and user-focused language.
- Use tables when comparing options or outlining variants.
- Link to related documents, prototypes, or tickets where useful.
- Update the PDD as decisions are made; maintain a changelog if revisions are substantial.

## Submission Checklist

Before finalizing a PDD:

- [ ] All sections above are present (omit a section only with an explanation).
- [ ] Goals and non-goals are clearly differentiated.
- [ ] Functional requirements map back to user stories.
- [ ] Open questions have owners or next steps.
- [ ] Release criteria provide an objective definition of done.
