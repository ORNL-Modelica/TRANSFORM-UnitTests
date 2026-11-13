within TRANSFORMTest.HeatExchangers;
model LMTD_HX_parallelFlow
  "LMTD_HX_Q in parallel flow (counterCurrent=false), against the exact parallel-flow solution"
  extends TRANSFORM.Icons.Example;
  // Incropera and DeWitt Example 11.1 data (as in
  // TRANSFORM.HeatExchangers.Examples.IncroperaAndDeWitt.Example_11_1_Q), run in parallel flow.
  // The reference values are the exact parallel-flow solution (effectiveness-NTU), which the
  // log mean of the end differences T_a1 - T_a2 and T_b1 - T_b2 reproduces.
  package Medium_oil = Modelica.Media.Water.ConstantPropertyLiquidWater (
      mediumName="Engine oil, constant cp", cp_const=2131, cv_const=2131);
  package Medium_water = Modelica.Media.Water.ConstantPropertyLiquidWater (
      mediumName="Water, constant cp", cp_const=4178, cv_const=4178);
  parameter SI.ThermalConductance UA = 38.1*5.178;
  parameter SI.ThermalConductance C_1 = 0.1*2131 "Oil heat capacity rate";
  parameter SI.ThermalConductance C_2 = 0.2*4178 "Water heat capacity rate";
  parameter Real NTU = UA/min(C_1, C_2);
  parameter Real C_r = min(C_1, C_2)/max(C_1, C_2);
  parameter SI.Power Q_exact = (1 - exp(-NTU*(1 + C_r)))/(1 + C_r)*min(C_1, C_2)*(373.15 - 303.15)
    "Exact parallel-flow heat rate";
  TRANSFORM.Fluid.BoundaryConditions.MassFlowSource_T boundary_a1(
    redeclare package Medium = Medium_oil,
    m_flow=0.1,
    T=373.15,
    nPorts=1) annotation (Placement(transformation(extent={{-60,10},{-40,30}})));
  TRANSFORM.Fluid.BoundaryConditions.Boundary_pT boundary_b1(
    redeclare package Medium = Medium_oil,
    p=100000,
    T=333.15,
    nPorts=1) annotation (Placement(transformation(extent={{60,10},{40,30}})));
  TRANSFORM.Fluid.BoundaryConditions.MassFlowSource_T boundary_a2(
    redeclare package Medium = Medium_water,
    m_flow=0.2,
    T=303.15,
    nPorts=1) annotation (Placement(transformation(extent={{-60,-30},{-40,-10}})));
  TRANSFORM.Fluid.BoundaryConditions.Boundary_pT boundary_b2(
    redeclare package Medium = Medium_water,
    p=100000,
    T=313.35,
    nPorts=1) annotation (Placement(transformation(extent={{60,-30},{40,-10}})));
  TRANSFORM.HeatExchangers.LMTD_HX_Q lmtd_HX(
    redeclare package Medium_1 = Medium_oil,
    redeclare package Medium_2 = Medium_water,
    counterCurrent=false,
    m_flow_start_1=0.1,
    m_flow_start_2=0.2,
    UA0=UA) annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  TRANSFORM.Utilities.ErrorAnalysis.UnitTests unitTests(
    n=3,
    x={lmtd_HX.Q_flow,lmtd_HX.sensor_T_b1.T,lmtd_HX.sensor_T_b2.T},
    x_reference={Q_exact,373.15 - Q_exact/C_1,303.15 + Q_exact/C_2})
    annotation (Placement(transformation(extent={{80,80},{100,100}})));
equation
  connect(boundary_a1.ports[1], lmtd_HX.port_a1) annotation (Line(points={{-40,20},{-16,20},
          {-16,4},{-10,4}}, color={0,127,255}));
  connect(lmtd_HX.port_b1, boundary_b1.ports[1]) annotation (Line(points={{10,4},{16,4},{16,
          20},{40,20}}, color={0,127,255}));
  connect(boundary_a2.ports[1], lmtd_HX.port_a2) annotation (Line(points={{-40,-20},{-20,-20},
          {-20,-4},{-10,-4}}, color={0,127,255}));
  connect(lmtd_HX.port_b2, boundary_b2.ports[1]) annotation (Line(points={{10,-4},{20,-4},{20,
          -20},{40,-20}}, color={0,127,255}));
  annotation (experiment(StopTime=1),
    Documentation(info="<html>
<p>Regression test for the <code>counterCurrent</code> option of
<code>TRANSFORM.HeatExchangers.BaseClasses.Partial_LMTD_HX</code>: parallel flow, both streams
entering at port a. Reference values: the exact parallel-flow solution.</p>
</html>"));
end LMTD_HX_parallelFlow;
