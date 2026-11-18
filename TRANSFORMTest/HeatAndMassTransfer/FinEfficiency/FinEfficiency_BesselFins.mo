within TRANSFORMTest.HeatAndMassTransfer.FinEfficiency;
model FinEfficiency_BesselFins
  "Efficiencies of the conical pin, triangular and annular fins against their textbook formulas"
  extends TRANSFORM.Icons.Example;
  // These fins' efficiencies use modified Bessel functions. For these values the textbook
  // formulas give: cone 2*I2(2mL)/(mL*I1(2mL)) = 0.9259 (pin m = sqrt(4h/(kD))), triangle
  // I1(2mL)/(mL*I0(2mL)) = 0.9477 with area 2*W*sqrt(L^2 + (th/2)^2) = 0.1203 m2, and the
  // annular fin's Bessel form 0.8975.
  TRANSFORM.HeatAndMassTransfer.FinEfficiency.SpineTriangular cone(
    alpha=50,
    lambda=200,
    D=0.005,
    L=0.05) annotation (Placement(transformation(extent={{-60,-10},{-40,10}})));
  TRANSFORM.HeatAndMassTransfer.FinEfficiency.StraightTriangular triangle(
    alpha=50,
    lambda=200,
    th=0.004,
    L=0.03,
    W=2) annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  TRANSFORM.HeatAndMassTransfer.FinEfficiency.RectangleAnnular annular(
    alpha=50,
    lambda=200,
    r_inner=0.01,
    r_outer=0.03,
    th=0.001,
    pitch=0.005) annotation (Placement(transformation(extent={{40,-10},{60,10}})));
  TRANSFORM.Utilities.ErrorAnalysis.UnitTests unitTests(n=5, x={cone.eta,triangle.eta,
        triangle.surfaceArea,annular.eta,annular.surfaceArea})
    annotation (Placement(transformation(extent={{80,80},{100,100}})));
  annotation (experiment(StopTime=1),
    Documentation(info="<html>
<p>Regression test for <code>TRANSFORM.HeatAndMassTransfer.FinEfficiency</code>:
<code>SpineTriangular</code>, <code>StraightTriangular</code> and <code>RectangleAnnular</code>, whose
efficiencies use modified Bessel functions.</p>
</html>"));
end FinEfficiency_BesselFins;
