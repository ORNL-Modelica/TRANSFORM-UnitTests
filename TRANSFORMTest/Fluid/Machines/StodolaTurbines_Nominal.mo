within TRANSFORMTest.Fluid.Machines;
model StodolaTurbines_Nominal
  "The two Stodola turbines held at their nominal point must pass their nominal flow"
  extends TRANSFORM.Icons.Example;
  // SteamTurbine and Turbine_SinglePhase_Stodola compute their flow coefficient Kt from the nominal
  // point. Between boundaries at exactly that point (10 MPa, 1000 K in, 5 MPa or 9.5 MPa out; and
  // 15 MPa, 620 K in, 7.5 MPa out, near saturation) the flow must equal m_flow_nominal = 10 kg/s,
  // also when Kt comes from the nominal density d_nominal (use_T_nominal = false):
  //   dm_*: m_flow/m_flow_nominal - 1, 0 when right. On TRANSFORM 1.3.0 Kt came from regRoot2 and the
  //         density at (p, T), the flow from regRoot and the density at (p, h): -4.5e-5 at a
  //         pressure ratio of 0.5, -2.6e-3 at 0.95, and near saturation the steam tables' (p, T) to
  //         (p, h) round trip adds up to about 1e-4.
  replaceable package Medium = Modelica.Media.Water.StandardWater;
  parameter Modelica.Units.SI.Pressure p_in = 10e6;
  parameter Modelica.Units.SI.Temperature T_in = 1000;
  parameter Modelica.Units.SI.MassFlowRate m_nom = 10;
  TRANSFORM.Fluid.Machines.SteamTurbine steam50(redeclare package Medium = Medium,
    p_a_start=p_in, T_a_start=T_in, p_b_start=5e6, T_b_start=900, m_flow_start=m_nom);
  TRANSFORM.Fluid.Machines.SteamTurbine steam95(redeclare package Medium = Medium,
    p_a_start=p_in, T_a_start=T_in, p_b_start=9.5e6, T_b_start=990, m_flow_start=m_nom);
  TRANSFORM.Fluid.Machines.Turbine_SinglePhase_Stodola single50(redeclare package Medium = Medium,
    p_a_start=p_in, T_a_start=T_in, p_b_start=5e6, T_b_start=900, m_flow_start=m_nom);
  TRANSFORM.Fluid.Machines.Turbine_SinglePhase_Stodola single95(redeclare package Medium = Medium,
    p_a_start=p_in, T_a_start=T_in, p_b_start=9.5e6, T_b_start=990, m_flow_start=m_nom);
  TRANSFORM.Fluid.Machines.SteamTurbine steamSat(redeclare package Medium = Medium,
    p_a_start=15e6, T_a_start=620, p_b_start=7.5e6, T_b_start=570, m_flow_start=m_nom)
    "Nominal point near saturation";
  TRANSFORM.Fluid.Machines.Turbine_SinglePhase_Stodola singleD(redeclare package Medium = Medium,
    p_a_start=p_in, T_a_start=T_in, p_b_start=5e6, T_b_start=900, m_flow_start=m_nom,
    use_T_nominal=false) "Kt from the nominal density d_nominal";
  TRANSFORM.Fluid.BoundaryConditions.Boundary_pT inletSat(redeclare package Medium = Medium,
    p=15e6, T=620, nPorts=1);
  TRANSFORM.Fluid.BoundaryConditions.Boundary_pT outSat(redeclare package Medium = Medium,
    p=7.5e6, T=570, nPorts=1);
  TRANSFORM.Electrical.PowerConverters.Generator_Basic gen5;
  TRANSFORM.Electrical.PowerConverters.Generator_Basic gen6;
  TRANSFORM.Fluid.BoundaryConditions.Boundary_pT inlet(redeclare package Medium = Medium,
    p=p_in, T=T_in, nPorts=5);
  TRANSFORM.Fluid.BoundaryConditions.Boundary_pT out50(redeclare package Medium = Medium,
    p=5e6, T=900, nPorts=3);
  TRANSFORM.Fluid.BoundaryConditions.Boundary_pT out95(redeclare package Medium = Medium,
    p=9.5e6, T=990, nPorts=2);
  TRANSFORM.Electrical.PowerConverters.Generator_Basic gen1;
  TRANSFORM.Electrical.PowerConverters.Generator_Basic gen2;
  TRANSFORM.Electrical.PowerConverters.Generator_Basic gen3;
  TRANSFORM.Electrical.PowerConverters.Generator_Basic gen4;
  Real dm_steam50 = steam50.portHP.m_flow/m_nom - 1 "SteamTurbine, pressure ratio 0.5";
  Real dm_steam95 = steam95.portHP.m_flow/m_nom - 1 "SteamTurbine, pressure ratio 0.95";
  Real dm_single50 = single50.port_a.m_flow/m_nom - 1 "Turbine_SinglePhase_Stodola, ratio 0.5";
  Real dm_single95 = single95.port_a.m_flow/m_nom - 1 "Turbine_SinglePhase_Stodola, ratio 0.95";
  Real dm_steamSat = steamSat.portHP.m_flow/m_nom - 1 "SteamTurbine, 15 MPa and 620 K";
  Real dm_singleD = singleD.port_a.m_flow/m_nom - 1 "Turbine_SinglePhase_Stodola, use_T_nominal = false";
  TRANSFORM.Utilities.ErrorAnalysis.UnitTests unitTests(n=6,
    x={dm_steam50, dm_steam95, dm_single50, dm_single95, dm_steamSat, dm_singleD});
equation
  connect(inlet.ports[1], steam50.portHP);
  connect(inlet.ports[2], steam95.portHP);
  connect(inlet.ports[3], single50.port_a);
  connect(inlet.ports[4], single95.port_a);
  connect(steam50.portLP, out50.ports[1]);
  connect(single50.port_b, out50.ports[2]);
  connect(steam95.portLP, out95.ports[1]);
  connect(single95.port_b, out95.ports[2]);
  connect(inlet.ports[5], singleD.port_a);
  connect(singleD.port_b, out50.ports[3]);
  connect(inletSat.ports[1], steamSat.portHP);
  connect(steamSat.portLP, outSat.ports[1]);
  connect(steamSat.shaft_b, gen5.shaft);
  connect(singleD.shaft_b, gen6.shaft);
  connect(steam50.shaft_b, gen1.shaft);
  connect(steam95.shaft_b, gen2.shaft);
  connect(single50.shaft_b, gen3.shaft);
  connect(single95.shaft_b, gen4.shaft);
  annotation (experiment(StopTime=10),
    Documentation(info="<html>
<p>Regression test for the nominal point of <code>TRANSFORM.Fluid.Machines.SteamTurbine</code> and
<code>Turbine_SinglePhase_Stodola</code>.</p>
</html>"));
end StodolaTurbines_Nominal;
