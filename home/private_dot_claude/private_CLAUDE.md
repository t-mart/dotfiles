# Instructions

- Less is more. Adding code/comments/documentation is a liability that must be
  outweighed by its benefit.

- When you write technical text (documentation, READMEs, runbooks, procedures,
  error messages, release notes, reports), obey rules from ASD-STE100 Simplified
  Technical English: Max 20 words per sentence in instructions, 25 in
  descriptions. Imperative for steps, one instruction per sentence, condition
  before command. Simple tenses only. No present perfect, no -ing verbs, no
  should/would/may/might. Active voice. One word per meaning. No synonym
  rotation. No contractions, keep articles and "that". Delete filler: simply,
  robust, seamlessly, leverage. Code and identifiers stay exact.

- Be judicious when writing into the project. Match the style and density of the
  writing already in place. Remember that comments are coupled to and can drift
  from actual code. If you do add comments, avoid:
  - LLM tropes,
  - references to in-conversation details or past implementations
  - use of characters that can't be easily typed on a standard keyboard
    (em/en-dashes, unicode arrows/symbols, smart/curly quotes, etc.).

- Favor pure functions, immutability, composition over inheritance, and early
  returns.

- When you are blocked on a decision that is genuinely mine to make (one you
  cannot resolve from the request, the code, or sensible defaults), question me
  before continuing. Recommend at least one option.

- Avoid tunnel vision. If you feel that you are going down many layers of
  abstraction, propose your investigation to me and ask me if I want to
  continue.

- For sufficiently complex prompts and requests, provide a summary of your plan
  before editing anything (unless I explicitly say to start immediately). This
  will let us collaborate on approach and avoid wasted effort.

- Run quality tasks to ensure correctness, such as configured linters,
  formatters, and tests. Try to bundle the invocation of such tools so that you
  get as much feedback as possible in one run. If we are deficient in this area,
  suggest improvements.

- New behavior should be covered by tests, especially in places where it is easy
  to do so. If the project feels small/one-off/ad-hoc, then don't write tests.

- When we've done a chunk of work that would fit in a commit, give me a commit
  log message in the form `[area]: [short line describing the main effect]`. I
  tend not to use the extended descriptions in commit messages.
  - If I provide an issue number, after the work is complete, add a trailer to
    the commit message in the form "Closes #123" where 123 is the issue number.
  - Do not add co-author trailers for yourself.

- If a CHANGELOG file exists, add an entry for changes you make that are
  user-facing, and very briefly explain the before-state. Do not create a
  CHANGELOG if one does not exist.

- Do not install dependencies or tools for me. Instead, present them to me with
  commands. I will install them if warranted.

- Do not run commands that mutate data outside the project directory. Instead,
  present them to me and ask me to run them if they are essential.

- Do not mutate git history, but you can interact with it in a read-only
  capacity.

- If we are ever writing command line scripts, use long-form flags and options
  because they self-document.

- If you ever want me to run commands, use nushell paradigms, built-in commands,
  and syntax. There is no line continuation in nushell. But, do not use nushell
  when writing documentation for general non-nushell projects.
