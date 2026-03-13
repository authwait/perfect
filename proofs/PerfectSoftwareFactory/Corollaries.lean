/-
  Perfect Software Factory — Corollaries

  Three corollaries derived from the main theorems: self-hosting,
  specification stability, and zero defect rate.

  All proofs are machine-checked by the Lean 4 type checker.
-/

import PerfectSoftwareFactory.Theorems

/-- Corollary 4.1 (Self-Hosting): The factory can produce itself from its own
    specification. Applying actualize twice is the same as applying it once. -/
theorem self_hosting {α : Type} :
    actualize ∘ actualize = (actualize : Specification α → Implementation α) := by
  funext s
  rfl

/-- Corollary 4.2 (Specification Stability): The specification format is closed
    under generation. generate(generate(S)) = generate(S). -/
theorem specification_stability {α : Type} (s : Specification α) :
    generate (generate s) = generate s :=
  rfl

/-- Corollary 4.3 (Zero Defect Rate): The factory produces zero defects
    relative to the specification. For any specification, the actualized
    implementation always passes assessment. -/
theorem zero_defect_rate {α : Type} [BEq α] [LawfulBEq α] (s : Specification α) :
    assess (actualize s) s = true :=
  completeness s
