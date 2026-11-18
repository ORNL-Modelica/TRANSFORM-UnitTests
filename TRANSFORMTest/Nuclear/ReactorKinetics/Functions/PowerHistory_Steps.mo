within TRANSFORMTest.Nuclear.ReactorKinetics.Functions;
model PowerHistory_Steps
  "Initial_powerBased_powerHistory for a sub-second ramp and a step, against integrating the equations"
  extends TRANSFORM.Icons.Example;
  // Regression test for TRANSFORM.Nuclear.ReactorKinetics.Functions.Initial_powerBased_powerHistory
  // with history intervals shorter than 1 s: a 0.5-s ramp to 1 MW and a step to 2 MW written as a
  // repeated time (t = 100 s twice). The function must return the precursor powers Cs and the
  // decay-heat energies Es that integrating
  //   der(C) = beta/Lambda*P - lambda*C,   der(E) = ef*P - lambda_dh*E
  // over the same history gives at its end (t = 200 s):
  //   dCs_rel, dEs_rel: largest relative gap over the groups (0 when right). With intervals clamped
  //                     to 1 s the gaps were 0.123 and 0.333.
  //   Cs_sum:           sum of Cs, 1.56527585e10 W from scipy's Radau integration of the same history.
  import SI = Modelica.Units.SI;
  TRANSFORM.Nuclear.ReactorKinetics.Data.PrecursorGroups.precursorGroups_6_TRACEdefault data;
  TRANSFORM.Nuclear.ReactorKinetics.Data.DecayHeat.decayHeat_11_TRACEdefault data_dh;
  parameter SI.Time Lambda = 1e-5 "Prompt neutron generation time";
  parameter SI.Power history[5, 2] = [0, 0; 0.5, 1e6; 100, 1e6; 100, 2e6; 200, 2e6]
    "Power history [t, Q]: a 0.5-s ramp, flat, a step at 100 s, flat";
  parameter SI.Power Cs[data.nC](each fixed=false);
  parameter SI.Energy Es[data_dh.nC](each fixed=false);
  SI.Power P = if time < 0.5 then 1e6*time/0.5 elseif time < 100 then 1e6 else 2e6
    "Fission power of the history";
  SI.Power C[data.nC](each start=0, each fixed=true) "Integrated precursor powers";
  SI.Energy E[data_dh.nC](each start=0, each fixed=true) "Integrated decay-heat energies";
  Real dCs_rel = max(abs(Cs - C)./Cs) "Largest relative gap in Cs, function vs integrated";
  Real dEs_rel = max(abs(Es - E)./Es) "Largest relative gap in Es, function vs integrated";
  Real Cs_sum = sum(Cs) "Sum of Cs";
  TRANSFORM.Utilities.ErrorAnalysis.UnitTests unitTests(n=3, x={dCs_rel, dEs_rel, Cs_sum});
initial equation
  (Cs, Es) = TRANSFORM.Nuclear.ReactorKinetics.Functions.Initial_powerBased_powerHistory(
    history, data.lambdas, data.alphas, data.Beta, Lambda, data_dh.lambdas, data_dh.efs,
    includeDH=false);
equation
  der(C) = data.alphas*data.Beta/Lambda*P - data.lambdas.*C;
  der(E) = data_dh.efs*P - data_dh.lambdas.*E;
  annotation (experiment(StopTime=200, Tolerance=1e-10, __Dymola_NumberOfIntervals=200),
    Documentation(info="<html>
<p>Regression test for <code>TRANSFORM.Nuclear.ReactorKinetics.Functions.Initial_powerBased_powerHistory</code>
with history intervals shorter than 1 s and a step in power. The comparison is at the end time, 200 s.</p>
</html>"));
end PowerHistory_Steps;
