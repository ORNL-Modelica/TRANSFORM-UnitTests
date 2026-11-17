within TRANSFORMTest.HeatAndMassTransfer.DiscritizedModels;
model StartValues_2D3D
  "Edge and face start temperatures of Conduction_2D and Conduction_3D land on their volumes"
  extends TRANSFORM.Icons.Example;
  // Every start value differs, so a value placed on the wrong edge or face, or averaged away,
  // shows. Conduction_2D keeps its default exposeState flags (b1 and b2 false). No port is
  // connected and the slabs are 1 m thick, so the temperatures barely move in 100 s.
  TRANSFORM.HeatAndMassTransfer.DiscritizedModels.Conduction_2D slab2D(
    redeclare package Material = TRANSFORM.Media.Solids.SS316,
    redeclare model Geometry =
        TRANSFORM.HeatAndMassTransfer.ClosureRelations.Geometry.Models.Plane_2D (
         nX=4, nY=4),
    T_a1_start=300,
    T_b1_start=400,
    T_a2_start=500,
    T_b2_start=600) annotation (Placement(transformation(extent={{-40,-10},{-20,10}})));
  TRANSFORM.HeatAndMassTransfer.DiscritizedModels.Conduction_3D slab3D(
    redeclare package Material = TRANSFORM.Media.Solids.SS316,
    redeclare model Geometry =
        TRANSFORM.HeatAndMassTransfer.ClosureRelations.Geometry.Models.Plane_3D (
         nX=3, nY=3, nZ=3),
    T_a1_start=300,
    T_b1_start=400,
    T_a2_start=500,
    T_b2_start=600,
    T_a3_start=700,
    T_b3_start=800) annotation (Placement(transformation(extent={{20,-10},{40,10}})));
  TRANSFORM.Utilities.ErrorAnalysis.UnitTests unitTests(n=6, x={slab2D.materials[1, 2].T,
        slab2D.materials[4, 2].T, slab2D.materials[2, 4].T, slab3D.materials[1, 2, 2].T,
        slab3D.materials[2, 2, 3].T, slab3D.materials[2, 2, 2].T})
    annotation (Placement(transformation(extent={{80,80},{100,100}})));
  annotation (experiment(StopTime=100, __Dymola_NumberOfIntervals=100),
    Documentation(info="<html>
<p>Regression test for the start temperatures of
<code>TRANSFORM.HeatAndMassTransfer.DiscritizedModels.Conduction_2D</code> and
<code>Conduction_3D</code>: each edge (2-D) or face (3-D) start value is the start temperature
of the volumes on that edge or face.</p>
</html>"));
end StartValues_2D3D;
