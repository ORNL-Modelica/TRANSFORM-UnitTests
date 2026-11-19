within TRANSFORMTest.Fluid.Machines;
model Pump_ParallelPower
  "A group of nParallel pumps must heat its fluid by the power of all of them"
  extends TRANSFORM.Icons.Example;
  // One pump and a group of two (nParallel = 2), each pump at 10 kg/s from 1 to 11 bar, water at
  // 60 degC, efficiency 1. All of a pump's work heats the fluid, so the enthalpy rise must be dp/d
  // in both: the group carries twice the flow and must add twice the power.
  //   dh_*: (h_pump - h_in)*d(p_out, h_pump)/(p_out - p_in) - 1, 0 when right. On TRANSFORM 1.3.0
  //         the group's energy balance added one pump's power: dh_2 was -0.5.
  replaceable package Medium = Modelica.Media.Water.StandardWater;
  parameter SI.Pressure p_in = 1e5 "Inlet pressure";
  parameter SI.Pressure p_out = 11e5 "Outlet pressure";
  parameter SI.Temperature T_in = 333.15 "Inlet temperature";
  parameter SI.SpecificEnthalpy h_in = Medium.specificEnthalpy_pTX(p_in, T_in, Medium.reference_X)
    "Inlet specific enthalpy";
  TRANSFORM.Fluid.Machines.Pump pump1(redeclare package Medium = Medium, nParallel=1,
    controlType="m_flow", m_flow_input=10, m_flow_nominal=10, dp_nominal=p_out - p_in,
    d_nominal=983, exposeState_a=false, exposeState_b=true, p_a_start=p_in, p_b_start=p_out,
    T_start=T_in, m_flow_start=10) "One pump";
  TRANSFORM.Fluid.Machines.Pump pump2(redeclare package Medium = Medium, nParallel=2,
    controlType="m_flow", m_flow_input=10, m_flow_nominal=10, dp_nominal=p_out - p_in,
    d_nominal=983, exposeState_a=false, exposeState_b=true, p_a_start=p_in, p_b_start=p_out,
    T_start=T_in, m_flow_start=20) "Two pumps in parallel";
  TRANSFORM.Fluid.BoundaryConditions.Boundary_pT inlet(redeclare package Medium = Medium,
    p=p_in, T=T_in, nPorts=2);
  TRANSFORM.Fluid.BoundaryConditions.Boundary_pT outlet(redeclare package Medium = Medium,
    p=p_out, T=340, nPorts=2);
  Real dh_1 = (pump1.medium.h - h_in)*Medium.density_phX(p_out, pump1.medium.h,
    Medium.reference_X)/(p_out - p_in) - 1 "One pump";
  Real dh_2 = (pump2.medium.h - h_in)*Medium.density_phX(p_out, pump2.medium.h,
    Medium.reference_X)/(p_out - p_in) - 1 "Two pumps in parallel";
  TRANSFORM.Utilities.ErrorAnalysis.UnitTests unitTests(n=3, x={dh_1, dh_2, pump2.port_a.m_flow})
    annotation (Placement(transformation(extent={{80,80},{100,100}})));
equation
  connect(inlet.ports[1], pump1.port_a);
  connect(pump1.port_b, outlet.ports[1]);
  connect(inlet.ports[2], pump2.port_a);
  connect(pump2.port_b, outlet.ports[2]);
  annotation (experiment(StopTime=1, __Dymola_Algorithm="Dassl"));
end Pump_ParallelPower;
