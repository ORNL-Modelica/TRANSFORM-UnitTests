within TRANSFORMTest.Nuclear.ReactorKinetics.Functions;
model PowerHistory_vs_ODE
  "Initial_powerBased_powerHistory against integrating the precursor and decay-heat equations"
  extends TRANSFORM.Icons.Example;
  // Regression test for TRANSFORM.Nuclear.ReactorKinetics.Functions.Initial_powerBased_powerHistory
  // (TRANSFORM CHANGELOG, Unreleased/Fixed). The function gives the precursor powers Cs and
  // decay-heat energies Es at the end of a power history, in closed form for a history that is
  // linear between its points. This model integrates the same equations over the same history,
  //   der(C) = beta/Lambda*P - lambda*C,   der(E) = ef*P - lambda_dh*E,
  // from zero (and once more from the start values Cs_0, Es_0), so at time = t_end the
  // integrated values must equal the function's.
  //   dCs_rel:     largest relative gap between Cs and the integrated C (0 at t_end when right;
  //                0.249 with the dimensionally wrong "- t[i]" term the precursor update had).
  //   dQdecay_rel: relative gap in the decay power sum(lambda_dh*E) (0 at t_end). Not per group:
  //                the slowest group (lambda_dh = 7.6e-10 1/s) loses about 0.3 % to round-off in
  //                the closed form over 100-s intervals, and carries almost no decay power.
  //   dCs0_rel, dEs0_rel: an empty history must return the start values Cs_0, Es_0 (1 when they
  //                are ignored, as they were without decay heat in the history).
  //   dStart_rel:  the same history started from Cs_0, Es_0: largest relative gap in Cs or in the
  //                decay power (0 at t_end when right; large when Es_0 wrongly scales the
  //                history's power, which holds no decay heat here).
  //   Cs_sum_DH:   sum of Cs with includeDH = true for the same history (no independent value;
  //                it moves if that branch changes).
  // The history is short and changes slope after t = 0: the wrong term is multiplied by the slope
  // and by t[i], and only recent intervals count. The library example's last interval is 1e16 s
  // long, so it moved by about 1e-10 there and no test saw it.
  import SI = Modelica.Units.SI;
  TRANSFORM.Nuclear.ReactorKinetics.Data.PrecursorGroups.precursorGroups_6_TRACEdefault data;
  TRANSFORM.Nuclear.ReactorKinetics.Data.DecayHeat.decayHeat_11_TRACEdefault data_dh;
  parameter SI.Time Lambda = 1e-5 "Prompt neutron generation time";
  parameter SI.Power history[4, 2] = [0, 0; 100, 1e6; 200, 2e6; 300, 2e6]
    "Power history [t, Q]: two ramps, then flat";
  parameter SI.Time t_end = history[end, 1];
  parameter SI.Power Cs_0[data.nC] = fill(1e6, data.nC) "Start values for the empty history";
  parameter SI.Energy Es_0[data_dh.nC] = fill(1e6, data_dh.nC) "Start values for the empty history";
  parameter SI.Power Cs[data.nC](each fixed=false);
  parameter SI.Energy Es[data_dh.nC](each fixed=false);
  parameter SI.Power Cs_DH[data.nC](each fixed=false);
  parameter SI.Energy Es_DH[data_dh.nC](each fixed=false);
  parameter SI.Power Cs_empty[data.nC](each fixed=false);
  parameter SI.Energy Es_empty[data_dh.nC](each fixed=false);
  parameter SI.Power Cs_start[data.nC](each fixed=false);
  parameter SI.Energy Es_start[data_dh.nC](each fixed=false);
  SI.Power P = if time < history[2, 1] then history[2, 2]*time/history[2, 1]
    elseif time < history[3, 1] then history[2, 2] + (history[3, 2] - history[2, 2])*
      (time - history[2, 1])/(history[3, 1] - history[2, 1])
    else history[3, 2] "Fission power, linear between the history points";
  SI.Power C[data.nC](each start=0, each fixed=true) "Integrated precursor powers";
  SI.Energy E[data_dh.nC](each start=0, each fixed=true) "Integrated decay-heat energies";
  SI.Power C0[data.nC](start=Cs_0, each fixed=true) "Integrated from Cs_0";
  SI.Energy E0[data_dh.nC](start=Es_0, each fixed=true) "Integrated from Es_0";
  Real dCs_rel = max(abs(Cs - C)./Cs) "Largest relative gap, function vs integrated";
  Real dQdecay_rel = abs(sum(data_dh.lambdas.*(Es - E)))/sum(data_dh.lambdas.*Es)
    "Relative gap in decay power, function vs integrated";
  Real dCs0_rel = max(abs(Cs_empty - Cs_0)./Cs_0) "Empty history: gap to Cs_0";
  Real dEs0_rel = max(abs(Es_empty - Es_0)./Es_0) "Empty history: gap to Es_0";
  Real dStart_rel = max(max(abs(Cs_start - C0)./Cs_start),
    abs(sum(data_dh.lambdas.*(Es_start - E0)))/sum(data_dh.lambdas.*Es_start))
    "From Cs_0, Es_0: largest relative gap, function vs integrated";
  Real Cs_sum_DH = sum(Cs_DH) "Sum of Cs with includeDH = true";
  TRANSFORM.Utilities.ErrorAnalysis.UnitTests unitTests(n=6,
    x={dCs_rel, dQdecay_rel, dCs0_rel, dEs0_rel, dStart_rel, Cs_sum_DH})
    annotation (Placement(transformation(extent={{80,80},{100,100}})));
initial equation
  (Cs, Es) = TRANSFORM.Nuclear.ReactorKinetics.Functions.Initial_powerBased_powerHistory(
    history, data.lambdas, data.alphas, data.Beta, Lambda, data_dh.lambdas, data_dh.efs,
    includeDH=false);
  (Cs_DH, Es_DH) = TRANSFORM.Nuclear.ReactorKinetics.Functions.Initial_powerBased_powerHistory(
    history, data.lambdas, data.alphas, data.Beta, Lambda, data_dh.lambdas, data_dh.efs,
    includeDH=true);
  (Cs_empty, Es_empty) = TRANSFORM.Nuclear.ReactorKinetics.Functions.Initial_powerBased_powerHistory(
    fill(0.0, 0, 2), data.lambdas, data.alphas, data.Beta, Lambda, data_dh.lambdas, data_dh.efs,
    includeDH=false, Cs_0=Cs_0, Es_0=Es_0);
  (Cs_start, Es_start) = TRANSFORM.Nuclear.ReactorKinetics.Functions.Initial_powerBased_powerHistory(
    history, data.lambdas, data.alphas, data.Beta, Lambda, data_dh.lambdas, data_dh.efs,
    includeDH=false, Cs_0=Cs_0, Es_0=Es_0);
equation
  der(C) = data.alphas*data.Beta/Lambda*P - data.lambdas.*C;
  der(E) = data_dh.efs*P - data_dh.lambdas.*E;
  der(C0) = data.alphas*data.Beta/Lambda*P - data.lambdas.*C0;
  der(E0) = data_dh.efs*P - data_dh.lambdas.*E0;
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(StopTime=300, Interval=1, Tolerance=1e-8));
end PowerHistory_vs_ODE;
