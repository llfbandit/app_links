package com.llfbandit.app_links;

import static android.content.Intent.ACTION_SEND;
import static android.content.Intent.ACTION_SENDTO;
import static android.content.Intent.ACTION_SEND_MULTIPLE;

import android.content.Intent;
import android.os.Parcel;
import android.util.Log;

import org.microg.safeparcel.SafeParcelReader;

public class AppLinksHelper {
  private static final String FIREBASE_DYNAMIC_LINKS_DATA = "com.google.firebase.dynamiclinks.DYNAMIC_LINK_DATA";

  private static final String TAG = "com.llfbandit.app_links";

  public static String getDeepLinkFromIntent(Intent intent) {
    String shortLink = getShortDeepLink(intent);

    if (shortLink != null) {
      Log.d(TAG, "handleIntent: (Data) (short deep link)" + shortLink);
      return shortLink;
    }


    return getUrl(intent);
  }

  // When the deeplink comes from Firebase Dynamics Link we need to read the Intent extra data to get the short link.
  // This is inspired by how the Firebase Dynamic Links library works. More information on how to get
  // deeplink extra data: https://developer.android.com/training/app-links/deep-linking#handling-intents
  private static String getShortDeepLink(Intent intent) {
    byte[] bytes = intent.getByteArrayExtra(FIREBASE_DYNAMIC_LINKS_DATA);

    if (bytes == null || bytes.length == 0) {
      return null;
    }

    Parcel parcel = Parcel.obtain();
    parcel.unmarshall(bytes, 0, bytes.length);
    parcel.setDataPosition(0);

    int header = parcel.readInt();
    return SafeParcelReader.readString(parcel, header);
  }

  private static String getUrl(Intent intent) {
    String action = intent.getAction();

    if (ACTION_SEND.equals(action) ||
        ACTION_SEND_MULTIPLE.equals(action) ||
        ACTION_SENDTO.equals(action)) {
      return null;
    }

    String dataString = intent.getDataString();

    if (dataString != null) {
      Log.d(TAG, "Handled intent: action: " + action + " / data: " + dataString);
    }

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
