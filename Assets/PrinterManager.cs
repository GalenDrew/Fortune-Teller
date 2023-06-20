using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ESCPOS_NET;
using ESCPOS_NET.Utils;
using ESCPOS_NET.Emitters;
using ESCPOS_NET.Extensions;
using ESCPOS_NET.Utilities;

using NaughtyAttributes;

public class PrinterManager : MonoBehaviour
{

    SerialPrinter printer;

    // Start is called before the first frame update
    void Start()
    {
        // USB, Bluetooth, or Serial
        printer = new SerialPrinter(portName: "COM5", baudRate: 115200);
    }

    [Button("testPrint")]
    public void testPrint()
    {
        var e = new EPSON();
        printer.Write( // or, if using and immediate printer, use await printer.WriteAsync
          ByteSplicer.Combine(
            e.CenterAlign(),
            e.PrintLine("B&H PHOTO & VIDEO")
        
             )
            );
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
