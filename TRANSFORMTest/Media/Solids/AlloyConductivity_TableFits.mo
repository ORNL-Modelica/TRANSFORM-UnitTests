within TRANSFORMTest.Media.Solids;
model AlloyConductivity_TableFits
  "Copper OFHC_RRR200 follows its conductivity and resistivity tables; Cr225Mo1 is held above its table"
  extends TRANSFORM.Icons.Example;
  // Regression test (TRANSFORM CHANGELOG, Unreleased/Fixed). Expected values:
  //   lambda_Cu_100, lambda_Cu_300: the table values 471 and 399 W/(m.K). The old degree-2
  //     polynomial fit gave 617 and 296.
  //   lambda_Cu_20: 1100 W/(m.K), the table's first value, held below 50 K (the spline alone would
  //     extrapolate linearly, far above it).
  //   lambda_Cu_112: between table points (100 K: 471, 125 K: 434), on the spline.
  //   lambda_Cr_1500: 25.9 W/(m.K), the fit's value at the table's last point (1088.71 K; the
  //     table's own value there is 26.48), held above it. The old fit extrapolated to
  //     7.5 at 1500 K and to zero at 1627 K.
  //   rho_Cu_50, rho_Cu_112: electrical resistivity x 1e8 [Ohm.m], at the table's first point
  //     (0.057) and between points. The old degree-2 fit gave 0.0334 at 50 K and was negative
  //     below 45 K.
  package Cu = TRANSFORM.Media.Solids.Copper.OFHC_RRR200;
  package Cr = TRANSFORM.Media.Solids.Cr225Mo1;
  Real lambda_Cu_100 = Cu.thermalConductivity(Cu.ThermodynamicState(T=100))
    "Copper conductivity at 100 K [W/(m.K)]";
  Real lambda_Cu_300 = Cu.thermalConductivity(Cu.ThermodynamicState(T=300))
    "Copper conductivity at 300 K [W/(m.K)]";
  Real lambda_Cu_20 = Cu.thermalConductivity(Cu.ThermodynamicState(T=20))
    "Copper conductivity at 20 K, below the table [W/(m.K)]";
  Real lambda_Cu_112 = Cu.thermalConductivity(Cu.ThermodynamicState(T=112))
    "Copper conductivity at 112 K, between table points [W/(m.K)]";
  Real rho_Cu_50 = 1e8*Cu.electricalResistivity(Cu.ThermodynamicState(T=50))
    "Copper electrical resistivity at 50 K, x 1e8 [Ohm.m]";
  Real rho_Cu_112 = 1e8*Cu.electricalResistivity(Cu.ThermodynamicState(T=112))
    "Copper electrical resistivity at 112 K, x 1e8 [Ohm.m]";
  Real lambda_Cr_1500 = Cr.thermalConductivity(Cr.ThermodynamicState(T=1500))
    "Cr225Mo1 conductivity at 1500 K [W/(m.K)]";
  TRANSFORM.Utilities.ErrorAnalysis.UnitTests unitTests(n=7, x={lambda_Cu_100, lambda_Cu_300,
        lambda_Cu_20, lambda_Cu_112, rho_Cu_50, rho_Cu_112, lambda_Cr_1500})
    annotation (Placement(transformation(extent={{80,80},{100,100}})));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(StopTime=1));
end AlloyConductivity_TableFits;
