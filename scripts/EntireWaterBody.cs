//using System.Numerics;
using Godot;
//using System;

public partial class EntireWaterBody : Node3D
{
    [Export] Node3D aircraft;
    public Transform3D newPos;
    [Export] public float followSpeed = 100f;

    public override void _PhysicsProcess(double delta)
    {
        Vector3 currentPos = GlobalTransform.Origin;
        Vector3 targetPos = aircraft.GlobalTransform.Origin;
        targetPos.Y = currentPos.Y;

        Vector3 newPos = currentPos.Lerp(targetPos, (float)(followSpeed * delta));

        GlobalTransform = new Transform3D(GlobalTransform.Basis, newPos);
    }
}
