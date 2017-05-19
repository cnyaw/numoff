/*
  CountoffActivity.java
  Count off android.

  Copyright (c) 2015 Waync Cheng.
  All Rights Reserved.

  2015/6/15 Waync created
 */

package weilican.countoff;

import weilican.good.*;

import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.view.Menu;
import android.view.MenuItem;
import java.util.Locale;

public class CountoffActivity extends goodJniActivity
{
  TextToSpeech t1;

  @Override protected void onCreate(Bundle b)
  {
    super.onCreate(b);

    t1 = new TextToSpeech(getApplicationContext(), new TextToSpeech.OnInitListener() {
       @Override
       public void onInit(int status) {
          if(status != TextToSpeech.ERROR) {
             t1.setLanguage(Locale.ENGLISH);
             t1.setSpeechRate(2.5f);
          } else {
            t1 = null;
          }
       }
    });
  }

  @Override protected void DoChooseFile() {
    goodJniLib.create("numoff.good", getAssets());
  }

  protected void handleIntEvent(int i) {
    if (null != t1) {
      switch (i)
      {
      case 10000:
        t1.speak("Game over", TextToSpeech.QUEUE_FLUSH, null);
        break;
      case 20000:
        t1.speak("Level complete", TextToSpeech.QUEUE_FLUSH, null);
        break;
      case 30029:
      case 30030:
      case 30031:
        setLang(i - 30029 + 1);
        break;
      default:
        t1.speak("" + i, TextToSpeech.QUEUE_ADD, null);
        break;
      }
    }
  }

  @Override
  public boolean onCreateOptionsMenu(Menu menu) {
    if (null != t1) {
      menu.add(1, Menu.FIRST, Menu.FIRST, "English");
      menu.add(1, Menu.FIRST + 1, Menu.FIRST + 1, "Japaness");
      menu.add(1, Menu.FIRST + 2, Menu.FIRST + 2, "Chinese");
    }
    return super.onCreateOptionsMenu(menu);
  }

  @Override
  public boolean onOptionsItemSelected(MenuItem item) {
    setLang(item.getItemId());
    return true;
  }

  void setLang(int lang) {
    if (null == t1) {
      return;
    }
    switch (lang)
    {
    case 1:
      t1.setLanguage(Locale.ENGLISH);
      break;
    case 2:
      t1.setLanguage(Locale.JAPANESE);
      break;
    case 3:
      t1.setLanguage(Locale.CHINESE);
      break;
    }
  }
}
