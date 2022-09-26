package com.llfbandit.app_links;

import android.content.Intent;
import android.os.Parcel;
import android.util.Log;
import androidx.annotation.NonNull;

public class AppLinksHelper {
    private static final String EXTRA_DATA_NAME = "com.google.firebase.dynamiclinks.DYNAMIC_LINK_DATA";

    private static final String TAG = "com.llfbandit.app_links";

    public String getDeepLinkFromIntent(Intent intent) {
        String shortLink = getShortDeepLink(intent);

        if (shortLink != null) {
            Log.d(TAG, "handleIntent: (Data) (short deep link)" + shortLink);
            return shortLink;
        }


        return getUrl(intent);
    }

    private String getShortDeepLink(Intent intent) {
        byte[] bytes = intent.getByteArrayExtra(EXTRA_DATA_NAME);
        Parcel parcel = Parcel.obtain();
        parcel.unmarshall(bytes, 0, bytes.length);
        parcel.setDataPosition(0);

        int end = validateObjectHeader(parcel);

        while (parcel.dataPosition() < end) {
            int header = parcel.readInt();
            switch (getFieldId(header)) {
                case 1:
                case 2:
                    String shortLink = createString(parcel, header);
                    return shortLink;
                default:
                    Log.d(TAG, "Nothing to show");
                    break;
            }
        }

        return null;
    }

    private String getUrl(Intent intent) {
        String action = intent.getAction();
        String dataString = intent.getDataString();

        Log.d(TAG, "handleIntent: (Action) " + action);
        Log.d(TAG, "handleIntent: (Data) " + dataString);

        return dataString;
    }

    private int readSize(Parcel parcel, int header) {
        if ((header & 0xFFFF0000) != 0xFFFF0000)
            return header >> 16 & 0xFFFF;
        return parcel.readInt();
    }

    public int validateObjectHeader(@NonNull Parcel p) {
        int var1 = p.readInt();
        int var2 = readSize(p, var1);
        int var3 = p.dataPosition();
        if (getFieldId(var1) != 20293) {
            throw new NullPointerException();
        } else {
            var1 = var3 + var2;
            if (var1 >= var3 && var1 <= p.dataSize()) {
                return var1;
            } else {
                StringBuilder var4 = new StringBuilder();
                var4.append("Size read is invalid start=");
                var4.append(var3);
                var4.append(" end=");
                var4.append(var1);
                throw new NullPointerException();
            }
        }
    }

    private int getFieldId(int header) {
        return header & 0xFFFF;
    }

    @NonNull
    private String createString(@NonNull Parcel p, int header) {
        header = readSize(p, header);
        int var2 = p.dataPosition();
        if (header == 0) {
            return null;
        } else {
            String var3 = p.readString();
            p.setDataPosition(var2 + header);
            return var3;
        }
    }
}
