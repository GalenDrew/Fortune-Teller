using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class audioManager : MonoBehaviour
{
    public static audioManager Instance;
    AudioSource source;

    public AudioClip cardFlip;
    public AudioClip typing;

    public float pitchVarience = 0.1f;
    // Start is called before the first frame update
    void Start()
    {
        Instance = this;
        source = GetComponent<AudioSource>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void playCardFlip()
    {
        playSound(cardFlip);
    }

    public void playTypeOut()
    {
        playSound(typing);
    }

    public void playSound(AudioClip clip)
    {
        source.clip = clip;
        source.pitch = 1 + Random.Range(-pitchVarience, pitchVarience);
        source.Play();
    }
}
