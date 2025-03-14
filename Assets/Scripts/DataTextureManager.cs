using System;
using UnityEngine;


[ExecuteAlways]
public class DataTextureManager : MonoBehaviour
{
    public static DataTextureManager Instance = null;

    private void Awake()
    {
        if (Instance == null)
            Instance = this;
        else
            Destroy(gameObject);
    }
    
    public delegate void OnRecalculateTexture();
    public OnRecalculateTexture onRecalculateTexture;
    
    [SerializeField] private bool recalculateTextureOnce = false;
    [SerializeField] private bool recalculateTextureConstant = false;

    private void Update()
    {
        if (recalculateTextureOnce || recalculateTextureConstant)
        {
            recalculateTextureOnce = false;
            onRecalculateTexture?.Invoke();
        }
    }
}
