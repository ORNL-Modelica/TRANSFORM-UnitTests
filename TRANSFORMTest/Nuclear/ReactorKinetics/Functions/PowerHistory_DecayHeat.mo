within TRANSFORMTest.Nuclear.ReactorKinetics.Functions;
model PowerHistory_DecayHeat
  "Initial_powerBased_powerHistory with decay heat in the history: a power-up, a shutdown, steady state"
  extends TRANSFORM.Icons.Example;
  // Regression test for TRANSFORM.Nuclear.ReactorKinetics.Functions.Initial_powerBased_powerHistory
  // with includeDH = true: the history's power is fission plus decay power, and the function must
  // find the fission power. Before its fix this was an iteration that stopped with "did not
  // converge" for nearly every history of 6 or more points and for shutdowns, and divided by zero
  // at a point with no fission power.
  // Three histories; the reference values come from integrating the equations with scipy (Radau,
  // rtol 1e-12), and the histories' totals add the decay power of a known fission history:
  //   up:     fission 0 (idle) for 100 s, -> 1 MW, flat, -> 2 MW, flat, -> 1.9 MW, every 100 s.
  //   down:   1 MW for a year, then a scram to 20 kW in 100 s and to 10 kW 3700 s later; decay
  //           heat is 56.5 % of the power at the end.
  //   steady: 1 MW with Cs_0, Es_0 at their steady values, held 1000 s: the result must be those
  //           steady values (C = betas/(lambda*Lambda)*P, E = efs/lambda_dh*P).
  //   dCs_*, dQ_*: largest relative gap in Cs, and relative gap in the decay power, to the reference;
  //                each must be below 1e-9. They are 1.6e-12 to 1.0e-11 for the
  //                power-up and shutdown, set by the 12-digit references, and about 2e-16 for steady.
  import SI = Modelica.Units.SI;
  TRANSFORM.Nuclear.ReactorKinetics.Data.PrecursorGroups.precursorGroups_6_TRACEdefault data;
  TRANSFORM.Nuclear.ReactorKinetics.Data.DecayHeat.decayHeat_11_TRACEdefault data_dh;
  parameter SI.Time Lambda = 1e-5 "Prompt neutron generation time";
  parameter SI.Power P_steady = 1e6 "Fission power of the steady history";
  parameter SI.Power history_up[7, 2] = [0, 0; 100, 0; 200, 1029510.61755; 300, 1039192.27111;
    400, 2072822.87393; 500, 2084940.19678; 600, 1987631.68567]
    "Power-up history [t, Q], fission plus decay power";
  parameter SI.Power Cs_up_ref[data.nC] = {8298257.74423, 112956959.521, 1615591016.34,
    2024872107.1, 8400513725.76, 3711672935.44} "Precursor powers at the end, from scipy";
  parameter SI.Power Q_up_ref = 87631.6856737 "Decay power at the end, from scipy";
  parameter SI.Power history_down[4, 2] = [0, 1e6; 3.15e7, 1069231.63332; 3.15e7 + 100,
    60311.2290018; 3.15e7 + 3800, 22966.5225236]
    "Shutdown history [t, Q], fission plus decay power";
  parameter SI.Power Cs_down_ref[data.nC] = {43672.15154, 594401.624343, 8496121.85002,
    10633602.0875, 43904204.6834, 19862563.6522} "Precursor powers at the end, from scipy";
  parameter SI.Power Q_down_ref = 12966.5225236 "Decay power at the end, from scipy";
  parameter SI.Power Cs_steady[data.nC] = data.alphas*data.Beta./(data.lambdas*Lambda)*P_steady
    "Steady precursor powers";
  parameter SI.Energy Es_steady[data_dh.nC] = data_dh.efs./data_dh.lambdas*P_steady
    "Steady decay-heat energies";
  parameter SI.Power Q_steady = P_steady*(1 + sum(data_dh.efs)) "Steady total power";
  parameter SI.Power Cs_up[data.nC](each fixed=false);
  parameter SI.Energy Es_up[data_dh.nC](each fixed=false);
  parameter SI.Power Cs_down[data.nC](each fixed=false);
  parameter SI.Energy Es_down[data_dh.nC](each fixed=false);
  parameter SI.Power Cs_st[data.nC](each fixed=false);
  parameter SI.Energy Es_st[data_dh.nC](each fixed=false);
  Real dCs_up = max(abs(Cs_up - Cs_up_ref)./Cs_up_ref) "Power-up: largest relative gap in Cs";
  Real dQ_up = abs(sum(data_dh.lambdas.*Es_up) - Q_up_ref)/Q_up_ref "Power-up: gap in decay power";
  Real dCs_down = max(abs(Cs_down - Cs_down_ref)./Cs_down_ref) "Shutdown: largest relative gap in Cs";
  Real dQ_down = abs(sum(data_dh.lambdas.*Es_down) - Q_down_ref)/Q_down_ref "Shutdown: gap in decay power";
  Real dCs_steady = max(abs(Cs_st - Cs_steady)./Cs_steady) "Steady: largest relative gap in Cs";
  Real dEs_steady = max(abs(Es_st - Es_steady)./Es_steady) "Steady: largest relative gap in Es";
  Real Cs_sum_up = sum(Cs_up) "Power-up: sum of Cs";
  Real Cs_sum_down = sum(Cs_down) "Shutdown: sum of Cs";
  TRANSFORM.Utilities.ErrorAnalysis.UnitTests unitTests(n=8, x={dCs_up, dQ_up, dCs_down, dQ_down,
    dCs_steady, dEs_steady, Cs_sum_up, Cs_sum_down});
initial equation
  (Cs_up, Es_up) = TRANSFORM.Nuclear.ReactorKinetics.Functions.Initial_powerBased_powerHistory(
    history_up, data.lambdas, data.alphas, data.Beta, Lambda, data_dh.lambdas, data_dh.efs,
    includeDH=true);
  (Cs_down, Es_down) = TRANSFORM.Nuclear.ReactorKinetics.Functions.Initial_powerBased_powerHistory(
    history_down, data.lambdas, data.alphas, data.Beta, Lambda, data_dh.lambdas, data_dh.efs,
    includeDH=true);
  (Cs_st, Es_st) = TRANSFORM.Nuclear.ReactorKinetics.Functions.Initial_powerBased_powerHistory(
    [0, Q_steady; 1000, Q_steady], data.lambdas, data.alphas, data.Beta, Lambda, data_dh.lambdas,
    data_dh.efs, includeDH=true, Cs_0=Cs_steady, Es_0=Es_steady);
  annotation (experiment(StopTime=1),
    Documentation(info="<html>
<p>Regression test for <code>TRANSFORM.Nuclear.ReactorKinetics.Functions.Initial_powerBased_powerHistory</code>
when the history includes decay heat.</p>
</html>"));
end PowerHistory_DecayHeat;
