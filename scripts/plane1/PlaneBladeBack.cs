using Godot;
using System;

public partial class PlaneBladeBack : Node3D
{
	Transform3D transform;
	Vector3 axis = new Vector3(1, 0, 0); // Or Vector3.Right
	double angVel = 0.1;
	double angAcc = 2;
	double deltaTime = 0.0;
	Vector3 bladeScale = new Vector3(0.65F, 0.65F, 0.65F);
	
	public override void _Process(double delta){
		transform = Transform;
		if(Input.IsActionPressed("Key_T")){
			if(angVel <= 0.7){
			deltaTime += delta;
			if(deltaTime >= 0.3){
				 angVel += delta * angAcc;
				 deltaTime -= 0.2;
				}
			}
		}
		if(Input.IsActionPressed("Key_G")){
			deltaTime += delta;
			if(deltaTime >= 0.3 && angVel > 0.0){
				 angVel -= delta * angAcc;
				deltaTime -= 0.2;
				}
		}
		transform = transform.Orthonormalized();
		
		transform.Basis = transform.Basis.Rotated(transform.Basis.Y.Normalized(), (float)(angVel * delta * 20));
		//transform.Basis = new Basis(transform.Basis.Y, (float)(angVel * delta * 20)) * transform.Basis;
		
		// Rotate the transform around the X axis by 0.1 radians.w
		transform = transform.ScaledLocal(bladeScale);
		Transform = transform;
	}
}
