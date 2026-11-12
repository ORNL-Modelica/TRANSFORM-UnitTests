within TRANSFORMTest.Fluid.Volumes;
model ExpansionTank_1Port_dheight
  "Expansion tank above a volume, joined straight to its port, started fixed"
  extends TRANSFORM.Icons.Example;
  package Medium = TRANSFORM.Media.Fluids.DOWTHERM.LinearDOWTHERM_A_95C;
  // The tank's port pressure, p_surface + rho*g*(level + dheight), ties the tank's level
  // and temperature to the pressure state of the volume below it, so a tool keeps only
  // some of them as states. With the tank's default free start, OpenModelica 1.27.2 took
  // the volume's start pressure and computed the tank temperature from it (1426 K here);
  // with massDynamics=FixedInitial, as ExpansionTank_1Port's documentation advises, both
  // tools start at level_start and T_start. The inflow is at T_start, so the tank
  // temperature stays within 0.01 K of T_start.
  parameter SI.Temperature T_start = 353.15 "Tank and inflow temperature";
  TRANSFORM.Fluid.BoundaryConditions.MassFlowSource_T source(
    redeclare package Medium = Medium,
    m_flow=0.05,
    T=T_start,
    nPorts=1) annotation (Placement(transformation(extent={{-80,-10},{-60,10}})));
  TRANSFORM.Fluid.FittingsAndResistances.SpecifiedResistance resistance(
    redeclare package Medium = Medium,
    R=1e4) annotation (Placement(transformation(extent={{-40,-10},{-20,10}})));
  TRANSFORM.Fluid.Volumes.SimpleVolume volume(
    redeclare package Medium = Medium,
    T_start=T_start,
    redeclare model Geometry =
        TRANSFORM.Fluid.ClosureRelations.Geometry.Models.LumpedVolume.GenericVolume
        (V=0.001)) annotation (Placement(transformation(extent={{0,-10},{20,10}})));
  TRANSFORM.Fluid.Volumes.ExpansionTank_1Port tank(
    redeclare package Medium = Medium,
    massDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    A=0.1,
    p_start=1e5,
    level_start=0.5,
    T_start=T_start,
    dheight=2) annotation (Placement(transformation(extent={{40,20},{60,40}})));
  TRANSFORM.Utilities.ErrorAnalysis.UnitTests unitTests(n=3, x={tank.state_liquid.T,
        tank.level, tank.port.p})
    annotation (Placement(transformation(extent={{80,80},{100,100}})));
equation
  connect(source.ports[1], resistance.port_a)
    annotation (Line(points={{-60,0},{-37,0}}, color={0,127,255}));
  connect(resistance.port_b, volume.port_a)
    annotation (Line(points={{-23,0},{4,0}}, color={0,127,255}));
  connect(volume.port_b, tank.port)
    annotation (Line(points={{16,0},{50,0},{50,21.6}}, color={0,127,255}));
  annotation (experiment(StopTime=100, __Dymola_NumberOfIntervals=100),
    Documentation(info="<html>
<p>Regression test for <code>TRANSFORM.Fluid.Volumes.ExpansionTank_1Port</code> with a nonzero
<code>dheight</code>, its port joined straight to a volume that holds a pressure, and the tank
started fixed (<code>massDynamics=FixedInitial</code>).</p>
</html>"));
end ExpansionTank_1Port_dheight;
