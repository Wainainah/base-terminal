# 🛡️ Base Terminal Audit Playbook

**Protocol:** When the user requests an audit (e.g., "Run audit-gold"), you MUST read this file first, then execute the specific checklist below.

## 🛠️ Post-Audit Actions (Required for ALL Audits)
*After identifying issues, you must automatically perform these fixes:*
1.  **Fix the Code:** Resolve imports, typos, and syntax errors immediately.
2.  **Add Tests:** If a logic bug was found, write a new Vitest/Foundry test case to prevent regression.
3.  **Update Comments:** If logic changed, update the JSDoc/NatSpec to reflect reality.
4.  **Log Errors:** Wrap fragile logic (API calls, parsing) in `try/catch` blocks with proper error logging.

---

## 🟢 Mode 1: `audit-lite` (Routine Hygiene)
*Run this after minor merges or feature additions.*

- [ ] **File Integrity:** specific check for "corrupted" files or weird artifacts (e.g., `>>>> HEAD` markers).
- [ ] **Imports & Paths:** Verify all `import` paths resolve correctly. Check for "drift" (e.g., importing from `../components` when it moved to `@/components`).
- [ ] **Dead Code:** Remove unused variables, imports, and `console.log` debugging leftovers.
- [ ] **Dependencies:** Check `package.json` vs. usage. Ensure no missing packages causing runtime crashes.

---

## 🟠 Mode 2: `audit-ux` (Frontend & Theming)
*Run this before showing the UI to anyone.*

- [ ] **Semantic Enforcement:** Scan for HARDCODED HEX CODES (`#000000`). Replace with semantic variables (`bg-background`).
- [ ] **Mobile Responsiveness:** Check complex components (tables, modals) for overflow issues on small screens.
- [ ] **Loading States:** Verify that every data fetch has a visual Skeleton or Spinner state.
- [ ] **Empty States:** Verify UI handles "zero data" gracefully (e.g., "No tokens found" instead of a blank screen).

---

## 🔴 Mode 3: `audit-security` (Smart Contracts & Data)
*Run this before any contract deployment.*

- [ ] **Access Control:** Verify `onlyOwner` is applied to ALL admin functions.
- [ ] **Input Validation:** Ensure every function checks `msg.value`, `address(0)`, and array lengths at the very start.
- [ ] **Re-entrancy:** Confirm `nonReentrant` modifiers are used on all withdrawal/transfer functions.
- [ ] **Secrets:** Scan frontend code for accidental hardcoded API keys or private keys.

---

## 👑 Mode 4: `audit-gold` (The "Gold Master")
*Run this before a major release (MVP, V1). THIS IS THE HOLISTIC DEEP DIVE.*

1.  **Execute `audit-lite`**
2.  **Execute `audit-security`**
3.  **Execute `audit-ux`**
4.  **Architecture Review:**
    * **Co-location:** Check for "God Components" (>150 lines). Decompose them if found.
    * **Constants:** Verify *every* user-facing string is in `lib/constants.ts`.
5.  **Final Polish:**
    * Run full test suite (`npm test`).
    * Ensure README is up to date with deployment instructions.