using Godot;
using System;

public partial class camera1 : SpringArm3D
{
	public float sensibility = 0.005f;
	[Export] public Node3D target;
	[Export] public float followSpeed = 65f;

	public override void _Ready()
	{
		Input.MouseMode = Input.MouseModeEnum.Captured;
	}

	public override void _UnhandledInput(InputEvent @event)
	{
		if (@event is InputEventMouseMotion motionEvent)
		{
			Rotation = new Vector3((float)Mathf.Clamp(Rotation.X - motionEvent.Relative.Y * sensibility, -Mathf.Pi / 2, Mathf.Pi / 16), (float)Mathf.Wrap(Rotation.Y - motionEvent.Relative.X * sensibility, 0.0, float.Tau), Rotation.Z);
		}
	}
	
	public override void _PhysicsProcess(double delta)
   {
    Vector3 currentPos = GlobalTransform.Origin;
    Vector3 targetPos = target.GlobalTransform.Origin;

    Vector3 newPos = currentPos.Lerp(targetPos, (float)(followSpeed * delta));
    GlobalTransform = new Transform3D(GlobalTransform.Basis, newPos);
   }

}
