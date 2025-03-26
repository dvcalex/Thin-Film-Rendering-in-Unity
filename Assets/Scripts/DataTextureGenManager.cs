using System;
using UnityEngine;


public class DataTextureGenManager : MonoBehaviour
{
    public static DataTextureGenManager Instance = null;

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
