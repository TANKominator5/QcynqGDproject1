//using System.Numerics;
//using System.Numerics;
using Godot;

public partial class Plane1_GravityPhysics : RigidBody3D
{
    Transform3D transform;
    public float Thrust = 0.0f;
    double deltaTime = 0.0;
    public float LiftStrength = 0.07f;
    public float torqueStrength = 9.3f;
    public float WingOffsetSide = 2.2f; // Distance of wings from center
    public float nosePos = 1.7f;
    public float applyForce = 0;
    //public float airFrictionStrength = 3f;
    public Vector3 planeScale = new Vector3(1.0f, 1.0f, 1.0F);
    Vector3 upVec = new Vector3(0.0f, 1.0f, 0.0f);
    Vector3 engine = new Vector3(1.6f, 0, 0);
    Vector3 lift = new Vector3(0.0f, 0.0f, 0.0f);

    public override void _PhysicsProcess(double delta)
    {
        transform = Transform;
        // Get forward speed
        Vector3 velocity_xy = new Vector3(LinearVelocity.X, 0, LinearVelocity.Z);
        Vector3 forward = -GlobalTransform.Basis.X;
        forward = forward.Normalized();

        //float speed = velocity.Length();
        // Only horizontal component
        //float speed_x = LinearVelocity.Dot(forward);
        float speed_x = velocity_xy.Length();

        // Apply upward lift force at each wing
        Vector3 torque = GlobalTransform.Basis.Y * torqueStrength;//upward wrt to local space of plane
        lift = upVec * speed_x * speed_x * LiftStrength;

        Vector3 torqueAng = (-GlobalTransform.Basis.X) * torqueStrength;//made for using torque through ApplyTorque() function

        Vector3 nose = new Vector3(-nosePos, 0, 0);

        Vector3 noseGlobal = GlobalTransform * nose;
        Vector3 engineGlobal = GlobalTransform * engine;

        if (Input.IsActionPressed("Key_T"))
        {
            if (Thrust <= 1000)
            {
                deltaTime += delta;
                if (deltaTime >= 0.25)
                {
                    Thrust += 10f;
                    deltaTime -= 0.15;
                }
            }
        }
        if (Input.IsActionPressed("Key_G"))
        {
            if (Thrust > 0)
            {
                deltaTime += delta;
                if (deltaTime >= 0.25)
                {
                    Thrust -= 10f;
                    deltaTime -= 0.15;
                }
            }
        }

        transform = transform.Orthonormalized();

        if (Input.IsActionPressed("Key_W"))
        {
            //transform.Basis = transform.Basis.Rotated(transform.Basis.Z.Normalized(), (float)(delta));
            ApplyForce(-torque, noseGlobal - GlobalTransform.Origin);
        }
        if (Input.IsActionPressed("Key_S"))
        {
            //transform.Basis = transform.Basis.Rotated(transform.Basis.Z.Normalized(), (float)(-delta));
            ApplyForce(torque, noseGlobal - GlobalTransform.Origin);
        }
        if (Input.IsActionPressed("Key_D"))
        {
            //transform.Basis = transform.Basis.Rotated(transform.Basis.X.Normalized(), (float)(-delta));
            //ApplyForce(torque, rightWingGlobal - GlobalTransform.Origin);
            ApplyTorque(torqueAng);
        }
        if (Input.IsActionPressed("Key_A"))
        {
            //transform.Basis = transform.Basis.Rotated(transform.Basis.X.Normalized(), (float)(delta));
            //ApplyForce(torque, leftWingGlobal - GlobalTransform.Origin);
            ApplyTorque(-torqueAng);
        }
        
        if (lift.Length() > 9.8f * Mass)
            lift = upVec * 9.8f * Mass;

        Vector3 forwardForce = forward * Thrust;
        ApplyForce(forwardForce, engineGlobal - GlobalTransform.Origin);
        ApplyCentralForce(lift);
        //LinearVelocity += forward * Thrust * (float)delta;
        transform = transform.ScaledLocal(planeScale);
        Transform = transform;
        
        //GD.Print("Lift: ", lift.Length(), " Weight: ", Mass * 9.8f);
    }
}

