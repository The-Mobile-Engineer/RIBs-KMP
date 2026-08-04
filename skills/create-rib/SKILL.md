---
name: create-rib
description: Scaffold and fill in a new RIB in a RIBs-KMP project (Router / Interactor / Builder / Presenter / View). Use when the user wants to add/create a new RIB, feature, or screen. Runs the `ribs` CLI to generate the boilerplate deterministically, then fills in the logic per the framework's conventions. Do NOT hand-write RIB boilerplate — it drifts from the pattern.
---

# Create a RIB

Two steps: generate the skeleton with the CLI, then fill in the substance. Never hand-write the
6-file boilerplate — the CLI keeps every RIB identical; hand-writing drifts.

## 1. Generate the skeleton

Run the `ribs` CLI from inside the source tree where the RIB should live. It writes a sibling
`<name>/` folder with 6 files (Builder, Router, Interactor, Presenter, View, ViewModel), one class
per file, and infers the package from the current path.

```sh
ribs new <Name>
```

- Run it from inside `src/<sourceSet>/kotlin/<your.package>/`; or pass `--package` / `--dir`.
- RIBs are **sibling** folders — never nest a RIB's folder under its parent (a RIB can attach under
  multiple parents).
- If `ribs` isn't installed:
  `curl -fsSL https://raw.githubusercontent.com/The-Mobile-Engineer/RIBs-KMP/main/install.sh | sh`

## 2. Fill in the substance — follow these conventions

- **Dependencies** — declare needs in `<Name>Dependency`, resolve in `<Name>Component`. Create a
  service at the **lowest** RIB that needs it; request from the parent only if an ancestor/sibling
  also uses it. Constructors only wire — no logic in Component/Builder.
- **build()** — takes the parent Component + the `listener`. Runtime params (ids, domain models)
  come as `build(...)` params, never via constructors. No service calls, no `?: default` in build().
- **Interactor** — all business logic + domain state. Never references a view model. Never holds a
  Router or another RIB (the router owns the tree; the interactor keeps only domain ids). Drives the
  presenter via `present…()`. Subscriptions on `activeScope`, set up in `didBecomeActive()`.
- **Presenter** — maps domain → view model and does ALL formatting, then `view.render(vm)`. Receives
  view input (`did…`) via `<Name>ViewDelegate`, interprets it as user intent, forwards to the
  interactor via `<Name>PresentableListener`. Parses raw user input here. NEVER passes a view model
  to the interactor. Interprets view lifecycle (`didAppear`/`willDisappear`).
- **View** — dumb: no logic, minimal/no state. Renders the view model; forwards raw input to the
  delegate.
- **Router** — routing/tree structure only, no logic. Every `routeToX()` gets a matching
  `routeAwayFromX()`, called in pairs from the same owner (retain/release). Never hide a routeAway
  inside a routeTo.
- **Child → parent** — a `<Name>Listener` callback is USER INTENT (`didCompleteX(interactor:)`), not
  a "notify closed". The parent decides routing.
- **Style** — no `!!` / force-unwraps, no `expect`/`actual`, keep platform types out of shared code.

## 3. Wire it into a parent (manual — the CLI doesn't patch parents yet)

In the parent RIB: add `<Name>Buildable` to its Builder, `routeToX`/`routeAwayFromX` to its Router,
and `<Name>Listener` to its Interactor's implemented interfaces.
