within TRANSFORMTest.HeatAndMassTransfer.Resistances;
model ConvectionMedia_Defaults
  "ConvectionMedia classes with their default areas, for 2 m of 2 cm pipe and a 2 cm square duct"
  extends TRANSFORM.Icons.Example;
  // Given coefficients (100 W/(m2.K), 0.01 m/s), a 50 K and a 10 mol/m3 difference. A round pipe's
  // wetted area pi*d*L = 0.1257 m2 gives 628.3 W and 0.01257 mol/s; the square duct (perimeter
  // 0.08 m) gives 0.16 m2 and 800 W. massTransferCoeff.vs checks the default flow area pi*d^2/4.
  // L = 2 m so that d*L and d/L differ.
  TRANSFORM.HeatAndMassTransfer.Resistances.Heat.ConvectionMedia convection(
    redeclare model HeatTransferCoeff =
        TRANSFORM.HeatAndMassTransfer.ClosureRelations.HeatTransfer.Models.Alphas (alpha0=100),
    dimensions={0.02},
    dlengths={2}) annotation (Placement(transformation(extent={{-10,50},{10,70}})));
  TRANSFORM.HeatAndMassTransfer.Resistances.Heat.ConvectionMedia_singleNode convectionRound(
    redeclare model HeatTransferCoeff =
        TRANSFORM.HeatAndMassTransfer.ClosureRelations.HeatTransfer.Models.Alphas (alpha0=100),
    v=0,
    dimension=0.02,
    dlength=2) annotation (Placement(transformation(extent={{-10,20},{10,40}})));
  TRANSFORM.HeatAndMassTransfer.Resistances.Heat.ConvectionMedia_singleNode convectionSquare(
    redeclare model HeatTransferCoeff =
        TRANSFORM.HeatAndMassTransfer.ClosureRelations.HeatTransfer.Models.Alphas (alpha0=100),
    v=0,
    crossArea=4e-4,
    perimeter=0.08,
    dlength=2) annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  TRANSFORM.HeatAndMassTransfer.Resistances.Mass.ConvectionMedia convectionM(
    redeclare model MassTransferCoeff =
        TRANSFORM.HeatAndMassTransfer.ClosureRelations.MassTransfer.Models.AlphasM (
          alphaM0={0.01}, Ds_ab=fill(1e-5, 1, 1)),
    Ts_wall={300},
    m_flows={0.01},
    dimensions={0.02},
    dlengths={2}) annotation (Placement(transformation(extent={{-10,-50},{10,-30}})));
  TRANSFORM.HeatAndMassTransfer.BoundaryConditions.Heat.Temperature hot(T=350)
    annotation (Placement(transformation(extent={{-60,50},{-40,70}})));
  TRANSFORM.HeatAndMassTransfer.BoundaryConditions.Heat.Temperature cold(T=300)
    annotation (Placement(transformation(extent={{60,50},{40,70}})));
  TRANSFORM.HeatAndMassTransfer.BoundaryConditions.Mass.Concentration high(C={10})
    annotation (Placement(transformation(extent={{-60,-50},{-40,-30}})));
  TRANSFORM.HeatAndMassTransfer.BoundaryConditions.Mass.Concentration low(C={0})
    annotation (Placement(transformation(extent={{60,-50},{40,-30}})));
  TRANSFORM.Utilities.ErrorAnalysis.UnitTests unitTests(n=5, x={convection.port_a[1].Q_flow,
        convectionRound.port_a.Q_flow,convectionSquare.port_a.Q_flow,
        convectionM.port_a[1].n_flow[1],convectionM.massTransferCoeff.vs[1]})
    annotation (Placement(transformation(extent={{80,80},{100,100}})));
equation
  connect(hot.port, convection.port_a[1]);
  connect(convection.port_b[1], cold.port);
  connect(hot.port, convectionRound.port_a);
  connect(convectionRound.port_b, cold.port);
  connect(hot.port, convectionSquare.port_a);
  connect(convectionSquare.port_b, cold.port);
  connect(high.port, convectionM.port_a[1]);
  connect(convectionM.port_b[1], low.port);
  annotation (experiment(StopTime=1),
    Documentation(info="<html>
<p>Regression test for the default areas of <code>TRANSFORM.HeatAndMassTransfer.Resistances</code>
<code>Heat.ConvectionMedia</code>, <code>Heat.ConvectionMedia_singleNode</code> and <code>Mass.ConvectionMedia</code>.</p>
</html>"));
end ConvectionMedia_Defaults;
