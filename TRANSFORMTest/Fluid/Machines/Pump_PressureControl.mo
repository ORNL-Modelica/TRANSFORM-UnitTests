within TRANSFORMTest.Fluid.Machines;
model Pump_PressureControl
  "With pressure control and the default set point, a pump holds the port it sets at that port's start pressure"
  extends TRANSFORM.Icons.Example;
  // controlType = "pressure" sets the pressure at the port whose state the pump exposes. With the
  // default set point p_input, that port must sit at its own start pressure: the inlet at p_a_start
  // (1 bar) with exposeState_a = true, the outlet at p_b_start (3 bar) with exposeState_b = true.
  // Pump_Controlled with controlType = "pressure_a" must likewise hold its inlet at p_a_start.
  // Each pump carries 10 kg/s of water at 30 degC.
  //   dp_a: pumpA.port_a.p/p_a_start - 1, 0 when right. On TRANSFORM 1.3.0 p_input defaulted to
  //         p_b_start for both, so pumpA held its inlet at 3 bar: 2.
  //   dp_b: pumpB.port_b.p/p_b_start - 1, 0 before and after.
  //   dp_c: pumpC.port_a.p/p_a_start - 1, 0 when right; 2 on TRANSFORM 1.3.0, as for pumpA.
  replaceable package Medium = Modelica.Media.Water.StandardWater;
  parameter SI.Pressure p_a_start = 1e5 "Inlet start pressure of both pumps";
  parameter SI.Pressure p_b_start = 3e5 "Outlet start pressure of both pumps";
  parameter SI.Temperature T = 303.15 "Water temperature";
  TRANSFORM.Fluid.Machines.Pump pumpA(redeclare package Medium = Medium, controlType="pressure",
    exposeState_a=true, exposeState_b=false, p_a_start=p_a_start, p_b_start=p_b_start,
    T_start=T, m_flow_nominal=10, dp_nominal=4e5, m_flow_start=10)
    "Inlet state exposed: sets the inlet pressure";
  TRANSFORM.Fluid.Machines.Pump pumpB(redeclare package Medium = Medium, controlType="pressure",
    exposeState_a=false, exposeState_b=true, p_a_start=p_a_start, p_b_start=p_b_start,
    T_start=T, m_flow_nominal=10, dp_nominal=2e5, m_flow_start=10)
    "Outlet state exposed: sets the outlet pressure";
  TRANSFORM.Fluid.Machines.Pump_Controlled pumpC(redeclare package Medium = Medium,
    controlType="pressure_a", p_a_start=p_a_start, p_b_start=p_b_start, m_flow_start=10,
    dp_nominal=4e5) "Pump_Controlled setting its inlet pressure";
  TRANSFORM.Fluid.BoundaryConditions.MassFlowSource_T sourceC(redeclare package Medium = Medium,
    m_flow=10, T=T, nPorts=1);
  TRANSFORM.Fluid.BoundaryConditions.Boundary_pT sinkC(redeclare package Medium = Medium,
    p=5e5, T=T, nPorts=1);
  TRANSFORM.Fluid.BoundaryConditions.MassFlowSource_T sourceA(redeclare package Medium = Medium,
    m_flow=10, T=T, nPorts=1);
  TRANSFORM.Fluid.BoundaryConditions.Boundary_pT sinkA(redeclare package Medium = Medium,
    p=5e5, T=T, nPorts=1);
  TRANSFORM.Fluid.BoundaryConditions.Boundary_pT sourceB(redeclare package Medium = Medium,
    p=p_a_start, T=T, nPorts=1);
  TRANSFORM.Fluid.BoundaryConditions.MassFlowSource_T sinkB(redeclare package Medium = Medium,
    m_flow=-10, T=T, nPorts=1);
  Real dp_a = pumpA.port_a.p/p_a_start - 1 "Inlet pressure of pumpA against p_a_start";
  Real dp_b = pumpB.port_b.p/p_b_start - 1 "Outlet pressure of pumpB against p_b_start";
  Real dp_c = pumpC.port_a.p/p_a_start - 1 "Inlet pressure of pumpC against p_a_start";
  TRANSFORM.Utilities.ErrorAnalysis.UnitTests unitTests(n=3, x={dp_a, dp_b, dp_c})
    annotation (Placement(transformation(extent={{80,80},{100,100}})));
equation
  connect(sourceA.ports[1], pumpA.port_a);
  connect(pumpA.port_b, sinkA.ports[1]);
  connect(sourceB.ports[1], pumpB.port_a);
  connect(pumpB.port_b, sinkB.ports[1]);
  connect(sourceC.ports[1], pumpC.port_a);
  connect(pumpC.port_b, sinkC.ports[1]);
  annotation (experiment(StopTime=1, __Dymola_Algorithm="Dassl"));
end Pump_PressureControl;
