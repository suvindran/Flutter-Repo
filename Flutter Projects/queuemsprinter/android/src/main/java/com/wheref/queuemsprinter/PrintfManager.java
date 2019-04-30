package com.wheref.queuemsprinter;

import android.annotation.SuppressLint;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.os.Message;

import com.android.print.sdk.PrinterConstants;
import com.android.print.sdk.PrinterInstance;
import com.android.print.sdk.CanvasPrint;
import com.android.print.sdk.FontProperty;
import com.android.print.sdk.PrinterType;
import com.android.print.sdk.PrinterConstants.Command;
import com.github.promeg.pinyinhelper.Pinyin;

import org.apache.commons.codec.binary.Hex;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.IOException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Set;

public class PrintfManager {

    private static PrinterInstance mPrinter;
    private static PrintfManager instance;
    private boolean connected = false;
    private static Context context;

    private PrintfManager(){}

    public static PrintfManager getInstance(Context ctx){
        
        context = ctx;
        instance = (instance==null)?new PrintfManager():instance;
        return instance;
    }

    public boolean connect(String address) {
        System.out.println("--connect address is "+address);
        BluetoothAdapter defaultAdapter = BluetoothAdapter.getDefaultAdapter();
        Set<BluetoothDevice> bondedDevices = defaultAdapter.getBondedDevices();
        for (BluetoothDevice device : bondedDevices) {
            if (device.getAddress().equals(address)) {
                mPrinter = new PrinterInstance(context, device, mHandler);
                mPrinter.openConnection();
                connected = true;
            }
        }
        return connected;
    }

    public boolean disconnect(){
        if (mPrinter != null) {
            mPrinter.closeConnection();
            mPrinter = null;
            connected = false;
        }
        return connected;
    }

    public boolean checkConnection(){

        System.out.println("--checkConnectuion "+ connected);
        return connected;
    }

    public final static int WIDTH_PIXEL_58 = 384; // 58mm型号打印机实际可用是48mm，48*8=384px
    public final static int WIDTH_PIXEL_80 = 576; // 80mm型号打印机实际可用是72mm，72*8=576px

    



    public void printToken(final String tokenLetter,
                          final String tokenNumber) {
        try {
            CanvasPrint cp = new CanvasPrint();
            cp.init(PrinterType.TIII);
            FontProperty fp = new FontProperty();
            fp.setFont(false, false, false, false, 100, null);
            cp.setFontProperty(fp);
            cp.drawText(tokenLetter+"-"+tokenNumber);
            mPrinter.printImage(cp.getCanvasImage());
            printfWrap(3);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static byte[] bitmap2PrinterBytes(Bitmap bitmap, int left) {
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        byte[] imgbuf = new byte[(width / 8 + left + 4) * height];
        byte[] bitbuf = new byte[width / 8];
        int[] p = new int[8];
        int s = 0;
        System.out.println("+++++++++++++++ Total Bytes: " + (width / 8 + 4) * height);

        for (int y = 0; y < height; ++y) {
            int n;
            for (n = 0; n < width / 8; ++n) {
                int value;
                for (value = 0; value < 8; ++value) {
                    int grey = bitmap.getPixel(n * 8 + value, y);
                    int red = ((grey & 0x00FF0000) >> 16);
                    int green = ((grey & 0x0000FF00) >> 8);
                    int blue = (grey & 0x000000FF);
                    int gray = (int) (0.29900 * red + 0.58700 * green + 0.11400 * blue); // 灰度转化公式
                    if (gray <= 190) {
                        gray = 1;
                    } else {
                        gray = 0;
                    }
                    p[value] = gray;
                }
                value = p[0] * 128 + p[1] * 64 + p[2] * 32 + p[3] * 16 + p[4] * 8 + p[5] * 4 + p[6] * 2 + p[7];
                bitbuf[n] = (byte) value;
            }

            if (y != 0) {
                ++s;
                imgbuf[s] = 22;
            } else {
                imgbuf[s] = 22;
            }

            ++s;
            imgbuf[s] = (byte) (width / 8 + left);

            for (n = 0; n < left; ++n) {
                ++s;
                imgbuf[s] = 0;
            }

            for (n = 0; n < width / 8; ++n) {
                ++s;
                imgbuf[s] = bitbuf[n];
            }

            ++s;
            imgbuf[s] = 21;
            ++s;
            imgbuf[s] = 1;
        }

        return imgbuf;
    }

    public static int getCenterLeft(int paperWidth, Bitmap bitmap) {
        //计算居中的边距
        // Calculate the central margin
        int width = bitmap.getWidth();
        //计算出图片在纸上宽度 单位为mm   8指的是1mm=8px
        //Calculating the width of the picture on paper in mm 8 means 1 mm = 8 PX
        float bitmapPaperWidth = width / 8F;
        //79为真实纸宽
        // 79 for real paper width.
        return (int) (paperWidth / 2F - bitmapPaperWidth / 2);
    }

    private void printTabSpace(int length) throws IOException {
        StringBuilder space1 = new StringBuilder();
        for (int i = 0; i < length; i++) {
            space1.append(" ");
        }
        mPrinter.sendByteData(space1.toString().getBytes());
    }

    private void printText(String text) throws IOException {
        mPrinter.sendByteData(getGbk(text));
    }

    private void printPlusLine_50() throws IOException {
        printText("- - - - - - - - - - - - - - - -\n");
    }

    private void printPlusLine_80() throws IOException {
        printText("- - - - - - - - - - - - - - - - - - - - - - -\n");
    }

    private void printTwoColumn(String title, String content, boolean is58mm) throws IOException {
        int iNum = 0;
        byte[] byteBuffer = new byte[100];
        byte[] tmp;

        tmp = getGbk(title);
        System.arraycopy(tmp, 0, byteBuffer, iNum, tmp.length);
        iNum += tmp.length;

        tmp = setLocation(getOffset(content, is58mm));
        System.arraycopy(tmp, 0, byteBuffer, iNum, tmp.length);
        iNum += tmp.length;

        tmp = getGbk(content);
        System.arraycopy(tmp, 0, byteBuffer, iNum, tmp.length);

        mPrinter.sendByteData(byteBuffer);
    }

    private int getOffset(String str, boolean is58mm) {
        return ((is58mm)?WIDTH_PIXEL_58:WIDTH_PIXEL_80) - getStringPixLength(str);
    }

    private byte[] getGbk(String stText) throws IOException {
        byte[] returnText = stText.getBytes("GBK"); // 必须放在try内才可以
        //byte[] returnText = stText.getBytes();
        //byte[] returnText = stText.getBytes("gb2312");
        return returnText;
    }

    private void printfWrap() throws IOException {
        printfWrap(1);
    }

    private void printfWrap(int lineNum) throws IOException {
        StringBuilder line = new StringBuilder();
        for (int i = 0; i < lineNum; i++) {
            line.append(" \n");
        }
        mPrinter.sendByteData(line.toString().getBytes());
    }

    private byte[] setLocation(int offset) throws IOException {
        byte[] bs = new byte[4];
        bs[0] = 0x1B;
        bs[1] = 0x24;
        bs[2] = (byte) (offset % 256);
        bs[3] = (byte) (offset / 256);
        return bs;
    }

    private int getStringPixLength(String str) {
        int pixLength = 0;
        char c;
        for (int i = 0; i < str.length(); i++) {
            c = str.charAt(i);
            if (Pinyin.isChinese(c)) {
                pixLength += 24;
            } else {
                pixLength += 12;
            }
        }
        return pixLength;
    }

    public static String stampToDate(long timeMillis) {
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyyMMdd HH:mm");
        Date date = new Date(timeMillis);
        return simpleDateFormat.format(date);
    }

    @SuppressLint("HandlerLeak")
    public Handler mHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
        switch (msg.what) {
            case PrinterConstants.Connect.SUCCESS://成功
                connected = true;
                break;
            case PrinterConstants.Connect.FAILED://失败
                connected = false;
                break;
            case PrinterConstants.Connect.CLOSED://关闭
                connected = false;
                break;
        }
        }
    };
}
