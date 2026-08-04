---
name: review-rib
description: Review RIBs-KMP code against the framework's architecture conventions (layer boundaries, routing discipline, dependencies, naming, style). Use when the user asks to review a RIB, check that a RIB follows the conventions, or audit RIBs architecture. This is scoped to RIBs conventions — NOT a general-purpose code review.
---

# Review a RIB

Check RIBs-KMP code against the conventions below. Report each violation concretely: `file:line`, the
rule it breaks, and the fix. Scoped to architecture/conventions — not general code quality.

## Layer boundaries (the core of RIBs)

- **View** is dumb — no logic, minimal/no state; it renders the view model and forwards raw input.
- **Presenter** only maps domain → view model and formats, then calls `view.render(...)`. It
  interprets `did…` input as user intent and forwards to the interactor. It **never** passes a view
  model to the interactor. Raw-input parsing (e.g. String→number) lives here.
- **Interactor** holds all business logic + domain state. It **never** references a view model. It
  **never** holds a Router or another RIB's reference — only domain ids. It drives the presenter via
  `present…()`.
- **Router** is tree/routing only — no business logic.
- **Builder/Component** constructors only wire; no logic, no service calls, and no `?: default` in
  `build()`.

## Routing — retain/release discipline

- Every `routeToX()` has a matching `routeAwayFromX()`.
- routeTo/routeAway are called in pairs by the same owner; no routeAway hidden inside a routeTo.
- Child→parent callbacks express user intent (`didCompleteX(interactor:)`); the **parent** decides
  routing. Reject "the child notifies the parent that it closed".

## Dependencies & parameters

- Runtime params (ids, domain models) passed via `build(...)`, not constructors.
- A dependency is created at the lowest RIB that needs it; requested from the parent only if shared
  with an ancestor/sibling.

## Style

- No force-unwraps (`!!` in Kotlin, `!` in Swift).
- No `expect` / `actual`.
- Swift protocol conformance in the class declaration, not an `extension`.
- Platform concerns (UIKit, DOM, `androidx.*`, `kotlinx.browser.*`) stay OUT of shared/common code —
  they belong in injected platform implementations.

## Naming & file layout

- `did…` for view/child input; `present…` for interactor → presenter.
- One top-level RIB class per file. Role interfaces co-located: `*PresentableListener` in the
  Presenter file; `*Routing` / `*Listener` / `*Presentable` in the Interactor file; `*Interactable`
  in the Router file.
