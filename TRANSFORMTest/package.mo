within ;
package TRANSFORMTest "Tests for TRANSFORM beyond its examples (not shipped with TRANSFORM)"
  import SI = Modelica.Units.SI;
  extends Modelica.Icons.Package;

  annotation (
    uses(TRANSFORM(version="1.3.0-dev"), Modelica(version="4.0.0")),
    Documentation(info="<html>
<p>Test models for TRANSFORM that are not teaching examples: regression tests for fixed bugs,
checks of functions no example covers, and variants that turn on model options. The package tree
mirrors TRANSFORM's. It is not shipped with TRANSFORM. What belongs here, and how to run it:
README.md of the TRANSFORM-UnitTests repository.</p>
</html>"));
end TRANSFORMTest;
