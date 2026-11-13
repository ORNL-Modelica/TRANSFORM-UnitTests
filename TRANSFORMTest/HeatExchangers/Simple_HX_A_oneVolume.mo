within TRANSFORMTest.HeatExchangers;
model Simple_HX_A_oneVolume
  "Simple_HX_A with one volume pair, against its exact steady state"
  extends TRANSFORM.Icons.Example;
  // Incropera and DeWitt Example 11.1 data (U = 38.1 W/(m2.K) split as alpha_1 = alpha_2 = 2*U,
  // A = 5.178 m2), nV = 1, steady-state balances. With one well-mixed volume pair the two outlet
  // temperatures differ by (T_in_1 - T_in_2)/(1 + UA*s), s = 1/C_1 + 1/C_2, so
  // Q = UA*(T_in_1 - T_in_2)/(1 + UA*s) with UA = A/(1/alpha_1 + 1/alpha_2).
  package Medium_oil = Modelica.Media.Water.ConstantPropertyLiquidWater (
      mediumName="Engine oil, constant cp", cp_const=2131, cv_const=2131);
  package Medium_water = Modelica.Media.Water.ConstantPropertyLiquidWater (
      mediumName="Water, constant cp", cp_const=4178, cv_const=4178);
  parameter SI.Area A = 5.178;
  parameter SI.CoefficientOfHeatTransfer alpha_1 = 2*38.1;
  parameter SI.CoefficientOfHeatTransfer alpha_2 = 2*38.1;
  parameter SI.ThermalConductance UA = A/(1/alpha_1 + 1/alpha_2);
  parameter SI.ThermalConductance C_1 = 0.1*2131 "Oil heat capacity rate";
  parameter SI.ThermalConductance C_2 = 0.2*4178 "Water heat capacity rate";
  parameter Real s(unit="K/W") = 1/C_1 + 1/C_2;
  parameter SI.Power Q_exact = UA*(373.15 - 303.15)/(1 + UA*s)
    "Exact steady heat rate of one well-mixed volume pair";
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
    nPorts=1) annotation (Placement(transformation(extent={{60,-30},{40,-10}})));
  TRANSFORM.Fluid.BoundaryConditions.Boundary_pT boundary_b2(
    redeclare package Medium = Medium_water,
    p=100000,
    T=313.35,
    nPorts=1) annotation (Placement(transformation(extent={{-60,-30},{-40,-10}})));
  TRANSFORM.HeatExchangers.Simple_HX_A simple_HX(
    redeclare package Medium_1 = Medium_oil,
    redeclare package Medium_2 = Medium_water,
    nV=1,
    V_1=0.001,
    V_2=0.001,
    surfaceArea=A,
    alpha_1=alpha_1,
    alpha_2=alpha_2,
    m_flow_start_1=0.1,
    m_flow_start_2=0.2,
    T_a_start_1=373.15,
    T_a_start_2=303.15,
    energyDynamics_1=Modelica.Fluid.Types.Dynamics.SteadyState)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  TRANSFORM.Utilities.ErrorAnalysis.UnitTests unitTests(
    n=3,
    x={simple_HX.Q_flow,simple_HX.sensor_T_b1.T,simple_HX.sensor_T_b2.T},
    x_reference={Q_exact,373.15 - Q_exact/C_1,303.15 + Q_exact/C_2})
    annotation (Placement(transformation(extent={{80,80},{100,100}})));
equation
  connect(boundary_a1.ports[1], simple_HX.port_a1) annotation (Line(points={{-40,20},{-16,20},
          {-16,4},{-10,4}}, color={0,127,255}));
  connect(simple_HX.port_b1, boundary_b1.ports[1]) annotation (Line(points={{10,4},{16,4},{16,
          20},{40,20}}, color={0,127,255}));
  connect(boundary_a2.ports[1], simple_HX.port_a2) annotation (Line(points={{40,-20},{16,-20},
          {16,-4},{10,-4}}, color={0,127,255}));
  connect(simple_HX.port_b2, boundary_b2.ports[1]) annotation (Line(points={{-10,-4},{-16,-4},
          {-16,-20},{-40,-20}}, color={0,127,255}));
  annotation (experiment(StopTime=1),
    Documentation(info="<html>
<p>Test of <code>TRANSFORM.HeatExchangers.Simple_HX_A</code>, which no example uses: one volume
pair, steady-state volumes, the conductance built from <code>alpha_1</code>, <code>alpha_2</code>
and <code>surfaceArea</code>. Reference values: the exact steady state of one well-mixed volume
pair.</p>
</html>"));
end Simple_HX_A_oneVolume;
