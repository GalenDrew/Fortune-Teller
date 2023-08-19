using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using NaughtyAttributes;
using SmartDLL;

public class PrinterManager : MonoBehaviour
{
    public SmartPrinter smartPrinter = new SmartPrinter();
    public string headerDirectory;

    [Button("test print")]
    public void printDoc()
    {
        smartPrinter.PrintDocument("test Print", headerDirectory);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
