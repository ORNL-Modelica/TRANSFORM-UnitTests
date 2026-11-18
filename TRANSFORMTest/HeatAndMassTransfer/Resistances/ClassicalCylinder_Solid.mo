within TRANSFORMTest.HeatAndMassTransfer.Resistances;
model ClassicalCylinder_Solid
  "Reported radial resistance of a solid rod in the ClassicalMethod cylinder"
  extends TRANSFORM.Icons.Example;
  // A solid rod (r_inner = 0) 10 mm across and 1 m long; R_cond_radial is centre to surface,
  // 1/(4*pi*lambda*L). The rod is insulated and stays at its start temperature.
  TRANSFORM.HeatAndMassTransfer.DiscritizedModels.ClassicalMethod.Cylinder_FD rod(
    r_inner=0,
    r_outer=0.005,
    length=1,
    nR=3,
    nZ=2,
    Tref=300) annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  TRANSFORM.Utilities.ErrorAnalysis.UnitTests unitTests(n=1, x={rod.solutionMethod.R_cond_radial})
    annotation (Placement(transformation(extent={{80,80},{100,100}})));
  annotation (experiment(StopTime=1),
    Documentation(info="<html>
<p>Regression test for the solid-rod radial resistance of
<code>TRANSFORM.HeatAndMassTransfer.DiscritizedModels.ClassicalMethod</code> cylinders.</p>
</html>"));
end ClassicalCylinder_Solid;
