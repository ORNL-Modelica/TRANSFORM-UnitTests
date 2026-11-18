within TRANSFORMTest.HeatAndMassTransfer.Resistances;
model ConvectionMedia_Water
  "ConvectionMedia_singleNode and ConvectionMediaSimple with water"
  extends TRANSFORM.Icons.Example;
  // Both used to fail: the fluid state was declared as moist air whatever the medium, and the
  // velocity had no default although the class says to give the velocity or the mass flow rate.
  // convectionSimple: 2000*0.0628*50 = 6280 W.
  TRANSFORM.HeatAndMassTransfer.Resistances.Heat.ConvectionMedia_singleNode convection(
    redeclare package Medium = Modelica.Media.Water.StandardWater,
    redeclare model HeatTransferCoeff =
        TRANSFORM.HeatAndMassTransfer.ClosureRelations.HeatTransfer.Models.Nus_SinglePhase_2Region,
    m_flow=0.1,
    dimension=0.02,
    crossArea=3.14e-4,
    dlength=1,
    surfaceArea=0.0628) annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  TRANSFORM.HeatAndMassTransfer.Resistances.Heat.ConvectionMediaSimple convectionSimple(
    redeclare package Medium = Modelica.Media.Water.StandardWater,
    alpha=2000,
    surfaceArea=0.0628,
    v=0,
    dimension=0.02) annotation (Placement(transformation(extent={{-10,-50},{10,-30}})));
  TRANSFORM.HeatAndMassTransfer.BoundaryConditions.Heat.Temperature wall(T=350)
    annotation (Placement(transformation(extent={{-60,-10},{-40,10}})));
  TRANSFORM.HeatAndMassTransfer.BoundaryConditions.Heat.Temperature fluid(T=300)
    annotation (Placement(transformation(extent={{60,-10},{40,10}})));
  TRANSFORM.Utilities.ErrorAnalysis.UnitTests unitTests(n=3, x={convection.port_a.Q_flow,convection.R,convectionSimple.port_a.Q_flow})
    annotation (Placement(transformation(extent={{80,80},{100,100}})));
equation
  connect(wall.port, convection.port_a);
  connect(convection.port_b, fluid.port);
  connect(wall.port, convectionSimple.port_a);
  connect(convectionSimple.port_b, fluid.port);
  annotation (experiment(StopTime=1),
    Documentation(info="<html>
<p>Regression test for <code>TRANSFORM.HeatAndMassTransfer.Resistances.Heat.ConvectionMedia_singleNode</code>
with water and only the mass flow rate given, and for
<code>ConvectionMediaSimple</code> with water.</p>
</html>"));
end ConvectionMedia_Water;
