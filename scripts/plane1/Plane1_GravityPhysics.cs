using Godot;

public partial class Plane1_GravityPhysics : RigidBody3D
{
    Transform3D transform;
    public float Thrust = 0.0f;
    double deltaTime = 0.0;
    public float LiftStrength = 0.5f;
    public float torqueStrength = 4f;
    public float WingOffsetSide = 2.2f; // Distance of wings from center
    public float nosePos = 1.7f;
    public float applyForce = 0;
    public float airFrictionStrength = 2.3f;
    public Vector3 planeScale = new Vector3(1.0f, 1.0f, 1.0F);
    Vector3 upVec = new Vector3(0.0f, 1.0f, 0.0f);
    Vector3 engine = new Vector3(1.6f, 0, 0);

    public override void _PhysicsProcess(double delta)
    {
        transform = Transform;
        // Get forward speed
        Vector3 velocity = LinearVelocity;
        Vector3 velocity_xy = new Vector3(LinearVelocity.X, 0, LinearVelocity.Z);
        Vector3 forward = -GlobalTransform.Basis.X;

        // Only forward component
        float speed = velocity.Length();
        float speed_xy = velocity_xy.Length();

        // Apply upward lift force at each wing
        Vector3 torque = GlobalTransform.Basis.Y * torqueStrength;
        Vector3 lift = upVec * speed_xy * speed_xy * LiftStrength;
        Vector3 airFriction = speed * airFrictionStrength  * (-LinearVelocity.Normalized());

        // Wing positions in local space
        Vector3 leftWing = new Vector3(-0.5f, 0, -WingOffsetSide);
        Vector3 rightWing = new Vector3(-0.5f, 0, WingOffsetSide);
        Vector3 nose = new Vector3(-nosePos, 0, 0);

        // Convert to global space
        Vector3 leftWingGlobal = GlobalTransform * leftWing;
        Vector3 rightWingGlobal = GlobalTransform * rightWing;
        Vector3 noseGlobal = GlobalTransform * nose;
        Vector3 engineGlobal = GlobalTransform * engine;

        if (Input.IsActionPressed("Key_T"))
        {
            if (Thrust <= 500)
            {
                deltaTime += delta;
                if (deltaTime >= 0.3)
                {
                    Thrust += 10f;
                    deltaTime -= 0.2;
                }
                applyForce = 0.01f;
            }
        }
        if (Input.IsActionPressed("Key_G"))
        {
            if (Thrust > 0)
            {
                deltaTime += delta;
                if (deltaTime >= 0.3)
                {
                    Thrust -= 10f;
                    deltaTime -= 0.2;
                }
            }
        }

        transform = transform.Orthonormalized();

        if (Input.IsActionJustReleased("Key_T"))
        {
            applyForce = 0;
            //Thrust = 0;
        }
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
            ApplyForce(torque, rightWingGlobal - GlobalTransform.Origin);
        }
        if (Input.IsActionPressed("Key_A"))
        {
            //transform.Basis = transform.Basis.Rotated(transform.Basis.X.Normalized(), (float)(delta));
            ApplyForce(torque, leftWingGlobal - GlobalTransform.Origin);
        }
        if (lift.Length() <= 150)
            ApplyCentralForce(lift);

        Vector3 forwardForce = forward * Thrust;
        ApplyForce(forwardForce, engineGlobal - GlobalTransform.Origin);
        ApplyCentralForce(airFriction);
        //LinearVelocity += forward * Thrust * (float)delta;
        transform = transform.ScaledLocal(planeScale);
        Transform = transform;
    }
}

