package com.llfbandit.app_links;

import static android.content.Intent.ACTION_SEND;
import static android.content.Intent.ACTION_SENDTO;
import static android.content.Intent.ACTION_SEND_MULTIPLE;

import android.content.Intent;

public class AppLinksHelper {

  public static String getUrl(Intent intent) {
    String action = intent.getAction();

    if (ACTION_SEND.equals(action) ||
        ACTION_SEND_MULTIPLE.equals(action) ||
        ACTION_SENDTO.equals(action)) {
      return null;
    }

    String dataString = intent.getDataString();

    return dataString;

//    if (ACTION_SEND.equals(action)) {
//      Bundle extras = intent.getExtras();
//
//      if (extras != null) {
//        if (extras.containsKey(Intent.EXTRA_TEXT)) {
//          CharSequence charSeq = extras.getCharSequence(Intent.EXTRA_TEXT);
//          if (charSeq != null) {
//            dataString = charSeq.toString();
//          }
//        } else if (extras.containsKey(Intent.EXTRA_STREAM)) {
//          Uri uri = (Uri) extras.getParcelable(Intent.EXTRA_STREAM);
//          if (uri != null) {
//            dataString = uri.toString();
//          }
//        }
//      }
//    }
  }
}
