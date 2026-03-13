/-
  Perfect Software Factory — Core Definitions

  A specification is a finite sequence of elements. An implementation is
  a specification. The actualization function maps specifications to
  implementations. The assessment function decides equivalence.
-/

/-- A specification is a finite sequence of elements of type α. -/
abbrev Specification (α : Type) := List α

/-- An implementation is a specification. -/
abbrev Implementation (α : Type) := Specification α

/-- The actualization function produces an implementation from a specification. -/
def actualize {α : Type} (s : Specification α) : Implementation α := s

/-- The generate function produces a specification from a target. -/
def generate {α : Type} (s : Specification α) : Specification α := s

/-- The validate function accepts a specification iff it is well-formed.
    All specifications are well-formed by construction. -/
def validate {α : Type} (_s : Specification α) : Bool := true

/-- The assessment function: decides whether an implementation matches a
    specification via decidable equality. -/
def assess {α : Type} [BEq α] (i : Implementation α) (s : Specification α) : Bool :=
  i == s

/-- Assessment as a proposition: the implementation equals the specification. -/
def passes_assessment {α : Type} (i : Implementation α) (s : Specification α) : Prop :=
  i = s

/-- Assessment result type. -/
inductive AssessmentResult where
  | PASS : AssessmentResult
  | FAIL : AssessmentResult
deriving DecidableEq

/-- Assessment returning a result value. -/
def assess_result {α : Type} [BEq α] (i : Implementation α) (s : Specification α) : AssessmentResult :=
  if assess i s then .PASS else .FAIL
