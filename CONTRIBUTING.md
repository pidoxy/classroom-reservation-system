# Contributing

Thank you for helping. Anyone can contribute: students in the cohort, people learning on their own, and experienced engineers who want to review.

Read [docs/GUIDELINES.md](docs/GUIDELINES.md) first. It is short. Then pick a way to help.

## Ways to contribute

| You want to | Do this |
| --- | --- |
| Fix a typo or unclear sentence | Open a pull request straight away |
| Report a mistake or contradiction in the Brief | Open a [Brief problem](.github/ISSUE_TEMPLATE/brief-problem.md) issue |
| Add a conformance case | Follow [tests/conformance/README.md](tests/conformance/README.md), then open a pull request |
| Add a starter for a new language | Open a [new language starter](.github/ISSUE_TEMPLATE/new-language-starter.md) issue first, then a pull request |
| Share your implementation | Add a row to [docs/implementations.md](docs/implementations.md) |
| Review someone's pull request | Comment kindly and specifically; point at the Brief line |
| Ask a question | Open a [question](.github/ISSUE_TEMPLATE/question.md) issue. Your answer helps the next person |

Good first issues are labelled `good first issue`.

## The workflow

1. **Fork** the repository on GitHub.
2. **Clone** your fork and create a branch:

   ```bash
   git clone https://github.com/<you>/classroom-reservation-system.git
   cd classroom-reservation-system
   git checkout -b docs/fix-typo-data-model
   ```

3. **Make one focused change.** If you touched the database or scripts, run `./scripts/check-step1.sh` where it applies.
4. **Commit** with a Conventional Commit message, for example `docs: fix typo in data model`.
5. **Push** to your fork and **open a pull request** against `main`. Fill in the template.
6. **Respond to review.** Push more commits to the same branch. Do not open a new pull request for changes to the same work.

Keep your fork current:

```bash
git remote add upstream https://github.com/<owner>/classroom-reservation-system.git
git fetch upstream
git rebase upstream/main
```

## For cohort students

- Build in your own fork, one branch per step: `step-1-schema`, `step-2-search`, and so on.
- You do not need to send your solution here. If you want to share it, add a row to [docs/implementations.md](docs/implementations.md) linking to your fork.
- You may review each other's forks. Leave comments on the fork's pull request or issues. This is practice at code review, not marking.
- Working with an AI agent is encouraged. Read [docs/working-with-agents.md](docs/working-with-agents.md) and declare it in your pull request.

## Ground rules

- Be kind. See the [Code of Conduct](CODE_OF_CONDUCT.md).
- Never edit tests to make code pass.
- Never commit secrets.
- Small pull requests get reviewed faster.

By contributing you agree your work is released under the [MIT License](LICENSE).
