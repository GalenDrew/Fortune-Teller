using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

[CreateAssetMenu(fileName = "Data", menuName = "ScriptableObjects/TextScrob", order = 1)]

public class TextScrob : ScriptableObject
{
    public textContent[] content;
   
}

[Serializable]
public class textContent
{
    public string title;
    public string description;
}
