within TRANSFORMTest.Obsolete;
model DeprecatedPaths
  "A model written for TRANSFORM 1.2.0 that uses paths moved to TRANSFORM.Obsolete in 1.3.0"
  extends TRANSFORM.Icons.Example;
  // TRANSFORM 1.3.0 keeps one-line deprecated aliases at the old paths, so a model written for 1.2.0
  // runs unchanged, with a warning. The aliases and this test go together in 1.4.0.
  //   y:  TRANSFORM.Math.GNU_ScientificLibrary...bessel_Jn(1, 3) = J1(3) = 0.339059 (A&S table 9.1).
  //   nX: the number of substances of TRANSFORM.Media.LookupTableMedia.ParaHydrogen (1).
  replaceable package Medium = TRANSFORM.Media.LookupTableMedia.ParaHydrogen;
  Real y = TRANSFORM.Math.GNU_ScientificLibrary.Functions.specfunc.bessel_Jn(1, 3.0)
    "Bessel J1(3) through the old path";
  Real nX = Medium.nX "Substances of the medium at its old path";
  TRANSFORM.Utilities.ErrorAnalysis.UnitTests unitTests(n=2, x={y, nX});
  annotation (experiment(StopTime=1),
    Documentation(info="<html>
<p>Regression test for the deprecated aliases that TRANSFORM 1.3.0 keeps at the paths moved to
<code>TRANSFORM.Obsolete</code>. It is removed with them.</p>
</html>"));
end DeprecatedPaths;
