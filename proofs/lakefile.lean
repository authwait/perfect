import Lake
open Lake DSL

package «PerfectSoftwareFactory» where
  leanOptions := #[⟨`autoImplicit, false⟩]

@[default_target]
lean_lib «PerfectSoftwareFactory» where
  srcDir := "."
