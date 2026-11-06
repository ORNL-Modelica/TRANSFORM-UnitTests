within TRANSFORMTest.Media.Solids;
model AlloyConductivity_FloorAt0K
  "Conductivity fits that reach zero below 0 K are evaluated at no less than 0 K"
  extends TRANSFORM.Icons.Example;
  // Regression test for the max(state.T, 0) guard in the thermalConductivity of these solids and
  // of the table- and spline-based solid interfaces (TRANSFORM CHANGELOG, Unreleased/Fixed).
  // Without it, each fit reaches zero (Alumina: divides by zero; Molybdenum and Tungsten: are
  // extrapolated negative) somewhere below 0 K, and a solver searching for a start could find a
  // false steady state with no conduction there (OpenModelica 1.27.1 in
  // TRANSFORM.Fluid.Pipes.Examples.GenericPipe_Tests.nParallel_withWall_*: a wall at -2043 K).
  //   dLambda_max: largest |lambda(T_neg) - lambda(0 K)| over the materials: 0 with the guards,
  //                at least 0.0618 W/(m.K) (FiberGlassGeneric) with any one guard removed.
  //   lambda_sum:  sum of lambda at T_ref, unchanged by the guards (moves if a fit changes).
  // T_neg is a plain parameter: no physical state goes there, only a solver's iterates. The
  // records are built below their T_min on purpose; Dymola and OpenModelica accept it.
  package SS316 = TRANSFORM.Media.Solids.SS316;
  package SS304 = TRANSFORM.Media.Solids.SS304;
  package SS316_TRACE = TRANSFORM.Media.Solids.SS316_TRACE;
  package SS304_TRACE = TRANSFORM.Media.Solids.SS304_TRACE;
  package ZrNb = TRANSFORM.Media.Solids.ZrNb_E125;
  package FiberGlass = TRANSFORM.Media.Solids.FiberGlassGeneric;
  package HT9 = TRANSFORM.Media.Solids.HT9;
  package Alumina = TRANSFORM.Media.Solids.Alumina;
  package He = TRANSFORM.Media.Solids.Helium;
  package G1 = TRANSFORM.Media.Solids.Graphite.Graphite_1;
  package G2 = TRANSFORM.Media.Solids.Graphite.Graphite_2;
  package G3 = TRANSFORM.Media.Solids.Graphite.Graphite_3;
  package In690 = TRANSFORM.Media.Solids.Inconel690;
  package In625 = TRANSFORM.Media.Solids.Inconel625;
  package Cr225Mo1 = TRANSFORM.Media.Solids.Cr225Mo1;
  package Mo = TRANSFORM.Media.Solids.Molybdenum;
  package W = TRANSFORM.Media.Solids.Tungsten;
  parameter Real T_neg = -600 "Negative temperature [K] the guard must hold at its 0 K value";
  parameter Real T_ref = 300 "Real temperature [K] where the fits must be unchanged";
  Real lambda_neg[17] = {
    SS316.thermalConductivity(SS316.ThermodynamicState(T=T_neg)),
    SS304.thermalConductivity(SS304.ThermodynamicState(T=T_neg)),
    SS316_TRACE.thermalConductivity(SS316_TRACE.ThermodynamicState(T=T_neg)),
    SS304_TRACE.thermalConductivity(SS304_TRACE.ThermodynamicState(T=T_neg)),
    ZrNb.thermalConductivity(ZrNb.ThermodynamicState(T=T_neg)),
    FiberGlass.thermalConductivity(FiberGlass.ThermodynamicState(T=T_neg)),
    HT9.thermalConductivity(HT9.ThermodynamicState(T=T_neg)),
    Alumina.thermalConductivity(Alumina.ThermodynamicState(T=T_neg)),
    He.thermalConductivity(He.ThermodynamicState(T=T_neg)),
    G1.thermalConductivity(G1.ThermodynamicState(T=T_neg)),
    G2.thermalConductivity(G2.ThermodynamicState(T=T_neg)),
    G3.thermalConductivity(G3.ThermodynamicState(T=T_neg)),
    In690.thermalConductivity(In690.ThermodynamicState(T=T_neg)),
    In625.thermalConductivity(In625.ThermodynamicState(T=T_neg)),
    Cr225Mo1.thermalConductivity(Cr225Mo1.ThermodynamicState(T=T_neg)),
    Mo.thermalConductivity(Mo.ThermodynamicState(T=T_neg)),
    W.thermalConductivity(W.ThermodynamicState(T=T_neg))}
    "Conductivity at T_neg [W/(m.K)]";
  Real lambda_0[17] = {
    SS316.thermalConductivity(SS316.ThermodynamicState(T=0)),
    SS304.thermalConductivity(SS304.ThermodynamicState(T=0)),
    SS316_TRACE.thermalConductivity(SS316_TRACE.ThermodynamicState(T=0)),
    SS304_TRACE.thermalConductivity(SS304_TRACE.ThermodynamicState(T=0)),
    ZrNb.thermalConductivity(ZrNb.ThermodynamicState(T=0)),
    FiberGlass.thermalConductivity(FiberGlass.ThermodynamicState(T=0)),
    HT9.thermalConductivity(HT9.ThermodynamicState(T=0)),
    Alumina.thermalConductivity(Alumina.ThermodynamicState(T=0)),
    He.thermalConductivity(He.ThermodynamicState(T=0)),
    G1.thermalConductivity(G1.ThermodynamicState(T=0)),
    G2.thermalConductivity(G2.ThermodynamicState(T=0)),
    G3.thermalConductivity(G3.ThermodynamicState(T=0)),
    In690.thermalConductivity(In690.ThermodynamicState(T=0)),
    In625.thermalConductivity(In625.ThermodynamicState(T=0)),
    Cr225Mo1.thermalConductivity(Cr225Mo1.ThermodynamicState(T=0)),
    Mo.thermalConductivity(Mo.ThermodynamicState(T=0)),
    W.thermalConductivity(W.ThermodynamicState(T=0))}
    "Conductivity at 0 K [W/(m.K)]";
  Real lambda_ref[17] = {
    SS316.thermalConductivity(SS316.ThermodynamicState(T=T_ref)),
    SS304.thermalConductivity(SS304.ThermodynamicState(T=T_ref)),
    SS316_TRACE.thermalConductivity(SS316_TRACE.ThermodynamicState(T=T_ref)),
    SS304_TRACE.thermalConductivity(SS304_TRACE.ThermodynamicState(T=T_ref)),
    ZrNb.thermalConductivity(ZrNb.ThermodynamicState(T=T_ref)),
    FiberGlass.thermalConductivity(FiberGlass.ThermodynamicState(T=T_ref)),
    HT9.thermalConductivity(HT9.ThermodynamicState(T=T_ref)),
    Alumina.thermalConductivity(Alumina.ThermodynamicState(T=T_ref)),
    He.thermalConductivity(He.ThermodynamicState(T=T_ref)),
    G1.thermalConductivity(G1.ThermodynamicState(T=T_ref)),
    G2.thermalConductivity(G2.ThermodynamicState(T=T_ref)),
    G3.thermalConductivity(G3.ThermodynamicState(T=T_ref)),
    In690.thermalConductivity(In690.ThermodynamicState(T=T_ref)),
    In625.thermalConductivity(In625.ThermodynamicState(T=T_ref)),
    Cr225Mo1.thermalConductivity(Cr225Mo1.ThermodynamicState(T=T_ref)),
    Mo.thermalConductivity(Mo.ThermodynamicState(T=T_ref)),
    W.thermalConductivity(W.ThermodynamicState(T=T_ref))}
    "Conductivity at T_ref [W/(m.K)]";
  Real dLambda_max = max(abs(lambda_neg - lambda_0))
    "Largest change of conductivity between 0 K and T_neg [W/(m.K)]";
  Real lambda_sum = sum(lambda_ref) "Sum of the conductivities at T_ref [W/(m.K)]";
  TRANSFORM.Utilities.ErrorAnalysis.UnitTests unitTests(n=2, x={dLambda_max, lambda_sum})
    annotation (Placement(transformation(extent={{80,80},{100,100}})));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(StopTime=1));
end AlloyConductivity_FloorAt0K;
