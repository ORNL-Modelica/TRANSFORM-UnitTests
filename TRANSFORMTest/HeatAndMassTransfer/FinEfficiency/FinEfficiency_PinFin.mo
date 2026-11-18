within TRANSFORMTest.HeatAndMassTransfer.FinEfficiency;
model FinEfficiency_PinFin "Efficiency of a pin fin against the textbook formula"
  extends TRANSFORM.Icons.Example;
  // A pin fin of diameter D has m = sqrt(h*P/(k*Ac)) = sqrt(4*h/(k*D)) (P = pi*D, Ac = pi*D^2/4),
  // so for these values mL = 0.7071 and eta = tanh(mL)/mL = 0.8611. SpineTriangular and
  // StraightTriangular call the GNU Scientific Library, which TRANSFORM ships for Linux only, so
  // they are not in this test (Windows could not run it).
  TRANSFORM.HeatAndMassTransfer.FinEfficiency.SpineRectangular pin(
    alpha=50,
    lambda=200,
    D=0.005,
    L=0.05) annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  TRANSFORM.Utilities.ErrorAnalysis.UnitTests unitTests(n=2, x={pin.mL,pin.eta})
    annotation (Placement(transformation(extent={{80,80},{100,100}})));
  annotation (experiment(StopTime=1),
    Documentation(info="<html>
<p>Regression test for <code>TRANSFORM.HeatAndMassTransfer.FinEfficiency.SpineRectangular</code>:
the pin fin's <code>mL</code> and efficiency.</p>
</html>"));
end FinEfficiency_PinFin;
