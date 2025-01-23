using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Events;

public class Test : MonoBehaviour
{
    [SerializeField] private GameObject obj0;
    [SerializeField] private GameObject obj1;
    [SerializeField] private float flt0 = 1.0f;

    private static int _cnt = 0;
    private float health;
    private static int x;
    private static int y;
    
    
    private void Start()
    {
        Debug.Log("Test");
        Foo();
    }

    public static void Foo()
    {
        Debug.Log("Foo" + _cnt);
        _cnt++;
    }

    public static void Something()
    {
    
    // Avoid
    if (x == y) {
        // Do something
    }
    // Prefer
    if (x == y) 
    {
        // Do something
    }


    }

    // Prefer
    public float Health { get { return health; } }
}


public class MyClass : MonoBehaviour
{
    private class MyNestedClass
    {
        //...
    }

    private const int SOME_CONSTANT = 1;

    public enum SomeEnum
    {
        FirstElement,
        SecondElement
    }

    public int SomeProperty
    {
        get => someField;
    }

    private int someField;

    

    public void SomePublicMethod()
    {
        //...
    }

    private void SomePrivateMethod()
    {
        //...
    }

    // Initialization
    private void Initialize()
    {
        //...
    }

    // Core functionality
    private void Move(Vector3 direction)
    {
        //...
    }

    // Helper
    private bool CheckIfPositionIsWalkable(Vector3 position)
    {
        //...
        return false;
    }
    
    public const int MAX_SCENE_OBJECTS = 256;


    

    public Action OnDeath;
    public UnityAction OnDeath2;



    public int publicVariable;

    public class Bullet
    {
        public void Fire()
        {
            //...
        }
    }

    [Serializable]
    public class Bullets
    {
        public Bullet fireBullet;
        public Bullet iceBullet;
        public Bullet windBullet;
    }

    private void Start()
    {
        Bullets bullets = new Bullets();
    }

    
}



