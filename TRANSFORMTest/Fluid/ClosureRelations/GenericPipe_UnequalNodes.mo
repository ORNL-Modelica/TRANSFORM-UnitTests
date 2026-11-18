within TRANSFORMTest.Fluid.ClosureRelations;
model GenericPipe_UnequalNodes
  "Pipe geometry whose two nodes differ in length: surface area per node and in total"
  extends TRANSFORM.Icons.Example;
  // Perimeter 0.1 m, node lengths 1 m and 3 m: node surface areas 0.1 and 0.3 m2, total 0.4 m2.
  TRANSFORM.Fluid.ClosureRelations.Geometry.Models.DistributedVolume_1D.GenericPipe geometry(
    nV=2,
    dlengths={1,3},
    crossAreas={6e-4,6e-4},
    perimeters={0.1,0.1}) annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  TRANSFORM.Utilities.ErrorAnalysis.UnitTests unitTests(n=3, x={geometry.surfaceAreas_nVtotal[1],
        geometry.surfaceAreas_nVtotal[2],geometry.surfaceArea_total})
    annotation (Placement(transformation(extent={{80,80},{100,100}})));
  annotation (experiment(StopTime=1),
    Documentation(info="<html>
<p>Regression test for the per-node and total surface areas of
<code>TRANSFORM.Fluid.ClosureRelations.Geometry.Models.DistributedVolume_1D.GenericPipe</code>
when its nodes differ.</p>
</html>"));
end GenericPipe_UnequalNodes;
