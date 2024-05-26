
using AtomsBase, DecoratedParticles, AtomsBuilder, 
      GeomOpt, Test, StaticArrays, Unitful 

GO = GeomOpt      

## 

sys = AosSystem( rattle!(bulk(:Si, cubic=true) * 2, 0.1) )
dofmgr = GO.DofManager(sys)
x = GO.get_dofs(sys, dofmgr)
@test length(x) == 3 * length(sys)
@test eltype(x) == Float64
@test all(iszero, x)
u = 0.01 * randn(length(x))
X = dofmgr.X0 + reinterpret(SVector{3, Float64}, u) * dofmgr.r0
GO.set_dofs!(sys, dofmgr, u)
@test position(sys) == X

##

sys = AosSystem( rattle!(bulk(:Si, cubic=true) * 2, 0.1) )
dofmgr = GO.DofManager(sys; variablecell = true)
x = GO.get_dofs(sys, dofmgr)
@test length(x) == 3 * length(sys) + 9 
@test eltype(x) == Float64
@test all(iszero, x[1:end-9])
@test x[end-8:end] == [1, 0, 0, 0, 1, 0, 0, 0, 1]
u = 0.01 * randn(length(x)-9)
F = SMatrix{3, 3}([1 0 0; 0 1 0; 0 0 1] + 0.01 * randn(3, 3))
x = [u; F[:]]
X = Ref(F) .* ( dofmgr.X0 + reinterpret(SVector{3, Float64}, u) * dofmgr.r0 )
bb_new = tuple([F * b for b in bounding_box(sys)]...)
GO.set_dofs!(sys, dofmgr, x)
@test position(sys) == X
@test bounding_box(sys) == bb_new


