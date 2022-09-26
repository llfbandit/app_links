package com.llfbandit.app_links;

import android.content.Intent;
import android.os.Parcel;
import android.util.Log;

import org.microg.safeparcel.SafeParcelReader;

public class AppLinksHelper {
    private static final String FIREBASE_DYNAMIC_LINKS_DATA = "com.google.firebase.dynamiclinks.DYNAMIC_LINK_DATA";

    private static final String TAG = "com.llfbandit.app_links";

    public static String getDeepLinkFromIntent(Intent intent) {
        String shortLink = getShortDeepLink(intent);
        Log.d(TAG, "handleIntent: (Action) " + intent.getExtras().toString());
        Log.d(TAG, "handleIntent: (Action) " + intent.getData().toString());

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
        Parcel parcel = Parcel.obtain();
        parcel.unmarshall(bytes, 0, bytes.length);
        parcel.setDataPosition(0);

        int end = SafeParcelReader.readObjectHeader(parcel);

        while (parcel.dataPosition() < end) {
            int header = parcel.readInt();
            switch (SafeParcelReader.getFieldId(header)) {
                case 1:
                case 2:
                    return SafeParcelReader.readString(parcel, header);
                default:
                    Log.d(TAG, "Nothing to show");
                    break;
            }
        }

        return null;
    }

    private static String getUrl(Intent intent) {
        String action = intent.getAction();
        String dataString = intent.getDataString();

        Log.d(TAG, "handleIntent: (Action) " + intent.getExtras().toString());
        Log.d(TAG, "handleIntent: (Data) " + dataString);

        return dataString;
    }
}
