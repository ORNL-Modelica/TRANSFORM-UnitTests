within TRANSFORMTest.HeatAndMassTransfer.Resistances;
model SemiInfinitePlane_Start
  "Semi-infinite solid after a step in surface temperature, from the first instant"
  extends TRANSFORM.Icons.Example;
  // A 100 K step at t = 0: the exact heat flow rate is lambda*A*dT/sqrt(pi*alpha*t), which is
  // infinite at t = 0 and 1.784e4 W at t = 100 s for these values.
  TRANSFORM.HeatAndMassTransfer.BoundaryConditions.Heat.Temperature surface(T=400)
    annotation (Placement(transformation(extent={{-60,-10},{-40,10}})));
  TRANSFORM.HeatAndMassTransfer.BoundaryConditions.Heat.Temperature bulk(T=300)
    annotation (Placement(transformation(extent={{60,-10},{40,10}})));
  TRANSFORM.HeatAndMassTransfer.Resistances.Heat.SemiInfinitePlane plane(
    crossArea=1,
    lambda=10,
    alpha_d=1e-5) annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  TRANSFORM.Utilities.ErrorAnalysis.UnitTests unitTests(n=2, x={plane.port_a.Q_flow,plane.R})
    annotation (Placement(transformation(extent={{80,80},{100,100}})));
equation
  connect(surface.port, plane.port_a);
  connect(plane.port_b, bulk.port);
  annotation (experiment(StopTime=100, __Dymola_NumberOfIntervals=100),
    Documentation(info="<html>
<p>Regression test for <code>TRANSFORM.HeatAndMassTransfer.Resistances.Heat.SemiInfinitePlane</code>
from the instant the surface temperature steps: the heat flow rate must start finite.</p>
</html>"));
end SemiInfinitePlane_Start;
