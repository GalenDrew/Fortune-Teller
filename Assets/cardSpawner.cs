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
    bool timeoutTimerActive;
    [ReadOnly]
    public float timeOutTimer = 0;
    
    public float timeoutCount = 600;

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

        if (Input.GetKeyDown(KeyCode.Escape))
        {
            Application.Quit();
        }

        if (Input.GetKeyDown(KeyCode.Space) || Input.GetButtonDown("Fire1"))
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
        if (currentCardState == cardStates.drawn)
        {
            
            timeoutTimerActive = true;
            if (timeoutTimerActive)
            {
                if (timeOutTimer < timeoutCount)
                {
                    timeOutTimer += 0.1f;
                }
                else
                {
                  
                    ResetCard();
                }

            }
            else
            {
                
                ResetCard();
            }
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
        string newText = " <uppercase> <b>" + textContent.content[pickedCard].title + "  \n  " + "<size= 15>" + textContent.content[pickedCard].subtitle;
            /*"</uppercase> </b> <typeSpeed = 1.5 > <alpha=#66>" + textContent.content[pickedCard].description;*/

        curentTypeout =  StartCoroutine(typeOut(newText));
    }

    private void ResetCard()
    {
        currentCardState = cardStates.preDraw;
        Anim.SetTrigger("Reset");
        StopCoroutine(curentTypeout);
        text.text = "";
        text.enabled = false;
        timeOutTimer = 0;
        timeoutTimerActive = false;
        playCardFlipSFX();
    }

    public void finishedAnim()
    {
        currentCardState = cardStates.drawn;
    }

    IEnumerator typeOut(string newText)
    {
        bool doPrint = true;
        
        text.text = "";

        float typeSpeedMult = 1;
        string loggedWord = "";

        bool soundAlt = false;
        foreach (char c in newText)
        {
            bool printNext = false;
            

            if(c == "<".ToCharArray()[0])
            {
                doPrint = false;
            }
            
            if (!doPrint)
            {

               loggedWord += c;
                if (loggedWord.Contains("<typeSpeed =") && loggedWord.Contains(">"))
                {

                    float typeMult = 1;
                    bool hasNum = false;
                    string splitString = loggedWord.Split(char.Parse(" "))[2];
                    
                    hasNum = float.TryParse(splitString, out typeMult);
                    print(splitString + typeMult);
                    if (hasNum)
                    {
                        typeSpeedMult = typeMult;
                        loggedWord = "";
                    }
                }
               

            }
            if (c == ">".ToCharArray()[0])
            {
                printNext = true;
            }
                
            if (doPrint )
            {
                text.text += c;
                soundAlt = !soundAlt;
                if (soundAlt && c.ToString() != " ")
                {
                    audioManager.Instance.playTypeOut();
                }
                

             
                

            }
            if (printNext)
            {
                text.text += loggedWord;
                loggedWord = "";
                doPrint = true;
            }



            if (doPrint)
            {
                yield return new WaitForSeconds(waitBetweenLetters/typeSpeedMult);
            }
        }
    }
    public void playCardFlipSFX()
    {
        
        audioManager.Instance.playCardFlip();
    }
}
