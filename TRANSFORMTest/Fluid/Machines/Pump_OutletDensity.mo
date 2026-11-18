within TRANSFORMTest.Fluid.Machines;
model Pump_OutletDensity
  "A pump's volume flow and head must use the liquid's density at the outlet pressure"
  extends TRANSFORM.Icons.Example;
  // A pump raises the pressure of a liquid; the head-to-pressure relation dp = d*g*head and the
  // volume flow V_flow = m_flow/d need the liquid's density. The pump's fluid leaves at its
  // outlet pressure, so that density is d(p_outlet, h_pump). From a saturated-liquid inlet the
  // outlet enthalpy is above saturation at the inlet pressure, so a density taken at the inlet
  // pressure is that of a two-phase mixture.
  //   dV_*: V_flow*d(p_outlet, h_pump)/m_flow - 1, 0 when right. On TRANSFORM 1.3.0 the pump
  //         took the density at the inlet pressure: 0.54 for the saturated inlet (630 against
  //         970 kg/m3) and 1.4e-4 for the subcooled one. With a 10 MPa outlet the saturated case
  //         did not initialize at all.
  //   dE_sat: (h_pump - h_in)*d(p_outlet, h_pump)/(p_out - p_in) - 1: the pump's work must heat the
  //         fluid by dp/d (efficiency 1 here), so 0 when right; it checks W_ideal.
  //   pumpSat.N: the speed that gives this flow and head; checks dp = d*g*head through the baseline.
  replaceable package Medium = Modelica.Media.Water.StandardWater;
  parameter SI.Pressure p_in = 0.5e5 "Inlet pressure";
  parameter SI.Pressure p_out = 3e5 "Outlet pressure";
  parameter SI.MassFlowRate m_flow = 10 "Pumped mass flow rate";
  parameter SI.SpecificEnthalpy h_sat = Medium.bubbleEnthalpy(Medium.setSat_p(p_in))
    "Saturated liquid at the inlet pressure";
  TRANSFORM.Fluid.Machines.Pump pumpSat(redeclare package Medium = Medium,
    controlType="m_flow", m_flow_input=m_flow, m_flow_nominal=m_flow, dp_nominal=p_out - p_in,
    d_nominal=960, p_a_start=p_in, p_b_start=p_out, use_T_start=false, h_start=h_sat + 1e4,
    m_flow_start=m_flow) "Saturated-liquid inlet";
  TRANSFORM.Fluid.Machines.Pump pumpSub(redeclare package Medium = Medium,
    controlType="m_flow", m_flow_input=m_flow, m_flow_nominal=m_flow, dp_nominal=p_out - p_in,
    d_nominal=985, p_a_start=p_in, p_b_start=p_out, T_start=335, m_flow_start=m_flow)
    "Subcooled inlet, 60 degC";
  TRANSFORM.Fluid.BoundaryConditions.Boundary_ph inSat(redeclare package Medium = Medium,
    p=p_in, h=h_sat, nPorts=1);
  TRANSFORM.Fluid.BoundaryConditions.Boundary_pT inSub(redeclare package Medium = Medium,
    p=p_in, T=333.15, nPorts=1);
  TRANSFORM.Fluid.BoundaryConditions.Boundary_pT outlet(redeclare package Medium = Medium,
    p=p_out, T=340, nPorts=2);
  Real dV_sat = pumpSat.V_flow*Medium.density_phX(p_out, pumpSat.medium.h, Medium.reference_X)
    /m_flow - 1 "Saturated inlet";
  Real dV_sub = pumpSub.V_flow*Medium.density_phX(p_out, pumpSub.medium.h, Medium.reference_X)
    /m_flow - 1 "Subcooled inlet";
  Real dE_sat = (pumpSat.medium.h - h_sat)*Medium.density_phX(p_out, pumpSat.medium.h,
    Medium.reference_X)/(p_out - p_in) - 1 "Saturated inlet, enthalpy rise";
  TRANSFORM.Utilities.ErrorAnalysis.UnitTests unitTests(n=4, x={dV_sat, dV_sub, dE_sat, pumpSat.N})
    annotation (Placement(transformation(extent={{80,80},{100,100}})));
equation
  connect(inSat.ports[1], pumpSat.port_a);
  connect(pumpSat.port_b, outlet.ports[1]);
  connect(inSub.ports[1], pumpSub.port_a);
  connect(pumpSub.port_b, outlet.ports[2]);
  annotation (experiment(StopTime=10, __Dymola_Algorithm="Dassl"));
end Pump_OutletDensity;
