using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Swivel : MonoBehaviour
{
    [SerializeField] private Vector3 direction;
    [SerializeField] private float force;
    [SerializeField] private Rigidbody rb;

    private void FixedUpdate()
    {
        rb.AddForce(direction * force);
    }
}
