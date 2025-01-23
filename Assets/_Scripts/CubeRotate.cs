using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class CubeRotate : MonoBehaviour
{
    [SerializeField] private float rotateAmountUp;
    [SerializeField] private float rotateAmountForward;
    [SerializeField] private float rotateAmountRight;

    private void Update()
    {
        this.transform.Rotate(Vector3.up, Time.deltaTime * rotateAmountUp);
        this.transform.Rotate(Vector3.forward, Time.deltaTime * rotateAmountForward);
        this.transform.Rotate(Vector3.right, Time.deltaTime * rotateAmountRight);
    }
}
