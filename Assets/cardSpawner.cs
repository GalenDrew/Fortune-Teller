using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using NaughtyAttributes;

public class cardSpawner : MonoBehaviour
{
    public Animator Anim;

    public int maxCards;
    public int pickedCard;
    public Material[] cardMat;

    public TextScrob textContent;
    public TMP_Text text;
    public enum cardStates { preDraw, drawing, drawn };
    public cardStates currentCardState;

    public Vector2Int cardIndex;
    string story;

    public float waitBetweenLetters = 0.125f;

    Coroutine curentTypeout;
    // Start is called before the first frame update
    void Start()
    {
        text.text = "";
        text.enabled = false;
    }

    // Update is called once per frame
    void Update()
    {
       
        if (Input.GetKeyDown(KeyCode.Space))
        {
            if (currentCardState == cardStates.preDraw)
            {
                pickCard();
            }
            if (currentCardState == cardStates.drawn)
            {
                ResetCard();
                
            }
            //Anim.SetTrigger("Reset");
            
        }
       
    }
    [Button("set card")]
    public void debugSetCard()
    {
        setCard();
        string newText = textContent.content[pickedCard].title + "  \n  " + textContent.content[pickedCard].description;
        text.text = newText;
    }


   
    public void setCard()
    {
        
        
        for (int i = 0; i < cardMat.Length; i++)
        {
            int rows = (int)cardMat[i].GetInt("_Rows");
            int columns = (int)cardMat[i].GetInt("_Columns");
            cardIndex = new Vector2Int((int)Mathf.Repeat(pickedCard, rows), pickedCard / rows);
            cardMat[i].SetInt("_Xindex", cardIndex.x); 
            cardMat[i].SetInt("_Yindex", cardIndex.y);
           
        }
    }


    public void pickCard()
    {
        currentCardState = cardStates.drawing;
        Anim.SetTrigger("Reveal");
        pickedCard = Random.Range(0, maxCards);
        setCard();
       
        //print((int)Mathf.Repeat(pickedCard, rows) + ", " + pickedCard % columns);

    }


    
    public void showText()
    {
        text.enabled = true;
        string newText = textContent.content[pickedCard].title + "  \n  "+  "9" + textContent.content[pickedCard].description;

        curentTypeout =  StartCoroutine(typeOut(newText));
    }

    private void ResetCard()
    {
        currentCardState = cardStates.preDraw;
        Anim.SetTrigger("Reset");
        StopCoroutine(curentTypeout);
        text.text = "";
        text.enabled = false;
       
    }

    public void finishedAnim()
    {
        currentCardState = cardStates.drawn;
    }

    IEnumerator typeOut(string newText)
    {
       
        text.text = "";

        foreach (char c in newText)
        {
            if (char.IsNumber(c))
            {
                text.text += "<size=-8>";
            }
            else
            {
                text.text += c;
            }
            
            yield return new WaitForSeconds(waitBetweenLetters);
        }
    }
}
