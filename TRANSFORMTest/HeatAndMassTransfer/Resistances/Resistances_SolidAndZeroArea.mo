within TRANSFORMTest.HeatAndMassTransfer.Resistances;
model Resistances_SolidAndZeroArea
  "Solid spheres and cylinders (r_in = 0) and a fin of zero area between fixed boundaries"
  extends TRANSFORM.Icons.Example;
  // r_in = 0 is a solid body; R joins its centre to its surface for uniform generation:
  // sphere 1/(8*pi*k*r_out), cylinder 1/(4*pi*L*k) (k = lambda or D_ab). With 100 K and
  // 10 mol/m3 across them: heat sphere 2513 W, mass cylinder 2.513e-7 mol/s, mass sphere
  // 2.513e-8 mol/s. The fin has zero area: it must run and carry no heat.
  TRANSFORM.HeatAndMassTransfer.BoundaryConditions.Heat.Temperature hot(T=400)
    annotation (Placement(transformation(extent={{-80,20},{-60,40}})));
  TRANSFORM.HeatAndMassTransfer.BoundaryConditions.Heat.Temperature cold(T=300)
    annotation (Placement(transformation(extent={{80,20},{60,40}})));
  TRANSFORM.HeatAndMassTransfer.Resistances.Heat.Sphere sphere(
    r_in=0,
    r_out=0.1,
    lambda=10) annotation (Placement(transformation(extent={{-10,40},{10,60}})));
  TRANSFORM.HeatAndMassTransfer.Resistances.Heat.Fin fin(
    eta=0.9,
    surfaceArea=0,
    alpha=50) annotation (Placement(transformation(extent={{-10,10},{10,30}})));
  TRANSFORM.HeatAndMassTransfer.BoundaryConditions.Mass.Concentration high(C={10})
    annotation (Placement(transformation(extent={{-80,-40},{-60,-20}})));
  TRANSFORM.HeatAndMassTransfer.BoundaryConditions.Mass.Concentration low(C={0})
    annotation (Placement(transformation(extent={{80,-40},{60,-20}})));
  TRANSFORM.HeatAndMassTransfer.Resistances.Mass.Cylinder cylinderM(
    L=2,
    r_in=0,
    r_out=0.1,
    D_ab={1e-9}) annotation (Placement(transformation(extent={{-10,-20},{10,0}})));
  TRANSFORM.HeatAndMassTransfer.Resistances.Mass.Sphere sphereM(
    r_in=0,
    r_out=0.1,
    D_ab={1e-9}) annotation (Placement(transformation(extent={{-10,-50},{10,-30}})));
  TRANSFORM.Utilities.ErrorAnalysis.UnitTests unitTests(n=3, x={sphere.port_a.Q_flow,
        cylinderM.port_a.n_flow[1],sphereM.port_a.n_flow[1]})
    annotation (Placement(transformation(extent={{80,80},{100,100}})));
equation
  connect(hot.port, sphere.port_a);
  connect(sphere.port_b, cold.port);
  connect(hot.port, fin.port_a);
  connect(fin.port_b, cold.port);
  connect(high.port, cylinderM.port_a);
  connect(cylinderM.port_b, low.port);
  connect(high.port, sphereM.port_a);
  connect(sphereM.port_b, low.port);
  annotation (experiment(StopTime=1),
    Documentation(info="<html>
<p>Regression test for <code>TRANSFORM.HeatAndMassTransfer.Resistances</code>: a solid
<code>Heat.Sphere</code>, <code>Mass.Cylinder</code> and <code>Mass.Sphere</code>
(<code>r_in = 0</code>), and a <code>Heat.Fin</code> with zero area.</p>
</html>"));
end Resistances_SolidAndZeroArea;
