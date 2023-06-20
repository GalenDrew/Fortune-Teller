using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class curlController : MonoBehaviour
{
    public MeshRenderer meshRenderer;

    public float curlAmount;
    public float parallaxAmount;
    // Start is called before the first frame update
    void Start()
    {
         
    }

    // Update is called once per frame
    void Update()
    {
        meshRenderer.sharedMaterial.SetFloat("_curlAmount", curlAmount);
        meshRenderer.sharedMaterial.SetFloat("_parallaxAmount", parallaxAmount);
    }
}
